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
-- Task01.ADD_CUSTOMER Add a new customerto Customertable.
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
            --for error number 50000 untest (how to test this?) In this syntax, max is the maximum storage size in bytes which is 2^31-1 bytes (2 GB). 
            --datatype of the message
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

--SELECT * FROM customer;

GO
--Task 1 ending point
--=================================================================================================================================================
--Task 2 starting point
--Task02.DELETE_ALL_CUSTOMERS Delete all customers from Customer table.
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
-- COMPAIR WITH  TASK 1 IS THIS RIGHT WAY  TO CATCH EXCEPITON? DO I NEED BEGIN END HERE FOR MUTI COMMAND LINE (predict)
-- the throw 50000 here is more likely a backup solution for sth you could not predic but the system will know about it(if the situcation the system knows better than you)
-- the nvarchar max here is not a excepton it just a datatype the max can change it self to define the the correct limit 1,3,5,7,100... whatever to the maxium possiablity
-- DO I NEED ; FOR EVERY END?  HOW OFTEN WE USE GO(you can try the execute the query if stopped add go that it for ; the system will show)
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
--Task3 ADD_PRODUCT SAME TO TASK1 Add a new productto Producttable.
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
--Task4 DELETE_ALL_PRODUCTS Delete all products from Product table.
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
--Task5 GET_CUSTOMER_STRING Get one customers details from customer table
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
--Task6 UPD_CUST_SALESYTD (this have a demo in complex example sql file) Update one customer's sales_ytd value in the customer table
DROP PROCEDURE IF EXISTS UPD_CUST_SALESYTD
GO

CREATE PROCEDURE UPD_CUST_SALESYTD @PCUSTID INT, @PAMT MONEY AS
BEGIN

  BEGIN TRY
    --pamt outside range:-999.99 to 999.99 50080. Amount out of range
    --Conditional Logic ? WHY THIS STURCTURE (the understanding of if conditon)
    --basicly in try block if any issure is been throwed then go stright into catch block and ignor other line of action
    --that why two if below beacuse it will never happen at same time, one of the condition happens other condition with their code got ignored
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
--Task7 GET_PROD_STRING OUT Parameter Get one products details from product table
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
--Task8 starting point 
--TASK8  UPD_PROD_SALESYTD Update one product's sales_ytd value in the product table
DROP PROCEDURE IF EXISTS UPD_PROD_SALESYTD
GO

CREATE PROCEDURE UPD_PROD_SALESYTD @PPRODID INT, @PAMT MONEY AS
BEGIN
  BEGIN TRY
    --pamt outside range:-999.99 to 999.99
    IF @PAMT < -999.99 OR @PAMT > 999.99
      THROW 50110, 'Amount out of range', 1

    UPDATE PRODUCT SET SALES_YTD = SALES_YTD + @PAMT WHERE PRODID = @PPRODID
    --No rows updated
    IF @@ROWCOUNT = 0
      THROW 50100, 'ProductID not found', 1
  END TRY

  BEGIN CATCH
    IF ERROR_NUMBER() IN (50110,50100)
      THROW
    ELSE
      BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
      END;
  END CATCH;
END;

GO

--TEST FOR ID NOT FOUND PASS (SOMETIME IT SAYS PROCEDURE NOT FOUND THEN YOU NEED TO RUN THOURGH WHOLE SQL DROP AND CREATE TABLE)
EXEC UPD_PROD_SALESYTD @PPRODID = 1001, @PAMT = 500;

--TEST FOR NORMAL RUN
INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES
(1001, 'TESTPRODUCT', 500 , 500)

EXEC UPD_PROD_SALESYTD @PPRODID = 1001, @PAMT = 500;

--TEST FOR AMOUNT OUT OF RANGE

EXEC UPD_PROD_SALESYTD @PPRODID = 1001, @PAMT = 2000;

DELETE FROM PRODUCT;

GO

--TASK8 ENDING POINT
--==================================================================================================================================================================
--TASK9 STARTING POINT
--TASK9 UPD_CUSTOMER_STATUS Update one customer's status value in the customer table
DROP PROCEDURE IF EXISTS UPD_CUSTOMER_STATUS
GO

CREATE PROCEDURE UPD_CUSTOMER_STATUS @PCUSTID INT, @PSTATUS NVARCHAR AS
BEGIN
  BEGIN TRY
    --Not Equal Operator: != 
    -- IF @PSTATUS != ('OK' OR 'SUSPEND')
    IF (@PSTATUS != 'OK' OR @PSTATUS != 'SUSPEND')
      THROW 50130, 'Invalid Status Value', 1
    --Change one customer's status value. 
    UPDATE CUSTOMER SET [STATUS] = @PSTATUS WHERE CUSTID = @PCUSTID;

    IF @@ROWCOUNT = 0
      THROW 50120, 'CustomerID not found', 1

  END TRY

  BEGIN CATCH

    IF ERROR_NUMBER() IN (50130,50120)
      THROW
    
    ELSE

      BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
      END; 

  END CATCH;

END;

GO

INSERT INTO CUSTOMER(CUSTID, CUSTNAME, SALES_YTD, [STATUS]) VALUES
(1, 'TESTCUSTOMER1', 500, NULL),
(2, 'TESTCUSTOMER2', 400, NULL),
(3, 'TESTCUSTOMER3', 600, NULL);

