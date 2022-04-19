
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec [spGetStoreDetailsByDSR_NEw_1]92,130,117,'21-Dec-2021'
CREATE PROCEDURE [dbo].[spGetStoreDetailsByDSR_New_1]
@SEAreaId INT,
@SEAreaNodeType INT,
@SalesmanId INT,
@Date DATE
AS
BEGIN
	DECLARE @SEArea VARCHAR(200)=''
	CREATE TABLE #RouteList(RouteId INT,RouteNodeType INT,RouteName VARCHAR(200),flgPlanned TINYINT)
	

	IF @SEAreaNodeType=130
		SELECT @SEArea=Descr FROM tblCompanySalesStructureCoverage WHERE NodeId=@SEAreaId
	ELSE IF @SEAreaNodeType=160
		SELECT @SEArea=Descr FROM tblDBRSalesStructureCoverage WHERE NodeId=@SEAreaId

	--getting the route list under cov area
	INSERT INTO #RouteList(RouteId,RouteNodeType,flgPlanned)
	SELECT DISTINCT  RouteNodeId,RouteNodetype,CASE WHEN VisitDate=@Date THEN 1 ELSE 0 END
	FROM tblRoutePlanningVisitDetail RP WHERE RP.CovAreaNodeID=@SEAreaId AND RP.CovAreaNodeType=@SEAreaNodeType 


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
	CREATE TABLE #Tmp(StoreId INT,StoreName NVARCHAR(500),VisitLatitude DECIMAL(27,24),VisitLongitude DECIMAL(27,24),
	StartTime TIME,TimeSpent TIME,ActLatCode DECIMAL(27,24),ActLongCode DECIMAL(27,24),DistanceFromOrgPointInM FLOAT,Accuracy FLOAT,DistanceAvailable TINYINT DEFAULT 0 NOT NULL,flgTelephonicCall TINYINT,IsGeoValidated TINYINT)

	--getting the store list for the routes in planned
	CREATE TABLE #Target(ReportDate Date,CovAreaNodeID INT,CovAreaNodeType INT,[Coverage] VARCHAR(200),RouteNodeId INT,RouteNodeType INT,RouteName VARCHAR(200),StoreID INT,StoreName VARCHAR(200),PrcRegionID INT,[Lat Code] NUMERIC(26,22),[Long Code] NUMERIC(26,22),VisitLatitude DECIMAL(27,24),VisitLongitude DECIMAL(27,24),StartTime TIME,TimeSpent TIME,flgTargetCall TINYINT,flgActualVisit TINYINT,flgTelephonicVisit TINYINT,flgGeofenceValidated TINYINT,flgProductive TINYINT,flgOffRoute TINYINT DEFAULT 1,OrderID INT,[Order(Kg)] DECIMAL(18,2) DEFAULT 0,[Order(Cases)] DECIMAL(18,2) DEFAULT 0, OrderValue DECIMAL(18,2) DEFAULT 0,Distancefrompoint FLOAT,Accuracy FLOAT,LinesOrdered INT)

	INSERT INTO #Target(ReportDate,CovAreaNodeID,CovAreaNodeType,RouteNodeId,RouteNodeType,RouteName,StoreID,StoreName,PrcRegionID,[Lat Code],[Long Code],flgTargetCall)
	SELECT DISTINCT @Date AS ReportDate,@SEAreaId,@SEAreaNodeType,#RouteList.RouteId, #RouteList.RouteNodeType ,#RouteList.RouteName ,AA.StoreID AS StoreID,SM.StoreName,PR.PrcRgnNodeId,SM.[Lat Code],SM.[Long Code],flgPlanned 
	FROM    #RouteList INNER JOIN tblRouteCoverageStoreMapping AA ON #RouteList.RouteID=AA.RouteID AND #RouteList.RouteNodeType=AA.RouteNodeType 
	INNER JOIN tblStoreMaster SM ON AA.StoreId=SM.StoreId
	LEFT OUTER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=SM.DistNodeId AND SM.DistNodeType=DBR.NodeType
	LEFT OUTER JOIN tblPriceRegionMstr PR ON PR.StateID=DBR.StateId
	WHERE (@Date BETWEEN AA.FromDate AND AA.ToDate)

	--SELECT * FROM #Target 

	--getting the visists for the day
	SELECT DISTINCT VM.VisitId,VM.RouteId,VM.RouteType,VM.StoreId,VM.VisitLatitude,VM.VisitLongitude,VM.FlgOnRoute,VM.DeviceVisitStartTS,VM.DeviceVisitEndTS,flgTelephonicCall,IsGeoValidated,VM.Accuracy INTO #tblVisitMaster 
	FROM tblVisitMaster VM 
	INNER JOIN #Target T ON T.RouteNodeId=VM.RouteID AND T.StoreID=VM.StoreID
	--INNER JOIN #RouteList R ON VM.RouteID=R.RouteID AND VM.RouteType=R.RouteNodeType --AND VM.SalesPersonID=@SalesmanId
	WHERE CONVERT(VARCHAR,VM.VisitDate,112) =CONVERT(VARCHAR, @Date,112) 
	--SELECT * FROM #tblVisitMaster ORDER BY RouteId

	INSERT INTO #Tmp(StoreId,StoreName,VisitLatitude,VisitLongitude,StartTime,TimeSpent,ActLatCode,ActLongCode,flgTelephonicCall,IsGeoValidated,Accuracy)	
	SELECT DISTINCT SM.StoreId,SM.StoreName AS StoreName,VM.VisitLatitude,VM.VisitLongitude, DeviceVisitStartTS AS StartTime, CONVERT(VARCHAR,((CONVERT(DATETIME,DeviceVisitEndTS,114) - CONVERT(DATETIME,DeviceVisitStartTS,114))),114) AS TimeSpent,SM.[Lat Code],SM.[Long Code],flgTelephonicCall,IsGeoValidated,Accuracy
	FROM #tblVisitMaster VM INNER JOIN tblStoreMaster SM ON VM.StoreId=SM.StoreId	
	--SELECT * FROM #Tmp
	
	--UPDATE #Tmp SET #Tmp.ActLatCode=SM.[Lat Code] ,#Tmp.ActLongCode=SM.[Long Code] FROM #Tmp INNER JOIN tblStoreMaster SM ON #Tmp.StoreId=SM.StoreId
	UPDATE #Tmp SET DistanceFromOrgPointInM=ROUND([dbo].[fnCalcDistanceKM](VisitLatitude,ActLatCode,VisitLongitude,ActLongCode) *1000,0) ,DistanceAvailable=1
	WHERE ActLatCode<>0 AND VisitLatitude<>0
	--UPDATE #Tmp SET DistanceFromOrgPointInM='NA' WHERE 	DistanceAvailable=0

	SELECT V.*,C.RelConversionUnits INTO #VwSFAProductHierarchy FROM [VwSFAProductHierarchy] V INNER JOIN tblPrdMstrPackingUnits_ConversionUnits C ON C.SKUId=V.SKUNodeID AND C.BaseUOMID=3
	
	SELECT DISTINCT OM.OrderID,VM.StoreId,V.CategoryNodeID,OD.ProductID,CAST(ROUND((OD.OrderQty * V.UOMValue)/1000,0) AS FLOAT) [Order(Kg)],CAST(ROUND(OrderQty/RelConversionUnits,0) AS FLOAT) [Order(Cases)],CAST(ROUND(OrderQty * P.StandardRate,0) AS FLOAT) [Order(Value)]
	INTO #Orders
	FROM #Target VM
	INNER JOIN tblOrderMaster OM On VM.StoreID=OM.StoreID
	INNER JOIN tblOrderDetail OD On OM.OrderId=OD.OrderId
	INNER JOIN #VwSFAProductHierarchy V ON V.SKUNodeID=OD.ProductID
	LEFT OUTER JOIN tblPrdSKUSalesMapping P ON P.SKUNodeId=V.SKUNodeID AND P.SKUNodeType=V.SKUNodeType AND P.UOMID=3 AND CAST(GETDATE() AS DATE) BETWEEN P.FromDate AND P.ToDate
	AND P.PrcLocationId=VM.PrcRegionID
	WHERE ISNULL(OM.OrderStatusID,0)<>3 AND OM.OrderDate=@Date


	--SELECT * FROM #Target

	--GROUP BY OM.OrderID,VM.StoreId,OD.ProductID,

