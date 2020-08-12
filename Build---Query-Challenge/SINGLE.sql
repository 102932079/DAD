/*
Build Query Challenge teng wang 102932079

Task 1 Convert the provided ERD to a Relational Schema

TOUR ( TourName , Description ) 
PRIMARY KEY ( TourName )

CLIENT ( ClientID , Surname , GivenName , Gender )
PRIMARY KEY ( ClientID )

EVENT ( TourName , EventYear , EventMonth , EventDay , Fee )
PRIMARY KEY ( TourName , EventYear , EventMonth , EventDay )
FOREIGN KEY ( TourName ) REFERENCES TOUR

BOOKING ( ClientID , TourName , EventYear , EventMonth , EventDay , DateBooked , Payment )
PRIMARY KEY ( TourName , EventYear , EventMonth , EventDay , ClientID )
FOREIGN KEY ( TourName , EventYear , EventMonth , EventDay ) REFERENCES EVENT
FOREIGN KEY ( ClientID ) REFERENCES CLIENT


--Task 2 create your database
CREATE DATABASE test

USE test
*/
GO
IF OBJECT_ID('BOOKING') IS NOT NULL
	DROP TABLE BOOKING;

IF OBJECT_ID('EVENT') IS NOT NULL
	DROP TABLE EVENT;

IF OBJECT_ID('CLIENT') IS NOT NULL
	DROP TABLE CLIENT;

IF OBJECT_ID('TOUR') IS NOT NULL
	DROP TABLE TOUR;

GO

CREATE TABLE TOUR (
    TourName    NVARCHAR(100)
,   Description NVARCHAR(500)
,   PRIMARY KEY ( TourName )
);

CREATE TABLE CLIENT (
    ClientID    INT
,   Surname     NVARCHAR(100) NOT NULL
,   GivenName   NVARCHAR(100) NOT NULL
,   Gender      NVARCHAR(1) CHECK ( Gender IN ( 'M' , 'F' , 'I' ) )
,   PRIMARY KEY ( ClientID )
);

CREATE TABLE EVENT (
    TourName   NVARCHAR(100)
,   EventMonth  NVARCHAR(3) CHECK ( EventMonth IN ( 'Jan' , 'Feb' , 'Mar' , 'Apr' , 'May' ,
'Jun' , 'Jul' , 'Aug' , 'Sep' , 'Oct' , 'Nov' , 'Dec' ))
,   EventDay    INT CHECK ( EventDay >= 1 AND EventDay <= 31 )
,   EventYear   INT CHECK ( LEN ( EventYear )  = 4 )
,   Fee         MONEY NOT NULL CHECK ( Fee > 0 )
,   PRIMARY KEY ( TourName , EventDay , EventMonth , EventYear )
,   FOREIGN KEY ( TourName ) REFERENCES TOUR  
);

CREATE TABLE BOOKING (
    ClientID    INT
,   TourName    NVARCHAR(100)
,   EventMonth  NVARCHAR(3) CHECK ( EventMonth IN ( 'Jan' , 'Feb' , 'Mar' , 'Apr' , 'May' ,
'Jun' , 'Jul' , 'Aug' , 'Sep' , 'Oct' , 'Nov' , 'Dec' ))
,   EventDay    INT CHECK ( EventDay >= 1 AND EventDay <= 31 )
,   EventYear   INT CHECK ( LEN ( EventYear )  = 4 )
,   Payment     MONEY NULL CHECK ( Payment > 0)
,   DateBooked  DATE NOT NULL
,   PRIMARY KEY ( ClientID , TourName , EventDay , EventMonth , EventYear )
,   FOREIGN KEY ( ClientID ) REFERENCES CLIENT
,   FOREIGN KEY ( TourName , EventDay , EventMonth , EventYear ) REFERENCES EVENT
);

--SELECT * FROM BOOKING;

-- Task 3 add the test data provided to your database

INSERT INTO TOUR ( TourName , Description ) VALUES
( 'North' , 'Tour of wineries and outlets of the Bedigo and Castlemaine region' ),
( 'South' , 'Tour of wineries and outlets of Mornington Penisula' ),
( 'West' , 'Tour of wineries and outlets of the Geelong and Otways region' );

INSERT INTO CLIENT ( ClientID , Surname , GivenName , Gender ) VALUES
( 1 , 'Price' , 'Taylor' , 'M'),
( 2 , 'Gamble', 'Ellyse' , 'F'),
( 3 , 'Tan' , 'Tilly' , 'F'),
( 102932079 , 'Wang' , 'Teng' , 'F');