--TEST FOR NORMAL PASS
EXEC UPD_CUSTOMER_STATUS  @PCUSTID = 1, @PSTATUS = 'OK';
EXEC UPD_CUSTOMER_STATUS  @PCUSTID = 2, @PSTATUS = 'SUSEND';

--TEST FOR ID NOT FOUND PASS
EXEC UPD_CUSTOMER_STATUS  @PCUSTID = 5, @PSTATUS = 'OK';

--TEST FOR INVALID STATUS PASS
EXEC UPD_CUSTOMER_STATUS  @PCUSTID = 3, @PSTATUS = 'WHAT';

GO

--TASK9 ENDING POINT
--=======================================================================================================================================================================================
--TASK10 STARTING POINT
--TASK10 ADD_SIMPLE_SALE (feels like problem?) Update one customer's status value in the customer table
DROP PROCEDURE IF EXISTS ADD_SIMPLE_SALE
GO

CREATE PROCEDURE ADD_SIMPLE_SALE @PCUSTID INT, @PPRODID INT, @PQTY INT AS
BEGIN

  BEGIN TRY
    --CREATE VARIABLE GUIDE
    --TOTAL AND PRICE IS FOR CALCULATE (WE GIVE QTY)
    --STATUS CID AND PID IS FOR JUDGE EXCEPITON

    DECLARE @TOTAL MONEY, @STATUS NVARCHAR, @PRICE MONEY, @CID INT, @PID INT;

    SELECT @STATUS = [STATUS] FROM CUSTOMER WHERE CUSTID = @PCUSTID;
    SELECT @PRICE = SELLING_PRICE FROM PRODUCT WHERE PRODID = @PPRODID;
    SELECT @CID = CUSTID FROM CUSTOMER WHERE CUSTID = @PCUSTID;
    SELECT @PID = PRODID FROM PRODUCT WHERE PRODID = @PPRODID;

    --ANY OF THE IF BELOW HAPPENS GOES TO CATCH BLOCK
    --No matching customer id found
    IF @CID IS NULL
      THROW 50160, 'Customer ID not found', 1
    --No matching product id found
    IF @PID IS NULL
      THROW 50170, 'Product ID not found', 1
    --Invalid customer status (status is not 'OK')
    IF @STATUS != 'OK'
      THROW 50150, 'Customer Status is not OK', 1
    --Sale Quantity range1 - 999
    IF @PQTY < 1 OR @PQTY > 999
      THROW 50140, 'Sale Quantity outside valid range', 1
    --Note: The YTD values must be increased by pqty * the product price
    SET @TOTAL = @PQTY * @PRICE

    --RUN HERE IF NONE OF ABOVE CONDITON HAPPENS
    --Update both the Customer and Product SalesYTD values 
    --Calls UPD_CUST_SALES_YTD_IN_DB  and UPD_PROD_SALES_YTD_IN_DB
    
    EXEC UPD_CUST_SALESYTD @PCUSTID = @PCUSTID, @PAMT = @TOTAL;
    EXEC UPD_PROD_SALESYTD @PPRODID = @PPRODID, @PAMT = @TOTAL;

    -- SHOULD I USE ROW COUNT HERE? HOW MANY ROW AFFECTED HRER? NO
    -- BOTH ID HERE ALSO COULD BE NULL NEED TO CHECK AGAIN HERE
    IF @PCUSTID IS NULL
      THROW 50160, 'Customer ID not found', 1
    
    IF @PPRODID IS NULL
      THROW 50170, 'Product ID not found', 1


  END TRY

  BEGIN CATCH
    IF ERROR_NUMBER() IN (50160, 50170, 50150, 50140)
      THROW

    ELSE
      BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
      END; 
  END CATCH;

END;

GO

--TEST

INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES
(1001, 'TESTPRODUCT1', 100, 200),
(1002, 'TESTPRODUCT2', 300, 400),
(1003, 'TESTPRODUCT3', 500, 600);

INSERT INTO CUSTOMER(CUSTID, CUSTNAME, SALES_YTD, [STATUS]) VALUES 
(1, 'TESTCUSTOMER1', 200, 'OK'),
(2, 'TESTCUSTOMER2', 400, 'OK'),
(3, 'TESTCUSTOMER3', 600, 'OK'),
(4, 'TESTCUSTOMER4', 800, 'SUSPEND');

--NORMAL TEST 
EXEC ADD_SIMPLE_SALE @PCUSTID = 1, @PPRODID = 1001, @PQTY = 10;
EXEC ADD_SIMPLE_SALE @PCUSTID = 2, @PPRODID = 1002, @PQTY = 20;
EXEC ADD_SIMPLE_SALE @PCUSTID = 3, @PPRODID = 1003, @PQTY = 30;
--Sale Quantity outside valid range
EXEC ADD_SIMPLE_SALE @PCUSTID = 1, @PPRODID = 1001, @PQTY = 9999;
--Customer status is not OK
EXEC ADD_SIMPLE_SALE @PCUSTID = 4, @PPRODID = 1002, @PQTY = 20;
--Customer ID not found
EXEC ADD_SIMPLE_SALE @PCUSTID = 5, @PPRODID = 1002, @PQTY = 20;
--Product ID not found
EXEC ADD_SIMPLE_SALE @PCUSTID = 4, @PPRODID = 1004, @PQTY = 20;

GO

SELECT * FROM CUSTOMER;
SELECT * FROM PRODUCT;

