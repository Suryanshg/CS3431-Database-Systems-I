/* Drops all tables and Views*/
DROP VIEW CrticalCases;
DROP VIEW DoctorsLoad;
DROP TABLE StayIn;
DROP TABLE Examine;
DROP TABLE Admission;
DROP TABLE Doctor;
DROP TABLE Patient;
DROP TABLE RoomAccess;
DROP TABLE RoomService;
DROP TABLE Equipment;
DROP TABLE Room;
DROP TABLE EquipmentType;
DROP TABLE Employee;

/* Creates all Tables */
CREATE TABLE Employee(ID CHAR(20) Primary Key,
                FName CHAR(20) NOT NULL,
                LNAME CHAR(20) NOT NULL,
                Salary REAL CHECK(Salary>0),
                jobTitle CHAR(30),
                OfficeNum INTEGER,
                empRANK INTEGER CHECK(empRank>=0 AND empRank<=2),
                supervisorID CHAR(20));
CREATE TABLE EquipmentType(ID CHAR(20) Primary Key,
                description CHAR(20),
                model CHAR(20) UNIQUE,
                instructions CHAR(20),
                numberOfUnits INTEGER);

CREATE TABLE Room(Num INTEGER Primary Key,
                occupied CHAR(1) CHECK(occupied in ('Y','N')));

CREATE TABLE Equipment(Serial# CHAR(20) Primary Key,
                TypeID CHAR(20),
                purchaseYear INTEGER NOT NULL,
                LastInspection Date,
                roomNum INTEGER,
                Foreign Key (TypeID) REFERENCES EquipmentType(ID),
                Foreign Key (roomNum) REFERENCES Room(Num));

CREATE TABLE RoomService(roomNum INTEGER,
                service CHAR(20),
                Primary Key (roomNum,service),
                Foreign Key (roomNum) REFERENCES Room(Num));
CREATE TABLE RoomAccess(roomNum INTEGER,
                EmpID CHAR(20),
                Primary Key (roomNum,EmpID),
                Foreign Key (roomNum) REFERENCES Room(Num),
                Foreign Key (EmpID) REFERENCES Employee(ID));
CREATE TABLE Patient (SSN CHAR(20) Primary Key,
                FirstName CHAR(20) NOT NULL,
                LastName CHAR(20) NOT NULL,
                Address CHAR(20),
                TelNum CHAR(10) UNIQUE);
CREATE TABLE Doctor (ID CHAR(20) Primary Key,
                gender CHAR(1) CHECK(gender in ('M','F')),
                specialty CHAR(20),
                LastName CHAR(20) NOT NULL,
                FirstName CHAR(20) NOT NULL);
CREATE TABLE Admission (Num INTEGER Primary Key,
                AdmissionDate Date NOT NULL,
                LeaveDate Date,
                TotalPayment REAL,
                InsurancePayment REAL,
                Patient_SSN CHAR(20),
                FutureVisit Date, Foreign Key (Patient_SSN) REFERENCES Patient(SSN));
CREATE TABLE Examine (DoctorID CHAR(20),
                AdmissionNum INTEGER,
                comments CHAR(20),
                Constraint pk Primary Key(DoctorID,AdmissionNum), Foreign Key (DoctorID) REFERENCES Doctor(ID),Foreign Key (AdmissionNum) REFERENCES Admission(Num));
CREATE TABLE StayIn(AdmissionNum INTEGER,
                RoomNum INTEGER,
                startDate Date,
                endDate Date,
                Primary Key(AdmissionNum, RoomNum, startDate), Foreign Key (RoomNum) REFERENCES Room(Num), Foreign Key (AdmissionNum) REFERENCES Admission(Num));


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
		IF(:new.comments IS NULL AND rec.service = 'ICU') THEN
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
	:new.InsurancePayment := :new.TotalPayment * 0.65;
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
	supervisorRank INTEGER;
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
		IF(:new.RoomNum = rec.roomNum) THEN
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
CREATE OR REPLACE TRIGGER PatientDischarge 
BEFORE UPDATE ON Admission
FOR EACH ROW
WHEN (new.LeaveDate IS NOT NULL)
DECLARE
	PatientFirstName CHAR(20);
	PatientLastName CHAR(20);
	PatientAddress CHAR(20);
	cursor c1 is SELECT DoctorID FROM Examine WHERE :new.Num = Examine.AdmissionNum;
	DoctorFirstName CHAR(20);
	DoctorLastName CHAR(20);
	DoctorComments CHAR(20);