--CREATE TABLE #Target(ReportDate Date,CovAreaNodeID INT,CovAreaNodeType INT,[Coverage] VARCHAR(200),RouteNodeId INT,RouteNodeType INT,RouteName VARCHAR(200),StoreID INT,StoreName VARCHAR(200),PrcRegionID INT,[Lat Code] NUMERIC(26,22),[Long Code] NUMERIC(26,22),flgTargetCall TINYINT,flgActualVisit TINYINT,flgTelephonicVisit TINYINT,flgGeofenceValidated TINYINT,flgProductive TINYINT,flgOffRoute TINYINT DEFAULT 1,OrderID INT,[Order(Kg)] DECIMAL(18,2) DEFAULT 0,[Order(Cases)] DECIMAL(18,2) DEFAULT 0, OrderValue DECIMAL(18,2) DEFAULT 0,Distancefrompoint FLOAT)
	
	UPDATE T SET flgOffROute=0 FROM #Target T WHERE flgTargetCall=1
	--SELECT * FROM #Tmp WHERE StoreID=113872
	PRINT 'AA'
	UPDATE T SET flgActualVisit=CASE flgTelephonicCall WHEN 1 THEN 0 ELSE 1 END,flgTelephonicVisit=flgTelephonicCall,flgGeofenceValidated=IsGeoValidated,Distancefrompoint=DistanceFromOrgPointInM,StartTime=V.StartTime,TimeSpent=V.TimeSpent,VisitLatitude=V.VisitLatitude,VisitLongitude=V.VisitLongitude,T.Accuracy=V.Accuracy FROM #Target T INNER JOIN #Tmp V ON V.StoreId=T.StoreID 
	PRINT 'BB'

	UPDATE T SET flgGeofenceValidated=1 FROM #Target T WHERE Distancefrompoint-Accuracy <= 30


	--SELECT * FROM #Target T WHERE flgActualVisit=1
	UPDATE A SET A.flgProductive=1,A.OrderID=B.OrderID,A.[Order(Cases)]=B.[Order(Cases)],A.[Order(Kg)]=B.[Order(Kg)],A.OrderValue=B.[Order(Value)] FROM #Target A INNER JOIN (SELECT DISTINCT StoreID,OrderID,SUM([Order(Value)]) [Order(Value)],SUM([Order(Kg)]) [Order(Kg)],SUM([Order(Cases)]) [Order(Cases)] FROM #Orders GROUP BY StoreID,OrderID) B ON A.StoreId=B.StoreId --AND A.OrderID=B.OrderID

	--SELECT * FROM #Target WHERE StoreID=113872
	
	DECLARE @TargetCall INT,@ActualCall INT,@TelephonicCall INT,@ProductiveCall INT,@ActualOrder FLOAT,@TelephonicOrder FLOAT,@TotalCall INT,@InStoreProd INT,@TelProd INT,@TotOrder FLOAT,@NewStoresAdded INT
	SELECT @TargetCall=COUNT(DISTINCT StoreID) FROM #Target WHERE flgTargetCall=1
	SELECT @TotalCall=COUNT(DISTINCT StoreID) FROM #Target WHERE flgActualVisit=1 OR flgTelephonicVisit=1
	SELECT @ActualCall=COUNT(DISTINCT StoreID) FROM #Target WHERE flgActualVisit=1
	SELECT @ProductiveCall=COUNT(DISTINCT StoreID) FROM #Target WHERE flgProductive=1
	SELECT @InStoreProd=COUNT(DISTINCT StoreID) FROM #Target WHERE flgProductive=1 AND flgActualVisit=1
	SELECT @TelProd=COUNT(DISTINCT StoreID) FROM #Target WHERE flgProductive=1 AND flgActualVisit=0
	SELECT @TelephonicCall=COUNT(DISTINCT StoreID) FROM #Target WHERE flgTelephonicVisit=1
	SELECT @TotOrder=SUM(OrderValue) FROM #Target WHERE flgActualVisit=1 OR flgTelephonicVisit=1
	SELECT @ActualOrder=SUM(OrderValue) FROM #Target WHERE flgActualVisit=1
	SELECT @TelephonicOrder=SUM(OrderValue) FROM #Target WHERE flgTelephonicVisit=1

	SELECT @NewStoresAdded=COUNT(DISTINCT StoreIDDB) FROM tblPDASyncStoreMappingMstr P INNER JOIN #Target T ON T.StoreID=P.OrgStoreId WHERE CAST(P.CreateDate AS DATE)=@Date

	-- CAtegorywise sales data
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
	SELECT DISTINCT CategoryNodeID,Category FROM VwSFAProductHierarchy
	SELECT @MaxCount=Max(RowId) FROM #tmpCatList
	WHILE @Counter<=@MaxCount
	BEGIN
		IF @Counter<>@MaxCount
		BEGIN
			INSERT INTO #ColumnIndexListForFormatting(ColumnIndex,ColorCode)
			SELECT 20+@Counter AS ColumnName,'5F8B41' AS ColorCode
		END

		SELECT @CatNodeId=CategoryNodeId,@Category=Category FROM #tmpCatList WHERE RowId=@Counter

		SELECT @strSQL='ALTER TABLE #Target ADD [Order Qty In KG^' + @Category + '] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @strSQL='UPDATE A SET A.[Order Qty In KG^' + @Category + ']=ROUND(B.OrderQtyInKG,2) FROM #Target A INNER JOIN (SELECT StoreID,SUM([Order(Kg)]) OrderQtyInKG FROM #Orders WHERE CategoryNodeID=' + CAST(@CatNodeId AS VARCHAR) + ' GROUP BY StoreID) B ON A.StoreID=B.StoreID'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @StrCategory= @StrCategory + ',[Order Qty In KG^' + @Category + ']'
		SELECT @StrCategoryForGrouping=@StrCategoryForGrouping +  ',SUM([Order Qty In KG^' + @Category + '])'
		SELECT @Counter+=1
	END
	   	  
	DELETE T FROM #Target T WHERE StoreID IN (SELECT StoreID FROM #Target WHERE flgTargetCall=1) AND flgTargetCall=0

	SELECT @TargetCall TC,CAST(@TotalCall AS VARCHAR) + ' (' + CAST(ISNULL(@ActualCall,0) AS VARCHAR) + '+' + CAST(ISNULL(@TelephonicCall,0) AS VARCHAR) + ')'  [AC (InStore + TelC)],CAST(ISNULL(@ProductiveCall,0) AS VARCHAR) + ' (' + CAST(ISNULL(@InStoreProd,0) AS VARCHAR) + '+' + CAST(ISNULL(@TelProd,0) AS VARCHAR) + ')' [PC (InStoreProd + TelProd)] ,CAST(ISNULL(@TotOrder,0) AS VARCHAR) + ' (' + CAST(ISNULL(@ActualOrder,0) AS VARCHAR) + '+' + CAST(ISNULL(@TelephonicOrder,0) AS VARCHAR) + ')' [TO (AO+TelO)],ISNULL(@NewStoresAdded,0) NewStoresAdded
	
	
	SELECT @StrSQL=''
	SET @StrSQL='SELECT DISTINCT StoreID AS [StoreID^$1],StoreName [StoreName^$1],ISNULL(flgGeofenceValidated,0) flgGeofenceValidated,CAST(DAtepart(hour,StartTime) AS VARCHAR) + '':'' + CAST(DAtepart(minute,StartTime) AS VARCHAR) StartTime, CAST(DATEPART(minute,TimeSpent) AS VARCHAR) + '':'' + CAST(DATEPART(Second,Timespent) AS VARCHAR)  TimeSpent,VisitLatitude,VisitLongitude,CAST(ISNULL(Distancefrompoint,0) AS VARCHAR) + '' M'' Distancefrompoint,ISNULL(flgProductive,0) flgProductive,
	CASE flgActualVisit WHEN 1 THEN 1 ELSE 0 END flgShowMap,CAST(OrderValue AS INT) Sales,[Order(Cases)],CAST([Order(Kg)] AS INT) [Order(Kg)]' + @StrCategory + ',ISNULL(flgActualVisit,0) flgActualVisit,ISNULL(flgTelephonicVisit,0) flgTelephonicVisit,[Lat Code] StoreLatitude,[Long Code] StoreLongitude,flgOffROute
	FROM #Target WHERE flgProductive=1 OR flgTargetCall=1 OR flgActualVisit=1 OR flgTelephonicVisit=1 ORDER BY flgActualVisit DESC,flgTelephonicVisit DESC,StartTime,StoreName'
	PRINT @StrSQL
	EXEC(@StrSQL)

	SELECT * FROM #ColumnIndexListForFormatting

	SELECt 1 AS NoOfColsToFix
	
	--stores in plan but not visited yet
	----SELECT A.* FROM #Target A LEFT OUTER JOIN #Tmp B ON A.StoreId=B.StoreId
	----WHERE A.[lat Code] IS NOT NULL AND B.StoreId IS NULL

	------ ########################## Result set to display the stores in group for similar coordinates ###########################################################
	----CREATE TABLE #TmpStoreGroup(SrNo INT,VisitLatitude DECIMAL(27,24),VisitLongitude DECIMAL(27,24),FlgOnRoute TINYINT,FlagProductive TINYINT DEFAULT 0,StartTime TIME,
	----StoreCount INT,StrStoreID VARCHAR(200))
	----INSERT INTO #TmpStoreGroup(SrNo,VisitLatitude,VisitLongitude,FlgOnRoute,FlagProductive,StoreCount,StartTime,StrStoreID)
	----SELECT RANK() OVER (ORDER BY MIN(StartTime)) AS SrNo,VisitLatitude,VisitLongitude,MIN(FlgOnRoute),MIN(FlagProductive),COUNT(StoreID),MIN(StartTime),
	----abc=STUFF(
	----		(SELECT ',' + CAST(StoreID AS VARCHAR) FROM #Tmp T WHERE T.VisitLatitude=T1.VisitLatitude AND T.VisitLongitude=T1.VisitLongitude FOR XML PATH('')) ,1,1,''
	----	)  
	----FROM #Tmp T1 GROUP BY VisitLatitude,VisitLongitude
	------#########################################################################################################################################################3
	----SELECT * FROM #TmpStoreGroup

	
	


END