GO

DELETE FROM CUSTOMER;
DELETE FROM PRODUCT;

--TASK10 ENDING POINT
--==================================================================================================================================
GO
--TASK 11 STARTING POINT
--TASK 11 SUM_CUSTOMER_SALESYTD Sum and return the SalesYTD value of all rows in the Customer table
DROP PROCEDURE IF EXISTS SUM_CUSTOMER_SALESYTD
GO

CREATE PROCEDURE SUM_CUSTOMER_SALESYTD AS
BEGIN
  BEGIN TRY
    --WHY RETURN Sum and return the SalesYTD value of all rows in the Customer table
    RETURN (SELECT SUM(SALES_YTD) FROM CUSTOMER)
   
  END TRY

  BEGIN CATCH
    BEGIN
      DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1
    END;
  END CATCH;
END;

GO

--TEST
INSERT INTO customer(CUSTID, CUSTNAME, SALES_YTD, [STATUS]) VALUES 
(1, 'TESTCUSTOMER1', 200, 'OK'),
(2, 'TESTCUSTOMER2', 400, 'OK'),
(3, 'TESTCUSTOMER3', 600, 'OK'),
(4, 'TESTCUSTOMER4', 800, 'SUSPEND');

GO

DECLARE @CUSTSALESSUM MONEY;
EXEC @CUSTSALESSUM = SUM_CUSTOMER_SALESYTD;
PRINT @CUSTSALESSUM;

GO

DELETE FROM CUSTOMER;

GO
--TASK11 ENDING POINT
--=============================================================================================================================================
--TASK12 STARTING POINT
--TASK12 SUM_PRODUCT_SALESYTD Sum and return the SalesYTD value of all rows in the Product table
DROP PROCEDURE IF EXISTS SUM_PRODUCT_SALESYTD
GO

CREATE PROCEDURE SUM_PRODUCT_SALESYTD AS
BEGIN
  BEGIN TRY
    RETURN (SELECT SUM(SALES_YTD) FROM PRODUCT)
  END TRY

  BEGIN CATCH
    BEGIN
      DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1
    END;        
  END CATCH;
END;

GO

--TEST
INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES
(1001, 'TESTPRODUCT1', 100, 200),
(1002, 'TESTPRODUCT2', 300, 400),
(1003, 'TESTPRODUCT3', 500, 600);

GO

DECLARE @PRODSALESSUM MONEY;
EXEC @PRODSALESSUM = SUM_PRODUCT_SALESYTD;
PRINT @PRODSALESSUM;

GO

DELETE FROM PRODUCT;

GO

--TASK12 ENDING POINT
--======================================================================================================================================================
--TASK13 STARING POINT
--TASK13 GET_ALL_CUSTOMERS Get all customer details and return as a SYS_REFCURSOR
--cursor

--like a pointer- doesn't hold data- refers to a place in memory where data is stored
--when you run a query gernally - create a temprorary table that stroed in memory
--when the table are not need it released from memory
/* ==============================cursor demo===============
INSERT INTO customer(CUSTID, CUSTNAME, SALES_YTD, [STATUS]) VALUES 
(1, 'TESTCUSTOMER1', 200, 'OK'),
(2, 'TESTCUSTOMER2', 400, 'OK'),
(3, 'TESTCUSTOMER3', 600, 'OK'),
(4, 'TESTCUSTOMER4', 800, 'SUSPEND');

SELECT * FROM CUSTOMER;
/*
GO 

BEGIN
  DECLARE CURSOR_NAME CURSOR
    FOR SELECT_STATEMENT;

  OPEN CURSOR_NAME;

  FETCH NEXT FROM CURSOR INTO VARIABLE_LIST;

  WHILE @@FETCH_STATUS = 0
    BEGIN
      FETCH NEXT FROM CURSOR_NAME;
    END;
  CLOSE CURSOR_NAME;

  DEALLOCATE CURSOR_NAME;
END;
*/
-- STORE THE CURSOR INTO MEMEORY AND USE CURSOR NAME AS A REFERENCE LEAD THE SYSTEM TO THE LOCATION
/*
DROP PROCEDURE IF EXISTS CURSORDEMO;
GO
--TSQL CURSOR OUTPUT
--FOR GETTING CURSOR OUT OF PROCEDURE WE TRATE IT AS OUTPUT 
--VARYING CURSOR WILL CHANGE DURING THE LOOPING AND FETCHING SO THE DATATYPE WILL CHANGE THAT WHY WE HAVE VARYING
CREATE PROCEDURE CURSORDEMO @OUTCUR CURSOR VARYING OUTPUT AS
BEGIN

  --SET @OUTCUR = CURSOR
  --  FORWARD_ONLY STATIC FOR 
  --    SELECT CURRENCYCODE, NAME FROM SALES,CURRENCY;
  SET @OUTCUR = CURSOR FOR SELECT * FROM CUSTOMER;
  OPEN @OUTCUR;
END

GO
--/WE CREATE A PROCEDURE
-- API THIS WHOLE BIT WOULD BE DONE IN THE API
BEGIN
  --FOR THE VARIABLE_LIST
  --/STORE DECLAREING THE VARIABLE
  DECLARE @CID INT,@CNAME NVARCHAR(100), @YTD MONEY, @STATUS NVARCHAR(7);
  --/CRATEING A CURSOR
  DECLARE @MYCUR CURSOR
  --/INSTEAD DOING A  SECELE WE ARE DOING EXCU PASSING THE PROCUDURE INSIDE INTO A STROED PROCEDURE
  EXEC CURSORDEMO @OUTCUR = @MYCUR OUTPUT
  --HERE WE CAN CHANGE THE ORDER FOR COMLUMN THAT WE PULLING FROM THE TABLE
  --FOR SELECT * FROM CUSTOMER;
  --ALREADY OPENED UP THERE
  --OPEN MYCUR;
  --/THEN WE ARE LOOPING THOURGH
  FETCH NEXT FROM @MYCUR INTO @CID, @CNAME, @YTD, @STATUS;
  --TAKE THE FETCH ABOVE AND PUT INTO THE CODE INTO A LOOP 
  --WE ARE GOING TO STAY IN THE LOOP AS LONG AS FETCH SUCESSFUL
  --FETCH UNSEUCEESSFUL MEANS THERE IS NO MORE DATA TO FETCH
  WHILE @@FETCH_STATUS = 0
    BEGIN
      --*************PRINT AND CONCAT?
      PRINT (CONCAT(@CID, @CNAME, @YTD, @STATUS))
      FETCH NEXT FROM @MYCUR INTO @CID, @CNAME, @YTD, @STATUS;
    END;
  --WHEN FETCH UNSCUESSFUL OUT OF LOOP AND CLOSE THE CURSOR
  CLOSE @MYCUR;
  --EMPTY THE MEMORY SAVE IT FOR SYSTEM
  DEALLOCATE @MYCUR;
END;

SEE PICUTRE:

APP
  HTTP
API  SO LOOPING THROUGH THE CURSOR AT API LEVEL
  API CALL STORED PROCEDURE , RETURN WITH CURSOR
DATABASE
*/
--====================================cursor demo finish===================================