BEGIN
	SELECT FirstName Into PatientFirstName From Patient Where SSN=:new.Patient_SSN; 
	SELECT LastName Into PatientLastName From Patient Where SSN=:new.Patient_SSN;
	SELECT Address Into PatientAddress From Patient Where SSN=:new.Patient_SSN;
	dbms_output.put_line('Patient First Name: ' || PatientFirstName);
	dbms_output.put_line('Patient Last Name: '|| PatientLastName);
	dbms_output.put_line('Patient Address: '|| PatientAddress);  
	FOR rec in c1 Loop
		Select FirstName INTO DoctorFirstName From Doctor WHERE ID = rec.DoctorID;
		Select LastName INTO DoctorLastName From Doctor WHERE ID = rec.DoctorID;
		Select comments INTO DoctorComments From Examine WHERE DoctorID = rec.DoctorID;
		dbms_output.put_line('Doctor:' || DoctorFirstName || ' ' || DoctorLastName);
		dbms_output.put_line('Comments: ' || DoctorComments);
	End Loop;
 
END; 
/ 

/* Insert data into all Tables*/
/* Patient Data */
INSERT INTO Patient VALUES ('A','Surya','Goyal','100 Institute Road', '11111');
INSERT INTO Patient VALUES ('B','Ben','Goyal','100 Institute Road', '2222');
INSERT INTO Patient VALUES ('111-22-3333','Casey','Goyal','100 Institute Road', '3333');
INSERT INTO Patient VALUES ('D','Derik','Goyal','100 Institute Road', '4444');
INSERT INTO Patient VALUES ('E','Evan','Goyal','100 Institute Road', '5555');
INSERT INTO Patient VALUES ('F','Ferland','Goyal','100 Institute Road', '6666');
INSERT INTO Patient VALUES ('G','Gigi','Goyal','100 Institute Road', '7777');
INSERT INTO Patient VALUES ('H','Han','Goyal','100 Institute Road', '8888');
INSERT INTO Patient VALUES ('I','Ivan','Goyal','100 Institute Road', '9999');
INSERT INTO Patient VALUES ('J','Jojo','Goyal','100 Institute Road', '1010');

/* Doctor Data */
INSERT INTO Doctor VALUES ('A','F','Physician','Smith','Alex');
INSERT INTO Doctor VALUES ('B','F','Cardiologist','Smith', 'Beth');
INSERT INTO Doctor VALUES ('C','M','Radiologist','Smith', 'Corey');
INSERT INTO Doctor VALUES ('D','F','Dentist','Smith', 'Danielle');
INSERT INTO Doctor VALUES ('E','M','Surgeon','Smith', 'Elon');
INSERT INTO Doctor VALUES ('F','F','Psychiatrist','Smith', 'Fiona');
INSERT INTO Doctor VALUES ('G','M','Physician','Smith', 'Geralt');
INSERT INTO Doctor VALUES ('H','F','Gynaecologist','Smith', 'Hanna');
INSERT INTO Doctor VALUES ('I','M','Pediatrician','Smith', 'Ivan');
INSERT INTO Doctor VALUES ('J','F','Radiologist','Smith', 'Jessica');

/* Room and Service Data */
INSERT INTO Room VALUES (1,'Y');
INSERT INTO Room VALUES (2,'Y');
INSERT INTO Room VALUES (3,'Y');
INSERT INTO Room VALUES (4,'Y');
INSERT INTO Room VALUES (5,'Y');
INSERT INTO Room VALUES (6,'Y');
INSERT INTO Room VALUES (7,'Y');
INSERT INTO Room VALUES (8,'Y');
INSERT INTO Room VALUES (9,'Y');
INSERT INTO Room VALUES (10,'Y');

