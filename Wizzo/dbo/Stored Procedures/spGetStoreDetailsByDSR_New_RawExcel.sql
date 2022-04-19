
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec [spGetStoreDetailsByDSR_NEw_RawExcel]0,0,123,'11-Jan-2022'
CREATE PROCEDURE [dbo].[spGetStoreDetailsByDSR_New_RawExcel]
@SEAreaId INT,
@SEAreaNodeType INT,
@SalesmanId INT,
@Date DATE
AS
BEGIN
	DECLARE @SEArea VARCHAR(200)=''
	CREATE TABLE #RouteList(RouteId INT,RouteNodeType INT,RouteName VARCHAR(200),flgPlanned TINYINT)
	

	--getting the route list under cov area
	IF @SEAreaId>0
	INSERT INTO #RouteList(RouteId,RouteNodeType)
	SELECT DISTINCT  RouteNodeId,RouteNodetype
	FROM tblRoutePlanningVisitDetail(nolock) RP WHERE RP.CovAreaNodeID=@SEAreaId AND RP.CovAreaNodeType=@SEAreaNodeType 
	ELSE
	INSERT INTO #RouteList(RouteId,RouteNodeType)
	SELECT DISTINCT  RouteNodeId,RouteNodetype
	FROM tblRoutePlanningVisitDetail(nolock) RP 

	UPDATE R SET flgPlanned=1 FROM #RouteList R INNER JOIN tblRoutePlanningVisitDetail(nolock) V ON V.RouteNodeId=R.RouteId AND V.RouteNodetype=R.RouteNodeType AND V.VisitDate=@Date


	----SELECT NodeId,NodeType
	----FROM tblCompanySalesStructureHierarchy
	----WHERE PNodeId=@SEAreaId AND PNodeType=@SEAreaNodeType

	UPDATE A SET A.RouteName=B.Descr FROM #RouteList A INNER JOIN tblCompanySalesStructureRouteMstr B ON A.RouteId=B.NodeId AND A.RouteNodeType=NodeType
	--UPDATE A SET A.RouteName=B.Descr FROM #RouteList A INNER JOIN tblDBRSalesStructureRouteMstr B ON A.RouteId=B.NodeId AND A.RouteNodeType=NodeType
	--SELECT * FROM #RouteList

	--geetting all the routes planned for the day
	----SET DATEFirst 1  
	----SELECT DISTINCT @SEAreaId CovAreaId,@SEAreaNodeType CovAreaNodeType,@SEArea AS CovArea,RC.RouteId,RC.NodeType AS RouteNodeType,#RouteList.RouteName AS RouteName,@Date AS RptDate,dbo.[fnGetPlannedVisit](RC.RouteId,RC.NodeType,@Date) AS FlgPlanned INTO #RouteList
	----FROM tblRouteCoverage RC INNER JOIN #RouteList ON RC.RouteId=#RouteList.RouteId AND RC.NodeType=#RouteList.RouteNodeType
	----WHERE (@Date BETWEEN RC.FromDate AND RC.ToDate) AND (DATEPART(dw,@Date)=Weekday)
	------SELECT * FROM #RouteList ORDER BY FlgPlanned
	SET DATEFirst 7
	--DELETE FROM #RouteList WHERE FlgPlanned=0
	--SELECT * FROM #RouteList ORDER BY RouteNodeType,RouteId
	CREATE TABLE #Tmp(VisitDetID INT,StoreId INT,StoreName NVARCHAR(500),VisitLatitude DECIMAL(27,24),VisitLongitude DECIMAL(27,24),
	StartTime TIME,EndTime Time,TimeSpent TIME,LastVisitedStoreEndTime TIME,TimeGAP INT,ActLatCode DECIMAL(27,24),ActLongCode DECIMAL(27,24),DistanceFromOrgPointInM FLOAT,Accuracy FLOAT,DistanceAvailable TINYINT DEFAULT 0 NOT NULL,flgTelephonicCall TINYINT,IsGeoValidated TINYINT,Seq INT)

	--getting the store list for the routes in planned
	CREATE TABLE #Target(ReportDate Date,CovAreaNodeID INT,CovAreaNodeType INT,[Coverage] VARCHAR(200),RouteNodeId INT,RouteNodeType INT,RouteName VARCHAR(200),StoreID INT,StoreName VARCHAR(200),PrcRegionID INT,[Lat Code] NUMERIC(26,22),[Long Code] NUMERIC(26,22),VisitLatitude DECIMAL(27,24),VisitLongitude DECIMAL(27,24),StartTime TIME,TimeSpent TIME,TimeGap VARCHAR(10),flgTargetCall TINYINT,flgActualVisit TINYINT,flgTelephonicVisit TINYINT,flgGeofenceValidated TINYINT,flgProductive TINYINT,flgOffRoute TINYINT DEFAULT 1,OrderID INT,ProductID INT,Category VARCHAR(100),Product VARCHAR(100),[Order(Kg)] DECIMAL(18,2) DEFAULT 0,[Order(Cases)] DECIMAL(18,2) DEFAULT 0,[Order(Pcs)] DECIMAL(18,2) DEFAULT 0, OrderValue DECIMAL(18,2) DEFAULT 0,Distancefrompoint FLOAT,GapfromPrvVisitInSec INT,Accuracy FLOAT,LinesOrdered INT,flgFirstVisit TINYINT)

	INSERT INTO #Target(ReportDate,CovAreaNodeID,CovAreaNodeType,RouteNodeId,RouteNodeType,RouteName,StoreID,StoreName,PrcRegionID,[Lat Code],[Long Code],flgTargetCall)
	SELECT DISTINCT @Date AS ReportDate,@SEAreaId,@SEAreaNodeType,#RouteList.RouteId, #RouteList.RouteNodeType ,#RouteList.RouteName ,AA.StoreID AS StoreID,SM.StoreName,PR.PrcRgnNodeId,SM.[Lat Code],SM.[Long Code],flgPlanned 
	FROM    #RouteList INNER JOIN tblRouteCoverageStoreMapping AA ON #RouteList.RouteID=AA.RouteID AND #RouteList.RouteNodeType=AA.RouteNodeType 
	INNER JOIN tblStoreMaster SM ON AA.StoreId=SM.StoreId
	LEFT OUTER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=SM.DistNodeId AND SM.DistNodeType=DBR.NodeType
	LEFT OUTER JOIN tblPriceRegionMstr PR ON PR.StateID=DBR.StateId
	WHERE (@Date BETWEEN AA.FromDate AND AA.ToDate)

	--SELECT * FROM #Target 

	--getting the visists for the day
	SELECT DISTINCT VD.VisitDetID,VM.VisitId,VM.RouteId,VM.RouteType,VM.StoreId,VM.VisitLatitude,VM.VisitLongitude,VM.FlgOnRoute,VD.VisitStartDate,VD.VisitEndDate,flgTelephonicCall,IsGeoValidated,VM.Accuracy INTO #tblVisitMaster 
	FROM tblVisitMaster VM INNER JOIN tblVisitDet VD ON VD.VisitID=VM.VisitID
	INNER JOIN #Target T ON T.RouteNodeId=VM.RouteID AND T.StoreID=VM.StoreID
	--INNER JOIN #RouteList R ON VM.RouteID=R.RouteID AND VM.RouteType=R.RouteNodeType --AND VM.SalesPersonID=@SalesmanId
	WHERE CONVERT(VARCHAR,VM.VisitDate,112) =CONVERT(VARCHAR, @Date,112) 
	--SELECT * FROM #tblVisitMaster ORDER BY RouteId

	INSERT INTO #Tmp(VisitDetID,StoreId,StoreName,VisitLatitude,VisitLongitude,StartTime,EndTime,TimeSpent,ActLatCode,ActLongCode,flgTelephonicCall,IsGeoValidated,Accuracy,Seq)	
	SELECT DISTINCT VisitDetID,SM.StoreId,SM.StoreName AS StoreName,VM.VisitLatitude,VM.VisitLongitude, VisitStartDate,VisitEndDate,CONVERT(VARCHAR,((CONVERT(DATETIME,VisitEndDate,114) - CONVERT(DATETIME,VisitStartDate,114))),114) AS TimeSpent,SM.[Lat Code],SM.[Long Code],flgTelephonicCall,IsGeoValidated,Accuracy,DENSE_RANK() OVER (ORDER BY VisitStartDate) 
	FROM #tblVisitMaster VM INNER JOIN tblStoreMaster SM ON VM.StoreId=SM.StoreId ORDER BY VisitStartDate
	

	UPDATE T SET LastVisitedStoreEndTime=X.Endtime,TimeGAP=DATEDIFF(SECOND,X.EndTime,Starttime) FROM #TMp T , (SELECT Endtime,Seq FROM #Tmp) X WHERE X.Seq=T.Seq-1

	--SELECT * FROM #Tmp
	
	--UPDATE #Tmp SET #Tmp.ActLatCode=SM.[Lat Code] ,#Tmp.ActLongCode=SM.[Long Code] FROM #Tmp INNER JOIN tblStoreMaster SM ON #Tmp.StoreId=SM.StoreId
	UPDATE #Tmp SET DistanceFromOrgPointInM=ROUND([dbo].[fnCalcDistanceKM](VisitLatitude,ActLatCode,VisitLongitude,ActLongCode) *1000,0) ,DistanceAvailable=1
	WHERE ActLatCode<>0 AND VisitLatitude<>0
	--UPDATE #Tmp SET DistanceFromOrgPointInM='NA' WHERE 	DistanceAvailable=0

	SELECT V.*,C.RelConversionUnits INTO #VwSFAProductHierarchy FROM [VwSFAProductHierarchy] V INNER JOIN tblPrdMstrPackingUnits_ConversionUnits C ON C.SKUId=V.SKUNodeID AND C.BaseUOMID=3
	
	SELECT DISTINCT OM.OrderID,VM.StoreId,V.CategoryNodeID,OD.ProductID,CAST(ROUND((OD.OrderQty * V.UOMValue)/1000,0) AS FLOAT) [Order(Kg)],OrderQty [Order(Pcs)],CAST(ROUND(OrderQty/RelConversionUnits,0) AS FLOAT) [Order(Cases)],CAST(ROUND(OrderQty * P.StandardRate,0) AS FLOAT) [Order(Value)]
	INTO #Orders
	FROM #Target VM
	INNER JOIN tblOrderMaster(nolock) OM On VM.StoreID=OM.StoreID
	INNER JOIN tblOrderDetail(nolock) OD On OM.OrderId=OD.OrderId
	INNER JOIN #VwSFAProductHierarchy V ON V.SKUNodeID=OD.ProductID
	LEFT OUTER JOIN tblPrdSKUSalesMapping(nolock) P ON P.SKUNodeId=V.SKUNodeID AND P.SKUNodeType=V.SKUNodeType AND P.UOMID=3 AND CAST(GETDATE() AS DATE) BETWEEN P.FromDate AND P.ToDate
	AND P.PrcLocationId=VM.PrcRegionID
	WHERE ISNULL(OM.OrderStatusID,0)<>3 AND OM.OrderDate=@Date


	--SELECT * FROM #Target

	--GROUP BY OM.OrderID,VM.StoreId,OD.ProductID,

