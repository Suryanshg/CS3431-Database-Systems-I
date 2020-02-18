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
INSERT INTO Doctor VALUES ('A','M','Physician','Smith','Alex');
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

/* Equipment Types and Units */
INSERT INTO EquipmentType VALUES ('X','Scalpel','Sc1','ONLY for Surgeon',3);
INSERT INTO EquipmentType VALUES ('Y','Stethoscope','St1','Hold to Chest',3);
INSERT INTO EquipmentType VALUES ('Z','Syringe','Sy1','Just a prick',3);

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
INSERT INTO Admission VALUES (1,'01-FEB-20', NULL ,500,100.1,'A','02-FEB-20');
INSERT INTO Admission VALUES (2,'10-DEC-19', '31-JAN-20',90.45,0,'A','01-FEB-20');

INSERT INTO Admission VALUES (3,'15-JAN-20', '17-JAN-20' ,300,100.1,'B','10-FEB-20');
INSERT INTO Admission VALUES (4,'11-DEC-19', '01-JAN-20',21.45,10,'B','15-JAN-20');

INSERT INTO Admission VALUES (5,'03-FEB-20', NULL ,100,100,'111-22-3333','08-FEB-20');
INSERT INTO Admission VALUES (6,'29-DEC-19', '31-DEC-19' ,9.45,0,'111-22-3333','03-FEB-20');

INSERT INTO Admission VALUES (7,'30-JAN-20', NULL ,49,0,'D','02-FEB-20');
INSERT INTO Admission VALUES (8,'10-DEC-19', '25-JAN-20' ,90.45,0,'D','30-JAN-20');

INSERT INTO Admission VALUES (9,'10-JAN-20', NULL ,500,100.1,'E','02-FEB-20');
INSERT INTO Admission VALUES (10,'10-DEC-19', '31-JAN-20' ,90.45,0,'E','10-JAN-20');

/* Employees */
INSERT INTO Employee VALUES ('1','Sloan', 'Alan' ,43,'General Admin',1,2,NULL);
INSERT INTO Employee VALUES ('2','Sloan', 'Betty' ,43,'General Admin',2,2,NULL);
INSERT INTO Employee VALUES ('3','Sloan', 'Carl' ,43,'Division Admin',3,1,2);
INSERT INTO Employee VALUES ('4','Sloan', 'Debra' ,43,'Division Admin',4,1,1);
INSERT INTO Employee VALUES ('5','Sloan', 'Emily' ,43,'Division Admin',5,1,1);
INSERT INTO Employee VALUES ('6','Sloan', 'Frederick' ,43,'Custodian Admin',6,1,2);
INSERT INTO Employee VALUES ('7','Sloan', 'George' ,43,'Secretary',7,0,3);
INSERT INTO Employee VALUES ('8','Sloan', 'Hannah' ,43,'Secretary',8,0,3);
INSERT INTO Employee VALUES ('9','Sloan', 'Ian' ,43,'Front Desk receptionist',9,0,3);
INSERT INTO Employee VALUES ('10','Sloan', 'Jose' ,43,'Nurse',10,0,4);
INSERT INTO Employee VALUES ('11','Sloan', 'Kim' ,43,'Nurse',11,0,4);
INSERT INTO Employee VALUES ('12','Sloan', 'Luke' ,43,'Nurse',12,0,5);
INSERT INTO Employee VALUES ('13','Sloan', 'Morgana' ,43,'Janitor',6,0,6);
INSERT INTO Employee VALUES ('14','Sloan', 'Nathan' ,43,'Janitor',6,0,6);
INSERT INTO Employee VALUES ('15','Sloan', 'Lloyd' ,43,'Janitor',6,0,6);
INSERT INTO Employee VALUES ('16','Sloan', 'XYZ' ,43,'Janitor',6,0,6);



