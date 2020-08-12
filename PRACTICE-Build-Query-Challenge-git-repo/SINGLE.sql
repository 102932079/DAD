/*
PRACTICE Build Query Challenge teng wang 102932079

Task 1 Convert the provided ERD to a Relational Schema

SUBJECT ( SubjCode , Description )
PRIMARY KEY ( SubjCode )

TEACHER ( StaffID , Surname , GivenName )
PRIMAYR KEY ( StaffID )

STUDENT ( StudentID , Surname , GivenName , Gender )
PRIMARY KEY ( StudentID )

SUBJECTOFFERING ( Year , Semster , Fee , SubjCode , StaffID )
PRIMARY KEY ( Year , Semster , SubjCode )
FOREIGN KEY ( StaffID ) REFERENCES TEACHER
FOREIGN KEY ( SubjCode ) REFERENCES SUBJECT


ENROLMENT ( Year , Semster , SubjCode , StudentID , Date Enrolled , Grade )
PRIMARY KEY ( Year , Semster , SubjCode , StudentID )
FOREIGN KEY ( StudentID ) REFERENCES STUDENT
FOREIGN KEY ( SubjCode , Year , Semster ) REFERENCES SUBJECTOFFERING

the following syntax are relay on the database version that you are used (try both if you are strating a new database)
The IF EXISTS condition/syntax (below) only works on SQL Server 2016 and later & Azure
DROP TABLE IF EXISTS SUBJECT;
DROP TABLE IF EXISTS STUDENT;
DROP TABLE IF EXISTS SUBJECTOFFERING;
DROP TABLE IF EXISTS ENROLMENT;
DROP TABLE IF EXISTS TEACHER;


For earlier Versions of SQL Server (e.g. SQL Server 2014) use the following instead
*/
-- drop create datatype null check FK PK object_id is table names

-- the master server issue need to create a sql file and link the master server to the sql that user created see memo for more

SELECT table_catalog [database], table_schema [schema], table_name name, table_type type
FROM INFORMATION_SCHEMA.TABLES
GO

create database demo

use demo

-- the order to drop (from child to parent relationship) exp: need drop enrolment first beacuse subjectoffering can not exist along


IF OBJECT_ID('ENROLMENT') IS NOT NULL
	DROP TABLE ENROLMENT;

IF OBJECT_ID('SUBJECTOFFERING') IS NOT NULL
	DROP TABLE SUBJECTOFFERING;

IF OBJECT_ID('SUBJECT') IS NOT NULL
	DROP TABLE SUBJECT;

IF OBJECT_ID('STUDENT') IS NOT NULL
	DROP TABLE STUDENT;

	--table name
IF OBJECT_ID('TEACHER') IS NOT NULL
	DROP TABLE TEACHER;

GO 

--create table without FK first (beacuse the code runs down so the table that needs fk cant created, subjectoffering need teacher and subject to exist so need to create teacher and subject table first)

CREATE TABLE SUBJECT (
    SubjCode     NVARCHAR(100)  
,   Description  NVARCHAR(500) 
,   PRIMARY KEY ( Subjcode )
);

CREATE TABLE STUDENT (
    StudentID  NVARCHAR(10)  
,   Surname    NVARCHAR(100) NOT NULL
,   GivenName  NVARCHAR(100) NOT NULL 
,   Gender     NVARCHAR(1) CHECK ( Gender IN ( 'M' , 'F' , 'I' ) )
,   PRIMARY KEY ( StudentID )
);

CREATE TABLE TEACHER (
	StaffID		INT CHECK ( LEN ( StaffID ) = 8 )
,	Surname     NVARCHAR(100) NOT NULL
, 	GivenName	NVARCHAR(100) NOT NULL
,	PRIMARY KEY ( StaffID )
);


