

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpCycEntry]
	@flgInOut TINYINT=1 -- Default is Pull
AS
BEGIN
	DECLARE @CurrentDate datetime
	SELECT @CurrentDate =DATEADD(HOUR,5,getdate() ) 
	SELECT @CurrentDate =DATEADD(MINUTE,30,@CurrentDate) 
	INSERT INTO [tblExtractCycMaster](CycleTimeID,flgInOut)
	SELECT CAST(YEAR(@CurrentDate) AS BIGINT) * 100000000+MONTH(@CurrentDate)*1000000+DAY(@CurrentDate) * 10000+ DATEPART(HOUR,@CurrentDate) *100 + DATEPART(MINUTE,@CurrentDate) CycTimeID,@flgInOut

	SELECT SCOPE_IDENTITY() CycleUnqID 

	--select * from sys.time_zone_info;
END
