-- SELECT name, database_id, create_date FROM sys.databases;
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



-- GET_CUSTOMER_STRING 
DROP PROCEDURE IF EXISTS GET_CUSTOMER_STRING
GO

CREATE PROCEDURE GET_CUSTOMER_STRING @pCustId INT, @pReturnString NVARCHAR(100) OUTPUT AS 
BEGIN

DECLARE @CustName NVARCHAR(100), @Status NVARCHAR(7), @YTD MONEY;

SELECT @CustName = CUSTNAME, @Status = [STATUS], @YTD = SALES_YTD
FROM CUSTOMER
WHERE CUSTID = @pCustId

IF @@ROWCOUNT = 0
  THROW 50060, 'Customer ID not Found', 1

SET @pReturnString = CONCAT(' Custid: ', @pCustId, ' Name: ', @CustName, ' Status: ', @Status, ' SalesYTD: ', @YTD)


END