CREATE TABLE SUBJECTOFFERING (
    SubjCode   NVARCHAR(100)
,   Year       INT CHECK ( LEN ( Year )  = 4 )
,   Semester    INT CHECK ( Semester IN ( 1 , 2 ) )
,   Fee        MONEY NOT NULL CHECK ( Fee > 0 )
,   StaffID    INT CHECK ( LEN ( StaffID ) = 8 ) 
,   PRIMARY KEY ( SubjCode , Year , Semester )
,   FOREIGN KEY ( StaffID ) REFERENCES TEACHER
, 	FOREIGN KEY ( SubjCode ) REFERENCES SUBJECT
);

CREATE TABLE ENROLMENT (
    StudentID    NVARCHAR(10) 
,   SubjCode     NVARCHAR(100)
,   Year 		 INT CHECK ( LEN ( YEAR ) = 4 )
,	Semester	 INT CHECK ( Semester IN ( 1 , 2 ))
,	Grade		 NVARCHAR(2)  DEFAULT Null CHECK ( Grade IN ( 'N' , 'P' , 'C' , 'D' , 'HD' )) 
,	DateEnrolled DATE
,	PRIMARY KEY ( StudentID , SubjCode , Year , Semester ) 
,   FOREIGN KEY ( SubjCode , Year , Semester ) REFERENCES SUBJECTOFFERING
,   FOREIGN KEY ( StudentID ) REFERENCES STUDENT
);

-- DATE - format YYYY-MM-DD 


--Task 2 Using an SQL Query (not the GUI) verify that all tables have been successfully created. select
/*
SELECT *
FROM TEACHER;
*/

--Task 3 add the test data provided to your database. insert 

INSERT INTO SUBJECT ( SubjCode , Description ) VALUES
( 'ICTWEB425' , 'Apply SQL to extract & manipulate data' ),
( 'ICTDBS403' , 'Create Basic Databases' ),
( 'ICTDBS502' , 'Design a Database' );

INSERT INTO STUDENT ( StudentID , Surname , GivenName , Gender ) VALUES
( 's12233445' , 'Morrison' , 'Scott' , 'M' ),
( 's23344556' , 'Gillard' , 'Julia' , 'F' ),
( 's34455667' , 'Whitlam' , 'Gough' , 'M' ),
( '102932079' , 'Wang' , 'Teng' , 'I' );

INSERT INTO TEACHER ( StaffID , Surname , GivenName ) VALUES
( 98776655 , 'Starr' , 'Ringo' ),
( 87665544 , 'Lennon', 'John' ),
( 76554433 , 'McCartney' , 'Paul' );

INSERT INTO SUBJECTOFFERING ( SubjCode , Year , Semester , Fee , StaffID ) VALUES
( 'ICTWEB425' , 2019 , 1 , 200 , 98776655 ),
( 'ICTWEB425' , 2020 , 1 , 225 , 98776655 ),
( 'ICTDBS403' , 2020 , 1 , 200 , 87665544 ),
( 'ICTDBS403' , 2020 , 2 , 200 , 76554433 ),
( 'ICTDBS502' , 2019 , 2 , 225 , 87665544 );

INSERT INTO ENROLMENT ( StudentID , SubjCode , Year ,Semester , Grade , DateEnrolled ) VALUES
( 's12233445' , 'ICTWEB425' , 2019 , 1 , 'D' , '2019-02-25' ),
( 's23344556' , 'ICTWEB425' , 2019 , 1 , 'P' , '2019-02-15' ),
( 's12233445' , 'ICTWEB425' , 2020 , 1 , 'C' , '2020-01-30' ),
( 's23344556' , 'ICTWEB425' , 2020 , 1 , 'HD' , '2020-02-26' ),
( 's34455667' , 'ICTWEB425' , 2020 , 1 , 'P' , '2020-01-28' ),
( 's12233445' , 'ICTDBS403' , 2020 , 1 , 'C' , '2020-02-08' ),
( 's23344556' , 'ICTDBS403' , 2020 , 2 , Null , '2020-06-30' ),
( 's34455667' , 'ICTDBS403' , 2020 , 2 , Null , '2020-07-03' ),
( 's23344556' , 'ICTDBS502' , 2019 , 2 , 'P' , '2019-07-01' ),
( 's34455667' , 'ICTDBS502' , 2019 , 2 , 'N' , '2019-07-13' ),
( '102932079' , 'ICTWEB425' , 2019 , 1 , 'C' , '2019-01-01' ),
( '102932079' , 'ICTDBS403' , 2020 , 1 , 'C' , '2020-01-01' ),
( '102932079' , 'ICTDBS502' , 2019 , 2 , Null , '2020-07-01' );


