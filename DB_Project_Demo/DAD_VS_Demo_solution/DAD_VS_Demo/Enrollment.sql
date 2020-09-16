CREATE TABLE [dbo].[Enrollment]
(
	[StudentID] INT NOT NULL,
	[SubjectCode] NVARCHAR(100) NOT NULL,
	[Grade] NVARCHAR(2) NULL,
	PRIMARY KEY( StudentID, SubjectCode),
	CONSTRAINT MAT_ASKED_FOR_THIS FOREIGN KEY (StudentID ) REFERENCES STUDENT, 
    CONSTRAINT [CK_Grade] CHECK (Grade in ('N', 'P', 'C')), 
   
)