--back to task13

DROP PROCEDURE IF EXISTS GET_ALL_CUSTOMERS;
GO

CREATE PROCEDURE GET_ALL_CUSTOMERS @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
  SET @POUTCUR = CURSOR FOR 
  SELECT *
  FROM PRODUCT;

  OPEN @POUTCUR;
END

GO
BEGIN
  BEGIN TRY
    DECLARE @OUTCUST AS CURSOR;
    DECLARE @OUTCNAME NVARCHAR(100), @OUTYTD MONEY, @OUTSTATUS NVARCHAR(10), @OUTCID INT
    
    --**********HOW TO Throw Exception Details HERE 50000.  Use value of error_message()
    --Get all customer details and assign to pOutCur
    EXEC GET_ALL_CUSTOMERS @POUTCUR = @OUTCUST OUTPUT

    --TEST FOR WHETHER STH CAN BE RETURNED
    FETCH NEXT FROM @OUTCUST INTO @OUTCID, @OUTCNAME, @OUTYTD, @OUTSTATUS;

    WHILE @@FETCH_STATUS = 0

    BEGIN
      --SEE CURSOR DEMO
      PRINT CONCAT(@OUTCID, @OUTCNAME, @OUTYTD, @OUTSTATUS)
      FETCH NEXT FROM @OUTCUST INTO @OUTCID, @OUTCNAME, @OUTYTD, @OUTSTATUS;
    END

    CLOSE @OUTCUST;
    DEALLOCATE @OUTCUST;
  END TRY

  BEGIN CATCH
    BEGIN
      DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1
    END;    
  END CATCH;
END;

--TASK13 ENDING POINT
--=================================================================================================
--TASK14 STARING POINT
--TASK14 GET_ALL_PRODUCTS Get all product details and assign to pOutCur
DROP PROCEDURE IF EXISTS GET_ALL_PRODUCTS;
GO

CREATE PROCEDURE GET_ALL_PRODUCTS @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN 
  SET @POUTCUR = CURSOR FOR 
  SELECT *
  FROM PRODUCT;

  OPEN @POUTCUR;
END

GO

BEGIN
  BEGIN TRY
    DECLARE @OUTPROD AS CURSOR;
    DECLARE @OUTPID INT, @OUTPNAME NVARCHAR(100), @OUTPRICE MONEY, @OUTYTD MONEY;
    --Get all product details and return as a SYS_REFCURSOR
    --Get all product details and assign to pOutCur
    EXEC GET_ALL_PRODUCTS @POUTCUR = @OUTPROD OUTPUT

    FETCH NEXT FROM @OUTPROD INTO @OUTPID, @OUTPNAME, @OUTPRICE, @OUTYTD;

    WHILE @@FETCH_STATUS = 0
    BEGIN    
      PRINT CONCAT(@OUTPID, @OUTPNAME, @OUTPRICE, @OUTYTD)
      FETCH NEXT FROM @OUTPROD INTO @OUTPID, @OUTPNAME, @OUTPRICE, @OUTYTD;
    END

    CLOSE @OUTPROD;
    DEALLOCATE @OUTPROD;
  END TRY

  BEGIN CATCH
    BEGIN
      DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1
    END;   
  END CATCH;
END;

GO

