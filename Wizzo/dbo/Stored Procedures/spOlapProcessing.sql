

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spOlapProcessing] 
	
AS
BEGIN
	DECLARE @CurrentWeekEning DATE
	DECLARE @Counter INT
	DECLARE @MaxCount INT
	CREATE TABLE #WeekList(Id INT IDENTITY(1,1),WeekEnding DATE)

	SELECT @CurrentWeekEning=dbo.fncUTLGetWeekEndDate(GETDATE())

	INSERT INTO #WeekList(WeekEnding) SELECT DATEADD(dd,-14,@CurrentWeekEning)
	INSERT INTO #WeekList(WeekEnding) SELECT DATEADD(dd,-7,@CurrentWeekEning)
	INSERT INTO #WeekList(WeekEnding) SELECT @CurrentWeekEning	


	--INSERT INTO #WeekList(WeekEnding) 
	--SELECT DISTINCT WeekEnding FROM tblOLAPTimeHierarchy_Day ORDER BY 1
	--SELECT DISTINCT dbo.fncUTLGetWeekEndDate(VisitDate) FROm tblVisitMaster ORDER BY 1
	
	--SELECT * FROM #WeekList ORDER BY 1
	
	SELECT @Counter=1
	SELECT @MaxCount=MAX(Id) FROM #WeekList

	WHILE @Counter<=@MaxCount
	BEGIN
		SELECT @CurrentWeekEning=WeekEnding FROM #WeekList WHERE Id=@Counter
		PRINT @CurrentWeekEning

		INSERT INTO tblOlapProcessingLog(WeekEnding) SELECT @CurrentWeekEning

		EXEC spOLAPPopulateDailyTables @CurrentWeekEning

		SET @Counter+=1
	END
	EXEC [spPopulateOLAPCompanySalesHierarchy]
	EXEC spPopulateOLAPFullSalesHierarchy
END