INSERT INTO RoomService VALUES (1,'Operating Room');
INSERT INTO RoomService VALUES (1,'ICU');
INSERT INTO RoomService VALUES (2,'Pharmacy');
INSERT INTO RoomService VALUES (2,'General Ward');
INSERT INTO RoomService VALUES (3,'Delivery Room');
INSERT INTO RoomService VALUES (3,'Operating Room');
INSERT INTO RoomService VALUES (4,'Emergency Room');

/* Equipment Types and Units */
INSERT INTO EquipmentType VALUES ('X','Scalpel','Sc1','ONLY for Surgeon',3);
INSERT INTO EquipmentType VALUES ('Y','Stethoscope','St1','Hold to Chest',3);
INSERT INTO EquipmentType VALUES ('Z','Syringe','Sy1','Just a prick',10);

INSERT INTO Equipment VALUES ('A01-02X','X', 2020 ,'01-FEB-20',1);
INSERT INTO Equipment VALUES ('2','Y', 1999 ,'01-FEB-20',2);
INSERT INTO Equipment VALUES ('3','Z',2018,'01-FEB-20',1);

INSERT INTO Equipment VALUES ('4','X',2011,'01-FEB-20',1);
INSERT INTO Equipment VALUES ('5','Y',2001,'01-FEB-20',2);
INSERT INTO Equipment VALUES ('6','Z',2019,'01-FEB-20',1);

INSERT INTO Equipment VALUES ('7','X',2010,'01-FEB-20',3);
INSERT INTO Equipment VALUES ('8','Y',2016,'01-FEB-20',3);
INSERT INTO Equipment VALUES ('9','Z',2019,'01-FEB-20',3);

/* Admission */
INSERT INTO Admission VALUES (1,'01-FEB-20', '01-FEB-20' ,500,100.1,'A','02-FEB-20');
INSERT INTO Admission VALUES (2,'10-DEC-19', '31-JAN-20',90.45,0,'A','01-FEB-20');

INSERT INTO Admission VALUES (3,'15-JAN-20', '17-JAN-20' ,300,100.1,'B','10-FEB-20');
INSERT INTO Admission VALUES (4,'11-DEC-19', '01-JAN-20',21.45,10,'B','15-JAN-20');

INSERT INTO Admission VALUES (5,'03-FEB-20', NULL ,100,100,'111-22-3333','08-FEB-20');
INSERT INTO Admission VALUES (6,'29-DEC-19', '31-DEC-19' ,9.45,0,'111-22-3333','03-FEB-20');

INSERT INTO Admission VALUES (7,'30-JAN-20', NULL ,49,0,'D','02-FEB-20');
INSERT INTO Admission VALUES (8,'10-DEC-19', '25-JAN-20' ,90.45,0,'D','30-JAN-20');

INSERT INTO Admission VALUES (9,'10-JAN-20', NULL ,500,100.1,'E','02-FEB-20');
INSERT INTO Admission VALUES (10,'10-DEC-19', '31-JAN-20' ,90.45,0,'E','10-JAN-20');
INSERT INTO Admission VALUES (11, '5-FEB-20', '5-FEB-20', 100, 100, '111-22-3333', '7-FEB-20');
INSERT INTO Admission VALUES (12, '7-FEB-20', '7-FEB-20', 100, 100, '111-22-3333', '8-FEB-20');
INSERT INTO Admission VALUES (13, '8-FEB-20', '8-FEB-20', 100, 100, '111-22-3333', '11-FEB-20');