--TASK14 ENDING POINT
--====================================================================================================
--TASK15 STARTING POINT
--TASK15 ADD_LOCATION Add a new row to the location table
DROP PROCEDURE IF EXISTS ADD_LOCATION;
GO
--Location Code- format ‘locnn’ ‘nn’= int ploccode nvarchar
CREATE PROCEDURE ADD_LOCATION @PLOCCODE NVARCHAR(20), @PMINQTY INT, @PMAXQTY INT AS
BEGIN
  BEGIN TRY    
    INSERT INTO [LOCATION] (LOCID, MINQTY, MAXQTY) VALUES
    (@PLOCCODE, @PMINQTY, @PMAXQTY)
    --Duplicate primary key 50180.  Duplicate location ID
    --Duplicate location ID  Server: Msg 2627, Level 14, State 1, Line 1 Violation of PRIMARY KEY constraint Constraint Name. 
    IF ERROR_NUMBER() = 2627
      THROW 50180, 'Duplicate location ID', 1
    --2628 – String or binary data would be truncated in table ‘%.*ls’, column ‘%.*ls’. Truncated value: ‘%.*ls’.
    --CHECK_LOCID_LENGTH check failed 50190. Location Code length invalid
    IF ERROR_NUMBER() = 2628
      THROW 50190, 'Location Code length invalid', 1
    --SQL Server throws the error msg 547 when a statement conflicts with the FOREIGN KEY/REFERENCE constraints. 3 possiable ways
    --CHECK_MINQTY_RANGE check failed 50200. Minimum Qty out of range
    --CHECK_MAXQTY_RANGE check failed 50210. Maximum Qty out of range
    --CHECK_MAXQTY_GREATER_MIXQTY check failed 0220. Minimum Qty larger than                  Maximum Qty
    IF ERROR_NUMBER() = 547
      -- serach key word
      BEGIN
        IF ERROR_MESSAGE() LIKE '%CHECK_MINQTY_RANGE%'
          THROW 50200, 'Minimum Qty out of range', 1
        IF ERROR_MESSAGE() LIKE '%CHECK_MAXQTY_RANGE%'
          THROW 50210, 'Maximum Qty out of range', 1
        IF ERROR_MESSAGE() LIKE '%CHECK_MAXQTY_GREATER_MIXQTY%'
          THROW 50220, 'Minimum Qty larger than Maximum Qty', 1
      END
  END TRY
  
  BEGIN CATCH
    IF ERROR_NUMBER() IN (50180, 50190, 50200, 50210, 50220)
      THROW
    ELSE
      BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
      END;    
  END CATCH;
END;

GO

DELETE FROM [LOCATION];
INSERT INTO [LOCATION] (LOCID, MINQTY, MAXQTY) VALUES
('LOC12', 123, 456);

GO

--TEST DUPLICATE LOCATION ID (LOC12)
EXEC ADD_LOCATION @PLOCCODE = 'LOC12', @QMINQTY = 123, @QMAXQTY = 456;
--TEST FOR LOCID LENGTH (LEN = 5 NN=INT)
EXEC ADD_LOCATION @PLOCCODE = 'LOC123', @QMINQTY = 123, @QMAXQTY = 456;
--TEST FOR MIN RANGE 0-999
EXEC ADD_LOCATION @PLOCCODE = 'LOC13', @QMINQTY = 9998, @QMAXQTY = 9999;
--TEST FOR MAX RANGE 0-999
EXEC ADD_LOCATION @PLOCCODE = 'LOC13', @QMINQTY = 9998, @QMAXQTY = 9999;
--TEST FOR MIN GREATER THAN MAX MAX>=MIN
EXEC ADD_LOCATION @PLOCCODE = 'LOC13', @QMINQTY = 456, @QMAXQTY = 123;

GO
SELECT * FROM [LOCATION];

GO

DELETE FROM [LOCATION];

GO

--TASK15 ENDING POINT

--=====================================================================================================

--TASK16 STARTING POINT
--TASK16 ADD_COMPLEX_SALE Adds a complex sale to the database.
DROP PROCEDURE IF EXISTS ADD_COMPLEX_SALE;
GO

CREATE PROCEDURE ADD_COMPLEX_SALE @PCUSTID INT, @PPRODID INT, @PQTY INT, @PDATE NVARCHAR(10) AS

