
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec [spGetStoreDetailsByDSR_NEw_15Feb2022]194,130,237,'24-Jan-2022'
CREATE PROCEDURE [dbo].[spGetStoreDetailsByDSR_New_15Feb2022]
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
	INSERT INTO #RouteList(RouteId,RouteNodeType)
	SELECT DISTINCT  RouteNodeId,RouteNodetype
	FROM tblRoutePlanningVisitDetail(nolock) RP WHERE RP.CovAreaNodeID=@SEAreaId AND RP.CovAreaNodeType=@SEAreaNodeType 

	UPDATE R SET flgPlanned=1 FROM #RouteList R INNER JOIN tblRoutePlanningVisitDetail V ON V.RouteNodeId=R.RouteId AND V.RouteNodetype=R.RouteNodeType AND V.VisitDate=@Date


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
	CREATE TABLE #Tmp(VisitDetID INT,RouteNodeId INT,RouteNodeType INT,RouteName VARCHAR(200),StoreId INT,StoreName NVARCHAR(500),VisitLatitude DECIMAL(27,24),VisitLongitude DECIMAL(27,24),
	StartTime TIME,EndTime Time,TimeSpent TIME,LastVisitedStoreEndTime TIME,TimeGAP INT,ActLatCode DECIMAL(27,24),ActLongCode DECIMAL(27,24),DistanceFromOrgPointInM FLOAT,Accuracy FLOAT,DistanceAvailable TINYINT DEFAULT 0 NOT NULL,flgTelephonicCall TINYINT,IsGeoValidated TINYINT,Seq INT)

	--getting the store list for the routes in planned
	CREATE TABLE #Target(ReportDate Date,CovAreaNodeID INT,CovAreaNodeType INT,[Coverage] VARCHAR(200),RouteNodeId INT,RouteNodeType INT,RouteName VARCHAR(200),StoreID INT,StoreName VARCHAR(200),PrcRegionID INT,[Lat Code] NUMERIC(26,22),[Long Code] NUMERIC(26,22),VisitLatitude DECIMAL(27,24),VisitLongitude DECIMAL(27,24),StartTime TIME,TimeSpent TIME,TimeGap VARCHAR(10),flgTargetCall TINYINT,flgActualVisit TINYINT,flgTelephonicVisit TINYINT,flgGeofenceValidated TINYINT,flgProductive TINYINT,flgOffRoute TINYINT DEFAULT 1,OrderID INT,[Order(Kg)] DECIMAL(18,2) DEFAULT 0,[Order(Cases)] DECIMAL(18,2) DEFAULT 0,[Order(Pcs)] DECIMAL(18,2) DEFAULT 0, OrderValue DECIMAL(18,2) DEFAULT 0,Distancefrompoint FLOAT,GapfromPrvVisitInSec INT,Accuracy FLOAT,LinesOrdered INT,flgFirstVisit TINYINT,VisitedRoute VARCHAR(200))

	INSERT INTO #Target(ReportDate,CovAreaNodeID,CovAreaNodeType,RouteNodeId,RouteNodeType,RouteName,StoreID,StoreName,PrcRegionID,[Lat Code],[Long Code],flgTargetCall)
	SELECT DISTINCT @Date AS ReportDate,@SEAreaId,@SEAreaNodeType,#RouteList.RouteId, #RouteList.RouteNodeType ,#RouteList.RouteName ,AA.StoreID AS StoreID,SM.StoreName,PR.PrcRgnNodeId,SM.[Lat Code],SM.[Long Code],flgPlanned 
	FROM    #RouteList INNER JOIN tblRouteCoverageStoreMapping AA ON #RouteList.RouteID=AA.RouteID AND #RouteList.RouteNodeType=AA.RouteNodeType 
	INNER JOIN tblStoreMaster SM ON AA.StoreId=SM.StoreId
	LEFT OUTER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=SM.DistNodeId AND SM.DistNodeType=DBR.NodeType
	LEFT OUTER JOIN tblPriceRegionMstr PR ON PR.StateID=DBR.StateId
	WHERE (@Date BETWEEN AA.FromDate AND AA.ToDate)

	

	--SELECT * FROM #Target 

	--getting the visists for the day
	SELECT DISTINCT VD.VisitDetID,VM.VisitId,VM.RouteId,VM.RouteType,T.RouteName,VM.StoreId,VM.VisitLatitude,VM.VisitLongitude,VM.FlgOnRoute,ISNULL(VD.VisitStartDate,DeviceVisitStartTS) VisitStartDate,ISNULL(VD.VisitEndDate,DeviceVisitEndTS) VisitEndDate,flgTelephonicCall,IsGeoValidated,VM.Accuracy INTO #tblVisitMaster 
	FROM tblVisitMaster VM INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=VM.RouteID AND R.NodeType=VM.RouteType LEFT OUTER JOIN tblVisitDet VD ON VD.VisitID=VM.VisitID
	INNER JOIN #Target T ON T.RouteNodeId=VM.RouteID AND T.StoreID=VM.StoreID
	--INNER JOIN #RouteList R ON VM.RouteID=R.RouteID AND VM.RouteType=R.RouteNodeType --AND VM.SalesPersonID=@SalesmanId
	WHERE CONVERT(VARCHAR,VM.VisitDate,112) =CONVERT(VARCHAR, @Date,112) 
	--SELECT * FROM #tblVisitMaster ORDER BY RouteId

	INSERT INTO #Tmp(VisitDetID,RouteNodeId,RouteNodeType,RouteName,StoreId,StoreName,VisitLatitude,VisitLongitude,StartTime,EndTime,TimeSpent,ActLatCode,ActLongCode,flgTelephonicCall,IsGeoValidated,Accuracy,Seq)	
	SELECT DISTINCT VisitDetID,VM.RouteID,VM.RouteType,VM.RouteName,SM.StoreId,SM.StoreName AS StoreName,VM.VisitLatitude,VM.VisitLongitude, VisitStartDate,VisitEndDate,CONVERT(VARCHAR,((CONVERT(DATETIME,VisitEndDate,114) - CONVERT(DATETIME,VisitStartDate,114))),114) AS TimeSpent,SM.[Lat Code],SM.[Long Code],flgTelephonicCall,IsGeoValidated,Accuracy,DENSE_RANK() OVER (ORDER BY VisitStartDate) 
	FROM #tblVisitMaster VM INNER JOIN tblStoreMaster SM ON VM.StoreId=SM.StoreId ORDER BY VisitStartDate
	

	UPDATE T SET LastVisitedStoreEndTime=X.Endtime,TimeGAP=DATEDIFF(SECOND,X.EndTime,Starttime) FROM #TMp T , (SELECT Endtime,Seq FROM #Tmp) X WHERE X.Seq=T.Seq-1

	--SELECT * FROM #Tmp
	
	--UPDATE #Tmp SET #Tmp.ActLatCode=SM.[Lat Code] ,#Tmp.ActLongCode=SM.[Long Code] FROM #Tmp INNER JOIN tblStoreMaster SM ON #Tmp.StoreId=SM.StoreId
	UPDATE #Tmp SET DistanceFromOrgPointInM=ROUND([dbo].[fnCalcDistanceKM](VisitLatitude,ActLatCode,VisitLongitude,ActLongCode) *1000,0) ,DistanceAvailable=1
	WHERE ActLatCode<>0 AND VisitLatitude<>0
	--UPDATE #Tmp SET DistanceFromOrgPointInM='NA' WHERE 	DistanceAvailable=0

	SELECT V.*,C.RelConversionUnits INTO #VwSFAProductHierarchy FROM [VwSFAProductHierarchy] V INNER JOIN tblPrdMstrPackingUnits_ConversionUnits C ON C.SKUId=V.SKUNodeID AND C.BaseUOMID=3
	
	SELECT DISTINCT OM.OrderID,VM.StoreId,V.CategoryNodeID,OD.ProductID,CAST(ROUND((OD.OrderQty * V.UOMValue)/1000,0) AS FLOAT) [Order(Kg)],OrderQty [Order(Pcs)],CAST(ROUND(OrderQty/RelConversionUnits,2) AS FLOAT) [Order(Cases)],CAST(OD.NetLineOrderVal AS FLOAT) [Order(Value)]
	INTO #Orders
	FROM #Target VM
	INNER JOIN tblOrderMaster(nolock) OM On VM.StoreID=OM.StoreID
	INNER JOIN tblOrderDetail(nolock) OD On OM.OrderId=OD.OrderId
	INNER JOIN #VwSFAProductHierarchy V ON V.SKUNodeID=OD.ProductID
	--LEFT OUTER JOIN tblPrdSKUSalesMapping(nolock) P ON P.SKUNodeId=V.SKUNodeID AND P.SKUNodeType=V.SKUNodeType AND P.UOMID=3 AND CAST(GETDATE() AS DATE) BETWEEN P.FromDate AND P.ToDate
	--AND P.PrcLocationId=VM.PrcRegionID
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

	INSERT INTO #Target(ReportDate,CovAreaNodeID,CovAreaNodeType,RouteNodeId,RouteNodeType,RouteName,StoreID,StoreName,PrcRegionID,[Lat Code],[Long Code],flgTargetCall,flgActualVisit,flgTelephonicVisit,flgGeofenceValidated,Distancefrompoint,StartTime,TimeSpent,VisitLatitude,VisitLongitude,Accuracy,flgFirstVisit,TimeGap,VisitedRoute)

	SELECT T.ReportDate,T.CovAreaNodeID,T.CovAreaNodeType,T.RouteNodeId,T.RouteNodeType,T.RouteName,T.StoreID,T.StoreName,T.PrcRegionID,T.[Lat Code],T.[Long Code],T.flgTargetCall,CASE flgTelephonicCall WHEN 1 THEN 0 ELSE 1 END,          V.flgTelephonicCall,V.IsGeoValidated,V.DistanceFromOrgPointInM,V.StartTime,V.TimeSpent,V.VisitLatitude,V.VisitLongitude,V.Accuracy,DENSE_RANK() OVER (PARTITION BY V.StoreID ORDER BY V.Starttime) Seq,dbo.fnGetTimeStringin_MinSecFormat(V.TimeGap),V.RouteName FROM #TargetTemp T INNER JOIN #Tmp V ON V.StoreId=T.StoreID ORDER BY StartTime

	--SELECT * FROM #Target

	INSERT INTO #Target(ReportDate,CovAreaNodeID,CovAreaNodeType,RouteNodeId,RouteNodeType,RouteName,StoreID,StoreName,PrcRegionID,[Lat Code],[Long Code],flgTargetCall,VisitedRoute)
	SELECT T.ReportDate,T.CovAreaNodeID,T.CovAreaNodeType,T.RouteNodeId,T.RouteNodeType,T.RouteName,T.StoreID,T.StoreName,T.PrcRegionID,T.[Lat Code],T.[Long Code],T.flgTargetCall,T.VisitedRoute FROM #TargetTemp T WHERE StoreID NOT IN (SELECT StoreID FROM #TargetTemp)

	--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	

	----UPDATE T SET flgActualVisit=CASE flgTelephonicCall WHEN 1 THEN 0 ELSE 1 END,flgTelephonicVisit=flgTelephonicCall,flgGeofenceValidated=IsGeoValidated,Distancefrompoint=DistanceFromOrgPointInM,StartTime=V.StartTime,TimeSpent=V.TimeSpent,VisitLatitude=V.VisitLatitude,VisitLongitude=V.VisitLongitude,T.Accuracy=V.Accuracy FROM #Target T INNER JOIN #Tmp V ON V.StoreId=T.StoreID 
	PRINT 'BB'

	UPDATE T SET flgGeofenceValidated=1 FROM #Target T WHERE Distancefrompoint-Accuracy <= 30


	--SELECT * FROM #Target T WHERE flgActualVisit=1
	UPDATE A SET A.flgProductive=1,A.OrderID=B.OrderID,A.[Order(Cases)]=B.[Order(Cases)],A.[Order(Kg)]=B.[Order(Kg)],A.OrderValue=B.[Order(Value)] FROM #Target A INNER JOIN (SELECT DISTINCT StoreID,OrderID,SUM([Order(Value)]) [Order(Value)],SUM([Order(Kg)]) [Order(Kg)],SUM([Order(Cases)]) [Order(Cases)],SUM([Order(Pcs)]) [Order(Pcs)] FROM #Orders GROUP BY StoreID,OrderID) B ON A.StoreId=B.StoreId WHERE A.flgFirstVisit=1 --AND A.OrderID=B.OrderID 

	--SELECT * FROM #Target WHERE StoreID=25751
	
	DECLARE @TargetCall INT,@ActualCall INT,@TelephonicCall INT,@ProductiveCall INT,@ActualOrder FLOAT,@TelephonicOrder FLOAT,@TotalCall INT,@InStoreProd INT,@TelProd INT,@TotOrder FLOAT,@NewStoresAdded INT,@TotTimeSpentInStore VARCHAR(10),@TotWorkingHours VARCHAR(10)

	DECLARE @AssignRoute VARCHAR(200),@VisitedRoute VARCHAR(200)

	SELECT @TargetCall=COUNT(DISTINCT StoreID) FROM #Target WHERE flgTargetCall=1 --and flgFirstVisit=1
	SELECT @TotalCall=COUNT(DISTINCT StoreID) FROM #Target WHERE (flgActualVisit=1 OR flgTelephonicVisit=1) and flgFirstVisit=1
	SELECT @ActualCall=COUNT(DISTINCT StoreID) FROM #Target WHERE flgActualVisit=1 and flgFirstVisit=1
	SELECT @ProductiveCall=COUNT(DISTINCT StoreID) FROM #Target WHERE flgProductive=1 and flgFirstVisit=1
	SELECT @InStoreProd=COUNT(DISTINCT StoreID) FROM #Target WHERE flgProductive=1 AND flgActualVisit=1 and flgFirstVisit=1
	SELECT @TelProd=COUNT(DISTINCT StoreID) FROM #Target WHERE flgProductive=1 AND flgActualVisit=0 and flgFirstVisit=1
	SELECT @TelephonicCall=COUNT(DISTINCT StoreID) FROM #Target WHERE flgTelephonicVisit=1 and flgFirstVisit=1
	SELECT @TotOrder=SUM(OrderValue) FROM #Target WHERE (flgActualVisit=1 OR flgTelephonicVisit=1) and flgFirstVisit=1
	SELECT @ActualOrder=SUM(OrderValue) FROM #Target WHERE flgActualVisit=1 and flgFirstVisit=1
	SELECT @TelephonicOrder=SUM(OrderValue) FROM #Target WHERE flgTelephonicVisit=1 and flgFirstVisit=1

	-- UPdate Route Details
	SELECT * FROM #Target
	CREATE TABLE #AssignRoute(RouteName VARCHAR(200))
	IF NOT EXISTS (SELECT 1 FROM #Target WHERE flgTargetCall=1)
	BEGIN
		INSERT INTO #AssignRoute
		SELECT DISTINCT R.RouteName FROM tblRoutePlanningVisitDetail V INNER JOIN #RouteList R ON R.RouteId=V.RouteNodeId AND R.RouteNodeType=V.RouteNodetype WHERE DSENodeId=@SalesmanId AND VisitDate=@Date

		SELECT * FROM #Target
	END
	ELSE
	BEGIN
		INSERT INTO #AssignRoute
		SELECT DISTINCT RouteName FROM #Target WHERE flgTargetCall=1 
	END
		
	SELECT DISTINCT VisitedRoute INTO #VisitedRoute FROM #Target WHERE flgTelephonicVisit<>1


	SELECT @AssignRoute=  dbo.ConvertFirstLetterinCapital(RouteName) FROM #AssignRoute F 

	SELECT @VisitedRoute= dbo.ConvertFirstLetterinCapital(VisitedRoute) FROM #VisitedRoute F 

	DECLARE @DayStart Datetime,@DayStartLatCode NUMERIC(27,24),@DayStartLongCode NUMERIC(27,24),@DayEnd Datetime,@DayEndLatCode NUMERIC(27,24),@DayEndLongCode NUMERIC(27,24)

	SELECT @DayStart=Datetime,@DayStartLatCode=[Lat Code],@DayStartLongCode=[Long Code] FROM tblPersonAttendance WHERE PersonNodeID=@SalesmanId AND CAST(DAtetime AS DATE)=@Date
	SELECT @DayEnd=Endtime FROM tblDayEndDetails WHERE PersonId=@SalesmanId AND CAST(ForDate AS DATE)=@Date
	

	SELECT @TotTimeSpentInStore=RIGHT('00' + CAST(SUM(DATEDIFF(ss,VisitStartDate,VisitEndDate)) / 3600 AS VARCHAR),2) + ':' + RIGHT('00' + CAST((SUM(DATEDIFF(ss,VisitStartDate,VisitEndDate)) / 60) % 60 AS VARCHAR),2) + ':' + RIGHT('00' + CAST(SUM(DATEDIFF(ss,VisitStartDate,VisitEndDate)) % 60 AS VARCHAR),2) FROM #tblVisitMaster V  

	SELECT @NewStoresAdded=COUNT(DISTINCT StoreIDDB) FROM tblPDASyncStoreMappingMstr(nolock) P INNER JOIN #Target T ON T.StoreID=P.OrgStoreId WHERE CAST(P.CreateDate AS DATE)=@Date and flgFirstVisit=1

	-- CAtegorywise sales data
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
		
		SELECT @CatNodeId=CategoryNodeId,@Category=Category FROM #tmpCatList WHERE RowId=@Counter

		SELECT @strSQL='ALTER TABLE #Target ADD [Order Qty In KG^' + @Category + '] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)

		

		SELECT @strSQL='UPDATE A SET A.[Order Qty In KG^' + @Category + ']=ROUND(B.OrderQtyInKG,2) FROM #Target A INNER JOIN (SELECT StoreID,SUM([Order(Kg)]) OrderQtyInKG FROM #Orders WHERE CategoryNodeID=' + CAST(@CatNodeId AS VARCHAR) + ' GROUP BY StoreID) B ON A.StoreID=B.StoreID WHERE flgFirstVisit=1'
		PRINT @strSQL
		EXEC(@strSQL)

		
		SELECT @StrCategory= @StrCategory + ',[Order Qty In KG^' + @Category + ']' 
		SELECT @StrCategoryForGrouping=@StrCategoryForGrouping +  ',SUM([Order Qty In KG^' + @Category + '])' 
		SELECT @Counter+=1
	END
	SET @Counter=1
	WHILE @Counter<=@MaxCount
	BEGIN
		
		SELECT @CatNodeId=CategoryNodeId,@Category=Category FROM #tmpCatList WHERE RowId=@Counter

		
		SELECT @strSQL='ALTER TABLE #Target ADD [Order Qty In Case^' + @Category + '] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)

		

		SELECT @strSQL='UPDATE A SET A.[Order Qty In Case^' + @Category + ']=ROUND(B.[Order(Cases)],2) FROM #Target A INNER JOIN (SELECT StoreID,SUM([Order(Cases)]) [Order(Cases)] FROM #Orders WHERE CategoryNodeID=' + CAST(@CatNodeId AS VARCHAR) + ' GROUP BY StoreID) B ON A.StoreID=B.StoreID WHERE flgFirstVisit=1'
		PRINT @strSQL
		EXEC(@strSQL)

		

		SELECT @StrCategory= @StrCategory  + ',[Order Qty In Case^' + @Category + ']' 
		SELECT @StrCategoryForGrouping=@StrCategoryForGrouping  +  ',SUM([Order Qty In Case^' + @Category + '])' 
		SELECT @Counter+=1
	END

	SET @Counter=1
	WHILE @Counter<=@MaxCount
	BEGIN
		
		SELECT @CatNodeId=CategoryNodeId,@Category=Category FROM #tmpCatList WHERE RowId=@Counter

		

		SELECT @strSQL='ALTER TABLE #Target ADD [Order Qty In Pcs^' + @Category + '] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)

		

		SELECT @strSQL='UPDATE A SET A.[Order Qty In Pcs^' + @Category + ']=ROUND(B.[Order(Pcs)],2) FROM #Target A INNER JOIN (SELECT StoreID,SUM([Order(Pcs)]) [Order(Pcs)] FROM #Orders WHERE CategoryNodeID=' + CAST(@CatNodeId AS VARCHAR) + ' GROUP BY StoreID) B ON A.StoreID=B.StoreID WHERE flgFirstVisit=1'
		PRINT @strSQL
		EXEC(@strSQL)



		SELECT @StrCategory= @StrCategory  + ',[Order Qty In Pcs^' + @Category + ']'
		SELECT @StrCategoryForGrouping=@StrCategoryForGrouping +  ',SUM([Order Qty In Pcs^' + @Category + '])'
		SELECT @Counter+=1
	END


	
	   	  
	DELETE T FROM #Target T WHERE StoreID IN (SELECT StoreID FROM #Target WHERE flgTargetCall=1) AND flgTargetCall=0

	SELECT @TargetCall TC,CAST(@TotalCall AS VARCHAR) + ' (' + CAST(ISNULL(@ActualCall,0) AS VARCHAR) + '+' + CAST(ISNULL(@TelephonicCall,0) AS VARCHAR) + ')'  [AC (InStore + TelC)],CAST(ISNULL(@ProductiveCall,0) AS VARCHAR) + ' (' + CAST(ISNULL(@InStoreProd,0) AS VARCHAR) + '+' + CAST(ISNULL(@TelProd,0) AS VARCHAR) + ')' [PC (InStoreProd + TelProd)] ,CAST(ISNULL(@TotOrder,0) AS VARCHAR) + ' (' + CAST(ISNULL(@ActualOrder,0) AS VARCHAR) + '+' + CAST(ISNULL(@TelephonicOrder,0) AS VARCHAR) + ')' [TO (AO+TelO)],ISNULL(@NewStoresAdded,0) NewStoresAdded,@TotTimeSpentInStore TotTimeSpentInStore,@AssignRoute AssignRoute,@VisitedRoute VisitedRoute
	
	--CAST(DAtepart(hour,StartTime) AS VARCHAR) + '':'' + CAST(DAtepart(minute,StartTime) AS VARCHAR)
	SELECT @StrSQL=''
	SET @StrSQL='SELECT DISTINCT StoreID,StoreName,ISNULL(flgGeofenceValidated,0) flgGeofenceValidated,LEFT (StartTime,5)
	 [Start Time], LEFT (TimeSpent,5)  [Time Spent],TimeGap [Time Gap],VisitLatitude,VisitLongitude,CAST(ISNULL(CAST(Distancefrompoint AS BIGINT),0) AS VARCHAR) + '' M'' [Distance from point],ISNULL(flgProductive,0) flgProductive,
	CASE flgActualVisit WHEN 1 THEN 1 ELSE 0 END flgShowMap,ROUND(CAST(OrderValue AS FLOAT),2) [Sales Value],ROUND(CAST([Order(Cases)] AS FLOAT),2) [Order (Cases)],ROUND(CAST([Order(Kg)] AS FLOAT),2) [Order (Kg)]' + @StrCategory + ',ISNULL(flgActualVisit,0) flgActualVisit,ISNULL(flgTelephonicVisit,0) flgTelephonicVisit,[Lat Code] StoreLatitude,[Long Code] StoreLongitude,flgOffROute
	FROM #Target WHERE flgProductive=1 OR flgTargetCall=1 OR flgActualVisit=1 OR flgTelephonicVisit=1 ORDER BY flgActualVisit DESC,flgTelephonicVisit DESC,[Start Time],StoreName'
	PRINT @StrSQL
	EXEC(@StrSQL)


	
	
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

	SELECT CONVERT(VARCHAR,@DayStart,109) DayStart , CONVERT(VARCHAR,@DayEnd,109) DayEnd , @DayStartLatCode DayStartLatCode,@DayStartLongCode DayStartLongCode,@DayEndLatCode DayEndLatCode,@DayEndLongCode DayEndLongCode

	
	


END



