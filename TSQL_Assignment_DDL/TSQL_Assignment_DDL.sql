-- SELECT name, database_id, create_date FROM sys.databases; MASTER SERVER
USE test;

GO

IF OBJECT_ID('Sale') IS NOT NULL
DROP TABLE SALE;

IF OBJECT_ID('Product') IS NOT NULL
DROP TABLE PRODUCT;

IF OBJECT_ID('Customer') IS NOT NULL
DROP TABLE CUSTOMER;

IF OBJECT_ID('Location') IS NOT NULL
DROP TABLE LOCATION;

GO

CREATE TABLE CUSTOMER (
CUSTID	INT
, CUSTNAME	NVARCHAR(100)
, SALES_YTD	MONEY
, STATUS	NVARCHAR(7)
, PRIMARY KEY	(CUSTID) 
);

CREATE TABLE PRODUCT (
PRODID	INT
, PRODNAME	NVARCHAR(100)
, SELLING_PRICE	MONEY
, SALES_YTD	MONEY
, PRIMARY KEY	(PRODID)
);

CREATE TABLE SALE (
SALEID	BIGINT
, CUSTID	INT
, PRODID	INT
, QTY	INT
, PRICE	MONEY
, SALEDATE	DATE
, PRIMARY KEY 	(SALEID)
, FOREIGN KEY 	(CUSTID) REFERENCES CUSTOMER
, FOREIGN KEY 	(PRODID) REFERENCES PRODUCT
);
-- SQL constraints are used to specify rules for data in a table.
--Constraints can be specified when the table is created with the CREATE TABLE statement, or after the table is created with the ALTER TABLE statement
--The ALTER TABLE statement is used to add, delete, or modify columns in an existing table.
--The ALTER TABLE statement is also used to add and drop various constraints on an existing table.
CREATE TABLE LOCATION (
  LOCID	NVARCHAR(5)
, MINQTY	INTEGER
, MAXQTY	INTEGER
, PRIMARY KEY 	(LOCID)
, CONSTRAINT CHECK_LOCID_LENGTH CHECK (LEN(LOCID) = 5)
, CONSTRAINT CHECK_MINQTY_RANGE CHECK (MINQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_RANGE CHECK (MAXQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_GREATER_MIXQTY CHECK (MAXQTY >= MINQTY)
);

--DROP SEQUENCE (Transact-SQL) Removes a sequence object from the current database.

IF OBJECT_ID('SALE_SEQ') IS NOT NULL
--Creates a sequence object and specifies its properties. A sequence is a user-defined schema bound object that generates a sequence of numeric values according to the specification with which the sequence was created. 
DROP SEQUENCE SALE_SEQ;
CREATE SEQUENCE SALE_SEQ;

GO
--===================================================================================================================================
-- Task01.ADD_CUSTOMER
-- we have been thorugh @create procedure @passing variable into parameter @if logic loop @mutiple sql statement in procedure @how to group complex opration together into sigle procudure
--this a complex example for stored procedure
--IF OBJECT_ID('ADD_CUSTOMER') IS NOT NULL
DROP PROCEDURE IF EXISTS ADD_CUSTOMER;
GO
-- drop if exists procedure add_customer （older newer database depend on version）
--Insert a new customer using parameter values.
CREATE PROCEDURE ADD_CUSTOMER @PCUSTID INT, @PCUSTNAME NVARCHAR(100) AS

-- begin try end try begin catch end catch sturcture (error handling)
--try block can have logic
-- !!!expected to do try catch for almost everything after any excepiton need do test according to requirement if the test piece are happy you comment those code out, the entire sql need to be run one piece create go between.
BEGIN
    BEGIN TRY
    -- thats how you throw a excepton out of range same with csharp
    -- as soon as the excepiton ocure then catch block will catch them
        --exception pcustid outside range:1-499
        IF @PCUSTID < 1 OR @PCUSTID > 499
            THROW 50020, 'Customer ID out of range', 1

        --if condition within the range pass in the variable into parameter
        --Set the SALES_YTD value to zero.   Set the STATUS value to 'OK'
        INSERT INTO CUSTOMER (CUSTID, CUSTNAME, SALES_YTD, STATUS) 
        VALUES (@PCUSTID, @PCUSTNAME, 0, 'OK');

    END TRY
    BEGIN CATCH
    -- how to find out that error number means by google or just throw it
        --Server: Msg 2627, Level 14, State 1, Line 1 Violation of PRIMARY KEY constraint Constraint Name. Cannot insert duplicate key in object Table Name.
        --exception Duplicate primary key
        if ERROR_NUMBER() = 2627
            THROW 50010, 'Duplicate customer ID', 1
        ELSE IF ERROR_NUMBER() = 50020
            THROW
        -- see above the if and else if only have one line of procedure
        -- here below more than one line you need to have begin and end
        ELSE
            BEGIN
            -- declare a variable but you can not aceess the error message on its own
            -- save the error message into variable and pass that value into the variable
            --excepiton Other
            --In this syntax, max is the maximum storage size in bytes which is 2^31-1 bytes (2 GB). how to test this?
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
--  we need to write the test with any procedure as assignment required
END;
--test for exceptions 
--GO
-- for Guaranteed no row in customer to create a perfect test enviorment clear out customer table return null
--DELETE FROM CUSTOMER;
-- if the test piece are happy you comment those code out
--GO
--normal insert pass
--EXEC ADD_CUSTOMER @PCUSTID = 1, @PCUSTNAME = 'testdude1'; 
--out of range pass
--EXEC ADD_CUSTOMER @pcustid = 0, @pcustname = 'testdude2';
--dulplicate pass
--EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude3';
--EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude4';
--50000 untest
--select * from customer;

GO
--=================================================================================================================================================
--Task02.DELETE_ALL_CUSTOMERS
--delete from where no parameter rowcount stored procedure
DROP PROCEDURE IF EXISTS DELETE_ALL_CUSTOMERS
GO

CREATE PROCEDURE DELETE_ALL_CUSTOMERS AS
BEGIN
  -- HOW TO DELETE TABLE?
  DELETE FROM CUSTOMER
  -- SELECT SET PRINT? WHAT TO USE ROW COUNT?
  PRINT CONCAT(@@ROWCOUNT,' rows has been deleted.')
END

GO
-- HOW TO USE ERRORMEESSAGE IF WHILE FOR ? 
BEGIN
DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
THROW 50000, @ERRORMESSAGE, 1

--GET_CUSTOMER_STRING
-- GET_CUSTOMER_STRING , multi variable declares and value selects
--NEED DROP PROCEDURE BEFORE USE
DROP PROCEDURE IF EXISTS GET_CUSTOMER_STRING
-- USE GO TO JOINT THEM AS BATCH
GO
-- @ FOR VARIABLE OUTPUT FOR PARAMETER
CREATE PROCEDURE GET_CUSTOMER_STRING @pCustId INT, @pReturnString NVARCHAR(100) OUTPUT AS 
BEGIN
  --try catch block for exception
  BEGIN TRY
    --WE CAN DECLARE MORE THAN ONE VARIABLE IN ONE LINE
    DECLARE @CustName NVARCHAR(100), @Status NVARCHAR(7), @YTD MONEY;
    -- SELECT THEM IN ONE LINE for keeping the code nite
    SELECT @CustName = CUSTNAME, @Status = [STATUS], @YTD = SALES_YTD
    FROM CUSTOMER
    WHERE CUSTID = @pCustId
    -- ACHIVE ALL ABOVE IN ONE SELECT ALL BATCH OF NULL

    --WE COULD DO IF ALL ATTRIBUTE EQUAL TO NULL BUT SUGGEST TO USE ROWCOUNT
    IF @@ROWCOUNT = 0
      --THROW THE ERROR,CREATE THIS ERROR, AND THE MESSAGE OF THE ERROR, 1 IS PROERIOTY 1 is state
      --THROW [ { error_number | @local_variable }, { message | @local_variable }, { state | @local_variable } ]  [ ; ]  
      --If the condition satisfy about this will stright to thorw the error and it wont excu anything after that goes to end
      THROW 50060, 'Customer ID not Found', 1
    --this is the condition for if the data is found
    --doing copy avoid typo
    --see the demo picture not using print here is beacuse the output for database only print in database it's not going to back to applicaiton with api
    --send in output variable as output the api when it get done it will refer to variable, get the data in it and send back to applicaton
    --just print  it will only refer to database
    SET @pReturnString = CONCAT(' Custid: ', @pCustId, ' Name: ', @CustName, ' Status: ', @Status, ' SalesYTD: ', @YTD)
  END TRY

  BEGIN CATCH
    --IF ERROR_NUMBER() = 50060 for single error in (50010,50020,50030,) for multiple errors with in keyword
    IF ERROR_NUMBER() IN (50060)
      THROW
    ELSE
      BEGIN
        --creating a variable to hold the errormessage - call a errormessages and pass into a varible
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        --the throw need a variable or existing vaule it cant throw a funciotn or procedure
        THROW 50000, @ERRORMESSAGE, 1
      END
  END CATCH

END
GO

-- the way to test it
BEGIN
  DECLARE @OUTPUTVALUE NVARCHAR(100);
  -- @outputvalue is the data coming out from output , then the output keyword is expecting trigger the output
  EXEC GET_CUSTOMER_STRING @pCustId = 1, @pReturnString = @OUTPUTVALUE OUTPUT;
  PRINT(@OUTPUTVALUE)
END


-- UPD_CUST_SALESYTD has demo