BEGIN
  BEGIN TRY
    DECLARE @TOTAL MONEY, @STATUS NVARCHAR(7), @PRICE MONEY, @CID INT, @PID INT, @CONVEREDDATE DATE;

    SELECT @STATUS = [STATUS], @CID = CUSTID FROM CUSTOMER WHERE CUSTID = @PCUSTID;
    SELECT @PRICE = SELLING_PRICE, @UID = PRODID FROM PRODUCT WHERE PRODID = @PPRODID;
    --select convert(varchar, getdate(), 112) 	20061230
    --CONVERT VARCHAR TO DATE
    --Sale Date format yyyymmdd
    SELECT @CONVEREDDATE = CONVERT(NVARCHAR, @PDATE, 112);
    --Check if customer status is 'OK'. If not raise an exception. Invalid customer status (status is not 'OK') 50240. Customer status is not OK
    IF @STATUS != 'OK'
      THROW THROW 50240, 'Customer Status is not OK', 1
    --Check if quantity value is valid. If not raise an exception. (1-999) Sale Quantity range1 - 999 50230. Sale Quantity outside valid range
    IF @PQTY < 1 OR @PQTY > 999
      THROW 50230, 'Sale Quantity outside valid range', 1
    --*******Check if date value is valid. If not raise an exception. 2665 Invalid sale date 50250. Date not valid
    IF ERROR_NUMBER() = 2665
      THROW 50250, 'Invalid sale date', 1

    -- The saleid value must be obtained from the SALE_SEQ
    DECLARE @SID BIGINT
    SET @SID = NEXT VALUES FOR SALE_SEQ      

    -- Note: The YTD values must be increased by pqty * the unit price
    SET @TOTAL = @PQTY * @PRICE

    -- Calls UPD_CUST_SALES_YTD_IN_DB  and UPD_PROD_SALES_YTD_IN_DB
    -- Update both the Customer and Product SalesYTD values 
    
    EXEC UPD_CUST_SALESYTD @PCUSTID = @PCUSTID, @PAMT = @TOTAL;
    EXEC UPD_PROD_SALESYTD @PPRODID = @PPRODID, @PAMT = @TOTAL;

    -- Insert a new row into the Sale table.
    INSERT INTO SALE (SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE) VALUES
    (@SID, @PCUSTID, @PPRODID, @PQTY, @PRICE, @CONVEREDDATE)

    --No matching customer id found 50260. Customer ID not found
    --IF (SELECT COUNT(*) FROM CUSTOMER WHERE CUSTID = @pcustid) = 0
    IF @CID = NULL
      THROW 50260, 'Customer ID not found', 1
    --No matching product id found 50270. Product ID not found
    IF @PID = NULL
      THROW 50270, 'Product ID not found', 1
  END TRY    

  BEGIN CATCH
    IF ERROR_NUMBER() IN (50270, 50260, 50250, 50240, 50230)
      THROW
    ELSE
      BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 
      END; 
  END CATCH;
END;

GO

INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES
(1001, 'TESTPRODUCT1', 100, 200),
(1002, 'TESTPRODUCT2', 300, 400),
(1003, 'TESTPRODUCT3', 500, 600);

INSERT INTO CUSTOMER(CUSTID, CUSTNAME, SALES_YTD, [STATUS]) VALUES 
(1, 'TESTCUSTOMER1', 200, 'OK'),
(2, 'TESTCUSTOMER2', 400, 'OK'),
(3, 'TESTCUSTOMER3', 600, 'OK'),
(4, 'TESTCUSTOMER4', 800, 'SUSPEND');
--TEST INSERT
EXEC ADD_COMPLEX_SALE @PCUSTID = 1, @PPRODID = 1001, @PQTY = 10, @PDATE = 20200202;
--TEST CID NOT FOUND NULL
EXEC ADD_COMPLEX_SALE @PCUSTID = 5, @PPRODID = 1001, @PQTY = 10, @PDATE = 20200202;
--TEST PID NOT FOUND NULL
EXEC ADD_COMPLEX_SALE @PCUSTID = 1, @PPRODID = 1004, @PQTY = 10, @PDATE = 20200202;
--TEST INVALID DATE YYYYMMDD
EXEC ADD_COMPLEX_SALE @PCUSTID = 1, @PPRODID = 1001, @PQTY = 10, @PDATE = 20209999;
--TEST QTY OUT OF RANGE 1-999
EXEC ADD_COMPLEX_SALE @PCUSTID = 1, @PPRODID = 1001, @PQTY = 1000, @PDATE = 20200202;
--TEST STATUS NOT OK
EXEC ADD_COMPLEX_SALE @PCUSTID = 4, @PPRODID = 1001, @PQTY = 10, @PDATE = 20200202;

GO

SELECT * FROM SALE;

GO 

DELETE FROM SALE;

GO

DELETE FROM PRODUCT;

GO

DELETE FROM CUSTOMER;

GO
--TASK16 ENDING POINT
--======================================================================================================--TASK17 STARTING POINT
--TASK17 GET_ALLSALES Get all customer details and return as a SYS_REFCURSOR
DROP PROCEDURE IF EXISTS GET_ALLSALES;
GO

CREATE PROCEDURE GET_ALLSALES @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
  SET @POUTCUR = CURSOR FOR
  SELECT *
  FROM SALE;

  OPEN @POUTCUR;
END

GO

BEGIN
  BEGIN TRY
    DECLARE @OUTSALE AS CURSOR;
    DECLARE @OUTSID BIGINT, @OUTCID INT, @OUTPID INT, @OUTQTY INT, @OUTPRICE MONEY, @OUTDATE DATE;
    --Get all complex sale details and assign to pOutCur
    EXEC GET_ALLSALES @POUTCUR = @OUTSALE OUTPUT

    FETCH NEXT FROM @OUTSALE INTO @OUTSID, @OUTCID, @OUTPID, @OUTQTY, @OUTPRICE, @OUTDATE;

    WHILE @@FETCH_STATUS = 0
    
    BEGIN
      PRINT CONCAT(@OUTSID, @OUTCID, @OUTPID, @OUTQTY, @OUTPRICE, @OUTDATE);
      FETCH NEXT FROM @OUTSALE INTO @OUTSID, @OUTCID, @OUTPID, @OUTQTY, @OUTPRICE, @OUTDATE;
    END

    CLOSE @OUTSALE;
    DEALLOCATE @OUTSALE;

  END TRY

  BEGIN CATCH
    BEGIN
      DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1
    END; 
  END CATCH;
END;

GO

--TASK17 ENDING POINT
--===================================================================================================
--TASK18 STARING POINT
--TASK18 COUNT_PRODUCT_SALES Count and return the int of sales with nn days of current date
DROP PROCEDURE COUNT_PRODUCT_SALES;
GO