/*
-- when create a new set of values needs to be has the data there exist from other table can not create from nothing


SELECT *
FROM STUDENT;
*/
/*
Task 4 Query 1:
Write a query that shows the student first name and surname, the subject code and description, the subject offering year, semester & fee and the given name and surname of the teacher for that subject offering
student.surname student.givenname subject.subjcode subject.description subjectoffering.year subjectoffering.semester subjectoffering.fee teacher.surname teacher.givenname 
( mutiple innerjoin on )


SELECT STUDENT.Surname , STUDENT.GivenName , SUBJECT.SubjCode , SUBJECT.Description , SUBJECTOFFERING.Year , SUBJECTOFFERING.Semester , SUBJECTOFFERING.Fee , TEACHER.Surname , TEACHER.GivenName
FROM SUBJECT
INNER JOIN SUBJECTOFFERING
ON SUBJECT.SubjCode = SUBJECTOFFERING.SubjCode
INNER JOIN TEACHER
ON TEACHER.StaffID = SUBJECTOFFERING.StaffID
INNER JOIN ENROLMENT
ON SUBJECTOFFERING.Year = ENROLMENT.Year
INNER JOIN STUDENT
ON STUDENT.StudentID = ENROLMENT.StudentID
;
*/
/*
Task 4 Query 2:
Write a query which shows the number of enrolments, for each year and semester in the following example format. For example:
Aggregate queries group by count order by as

-- as no space or space in [] [NumEnrolments]

SELECT Year , Semester , COUNT(*) AS MumEnrolments
FROM SUBJECTOFFERING
GROUP BY Year , Semester
ORDER BY Year , semester
;
*/
/*
Task 4 Query 3:
Write a query which lists all enrolments which for the subject offering which has the highest fee. (This query must use a sub-query.)
Sub Queries having clause
SELECT *FROM MOVIEWHERE runtime = (  SELECT   MAX(runtime)FROM    MOVIE);


SELECT *
FROM SUBJECTOFFERING
WHERE Fee = ( SELECT MAX(Fee) FROM SUBJECTOFFERING )
;



--Task 5 Create a View based on Query 1 from Task 4 (create view)

SELECT * FROM STUDENT
SELECT * FROM SUBJECT
SELECT * FROM SUBJECTOFFERING
SELECT * FROM TEACHER

Create View viewtask5 AS

SELECT STUDENT.Surname , STUDENT.GivenName , SUBJECT.SubjCode , SUBJECT.Description , SUBJECTOFFERING.Year , SUBJECTOFFERING.Semester , SUBJECTOFFERING.Fee , TEACHER.Surname , TEACHER.GivenName
FROM SUBJECT
INNER JOIN SUBJECTOFFERING
ON SUBJECT.SubjCode = SUBJECTOFFERING.SubjCode
INNER JOIN TEACHER
ON TEACHER.StaffID = SUBJECTOFFERING.StaffID
INNER JOIN ENROLMENT
ON SUBJECTOFFERING.Year = ENROLMENT.Year
INNER JOIN STUDENT
ON STUDENT.StudentID = ENROLMENT.StudentID
;
*/
/*
Task 6 • 
Write queries to prove your responses to task 4 are returning the correct/sensible results.
• E.g. to test that select * from student is returning the correct number of rows you could use
select count(*) from student and check that the number in the count query is the same as
the number of rows returned by the select * query.
• Provide a (short) written explanation of how each of your ‘test’ queries verifies that the
related task 3 query is correct. Add these explanations as COMMENTS after each test query
in your .sql script
to have the same result with different approach (everystudentname on the list or all the student number with names)
*/

