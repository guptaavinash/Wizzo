
--[spRptGetBasicDayTracker_PreOrder_FullMonth_02Mar2022]'28-Feb-2022',4492,''
CREATE PROC [dbo].[spRptGetBasicDayTracker_PreOrder_FullMonth_02Mar2022]
@strDate DATE,
@LoginId INT,
@strSalesHierarchy VARCHAR(5000)=''
AS	

	DECLARE @StartDate DATE =DATEADD(month,MONTH(@StrDate)-1,DATEADD(year,YEAR(@StrDate)-1900,0))
	--DECLARE @EndDate DATE =EOMONTH(@StartDate) 
	DECLARE @EndDate DATE =@strDate

	SELECT  TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1) Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @StartDate) INTO #tblDates
	FROM    sys.all_objects a CROSS JOIN sys.all_objects b

	--SELECT * FROM #tblDates

	CREATE TABLE #tmpRsltWithFullHierarchy(ZoneId INT,ZoneNodeType INT,Zone VARCHAR(200),RegionNodeId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,EmpCode VARCHAR(20),Salesman VARCHAR(200),[User Status] VARCHAR(20),[User Contact] VARCHAR(20),flgActive TINYINT DEFAULT 0 NOT NULL)

	CREATE TABLE #tmpRsltWithFullHierarchyDateWise(ZoneId INT,ZoneNodeType INT,Zone VARCHAR(200),RegionNodeId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,EmpCode VARCHAR(20),Salesman VARCHAR(200),[User Status] VARCHAR(20),[User Contact] VARCHAR(20),flgActive TINYINT DEFAULT 0 NOT NULL,RptDate Date)


	CREATE TABLE #Final(flgHide TINYINT DEFAULT 0 NOT NULL,Lvl TINYINT DEFAULT 0 NOT NULL,flg TINYINT DEFAULT 0 NOT NULL,flgGrouping VARCHAR(10) DEFAULT 0 NOT NULL,RptDate Date,RSMAreaId INT,RSMAreaNodeType INT,[RSM Area] VARCHAR(200),RSMName VARCHAR(200),StateHeadAreaNodeID INT,StateHeadAreaNodeType INT,StateHeadArea VARCHAR(200),
	ASMAreaId INT,ASMAreaNodeType INT,[ASM Area] VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,[SO Area] VARCHAR(200),CoverageAreaId INT,CoverageAreaNodeType INT,CoverageArea VARCHAR(200),AssignRoute VARCHAR(200),VisitRoute VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,EmpCode VARCHAR(20),Salesman VARCHAR(200),[User Status] VARCHAR(20),[User Contact] VARCHAR(20),DOJ VARCHAR(20),[Day Start Time] VARCHAR(20),Activity VARCHAR(500),[Day End Time] VARCHAR(20),[Start Time] VARCHAR(20) DEFAULT '', [End Time] VARCHAR(20) DEFAULT '',[Working Hours] VARCHAR(20) DEFAULT '',WorkingHours_FirstVisitMinusDayEnd VARCHAR(20) DEFAULT '',[Time Spent in Store] VARCHAR(10) DEFAULT '',[Stores Added^Total] INT DEFAULT 0, [Stores Added^Today] INT DEFAULT 0,[Calls^DaysInMonth] INT DEFAULT 0,[Calls^Target] INT DEFAULT 0, [Calls^Actual] INT DEFAULT 0, [Calls^Avg Retailing Time(Sec)] INT,[Calls^Avg Retailing Time(hour:min:Sec)] VARCHAR(10),[Calls^Retailing Grade] VARCHAR(50),[Calls^Productive] INT DEFAULT 0,[Calls^Productivity %] VARCHAR(10) DEFAULT '' NOT NULL,[Total Sales^Dstr] INT,[Total Sales^Lines Ordered] INT,[Total Sales^Qty In KG] FLOAT,[Total Sales^Qty In Case] FLOAT,[Total Sales^Value] FLOAT,[Lines/Bill] FLOAT,flgMarkedNotWorking TINYINT,ReasonID INT,ReasonDescr VARCHAR(20))
		

		-- flgAttendence=1
	DECLARE @StrColumn VARCHAR(MAX)='', @strColumnSEArea VARCHAR(MAX)=''
		
	INSERT INTO #tmpRsltWithFullHierarchy(ZoneId,ZoneNodeType,Zone,RegionNodeId,RegionNodeType,Region,
	ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea, RouteId,RouteNodeType,Route)
	EXEC [spRptGetFullSalesHierarchyBasedonLogin] @LoginId,0,0,@strSalesHierarchy

	INSERT INTO #tmpRsltWithFullHierarchyDateWise(ZoneId,ZoneNodeType,Zone,RegionNodeId,RegionNodeType,Region,
	ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea, RouteId,RouteNodeType,Route,RptDate)
	SELECT ZoneId,ZoneNodeType,Zone,RegionNodeId,RegionNodeType,Region,
	ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea, RouteId,RouteNodeType,Route,D.Date FROM #tmpRsltWithFullHierarchy CROSS JOIN #tblDates D

	--SELECT * FROM #tmpRsltWithFullHierarchy WHERE SOAreaId=7

	SELECT NodeID,NodeType,MIN(VldFrom) VldFrom,MAX(VldTo) VldTo INTO #tmp 
	FROM (SELECT NodeID,NodeType,VldFrom,VldTo FROM tblCompanySalesStructureHierarchy(nolock) WHERE NodeType=130
	UNION
	SELECT NodeID,NodeType,VldFrom,VldTo FROM tblCompanySalesStructureHierarchy_Backup(nolock) WHERE NodeType=130) AA GROUP BY NodeID,NodeType
	--SELECT * FROM #tmp

	UPDATE A SET A.flgActive=1
	FROM #tmpRsltWithFullHierarchyDateWise A INNER JOIN #tmp B ON A.CovAreaId=B.NodeID AND A.CovAreaNodeType=B.NodeType AND A.RptDate BETWEEN B.VldFrom AND B.VldTo --WHERE (@strDate BETWEEN B.VldFrom AND B.VldTo)
	--DELETE FROM #tmpRsltWithFullHierarchy WHERE flgActive=0
	--DELETE FROM #tmpRsltWithFullHierarchy WHERE CovAreaId IN(12,16)
	--SELECT * FROM #tmpRsltWithFullHierarchy ORDER BY CovAreaId

	--SELECT 1
	--SELECT * FROM #tmpRsltWithFullHierarchy WHERE SOAreaId=7

	DELETE A FROM #tmpRsltWithFullHierarchyDateWise A INNER JOIN tblSalesPersonMapping(nolock) SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType AND (A.RptDate BETWEEN SP.FromDate AND SP.ToDate)
	INNER JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID WHERE MP.flgSFAUser<>1
	
	UPDATE A SET A.EmpCode=MP.Code,A.SalesmanNodeId=MP.NodeId,A.SalesmanNodeType=Mp.NodeType,A.Salesman=ISNULL(MP.Descr,'Vacant'),A.[User Contact]=MP.PersonPhone,A.[User Status]=CASE WHEN MP.flgActive=1 THEN 'Yes' ELSE 'No' END
	FROM #tmpRsltWithFullHierarchyDateWise A LEFT JOIN tblSalesPersonMapping(nolock) SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType AND (A.RptDate BETWEEN SP.FromDate AND SP.ToDate)
	LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID

	--SELECT * FROM #tmpRsltWithFullHierarchyDateWise WHERE SOAreaId=88



	--UPDATE A SET A.ASMArea= A.ASMArea + ' (' + ISNULL(MP.Descr,'Vacant') + ')'
	--FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping SP ON A.ASMAreaId=SP.NodeId AND A.ASMAreaNodeType=SP.NodeType AND (@strDate BETWEEN SP.FromDate AND SP.ToDate)
	--LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID
	
	--UPDATE A SET A.SOArea= A.SOArea + ' (' + ISNULL(MP.Descr,'Vacant') + ')'
	--FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping SP ON A.SOAreaId=SP.NodeId AND A.SOAreaNodeType=SP.NodeType AND (@strDate BETWEEN SP.FromDate AND SP.ToDate)
	--LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID
		
	--SELECT * FROM #tmpRsltWithFullHierarchy ORDER BY RouteId
		
	SELECT DISTINCT R.CovAreaId,R.CovAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.RouteId,R.RouteNodetype,RCM.StoreId,CASE WHEN SM.CreatedDate=RptDate THEN 1 ELSE 0 END AddedToday,ISNULL(SM.CreatedDate,'01-Nov-2021') CreatedDate  INTO #StoreList
	FROM #tmpRsltWithFullHierarchyDateWise R INNER JOIN tblRouteCoverageStoreMapping(nolock) RCM ON R.RouteId=RCM.RouteId AND R.RouteNodetype=RCM.RouteNodetype AND (R.RptDate BETWEEN RCM.FromDate AND RCM.ToDate)
	INNER JOIN tblStoreMaster(nolock) SM ON RCM.StoreId=SM.StoreId
	 
	

	----UPDATE A SET A.AddedToday=1
	----FROM #StoreList A INNER JOIN tblStoreMaster(nolock) B ON A.StoreId=B.StoreId
	----WHERE CAST(B.CreatedDate AS DATE)=CAST(GETDATE() AS DATE)


	--SELECT * FROM #StoreList ORDER BY AddedToday desc
	
	SELECT A.CovAreaId,A.CovAreaNodeType,A.ASMAreaId,A.ASMAreaNodeType,A.RouteId,A.RouteNodetype,A.StoreId,B.BatteryStatus,B.CreateDate,B.VisitStartTS,B.VisitEndTS INTO #WorkingForStoreAddition
	FROM #StoreList A INNER JOIN 	tblPdaSyncStoreMappingMstr(nolock) B ON A.StoreId=B.OrgStoreId WHERE A.AddedToday=1


	
	--SELECT * FROM #WorkingForStoreAddition

	--Target Calls
	/*
	SET DATEFirst 1  
	SELECT DISTINCT CovAreaId,CovAreaNodeType,ASMAreaId,ASMAreaNodeType,RC.RouteId,RC.NodeType AS RouteNodeType,@strDate AS RptDate,dbo.[fnGetPlannedVisit](RC.RouteId,RC.NodeType,@strDate) AS FlgPlanned INTO #tmpRoute
	FROM tblRouteCoverage RC INNER JOIN #tmpRsltWithFullHierarchy R ON RC.RouteId=R.RouteId AND RC.NodeType=R.RouteNodeType
	WHERE (@strDate BETWEEN RC.FromDate AND RC.ToDate) AND (DATEPART(dw,@strDate)=Weekday)
	--SELECT * FROM #tmpRoute ORDER BY FlgPlanned
	SET DATEFirst 7 
	DELETE FROM #tmpRoute WHERE FlgPlanned=0
	*/


	


	SELECT DISTINCT R.CovAreaId,R.CovAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.RouteId,R.RouteNodeType,R.Route,RC.VisitDate AS RptDate,1 AS FlgPlanned INTO #tmpRoute
	FROM tblRoutePlanningVisitDetail(nolock) RC INNER JOIN #tmpRsltWithFullHierarchyDateWise R ON RC.RouteNodeId=R.RouteId AND RC.RouteNodetype=R.RouteNodeType AND RC.VisitDate=R.RptDate
	WHERE MONTH(RC.VisitDate)=MONTH(@strDate) AND YEAR(RC.VisitDAte)=YEAR(@strDate)

	--SELECT * FROM #tmpRoute WHERE CovAreaId=7 AND RptDate='23-Feb-2022' ORDER BY RouteNodeType,RouteId
	
	SELECT DISTINCT RptDate,AA.StoreID AS StoreID, #tmpRoute.RouteID, #tmpRoute.RouteNodeType,#tmpRoute.Route, 1 AS OnRoute,CovAreaId,CovAreaNodeType,ASMAreaId,ASMAreaNodeType INTO [#Target]
	FROM    #tmpRoute
	INNER JOIN (SELECT RouteID,RouteNodeType,StoreID FROM tblRouteCoverageStoreMapping (nolock)
	WHERE (CONVERT(VARCHAR,tblRouteCoverageStoreMapping.FromDate, 112) <= CONVERT(VARCHAR, GETDATE(), 112)) AND (CONVERT(VARCHAR, ISNULL(tblRouteCoverageStoreMapping.ToDate, GETDATE()), 112) >= CONVERT(VARCHAR, GETDATE(), 112))) AA 
	ON #tmpRoute.RouteID=AA.RouteID AND #tmpRoute.RouteNodeType=AA.RouteNodeType 

	--SELECT * FROM [#Target] WHERE CovAreaId=7 AND RptDate='23-Feb-2022' ORDER BY RouteNodeType,RouteId
	
	--Actual Calls
	SELECT R.CovAreaId,R.CovAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,V.VisitId,V.VisitDate,V.RouteID,V.RouteType AS RouteNodeType,V.StoreID,V.BatteryLeftStatus,ISNULL(VD.VisitStartDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitStartTS AS DATETIME)) DeviceVisitStartTS,ISNULL(VD.VisitEndDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitEndTS AS DATETIME)) DeviceVisitEndTS,DATEDIFF(ss,ISNULL(VD.VisitStartDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitStartTS AS DATETIME)) ,ISNULL(VD.VisitEndDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitEndTS AS DATETIME))) TimeSpentInStore,ISNULL(V.EntryPersonNodeId,V.SalesPersonId) SalesmanId,V.flgTelephonicCall,DeviceVisitStartTS STartTS,DeviceVisitEndTS EndTS INTO [#VIsitedStores]
	FROM tblVisitMaster (nolock)V 
	LEFT OUTER JOIN tblVisitDet VD ON VD.VisitID=V.VisitID
	INNER JOIN #tmpRsltWithFullHierarchyDateWise R ON V.RouteID=R.RouteID AND V.RouteType=R.RouteNodeType AND V.VisitDate=R.RptDate
	WHERE MONTH(V.VisitDate) = MONTH(@strDate)   AND YEAR(V.VisitDate) = YEAR(@strDate) 
	ORDER BY V.StoreID

	--SELECT *	FROM [#VIsitedStores] WHERE CovAreaId=12 AND VisitDate='23-Feb-2022' ORDER BY CovAreaId,DeviceVisitStartTS


	DELETE A FROM #tmpRsltWithFullHierarchyDateWise A LEFT OUTER JOIN (SELECT DISTINCT CovAreaId,CovAreaNodeType,RptDate FROM #Target UNION SELECT DISTINCT CovAreaId,CovAreaNodeType,VisitDate FROM [#VIsitedStores]) B ON A.CovAreaId=B.CovAreaId AND A.CovAreaNodeType=B.CovAreaNodeType AND A.RptDate=B.RptDate
	WHERE B.CovAreaId IS NULL AND A.flgActive=0
	
	SELECT VisitDate,CovAreaId,CovAreaNodeType,SUM(TimeSpentInStore) TimeSpentInStore,CAST('' AS VARCHAR(10)) AS TimeSpentInStore_HHMM,CASE WHEN SUM(TimeSpentInStore)>=18000 THEN 1 ELSE 0 END flgWorking INTO #TimeSpentInStore 
	FROM [#VIsitedStores] GROUP BY VisitDate,CovAreaId,CovAreaNodeType
	
	UPDATE #TimeSpentInStore SET TimeSpentInStore_HHMM=RIGHT('00' + CAST(TimeSpentInStore / 3600 AS VARCHAR),2) + ':' + RIGHT('00' + CAST((TimeSpentInStore / 60) % 60 AS VARCHAR),2) + ':' + RIGHT('00' + CAST(TimeSpentInStore % 60 AS VARCHAR),2)
	--SELECT * FROM #TimeSpentInStore
	
	SELECT VisitDate,CovAreaId,CovAreaNodeType,ASMAreaId,ASMAreaNodeType,RouteID,RouteNodeType,StoreID,BatteryLeftStatus,DeviceVisitStartTS,DeviceVisitEndTS,1 AS WorkingType INTO #Wroking 
	FROM [#VIsitedStores]
	--SELECT * FROM #Wroking WHERE CovAreaId=

	INSERT INTO #Wroking(VisitDate,CovAreaId,CovAreaNodeType,ASMAreaId,ASMAreaNodeType,RouteID,RouteNodeType,StoreID,BatteryLeftStatus,DeviceVisitStartTS,DeviceVisitEndTS,WorkingType)
	SELECT A.CreateDate,A.CovAreaId,A.CovAreaNodeType,A.ASMAreaId,A.ASMAreaNodeType,A.RouteID,A.RouteNodeType,A.StoreID,A.BatteryStatus,A.VisitStartTS,A.VisitEndTS ,2
	FROM #WorkingForStoreAddition A LEFT OUTER JOIN #Wroking B ON A.StoreId=B.StoreId AND A.CreateDate=B.VisitDate WHERE B.StoreId IS NULL
	--SELECT * FROM #Wroking
	
	--Order List
	SELECT * INTO #PrdHier FROM VwSFAProductHierarchy

	SELECT R.CovAreaId,R.CovAreaNodeType,R.SOAreaId,R.SOAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.ZoneId,R.ZoneNodeType,R.RegionNodeId,R.RegionNodeType,OM.StoreID,#PrdHier.CategoryNodeID CategoryId,#PrdHier.Category,#PrdHier.SKUNodeId,#PrdHier.SKUNodeType,#PrdHier.SKU,#PrdHier.SKUCode,OM.OrderDate,SUM(Od.OrderQty) OrderQty,SUM(CAST(ROUND((OD.OrderQty * UOMValue)/1000,0) AS FLOAT)) OrderQtyInKG,SUM(CAST(OD.NetLineOrderVal AS FLOAT)) OrderVal,ROUND(SUM(CAST(Od.OrderQty AS FLOAT)/RelConversionUnits),2) OrderInCase INTO [#TMPSales]
	FROM tblOrderMaster(nolock) OM INNER JOIN tblOrderDetail(nolock) OD ON OM.OrderId=OD.OrderId
	INNER JOIN #tmpRsltWithFullHierarchyDateWise R ON OM.RouteNodeID=R.RouteID AND OM.RouteNodeType=R.RouteNodeType AND OM.OrderDate=R.RptDate
	INNER JOIN #PrdHier ON OD.ProductID = #PrdHier.SKUNodeId
	LEFT OUTER JOIN tblPrdMstrPackingUnits_ConversionUnits(nolock) C ON C.SKUId=OD.ProductID AND C.BaseUOMID=3
	WHERE MONTH(OM.OrderDate)=MONTH(@strDate) AND YEAR(OM.OrderDate)=YEAR(@StrDate) AND OM.OrderStatusId<>3
	GROUP BY R.CovAreaId,R.CovAreaNodeType,R.SOAreaId,R.SOAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.ZoneId,R.ZoneNodeType,R.RegionNodeId,R.RegionNodeType,OM.StoreID, #PrdHier.CategoryNodeID,#PrdHier.Category,#PrdHier.SKUNodeId, #PrdHier.SKUNodeType, #PrdHier.SKU,#PrdHier.SKUCode,OM.OrderDate
	--SELECT * FROM [#TMPSales] ORDER BY SKUNodeId,StoreId--,ProductNodeID
	/*
	Select RegionNodeId,RegionNodeType, ISNULL(SUM(OrderQty),0) AS OrderQty,SUM(OrderQtyInKG) OrderQtyInKG, SUM(OrderVal) AS TotOrderVal, COUNT(CAST(SKUNodeId AS VARCHAR)+'-'+ CAST(StoreID AS VARCHAR)) AS TotLinesOrdered,COUNT(DISTINCT StoreID) AS Prod_Call INTO #ForUpdate_RSMArea  
	FROM #TMPSales GROUP BY RegionNodeId,RegionNodeType
	--SELECT * FROM #ForUpdate_RSMArea

	Select ASMAreaId,ASMAreaNodeType, ISNULL(SUM(OrderQty),0) AS OrderQty,SUM(OrderQtyInKG) OrderQtyInKG, SUM(OrderVal) AS TotOrderVal, COUNT(CAST(SKUNodeId AS VARCHAR)+'-'+ CAST(StoreID AS VARCHAR)) AS TotLinesOrdered,COUNT(DISTINCT StoreID) AS Prod_Call INTO #ForUpdate_ASMArea  
	FROM #TMPSales GROUP BY ASMAreaId,ASMAreaNodeType
	--SELECT * FROM #ForUpdate_ASMArea

	Select SOAreaId,SOAreaNodeType, ISNULL(SUM(OrderQty),0) AS OrderQty,SUM(OrderQtyInKG) OrderQtyInKG, SUM(OrderVal) AS TotOrderVal, COUNT(CAST(SKUNodeId AS VARCHAR)+'-'+ CAST(StoreID AS VARCHAR)) AS TotLinesOrdered,COUNT(DISTINCT StoreID) AS Prod_Call INTO #ForUpdate_SOArea  
	FROM #TMPSales GROUP BY SOAreaId,SOAreaNodeType
	--SELECT * FROM #ForUpdate_SOArea

	Select ISNULL(SUM(OrderQty),0) AS OrderQty,SUM(OrderQtyInKG) OrderQtyInKG, SUM(OrderVal) AS TotOrderVal, COUNT(CAST(SKUNodeId AS VARCHAR)+'-'+ CAST(StoreID AS VARCHAR)) AS TotLinesOrdered,COUNT(DISTINCT StoreID) AS Prod_Call INTO #ForUpdate_Total 
	FROM #TMPSales
	--SELECT * FROM #ForUpdate_Total
	*/

	Select CovAreaId,CovAreaNodeType,OrderDate, ISNULL(SUM(OrderQty),0) AS OrderQty,SUM(OrderQtyInKG) OrderQtyInKG,SUM(OrderInCase) OrderInCase,SUM(OrderVal) AS TotOrderVal, COUNT(CAST(SKUNodeId AS VARCHAR)+'-'+ CAST(StoreID AS VARCHAR)) AS TotLinesOrdered,COUNT(DISTINCT StoreID) AS Prod_Call INTO #ForUpdate_CovArea  
	FROM #TMPSales GROUP BY CovAreaId,CovAreaNodeType,OrderDate
	--SELECT * FROM #ForUpdate_CovArea
	

	select CAST(A.Datetime AS DATE) AttenDate,A.PersonNodeId,A.PersonNodeType,A.[Datetime] AS DayStartTime,B.ReasonID,B.ReasonDescr INTO #DayStartDetail
	from tblPersonAttendance A INNER JOIN PersonAttReason B oN A.PersonAttendanceID=B.PersonAttendanceID 
	INNER JOIN (SELECT CAST([Datetime] AS DATE) AttenDate,AA.PersonNodeId,MAX(AA.[Datetime]) [Datetime] FROM tblPersonAttendance(nolock) AA INNER JOIN PersonAttReason(nolock) BB oN AA.PersonAttendanceID=BB.PersonAttendanceID 
	WHERE BB.ReasonID<>0 GROUP BY CAST([Datetime] AS DATE),AA.PersonNodeId) C ON A.PersonNodeId=C.PersonNodeId AND A.[Datetime]=C.[Datetime] AND CAST(A.Datetime AS DATE)=C.AttenDate AND  MONTH(A.Datetime)=MONTH(@StrDate) AND YEAR(A.Datetime)=YEAR(@StrDate)
	--INNER JOIN tblMstrReasonsForNoVisit M ON B.ReasonID=M.ReasonID
	ORDER BY A.PersonNodeId,B.ReasonID

	

	--SELECT * FROM #DayStartDetail WHERE PersonNodeID=138 AND CAST(AttenDate AS DATE)='02-Jan-2022'

	SELECT DISTINCT P.AttenDate,P.PersonNodeId,P.DayStartTime,STUFF((SELECT DISTINCT ','  + p1.ReasonDescr 
	FROM #DayStartDetail p1  
	WHERE P.PersonNodeId = p1.PersonNodeId AND P.AttenDate=P1.AttenDate
     FOR XML PATH(''), TYPE  
     ).value('.', 'NVARCHAR(MAX)')  
    ,1,1,'') Activity INTO #DayStartActivity
	FROM #DayStartDetail P GROUP BY P.AttenDate,P.PersonNodeId,P.DayStartTime

	--SELECT *,FORMAT(DayStartTime,'HH:mm') FROM #DayStartActivity WHERE PersonNodeID=138 AND AttenDate='02-Jan-2022'

	Select VisitDate,CovAreaId,CovAreaNodeType, 0 AS MIN_Battery, 0 AS MAX_Battery,CAST(NULL AS TIME) DayStartTime,CAST(NULL AS DATETIME) DayEndTime, MIN(DeviceVisitStartTS) AS Start_Time, MAX(DeviceVisitEndTS) AS End_Time,CAST('' AS VARCHAR(20)) AS WorkingHours,CAST('' AS VARCHAR(20)) AS WorkingHours_FirstVisitMinusDayEnd,MIN(WorkingType) WorkingType,CAST(NULL AS DATETIME) Start_TimeWithDate,CAST(NULL AS DATETIME) End_TimeWithDate INTO #BatteryStatus FROM #Wroking
	GROUP BY VisitDate,CovAreaId,CovAreaNodeType

	UPDATE #BatteryStatus SET Start_TimeWithDate=CAST((CAST(@strDate AS VARCHAR) + ' ' + CAST(FORMAT(cast(Start_Time as datetime),'hh:mm:ss') AS VARCHAR)) AS DATETIME)



	UPDATE #BatteryStatus SET End_TimeWithDate=CAST(CAST(@strDate AS VARCHAR) + ' ' + CAST(CONVERT(VARCHAR(8),End_Time,108) AS VARCHAR) AS DATETIME)
	--UPDATE #BatteryStatus SET End_TimeWithDate=CONVERT(VARCHAR(8),End_TimeWithDate,108)

	UPDATE A SET A.DayStartTime=CAST(C.DayStartTime AS TIME)
	FROM #BatteryStatus A INNER JOIN #tmpRsltWithFullHierarchyDateWise B ON A.CovAreaId=B.CovAreaId AND A.CovAreaNodeType=B.CovAreaNodeType AND A.VisitDate=B.RptDate
	INNER JOIN #DayStartActivity C ON B.SalesmanNodeId=C.PersonNodeId AND C.AttenDate=A.VisitDate AND C.AttenDate=B.RptDate

	--SELECT * FROM #BatteryStatus WHERE CovAreaId=153 AND VisitDate='21-Feb-2022'

	UPDATE #BatteryStatus SET DayStartTime=Start_Time WHERE DayStartTime IS NULL

	SELECT A.ForDate,B.SalesmanNodeId,MAX(A.EndTime) DayEndTime INTO #DayEndDetails
	FROM tblDayEndDetails A INNER JOIN #tmpRsltWithFullHierarchyDateWise B ON A.PersonId=B.SalesmanNodeId AND A.ForDate=B.RptDate
	WHERE CAST(ForDate AS DATE)=CAST(A.EndTime AS DATE)
	GROUP BY A.ForDate,B.SalesmanNodeId
	--SELECT * FROM #DayEndDetails ORDER BY SalesmanNodeId

	UPDATE A SET A.DayEndTime=C.DayEndTime --CAST(C.DayEndTime AS TIME)
	FROM #BatteryStatus A INNER JOIN #tmpRsltWithFullHierarchyDateWise B ON A.CovAreaId=B.CovAreaId AND A.CovAreaNodeType=B.CovAreaNodeType AND B.RptDate=A.VisitDate
	INNER JOIN #DayEndDetails C ON B.SalesmanNodeId=C.SalesmanNodeId AND C.ForDate=A.VisitDate

	--UPDATE #BatteryStatus SET DayEndTime=End_Time WHERE DayEndTime IS NULL

	--UPDATE #BatteryStatus SET WorkingHours=CAST(DATEDIFF(MINUTE,Start_Time,End_Time)/60 AS VARCHAR) + ':' + RIGHT('0' + CAST(CAST(DATEDIFF(MINUTE,Start_Time,End_Time)%60 AS INT) AS VARCHAR),2)
	UPDATE #BatteryStatus SET WorkingHours=CAST(DATEDIFF(MINUTE,Start_Time,End_Time)/60 AS VARCHAR) + ':' + RIGHT('0' + CAST(CAST(DATEDIFF(MINUTE,Start_Time,End_Time)%60 AS INT) AS VARCHAR),2)
	
	UPDATE #BatteryStatus SET WorkingHours_FirstVisitMinusDayEnd=CAST(DATEDIFF(MINUTE,Start_TimeWithDate,DayEndTime)/60 AS VARCHAR) + ':' + RIGHT('0' + CAST(CAST(DATEDIFF(MINUTE,Start_TimeWithDate,DayEndTime)%60 AS INT) AS VARCHAR),2)

	--SELECT * FROM #BatteryStatus
	--SELECT * FROM #BatteryStatus WHERE CovAreaId=153 AND VisitDate='21-Feb-2022'

	UPDATE #BatteryStatus SET MIN_Battery = BatteryLeftStatus FROM #BatteryStatus INNER JOIN #Wroking ON #Wroking.DeviceVisitStartTS = Start_Time AND #Wroking.VisitDate=#BatteryStatus.VisitDate
	UPDATE #BatteryStatus SET MAX_Battery = BatteryLeftStatus FROM #BatteryStatus INNER JOIN #Wroking ON #Wroking.DeviceVisitEndTS = End_Time AND #Wroking.VisitDate=#BatteryStatus.VisitDate
	--SELECT *,CAST(@strDate AS VARCHAR),CAST(Start_Time AS VARCHAR),FORMAT(cast(Start_Time as datetime),'HH:mm:ss'),CAST((CAST(@strDate AS VARCHAR) + ' ' + CAST(FORMAT(cast(Start_Time as datetime),'hh:mm:ss') AS VARCHAR)) AS DATETIME) FROM #BatteryStatus

	----Select CovAreaId,CovAreaNodeType, 0 AS MIN_Battery, 0 AS MAX_Battery, MIN(DeviceVisitStartTS) AS Start_Time, MAX(DeviceVisitEndTS) AS End_Time,CAST('' AS VARCHAR(20)) AS WorkingHours INTO #BatteryStatus FROM [#VIsitedStores]
	----GROUP BY CovAreaId,CovAreaNodeType

	----UPDATE #BatteryStatus SET WorkingHours=CAST(DATEDIFF(MINUTE,Start_Time,End_Time)/60 AS VARCHAR) + ':' + CAST(CAST(DATEDIFF(MINUTE,Start_Time,End_Time)%60 AS INT) AS VARCHAR)
	----UPDATE #BatteryStatus SET MIN_Battery = BatteryLeftStatus FROM #BatteryStatus INNER JOIN [#VIsitedStores] ON [#VIsitedStores].DeviceVisitStartTS = Start_Time
	----UPDATE #BatteryStatus SET MAX_Battery = BatteryLeftStatus FROM #BatteryStatus INNER JOIN [#VIsitedStores] ON [#VIsitedStores].DeviceVisitEndTS = End_Time
	--SELECT * FROM #BatteryStatus


	INSERT INTO #Final(RptDate,RSMAreaId,RSMAreaNodeType,[RSM Area],StateHeadAreaNodeID,StateHeadAreaNodeType,StateHeadArea,ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area],CoverageAreaId,CoverageAreaNodeType,CoverageArea, SalesmanNodeId,SalesmanNodeType,EmpCode,Salesman,[User Status],[User Contact])
	SELECT DISTINCT RptDate,ZoneId,ZoneNodeType,Zone,RegionNodeId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea,SalesmanNodeId,SalesmanNodeType,EmpCode, Salesman ,[User Status],[User Contact]
	FROM #tmpRsltWithFullHierarchyDateWise  WHERE ISNULL(RouteId,0)>0

	--SELECT * FROM #Final WHERE CoverageAreaId=88 ORDER BY RptDate

	UPDATE F SET DOJ=P.FromDate FROM #Final F INNER JOIN tblMstrPerson P ON P.NodeID=F.SalesmanNodeId

	UPDATE F SET ReasonID=D.ReasonID FROM #Final F INNER JOIN #DayStartDetail D ON D.PersonNodeID=F.SalesmanNodeId AND CAST(D.AttenDate AS DATE)=F.RptDate

	UPDATE F SET ReasonDescr='L' FROM #Final F WHERE ReasonID IN (1,18)
	UPDATE F SET ReasonDescr='H' FROM #Final F WHERE ReasonID=2
	UPDATE F SET ReasonDescr='W' FROM #Final F WHERE ReasonID=3
	UPDATE F SET ReasonDescr='P' FROM #Final F WHERE ReasonID IN (8,9,10,16) OR ReasonID IN (6,4,7,12,14,17)
	--UPDATE F SET ReasonDescr='O' FROM #Final F WHERE ReasonID IN (6,4,7,12,14,17)
	
	UPDATE F SET ReasonDescr='A' FROM #Final F WHERE ReasonID IS NULL

	--- Sunday Handling
	UPDATE F SET ReasonDescr='W' FROM #Final F WHERE ReasonID IS NULL AND DATENAME(WEEKDAY,RptDate)='Sunday'

	-- UPdate Route Details
	UPDATE F SET AssignRoute= COALESCE(AssignRoute+',' , '') + Route FROM #Final F INNER JOIN #tmpRoute T ON T.CovAreaId=F.CoverageAreaId AND T.CovAreaNodeType=F.CoverageAreaNodeType AND T.RptDate=F.RptDate

	UPDATE F SET VisitRoute= COALESCE(VisitRoute+',' , '') + R.Descr FROM #Final F INNER JOIN #VIsitedStores T ON T.CovAreaId=F.CoverageAreaId AND T.CovAreaNodeType=F.CoverageAreaNodeType AND T.VisitDate=F.RptDate INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=T.RouteID AND R.NodeType=T.RouteNodeType WHERE T.flgTelephonicCall<>1
		
	--SELECT * FROM #DayStartActivity

	UPDATE A SET A.[Day Start Time]=FORMAT(B.DayStartTime,'HH:mm'),A.Activity=B.Activity
	FROM #Final A INNER JOIN #DayStartActivity B ON A.SalesmanNodeId=B.PersonNodeId AND A.RptDate=B.AttenDate
	
	UPDATE A SET A.[Day End Time]=CASE WHEN CAST(B.DayEndTime AS DATE)=@strDate THEN FORMAT(B.DayEndTime,'HH:mm') ELSE FORMAT(B.DayEndTime,'dd-MMM HH:mm') END FROM #Final A INNER JOIN #DayEndDetails B ON A.SalesmanNodeId=B.SalesmanNodeId AND A.RptDate=B.ForDate
	
	UPDATE A SET A.WorkingHours_FirstVisitMinusDayEnd=B.WorkingHours_FirstVisitMinusDayEnd FROM #Final A INNER JOIN #BatteryStatus B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType AND A.RptDate=B.VisitDate

	UPDATE A 
	SET [Start Time] = CASE WHEN DATEPART(hh,Start_Time)<10 THEN '0'+ CAST(DATEPART(hh,Start_Time) AS VARCHAR)  ELSE CAST(DATEPART(hh,Start_Time) AS VARCHAR) End+':'+					CASE WHEN DATEPART(mi,Start_Time)<10 THEN '0'+ CAST(DATEPART(mi,Start_Time) AS VARCHAR) ELSE CAST(DATEPART(mi,Start_Time) AS VARCHAR) End+'						Bt@'+CAST(MIN_Battery AS VARCHAR),
		[End Time] = CASE WHEN DATEPART(hh,end_Time)<10 THEN '0'+ CAST(DATEPART(hh,end_Time) AS VARCHAR) ELSE CAST(DATEPART(hh,end_Time) AS VARCHAR) End+':'+
						CASE WHEN DATEPART(mi,end_Time)<10 THEN '0'+ CAST(DATEPART(mi,end_Time) AS VARCHAR) ELSE CAST(DATEPART(mi,end_Time) AS VARCHAR) End+' Bt@'+CAST(MAX_Battery AS VARCHAR),
		[Working Hours]=B.WorkingHours
	FROM #Final A INNER JOIN #BatteryStatus B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType AND B.WorkingType=1 AND A.RptDate=B.VisitDate
	
	UPDATE A 
	SET [Start Time] = CASE WHEN DATEPART(hh,Start_Time)<10 THEN '0'+ CAST(DATEPART(hh,Start_Time) AS VARCHAR)  ELSE CAST(DATEPART(hh,Start_Time) AS VARCHAR) End+':'+				 CASE WHEN DATEPART(mi,Start_Time)<10 THEN '0'+ CAST(DATEPART(mi,Start_Time) AS VARCHAR) ELSE CAST(DATEPART(mi,Start_Time) AS VARCHAR) End,
		[End Time] = CASE WHEN DATEPART(hh,end_Time)<10 THEN '0'+ CAST(DATEPART(hh,end_Time) AS VARCHAR) ELSE CAST(DATEPART(hh,end_Time) AS VARCHAR) End+':'+
					CASE WHEN DATEPART(mi,end_Time)<10 THEN '0'+ CAST(DATEPART(mi,end_Time) AS VARCHAR) ELSE CAST(DATEPART(mi,end_Time) AS VARCHAR) End,
		[Working Hours]=B.WorkingHours
	FROM #Final A INNER JOIN #BatteryStatus B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType AND B.WorkingType=2 AND ISNULL(A.[Start Time],'')='' AND A.RptDate=B.VisitDate
	
	UPDATE  #Final SET [Time Spent in Store] = #TimeSpentInStore.TimeSpentInStore_HHMM
	FROM #Final INNER JOIN #TimeSpentInStore ON #TimeSpentInStore.CovAreaId = #Final.CoverageAreaId AND #TimeSpentInStore.CovAreaNodeType = #Final.CoverageAreaNodeType  AND #Final.RptDate=#TimeSpentInStore.VisitDate

	UPDATE #Final SET [Stores Added^Total] = AA.TotStoresAdded
	FROM #Final  INNER JOIN (Select CreatedDate,CovAreaId,CovAreaNodeType,COUNT(DISTINCT StoreID) AS TotStoresAdded FROM #StoreList GROUP BY CreatedDate,CovAreaId,CovAreaNodeType) AS AA ON #Final.CoverageAreaId = AA.CovAreaId AND #Final.CoverageAreaNodeType=AA.CovAreaNodeType AND #Final.RptDate=AA.CreatedDate

	UPDATE #Final SET [Stores Added^Today] = AA.TotStoresAdded
	FROM #Final  INNER JOIN (Select CreatedDate,CovAreaId,CovAreaNodeType,COUNT(DISTINCT StoreID) AS TotStoresAdded FROM #StoreList WHERE AddedToday=1 GROUP BY CreatedDate,CovAreaId,CovAreaNodeType) AS AA ON #Final.CoverageAreaId = AA.CovAreaId AND #Final.CoverageAreaNodeType=AA.CovAreaNodeType AND #Final.RptDate=AA.CreatedDate 

	UPDATE #Final SET [Calls^Target] = AA.TargetCalls
	FROM #Final  INNER JOIN (Select RptDate,CovAreaId,CovAreaNodeType,COUNT(DISTINCT StoreID) AS TargetCalls FROM #Target GROUP BY RptDate,CovAreaId,CovAreaNodeType) AS AA ON #Final.CoverageAreaId = AA.CovAreaId AND #Final.CoverageAreaNodeType=AA.CovAreaNodeType AND #Final.RptDate=AA.RptDate

	UPDATE #Final SET [Calls^Actual] = AA.Actual 
	FROM #Final INNER JOIN (Select VisitDate,CovAreaId,CovAreaNodeType,COUNT(DISTINCT StoreID) AS Actual FROM [#VIsitedStores] GROUP BY VisitDate,CovAreaId,CovAreaNodeType) AS AA ON #Final.CoverageAreaId = AA.CovAreaId AND #Final.CoverageAreaNodeType=AA.CovAreaNodeType AND #Final.RptDate=AA.VisitDate 

	--,CASE WHEN SUM(TimeSpentInStore)>=18000 THEN 1 ELSE 0 END flgWorking

	--SELECT * FROM #TimeSpentInStore WHERE CovAreaId=12 AND VisitDate='23-Feb-2022'

	UPDATE F SET [Calls^Avg Retailing Time(Sec)]=T.TimeSpentInStore/[Calls^Actual],[Calls^Retailing Grade]=CASE WHEN T.TimeSpentInStore>18000 THEN 'Greater Than 5 Hours' ELSE 'Less Than 5 Hours' END FROM #Final F , 
	(SELECT CovAreaId,CovAreaNodeType,VisitDate,SUM(T.TimeSpentInStore) TimeSpentInStore FROM #TimeSpentInStore T GROUP BY CovAreaId,CovAreaNodeType,VisitDate ) T
	WHERE T.CovAreaId=F.CoverageAreaId AND T.CovAreaNodeType=F.CoverageAreaNodeType AND F.RptDate=T.VisitDate

	UPDATE F SET [Calls^Avg Retailing Time(hour:min:Sec)]= CAST(FLOOR([Calls^Avg Retailing Time(Sec)]/60) AS VARCHAR) + ':' + CAST([Calls^Avg Retailing Time(Sec)] % 60 AS VARCHAR) FROM #Final F 

	 

	--SELECT * FROM #Final WHERE CoverageAreaId=12 AND RptDate='23-Feb-2022'

	PRINT 'Grv'
	SELECT DISTINCT A.PersonNodeID,CAST(A.Datetime AS DATE) NoAttDate INTO #SalesmanMarkedNotWorking
	FROM tblPersonAttendance A INNER JOIN PersonAttReason B ON A.PersonAttendanceID=B.PersonAttendanceID INNER JOIN tblMstrReasonsForNoVisit C ON B.ReasonID=C.ReasonId
	WHERE MONTH(@strDate)=MONTH(GETDATE()) AND YEAR(@Strdate)=YEAR(GETDATE()) AND C.flgNoVisitOption=1
	--SELECT * FROM #SalesmanMarkedNotWorking

	UPDATE A SET A.flgMarkedNotWorking=1 FROM #Final A INNER JOIN #SalesmanMarkedNotWorking B ON A.SalesmanNodeId=B.PersonNodeID AND A.RptDate=B.NoAttDate

	--UPDATE A SET A.[Calls^Target]=0 FROM #Final A INNER JOIN (SELECT CoverageAreaId,CoverageAreaNodeType FROM #Final WHERE flgMarkedNotWorking=1 GROUP BY CoverageAreaId,CoverageAreaNodeType HAVING SUM([Calls^Actual])=0) B ON A.CoverageAreaId=B.CoverageAreaId AND A.CoverageAreaNodeType=B.CoverageAreaNodeType
	--SELECT * FROM #ForUpdate_CovArea
	UPDATE  #Final SET [Calls^Productive]=Prod_Call,[Total Sales^Dstr] = #ForUpdate_CovArea.Prod_Call,[Total Sales^Lines Ordered]=#ForUpdate_CovArea.TotLinesOrdered,[Total Sales^Qty In KG]=#ForUpdate_CovArea.OrderQtyInKG,[Total Sales^Qty In Case]=#ForUpdate_CovArea.OrderInCase,[Total Sales^Value] = ROUND(ISNULL(#ForUpdate_CovArea.TotOrderVal,0),2), [Lines/Bill] =CASE ISNULL(#ForUpdate_CovArea.Prod_Call,0) WHEN 0 THEN NULL ELSE ROUND(#ForUpdate_CovArea.TotLinesOrdered/CAST(#ForUpdate_CovArea.Prod_Call AS FLOAT),2) END
	FROM #Final INNER JOIN #ForUpdate_CovArea ON #ForUpdate_CovArea.CovAreaId = #Final.CoverageAreaId AND #ForUpdate_CovArea.CovAreaNodeType = #Final.CoverageAreaNodeType AND #Final.RptDate=#ForUpdate_CovArea.OrderDate

	--DELETE FROM #Final WHERE ISNULL([Stores Added^Total],0)=0 AND ISNULL([Calls^Target],0)=0 AND ISNULL([Calls^Actual],0)=0 AND [Day Start Time] IS NULL
	--SELECT * FROM #Final WHERE CoverageAreaId=17 --AND RptDate='06-Feb-2022'
	
	CREATE TABLE #ColumnIndexListForFormatting(ColumnIndex TINYINT,ColorCode VARCHAR(10))

	INSERT INTO #ColumnIndexListForFormatting(ColumnIndex,ColorCode)
	SELECT 10 AS ColumnName,'FFD966' AS ColorCode
	UNION
	SELECT 12 AS ColumnName,'A9D08E' AS ColorCode
	UNION
	SELECT 13 AS ColumnName,'A9D08E' AS ColorCode
	UNION
	SELECT 14 AS ColumnName,'A9D08E' AS ColorCode
	UNION
	SELECT 16 AS ColumnName,'887D4D' AS ColorCode
	UNION
	SELECT 17 AS ColumnName,'887D4D' AS ColorCode	
	UNION
	SELECT 18 AS ColumnName,'887D4D' AS ColorCode
	UNION
	SELECT 19 AS ColumnName,'887D4D' AS ColorCode

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
		IF @Counter<>@MaxCount
		BEGIN
			INSERT INTO #ColumnIndexListForFormatting(ColumnIndex,ColorCode)
			SELECT 20+@Counter AS ColumnName,'5F8B41' AS ColorCode
		END
		
		SELECT @CatNodeId=CategoryNodeId,@Category=Category FROM #tmpCatList WHERE RowId=@Counter

		SELECT @strSQL='ALTER TABLE #Final ADD [Order Qty In KG: ' + @Category + '] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)
		SELECT @strSQL='ALTER TABLE #Final ADD [Order Qty In Case: ' + @Category + '] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @strSQL='UPDATE A SET A.[Order Qty In KG: ' + @Category + ']=ROUND(B.OrderQtyInKG,2) , A.[Order Qty In Case: ' + @Category + ']=ROUND(B.OrderInCase,2)
		FROM #Final A INNER JOIN (SELECT OrderDate,CovAreaId,CovAreaNodeType,SUM(OrderQtyInKG) OrderQtyInKG,SUM(OrderInCase) OrderInCase FROM #TMPSales WHERE CategoryId=' + CAST(@CatNodeId AS VARCHAR) + ' GROUP BY OrderDate,CovAreaId,CovAreaNodeType) B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType AND A.RptDate=B.OrderDate'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @StrCategory= @StrCategory + ',[Order Qty In KG: ' + @Category + ']' + ',[Order Qty In Case: ' + @Category + ']'
		SELECT @StrCategoryForGrouping=@StrCategoryForGrouping +  ',SUM([Order Qty In KG: ' + @Category + '])' +  ',SUM([Order Qty In Case: ' + @Category + '])'
		SELECT @Counter+=1
	END
	--SELECT * FROM #Final
	--RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area]
	----IF EXISTS(SELECT 1 FROM #Final)
	----BEGIN
	----	--INSERT INTO #Final(flg,flgGrouping,RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area],CoverageAreaId,[Stores Added^Total],[Stores Added^Today],[Calls^Target],[Calls^Actual],[Calls^Productive],[Total Sales^Dstr],[Total Sales^Lines Ordered],[Total Sales^Qty In Pcs],[Total Sales^Value],[Total Sales^Lines/Bill])
	----	--SELECT 0,'2,12',RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area] + ' Total',0,SUM([Stores Added^Total]),SUM([Stores Added^Today]),SUM([Calls^Target]),SUM([Calls^Actual]),SUM([Calls^Productive]),SUM([Total Sales^Dstr]),SUM([Total Sales^Lines Ordered]),SUM([Total Sales^Qty In Pcs]),SUM([Total Sales^Value]),CASE ISNULL(SUM([Calls^Productive]),0) WHEN 0 THEN NULL ELSE ROUND(SUM([Total Sales^Lines Ordered])/CAST(SUM([Calls^Productive]) AS FLOAT),2) END
	----	--FROM #Final WHERE CoverageAreaId>0
	----	--GROUP BY RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area]

	----	SELECT @strSQL='INSERT INTO #Final(flg,Lvl,flgGrouping,RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,CoverageAreaId,[Stores Added^Total],[Stores Added^Today],[Calls^Target],[Calls^Actual],[Calls^Productive],[Total Sales^Dstr],[Total Sales^Lines Ordered],[Total Sales^Qty In KG],[Total Sales^Value],[Total Sales^Lines/Bill]' + @StrCategory + ')
	----	SELECT 0,1,''1,9'',RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area] + '' Total'',0,0,SUM([Stores Added^Total]),SUM([Stores Added^Today]),SUM([Calls^Target]),SUM([Calls^Actual]),SUM([Calls^Productive]),SUM([Total Sales^Dstr]),SUM([Total Sales^Lines Ordered]),SUM([Total Sales^Qty In KG]),SUM([Total Sales^Value]),CASE ISNULL(SUM([Calls^Productive]),0) WHEN 0 THEN NULL ELSE ROUND(SUM([Total Sales^Lines Ordered])/CAST(SUM([Calls^Productive]) AS FLOAT),2) END' + @StrCategoryForGrouping + '
	----	FROM #Final WHERE CoverageAreaId>0 GROUP BY RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area]'
	----	PRINT @strSQL
	----	EXEC(@strSQL)

	----	UPDATE A SET A.flgHide=1 FROM #Final A INNER JOIN (SELECT ASMAreaId,ASMAreaNodeType FROM #Final WHERE ISNULL(SOAreaId,0)>0 GROUP BY ASMAreaId,ASMAreaNodeType HAVING COUNT(DISTINCT SOAreaId)=1) B ON A.ASMAreaId=B.ASMAreaId AND A.ASMAreaNodeType=B.ASMAreaNodeType AND A.Lvl=1

	----	SELECT @strSQL='INSERT INTO #Final(flg,Lvl,flgGrouping,RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,SOAreaId,CoverageAreaId,[Stores Added^Total],[Stores Added^Today],[Calls^Target],[Calls^Actual],[Calls^Productive],[Total Sales^Dstr],[Total Sales^Lines Ordered],[Total Sales^Qty In KG],[Total Sales^Value],[Total Sales^Lines/Bill]' + @StrCategory + ')
	----	SELECT 0,2,''0,9'',RSMAreaId,RSMAreaNodeType,[RSM Area] + '' Total'',0,0,0,SUM([Stores Added^Total]),SUM([Stores Added^Today]),SUM([Calls^Target]),SUM([Calls^Actual]),SUM([Calls^Productive]),SUM([Total Sales^Dstr]),SUM([Total Sales^Lines Ordered]),SUM([Total Sales^Qty In KG]),SUM([Total Sales^Value]),CASE ISNULL(SUM([Calls^Productive]),0) WHEN 0 THEN NULL ELSE ROUND(SUM([Total Sales^Lines Ordered])/CAST(SUM([Calls^Productive]) AS FLOAT),2) END' + @StrCategoryForGrouping + '
	----	FROM #Final WHERE CoverageAreaId>0 GROUP BY RSMAreaId,RSMAreaNodeType,[RSM Area]'
	----	PRINT @strSQL
	----	EXEC(@strSQL)

	----	--UPDATE A SET A.flgHide=1 FROM #Final A INNER JOIN (SELECT RSMAreaId,RSMAreaNodeType FROM #Final WHERE ISNULL(ASMAreaId,0)>0 GROUP BY RSMAreaId,RSMAreaNodeType HAVING COUNT(DISTINCT ASMAreaId)=1) B ON A.RSMAreaId=B.RSMAreaId AND A.RSMAreaNodeType=B.RSMAreaNodeType AND A.Lvl=2

	----	SELECT @strSQL='INSERT INTO #Final(flg,Lvl,flgGrouping,[RSM Area],RSMAreaId,ASMAreaId,SOAreaId,CoverageAreaId,[Stores Added^Total],[Stores Added^Today],[Calls^Target],[Calls^Actual],[Calls^Productive],[Total Sales^Dstr],[Total Sales^Lines Ordered],[Total Sales^Qty In KG],[Total Sales^Value],[Total Sales^Lines/Bill]' + @StrCategory + ')
	----	SELECT 1,3,''0,9'',''Grand Total'',0,0,0,0,SUM([Stores Added^Total]),SUM([Stores Added^Today]),SUM([Calls^Target]),SUM([Calls^Actual]),SUM([Calls^Productive]),SUM([Total Sales^Dstr]),SUM([Total Sales^Lines Ordered]),SUM([Total Sales^Qty In KG]),SUM([Total Sales^Value]),CASE ISNULL(SUM([Calls^Productive]),0) WHEN 0 THEN NULL ELSE ROUND(SUM([Total Sales^Lines Ordered])/CAST(SUM([Calls^Productive]) AS FLOAT),2) END' + @StrCategoryForGrouping + '
	----	FROM #Final WHERE CoverageAreaId>0'
	----	PRINT @strSQL
	----	EXEC(@strSQL)
	----END
	
	

	UPDATE #Final SET [Calls^Productivity %]=CASE [Calls^Actual] WHEN 0 THEN '' ELSE CAST(ROUND(([Calls^Productive]/CAST([Calls^Actual] AS FLOAT))*100,0) AS VARCHAR) + '%' END

	--SELECT * FROM #Final ORDER BY Flg Desc,[RSM Area],[ASM Area],[SO Area],CoverageArea
	--,WorkingHours_FirstVisitMinusDayEnd [Working Hours (Day End - First Visit) (hh:mm)^$2]
	--,CoverageArea [Coverage Area^$1],Salesman [Salesman^$1]
	UPDATE F SET RSMName=P.Descr FROM #Final F INNER JOIN tblSalesPersonMapping SM ON SM.NodeID=F.RSMAreaId AND SM.NodeType=F.RSMAreaNodeType INNER JOIN tblMstrPerson P ON P.NodeID=SM.PersonNodeID WHERE F.RptDate BETWEEN SM.FromDate AND SM.ToDate

	SELECT @strSQL='SELECT RptDate,[RSM Area],RSMName ,[ASM Area] ,[SO Area] ,AssignRoute,VisitRoute,CASE WHEN AssignRoute=VisitRoute THEN ''Yes'' ELSE ''No'' END AS [PJP Adherence],FORMAT(CAST(DOJ AS DATE),''dd-MMM-yy'') [Date Of Joining],[Start Time] ,[End Time] ,[Working Hours] [Working Hours] ,[Calls^Avg Retailing Time(hour:min:Sec)] [Avg Retailing Time(hour:min:Sec)],[Calls^Retailing Grade] [Retailing Grade],[Time Spent in Store] ,[Calls^Target] [Schedule Calls],[Calls^Actual] [Total Calls],[Calls^Productive] [Productive Shops],[Calls^Productivity %][Productivity %]' + @StrCategory + ',[Total Sales^Value] [Sales Value]

	----[Day Start Time] ,Activity ,[Day End Time] ,
	----[Stores Added^Total] [Stores InCoverage] ,[Stores Added^Today] [Stores Added TOday] ,[Total Sales^Dstr] [Sales Distribution],[Total Sales^Lines Ordered][Lines Ordered],ROUND([Total Sales^Qty In KG],2) [Qty In KG],ROUND([Total Sales^Qty In Case],2) [Qty In Case],[Lines/Bill] ,flg [flg],flgGrouping [flgGrouping] 
	FROM #Final WHERE flgHide=0 ORDER BY flg DESC,[RSM Area],[ASM Area],[SO Area],CoverageArea,RptDate'
	PRINT @strSQL
	EXEC(@strSQL)


	CREATE TABLE #RptAttendance(RSMAreaId INT,RSMAreaNodeType INT,[RSM Area] VARCHAR(200),[RSM Name] VARCHAR(200),StateHeadAreaNodeID INT,StateHeadAreaNodeType SMALLINT,StateHeadArea VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,[ASM Area] VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,[SO Area] VARCHAR(200),CoverageAreaId INT,CoverageAreaNodeType INT,CoverageArea VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,EmpCode VARCHAR(20),Salesman VARCHAR(200),[User Status] VARCHAR(20),DOJ VARCHAR(20),[User Contact] BIGINT,[Total Days] INT,[Working Days] INT DEFAULT 0,[Retailing Days(R)] INT DEFAULT 0,[Other Official Work (O)] INT DEFAULT 0,[Leave(L)] INT DEFAULT 0,[Holiday(H)] INT DEFAULT 0,[Absent(A)] INT DEFAULT 0,[Weekly Off(W)] INT DEFAULT 0,
	[Calls^Avg Retailing Time(hour:min:Sec)] VARCHAR(10))


	----AssignRoute VARCHAR(200),VisitRoute VARCHAR(200),
	----[Day Start Time] VARCHAR(20),Activity VARCHAR(500),[Day End Time] VARCHAR(20),[Start Time] VARCHAR(20) DEFAULT '', [End Time] VARCHAR(20) DEFAULT '',[Working Hours] VARCHAR(20) DEFAULT '',WorkingHours_FirstVisitMinusDayEnd VARCHAR(20) DEFAULT '',[Time Spent in Store] VARCHAR(10) DEFAULT '',[Stores Added^Total] INT DEFAULT 0, [Stores Added^Today] INT DEFAULT 0,[Calls^DaysInMonth] INT DEFAULT 0,[Calls^Target] INT DEFAULT 0, [Calls^Actual] INT DEFAULT 0, [Calls^Avg Retailing Time(Sec)] INT,[Calls^Retailing Grade] VARCHAR(50),[Calls^Productive] INT DEFAULT 0,[Calls^Productivity %] VARCHAR(10) DEFAULT '' NOT NULL,[Total Sales^Dstr] INT,[Total Sales^Lines Ordered] INT,[Total Sales^Qty In KG] FLOAT,[Total Sales^Qty In Case] FLOAT,[Total Sales^Value] FLOAT,[Lines/Bill] FLOAT,flgMarkedNotWorking TINYINT)

	--SELECT * FROM #Final WHERE CoverageAreaId=12 AND RptDate='23-Feb-2022'

	INSERT INTO #RptAttendance(RSMAreaId,RSMAreaNodeType,[RSM Area],StateHeadAreaNodeID,StateHeadAreaNodeType,StateHeadArea,ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area],CoverageAreaId,CoverageAreaNodeType,CoverageArea)
	SELECT DISTINCT RSMAreaId,RSMAreaNodeType,[RSM Area],StateHeadAreaNodeID,StateHeadAreaNodeType,StateHeadArea,ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area],CoverageAreaId,CoverageAreaNodeType,CoverageArea FROM #Final

	
	SELECT F.CoverageAreaId,F.CoverageAreaNodeType,MAX(RptDate) LAstPersonAssignedDate INTO #LastPersonAssign FROM #Final F WHERE SalesmanNodeId>0 GROUP BY F.CoverageAreaId,F.CoverageAreaNodeType

	UPDATE R SET R.SalesmanNodeId=F.SalesmanNodeId,SalesmanNodeType=F.SalesmanNodeType,EmpCode=F.EmpCode,Salesman=F.Salesman,[User Status]=F.[User Status],DOJ=F.DOJ,[User Contact]=F.[User Contact],[RSM Name]=F.RSMName FROM #RptAttendance R INNER JOIN #LastPersonAssign A ON A.CoverageAreaId=R.CoverageAreaId AND A.CoverageAreaNodeType=R.CoverageAreaNodeType INNER JOIN #Final F ON F.CoverageAreaId=A.CoverageAreaId AND F.CoverageAreaNodeType=A.CoverageAreaNodeType AND F.RptDate=A.LAstPersonAssignedDate
	
	--,SalesmanNodeId,SalesmanNodeType,EmpCode,Salesman,[User Status],DOJ,[User Contact] FROM #Final

	
	----UPDATE F SET [Calls^Avg Retailing Time(Sec)]=T.TimeSpentInStore/[Calls^Actual],[Calls^Retailing Grade]=CASE WHEN T.TimeSpentInStore>18000 THEN 'Greater Than 5 Hours' ELSE 'Less Than 5 Hours' END FROM #Final F , 
	----(SELECT CovAreaId,CovAreaNodeType,VisitDate,SUM(T.TimeSpentInStore) TimeSpentInStore FROM #TimeSpentInStore T GROUP BY CovAreaId,CovAreaNodeType,VisitDate ) T
	----WHERE T.CovAreaId=F.CoverageAreaId AND T.CovAreaNodeType=F.CoverageAreaNodeType AND F.RptDate=T.VisitDate

	SELECT CovAreaId,CovAreaNodeType,VisitDate,SUM(T.TimeSpentInStore) TimeSpentInStore INTO #PerDayRetailing FROM #TimeSpentInStore T GROUP BY CovAreaId,CovAreaNodeType,VisitDate

	SELECT CovAreaId,CovAreaNodeType,SUM(TimeSpentInStore)/COUNT(VisitDate) AvgRetailinginSec,CASE WHEN SUM(TimeSpentInStore)/COUNT(VisitDate)>18000 THEN 'Greater Than 5 Hours' ELSE 'Less Than 5 Hours' END AvgRetailingString INTO #AvgRetailingData FROM #PerDayRetailing GROUP BY CovAreaId,CovAreaNodeType

	UPDATE R SET [Calls^Avg Retailing Time(hour:min:Sec)]=RIGHT('00' + CAST(AvgRetailinginSec / 3600 AS VARCHAR),2) + ':' + RIGHT('00' + CAST((AvgRetailinginSec / 60) % 60 AS VARCHAR),2) + ':' + RIGHT('00' + CAST(AvgRetailinginSec % 60 AS VARCHAR),2)
	FROM #RptAttendance R INNER JOIN #AvgRetailingData A ON A.CovAreaId=R.CoverageAreaId AND A.CovAreaNodeType=R.CoverageAreaNodeType 

	--CAST(FLOOR(AvgRetailinginSec/60) AS VARCHAR) + ':' + CAST(AvgRetailinginSec % 60 AS VARCHAR)

	--SELECT * FROM #RptAttendance WHERE CoverageAreaId=12 AND RptDate='23-Feb-2022'

	UPDATE R SET [Total Days]=TotalDays FROM #RptAttendance R,(SELECT SalesmanNodeID,COUNT(RptDate) TotalDays FROM #Final F WHERE RptDate>=F.DOJ GROUP BY SalesmanNodeID) F WHERE F.SalesmanNodeId=R.SalesmanNodeId

	UPDATE R SET [Working Days]=WorkingDays FROM #RptAttendance R,(SELECT SalesmanNodeID,COUNT(RptDate) WorkingDays FROM #Final F WHERE ReasonDescr IN ('P') GROUP BY SalesmanNodeID) F WHERE F.SalesmanNodeId=R.SalesmanNodeId
	UPDATE R SET [Retailing Days(R)]=RetailingDays FROM #RptAttendance R,(SELECT SalesmanNodeID,COUNT(DISTINCT RptDate) RetailingDays FROM #Final F INNER JOIN #TimeSpentInStore T ON T.CovAreaId=F.CoverageAreaId AND T.CovAreaNodeType=F.CoverageAreaNodeType AND T.VisitDate=F.RptDate WHERE ReasonDescr IN ('P') GROUP BY SalesmanNodeID) F WHERE F.SalesmanNodeId=R.SalesmanNodeId
	
	UPDATE R SET [Other Official Work (O)]=OtherWorkDays FROM #RptAttendance R,(SELECT SalesmanNodeID,COUNT(RptDate) OtherWorkDays FROM #Final F WHERE ReasonDescr IN ('O') GROUP BY SalesmanNodeID) F WHERE F.SalesmanNodeId=R.SalesmanNodeId
	UPDATE R SET [Leave(L)]=LeaveDays FROM #RptAttendance R,(SELECT SalesmanNodeID,COUNT(RptDate) LeaveDays FROM #Final F WHERE ReasonDescr IN ('L') GROUP BY SalesmanNodeID) F WHERE F.SalesmanNodeId=R.SalesmanNodeId
	UPDATE R SET [Holiday(H)]=HoliDays FROM #RptAttendance R,(SELECT SalesmanNodeID,COUNT(RptDate) HoliDays FROM #Final F WHERE ReasonDescr IN ('H') GROUP BY SalesmanNodeID) F WHERE F.SalesmanNodeId=R.SalesmanNodeId
	UPDATE R SET [Absent(A)]=AbsentDays FROM #RptAttendance R,(SELECT SalesmanNodeID,COUNT(RptDate) AbsentDays FROM #Final F WHERE ReasonDescr IN ('A') GROUP BY SalesmanNodeID) F WHERE F.SalesmanNodeId=R.SalesmanNodeId
	UPDATE R SET [Weekly Off(W)]=WeeklyOffDays FROM #RptAttendance R,(SELECT SalesmanNodeID,COUNT(RptDate) WeeklyOffDays FROM #Final F WHERE ReasonDescr IN ('W') GROUP BY SalesmanNodeID) F WHERE F.SalesmanNodeId=R.SalesmanNodeId
	
	
	

	CREATE TABLE #Loop(ID INT IDENTITY(1,1),RptDate Date,DayNo INT,Dayname VARCHAR(10))
	INSERT INTO #Loop(RptDate,DayNo,Dayname)
	SELECT DISTINCT RptDate,DAY(RptDate),SUBSTRING(DATENAME(WeekDay,RptDate),0,4) FROM #Final ORDER BY RptDate
		
	DECLARE @MaxCounter INT,@Count INT,@DayNo VARCHAR(10),@DayName VARCHAR(10),@CurrentDate Date
	SELECT @Count=1
	SELECT @MaxCounter=MAX(ID) FROM #Loop

	WHILE (@MaxCounter>=@Count)
	BEGIN
		SELECT @DayNo=CAST(DayNo AS VARCHAR),@DayName=Dayname,@CurrentDate=RptDate FROM #Loop WHERE ID=@Count

		SET @strSQL='ALTER TABLE #RptAttendance ADD [' + @DayNo + '(' + @DayName + ')] VARCHAR(10)'
		PRINT @strsql
		EXEC (@strSQL)

		SET @strSQL='UPDATE R SET [' + @DayNo + '(' + @DayName + ')]=F.ReasonDescr FROM #RptAttendance R INNER JOIN #Final F ON F.SalesmanNodeId=R.SalesmanNodeId AND F.RptDate=''' + CAST(@CurrentDate AS VARCHAR) + ''''
		PRINT @strsql
		EXEC (@strSQL)

		SELECT @Count=@Count + 1
	END

	ALTER TABLE #RptAttendance DROP COLUMN  RSMAreaId
	ALTER TABLE #RptAttendance DROP COLUMN  RSMAreaNodeType
	ALTER TABLE #RptAttendance DROP COLUMN  StateHeadAreaNodeID
	ALTER TABLE #RptAttendance DROP COLUMN  StateHeadAreaNodeType
	ALTER TABLE #RptAttendance DROP COLUMN  ASMAreaID
	ALTER TABLE #RptAttendance DROP COLUMN  ASMAreaNodeType
	ALTER TABLE #RptAttendance DROP COLUMN  SOAreaID
	ALTER TABLE #RptAttendance DROP COLUMN  SOAreaNodeType
	--ALTER TABLE #RptAttendance DROP COLUMN  CoverageAreaId
	--ALTER TABLE #RptAttendance DROP COLUMN  CoverageAreaNodeType
	ALTER TABLE #RptAttendance DROP COLUMN  SalesmanNodeId
	ALTER TABLE #RptAttendance DROP COLUMN  SalesmanNodeType



	SELECT * FROM #RptAttendance

	----SELECT * FROM #ColumnIndexListForFormatting

	----SELECt 3 AS NoOfColsToFix

	----DECLARE @TotStoresAdded INT=0
	----DECLARE @StoresAddedToday INT=0
	----DECLARE @TotCalls INT=0
	----DECLARE @ProdCalls INT=0
	----DECLARE @TotOrderVal INT=0
	------DECLARE @TotStockVal INT=0
	----DECLARE @NoOFSKUs INT=0
	----DECLARE @NoOFLines INT=0
	----DECLARE @TotSalesman INT=0
	----DECLARE @NoOfSalesmanInMarket INT=0
	
	----SELECT @TotSalesman=COUNT(DISTINCT SalesmanNodeId) FROM #Final WHERE ISNULL(SalesmanNodeId,0)>0
	----SELECT @NoOfSalesmanInMarket=COUNT(DISTINCT SalesmanNodeId) FROM #Final WHERE ISNULL([Calls^Actual],0)>0 AND ISNULL(SalesmanNodeId,0)>0
	----SELECT @TotCalls=ISNULL([Calls^Actual],0),@ProdCalls=ISNULL([Calls^Productive],0) FROM #Final WHERE CoverageAreaId=0

	----SELECT @TotOrderVal=ROUND(SUM(OrderVal),0),@NoOFSKUs=COUNT(DISTINCT SKUNodeId),@NoOFLines= COUNT(CAST(SKUNodeId AS VARCHAR)+'-'+ CAST(StoreID AS VARCHAR))
	----FROM #TMPSales
	----SELECT @TotStoresAdded=COUNT(DISTINCT StoreId) FROM #StoreList
	----SELECT @StoresAddedToday=COUNT(DISTINCT StoreId) FROM #StoreList WHERE AddedToday=1

	----SELECT ISNULL(@TotStoresAdded,0) [Total Stores Added^E6B8B7],ISNULL(@StoresAddedToday,0) [Stores Added Today^CC6C6A],ISNULL(@TotSalesman,0) [Total Salesman^808080],ISNULL(@NoOfSalesmanInMarket,0) [# Salesman In Market^C7C7C7],ISNULL(@TotCalls,0) [Total Calls Made^8AB96A],ISNULL(@ProdCalls,0) [Productive Calls^9856C9],ISNULL(@TotOrderVal,0) [Total Order Value^D3824B], ISNULL(@NoOFSKUs,0) [# of SKUs Ordered^FFC000],ISNULL(@NoOFLines,0) [Total Lines Ordered^B8AF82] 
	

	
















