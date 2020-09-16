/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

IF ('$(DeployTestData)' = 'true' )
BEGIN
    DELETE FROM STUDENT;

    INSERT INTO STUDENT (StudentID, Fname, Surname, NewColumn ) VALUES
    (1, 'Onezz', 'dsfsdf, null'),
    (2, 'Twozz', 'dsfsdf, null'),
    (3, 'Threezz', 'dsfsdf, null');

END