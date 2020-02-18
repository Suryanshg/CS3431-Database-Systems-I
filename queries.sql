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
/*Should we make numberOfUnits a derived attribute???*/

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




