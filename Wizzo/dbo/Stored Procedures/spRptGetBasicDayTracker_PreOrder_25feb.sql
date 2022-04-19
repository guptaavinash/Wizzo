
--[spRptGetBasicDayTracker_PreOrder_25feb]'02-Feb-2022',4492,''
CREATE PROC [dbo].[spRptGetBasicDayTracker_PreOrder_25feb]
@strDate DATE,
@LoginId INT,
@strSalesHierarchy VARCHAR(5000)=''
AS
	CREATE TABLE #tmpRsltWithFullHierarchy(ZoneId INT,ZoneNodeType INT,Zone VARCHAR(200),RegionNodeId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,Salesman VARCHAR(200),flgActive TINYINT DEFAULT 0 NOT NULL)

	CREATE TABLE #Final(flgHide TINYINT DEFAULT 0 NOT NULL,Lvl TINYINT DEFAULT 0 NOT NULL,flg TINYINT DEFAULT 0 NOT NULL,flgGrouping VARCHAR(10) DEFAULT 0 NOT NULL,RSMAreaId INT,RSMAreaNodeType INT,[RSM Area] VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,[ASM Area] VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,[SO Area] VARCHAR(200),CoverageAreaId INT,CoverageAreaNodeType INT,CoverageArea VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,Salesman VARCHAR(200),[Day Start Time] VARCHAR(20),Activity VARCHAR(500),[Day End Time] VARCHAR(20),[Start Time] VARCHAR(20) DEFAULT '', [End Time] VARCHAR(20) DEFAULT '',[Working Hours] VARCHAR(20) DEFAULT '',WorkingHours_FirstVisitMinusDayEnd VARCHAR(20) DEFAULT '',[Time Spent in Store] VARCHAR(10) DEFAULT '',[Stores Added^Total] INT DEFAULT 0, [Stores Added^Today] INT DEFAULT 0,[Calls^Target] INT DEFAULT 0, [Calls^Actual] INT DEFAULT 0, [Calls^Productive] INT DEFAULT 0,[Calls^Productivity %] VARCHAR(10) DEFAULT '' NOT NULL,[Total Sales^Dstr] INT,[Total Sales^Lines Ordered] INT,[Total Sales^Qty In KG] FLOAT,[Total Sales^Qty In Cases] FLOAT,[Total Sales^Value] FLOAT,[Total Sales^Lines/Bill] FLOAT,flgMarkedNotWorking TINYINT)
		
	DECLARE @StrColumn VARCHAR(MAX)='', @strColumnSEArea VARCHAR(MAX)=''
		
	INSERT INTO #tmpRsltWithFullHierarchy(ZoneId,ZoneNodeType,Zone,RegionNodeId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea, RouteId,RouteNodeType,Route)
	EXEC [spRptGetFullSalesHierarchyBasedonLogin] @LoginId,0,0,@strSalesHierarchy

	--SELECT * FROM #tmpRsltWithFullHierarchy

	SELECT NodeID,NodeType,MIN(VldFrom) VldFrom,MAX(VldTo) VldTo INTO #tmp 
	FROM (SELECT NodeID,NodeType,VldFrom,VldTo FROM tblCompanySalesStructureHierarchy WHERE NodeType=130
	UNION
	SELECT NodeID,NodeType,VldFrom,VldTo FROM tblCompanySalesStructureHierarchy_Backup WHERE NodeType=130) AA GROUP BY NodeID,NodeType
	--SELECT * FROM #tmp

	UPDATE A SET A.flgActive=1
	FROM #tmpRsltWithFullHierarchy A INNER JOIN #tmp B ON A.CovAreaId=B.NodeID AND A.CovAreaNodeType=B.NodeType WHERE (@strDate BETWEEN B.VldFrom AND B.VldTo)
	--DELETE FROM #tmpRsltWithFullHierarchy WHERE flgActive=0
	--DELETE FROM #tmpRsltWithFullHierarchy WHERE CovAreaId IN(12,16)
	--SELECT * FROM #tmpRsltWithFullHierarchy ORDER BY CovAreaId

	DELETE A FROM #tmpRsltWithFullHierarchy A INNER JOIN tblSalesPersonMapping SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType AND (@strDate BETWEEN SP.FromDate AND SP.ToDate)
	INNER JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID WHERE MP.flgSFAUser<>1
	
	UPDATE A SET A.SalesmanNodeId=MP.NodeId,A.SalesmanNodeType=Mp.NodeType,A.Salesman=ISNULL(MP.Descr,'Vacant')
	FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType AND (@strDate BETWEEN SP.FromDate AND SP.ToDate)
	LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID

	--UPDATE A SET A.ASMArea= A.ASMArea + ' (' + ISNULL(MP.Descr,'Vacant') + ')'
	--FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping SP ON A.ASMAreaId=SP.NodeId AND A.ASMAreaNodeType=SP.NodeType AND (@strDate BETWEEN SP.FromDate AND SP.ToDate)
	--LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID
	
	--UPDATE A SET A.SOArea= A.SOArea + ' (' + ISNULL(MP.Descr,'Vacant') + ')'
	--FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping SP ON A.SOAreaId=SP.NodeId AND A.SOAreaNodeType=SP.NodeType AND (@strDate BETWEEN SP.FromDate AND SP.ToDate)
	--LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID
		
	--SELECT * FROM #tmpRsltWithFullHierarchy ORDER BY RouteId
		
	SELECT DISTINCT R.CovAreaId,R.CovAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.RouteId,R.RouteNodetype,RCM.StoreId,0 AS AddedToday INTO #StoreList
	FROM #tmpRsltWithFullHierarchy R INNER JOIN tblRouteCoverageStoreMapping RCM ON R.RouteId=RCM.RouteId AND R.RouteNodetype=RCM.RouteNodetype
	INNER JOIN tblRoutePlanningMstr P ON P.RouteNodeId=RCM.RouteID AND P.RouteNodeType=RCM.RouteNodeType
	INNER JOIN tblStoreMaster SM ON RCM.StoreId=SM.StoreId
	WHERE (@strDate BETWEEN RCM.FromDate AND RCM.ToDate)

	UPDATE A SET A.AddedToday=1
	FROM #StoreList A INNER JOIN tblStoreMaster B ON A.StoreId=B.StoreId
	WHERE CAST(B.CreatedDate AS DATE)=@strDate	
	--SELECT * FROM #StoreList ORDER BY AddedToday desc
	
	SELECT A.CovAreaId,A.CovAreaNodeType,A.ASMAreaId,A.ASMAreaNodeType,A.RouteId,A.RouteNodetype,A.StoreId,B.BatteryStatus,B.VisitStartTS,B.VisitEndTS INTO #WorkingForStoreAddition
	FROM #StoreList A INNER JOIN 	tblPdaSyncStoreMappingMstr B ON A.StoreId=B.OrgStoreId WHERE A.AddedToday=1
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
	SELECT DISTINCT R.CovAreaId,R.CovAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.RouteId,R.RouteNodeType,@strDate AS RptDate,1 AS FlgPlanned INTO #tmpRoute
	FROM tblRoutePlanningVisitDetail RC INNER JOIN #tmpRsltWithFullHierarchy R ON RC.RouteNodeId=R.RouteId AND RC.RouteNodetype=R.RouteNodeType
	WHERE RC.VisitDate=@strDate

	--SELECT * FROM #tmpRoute ORDER BY RouteNodeType,RouteId
	
	SELECT DISTINCT AA.StoreID AS StoreID, #tmpRoute.RouteID, #tmpRoute.RouteNodeType, 1 AS OnRoute,CovAreaId,CovAreaNodeType,ASMAreaId,ASMAreaNodeType INTO [#Target]
	FROM    #tmpRoute
	INNER JOIN (SELECT RouteID,RouteNodeType,StoreID FROM tblRouteCoverageStoreMapping WHERE (CONVERT(VARCHAR,tblRouteCoverageStoreMapping.FromDate, 112) <= CONVERT(VARCHAR, @strDate, 112)) AND (CONVERT(VARCHAR, ISNULL(tblRouteCoverageStoreMapping.ToDate, @strDate), 112) >= CONVERT(VARCHAR, @strDate, 112))) AA ON #tmpRoute.RouteID=AA.RouteID AND #tmpRoute.RouteNodeType=AA.RouteNodeType 
	--SELECT * FROM [#Target] ORDER BY RouteNodeType,RouteId
	
	--Actual Calls
	SELECT R.CovAreaId,R.CovAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,V.VisitId,V.VisitDate,V.RouteID,V.RouteType AS RouteNodeType,V.StoreID,V.BatteryLeftStatus,ISNULL(VD.VisitStartDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitStartTS AS DATETIME)) DeviceVisitStartTS,ISNULL(VD.VisitEndDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitEndTS AS DATETIME)) DeviceVisitEndTS,DATEDIFF(ss,ISNULL(VD.VisitStartDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitStartTS AS DATETIME)) ,ISNULL(VD.VisitEndDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitEndTS AS DATETIME))) TimeSpentInStore,ISNULL(V.EntryPersonNodeId,V.SalesPersonId) SalesmanId INTO [#VIsitedStores]
	FROM tblVisitMaster V 
	LEFT OUTER JOIN tblVisitDet VD ON VD.VisitID=V.VisitID
	INNER JOIN #tmpRsltWithFullHierarchy R ON V.RouteID=R.RouteID AND V.RouteType=R.RouteNodeType
	WHERE (CONVERT(VARCHAR, V.VisitDate, 112) = CONVERT(VARCHAR, @strDate, 112))   
	ORDER BY V.StoreID
	--SELECT *	FROM [#VIsitedStores] ORDER BY CovAreaId,DeviceVisitStartTS
	SELECT * FROM [#VIsitedStores] WHERE CovAreaId=182-- AND StoreID=92464

	DELETE A FROM #tmpRsltWithFullHierarchy A LEFT OUTER JOIN (SELECT DISTINCT CovAreaId,CovAreaNodeType FROM #Target UNION SELECT DISTINCT CovAreaId,CovAreaNodeType FROM [#VIsitedStores]) B ON A.CovAreaId=B.CovAreaId AND A.CovAreaNodeType=B.CovAreaNodeType
	WHERE B.CovAreaId IS NULL AND A.flgActive=0
	
	SELECT CovAreaId,CovAreaNodeType,SUM(TimeSpentInStore) TimeSpentInStore,CAST('' AS VARCHAR(10)) AS TimeSpentInStore_HHMM INTO #TimeSpentInStore 
	FROM [#VIsitedStores] GROUP BY CovAreaId,CovAreaNodeType
	
	UPDATE #TimeSpentInStore SET TimeSpentInStore_HHMM=RIGHT('00' + CAST(TimeSpentInStore / 3600 AS VARCHAR),2) + ':' + RIGHT('00' + CAST((TimeSpentInStore / 60) % 60 AS VARCHAR),2) + ':' + RIGHT('00' + CAST(TimeSpentInStore % 60 AS VARCHAR),2)
	--SELECT * FROM #TimeSpentInStore
	
	SELECT CovAreaId,CovAreaNodeType,ASMAreaId,ASMAreaNodeType,RouteID,RouteNodeType,StoreID,BatteryLeftStatus,DeviceVisitStartTS,DeviceVisitEndTS,1 AS WorkingType INTO #Wroking 
	FROM [#VIsitedStores]
	--SELECT * FROM [#VIsitedStores] WHERE CovAreaId=7 AND StoreID=92464

	INSERT INTO #Wroking(CovAreaId,CovAreaNodeType,ASMAreaId,ASMAreaNodeType,RouteID,RouteNodeType,StoreID,BatteryLeftStatus,DeviceVisitStartTS,DeviceVisitEndTS,WorkingType)
	SELECT A.CovAreaId,A.CovAreaNodeType,A.ASMAreaId,A.ASMAreaNodeType,A.RouteID,A.RouteNodeType,A.StoreID,A.BatteryStatus,A.VisitStartTS,A.VisitEndTS ,2
	FROM #WorkingForStoreAddition A LEFT OUTER JOIN #Wroking B ON A.StoreId=B.StoreId WHERE B.StoreId IS NULL
	--SELECT * FROM #Wroking WHERE CovAreaId=7
	
	--Order List
	SELECT * INTO #PrdHier FROM VwSFAProductHierarchy

	SELECT R.CovAreaId,R.CovAreaNodeType,R.SOAreaId,R.SOAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.ZoneId,R.ZoneNodeType,R.RegionNodeId,R.RegionNodeType,OM.StoreID,#PrdHier.CategoryNodeID CategoryId,#PrdHier.Category,#PrdHier.SKUNodeId,#PrdHier.SKUNodeType,#PrdHier.SKU,#PrdHier.SKUCode,SUM(Od.OrderQty) OrderQty,SUM(CAST(ROUND((OD.OrderQty * UOMValue)/1000,0) AS FLOAT)) OrderQtyInKG,SUM(CAST(OD.NetLineOrderVal AS FLOAT)) OrderVal,ROUND(SUM(CAST(Od.OrderQty AS FLOAT)/RelConversionUnits),2) OrderInCase INTO [#TMPSales]
	FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
	INNER JOIN #tmpRsltWithFullHierarchy R ON OM.RouteNodeID=R.RouteID AND OM.RouteNodeType=R.RouteNodeType
	INNER JOIN #PrdHier ON OD.ProductID = #PrdHier.SKUNodeId
	LEFT OUTER JOIN tblPrdMstrPackingUnits_ConversionUnits C ON C.SKUId=OD.ProductID AND C.BaseUOMID=3
	WHERE OM.OrderDate=@strDate AND OM.OrderStatusId<>3
	GROUP BY R.CovAreaId,R.CovAreaNodeType,R.SOAreaId,R.SOAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.ZoneId,R.ZoneNodeType,R.RegionNodeId,R.RegionNodeType,OM.StoreID, #PrdHier.CategoryNodeID,#PrdHier.Category,#PrdHier.SKUNodeId, #PrdHier.SKUNodeType, #PrdHier.SKU,#PrdHier.SKUCode



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

	Select CovAreaId,CovAreaNodeType, ISNULL(SUM(OrderQty),0) AS OrderQty,SUM(OrderQtyInKG) OrderQtyInKG,SUM(OrderVal) AS TotOrderVal, COUNT(CAST(SKUNodeId AS VARCHAR)+'-'+ CAST(StoreID AS VARCHAR)) AS TotLinesOrdered,COUNT(DISTINCT StoreID) AS Prod_Call,SUM(OrderInCase) OrderQtyInCase INTO #ForUpdate_CovArea  
	FROM #TMPSales GROUP BY CovAreaId,CovAreaNodeType


	--SELECT * FROM #ForUpdate_CovArea
	

	select A.PersonNodeId,A.PersonNodeType,A.[Datetime] AS DayStartTime,B.ReasonID,R.ReasonDescr INTO #DayStartDetail
	from tblPersonAttendance A INNER JOIN PersonAttReason B oN A.PersonAttendanceID=B.PersonAttendanceID 
	INNER JOIN tblMstrReasonsForNoVisit R ON R.ReasonId=B.ReasonID
	INNER JOIN (SELECT AA.PersonNodeId,MAX(AA.[Datetime]) [Datetime] FROM tblPersonAttendance AA INNER JOIN PersonAttReason BB oN AA.PersonAttendanceID=BB.PersonAttendanceID 
	WHERE BB.ReasonID<>0 AND CAST([Datetime] AS DATE)=@strDate GROUP BY AA.PersonNodeId) C ON A.PersonNodeId=C.PersonNodeId AND A.[Datetime]=C.[Datetime]
	--INNER JOIN tblMstrReasonsForNoVisit M ON B.ReasonID=M.ReasonID
	ORDER BY A.PersonNodeId,B.ReasonID
	--SELECT * FROM #DayStartDetail 

	SELECT DISTINCT P.PersonNodeId,P.DayStartTime,STUFF((SELECT DISTINCT ','  + p1.ReasonDescr 
	FROM #DayStartDetail p1  
	WHERE P.PersonNodeId = p1.PersonNodeId
     FOR XML PATH(''), TYPE  
     ).value('.', 'NVARCHAR(MAX)')  
    ,1,1,'') Activity INTO #DayStartActivity
	FROM #DayStartDetail P GROUP BY P.PersonNodeId,P.DayStartTime
	--SELECT *,FORMAT(DayStartTime,'HH:mm') FROM #DayStartActivity

	Select CovAreaId,CovAreaNodeType, 0 AS MIN_Battery, 0 AS MAX_Battery,CAST(NULL AS TIME) DayStartTime,CAST(NULL AS DATETIME) DayEndTime, MIN(DeviceVisitStartTS) AS Start_Time, MAX(DeviceVisitEndTS) AS End_Time,CAST('' AS VARCHAR(20)) AS WorkingHours,CAST('' AS VARCHAR(20)) AS WorkingHours_FirstVisitMinusDayEnd,MIN(WorkingType) WorkingType,CAST(NULL AS DATETIME) Start_TimeWithDate INTO #BatteryStatus FROM #Wroking
	GROUP BY CovAreaId,CovAreaNodeType

	UPDATE #BatteryStatus SET Start_TimeWithDate=CAST((CAST(@strDate AS VARCHAR) + ' ' + CAST(FORMAT(cast(Start_Time as datetime),'hh:mm:ss') AS VARCHAR)) AS DATETIME)

	UPDATE A SET A.DayStartTime=CAST(C.DayStartTime AS TIME)
	FROM #BatteryStatus A INNER JOIN #tmpRsltWithFullHierarchy B ON A.CovAreaId=B.CovAreaId AND A.CovAreaNodeType=B.CovAreaNodeType
	INNER JOIN #DayStartActivity C ON B.SalesmanNodeId=C.PersonNodeId

	UPDATE #BatteryStatus SET DayStartTime=Start_Time WHERE DayStartTime IS NULL

	SELECT B.SalesmanNodeId,MAX(A.EndTime) DayEndTime INTO #DayEndDetails
	FROM tblDayEndDetails A INNER JOIN #tmpRsltWithFullHierarchy B ON A.PersonId=B.SalesmanNodeId
	WHERE ForDate=@strDate AND CAST(ForDate AS DATE)=CAST(A.EndTime AS DATE) GROUP BY B.SalesmanNodeId
	--SELECT * FROM #DayEndDetails ORDER BY SalesmanNodeId

	UPDATE A SET A.DayEndTime=C.DayEndTime --CAST(C.DayEndTime AS TIME)
	FROM #BatteryStatus A INNER JOIN #tmpRsltWithFullHierarchy B ON A.CovAreaId=B.CovAreaId AND A.CovAreaNodeType=B.CovAreaNodeType
	INNER JOIN #DayEndDetails C ON B.SalesmanNodeId=C.SalesmanNodeId

	--SELECT * FROM #BatteryStatus

	UPDATE #BatteryStatus SET WorkingHours=CAST(DATEDIFF(MINUTE,Start_Time,End_Time)/60 AS VARCHAR) + ':' + RIGHT('0' + CAST(CAST(DATEDIFF(MINUTE,Start_Time,End_Time)%60 AS INT) AS VARCHAR),2)

	--SELECT * FROM #BatteryStatus WHERE CovAreaId=153

	--SELECT * FROM #BatteryStatus
	--UPDATE #BatteryStatus SET WorkingHours=CAST(DATEDIFF(MINUTE,DayStartTime,End_Time)/60 AS VARCHAR) + ':' + RIGHT('0' + CAST(CAST(DATEDIFF(MINUTE,DayStartTime,End_Time)%60 AS INT) AS VARCHAR),2)
	
	UPDATE #BatteryStatus SET WorkingHours_FirstVisitMinusDayEnd=CAST(DATEDIFF(MINUTE,Start_TimeWithDate,DayEndTime)/60 AS VARCHAR) + ':' + RIGHT('0' + CAST(CAST(DATEDIFF(MINUTE,Start_TimeWithDate,DayEndTime)%60 AS INT) AS VARCHAR),2)

	UPDATE #BatteryStatus SET MIN_Battery = BatteryLeftStatus FROM #BatteryStatus INNER JOIN #Wroking ON #Wroking.DeviceVisitStartTS = Start_Time
	UPDATE #BatteryStatus SET MAX_Battery = BatteryLeftStatus FROM #BatteryStatus INNER JOIN #Wroking ON #Wroking.DeviceVisitEndTS = End_Time
	--SELECT *,CAST(@strDate AS VARCHAR),CAST(Start_Time AS VARCHAR),FORMAT(cast(Start_Time as datetime),'HH:mm:ss'),CAST((CAST(@strDate AS VARCHAR) + ' ' + CAST(FORMAT(cast(Start_Time as datetime),'hh:mm:ss') AS VARCHAR)) AS DATETIME) FROM #BatteryStatus

	----Select CovAreaId,CovAreaNodeType, 0 AS MIN_Battery, 0 AS MAX_Battery, MIN(DeviceVisitStartTS) AS Start_Time, MAX(DeviceVisitEndTS) AS End_Time,CAST('' AS VARCHAR(20)) AS WorkingHours INTO #BatteryStatus FROM [#VIsitedStores]
	----GROUP BY CovAreaId,CovAreaNodeType

	----UPDATE #BatteryStatus SET WorkingHours=CAST(DATEDIFF(MINUTE,Start_Time,End_Time)/60 AS VARCHAR) + ':' + CAST(CAST(DATEDIFF(MINUTE,Start_Time,End_Time)%60 AS INT) AS VARCHAR)
	----UPDATE #BatteryStatus SET MIN_Battery = BatteryLeftStatus FROM #BatteryStatus INNER JOIN [#VIsitedStores] ON [#VIsitedStores].DeviceVisitStartTS = Start_Time
	----UPDATE #BatteryStatus SET MAX_Battery = BatteryLeftStatus FROM #BatteryStatus INNER JOIN [#VIsitedStores] ON [#VIsitedStores].DeviceVisitEndTS = End_Time
	--SELECT * FROM #BatteryStatus WHERE CovAreaId=7


	INSERT INTO #Final(RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area],CoverageAreaId,CoverageAreaNodeType,CoverageArea, SalesmanNodeId,SalesmanNodeType,Salesman)
	SELECT DISTINCT ZoneId,ZoneNodeType,Zone,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea,SalesmanNodeId,SalesmanNodeType, Salesman
	FROM #tmpRsltWithFullHierarchy WHERE ISNULL(RouteId,0)>0
		
	UPDATE A SET A.[Day Start Time]=FORMAT(B.DayStartTime,'HH:mm'),A.Activity=B.Activity
	FROM #Final A INNER JOIN #DayStartActivity B ON A.SalesmanNodeId=B.PersonNodeId
	
	UPDATE A SET A.[Day End Time]=CASE WHEN CAST(B.DayEndTime AS DATE)=@strDate THEN FORMAT(B.DayEndTime,'HH:mm') ELSE FORMAT(B.DayEndTime,'dd-MMM HH:mm') END FROM #Final A INNER JOIN #DayEndDetails B ON A.SalesmanNodeId=B.SalesmanNodeId
	
	UPDATE A SET A.WorkingHours_FirstVisitMinusDayEnd=B.WorkingHours_FirstVisitMinusDayEnd FROM #Final A INNER JOIN #BatteryStatus B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType

	UPDATE A 
	SET [Start Time] = CASE WHEN DATEPART(hh,Start_Time)<10 THEN '0'+ CAST(DATEPART(hh,Start_Time) AS VARCHAR)  ELSE CAST(DATEPART(hh,Start_Time) AS VARCHAR) End+':'+					CASE WHEN DATEPART(mi,Start_Time)<10 THEN '0'+ CAST(DATEPART(mi,Start_Time) AS VARCHAR) ELSE CAST(DATEPART(mi,Start_Time) AS VARCHAR) End+'						Bt@'+CAST(MIN_Battery AS VARCHAR),
		[End Time] = CASE WHEN DATEPART(hh,end_Time)<10 THEN '0'+ CAST(DATEPART(hh,end_Time) AS VARCHAR) ELSE CAST(DATEPART(hh,end_Time) AS VARCHAR) End+':'+
						CASE WHEN DATEPART(mi,end_Time)<10 THEN '0'+ CAST(DATEPART(mi,end_Time) AS VARCHAR) ELSE CAST(DATEPART(mi,end_Time) AS VARCHAR) End+' Bt@'+CAST(MAX_Battery AS VARCHAR),
		[Working Hours]=B.WorkingHours
	FROM #Final A INNER JOIN #BatteryStatus B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType AND B.WorkingType=1
	
	UPDATE A 
	SET [Start Time] = CASE WHEN DATEPART(hh,Start_Time)<10 THEN '0'+ CAST(DATEPART(hh,Start_Time) AS VARCHAR)  ELSE CAST(DATEPART(hh,Start_Time) AS VARCHAR) End+':'+				 CASE WHEN DATEPART(mi,Start_Time)<10 THEN '0'+ CAST(DATEPART(mi,Start_Time) AS VARCHAR) ELSE CAST(DATEPART(mi,Start_Time) AS VARCHAR) End,
		[End Time] = CASE WHEN DATEPART(hh,end_Time)<10 THEN '0'+ CAST(DATEPART(hh,end_Time) AS VARCHAR) ELSE CAST(DATEPART(hh,end_Time) AS VARCHAR) End+':'+
					CASE WHEN DATEPART(mi,end_Time)<10 THEN '0'+ CAST(DATEPART(mi,end_Time) AS VARCHAR) ELSE CAST(DATEPART(mi,end_Time) AS VARCHAR) End,
		[Working Hours]=B.WorkingHours
	FROM #Final A INNER JOIN #BatteryStatus B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType AND B.WorkingType=2 AND ISNULL(A.[Start Time],'')=''
	
	UPDATE  #Final SET [Time Spent in Store] = #TimeSpentInStore.TimeSpentInStore_HHMM
	FROM #Final INNER JOIN #TimeSpentInStore ON #TimeSpentInStore.CovAreaId = #Final.CoverageAreaId AND #TimeSpentInStore.CovAreaNodeType = #Final.CoverageAreaNodeType 

	UPDATE #Final SET [Stores Added^Total] = AA.TotStoresAdded
	FROM #Final  INNER JOIN (Select CovAreaId,CovAreaNodeType,COUNT(DISTINCT StoreID) AS TotStoresAdded FROM #StoreList GROUP BY CovAreaId,CovAreaNodeType) AS AA ON #Final.CoverageAreaId = AA.CovAreaId AND #Final.CoverageAreaNodeType=AA.CovAreaNodeType 

	UPDATE #Final SET [Stores Added^Today] = AA.TotStoresAdded
	FROM #Final  INNER JOIN (Select CovAreaId,CovAreaNodeType,COUNT(DISTINCT StoreID) AS TotStoresAdded FROM #StoreList WHERE AddedToday=1 GROUP BY CovAreaId,CovAreaNodeType) AS AA ON #Final.CoverageAreaId = AA.CovAreaId AND #Final.CoverageAreaNodeType=AA.CovAreaNodeType 

	UPDATE #Final SET [Calls^Target] = AA.TargetCalls
	FROM #Final  INNER JOIN (Select CovAreaId,CovAreaNodeType,COUNT(DISTINCT StoreID) AS TargetCalls FROM #Target GROUP BY CovAreaId,CovAreaNodeType) AS AA ON #Final.CoverageAreaId = AA.CovAreaId AND #Final.CoverageAreaNodeType=AA.CovAreaNodeType 

	UPDATE #Final SET [Calls^Actual] = AA.Actual 
	FROM #Final INNER JOIN (Select CovAreaId,CovAreaNodeType,COUNT(DISTINCT StoreID) AS Actual FROM [#VIsitedStores] GROUP BY CovAreaId,CovAreaNodeType) AS AA ON #Final.CoverageAreaId = AA.CovAreaId AND #Final.CoverageAreaNodeType=AA.CovAreaNodeType 

	PRINT 'Grv'
	SELECT DISTINCT A.PersonNodeID INTO #SalesmanMarkedNotWorking
	FROM tblPersonAttendance A INNER JOIN PersonAttReason B ON A.PersonAttendanceID=B.PersonAttendanceID INNER JOIN tblMstrReasonsForNoVisit C ON B.ReasonID=C.ReasonId
	WHERE CAST(A.[Datetime] AS DATE)=@strDate AND C.flgNoVisitOption=1
	--SELECT * FROM #SalesmanMarkedNotWorking

	UPDATE A SET A.flgMarkedNotWorking=1 FROM #Final A INNER JOIN #SalesmanMarkedNotWorking B ON A.SalesmanNodeId=B.PersonNodeID

	--UPDATE A SET A.[Calls^Target]=0 FROM #Final A INNER JOIN (SELECT CoverageAreaId,CoverageAreaNodeType FROM #Final WHERE flgMarkedNotWorking=1 GROUP BY CoverageAreaId,CoverageAreaNodeType HAVING SUM([Calls^Actual])=0) B ON A.CoverageAreaId=B.CoverageAreaId AND A.CoverageAreaNodeType=B.CoverageAreaNodeType
	--SELECT * FROM #ForUpdate_CovArea
	UPDATE  #Final SET [Calls^Productive]=Prod_Call,[Total Sales^Dstr] = #ForUpdate_CovArea.Prod_Call,[Total Sales^Lines Ordered]=#ForUpdate_CovArea.TotLinesOrdered,[Total Sales^Qty In KG]=#ForUpdate_CovArea.OrderQtyInKG,[Total Sales^Qty In Cases]=#ForUpdate_CovArea.OrderQtyInCase,
	[Total Sales^Value] = ROUND(ISNULL(#ForUpdate_CovArea.TotOrderVal,0),2), [Total Sales^Lines/Bill] =CASE ISNULL(#ForUpdate_CovArea.Prod_Call,0) WHEN 0 THEN NULL ELSE ROUND(#ForUpdate_CovArea.TotLinesOrdered/CAST(#ForUpdate_CovArea.Prod_Call AS FLOAT),2) END
	FROM #Final INNER JOIN #ForUpdate_CovArea ON #ForUpdate_CovArea.CovAreaId = #Final.CoverageAreaId AND #ForUpdate_CovArea.CovAreaNodeType = #Final.CoverageAreaNodeType

	DELETE FROM #Final WHERE ISNULL([Stores Added^Total],0)=0 AND ISNULL([Calls^Target],0)=0 AND ISNULL([Calls^Actual],0)=0

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

		SELECT @strSQL='ALTER TABLE #Final ADD [Order Qty In KG^' + @Category + '$2|5F8B41~80B45C] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @strSQL='ALTER TABLE #Final ADD [Order Qty In Case^' + @Category + '$2|5F8B41~80B45C] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @strSQL='UPDATE A SET A.[Order Qty In KG^' + @Category + '$2|5F8B41~80B45C]=ROUND(B.OrderQtyInKG,2),A.[Order Qty In Case^' + @Category + '$2|5F8B41~80B45C]=ROUND(B.OrderInCase,2)
		
		FROM #Final A INNER JOIN (SELECT CovAreaId,CovAreaNodeType,SUM(OrderQtyInKG) OrderQtyInKG,SUM(OrderInCase) OrderInCase FROM #TMPSales WHERE CategoryId=' + CAST(@CatNodeId AS VARCHAR) + ' GROUP BY CovAreaId,CovAreaNodeType) B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @StrCategory= @StrCategory + ',[Order Qty In KG^' + @Category + '$2|5F8B41~80B45C]' + ',[Order Qty In Case^' + @Category + '$2|5F8B41~80B45C]'
		SELECT @StrCategoryForGrouping=@StrCategoryForGrouping +  ',SUM([Order Qty In KG^' + @Category + '$2|5F8B41~80B45C])' +  ',SUM([Order Qty In Case^' + @Category + '$2|5F8B41~80B45C])'
		SELECT @Counter+=1
	END
	--SELECT * FROM #Final
	--RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area]
	IF EXISTS(SELECT 1 FROM #Final)
	BEGIN
		--INSERT INTO #Final(flg,flgGrouping,RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area],CoverageAreaId,[Stores Added^Total],[Stores Added^Today],[Calls^Target],[Calls^Actual],[Calls^Productive],[Total Sales^Dstr],[Total Sales^Lines Ordered],[Total Sales^Qty In Pcs],[Total Sales^Value],[Total Sales^Lines/Bill])
		--SELECT 0,'2,12',RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area] + ' Total',0,SUM([Stores Added^Total]),SUM([Stores Added^Today]),SUM([Calls^Target]),SUM([Calls^Actual]),SUM([Calls^Productive]),SUM([Total Sales^Dstr]),SUM([Total Sales^Lines Ordered]),SUM([Total Sales^Qty In Pcs]),SUM([Total Sales^Value]),CASE ISNULL(SUM([Calls^Productive]),0) WHEN 0 THEN NULL ELSE ROUND(SUM([Total Sales^Lines Ordered])/CAST(SUM([Calls^Productive]) AS FLOAT),2) END
		--FROM #Final WHERE CoverageAreaId>0
		--GROUP BY RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area]

		SELECT @strSQL='INSERT INTO #Final(flg,Lvl,flgGrouping,RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,CoverageAreaId,[Stores Added^Total],[Stores Added^Today],[Calls^Target],[Calls^Actual],[Calls^Productive],[Total Sales^Dstr],[Total Sales^Lines Ordered],[Total Sales^Qty In KG],[Total Sales^Qty In Cases],[Total Sales^Value],[Total Sales^Lines/Bill]' + @StrCategory + ')
		SELECT 0,1,''1,9'',RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area] + '' Total'',0,0,SUM([Stores Added^Total]),SUM([Stores Added^Today]),SUM([Calls^Target]),SUM([Calls^Actual]),SUM([Calls^Productive]),SUM([Total Sales^Dstr]),SUM([Total Sales^Lines Ordered]),SUM([Total Sales^Qty In KG]),SUM([Total Sales^Qty In Cases]),SUM([Total Sales^Value]),CASE ISNULL(SUM([Calls^Productive]),0) WHEN 0 THEN NULL ELSE ROUND(SUM([Total Sales^Lines Ordered])/CAST(SUM([Calls^Productive]) AS FLOAT),2) END' + @StrCategoryForGrouping + '
		FROM #Final WHERE CoverageAreaId>0 GROUP BY RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area]'
		PRINT @strSQL
		EXEC(@strSQL)

		UPDATE A SET A.flgHide=1 FROM #Final A INNER JOIN (SELECT ASMAreaId,ASMAreaNodeType FROM #Final WHERE ISNULL(SOAreaId,0)>0 GROUP BY ASMAreaId,ASMAreaNodeType HAVING COUNT(DISTINCT SOAreaId)=1) B ON A.ASMAreaId=B.ASMAreaId AND A.ASMAreaNodeType=B.ASMAreaNodeType AND A.Lvl=1

		SELECT @strSQL='INSERT INTO #Final(flg,Lvl,flgGrouping,RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,SOAreaId,CoverageAreaId,[Stores Added^Total],[Stores Added^Today],[Calls^Target],[Calls^Actual],[Calls^Productive],[Total Sales^Dstr],[Total Sales^Lines Ordered],[Total Sales^Qty In KG],[Total Sales^Qty In Cases],[Total Sales^Value],[Total Sales^Lines/Bill]' + @StrCategory + ')
		SELECT 0,2,''0,9'',RSMAreaId,RSMAreaNodeType,[RSM Area] + '' Total'',0,0,0,SUM([Stores Added^Total]),SUM([Stores Added^Today]),SUM([Calls^Target]),SUM([Calls^Actual]),SUM([Calls^Productive]),SUM([Total Sales^Dstr]),SUM([Total Sales^Lines Ordered]),SUM([Total Sales^Qty In KG]),SUM([Total Sales^Qty In Cases]),SUM([Total Sales^Value]),CASE ISNULL(SUM([Calls^Productive]),0) WHEN 0 THEN NULL ELSE ROUND(SUM([Total Sales^Lines Ordered])/CAST(SUM([Calls^Productive]) AS FLOAT),2) END' + @StrCategoryForGrouping + '
		FROM #Final WHERE CoverageAreaId>0 GROUP BY RSMAreaId,RSMAreaNodeType,[RSM Area]'
		PRINT @strSQL
		EXEC(@strSQL)

		--UPDATE A SET A.flgHide=1 FROM #Final A INNER JOIN (SELECT RSMAreaId,RSMAreaNodeType FROM #Final WHERE ISNULL(ASMAreaId,0)>0 GROUP BY RSMAreaId,RSMAreaNodeType HAVING COUNT(DISTINCT ASMAreaId)=1) B ON A.RSMAreaId=B.RSMAreaId AND A.RSMAreaNodeType=B.RSMAreaNodeType AND A.Lvl=2

		SELECT @strSQL='INSERT INTO #Final(flg,Lvl,flgGrouping,[RSM Area],RSMAreaId,ASMAreaId,SOAreaId,CoverageAreaId,[Stores Added^Total],[Stores Added^Today],[Calls^Target],[Calls^Actual],[Calls^Productive],[Total Sales^Dstr],[Total Sales^Lines Ordered],[Total Sales^Qty In KG],[Total Sales^Qty In Cases],[Total Sales^Value],[Total Sales^Lines/Bill]' + @StrCategory + ')
		SELECT 1,3,''0,9'',''Grand Total'',0,0,0,0,SUM([Stores Added^Total]),SUM([Stores Added^Today]),SUM([Calls^Target]),SUM([Calls^Actual]),SUM([Calls^Productive]),SUM([Total Sales^Dstr]),SUM([Total Sales^Lines Ordered]),SUM([Total Sales^Qty In KG]),SUM([Total Sales^Qty In Cases])
		
		,SUM([Total Sales^Value]),CASE ISNULL(SUM([Calls^Productive]),0) WHEN 0 THEN NULL ELSE ROUND(SUM([Total Sales^Lines Ordered])/CAST(SUM([Calls^Productive]) AS FLOAT),2) END' + @StrCategoryForGrouping + '
		FROM #Final WHERE CoverageAreaId>0'
		PRINT @strSQL
		EXEC(@strSQL)
	END
	
	

	UPDATE #Final SET [Calls^Productivity %]=CASE [Calls^Actual] WHEN 0 THEN '' ELSE CAST(ROUND(([Calls^Productive]/CAST([Calls^Actual] AS FLOAT))*100,2) AS VARCHAR) + '%' END

	--SELECT * FROM #Final ORDER BY Flg Desc,[RSM Area],[ASM Area],[SO Area],CoverageArea
	--,WorkingHours_FirstVisitMinusDayEnd [Working Hours (Day End - First Visit) (hh:mm)^$2]
	--,CoverageArea [Coverage Area^$1],Salesman [Salesman^$1]
	SELECT @strSQL='SELECT [RSM Area] [RSM Area^$1],[ASM Area] [ASM Area^$1],[SO Area] [SO Area^$1],[Day Start Time] [Day Start Time^$2],Activity [Activity^$1],[Day End Time] [Day End Time^$2],[Start Time] [First Store Visit Time^$2],[End Time] [Last Store Visit Time^$2],[Working Hours] [Working Hours (hh:mm)^$2],[Time Spent in Store] [Time Spent in Store (hh:mm:ss)^$2],[Stores Added^Total] [Stores Added^Total$2|FFD966~FFF2CC],[Stores Added^Today] [Stores Added^Today$2|FFD966~FFF2CC],[Calls^Target] [Callage^Target$2|A9D08E~E2EFDA],[Calls^Actual] [Callage^Actual$2|A9D08E~E2EFDA],[Calls^Productive] [Callage^Productive$2|A9D08E~E2EFDA],[Calls^Productivity %] [Callage^Productivity %$2|A9D08E~E2EFDA],[Total Sales^Dstr] [Total Sales^Dstr$2|A0A0A0~CDCDCD],[Total Sales^Lines Ordered] [Total Sales^Lines Ordered$2|A0A0A0~CDCDCD],ROUND([Total Sales^Qty In KG],2) [Total Sales^Qty In KG$2|A0A0A0~CDCDCD],ROUND([Total Sales^Qty In Cases],2) [Total Sales^Qty In Case$2|A0A0A0~CDCDCD]
	,[Total Sales^Value] [Total Sales^Value$3|A0A0A0~CDCDCD],[Total Sales^Lines/Bill] [Total Sales^Avg LPC$2|A0A0A0~CDCDCD]' + @StrCategory + ',flg [flg],flgGrouping [flgGrouping] ,CoverageAreaId, CoverageAreaNodeType,SalesmanNodeId,SalesmanNodeType
	FROM #Final WHERE flgHide=0 ORDER BY flg DESC,[RSM Area],[ASM Area],[SO Area],CoverageArea'
	PRINT @strSQL
	EXEC(@strSQL)

	SELECT * FROM #ColumnIndexListForFormatting

	SELECt 3 AS NoOfColsToFix

	DECLARE @TotStoresAdded INT=0
	DECLARE @StoresAddedToday INT=0
	DECLARE @TotCalls INT=0
	DECLARE @ProdCalls INT=0
	DECLARE @TotOrderVal INT=0
	--DECLARE @TotStockVal INT=0
	DECLARE @NoOFSKUs INT=0
	DECLARE @NoOFLines INT=0
	DECLARE @TotSalesman INT=0
	DECLARE @NoOfSalesmanInMarket INT=0
	
	SELECT @TotSalesman=COUNT(DISTINCT SalesmanNodeId) FROM #Final WHERE ISNULL(SalesmanNodeId,0)>0
	SELECT @NoOfSalesmanInMarket=COUNT(DISTINCT SalesmanNodeId) FROM #Final WHERE ISNULL([Calls^Actual],0)>0 AND ISNULL(SalesmanNodeId,0)>0
	SELECT @TotCalls=ISNULL(SUM([Calls^Actual]),0),@ProdCalls=ISNULL(SUM([Calls^Productive]),0) FROM #Final WHERE ISNULL([Calls^Actual],0)>0 AND ISNULL(SalesmanNodeId,0)>0

	SELECT @TotOrderVal=ROUND(SUM(OrderVal),0),@NoOFSKUs=COUNT(DISTINCT SKUNodeId),@NoOFLines= COUNT(CAST(SKUNodeId AS VARCHAR)+'-'+ CAST(StoreID AS VARCHAR))
	FROM #TMPSales
	SELECT @TotStoresAdded=COUNT(DISTINCT StoreId) FROM #StoreList
	SELECT @StoresAddedToday=COUNT(DISTINCT StoreId) FROM #StoreList WHERE AddedToday=1

	SELECT ISNULL(@TotStoresAdded,0) [Total Stores Added^E6B8B7],ISNULL(@StoresAddedToday,0) [Stores Added Today^CC6C6A],ISNULL(@TotSalesman,0) [Total Salesman^808080],ISNULL(@NoOfSalesmanInMarket,0) [# Salesman In Market^C7C7C7],ISNULL(@TotCalls,0) [Total Calls Made^8AB96A],ISNULL(@ProdCalls,0) [Productive Calls^9856C9],ISNULL(@TotOrderVal,0) [Total Order Value^D3824B], ISNULL(@NoOFSKUs,0) [# of SKUs Ordered^FFC000],ISNULL(@NoOFLines,0) [Total Lines Ordered^B8AF82] 
	

	
















