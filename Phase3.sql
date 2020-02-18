/* VIEWS */
/* Create a database view named CriticalCases that selects the patients who have been admitted to Intensive Care Unit(ICU) at least 2 times. The view columns should be: Patient_SSN, firstName, lastName, numberOfAdmissionsToICU. Hint:ICU is a service that is stored intable ‘RoomService’ */
CREATE VIEW CriticalCases AS 
	SELECT Patient_SSN, FirstName, LastName, numberOfAdmissionsToICU
		FROM(SELECT Patient_SSN, COUNT (*) AS numberOfAdmissionsToICU
		     FROM (SELECT AdmissionNum
			   FROM (SELECT roomNum 
			         FROM RoomService
			         WHERE service='ICU') R1, StayIn
			   WHERE R1.roomNum=StayIn.roomNum) R2, Admission
		      WHERE R2.AdmissionNum=Admission.Num
		      GROUP BY Patient_SSN) R3, Patient P
	WHERE R3.Patient_SSN=P.SSN AND R3.numberOfAdmissionsToICU>=2;

/* Create a Database view  named DoctorsLoad that reports for each doctor whether this doctor has an overload or not. A doctor has an overload if (s)he has more  than  10  distinct  admission  cases,  otherwise  the  doctor  has  an  underload. Notice that if a doctor examined a patient multiple times in the same admission, that still counts  as one admission case.  The view  columns should be: DoctorID,gender, load.
The load column should have either of these two values ‘Overloaded’, or‘Underloaded’ according to the definition above. */
CREATE VIEW DoctorsLoad AS
	SELECT DoctorID, gender, load
	FROM(SELECT DoctorID, 'Overloaded' AS load
             FROM (SELECT DoctorID, COUNT(*) AS PatientCnt
	           FROM Examine
	           GROUP BY DoctorID)
	     WHERE PatientCnt>10
	     UNION
	     SELECT DoctorID, 'Underloaded' AS load
             FROM (SELECT DoctorID, COUNT(*) AS PatientCnt
	           FROM Examine
	           GROUP BY DoctorID)
	     WHERE PatientCnt<=10) R1, Doctor
	WHERE R1.DoctorID=Doctor.ID;

/* Use the views created above (you may need the original tables as well) to report the critical-case patients with number of admissions to ICU greater than 4.  */
SELECT *
FROM CriticalCases
WHERE numberOfAdmissionsToICU>4;

/* Use the views created above (you may need the original tables as well) to report the female overloaded doctors. You should report the doctorID, firstName, and lastName. */
SELECT DoctorID, firstName, lastName
FROM (SELECT DoctorID
      FROM DoctorsLoad 
      WHERE load='Overloaded' AND gender='F') R1, Doctor
WHERE R1.DoctorID = Doctor.ID;

/* Use the views created above (you may need the original tables as well) to report the  comments  inserted  by  underloaded  doctors  when  examining  critical-case patients. You should report the doctorID, patient SSN, and the comment. */
SELECT R3.DoctorID, C.Patient_SSN, comments
FROM (SELECT DoctorID, Patient_SSN, comments
      FROM (SELECT R1.DoctorID, AdmissionNum, comments
            FROM (SELECT DoctorID 
                  FROM DoctorsLoad
                  WHERE load='Underloaded')R1, Examine E
            WHERE R1.DoctorID = E.DoctorID)R2, Admission A
      WHERE R2.AdmissionNum = A.Num)R3, CriticalCases C
WHERE R3.Patient_SSN = C.Patient_SSN;

/* TRIGGERS */
/* If a doctor visits a patient in the ICU, they must leave a comment. */
/*Untested*/
CREATE OR REPLACE TRIGGER DocComments
BEFORE INSERT ON Examine
FOR EACH ROW
DECLARE
	cursor C1 is SELECT service FROM(Select roomNum FROM StayIn WHERE AdmissionNum = :new.AdmissionNum) R ,RoomService WHERE R.roomNum = RoomService.roomNum;
BEGIN
	For rec In C1 Loop
		IF(:new.comments IS NULL AND rec = 'ICU') THEN
			RAISE_APPLICATION_ERROR(-20004,'Error: Must have comments for patient in ICU.');
		END IF;
	End Loop;
END;
/
/* The  insurance  payment  should  be  calculated  automatically  as  65%  of  the  total payment.  
If  the  total  payment  changes  then  the  insurance  amount  should  also change. 
If in your DB you store the insurance payment as a percent, then it shouldbe always set to 65%.*/

CREATE OR REPLACE TRIGGER InsuranceVal
BEFORE INSERT OR UPDATE ON Admission
FOR EACH ROW
BEGIN
	:new.InsurancePayment= :new.TotalPayment * 0.65;
END;
/

