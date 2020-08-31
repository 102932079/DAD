-- we have been thorugh @create procedure @passing variable into parameter @if logic loop @mutiple sql statement in procedure @how to group complex opration together into sigle procudure
--this a complex example for stored procedure
IF OBJECT_ID('ADD_CUSTOMER') IS NOT NULL
DROP PROCEDURE ADD_CUSTOMER;
GO
-- drop if exists procedure add_customer （older newer database depend on version）

CREATE PROCEDURE ADD_CUSTOMER @PCUSTID INT, @PCUSTNAME NVARCHAR(100) AS

-- begin try end try begin catch end catch sturcture (error handling)
--try block can have logic
-- !!!expected to do try catch for almost everything after any excepiton need do test according to requirement if the test piece are happy you comment those code out, the entire sql need to be run one piece create go between.
BEGIN
    BEGIN TRY
    -- thats how you throw a excepton out of range same with csharp
    -- as soon as the excepiton ocure then catch block will catch them

        IF @PCUSTID < 1 OR @PCUSTID > 499
            THROW 50020, 'Customer ID out of range', 1

            --if condition within the range pass in the variable into parameter

        INSERT INTO CUSTOMER (CUSTID, CUSTNAME, SALES_YTD, STATUS) 
        VALUES (@PCUSTID, @PCUSTNAME, 0, 'OK');

    END TRY
    BEGIN CATCH
    -- how to find out that error number means by google or just throw it
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
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
--  we need to write the test with any procedure as assignment required
END;

GO
-- for Guaranteed no row in customer to create a perfect test enviorment
delete from customer;
-- if the test piece are happy you comment those code out
GO
-- for this test code the pcustid within the range so it will create varible and pass valuse into the varible sucessfully
EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude2';
-- for this test code due to out of range will the throw 50020 exception
EXEC ADD_CUSTOMER @pcustid = 500, @pcustname = 'testdude3';
-- for this test code due to dulpulicate the values can not pass in throw 50010 (dulplicate primary key)
EXEC ADD_CUSTOMER @pcustid = 500, @pcustname = 'testdude4';
-- to see only one row in there
select * from customer;