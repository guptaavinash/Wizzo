
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spRptCalculateDataFor2HourlyReport]'30-Nov-2021'
CREATE PROCEDURE [dbo].[spRptCalculateDataFor2HourlyReport] 
@RptDate DATE
AS
BEGIN
	CREATE TABLE #tmpRsltWithFullHierarchy(ZoneId INT,ZoneNodeType INT,Zone VARCHAR(200),RegionNodeId INT,RegjonNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,Salesman VARCHAR(200),ASMId INT,ASM VARCHAR(200),flgActive TINYINT DEFAULT 0 NOT NULL,FlgPlanned TINYINT DEFAULT 0 NOT NULL,PlannedCalls INT DEFAULT 0 NOT NULL,ActCalls INT DEFAULT 0 NOT NULL,flgWorkingType TINYINT DEFAULT 0 NOT NULL,FirstStoreVisit VARCHAR(20),LastStoreVisit VARCHAR(20),WorkingHours VARCHAR(20),ProdCalls INT DEFAULT 0 NOT NULL,TotLinesOrdered INT DEFAULT 0 NOT NULL,OrderQty FLOAT,OrderVal FLOAT,flgMarkedNotWorking TINYINT,StrCategory VARCHAR(5000),StrCategoryForGrouping VARCHAR(5000))

	INSERT INTO #tmpRsltWithFullHierarchy(ZoneId,ZoneNodeType,Zone,RegionNodeId,RegjonNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea, RouteId,RouteNodeType,Route)
	EXEC [spRptGetFullSalesHierarchyBasedonLogin] 0,0,0,''

	SELECT NodeID,NodeType,MIN(VldFrom) VldFrom,MAX(VldTo) VldTo INTO #tmp 
	FROM (SELECT NodeID,NodeType,VldFrom,VldTo FROM tblCompanySalesStructureHierarchy WHERE NodeType=130
	UNION
	SELECT NodeID,NodeType,VldFrom,VldTo FROM tblCompanySalesStructureHierarchy_Backup WHERE NodeType=130) AA GROUP BY NodeID,NodeType
	--SELECT * FROM #tmp

	UPDATE A SET A.flgActive=1
	FROM #tmpRsltWithFullHierarchy A INNER JOIN #tmp B ON A.CovAreaId=B.NodeID AND A.CovAreaNodeType=B.NodeType WHERE (@RptDate BETWEEN B.VldFrom AND B.VldTo)
	--SELECT * FROM #tmpRsltWithFullHierarchy WHERE flgActive=0
	--DELETE FROM #tmpRsltWithFullHierarchy WHERE flgActive=0
	--DELETE FROM #tmpRsltWithFullHierarchy WHERE CovAreaId IN(12,16)
					
	UPDATE A SET A.SalesmanNodeId=ISNULL(MP.NodeId,0),A.SalesmanNodeType=ISNULL(Mp.NodeType,0),A.Salesman=ISNULL(MP.Descr,'Vacant')--,A.CovArea= A.CovArea + ' (' + ISNULL(MP.Descr,'Vacant') + ')'
	FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType AND (@RptDate BETWEEN SP.FromDate AND SP.ToDate)
	LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID

	UPDATE A SET A.ASM= ISNULL(MP.Descr,'Vacant'),A.ASMId=ISNULL(MP.NodeId,0)
	FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping SP ON A.ASMAreaId=SP.NodeId AND A.ASMAreaNodeType=SP.NodeType AND (@RptDate BETWEEN SP.FromDate AND SP.ToDate)
	LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID
	
	UPDATE A SET A.SOArea= A.SOArea + ' (' + ISNULL(MP.Descr,'Vacant') + ')'
	FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping SP ON A.SOAreaId=SP.NodeId AND A.SOAreaNodeType=SP.NodeType AND (@RptDate BETWEEN SP.FromDate AND SP.ToDate)
	LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID	

	SELECT DISTINCT A.PersonNodeID INTO #SalesmanMarkedNotWorking
	FROM tblPersonAttendance A INNER JOIN PersonAttReason B ON A.PersonAttendanceID=B.PersonAttendanceID INNER JOIN tblMstrReasonsForNoVisit C ON B.ReasonID=C.ReasonId
	WHERE CAST(A.[Datetime] AS DATE)=@RptDate AND C.flgNoVisitOption=1
	--SELECT * FROM #SalesmanMarkedNotWorking

	UPDATE A SET A.flgMarkedNotWorking=1 FROM #tmpRsltWithFullHierarchy A INNER JOIN #SalesmanMarkedNotWorking B ON A.SalesmanNodeId=B.PersonNodeID
	/*
	SET DATEFirst 1  
	SELECT DISTINCT CovAreaId,CovAreaNodeType,ASMAreaId,ASMAreaNodeType,RC.RouteId,RC.NodeType AS RouteNodeType,@RptDate AS RptDate,dbo.[fnGetPlannedVisit](RC.RouteId,RC.NodeType,@RptDate) AS FlgPlanned INTO #tmpPlannedRoute
	FROM tblRouteCoverage RC INNER JOIN #tmpRsltWithFullHierarchy R ON RC.RouteId=R.RouteId AND RC.NodeType=R.RouteNodeType
	WHERE (@RptDate BETWEEN RC.FromDate AND RC.ToDate) AND (DATEPART(dw,@RptDate)=Weekday)
	--SELECT * FROM #tmpPlannedRoute ORDER BY FlgPlanned
	SET DATEFirst 7 
	DELETE FROM #tmpPlannedRoute WHERE FlgPlanned=0
	*/
	SELECT DISTINCT R.CovAreaId,R.CovAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.RouteId,R.RouteNodeType,@RptDate AS RptDate,1 AS FlgPlanned INTO #tmpPlannedRoute
	FROM tblRoutePlanningVisitDetail RC INNER JOIN #tmpRsltWithFullHierarchy R ON RC.RouteNodeId=R.RouteId AND RC.RouteNodetype=R.RouteNodeType
	WHERE RC.VisitDate=@RptDate
	--SELECT * FROM #tmpPlannedRoute

	UPDATE A SET A.FlgPlanned=B.FlgPlanned FROM #tmpRsltWithFullHierarchy A INNER JOIN #tmpPlannedRoute B ON A.RouteId=B.RouteID AND A.RouteNodeType=B.RouteNodeType

	UPDATE A SET A.PlannedCalls=AA.PlannedCalls FROM #tmpRsltWithFullHierarchy A INNER JOIN (SELECT A.RouteID,A.RouteNodeType,COUNT(DISTINCT B.StoreId) PlannedCalls
	FROM    #tmpPlannedRoute A INNER JOIN tblRouteCoverageStoreMapping B ON A.RouteID=B.RouteID AND A.RouteNodeType=B.RouteNodeType
	WHERE (@RptDate BETWEEN B.FromDate AND B.ToDate) GROUP BY A.RouteID,A.RouteNodeType) AA ON A.RouteId=AA.RouteID AND A.RouteNodeType=AA.RouteNodeType
	--SELECT * FROM #tmpRsltWithFullHierarchy WHERE PlannedCalls>0

	SELECT B.CovAreaId,B.CovAreaNodeType,A.RouteID,A.RouteType AS RouteNodeType,A.StoreID,ISNULL(A.EntryPersonNodeID,A.SalesPersonID) SalesPersonID,A.DeviceVisitStartTS,A.DeviceVisitEndTS,flgTelephonicCall,SourceId INTO #Visits 
	FROM tblVisitMaster A INNER JOIN #tmpRsltWithFullHierarchy B ON A.RouteID=B.RouteId AND A.RouteType=B.RouteNodeType WHERE VisitDate=@RptDate

	UPDATE #Visits SET SourceId=1 WHERE flgTelephonicCall=1 AND SourceId=2

	PRINT 'Grv'
	--SELECT A.* 
	UPDATE A SET A.SourceId=2
	FROM #Visits A INNER JOIN (SELECT DISTINCT CovAreaId,CovAreaNodeType FROM #Visits WHERE SourceId=2) B ON A.CovAreaId=B.CovAreaId AND A.CovAreaNodeType=B.CovAreaNodeType 
	WHERE A.SourceId=1
	--SELECT * FROM #Visits

	UPDATE A SET A.ActCalls=AA.ActCalls
	FROM #tmpRsltWithFullHierarchy A INNER JOIN (SELECT RouteID,RouteNodeType,COUNT(DISTINCT StoreId) ActCalls
	FROM    #Visits GROUP BY RouteID,RouteNodeType) AA ON A.RouteId=AA.RouteID AND A.RouteNodeType=AA.RouteNodeType
	--SELECT * FROM #tmpRsltWithFullHierarchy WHERE PlannedCalls>0 OR ActCalls>0

	Select CovAreaId,CovAreaNodeType,MIN(DeviceVisitStartTS) AS FirstStoreVisitTime, MAX(DeviceVisitEndTS) AS LastStoreVisitTime,CAST('' AS VARCHAR(20)) AS WorkingHours,MAX(SourceId) flgWorkingType INTO #FirstAndLastVisitTime
	FROM #Visits GROUP BY CovAreaId,CovAreaNodeType

	UPDATE #FirstAndLastVisitTime SET WorkingHours=CAST(DATEDIFF(MINUTE,FirstStoreVisitTime,LastStoreVisitTime)/60 AS VARCHAR) + ':' + RIGHT('0' + CAST(CAST(DATEDIFF(MINUTE,FirstStoreVisitTime,LastStoreVisitTime)%60 AS INT) AS VARCHAR),2)

	--SELECT *,FORMAT(CAST(FirstStoreVisitTime AS DATETIME),'HH:mm'),FORMAT(CAST(LastStoreVisitTime AS DATETIME),'HH:mm') FROM #FirstAndLastVisitTime ORDER BY LastStoreVisitTime

	UPDATE A SET A.FirstStoreVisit=FORMAT(CAST(B.FirstStoreVisitTime AS DATETIME),'HH:mm'),A.LastStoreVisit=FORMAT(CAST(B.LastStoreVisitTime AS DATETIME),'HH:mm'), A.flgWorkingType=B.flgWorkingType,A.WorkingHours=B.WorkingHours 
	FROM #tmpRsltWithFullHierarchy A INNER JOIN #FirstAndLastVisitTime B ON A.CovAreaId=B.CovAreaId AND A.CovAreaNodeType=B.CovAreaNodeType
	WHERE A.FlgPlanned=1 OR ActCalls>0

	SELECT * INTO #PrdHier FROM VwSFAProductHierarchy
	--SELECT * FROM VwProductHierarchy
	
	SELECT R.CovAreaId,R.CovAreaNodeType,R.RouteId,R.RouteNodeType,OM.StoreID,#PrdHier.CategoryNodeID,#PrdHier.CategoryNodeType,#PrdHier.Category,#PrdHier.SKUNodeId,#PrdHier.Grammage, OD.OrderQty,OD.NetLineOrderVal OrderVal INTO #TMPSales
	FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
	INNER JOIN #tmpRsltWithFullHierarchy R ON OM.RouteNodeID=R.RouteID AND OM.RouteNodeType=R.RouteNodeType
	INNER JOIN #PrdHier ON OD.ProductID = #PrdHier.SKUNodeId
	WHERE OM.OrderDate=@RptDate AND OM.OrderStatusId<>3
	--SELECT * FROM #TMPSales ORDER BY BrandID,ProductTypeNodeID,PrdPackingTypeId

	Select RouteId,RouteNodeType, ISNULL(SUM(OrderQty),0) AS OrderQty, SUM(OrderVal) AS TotOrderVal, COUNT(CAST(SKUNodeId AS VARCHAR)+'-'+ CAST(StoreID AS VARCHAR)) AS TotLinesOrdered,COUNT(DISTINCT StoreID) AS ProdCalls INTO #ForUpdate_Route 
	FROM #TMPSales GROUP BY RouteId,RouteNodeType

	UPDATE A SET A.ProdCalls=B.ProdCalls,A.TotLinesOrdered=B.TotLinesOrdered, A.OrderQty=B.OrderQty,A.OrderVal=B.TotOrderVal
	FROM #tmpRsltWithFullHierarchy A INNER JOIN #ForUpdate_Route B ON A.RouteId=B.RouteId AND A.RouteNodeType=B.RouteNodeType
	--SELECT * FROM #tmpRsltWithFullHierarchy WHERE PlannedCalls>0 OR ActCalls>0 Or ProdCalls>0

	DECLARE @Counter INT=1
	DECLARE @MaxCount INT
	DECLARE @StrCategory VARCHAR(5000)=''
	DECLARE @StrCategoryForGrouping VARCHAR(5000)=''
	DECLARE @CatNodeId INT
	DECLARE @Category VARCHAR(200)
	DECLARE @strSQL VARCHAR(8000)

	CREATE TABLE #tmpCatList(RowId INT IDENTITY(1,1),CategoryNodeId INT,Category VARCHAR(200))
	INSERT INTO #tmpCatList(CategoryNodeId,Category)
	SELECT DISTINCT CategoryNodeID,Category FROM #PrdHier
	--SELECT * FROM #tmpCatList

	SELECT @MaxCount=Max(RowId) FROM #tmpCatList
	WHILE @Counter<=@MaxCount
	BEGIN
		SELECT @CatNodeId=CategoryNodeId,@Category=Category FROM #tmpCatList WHERE RowId=@Counter

		SELECT @strSQL='ALTER TABLE #tmpRsltWithFullHierarchy ADD [Tot Order Val^' + @Category + '$3|5F8B41~80B45C] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @strSQL='UPDATE A SET A.[Tot Order Val^' + @Category + '$3|5F8B41~80B45C]=ROUND(B.OrderVal,0) FROM #tmpRsltWithFullHierarchy A INNER JOIN (SELECT RouteId,RouteNodeType,SUM(OrderVal) OrderVal FROM #TMPSales WHERE CategoryNodeID=' + CAST(@CatNodeId AS VARCHAR) + ' GROUP BY RouteId,RouteNodeType) B ON A.RouteId=B.RouteId AND A.RouteNodeType=B.RouteNodeType'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @StrCategory= @StrCategory + ',[Tot Order Val^' + @Category + '$3|5F8B41~80B45C]'
		SELECT @StrCategoryForGrouping=@StrCategoryForGrouping +  ',SUM([Tot Order Val^' + @Category + '$3|5F8B41~80B45C])'
		SELECT @Counter+=1
	END
	--SELECT @StrCategory
	--SELECT * FROM #tmpRsltWithFullHierarchy WHERE PlannedCalls>0 OR ActCalls>0 Or ProdCalls>0
	
	DELETE A FROM #tmpRsltWithFullHierarchy A INNER JOIN (SELECT CovAreaId,CovAreaNodeType FROM #tmpRsltWithFullHierarchy GROUP BY CovAreaId,CovAreaNodeType HAVING MAX(flgActive)=0 AND SUM(PlannedCalls)=0 AND SUM(ActCalls)=0) B ON A.CovAreaId=B.CovAreaId AND A.CovAreaNodeType=B.CovAreaNodeType

	PRINT 'Grv'
	UPDATE A SET A.PlannedCalls=0 FROM #tmpRsltWithFullHierarchy A INNER JOIN (SELECT CovAreaId,CovAreaNodeType FROM #tmpRsltWithFullHierarchy WHERE flgMarkedNotWorking=1 GROUP BY CovAreaId,CovAreaNodeType HAVING SUM(ActCalls)=0) B ON A.CovAreaId=B.CovAreaId AND A.CovAreaNodeType=B.CovAreaNodeType
	
	UPDATE #tmpRsltWithFullHierarchy Set StrCategory=@StrCategory,StrCategoryForGrouping=@StrCategoryForGrouping
	--SELECT * FROM #tmpRsltWithFullHierarchy where PlannedCalls=0 AND ActCalls=0 AND ProdCalls=0 ORDER BY zone
	--SELECT * FROM #tmpRsltWithFullHierarchy ORDER BY CovAreaId

	IF object_id('tmpRptDataFor2HourlyReport') is not null
	BEGIN
		DROP TABLE tmpRptDataFor2HourlyReport
	END

	SELECT @strSQL='SELECT ZoneId,ZoneNodeType,Zone,RegionNodeId,RegjonNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,ASMId,ASM,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea,SalesmanNodeId,Salesman,RouteId, RouteNodeType,Route,FlgPlanned AS flgOnRoute,flgWorkingType AS SalesmanWorkingType,FirstStoreVisit AS FirstStoreVisit,LastStoreVisit AS LastStoreVisit,WorkingHours,PlannedCalls, ActCalls,ProdCalls,TotLinesOrdered,OrderQty,OrderVal,' + CAST(@RptDate  AS VARCHAR) + ' AS RptDate' + @StrCategory + ',StrCategory,StrCategoryForGrouping INTO tmpRptDataFor2HourlyReport
	FROM #tmpRsltWithFullHierarchy WHERe PlannedCalls>0 OR ActCalls>0 OR ProdCalls>0'
	PRINT @strSQL
	EXEC(@strSQL)
END
