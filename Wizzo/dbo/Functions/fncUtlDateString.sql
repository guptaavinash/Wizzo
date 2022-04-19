



CREATE FUNCTION [dbo].[fncUtlDateString]
--This function returns date string as dd-MMM-yyyy
	(@DateIn DATETIME)
RETURNS varChar(20)	
AS  
BEGIN
	DECLARE @DATEOUT varChar(20)
SET @DATEOUT=CASE LEN(CAST(DATEPART(dd, @DateIn) AS VarChar)) WHEN 1 THEN '0' + CAST(DATEPART(dd, @DateIn) AS VarChar) ELSE CAST(DATEPART(dd, @DateIn) AS VarChar) END + '-' + LEFT(CAST(DATENAME(MM, @DateIn) AS VarChar),3) + '-'  + RIGHT(CAST(DATEPART(YY, @DateIn) AS VarChar),2) + ' ' + REPLACE(REPLACE(RIGHT(CONVERT(VARCHAR(30), @DateIn),7),'AM',' AM'),'PM',' PM')
	RETURN(@DATEOUT)
END





