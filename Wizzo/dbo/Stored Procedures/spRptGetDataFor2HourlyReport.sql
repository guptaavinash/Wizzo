-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spRptGetDataFor2HourlyReport]0,0,'30-Nov-2021'
CREATE PROCEDURE [dbo].[spRptGetDataFor2HourlyReport]
@NodeId INT,
@NodeType INT,
@RptDate DATE
AS
BEGIN
	SELECT * INTO #DataFor2HourlyReport FROM tmpRptDataFor2HourlyReport WHERE 1<>1
	DECLARE @StrCategory VARCHAR(5000)=''
	DECLARE @StrCategoryForGrouping VARCHAR(5000)=''
	DECLARE @StrSql VARCHAR(8000)=''

	IF @NodeType=0
	begin
		insert into #DataFor2HourlyReport
		select * from tmpRptDataFor2HourlyReport 
	end
	else IF @NodeType=100
	begin
		insert into #DataFor2HourlyReport
		select * from tmpRptDataFor2HourlyReport where ZoneId=@NodeId and ZoneNodeType=@NodeType
	end
	else if @NodeType=110
	begin
		insert into #DataFor2HourlyReport
		select * from tmpRptDataFor2HourlyReport where ASMAreaId=@NodeId and ASMAreaNodeType=@NodeType
	end
	SELECT @StrCategory=strCategory,@StrCategoryForGrouping=StrCategoryForGrouping FROm #DataFor2HourlyReport
	--SELECT @StrCategory,@StrCategoryForGrouping
	--SELECT * FROM #DataFor2HourlyReport

	SELECT 0 AS flgOverall,0 AS flgLvl,CAST('0' AS VARCHAR(10)) AS flgGrouping,ZoneId,Zone,RegionNodeId,Region,ASMAreaId,ASM,ASMArea,0 AS PlannedSalesmen,0 AS ActualSalesmen,0 AS TotSalesmenOnField,0 AS TotSalesmenOnTelecalling,SUM(PlannedCalls) PlannedCalls,SUM(ActCalls) AS TotCallsMade,SUM(ProdCalls) AS ProdCalls,CASE WHEN ISNULl(SUM(ActCalls),0)>0 THEN CAST(ROUND((SUM(ProdCalls)/CAST(SUM(ActCalls) AS FLOAT))*100,0) AS VARCHAR) + '%' END AS [PC %], SUM(TotLinesOrdered) LinesOrdered,CASE WHEN ISNULl(SUM(ProdCalls),0)>0 THEN ROUND((SUM(TotLinesOrdered)/CAST(SUM(ProdCalls) AS FLOAT)),2) END AS [Avg LPC],SUM(OrderQty) OrderQtyInPcs,SUM(OrderVal) OrderVal INTO #Summary
	FROM #DataFor2HourlyReport GROUP BY ZoneId,Zone,RegionNodeId,Region,ASMAreaId,ASM,ASMArea

	UPDATE A SET A.PlannedSalesmen=B.PlannedSalesmen
	FROM #Summary A INNER JOIN (SELECT ASMAreaId,COUNT(DISTINCT SalesmanNodeId) PlannedSalesmen FROM #DataFor2HourlyReport WHERE ISNULL(SalesmanNodeId,0)>0 AND flgOnRoute=1 GROUP BY ASMAreaId) B ON A.ASMAreaId=B.ASMAreaId

	UPDATE A SET A.ActualSalesmen=B.ActualSalesmen
	FROM #Summary A INNER JOIN (SELECT ASMAreaId,COUNT(DISTINCT SalesmanNodeId) ActualSalesmen FROM #DataFor2HourlyReport WHERE ISNULL(SalesmanNodeId,0)>0 AND ActCalls>0 GROUP BY ASMAreaId) B ON A.ASMAreaId=B.ASMAreaId

	UPDATE A SET A.TotSalesmenOnField=B.TotSalesmenOnField
	FROM #Summary A INNER JOIN (SELECT ASMAreaId,COUNT(DISTINCT SalesmanNodeId) TotSalesmenOnField FROM #DataFor2HourlyReport WHERE ISNULL(SalesmanNodeId,0)>0 AND SalesmanWorkingType=2 GROUP BY ASMAreaId) B ON A.ASMAreaId=B.ASMAreaId

	UPDATE A SET A.TotSalesmenOnTelecalling=B.TotSalesmenOnTelecalling
	FROM #Summary A INNER JOIN (SELECT ASMAreaId,COUNT(DISTINCT SalesmanNodeId) TotSalesmenOnTelecalling FROM #DataFor2HourlyReport WHERE ISNULL(SalesmanNodeId,0)>0 AND SalesmanWorkingType=1 GROUP BY ASMAreaId) B ON A.ASMAreaId=B.ASMAreaId
	
	--SELECT * FROM #Summary
	PRINT 'GRv'
	IF @NodeType<=100
	BEGIN
		INSERT INTO #Summary(flgOverall,flgLvl,flgGrouping,ZoneId,Zone,RegionNodeId,Region,ASM,ASMArea,PlannedSalesmen,ActualSalesmen,TotSalesmenOnField,TotSalesmenOnTelecalling,PlannedCalls, TotCallsMade,ProdCalls,[PC %],LinesOrdered,[Avg LPC],OrderQtyInPcs,OrderVal)
		SELECT 0 AS flgOverall,1 AS flgLvl,'2,3' AS flgGrouping,ZoneId,Zone,RegionNodeId,Region,'Region-' + Region + ' Total','',SUM(PlannedSalesmen),SUM(ActualSalesmen),SUM(TotSalesmenOnField),SUM(TotSalesmenOnTelecalling),SUM(PlannedCalls),SUM(TotCallsMade),SUM(ProdCalls),CASE WHEN ISNULl(SUM(TotCallsMade),0)>0 THEN CAST(ROUND((SUM(ProdCalls)/CAST(SUM(TotCallsMade) AS FLOAT))*100,0) AS VARCHAR) + '%' END AS [PC %], SUM(LinesOrdered),CASE WHEN ISNULl(SUM(ProdCalls),0)>0 THEN ROUND((SUM(LinesOrdered)/CAST(SUM(ProdCalls) AS FLOAT)),2) END AS [Avg LPC],SUM(OrderQtyInPcs),SUM(OrderVal)
		FROM #Summary GROUP BY ZoneId,Zone,RegionNodeId,Region
	END
	
	IF @NodeType=0 AND EXISTS(SELECT 1 FROM #Summary WHERE flgLvl=0)
	BEGIN
		INSERT INTO #Summary(flgOverall,flgLvl,flgGrouping,ASM,ASMArea,PlannedSalesmen,ActualSalesmen,TotSalesmenOnField,TotSalesmenOnTelecalling,PlannedCalls,TotCallsMade, ProdCalls,[PC %],LinesOrdered,[Avg LPC],OrderQtyInPcs,OrderVal)
		SELECT 1,2,'2,3','Grand Total','',SUM(PlannedSalesmen),SUM(ActualSalesmen),SUM(TotSalesmenOnField),SUM(TotSalesmenOnTelecalling),SUM(PlannedCalls),SUM(TotCallsMade),SUM(ProdCalls),CASE WHEN ISNULl(SUM(TotCallsMade),0)>0 THEN CAST(ROUND((SUM(ProdCalls)/CAST(SUM(TotCallsMade) AS FLOAT))*100,0) AS VARCHAR) + '%' END AS [PC %],SUM(LinesOrdered),CASE WHEN ISNULl(SUM(ProdCalls),0)>0 THEN ROUND((SUM(LinesOrdered)/CAST(SUM(ProdCalls) AS FLOAT)),2) END AS [Avg LPC],SUM(OrderQtyInPcs),SUM(OrderVal)
		FROM #Summary WHERE flgLvl=0
	END
	--SELECT * FROM #Summary

	--,ASMArea [Head Quarter$1]
	SELECT flgLvl,flgGrouping,ASM [ASM Name$1],PlannedSalesmen [Planned Salesmen$2],ActualSalesmen [Actual Salesmen$2],TotSalesmenOnField [Total Salesmen on Field$2],TotSalesmenOnTelecalling [Total Salesmen on Telecalling$2],PlannedCalls [Planned Calls$2],TotCallsMade [Tot Calls Made$2],CASE WHEN ISNULl(PlannedCalls,0)>0 THEN CAST(ROUND((TotCallsMade/CAST(PlannedCalls AS FLOAT))*100,0) AS VARCHAR) + '%' END AS [Calls %$2],ProdCalls [Prod Calls$2],[PC %] [PC %$2],LinesOrdered [Lines Ordered$2],CAST([Avg LPC] AS DECIMAL(18,2)) [Avg LPC$2], ROUND(OrderQtyInPcs,0) [Tot Order Qty In Pcs$2],ROUND(OrderVal,0) [Tot Order Val$3],CASE WHEN ActualSalesmen>0 THEN ROUND((OrderVal/CAST(ActualSalesmen AS FLOAT)),0) END AS [Avg Sales / Salesman$3]
	FROM #Summary ORDER BY flgOverall,Region,flgLvl,ASM
	
	--+ ' (' + ASM + ')'
	SELECT 0 AS flgOverall,0 AS flgLvl,CAST('0' AS VARCHAR(10)) AS flgGrouping,CASE SalesmanWorkingType WHEN 2 THEN 'F' WHEN 1 THEN 'T' ELSE '' END AS strSalesmenWorkingType,* INTO #Detail
	FROM #DataFor2HourlyReport ORDER BY Region,ASMArea,CovArea,Route
	--SELECT * FROM #Detail

	IF @NodeType<=110 AND EXISTS(SELECT 1 FROM #DataFor2HourlyReport)
	BEGIN
		SELECT @StrSql='INSERT INTO #Detail(flgOverall,flgLvl,flgGrouping,flgOnRoute,strSalesmenWorkingType,SalesmanWorkingType,Region,ASMArea,PlannedCalls,ActCalls,ProdCalls,TotLinesOrdered, OrderQty,OrderVal'+ @StrCategory + ')
		SELECT 0,1,''3,9'',1,'''',0,Region,ASMArea + '' Total'',SUM(PlannedCalls),SUM(ActCalls),SUM(ProdCalls),SUM(TotLinesOrdered),SUM(OrderQty),SUM(OrderVal)' + @StrCategoryForGrouping + '
		FROM #DataFor2HourlyReport
		GROUP BY Region,ASMArea'
		PRINT @StrSql
		EXEC(@StrSql)
	END
	
	IF @NodeType<=100 AND EXISTS(SELECT 1 FROM #DataFor2HourlyReport)
	BEGIN
		SELECT @StrSql='INSERT INTO #Detail(flgOverall,flgLvl,flgGrouping,flgOnRoute,strSalesmenWorkingType,SalesmanWorkingType,ASMArea,PlannedCalls,ActCalls,ProdCalls,TotLinesOrdered, OrderQty,OrderVal'+ @StrCategory + ')
		SELECT 1,2,''3,9'',1,'''',0,''Grand Total'',SUM(PlannedCalls),SUM(ActCalls),SUM(ProdCalls),SUM(TotLinesOrdered),SUM(OrderQty),SUM(OrderVal)' + @StrCategoryForGrouping + '
		FROM #DataFor2HourlyReport'
		PRINT @StrSql
		EXEC(@StrSql)

		--INSERT INTO #Detail(flgOverall,flgLvl,flgGrouping,flgOnRoute,ASMArea,PlannedCalls,ActCalls,ProdCalls,TotLinesOrdered,TotSecSalesInL,SunnySFO1PP,SunnySFOBottles, SunnySFO5LJar,SunnySFO15LJar, TotSunnySFO,TotSunnySBO,PriyaSFO,PriyaSBO,PriyaMustard,PriyaVP,PriyaRBO,PriyaTotal,Allergo,TotCPSecInL,TotComPSecInL)
		--SELECT 1,2,'3,9',1,'Grand Total',SUM(PlannedCalls),SUM(ActCalls),SUM(ProdCalls),SUM(TotLinesOrdered),SUM(TotSecSalesInL),SUM(SunnySFO1PP),SUM(SunnySFOBottles), SUM(SunnySFO5LJar),SUM(SunnySFO15LJar),SUM(TotSunnySFO),SUM(TotSunnySBO),SUM(PriyaSFO),SUM(PriyaSBO),SUM(PriyaMustard),SUM(PriyaVP),SUM(PriyaRBO),SUM(PriyaTotal),SUM(Allergo), SUM(TotCPSecInL),SUM(TotComPSecInL)
		--FROM #DataFor2HourlyReport		
	END
	--SELECT * FROM #Detail

	SELECT @StrSql='SELECT flgLvl,flgGrouping,flgOnRoute,ASMArea AS [ASM Area^$1],CovArea AS [User Name^$1],Route AS [Route Name^$1],strSalesmenWorkingType AS [Salesmen on F/T^$2],FirstStoreVisit AS [First Store Visit^$2],LastStoreVisit AS [Last Store Visit^$2], WorkingHours [Working Hours (hh:mm)^$2],PlannedCalls AS [Planned Calls^$2],ActCalls AS [Calls Made^$2],CASE WHEN ISNULl(PlannedCalls,0)>0 THEN CAST(ROUND((ActCalls/CAST(PlannedCalls AS FLOAT))*100,0) AS VARCHAR) + ''%'' END AS [Calls %^$2],ProdCalls AS [Prod Calls^$2],CASE WHEN ISNULl(ActCalls,0)>0 THEN CAST(ROUND((ProdCalls/CAST(ActCalls AS FLOAT))*100,0) AS VARCHAR) + ''%'' END AS [PC %^$2], TotLinesOrdered [Lines Ordered^$2],CASE WHEN ISNULl(ProdCalls,0)>0 THEN CAST(ROUND((TotLinesOrdered/CAST(ProdCalls AS FLOAT)),2) AS DECIMAL(18,2)) END AS [Avg LPC^$2],ROUND(OrderQty,0) [Tot Order Qty In Pcs^$2],ROUND(OrderVal,0) [Tot Order Val^$3]'+ @StrCategory + '
	FROM #Detail ORDER BY flgOverall,Region,ASMArea,flgLvl,CovArea,Route'
	PRINT @StrSql
	EXEC(@StrSql)
END