CREATE PROCEDURE COUNT_PRODUCT_SALES @PDAYS INT AS
BEGIN
  BEGIN TRY
    DECLARE @DATEADD DATE
    --DATEADD (datepart , number , date ) This function adds a specified number value (as a signed integer) to a specified datepart of an input date value, and then returns that modified value.
    --SYSDATETIME ( )  Returns a datetime2(7) value that contains the date and time of the computer on which the instance of SQL Server is running.
    --Count sales made within pdays of today's date
    SET @DATEADD = DATEADD(DD, @PDAYS, SYSDATETIME());
    --RETURN INT

    RETURN (SELECT COUNT(*)
    FROM SALE
    WHERE SALEDATE >= @DATEADD);

    --Count and return the int of sales in the SALES table with nn days of current date
    --**************
    DECLARE @COUNTPS INT
    --COUNT THE SALES WITH PDAYS
    SET @COUNTPS = COUNT_PRODUCT_SALES (@PDAYS)
  END TRY

  BEGIN CATCH    
    BEGIN
      DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1
    END; 
  END CATCH 
END

GO
--Count and return the int of sales in the SALES table with nn days of current date

EXEC COUNT_PRODUCT_SALES @PDAYS = 2;
INSERT
DELETE
GO
--TASK18 ENDING POINT
--==================================================================================================
--TASK19 STARTING POINT
--TASK19 DELETE_SALE Delete a row from the SALE table
DROP PROCEDURE DELETE_SALE;
GO

CREATE PROCEDURE DELETE_SALE AS
BEGIN
  BEGIN TRY
    DECLARE @MINSALE BIGINT, @PID INT, @CID INT, @PRICE MONEY
    --Determine the smallest saleid value in the SALE table.  (use Select MIN()...)
    SELECT @MINSALE = MIN(SALEID) FROM SALE;
    DELETE FROM SALE
    --MAEK MINSALE UNIQUE Otherwise delete a row from the SALE table with the matching sale id
    WHERE SALEID = @MINSALE;
    --If the value is NULL raise a No Sale Rows Found exception.No Sale Rows Found 50280. No Sale Rows Found
    IF @MINSALE = NULL
      THROW 50280, 'No Sale Rows Found', 1
    ELSE
    DECLARE @TOTAL MONEY, @QTY INT
    SELECT @PRICE = PRICE, @CID = CUSTID, @QTY = QTY, @PID =PRODID
    FROM SALE
    WHERE SALEID = @MINSALE
    --You must calculate the amount using the PRICE in the SALE table multiplied by the QTY
    SET @TOTAL = @QTY * @PRICE
    --Calls UPD_CUST_SALES_YTD_IN_DB  and UPD_PROD_SALES_YTD_IN_DB 
    --so that the correct amount is subtracted from SALES_YTD.
    --*****************************************
    --ANOTHER VARIABLE MAKE @CORRECTTOTAL = -(@TOTAL)?
    EXEC UPD_CUST_SALESYTD @PCUSTID = @PCUSTID, @PAMT = -@TOTAL;
    EXEC UPD_PROD_SALESYTD @PPRODID = @PPRODID, @PAMT = -@TOTAL;
  END TRY
  
  BEGIN CATCH       
    IF ERROR_NUMBER() IN (50280)
      THROW
    ELSE
      BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END; 
  END CATCH;
END;

GO 

INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES
(1001, 'TESTPRODUCT1', 10, 500),
(1002, 'TESTPRODUCT2', 20, 500);

INSERT INTO CUSTOMER(CUSTID, CUSTNAME, SALES_YTD, [STATUS]) VALUES 
(1, 'TESTCUSTOMER1', 500, 'OK'),
(2, 'TESTCUSTOMER2', 500, 'OK');
    
INSERT INTO SALE(SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE) VALUES
(100, 1, 1001, 10, 10, 2020-10-10),
(200, 2, 1002, 20, 20, 2020-10-10);

GO

EXEC DELETE_SALE;

GO
SELECT * FROM CUSTOMER;
GO
SELECT * FROM PRODCUT;
GO
SELECT * FROM SALE;
GO

DELETE FROM CUSTOMER;
GO
DELETE FROM PRODCUT;
GO
DELETE FROM SALE;
GO
--TASK19 ENDING POINT
--=============================================================================
--TASK20 STARING POINT
--TASK20 DELETE_ALL_SALES Delete ALL ROWS from the SALE table
DROP PROCEDURE DELETE_ALL_SALES;
GO

CREATE PROCEDURE DELETE_ALL_SALES AS
BEGIN
  BEGIN TRY
    --Delete all rows in the SALE table 
    DELETE FROM SALE;
    --Set the Sales_YTD value to zero for all rows in the Customer and Product tables
    UPDATE CUSTOMER
    SET SALES_YTD = 0;
  END TRY

  BEGIN CATCH
    BEGIN
      DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1
    END; 
  END CATCH;
END;

GO

INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES
(1001, 'TESTPRODUCT1', 10, 500),
(1002, 'TESTPRODUCT2', 20, 500);

INSERT INTO CUSTOMER(CUSTID, CUSTNAME, SALES_YTD, [STATUS]) VALUES 
(1, 'TESTCUSTOMER1', 500, 'OK'),
(2, 'TESTCUSTOMER2', 500, 'OK');
    
