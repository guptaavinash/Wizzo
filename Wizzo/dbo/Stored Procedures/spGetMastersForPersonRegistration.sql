
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetMastersForPersonRegistration]
	
AS
BEGIN
	SELECT 'O+' AS BloddGroups
	UNION
	SELECT 'O-'
	UNION
	SELECT 'B+'
	UNION
	SELECT 'B-'
	UNION
	SELECT 'AB+'
	UNION
	SELECT 'AB-'
	UNION
	SELECT 'A+'
	UNION
	SELECT 'A-'

	SELECT '10th' AS Qualification
	UNION
	SELECT '12th'
	UNION
	SELECT 'Graduate'
	UNION
	SELECT 'Post Graduate'
END