/* Ensure  that  regular  employees  (with  rank  0)  must  have  their  supervisors  as division  managers  (with  rank  1).  
Also  each  regular  employee  must  have  a supervisor at all times. Similarly, division managers (with rank 1) 
must have their supervisors as general managers  (with  rank  2).  Division  managers  must  have  supervisors  at  all  times. 
General Managers must not have any supervisors.*/
CREATE OR REPLACE TRIGGER EmployeeSuperversion
BEFORE INSERT OR UPDATE On Employee
FOR EACH ROW
DECLARE 
	supervisorRank;
BEGIN
	IF(:new.empRANK<2) THEN
		IF(:new.supervisorID IS NULL) THEN
			RAISE_APPLICATION_ERROR(-20005,'Error: regular employees and division managers must have supervisors.');
		END IF;

		IF(:new.supervisorID IS NOT NULL) THEN
			SELECT empRANK INTO supervisorRank FROM Employee WHERE :new.supervisorID=Employee.ID;
			IF(:new.empRANK=0 AND supervisorRank!=1) THEN
				RAISE_APPLICATION_ERROR(-20007,'Error: regular employees should have division managers as their supervisor.');
			END IF;
			IF(:new.empRANK=1 AND supervisorRank!=2) THEN
				RAISE_APPLICATION_ERROR(-20008,'Error: division managers should have general managers as their supervisor.');
			END IF;
		END IF;

	END IF;

	IF(:new.empRANK=2) THEN
		IF(:new.supervisorID IS NOT NULL) THEN
			RAISE_APPLICATION_ERROR(-20006,'Error: General Managers should not have a supervisor.');
		END IF;
	END IF;
END;
/

/* When a patient is admitted to an Emergency Room (a room with an Emergency service) on date  D,  
the futureVisitDate should be automatically set to 2 months after that date, i.e., D + 2 months. 
The futureVisitDate may be manually changed later, but when the Emergency Room admission happens, the date should be set to default as mentioned above. */

CREATE OR REPLACE TRIGGER DefaultEmergencyFutureVisit
BEFORE INSERT ON StayIn
FOR EACH ROW
DECLARE
	cursor C1 is SELECT roomNum FROM RoomService WHERE service = 'Emergency Room';
BEGIN
	FOR rec in C1 Loop
		IF(:new.RoomNum = rec) THEN
			UPDATE Admission
			SET FutureVisit=ADD_MONTHS(:new.startDate, 2)
			WHERE Num = :new.AdmissionNum;
		END IF;
	End Loop;
END;
/

/* If a piece of equipment is of type ‘CT Scanner’ or ‘Ultrasound’, then the purchase year must be not null and after 2006. */
CREATE OR REPLACE TRIGGER CTUtltraPurchaseYear
BEFORE INSERT OR UPDATE ON Equipment
FOR EACH ROW
DECLARE
	CTID CHAR(20);
	UltraID CHAR(20);
BEGIN
	SELECT ID INTO CTID FROM EquipmentType WHERE description='CT Scanner';
	SELECT ID INTO UltraID FROM EquipmentType WHERE description='Ultrasound';

	IF(:new.TypeID=CTID OR :new.TypeID=UltraID) THEN
		IF(:new.purchaseYear<=2006) THEN
			RAISE_APPLICATION_ERROR(-20009,'Error: Purchase of Ultrasound and CT Scanner cannot be in and before 2006');
		END IF;
	END IF;
END;
/

/* When a patient leaves the hospital (Admission leave time is set), print out the patient’s first and last name, 
address, all of the comments from doctors involved in that admission, and which doctor (name) left each comment.
Hint: Use function dbms_output.put_line() also make sure to run the following line so you can see the output lines.
Sql> set serveroutput on;*/

SET serveroutput ON;
CREATE OR REPLACE TRIGGER 
BEFORE UPDATE OF LeaveDate ON Admission
FOR EACH ROW
WHEN (new.LeaveDate IS NOT NULL)
DECLARE
	PatientFirstName Char(20);
	PatientLastName Char(20);
	PatientAddress Char(20);
	cursor c1 is SELECT DoctorID FROM Examine WHERE :new.Num = Examine.AdmissionNum;
BEGIN
	SELECT FirstName Into PatientFirstName From Patient Where SSN=:new.Patient_SSN; 
	SELECT LastName Into PatientLastName From Patient Where SSN=:new.Patient_SSN;
	SELECT Address Into PatientAddress From Patient Where SSN=:new.Patient_SSN;
	dbms_output.put_line('Patient First Name: ' || PatientFirstName);
	dbms_output.put_line('Patient Last Name: '|| PatientLastName);
	dbms_output.put_line('Patient Address: '|| PatientAddress);  
	FOR rec in c1 Loop
		dbms_output.put_line('Doctor:' || Select FirstName From Doctor WHERE ID = rec || ' ' || Select LastName From Doctor WHERE ID = rec);
		dbms_output.put_line('Comments: ' || Select comments From Examine WHERE DoctorID = rec);
	End Loop;
 
END; 
/ 
	 
 





	