INSERT INTO SALE(SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE) VALUES
(100, 1, 1001, 10, 10, 2020-10-10),
(200, 2, 1002, 20, 20, 2020-10-10);

GO

EXEC DELETE_ALL_SALES;

GO
SELECT * FROM CUSTOMER;
GO
SELECT * FROM PRODCUT;
GO
SELECT * FROM SALE;
GO

DELETE FROM CUSTOMER;
GO
DELETE FROM PRODCUT;
GO
DELETE FROM SALE;
GO

--TASK20 ENDING POINT
--==================================================================================
--TASK21 STARTING POINT
--TASK21 DELETE_CUSTOMER Delete a row from the Customer table
DROP PROCEDURE IF EXISTS DELETE_CUSTOMER
GO

CREATE PROCEDURE DELETE_CUSTOMER @PCUSTID INT AS
BEGIN 
  BEGIN TRY
    --Delete a customer with a matching customer id
    DELETE FROM CUSTOMER
    WHERE CUSTID = @PCUSTID 
    --No matching customer id found 50290. Customer ID not found
    IF @@ROWCOUNT = 0
      THROW 50290, 'Customer ID not found', 1
    -- ComplexSales exist for the customer, replace the default error code with a custom made exception to handle this error & raise the exception below
    -- SHOULD BE HERE IN TRY OR CATCH NEED TO BE DOWN IN CATCH
    
  END TRY
  BEGIN CATCH
    IF ERROR_NUMBER() IN (50290, 50300)  
      THROW
    IF ERROR_NUMBER() = 547
      THROW 50300, 'Customer cannot be deleted as sales exist', 1
    ELSE
      BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 
      END; 
  END CATCH;
END;

GO

INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES
(1001, 'TESTPRODUCT1', 10, 500),
(1002, 'TESTPRODUCT2', 20, 500);

INSERT INTO CUSTOMER(CUSTID, CUSTNAME, SALES_YTD, [STATUS]) VALUES 
(1, 'TESTCUSTOMER1', 500, 'OK'),
(2, 'TESTCUSTOMER2', 500, 'OK');
    
INSERT INTO SALE(SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE) VALUES
(100, 1, 1001, 10, 10, 2020-10-10),
(200, 2, 1002, 20, 20, 2020-10-10);

GO

--TEST FOR ID NOT FOUND
EXEC DELETE_CUSTOMER @PCUSTID = 3;
--TEST FOR SALES EXISTS CANT DELETE
EXEC DELETE_CUSTOMER @PCUSTID = 1;
--TEST FOR NORMAL DELETE
EXEC DELETE_ALL_SALES;
EXEC DELETE_CUSTOMER @PCUSTID = 1;

GO
SELECT * FROM CUSTOMER;
GO
SELECT * FROM PRODCUT;
GO
SELECT * FROM SALE;
GO

DELETE FROM CUSTOMER;
GO
DELETE FROM PRODCUT;
GO
DELETE FROM SALE;
GO
  
--TASK21 ENDING POINT;
--================================================================================
--TASK22 STARTING POINT
--TASK22 DELETE_PRODUCT Delete a row from the Product table
DROP PROCEDURE DELETE_PRODUCT;
GO

CREATE PROCEDURE DELETE_PRODUCT @PPRODID INT AS
BEGIN 
  BEGIN TRY
    --Delete a product with a matching Product id
    DELETE FROM PRODUCT
    WHERE PRODID = @PPRODID
    --No matching Product id found 50310. Product ID not found
    IF @@ROWCOUNT = 0
      THROW 50310, 'Product ID not found', 1    
  END TRY

  BEGIN CATCH
    IF ERROR_NUMBER() IN (50310)
      THROW
    --Product has child complexsales rows 0320. Product cannot be deleted as sales exist
    --f ComplexSales exist for the customer, Oracle?? would normally generate a 'Child Record Found' error (error code -2292). Instead,Create a custom made exception to handle this error & raise the exception below
    IF ERROR_NUMBER() = 547
            THROW 50320, 'Product cannot be deleted as sales exist', 1
    ELSE
      BEGIN
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 
      END; 
  END CATCH;
END;

GO

INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES
(1001, 'TESTPRODUCT1', 10, 500),
(1002, 'TESTPRODUCT2', 20, 500);

INSERT INTO CUSTOMER(CUSTID, CUSTNAME, SALES_YTD, [STATUS]) VALUES 
(1, 'TESTCUSTOMER1', 500, 'OK'),
(2, 'TESTCUSTOMER2', 500, 'OK');
    
INSERT INTO SALE(SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE) VALUES
(100, 1, 1001, 10, 10, 2020-10-10),
(200, 2, 1002, 20, 20, 2020-10-10);

GO

--TEST FOR ID NOT FOUND
EXEC DELETE_PRODUCT @PPRODID = 1003;
--TEST FOR SALES EXISTS CANT DELETE
EXEC DELETE_PRODUCT @PPRODID = 1001;
--TEST FOR NORMAL DELETE
EXEC DELETE_ALL_SALES;
EXEC DELETE_PRODUCT @PPRODID = 1001;

GO
SELECT * FROM CUSTOMER;
GO
SELECT * FROM PRODCUT;
GO
SELECT * FROM SALE;
GO

DELETE FROM CUSTOMER;
GO
DELETE FROM PRODCUT;
GO
DELETE FROM SALE;
GO


