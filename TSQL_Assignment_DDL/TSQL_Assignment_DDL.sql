-- SELECT name, database_id, create_date FROM sys.databases; MASTER SERVER
USE test;

GO
--DDL startint point
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
--DDl ending point
-- All Task is Stroed procedure 22 tasks intotal
GO
--================================================TSQL WORK===================================================================================
--Task 1 starting point
-- Task01.ADD_CUSTOMER
-- we have been thorugh @create procedure @passing variable into parameter @if logic loop @mutiple sql statement in procedure @how to group complex opration together into sigle procudure
--this a complex example for stored procedure
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
GO
-- for Guaranteed no row in customer to create a perfect test enviorment clear out customer table return null
--DELETE FROM CUSTOMER;
-- if the test piece are happy you comment those code out
GO
--TEST normal insert pass
EXEC ADD_CUSTOMER @PCUSTID = 1, @PCUSTNAME = 'testdude1'; 
--TEST out of range EXCEPTION pass
EXEC ADD_CUSTOMER @PCUSTID = 0, @PCUSTNAME = 'testdude2';
--TEST dulplicate EXCEPITON pass
EXEC ADD_CUSTOMER @PCUSTID = 2, @PCUSTNAME = 'testdude3';
EXEC ADD_CUSTOMER @PCUSTID = 2, @PCUSTNAME = 'testdude4';
--**********for error number 50000 untest (how to test this?)
--SELECT * FROM customer;

GO
--Task 1 ending point
--=================================================================================================================================================
--Task 2 starting point
--Task02.DELETE_ALL_CUSTOMERS
--delete from where no parameter rowcount stored procedure.
--another way to drop procedure
-- IF OBJECT_ID('ADD_PRODUCT') IS NOT NULL
-- DROP PROCEDURE ADD_PRODUCT;
DROP PROCEDURE IF EXISTS DELETE_ALL_CUSTOMERS
GO

CREATE PROCEDURE DELETE_ALL_CUSTOMERS AS
BEGIN

  BEGIN TRY
  --Delete all customers from Customer table. Return the int of rows deleted
    -- **********HOW TO DELETE TABLE? delete from table or a column
    DELETE FROM CUSTOMER
    -- **********SELECT SET PRINT? HOW TO USE ROW COUNT?
    PRINT (CONCAT(@@ROWCOUNT,' rows has been deleted.'))
  END TRY

-- HOW TO USE ERRORMEESSAGE IF WHILE FOR ? 
-- ********** COMPAIR WITH  TASK 1 IS THIS RIGHT WAY  TO CATCH EXCEPITON? DO I NEED BEGIN END HERE FOR MUTI COMMAND LINE
-- ********** DO I NEED ; FOR EVERY END?  
  BEGIN CATCH
    DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
    THROW 50000, @ERRORMESSAGE, 1  
  END CATCH;

END;

GO
--test for delete pass 
--system message (1 row affected) print out message "1 rows has been deleted"
EXEC DELETE_ALL_CUSTOMERS;

GO

--SELECT * FROM CUSTOMER;
--Task2 ending point
--============================================================================================================
--Task3 starting point
--Task3 ADD_PRODUCT SAME TO TASK1
DROP PROCEDURE IF EXISTS ADD_PRODUCT
GO
--@ OUTPUT
CREATE PROCEDURE ADD_PRODUCT @PPRODID INT, @PPRODNAME NVARCHAR, @PPRICE MONEY AS

BEGIN

  BEGIN TRY
    --THREE CONDITION TWO EXCEPTION
    --pprodid outside range:1000 - 2500
    IF @PPRODID < 1000 OR @PPRODID > 2500
      THROW 50040, 'Product ID out of range', 1

    --pprice outside range:0 – 999.99
    ELSE IF @PPRICE < 0 OR @PPRICE > 999.99
      THROW 50050, 'Product price out of range', 1

    ELSE
    --Insert a new productusing parameter values.Set the SALES_YTD value to zero. (TO PRODUCE TABLE)
      INSERT INTO PRODUCT ( PRODID, PRODNAME, SELLING_PRICE, SALES_YTD ) VALUES
      ( @PPRODID, @PPRODNAME, @PPRICE, 0);
  END TRY

