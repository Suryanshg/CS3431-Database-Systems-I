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