/* Employees */
INSERT INTO Employee VALUES ('10','Sloan', 'Alan' ,43,'General Admin',1,2,NULL);
INSERT INTO Employee VALUES ('2','Sloan', 'Betty' ,43,'General Admin',2,2,NULL);
INSERT INTO Employee VALUES ('3','Sloan', 'Carl' ,43,'Division Admin',3,1,'2');
INSERT INTO Employee VALUES ('4','Sloan', 'Debra' ,43,'Division Admin',4,1,'10');
INSERT INTO Employee VALUES ('5','Sloan', 'Emily' ,43,'Division Admin',5,1,'10');
INSERT INTO Employee VALUES ('6','Sloan', 'Frederick' ,43,'Custodian Admin',6,1,'2');
INSERT INTO Employee VALUES ('7','Sloan', 'George' ,43,'Secretary',7,0,'3');
INSERT INTO Employee VALUES ('8','Sloan', 'Hannah' ,43,'Secretary',8,0,'3');
INSERT INTO Employee VALUES ('9','Sloan', 'Ian' ,43,'Front Desk receptionist',9,0,'3');
INSERT INTO Employee VALUES ('1','Sloan', 'Jose' ,43,'Nurse',10,0,'4');
INSERT INTO Employee VALUES ('11','Sloan', 'Kim' ,43,'Nurse',11,0,'4');
INSERT INTO Employee VALUES ('12','Sloan', 'Luke' ,43,'Nurse',12,0,'5');
INSERT INTO Employee VALUES ('13','Sloan', 'Morgana' ,43,'Janitor',6,0,'6');
INSERT INTO Employee VALUES ('14','Sloan', 'Nathan' ,43,'Janitor',6,0,'6');
INSERT INTO Employee VALUES ('15','Sloan', 'Lloyd' ,43,'Janitor',6,0,'6');
INSERT INTO Employee VALUES ('16','Sloan', 'XYZ' ,43,'Janitor',6,0,'6');

/* Examinations */
INSERT INTO Examine VALUES ('A',5, 'Treated common cold');
INSERT INTO Examine VALUES ('A',6, 'Have common cold');
INSERT INTO Examine VALUES ('A',11, 'Suspected influenza');
INSERT INTO Examine VALUES ('A',1, 'Treated common cold');
INSERT INTO Examine VALUES ('A',2, 'Have common cold');
INSERT INTO Examine VALUES ('A',3, 'Suspected influenza');
INSERT INTO Examine VALUES ('A',4, 'Treated common cold');
INSERT INTO Examine VALUES ('A',7, 'Have common cold');
INSERT INTO Examine VALUES ('A',8, 'Suspected influenza');
INSERT INTO Examine VALUES ('A',9, 'Treated common cold');
INSERT INTO Examine VALUES ('A',10, 'Have common cold');
INSERT INTO Examine VALUES ('B',5, 'Suspected High BP');
INSERT INTO Examine VALUES ('B',12, 'Prescribed medicines');
INSERT INTO Examine VALUES ('B',6, 'Regular Checkup');
INSERT INTO Examine VALUES ('B',11, 'Regular Checkup');

/* Room Access */
INSERT INTO RoomAccess VALUES (1,'1');
INSERT INTO RoomAccess VALUES (3,'1');
INSERT INTO RoomAccess VALUES (4,'1');
INSERT INTO RoomAccess VALUES (5,'1');
INSERT INTO RoomAccess VALUES (2,'2');
INSERT INTO RoomAccess VALUES (3,'2');
INSERT INTO RoomAccess VALUES (4,'2');
INSERT INTO RoomAccess VALUES (5,'2');
INSERT INTO RoomAccess VALUES (3,'3');
INSERT INTO RoomAccess VALUES (4,'4');
INSERT INTO RoomAccess VALUES (5,'5');

/* Stay In */
INSERT INTO StayIn VALUES (5,1,'03-FEB-20', NULL);
INSERT INTO StayIn VALUES (6,1,'29-DEC-19', '31-DEC-19');
INSERT INTO StayIn VALUES (11,1,'5-FEB-20','5-FEB-20');
INSERT INTO StayIn VALUES (12,1,'7-FEB-20','7-FEB-20');
INSERT INTO StayIn VALUES (13,1,'8-FEB-20','8-FEB-20');
INSERT INTO StayIn VALUES (1,4,'1-FEB-20','1-FEB-20');

