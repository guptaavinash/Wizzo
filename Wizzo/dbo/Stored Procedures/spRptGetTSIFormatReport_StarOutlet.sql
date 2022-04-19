
--EXEC [spRptGetTSIFormatReport_StarOutlet]
CREATE PROC [dbo].[spRptGetTSIFormatReport_StarOutlet]

AS
BEGIN
	DECLARE @strDate DATE=DATEADD(dd,-1,GETDATE())
	PRINT @strDate

	CREATE TABLE #tmpRsltWithFullHierarchy(ZoneId INT,ZoneNodeType INT,Zone VARCHAR(200),RegionNodeId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,Salesman VARCHAR(200),flgActive TINYINT DEFAULT 0 NOT NULL)

	CREATE TABLE #Final(flgHide TINYINT DEFAULT 0 NOT NULL,Lvl TINYINT DEFAULT 0 NOT NULL,flg TINYINT DEFAULT 0 NOT NULL,flgGrouping VARCHAR(10) DEFAULT 0 NOT NULL,RSMAreaId INT,RSMAreaNodeType INT,[RSM Area] VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,[ASM Area] VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,[SO Area] VARCHAR(200),CoverageAreaId INT,CoverageAreaNodeType INT,CoverageArea VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,Salesman VARCHAR(200),[Change Route] VARCHAR(500),[Assigned Route] VARCHAR(500),[GATE Meeting] VARCHAR(50),[PJP follow/not] VARCHAR(50),TC INT DEFAULT 0,PC INT DEFAULT 0, [Total Cases] DECIMAL(18,2),[Total sale in Rs.] BIGINT,[Retailing Time] VARCHAR(10) DEFAULT '',flgMarkedNotWorking TINYINT)
		
	DECLARE @StrColumn VARCHAR(MAX)='', @strColumnSEArea VARCHAR(MAX)=''
		
	INSERT INTO #tmpRsltWithFullHierarchy(ZoneId,ZoneNodeType,Zone,RegionNodeId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea, RouteId,RouteNodeType,Route)
	EXEC [spRptGetFullSalesHierarchyBasedonLogin] 0,0,0,''
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

	DELETE A FROM #tmpRsltWithFullHierarchy A INNER JOIN tblSalesPersonMapping SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType AND (@strDate BETWEEN SP.FromDate AND SP.ToDate) INNER JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID WHERE MP.flgSFAUser<>1
	
	UPDATE A SET A.SalesmanNodeId=MP.NodeId,A.SalesmanNodeType=Mp.NodeType,A.Salesman=ISNULL(MP.Descr,'Vacant')
	FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType AND (@strDate BETWEEN SP.FromDate AND SP.ToDate)
	LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID

	UPDATE A SET A.ASMArea= A.ASMArea + ' (' + ISNULL(MP.Descr,'Vacant') + ')'
	FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping SP ON A.ASMAreaId=SP.NodeId AND A.ASMAreaNodeType=SP.NodeType AND (@strDate BETWEEN SP.FromDate AND SP.ToDate)
	LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID
	--SELECT * FROM #tmpRsltWithFullHierarchy ORDER BY RouteId
		
	/*
	SELECT DISTINCT R.CovAreaId,R.CovAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.RouteId,R.RouteNodetype,RCM.StoreId,0 AS AddedToday INTO #StoreList
	FROM #tmpRsltWithFullHierarchy R INNER JOIN tblRouteCoverageStoreMapping RCM ON R.RouteId=RCM.RouteId AND R.RouteNodetype=RCM.RouteNodetype
	INNER JOIN tblRoutePlanningMstr P ON P.RouteNodeId=RCM.RouteID AND P.RouteNodeType=RCM.RouteNodeType
	INNER JOIN tblStoreMaster SM ON RCM.StoreId=SM.StoreId
	WHERE (@strDate BETWEEN RCM.FromDate AND RCM.ToDate)

	UPDATE A SET A.AddedToday=1
	FROM #StoreList A INNER JOIN tblStoreMaster B ON A.StoreId=B.StoreId
	WHERE CAST(B.CreatedDate AS DATE)=@strDate	
	--SELECT * FROM #StoreList ORDER BY AddedToday desc
	*/

	SELECT DISTINCT R.CovAreaId,R.CovAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.RouteId,R.RouteNodeType,R.Route,@strDate AS RptDate,1 AS FlgPlanned INTO #tmpRoute
	FROM tblRoutePlanningVisitDetail RC INNER JOIN #tmpRsltWithFullHierarchy R ON RC.RouteNodeId=R.RouteId AND RC.RouteNodetype=R.RouteNodeType
	WHERE RC.VisitDate=@strDate
	--SELECT * FROM #tmpRoute ORDER BY RouteNodeType,RouteId
	
	SELECT DISTINCT P.CovAreaId,P.CovAreaNodeType,STUFF((SELECT DISTINCT ','  + p1.Route 
	FROM #tmpRoute p1  
	WHERE P.CovAreaId = p1.CovAreaId AND P.CovAreaNodeType=p1.CovAreaNodeType
     FOR XML PATH(''), TYPE  
     ).value('.', 'NVARCHAR(MAX)')  
    ,1,1,'') PlannedRoute INTO #PlannedRoutes
	FROM #tmpRoute P GROUP BY P.CovAreaId,P.CovAreaNodeType
	--SELECT * FROM #PlannedRoutes ORDER BY CovAreaNodeType,CovAreaId

	SELECT DISTINCT AA.StoreID AS StoreID, #tmpRoute.RouteID, #tmpRoute.RouteNodeType, 1 AS OnRoute,CovAreaId,CovAreaNodeType,ASMAreaId,ASMAreaNodeType INTO #Target
	FROM    #tmpRoute
	INNER JOIN (SELECT RouteID,RouteNodeType,StoreID FROM tblRouteCoverageStoreMapping 
	WHERE (CONVERT(VARCHAR,tblRouteCoverageStoreMapping.FromDate, 112) <= CONVERT(VARCHAR, @strDate, 112)) AND (CONVERT(VARCHAR, ISNULL(tblRouteCoverageStoreMapping.ToDate, @strDate), 112) >= CONVERT(VARCHAR, @strDate, 112))) AA ON #tmpRoute.RouteID=AA.RouteID AND #tmpRoute.RouteNodeType=AA.RouteNodeType 
	INNER JOIN StartOutletDump BB ON AA.StoreID=BB.StoreID
	--SELECT * FROM [#Target] ORDER BY RouteNodeType,RouteId
	
	SELECT DISTINCt B.SalesmanNodeId,B.CovAreaId,B.CovAreaNodeType,A.RequestRouteNodeID,A.RequestRouteNodeType,C.ShortName AS ChangedRoute INTO #ChangedRouteDetails
	FROM tblPDARouteChangeApprovalDetail A INNER JOIN #tmpRsltWithFullHierarchy B ON A.RequestPersonNodeID=B.SalesmanNodeId
	INNER JOIN tblCompanySalesStructureRouteMstr C ON A.RequestRouteNodeID=C.NodeID AND A.RequestRouteNodeType=C.NodeType
	WHERE CAST(A.RequestDatetime AS DATE)=@strDate AND A.flgApprovedOrReject=1
	--SELECT * FROM #ChangedRouteDetails ORDER BY SalesmanNodeId,RequestRouteNodeID

	SELECT DISTINCT P.CovAreaId,P.CovAreaNodeType,STUFF((SELECT DISTINCT ','  + p1.ChangedRoute 
	FROM #ChangedRouteDetails p1  
	WHERE P.CovAreaId = p1.CovAreaId AND P.CovAreaNodeType=p1.CovAreaNodeType
     FOR XML PATH(''), TYPE  
     ).value('.', 'NVARCHAR(MAX)')  
    ,1,1,'') ChangedRoute INTO #ChangedRoutes
	FROM #ChangedRouteDetails P GROUP BY P.CovAreaId,P.CovAreaNodeType
	--SELECT * FROM #ChangedRoutes ORDER BY CovAreaNodeType,CovAreaId

	--Actual Calls
	SELECT R.CovAreaId,R.CovAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,V.VisitId,V.VisitDate,V.RouteID,V.RouteType AS RouteNodeType,V.StoreID,V.BatteryLeftStatus,ISNULL(VD.VisitStartDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitStartTS AS DATETIME)) DeviceVisitStartTS,ISNULL(VD.VisitEndDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitEndTS AS DATETIME)) DeviceVisitEndTS,DATEDIFF(ss,ISNULL(VD.VisitStartDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitStartTS AS DATETIME)) ,ISNULL(VD.VisitEndDate,CAST(V.VisitDate AS DATETIME) + CAST(V.DeviceVisitEndTS AS DATETIME))) TimeSpentInStore,ISNULL(V.EntryPersonNodeId,V.SalesPersonId) SalesmanId INTO [#VIsitedStores]
	FROM tblVisitMaster V LEFT OUTER JOIN tblVisitDet VD ON VD.VisitID=V.VisitID
	INNER JOIN #tmpRsltWithFullHierarchy R ON V.RouteID=R.RouteID AND V.RouteType=R.RouteNodeType
	INNER JOIN StartOutletDump BB ON V.StoreID=BB.StoreID
	WHERE (CONVERT(VARCHAR, V.VisitDate, 112) = CONVERT(VARCHAR, @strDate, 112))   
	ORDER BY V.StoreID
	--SELECT *	FROM [#VIsitedStores] ORDER BY CovAreaId,DeviceVisitStartTS

	DELETE A FROM #tmpRsltWithFullHierarchy A LEFT OUTER JOIN (SELECT DISTINCT CovAreaId,CovAreaNodeType FROM #Target UNION SELECT DISTINCT CovAreaId,CovAreaNodeType FROM [#VIsitedStores]) B ON A.CovAreaId=B.CovAreaId AND A.CovAreaNodeType=B.CovAreaNodeType
	WHERE B.CovAreaId IS NULL AND A.flgActive=0
	
	SELECT CovAreaId,CovAreaNodeType,SUM(TimeSpentInStore) TimeSpentInStore,CAST('' AS VARCHAR(10)) AS TimeSpentInStore_HHMM INTO #TimeSpentInStore 
	FROM [#VIsitedStores] GROUP BY CovAreaId,CovAreaNodeType
	
	UPDATE #TimeSpentInStore SET TimeSpentInStore_HHMM=RIGHT('00' + CAST(TimeSpentInStore / 3600 AS VARCHAR),2) + ':' + RIGHT('00' + CAST((TimeSpentInStore / 60) % 60 AS VARCHAR),2) + ':' + RIGHT('00' + CAST(TimeSpentInStore % 60 AS VARCHAR),2)
	--SELECT * FROM #TimeSpentInStore
	
	--Order List
	SELECT * INTO #PrdHier FROM VwSFAProductHierarchy

	SELECT R.CovAreaId,R.CovAreaNodeType,R.SOAreaId,R.SOAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.ZoneId,R.ZoneNodeType,R.RegionNodeId,R.RegionNodeType,OM.StoreID,#PrdHier.CategoryNodeID CategoryId,#PrdHier.Category,#PrdHier.SKUNodeId,#PrdHier.SKUNodeType,#PrdHier.SKU,#PrdHier.SKUCode,SUM(Od.OrderQty) OrderQty,SUM(CAST(ROUND((OD.OrderQty * UOMValue)/1000,0) AS FLOAT)) OrderQtyInKG,SUM(CAST(OD.NetLineOrderVal AS FLOAT)) OrderVal,ROUND(SUM(CAST(Od.OrderQty AS FLOAT)/RelConversionUnits),2) OrderInCase INTO [#TMPSales]
	FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
	INNER JOIN StartOutletDump BB ON OM.StoreID=BB.StoreID
	INNER JOIN #tmpRsltWithFullHierarchy R ON OM.RouteNodeID=R.RouteID AND OM.RouteNodeType=R.RouteNodeType
	INNER JOIN #PrdHier ON OD.ProductID = #PrdHier.SKUNodeId
	LEFT OUTER JOIN tblPrdMstrPackingUnits_ConversionUnits C ON C.SKUId=OD.ProductID AND C.BaseUOMID=3
	WHERE OM.OrderDate=@strDate AND OM.OrderStatusId<>3
	GROUP BY R.CovAreaId,R.CovAreaNodeType,R.SOAreaId,R.SOAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.ZoneId,R.ZoneNodeType,R.RegionNodeId,R.RegionNodeType,OM.StoreID, #PrdHier.CategoryNodeID,#PrdHier.Category,#PrdHier.SKUNodeId, #PrdHier.SKUNodeType, #PrdHier.SKU,#PrdHier.SKUCode
	--SELECT * FROM [#TMPSales] WHERE CovAreaId=160 ORDER BY CovAreaId,Category,StoreId--,ProductNodeID
	
	Select CovAreaId,CovAreaNodeType, ISNULL(SUM(OrderQty),0) AS OrderQty,SUM(OrderQtyInKG) OrderQtyInKG,SUM(OrderVal) AS TotOrderVal, COUNT(CAST(SKUNodeId AS VARCHAR)+'-'+ CAST(StoreID AS VARCHAR)) AS TotLinesOrdered,COUNT(DISTINCT StoreID) AS Prod_Call,SUM(OrderInCase) OrderQtyInCase INTO #ForUpdate_CovArea  
	FROM #TMPSales GROUP BY CovAreaId,CovAreaNodeType
	--SELECT * FROM #ForUpdate_CovArea WHERE CovAreaId=160 ORDER BY CovAreaId
	

	select A.PersonNodeId,A.PersonNodeType,A.[Datetime] AS DayStartTime,B.ReasonID,R.ReasonDescr,R.flgNoVisitOption INTO #DayStartDetail
	from tblPersonAttendance A INNER JOIN PersonAttReason B oN A.PersonAttendanceID=B.PersonAttendanceID 
	INNER JOIN tblMstrReasonsForNoVisit R ON R.ReasonId=B.ReasonID
	INNER JOIN (SELECT AA.PersonNodeId,MAX(AA.[Datetime]) [Datetime] FROM tblPersonAttendance AA INNER JOIN PersonAttReason BB oN AA.PersonAttendanceID=BB.PersonAttendanceID 
	WHERE BB.ReasonID<>0 AND CAST([Datetime] AS DATE)=@strDate GROUP BY AA.PersonNodeId) C ON A.PersonNodeId=C.PersonNodeId AND A.[Datetime]=C.[Datetime]
	--INNER JOIN tblMstrReasonsForNoVisit M ON B.ReasonID=M.ReasonID
	ORDER BY A.PersonNodeId,B.ReasonID

	--SELECT A.*
	--FROM #DayStartDetail A INNER JOIN #DayStartDetail B ON A.PersonNodeID=B.PersonNodeID
	--WHERE A.flgNoVisitOption=0 AND B.flgNoVisitOption=1
	--SELECT * FROM #DayStartDetail  ORDER By PersonNodeID

	/*
	SELECT DISTINCT P.PersonNodeId,P.DayStartTime,STUFF((SELECT DISTINCT ','  + p1.ReasonDescr 
	FROM #DayStartDetail p1  
	WHERE P.PersonNodeId = p1.PersonNodeId
     FOR XML PATH(''), TYPE  
     ).value('.', 'NVARCHAR(MAX)')  
    ,1,1,'') Activity INTO #DayStartActivity
	FROM #DayStartDetail P GROUP BY P.PersonNodeId,P.DayStartTime
	SELECT *,FORMAT(DayStartTime,'HH:mm') FROM #DayStartActivity
	*/

	INSERT INTO #Final(RSMAreaId,RSMAreaNodeType,[RSM Area],ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area],CoverageAreaId,CoverageAreaNodeType, CoverageArea,SalesmanNodeId,SalesmanNodeType,Salesman)
	SELECT DISTINCT RegionNodeId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea,SalesmanNodeId, SalesmanNodeType,Salesman
	FROM #tmpRsltWithFullHierarchy

	UPDATE A SET A.[Assigned Route]=B.PlannedRoute FROM #Final A INNER JOIN #PlannedRoutes B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType
	UPDATE A SET A.[Change Route]=B.ChangedRoute FROM #Final A INNER JOIN #ChangedRoutes B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType
	
	UPDATE  #Final SET [Retailing Time] = #TimeSpentInStore.TimeSpentInStore_HHMM
	FROM #Final INNER JOIN #TimeSpentInStore ON #TimeSpentInStore.CovAreaId = #Final.CoverageAreaId AND #TimeSpentInStore.CovAreaNodeType = #Final.CoverageAreaNodeType 

	--UPDATE #Final SET [Calls^Target] = AA.TargetCalls
	--FROM #Final  INNER JOIN (Select CovAreaId,CovAreaNodeType,COUNT(DISTINCT StoreID) AS TargetCalls FROM #Target GROUP BY CovAreaId,CovAreaNodeType) AS AA ON #Final.CoverageAreaId = AA.CovAreaId AND #Final.CoverageAreaNodeType=AA.CovAreaNodeType 

	UPDATE #Final SET TC = AA.Actual 
	FROM #Final INNER JOIN (Select CovAreaId,CovAreaNodeType,COUNT(DISTINCT StoreID) AS Actual FROM [#VIsitedStores] GROUP BY CovAreaId,CovAreaNodeType) AS AA ON #Final.CoverageAreaId = AA.CovAreaId AND #Final.CoverageAreaNodeType=AA.CovAreaNodeType 

	PRINT 'Grv'
	UPDATE A SET A.flgMarkedNotWorking=1 FROM #Final A INNER JOIN #DayStartDetail B ON A.SalesmanNodeId=B.PersonNodeID WHERE B.flgNoVisitOption=1
	UPDATE A SET A.[Assigned Route]='Leave',A.[GATE Meeting]='Leave',A.[PJP follow/not]='Leave' 
	FROM #Final A INNER JOIN #DayStartDetail B ON A.SalesmanNodeId=B.PersonNodeID WHERE B.ReasonID=1

	--UPDATE A SET A.[Calls^Target]=0 FROM #Final A INNER JOIN (SELECT CoverageAreaId,CoverageAreaNodeType FROM #Final WHERE flgMarkedNotWorking=1 GROUP BY CoverageAreaId,CoverageAreaNodeType HAVING SUM([Calls^Actual])=0) B ON A.CoverageAreaId=B.CoverageAreaId AND A.CoverageAreaNodeType=B.CoverageAreaNodeType
	--SELECT * FROM #ForUpdate_CovArea
	UPDATE  #Final SET PC = #ForUpdate_CovArea.Prod_Call,[Total Cases]=#ForUpdate_CovArea.OrderQtyInCase,[Total sale in Rs.]=ROUND(ISNULL(#ForUpdate_CovArea.TotOrderVal,0),2)
	FROM #Final INNER JOIN #ForUpdate_CovArea ON #ForUpdate_CovArea.CovAreaId = #Final.CoverageAreaId AND #ForUpdate_CovArea.CovAreaNodeType = #Final.CoverageAreaNodeType

	UPDATE A SET A.[PJP follow/not]='Yes'
	FROM #Final A INNER JOIN (SELECT DISTINCT V.CovAreaId,V.CovAreaNodeType FROM #VIsitedStores V INNER JOIN #tmpRoute R ON V.RouteID=R.RouteId AND V.RouteNodeType=R.RouteNodeType) B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType

	--UPDATE #Final SET [PJP follow/not]='No' WHERE ISNULL([PJP follow/not],'')='' AND (TC>0 or ISNULL([Assigned Route],'')<>'')
	UPDATE #Final SET [PJP follow/not]='No' WHERE ISNULL([PJP follow/not],'')='' AND TC>0

	UPDATE A SET A.[GATE Meeting]='Yes' FROM #Final A INNER JOIN (SELECT PersonNodeID FROM tblGateMeetingTarget WHERE DataDate=@strDate) B ON A.SalesmanNodeId=B.PersonNodeID
	UPDATE #Final SET [GATE Meeting]='No' WHERE ISNULL([GATE Meeting],'')='' AND ISNULL([Assigned Route],'')<>''

	DELETE FROM #Final WHERE ISNULL([Assigned Route],'')='' AND ISNULL([Change Route],'')='' AND ISNULL(TC,0)=0 AND ISNULL(PC,0)=0
	--SELECT * FROM #Final ORDER BY CoverageAreaNodeType,CoverageAreaId

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

		SELECT @strSQL='ALTER TABLE #Final ADD [Cases^' + @Category + '$2] DECIMAL(18,2)'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @strSQL='UPDATE A SET A.[Cases^' + @Category + '$2]=ROUND(B.OrderInCase,2)		
		FROM #Final A INNER JOIN (SELECT CovAreaId,CovAreaNodeType,SUM(OrderInCase) OrderInCase FROM #TMPSales WHERE CategoryId=' + CAST(@CatNodeId AS VARCHAR) + ' GROUP BY CovAreaId,CovAreaNodeType) B ON A.CoverageAreaId=B.CovAreaId AND A.CoverageAreaNodeType=B.CovAreaNodeType'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @StrCategory= @StrCategory + ',[Cases^' + @Category + '$2]'
		SELECT @StrCategoryForGrouping=@StrCategoryForGrouping +  ',SUM([Cases^' + @Category + '$2])' +  ''
		SELECT @Counter+=1
	END
	
	--SELECT * FROM #Final ORDER BY Flg Desc,[RSM Area],[ASM Area],[SO Area],CoverageArea
	SELECT @strSQL='SELECT [ASM Area] [ASM Area^$1],[SO Area] [TSI Area^$1],[Change Route] [Change Route^$1],[Assigned Route] [Assigned Route^$1],[GATE Meeting] [GATE Meeting^$2],[PJP follow/not] [PJP follow/not^$2],[TC] [TC^$2],[PC] [PC^$2]' + @StrCategory + ',[Total Cases] [Total Cases^$2],[Total sale in Rs.] [Total sale in Rs.^$3],[Retailing Time] [Retailing Time^$2]
	FROM #Final WHERE flgHide=0 ORDER BY flg DESC,[RSM Area],[ASM Area],[SO Area]'
	PRINT @strSQL
	EXEC(@strSQL)

	SELECT FORMAT(@strDate,'dd-MMM-yyy') AS strDate
END