--**********ASK ABOUT HOW TRY CATCH WORK
  BEGIN CATCH
  -- set a error to exception
    IF ERROR_NUMBER() = 2627
      THROW 50030, 'Duplicate Product ID', 1
    --multiple error toggled at same time with in ()

    ELSE IF ERROR_NUMBER() IN (50040, 50050)
      THROW

    ELSE
      --multiple command use amnous block begin end
      BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1  
      END;

  END CATCH;

END;

GO
--TESTING FOR ADD PRODUCT
--DELETE FROM PRODUCT;

GO
-- test for normal insert pass 
EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = 'testproduct1', @pprice = 10.00;
-- test FOR id range PASS !(1000-2500)
EXEC ADD_PRODUCT @pprodid = 999, @pprodname = 'testproduct2', @pprice = 20.00; 
-- test for price range PASS !(0-999.99)
EXEC ADD_PRODUCT @pprodid = 1002, @pprodname = 'testproduct3', @pprice = 1000.00; 
-- test for duplicate key pass
EXEC ADD_PRODUCT @pprodid = 1003, @pprodname = 'testproduct4', @pprice = 30.00; 
EXEC ADD_PRODUCT @pprodid = 1003, @pprodname = 'testproduct5', @pprice = 40.00; 

GO

--SELECT * FROM PRODUCT;

--GO
--Task3 ending point
--============================================================================================================
--Task4 starting point
--Task4 DELETE_ALL_PRODUCTS
DROP PROCEDURE IF EXISTS DELETE_ALL_PRODUCTS
GO

CREATE PROCEDURE DELETE_ALL_PRODUCTS AS
BEGIN

--Delete all products from Product table. Return the int of rows deleted
  BEGIN TRY    
    DELETE FROM PRODUCT    
    PRINT (CONCAT(@@ROWCOUNT,' rows has been deleted.'))
  END TRY

  BEGIN CATCH
    DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
    THROW 50000, @ERRORMESSAGE, 1  
  END CATCH;

END;

GO
--test for delete pass 
--system message (1 row affected) print out message "1 rows has been deleted"
EXEC DELETE_ALL_PRODUCTS;

GO
--Task4 ending point
--===========================================================================================================
--Task5 starting point
--Task5 GET_CUSTOMER_STRING
DROP PROCEDURE IF EXISTS GET_CUSTOMER_STRING 
-- USE GO TO JOINT THEM AS BATCH
GO
-- @ FOR VARIABLE OUTPUT FOR PARAMETER (OUT Parameter)
CREATE PROCEDURE GET_CUSTOMER_STRING @PCUSTID INT, @PRETURNSTRING NVARCHAR(1000) OUTPUT AS 
BEGIN
  --try catch block for exception
  BEGIN TRY
    --WE CAN DECLARE MORE THAN ONE VARIABLE IN ONE LINE multi variable declares and value selects
    DECLARE @CUSTNAME NVARCHAR(100), @STATUS NVARCHAR(7), @YTD MONEY;
    -- SELECT THEM IN ONE LINE for keeping the code nite
    SELECT @CUSTNAME = CUSTNAME, @STATUS = [STATUS], @YTD = SALES_YTD
    FROM CUSTOMER
    WHERE CUSTID = @PCUSTID
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
    --Assign a string to the OUT parameter using the format: Custid: 999  Name:XXXXXXXXXXXXXXXXXXXX  Status XXXXXXX SalesYTD:99999.99
    SET @PRETURNSTRING = CONCAT(' Custid: ', @PCUSTID, ' Name: ', @CUSTNAME, ' Status: ', @STATUS, ' SalesYTD: ', @YTD)

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
      END;

  END CATCH;

END;

GO
-- the way to test it and test for no id excepiton pass
--Msg 50060, Level 16, State 1, Procedure GET_CUSTOMER_STRING, Line 18 Customer ID not Found 

BEGIN
  DECLARE @OUTPUTVALUE NVARCHAR(100);
  -- @outputvalue is the data coming out from output , then the output keyword is expecting trigger the output
  EXEC GET_CUSTOMER_STRING @PCUSTID = 1, @PRETURNSTRING = @OUTPUTVALUE OUTPUT;
  PRINT(@OUTPUTVALUE)
END;

GO
--test for normal print out pass
--(1 row affected)  Custid: 10 Name: testcustomer Status: OK SalesYTD: 100.00 
INSERT INTO CUSTOMER ( CUSTID, CUSTNAME, [STATUS], SALES_YTD ) VALUES ( 10, 'testcustomer', 'OK', 100);

