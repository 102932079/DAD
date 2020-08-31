-- UPD_CUST_SALESYTD demo not same

--SELECT, UPDATE, DELETES AND INSERTS
-- run quiry effeivtiontly
BEGIN
    DECLARE @ExampleCustId INT = 1, @ExampleAmount MONEY = 100.00;
    --IF we select sth not exist it will return null values the queire still run don't going to update any rows
    -- WE DONT HAVE TO CHECK IF THE CUSTOMER EXISTS FRIST WITH WHERE CLAUSE WILL NARROW DOWN THE CHOICE TO ONE
    -- WITH UPDATE AND DELETE WE CAN JUST RUN THE QUIRE WITHOUT CHECK break out the data
    --keep this
    IF (@ExampleAmount > 999.00 )
        THROW 50000, 'TEST', 1

    IF EXISTS (SELECT * FROM CUSTOMER WHERE CUSTID = @ExampleCustId)
    --if exist update this 
    -- If the examplecustid not exist the quiry will still working without breaking the data we can check it later
    --but for exampleamount we must check it first
    --keep this
        UPDATE customer SET sales_ytd = sales_ytd + @ExampleAmount WHERE CUSTID = @ExampleCustId;
    --else throw a error
    ELSE
        THROW 50001, 'NO CUSTOMER',1
    --==========above quiry is not suggestable run two quiry waste resouce
    -- DELETE FROM CUSTOMER WHERE CUSTID = @NONEXISTANT SAME WITH UPDATE
    --keep this
    if @@ROWCOUNT = 0
        THROW 50001, 'NO CUSTOMER', 1

        PRINT ('No Row Updated')
    ELSE
        PRINT (CONCAT('There was ', @@ROWCOUNT, ' rows ! '))

END

SELECT * FROM CUSTOMER

--====================================another demo
BEGIN
-- one variable only hold one name but here we select mutiple name into one name
-- in orical you will have a excepiton for pass into mutiple values into a single variable
    DECLARE @CNAME VARCHAR(100)
    --CHECK THE IF THE QURIRY RETURN VALUES ARE QUNIQE
    IF ((SELECT COUNT(*) FROM CUSTOMER WHERE [STATUS] = 'OK') > 1)
        THROW 50001, 'NOT A NNIQUE ROW', 1
    -- if the varible not unique you could miss or lose data WHERE HERE MAKE THE VALUES UNIQUE
    -- 3 FOR NULL
    SELECT @CNAME = CUSTNAME FROM CUSTOMER WHERE CUSTID = 1
    -- DEMO BELOW THE STATTUS WILL HAVE 2 VALUES
    SELECT @CNAME = CUSTNAME FROM CUSTOMER WHERE [STATUS] = 'OK'

    PRINT @CNAME

END

INSERT INTO CUSTOMER VALUES (2, 'BARNEY RUBBLE', 120.00, 'OK')