INSERT INTO EVENT ( TourName , EventMonth , EventDay , EventYear , Fee ) VALUES
( 'North' , 'Jan' , 9 , 2016 , 200 ),
( 'North' , 'Feb' , 13 , 2016 , 225 ),
( 'South' , 'Jan' , 9 , 2016 , 225 ),
( 'South' , 'Jan' , 16 , 2016 , 200),
( 'West' , 'Jan' , 29 , 2016 , 225 );

INSERT INTO BOOKING ( ClientID , TourName , EventMonth , EventDay , EventYear , Payment , DateBooked ) VALUES
( 1 , 'North' , 'Jan' , 9 , 2016 , 200 , '2015-12-10'),
( 2 , 'North' , 'Jan' , 9 , 2016 , 200 , '2015-12-16'),
( 1 , 'North' , 'Feb' , 13 , 2016 , 225 , '2016-01-08'),
( 2 , 'North' , 'Feb' , 13 , 2016 , 125 , '2016-01-14'),
( 3 , 'North' , 'Feb' , 13 , 2016 , 225 , '2016-02-03'),
( 1 , 'South' , 'Jan' , 9 , 2016 , 200 , '2015-12-10'),
( 2 , 'South' , 'Jan' , 16 , 2016 , 200 , '2015-12-18'),
( 3 , 'South' , 'Jan' , 16 , 2016 , 200 , '2016-01-09'),
( 2 , 'West' , 'Jan' , 29 , 2016 , 225 , '2015-12-17'),
( 3 , 'West' , 'Jan' , 29 , 2016 , 200 , '2015-12-18'),
( 102932079 , 'North' , 'Jan' , 9 , 2016 , 200 , '2016-01-09'),
( 102932079 , 'South' , 'Jan' , 9 , 2016 , 200 , '2016-01-09'),
( 102932079 , 'West' , 'Jan' , 29 , 2016 , 225 , '2016-01-09');

--SELECT * FROM CLIENT;

/*
Task 4 Query 1: Write a query that shows the client first name and surname, the tour name and description, the tour event year, month, day and fee, the booking date and the fee paid for the booking

SELECT CLIENT.GivenName , CLIENT.Surname , TOUR.TourName , TOUR.Description , EVENT.EventDay , EVENT.EventYear , EVENT.EventMonth , EVENT.EventDay , EVENT.Fee , BOOKING.Payment ,  BOOKING.DateBooked
FROM TOUR
INNER JOIN EVENT
ON TOUR.TourName = EVENT.TourName
INNER JOIN BOOKING
ON EVENT.EventYear = BOOKING.EventYear
INNER JOIN CLIENT
ON BOOKING.ClientID = CLIENT.ClientID
;
*/

/*
Task 4 Query 2 : Write a query which shows the number of bookings for each (tour event) month, for each
tour in the following example format



SELECT EVENT.EventMonth , TOUR.TourName , COUNT(*) AS [Num Booking] 
FROM TOUR
INNER JOIN EVENT
ON TOUR.TourName = EVENT.TourName
GROUP BY EVENT.EventMonth , TOUR.TourName
ORDER BY EVENT.EventMonth , TOUR.TourName;
*/
/*
--Task 4: Query 3 :Write a query which lists all bookings which have a payment amount greater than the average payment amount. (This query must use a sub-query.)


SELECT *
FROM BOOKING
WHERE Payment > ( SELECT AVG( Payment ) FROM BOOKING )
;
*/

/*
--Task 5: Create a View based on Query 1 from Task 4


CREATE VIEW task5view AS
SELECT CLIENT.GivenName , CLIENT.Surname , TOUR.TourName , TOUR.Description , EVENT.EventDay , EVENT.EventYear , EVENT.EventMonth , EVENT.EventDay , EVENT.Fee , BOOKING.Payment ,  BOOKING.DateBooked
FROM TOUR
INNER JOIN EVENT
ON TOUR.TourName = EVENT.TourName
INNER JOIN BOOKING
ON EVENT.EventYear = BOOKING.EventYear
INNER JOIN CLIENT
ON BOOKING.ClientID = CLIENT.ClientID
;
*/

/*
Task 6: Write queries to prove your responses to task 4 are returning the correct/sensible results.

Query1 : save the query into view then count the number of row from task5view the return values should be same
SELECT COUNT(*) 
FROM task5view;

Query2 : instead of count list out all the booking record and compare with the values returned

SELECT *
FROM EVENT
INNER JOIN TOUR
ON EVENT.TourName = TOUR.TourName
WHERE 
EVENT.EventMonth = ( 'Jan' AND 'Feb' )
OR 
TOUR.TourName = ( 'North' AND 'West' AND 'South' );

Query3 : use another subquery to count total number of the booking record that more than average payment amount
SELECT COUNT(*)
FROM BOOKING
WHERE Payment > (SELECT AVG( Payment ) FROM BOOKING);