/* Queries */
/* Q1 Report the hospital rooms (the room number) that are currently occupied. */
SELECT Num from Room WHERE occupied='Y';

/* Q2 For a given division manager (say, ID = 10), report all regular employees that are supervised by this manager.
Display the employees ID, names, and salary. (Concatenation)*/
SELECT ID, FName || ' ' || LName AS Name, Salary
FROM Employee
WHERE supervisorID='10';

/* Q3 For each patient, report the sum of amounts paid by the insurance company
for that patient, i.e., report the patient's SSN, and the sum of insurance payments over all visits.*/
SELECT Patient_SSN, SUM(InsurancePayment) AS sumOfInsurancePayments
FROM Admission
GROUP BY Patient_SSN;

/* Q4 Report the number of visits done for each patient, i.e., for each patient, report the patient SSN,
first and last names, and the count of visits done by this patient.*/
SELECT Patient_SSN, FirstName, LastName,  NumberOfVisits
FROM (SELECT Patient_SSN, COUNT(*) AS NumberOfVisits
      FROM Admission A
      GROUP BY Patient_SSN) R, Patient P
WHERE R.Patient_SSN=P.SSN;

/* Q5 Report the room number that has an equipment unit with serial number ‘A01-02X’.*/
SELECT roomNum
FROM Equipment
WHERE Serial# = 'A01-02X';

/* Q6 Report the employee who has access to the largest number of rooms. We need the employee ID, and the number of rooms (s)he can access. */
SELECT EmpId, COUNT(roomNum) AS NumRoomsHasAccess
FROM RoomAccess
GROUP BY EmpId;

/* Q7 Report the number of regular employees, division managers, and general managers in the hospital." */
SELECT empRANK AS Type, COUNT(*) AS count
FROM Employee
GROUP BY empRANK;

/* Q8 For patients who have a scheduled future visit (which is part of their most recent visit), report that patient
(SSN, and first and last names) and the visit date. Do not report patients who do not have scheduled visit. */
SELECT Patient_SSN, FirstName, LastName, FutureVisit AS visitDate
FROM(SELECT R1.Patient_SSN, FutureVisit
     FROM Admission A,(SELECT Patient_SSN, MAX(AdmissionDate) AS recentDate
                  FROM Admission
                  GROUP BY Patient_SSN) R1
     WHERE A.Patient_SSN=R1.Patient_SSN AND A.AdmissionDate=R1.recentDate) R2, Patient P
WHERE P.SSN=R2.Patient_SSN;

/*Q9 For each equipment type that has more than 3 units,
 report the equipment type ID, model, and the number of units this type has.*/
SELECT ID, model, numberOFUnits
FROM EquipmentType
WHERE numberOfUnits>3;

/*Q10 Report the date of the coming future visit for patient with SSN = 111-22-3333.*/
SELECT FutureVisit
FROM (SELECT Patient_SSN, MAX(AdmissionDate) AS AdmissionVisit
      FROM Admission
      WHERE Patient_SSN='111-22-3333'
      GROUP BY Patient_SSN) R, Admission A
WHERE R.Patient_SSN=A.Patient_SSN AND R.AdmissionVisit=A.AdmissionDate;

/*Q11 For patient with SSN = 111-22-3333, report the doctors (only ID) who have examined this patient more than 2 times. */
SELECT DoctorID
FROM (SELECT Num
      FROM Admission
      WHERE Patient_SSN='111-22-3333') R, Examine E
WHERE R.Num=E.AdmissionNum
GROUP BY DoctorID
HAVING COUNT(*)>2;

/*Q12 Report the equipment types (only the ID) for which the hospital has purchased equipments (units) in both 2010 and 2011. Do not report duplication.*/
SELECT DISTINCT TypeID
FROM Equipment
WHERE PurchaseYear=2010
INTERSECT
SELECT DISTINCT TypeID
FROM Equipment
WHERE PurchaseYear=2011;

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
 





	

