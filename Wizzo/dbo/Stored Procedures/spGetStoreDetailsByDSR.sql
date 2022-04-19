-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec [spGetStoreDetailsByDSR]12,130,12,'24-Jun-2019'
CREATE PROCEDURE [dbo].[spGetStoreDetailsByDSR]
@SEAreaId INT,
@SEAreaNodeType INT,
@SalesmanId INT,
@Date DATE
AS
BEGIN
	DECLARE @SEArea VARCHAR(200)=''
	CREATE TABLE #RouteList(RouteId INT,RouteNodeType INT,RouteName VARCHAR(200))
	CREATE TABLE #Tmp(StoreId INT,StoreName NVARCHAR(500),VisitLatitude DECIMAL(27,24),VisitLongitude DECIMAL(27,24),FlgOnRoute TINYINT,FlagProductive TINYINT DEFAULT 0,
	StartTime TIME,TimeSpent TIME, Inv DECIMAL(18,2) DEFAULT 0, Sales DECIMAL(18,2) DEFAULT 0,ActLatCode DECIMAL(27,24),ActLongCode DECIMAL(27,24),DistanceFromOrgPointInM VARCHAR(20) DEFAULT '' NOT NULL,DistanceAvailable TINYINT DEFAULT 0 NOT NULL,flgIconType TINYINT DEFAULT 0 NOT NULL,StrStoreID BIGINT)

	IF @SEAreaNodeType=130
		SELECT @SEArea=Descr FROM tblCompanySalesStructureCoverage WHERE NodeId=@SEAreaId
	ELSE IF @SEAreaNodeType=160
		SELECT @SEArea=Descr FROM tblDBRSalesStructureCoverage WHERE NodeId=@SEAreaId

	--getting the route list under cov area
	INSERT INTO #RouteList(RouteId,RouteNodeType)
	SELECT NodeId,NodeType
	FROM tblCompanySalesStructureHierarchy
	WHERE PNodeId=@SEAreaId AND PNodeType=@SEAreaNodeType

	UPDATE A SET A.RouteName=B.Descr FROM #RouteList A INNER JOIN tblCompanySalesStructureRouteMstr B ON A.RouteId=B.NodeId AND A.RouteNodeType=NodeType
	--UPDATE A SET A.RouteName=B.Descr FROM #RouteList A INNER JOIN tblDBRSalesStructureRouteMstr B ON A.RouteId=B.NodeId AND A.RouteNodeType=NodeType
	--SELECT * FROM #RouteList

	--geetting all the routes planned for the day
	SET DATEFirst 1  
	SELECT DISTINCT @SEAreaId CovAreaId,@SEAreaNodeType CovAreaNodeType,@SEArea AS CovArea,RC.RouteId,RC.NodeType AS RouteNodeType,#RouteList.RouteName AS RouteName,@Date AS RptDate,dbo.[fnGetPlannedVisit](RC.RouteId,RC.NodeType,@Date) AS FlgPlanned INTO #tmpRoute
	FROM tblRouteCoverage RC INNER JOIN #RouteList ON RC.RouteId=#RouteList.RouteId AND RC.NodeType=#RouteList.RouteNodeType
	WHERE (@Date BETWEEN RC.FromDate AND RC.ToDate) AND (DATEPART(dw,@Date)=Weekday)
	--SELECT * FROM #tmpRoute ORDER BY FlgPlanned
	SET DATEFirst 7
	DELETE FROM #tmpRoute WHERE FlgPlanned=0
	--SELECT * FROM #tmpRoute ORDER BY RouteNodeType,RouteId

	--getting the store list for the routes in planned
	SELECT DISTINCT @Date AS ReportDate,#tmpRoute.CovAreaId AS RouteId,#tmpRoute.CovAreaNodeType AS RouteNodeType,#tmpRoute.CovArea AS [Route],#tmpRoute.RouteId AS BeatId, #tmpRoute.RouteNodeType AS BeatNodeType,#tmpRoute.RouteName AS Beat,AA.StoreID AS StoreID,SM.StoreName,SM.[Lat Code],SM.[Long Code] INTO #Target
	FROM    #tmpRoute INNER JOIN tblRouteCoverageStoreMapping AA ON #tmpRoute.RouteID=AA.RouteID AND #tmpRoute.RouteNodeType=AA.RouteNodeType 
	INNER JOIN tblStoreMaster SM ON AA.StoreId=SM.StoreId
	WHERE (@Date BETWEEN AA.FromDate AND AA.ToDate)
	--SELECT * FROM #Target

	--getting the visists for the day
	SELECT VM.VisitId,VM.RouteId,VM.RouteType,VM.StoreId,VM.VisitLatitude,VM.VisitLongitude,VM.FlgOnRoute,VM.DeviceVisitStartTS,VM.DeviceVisitEndTS INTO #tblVisitMaster 
	FROM tblVisitMaster VM INNER JOIN #RouteList R ON VM.RouteID=R.RouteID AND VM.RouteType=R.RouteNodeType --AND VM.SalesPersonID=@SalesmanId
	WHERE CONVERT(VARCHAR,VM.VisitDate,112) =CONVERT(VARCHAR, @Date,112)
	--SELECT * FROM #tblVisitMaster ORDER BY RouteId

	INSERT INTO #Tmp(StoreId,StoreName,VisitLatitude,VisitLongitude,FlgOnRoute,StartTime,TimeSpent,ActLatCode,ActLongCode,StrStoreID)	
	SELECT DISTINCT SM.StoreId,SM.StoreName AS StoreName,VM.VisitLatitude,VM.VisitLongitude,VM.FlgOnRoute, DeviceVisitStartTS AS StartTime, CONVERT(VARCHAR,((CONVERT(DATETIME,DeviceVisitEndTS,114) - CONVERT(DATETIME,DeviceVisitStartTS,114))),114) AS TimeSpent,SM.[Lat Code],SM.[Long Code],SM.StoreID
	FROM #tblVisitMaster VM INNER JOIN tblStoreMaster SM ON VM.StoreId=SM.StoreId	
	--SELECT * FROM #Tmp
	
	--UPDATE #Tmp SET #Tmp.ActLatCode=SM.[Lat Code] ,#Tmp.ActLongCode=SM.[Long Code] FROM #Tmp INNER JOIN tblStoreMaster SM ON #Tmp.StoreId=SM.StoreId
	UPDATE #Tmp SET DistanceFromOrgPointInM=CAST(ROUND([dbo].[fnCalcDistanceKM](VisitLatitude,ActLatCode,VisitLongitude,ActLongCode) *1000,0) AS VARCHAR) + ' M',DistanceAvailable=1
	WHERE ActLatCode<>0 AND VisitLatitude<>0
	UPDATE #Tmp SET DistanceFromOrgPointInM='NA' WHERE 	DistanceAvailable=0
		
	UPDATE A SET A.Sales=B.Sales FROM #Tmp A INNER JOIN	(SELECT DISTINCT VM.StoreId, SUM(OD.NetLineOrderVal) AS Sales
	FROM #tblVisitMaster VM
	INNER JOIN tblOrderMaster OM On VM.VisitId=OM.VisitId
	INNER JOIN tblOrderDetail OD On OM.OrderId=OD.OrderId
	WHERE ISNULL(OM.OrderStatusID,0)<>3
	GROUP BY VM.StoreId) B ON A.StoreId=B.StoreId

	UPDATE A SET A.FlagProductive=1 FROM #Tmp A WHERE Sales>0	
	--UPDATE A SET A.FlagProductive=2 FROM #Tmp A WHERE Sales=0 AND Inv>0	
	--UPDATE A SET A.FlagProductive=3 FROM #Tmp A WHERE Sales=0 AND Inv=0
	
	UPDATE #tmp SET flgIconType=CASE WHEN FlgOnRoute=1 AND FlagProductive=1 THEN 1 WHEN FlgOnRoute=1 AND FlagProductive=0 THEN 2 WHEN FlgOnRoute=0 AND FlagProductive=1 THEN 3 WHEN FlgOnRoute=0 AND FlagProductive=0 THEN 4 END

	--stores visited
	SELECT  * FROM #Tmp ORDER BY StartTime
	
	--stores in plan but not visited yet
	SELECT A.* FROM #Target A LEFT OUTER JOIN #Tmp B ON A.StoreId=B.StoreId
	WHERE A.[lat Code] IS NOT NULL AND B.StoreId IS NULL

	-- ########################## Result set to display the stores in group for similar coordinates ###########################################################
	CREATE TABLE #TmpStoreGroup(SrNo INT,VisitLatitude DECIMAL(27,24),VisitLongitude DECIMAL(27,24),FlgOnRoute TINYINT,FlagProductive TINYINT DEFAULT 0,StartTime TIME,
	StoreCount INT,StrStoreID VARCHAR(500),flgIconType TINYINT DEFAULT 0 NOT NULL)

	INSERT INTO #TmpStoreGroup(SrNo,VisitLatitude,VisitLongitude,FlgOnRoute,FlagProductive,StoreCount,StartTime,StrStoreID)
	SELECT RANK() OVER (ORDER BY MIN(StartTime)) AS SrNo,VisitLatitude,VisitLongitude,MIN(FlgOnRoute),MIN(FlagProductive),COUNT(StoreID),MIN(StartTime),
	abc=STUFF(
			(SELECT ',' + CAST(StoreID AS VARCHAR) FROM #Tmp T WHERE T.VisitLatitude=T1.VisitLatitude AND T.VisitLongitude=T1.VisitLongitude FOR XML PATH('')) ,1,1,''
		)  
	FROM #Tmp T1 GROUP BY VisitLatitude,VisitLongitude
	--#########################################################################################################################################################3

	UPDATE A SET A.flgIconType=B.flgIconType
	FROM #TmpStoreGroup A INNER JOIN #Tmp B ON B.StrStoreID=A.StrStoreID WHERE A.StoreCount=1

	
	UPDATE A SET A.flgIconType=B.flgIconType
	FROM #TmpStoreGroup A INNER JOIN #Tmp B ON B.VisitLatitude=A.VisitLatitude AND B.VisitLongitude=A.VisitLongitude 
	INNER JOIN (SELECT A.VisitLatitude,A.VisitLongitude,COUNT(DISTINCT B.flgIconType) DistinctIconCount
	FROM #TmpStoreGroup A INNER JOIN #Tmp B ON B.VisitLatitude=A.VisitLatitude AND A.VisitLongitude=B.VisitLongitude WHERE A.StoreCount>1 --AND A.VisitLatitude>0
	GROUP BY A.VisitLatitude,A.VisitLongitude HAVING COUNT(DISTINCT B.flgIconType)=1) C ON C.VisitLatitude=A.VisitLatitude AND C.VisitLongitude=A.VisitLongitude 
	WHERE A.StoreCount>1
	
	UPDATE #TmpStoreGroup SET flgIconType=10 WHERE flgIconType=0

	SELECT * FROM #TmpStoreGroup




END