BEGIN
  DECLARE @OUTPUTVALUE NVARCHAR(100);  
  EXEC GET_CUSTOMER_STRING @PCUSTID = 10, @PRETURNSTRING = @OUTPUTVALUE OUTPUT;
  PRINT(@OUTPUTVALUE)
END;

GO

DELETE FROM CUSTOMER;

GO
--Task5 ending points
--=============================================================================================================================================
--Task6 strating points
--Task6 UPD_CUST_SALESYTD (this have a demo in complex example sql file)
DROP PROCEDURE IF EXISTS UPD_CUST_SALESYTD
GO

CREATE PROCEDURE UPD_CUST_SALESYTD @PCUSTID INT, @PAMT MONEY AS
BEGIN

  BEGIN TRY
    --pamt outside range:-999.99 to 999.99 50080. Amount out of range
    --**********Conditional Logic ? WHY THIS STURCTURE
    IF @PAMT < -999.00 OR @PAMT > 999.00
      THROW 50080, 'Amount out of range', 1

    UPDATE CUSTOMER SET SALES_YTD = SALES_YTD + @PAMT WHERE CUSTID = @PCUSTID;
    --No rows updated
    IF @@ROWCOUNT = 0
      THROW 50070, 'CustomerID not found', 1   

  END TRY

  BEGIN CATCH

    IF ERROR_NUMBER() IN (50070,50080)
      THROW

    ELSE

      BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
      END;

  END CATCH;

END;

GO
--test with ID not found pass
EXEC UPD_CUST_SALESYTD @PCUSTID = 1, @PAMT = 100;

INSERT INTO CUSTOMER ( CUSTID, CUSTNAME, [STATUS], SALES_YTD ) VALUES 
( 1, 'testcustomer1', 'OK', 500),
( 2, 'testcustomer2', 'OK', 800); 
--test with normal conditon PASS
EXEC UPD_CUST_SALESYTD @PCUSTID = 1, @PAMT = 100;
--test for out of range excepiton PASS
EXEC UPD_CUST_SALESYTD @PCUSTID = 2, @PAMT = 100000;

DELETE FROM CUSTOMER;

GO
--Task6 ending point
--====================================================================================================================================
--Task7 strating point
--Task7 GET_PROD_STRING OUT Parameter
DROP PROCEDURE IF EXISTS GET_PROD_STRING
GO
--CREATE THIS VARIABLE FOR LATER (SELECT FROM WHERE)
CREATE PROCEDURE GET_PROD_STRING @PPRODID INT, @PRETURNSTRING NVARCHAR(1000) OUTPUT AS

BEGIN
  BEGIN TRY
    --(TEMP VARIABLE) CAN BE ANY NAMES
    DECLARE @PRODNAME NVARCHAR(100), @YTD MONEY, @SELL MONEY;

    SELECT @PRODNAME = PROGRAM_NAME(), @YTD = SALES_YTD, @SELL = SELLING_PRICE
    FROM PRODUCT
    WHERE PRODID = @PPRODID;
    --No matching product id found
    IF @@ROWCOUNT = 0
      THROW 50090, 'Product ID not found', 1
    --Assign a string to the OUT parameter using the format:Prodid: 999  Name:XXXXXXXXXXXXXXXXXXXX  Price 999.99 SalesYTD:99999.99
    SET @PRETURNSTRING = CONCAT('Prodid: ', @PPRODID, ' ','Name: ', @PRODNAME, ' ',  'Price: ' , @SELL ,' ','SalesYTD: ',@YTD);

  END TRY

  BEGIN CATCH

    IF ERROR_NUMBER() IN (50090)
      THROW
    
    ELSE

      BEGIN

        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1

      END;

  END CATCH; 

END;

GO

INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES (1001,'testproduct', 500, 800);

--test for normal conditon pass

GO

BEGIN
    DECLARE @OUTPUTVALUE NVARCHAR(100)
    EXEC GET_PROD_STRING @PPRODID = 1001, @PRETURNSTRING = @OUTPUTVALUE OUTPUT
    PRINT @OUTPUTVALUE
END; 

--test for id not found pass
GO

BEGIN
    DECLARE @OUTPUTVALUE NVARCHAR(100)
    EXEC GET_PROD_STRING @PPRODID = 1002, @PRETURNSTRING = @OUTPUTVALUE OUTPUT
    PRINT @OUTPUTVALUE
END; 

GO

DELETE FROM PRODUCT;

GO

--Task7 ending point
--====================================================================================================================================