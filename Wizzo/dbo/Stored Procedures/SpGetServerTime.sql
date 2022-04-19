-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpGetServerTime] 
	
AS
BEGIN
	DECLARE @LateTimimgs VARCHAR(10)
	SET @LateTimimgs='09:30 AM'
	SELECT FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt') + '^' + @LateTimimgs as ServerTime
END
