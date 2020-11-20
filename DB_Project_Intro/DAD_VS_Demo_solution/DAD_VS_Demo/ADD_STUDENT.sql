CREATE PROCEDURE [dbo].[ADD_STUDENT]
	@pStuid int,
	@pFname NVARCHAR(100),
	@pSurname NVARCHAR(100)
AS
	INSERT INTO STUDENT (StudentID, Fname, Surname, NewColumn ) VALUES
    (@pStuid, @pFname, @pSurname, null);
    
RETURN 0
