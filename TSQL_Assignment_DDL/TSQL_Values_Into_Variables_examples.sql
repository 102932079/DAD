--USE DEMO; SELECT name, database_id, create_date FROM sys.databases;
DROP TABLE IF EXISTS A_TABLE;

GO

CREATE TABLE A_TABLE(
    RID INTEGER,
    RDATA NVARCHAR(100),
    PRIMARY KEY(RID)
);

GO

INSERT INTO A_TABLE(RID, RDATA) VALUES
(1, 'DYNAMIC VALUES');

GO

CREATE FUNCTION GET_TEXT () RETURNS NVARCHAR(100) AS
BEGIN
    RETURN 'PROCEDURE / FUNCTION RETURNED VALUES';
END

GO

-- variable @textout 
BEGIN
    DECLARE @TEXTOUT NVARCHAR(100);
-- set keyword set a varible into a values
    SET @TEXTOUT = 'HARD CODED VALUES';
    PRINT(CONCAT ('SET = IS FOR - ', @TEXTOUT));
-- selecet keyword same with select statement just put a variable equal in there 
-- select whatever you got in data put in variable @textout but variable can only hold one value
-- to add where clause to make sure only return one value
    SELECT @TEXTOUT = RDATA FROM A_TABLE WHERE RID = 1;
    PRINT(CONCAT ('SELECT  = IS FOR - ', @TEXTOUT));

    EXEC @TEXTOUT = GET_TEXT;
    PRINT(CONCAT ('EXEC = IS FOR - ', @TEXTOUT));

END

--------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS A_TABLE;

GO

CREATE TABLE A_TABLE(
    RID INTEGER,
    RDATA NVARCHAR(100),
    PRIMARY KEY(RID)
);

GO

INSERT INTO A_TABLE(RID, RDATA) VALUES
(1, 'SELECTED VALUE ONE'),
(2, 'SELECTED VALUE TWO');

GO

------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS NORMAL_PARAM_EXAMPLE;

GO

CREATE PROCEDURE NORMAL_PARAM_EXAMPLE @RID INT, @PARAM NVARCHAR(100) AS

BEGIN

    -- ANY CHANGES MADE TO @OUTPARAM HERE WILL ** NOT ** REMAIN AFTER THE PROCEDURE
    SELECT @PARAM = RDATA FROM A _TABLE WHERE RID = @RID;
    PRINT (CONCAT ('INSIDE AFTER - ', @PARAM ));
END;

GO

BEGIN

DECLARE @EXTERNAL_PARAM NVARCHAR(100) = 'INITIAL VALUE'
--1
PRINT (CONCAT ('BEFORE ANYTHING - ', @EXTERNAL_PARAM ));

EXEC NORMAL_PARAM_EXAMPLE @RID = 1, @PARAM = @EXTERNAL_PARAM
--2
--3
-----------------------------THE PROCEDURE IS FINISHED AT THIS POINT
--4
PRINT (CONCAT ('AFTER NORMAL_PARAM_EXAMPLE - ', @EXTERNAL_PARAM ));

END;

GO

------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS OUT_PARAM_EXAMPLE;

GO

CREATE PROCEDURE OUT_PARAM_EXAMPLE @RID INT, @OUTPARAM NVARCHAR(100) OUTPUT AS

BEGIN
    -- ANY CHANGES MADE TO @OUTPARAM HERE WILL REMAIN AFTER THE PROCEDURE
    PRINT (CONCAT ('INSIDE BEFORE - ', @OUTPARAM ));
    SELECT @OUTPARAM = RDATA FROM A_TABLE WHERE RID = @RID;
    PRINT (CONCAT ('INSIDE AFTER - ', @OUTPARAM ));
END;

--powerful way to get data from procedure, to get data out instead of return it.

BEGIN 

DECLARE @EXTERNAL_PARAM NVARCHAR(100) = 'INITIAL VALUE'
--1
PRINT (CONCAT ('BEFORE ANYTHING - ', @EXTERNAL_PARAM ));
-- the output parameter stay on after the procedure
EXEC OUT_PARAM_EXAMPLE @RID = 1, @OUTPARAM = @EXTERNAL_PARAM OUTPUT
--2
--3
---------------------------
--4

PRINT ( CONCAT (' AFTER OUT_PARAM_EXAMPLE - ', @EXTERNAL_PARAM))


END



---------------------------------------------------------------------------------------------

-- ROW COUNT TELLS YOU HOW MANY ROWS WERE AFFECTED BJY THE MOST RECENTLY RUNQUERY

--SELECT, UPDATE, DELETE, INSERT


BEGIN
    SELECT RDTA FROM A_TABLE WHERE RID = 1 ;
    -- 1 ROW AFFECTED WITHOUT WHERE 2 ROWS AFFECTED

    --DELETE FROM A_TABLE; 2 ROWS AFFECTED

    PRINT (CONCAT ('NUM OF ROWS AFFECTED - ', @@ROWCOUNT ));

    END;