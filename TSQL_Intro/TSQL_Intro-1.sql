--TSQL Task 1 - Intro Teng Wang 102932079
/*
To view a list of databases on an instance of SQL Server
SELECT name, database_id, create_date  
FROM sys.databases ;  
*/

USE demo;
GO

--Task 1 Create a stored procedure called ‘MULTIPLY’ that takes 2 numbers as parameters and outputs to screen the answer in the following format: e.g. The product of 2 and 3 is 6;
--(stored procedure with parameters)
--Stored Procedures  Have a name, stored in DB, can be called repeatedly no return value (stored functions do that)
--parameters Used to pass input into stored procedure (and functions)
--Variables Have data types and store values just like C#

/*
DROP PROCEDURE IF EXISTS MULTIPLY;
GO
CREATE PROCEDURE MULTIPLY @PARAM1 INT, @PARAM2 INT AS
BEGIN
DECLARE @RESULT INT;
SET @RESULT = @PARAM1 * @PARAM2;
    SELECT CONCAT( 'The product of' , @PARAM1 , 'and' , @PARAM2 , 'is' , @RESULT );
END;
GO
EXEC MULTIPLY @PARAM1 = 2, @PARAM2 = 3;
*/

--Task 2 Create a stored function called ‘ADD’ that takes 2 numbers as parameters and returns the sum of the numbers ( as a suitable numeric datatype ) Write an anonymous block that calls the stored function, and outputs the result in the following format e.g. Ths sum of 1 and 5 is 6
--(stroed function parameters anonymous block)
--anonymous block Starts with BEGIN, finishes with END;
--stroed function Returns a Value. This means you don’t output the value from the function but rather have another block which calls the function and outputs its return value.

/*
DROP FUNCTION IF EXISTS ADD;
GO
CREATE FUNCTION ADD (@PARAM1 INT, @PARAM2 INT) RETURNS INT AS
BEGIN
DECLARE @RESULT INT;
SET @RESULT = @PARAM1 + @PARAM2
    SELECT CONCAT('The sum of' , @PARAM1 , 'and' , @PARAM2 , 'is' , @RESULT);
END;
GO
BEGIN   
    SELECT ADD(1,5);
END;
*/
/*
sample
DROP FUNCTION IF EXISTS [ADD]; why drop why[]
GO
CREATE FUNCTION [ADD] (@PARAM1 INT, @PARAM2 INT) RETURNS INT AS
BEGIN
RETURN @PARAM1 + @PARAM2;
END;
GO
BEGIN
DECLARE @RESULT INT;
EXEC @RESULT = [ADD] @PARAM1 = 1, @PARAM2=5;
SELECT CONCAT('The sum of' , @PARAM1 , 'and' , @PARAM2 , 'is' , @RESULT);
END;
*/

--Task3 Create tables based on the below relational schema:
/*
Account(AcctNo, Fname, Lname, CreditLimit, Balance)
Primary Key (AcctNo)
Log(OrigAcct, LogDateTime, RecAcct, Amount)
Primay Key (OrigAcct, LogDateTime)
Foreign Key (OrigAcct) References Account (AcctNo)
Foreign Key (RecAcct) References Account (AcctNo)
*/

--order of drop table is drop the table has no FK last

IF OBJECT_ID('LOG') IS NOT NULL
	DROP TABLE LOG;

IF OBJECT_ID('ACCOUNT') IS NOT NULL
	DROP TABLE ACCOUNT;

GO

--order of create table is create the table has no FK first

CREATE TABLE ACCOUNT (
    AcctNo  INT NOT NULL
,   Fname   NVARCHAR(100) NOT NULL
,   Lname   NVARCHAR(100) NOT NULL
,   CreditLimit MONEY NOT NULL CHECK ( CreditLimit > 0 )
,   Balance MONEY NOT NULL CHECK ( Balance > 0 )
,   PRIMARY KEY ( AcctNo )
);

CREATE TABLE LOG (
    OrigAcct INT NOT NULL
,   LogDateTime DATE NOT NULL
,   RecAcct INT NOT NULL
,   Amount MONEY CHECK ( Amount > 0 )
,   PRIMARY KEY ( OrigAcct , LogDateTime )
,   FOREIGN KEY ( OrigAcct ) REFERENCES ACCOUNT ( AcctNo )
,   FOREIGN KEY ( RecAcct ) REFERENCES ACCOUNT ( AcctNo )
);
-- origacct and recacct are comes from same table so acctno can split

GO
-- why OrigAcct RecAcct ?REFERENCES ACCOUNT ( AcctNo )

--Task 4a Update the from account so its balance is reduced by the amount (note the check constaint on this will fail if the account doesn have enough credit / funds) 
--(Conditional Logic parameters stored procedure)
/*
The SQL Server UPDATE Query is used to modify the existing records in a table.
You can use WHERE clause with UPDATE query to update selected rows otherwise all the rows would be affected.
UPDATE table_name 
SET column1 = value1, column2 = value2...., columnN = valueN 
WHERE [condition];
*/

--CREATE A PROCEDURE PRINT OVERDRAW MESSAGE
/* requirement removed
-- @OrigAcct INT, @RecAcct INT, @Amount MONEY
DROP PROCEDURE IF EXISTS WARNNING;
GO
CREATE PROCEDURE WARNNING AS
SELECT CONCAT('Warnning! Non-Sufficient Funds. Payment declined.')
END;
*/
GO
-- wrong clomn name there 
DROP PROCEDURE IF EXISTS WITHDRAWAL;
GO
CREATE PROCEDURE WITHDRAWAL @FROMACCT INT, @AMOUNT MONEY AS
BEGIN
    UPDATE ACCOUNT SET Balance -= @AMOUNT WHERE AcctNo = @FROMACCT;
END;
GO

BEGIN
DECLARE @FROMACCT INT, @AMOUNT MONEY;
-- select here will select all column in all table
SELECT CreditLimit, Balance FROM ACCOUNT;
-- the condition need to define as one comparesion and another comparsion
-- creditlimit <= amount AND amount <= balance
IF ( CreditLimit <=  @AMOUNT <=Balance ) THEN
-- procedure cant select , procedure need to excu
    EXEC WITHDRAWAL;
ELSE 
-- if else end if
    EXEC WARNNING;
END IF;
END;


--Task 4b Update the to account so its balance is increased by the amount 
-- @OrigAcct INT, @RecAcct INT, @Amount MONEY
DROP PROCEDURE IF EXISTS SAVING;
GO
CREATE PROCEDURE SAVING @TOACCT INT, @AMOUNT MONEY AS
BEGIN
    UPDATE ACCOUNT SET Balance += @AMOUNT WHERE AcctNo = @TOACCT;
SELECT CONCAT( @AMOUNT , 'has been saved to' , @TOACCT )
END;
GO
EXEC SAVING @TOACCT = 123456, @AMOUNT = $400;


--Task 4c Log the transfer by inserting the from account, to account, current datetime and amount into the log table. 
--insert statement with variable 

--task 4 a and b as update statement showed c as insert statement with variable
GO
CREATE PROCEDURE Transfer @OrigAcct INT, @RecAcct INT, @Amount MONEY AS
BEGIN   
    UPDATE ACCOUNT SET Balance = Balance - @Amount WHERE AcctNo = @OrigAcct;
    UPDATE ACCOUNT SET Balance = Balance + @Amount WHERE AcctNo = @RecAcct;
    INSERT INTO LOG ( OrigAcct , RecAcct , Amount , LogDateTime ) VALUES
    (  @OrigAcct , @RecAcct , @Amount , SYSDATETIME() );
END;
GO