--CREATE TABLE #Target(ReportDate Date,CovAreaNodeID INT,CovAreaNodeType INT,[Coverage] VARCHAR(200),RouteNodeId INT,RouteNodeType INT,RouteName VARCHAR(200),StoreID INT,StoreName VARCHAR(200),PrcRegionID INT,[Lat Code] NUMERIC(26,22),[Long Code] NUMERIC(26,22),flgTargetCall TINYINT,flgActualVisit TINYINT,flgTelephonicVisit TINYINT,flgGeofenceValidated TINYINT,flgProductive TINYINT,flgOffRoute TINYINT DEFAULT 1,OrderID INT,[Order(Kg)] DECIMAL(18,2) DEFAULT 0,[Order(Cases)] DECIMAL(18,2) DEFAULT 0, OrderValue DECIMAL(18,2) DEFAULT 0,Distancefrompoint FLOAT)
	
	UPDATE T SET flgOffROute=0 FROM #Target T WHERE flgTargetCall=1
	--SELECT * FROM #Tmp WHERE StoreID=113872
	PRINT 'AA'

	--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& Additional Code ToMake an entries of multiple Visits of the stores in the report &&&&&&&&&&&&&&&
	SELECT * INTO #TargetTemp FROM #Target

	--SELECT * FROM #Tmp
	DELETE T FROM #Target T WHERE StoreID IN (SELECT StoreID FROM #Tmp)

	INSERT INTO #Target(ReportDate,CovAreaNodeID,CovAreaNodeType,RouteNodeId,RouteNodeType,RouteName,StoreID,StoreName,PrcRegionID,[Lat Code],[Long Code],flgTargetCall,flgActualVisit,flgTelephonicVisit,flgGeofenceValidated,Distancefrompoint,StartTime,TimeSpent,VisitLatitude,VisitLongitude,Accuracy,flgFirstVisit,TimeGap)

	SELECT T.ReportDate,T.CovAreaNodeID,T.CovAreaNodeType,T.RouteNodeId,T.RouteNodeType,T.RouteName,T.StoreID,T.StoreName,T.PrcRegionID,T.[Lat Code],T.[Long Code],T.flgTargetCall,CASE flgTelephonicCall WHEN 1 THEN 0 ELSE 1 END,          V.flgTelephonicCall,V.IsGeoValidated,V.DistanceFromOrgPointInM,V.StartTime,V.TimeSpent,V.VisitLatitude,V.VisitLongitude,V.Accuracy,DENSE_RANK() OVER (PARTITION BY V.StoreID ORDER BY V.Starttime) Seq,dbo.fnGetTimeStringin_MinSecFormat(V.TimeGap) FROM #TargetTemp T INNER JOIN #Tmp V ON V.StoreId=T.StoreID ORDER BY StartTime

	--SELECT * FROM #Target

	INSERT INTO #Target(ReportDate,CovAreaNodeID,CovAreaNodeType,RouteNodeId,RouteNodeType,RouteName,StoreID,StoreName,PrcRegionID,[Lat Code],[Long Code],flgTargetCall)
	SELECT T.ReportDate,T.CovAreaNodeID,T.CovAreaNodeType,T.RouteNodeId,T.RouteNodeType,T.RouteName,T.StoreID,T.StoreName,T.PrcRegionID,T.[Lat Code],T.[Long Code],T.flgTargetCall FROM #TargetTemp T WHERE StoreID NOT IN (SELECT StoreID FROM #TargetTemp)

	--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	

	----UPDATE T SET flgActualVisit=CASE flgTelephonicCall WHEN 1 THEN 0 ELSE 1 END,flgTelephonicVisit=flgTelephonicCall,flgGeofenceValidated=IsGeoValidated,Distancefrompoint=DistanceFromOrgPointInM,StartTime=V.StartTime,TimeSpent=V.TimeSpent,VisitLatitude=V.VisitLatitude,VisitLongitude=V.VisitLongitude,T.Accuracy=V.Accuracy FROM #Target T INNER JOIN #Tmp V ON V.StoreId=T.StoreID 
	PRINT 'BB'

	UPDATE T SET flgGeofenceValidated=1 FROM #Target T WHERE Distancefrompoint-Accuracy <= 30


	--SELECT * FROM #Target T WHERE flgActualVisit=1
	--UPDATE A SET A.flgProductive=1,A.OrderID=B.OrderID,A.[Order(Cases)]=B.[Order(Cases)],A.[Order(Kg)]=B.[Order(Kg)],A.OrderValue=B.[Order(Value)] FROM #Target A INNER JOIN (SELECT DISTINCT StoreID,OrderID,ProductID,SUM([Order(Value)]) [Order(Value)],SUM([Order(Kg)]) [Order(Kg)],SUM([Order(Cases)]) [Order(Cases)],SUM([Order(Pcs)]) [Order(Pcs)] FROM #Orders GROUP BY StoreID,OrderID,ProductID) B ON A.StoreId=B.StoreId AND A.ProductID=B.ProductID WHERE A.flgFirstVisit=1 --AND A.OrderID=B.OrderID 

	--SELECT * FROM #Target --WHERE StoreID=25751


	DELETE T FROM #Target T WHERE StoreID IN (SELECT StoreID FROM #Target WHERE flgTargetCall=1) AND flgTargetCall=0

	--SELECT * FROM #Target
	SELECT * FROM #Target T

	SELECT T.*,P.Category,O.ProductID,P.SKU,O.[Order(Value)],O.[Order(Kg)],O.[Order(Cases)],O.[Order(Pcs)] FROM #Target T  LEFT OUTER JOIN #Orders O ON O.StoreID=T.StoreID LEFT OUTER JOIN #VwSFAProductHierarchy P ON P.SKUNodeID=O.ProductID

END



