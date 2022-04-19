-- =============================================
-- Author:		Avinash Gupta
-- Create date: 21-Sep-2015
-- Description:	Sp to get the store details capture from PDA
--z =============================================

--exec [SpRptGetStoreDetailsForMap] 2,120,2,110,2,100,0,1
CREATE PROCEDURE [dbo].[SpRptGetStoreDetailsForMap] 
@NodeID INT,
@NodeType INT,
@PNodeId INT,
@PNodeType INT,
@PPNodeId INT,
@PPNodeType INT,
@flgHierarchyType TINYINT, -- 5: Only DBR Hierarchy, 2: Combined Hierarchy
@ChannelId INT
AS
BEGIN
	
	DECLARE @MaxID INT
	DECLARE @Counter INT
	DECLARE @SQL VARCHAR(MAX)
	DECLARE @ColumeName VARCHAR(200)
	DECLARE @ColorCount INT
	DECLARE @CovAreaCount INT
	DECLARE @SqlString VARCHAR(500)=''
	DECLARE @BuildString NVARCHAR(MAX)
	DECLARE @CovAreaId INT
	DECLARE @CovAreaNodetype INT
	DECLARE @StoreCategoryId INT
	DECLARE @StoreCategory VARCHAR(200)
	DECLARE @OutletTypeId INT
	DECLARE @OutletType VARCHAR(200)

	SET @SQL=''
	SET @Counter=1
	
	CREATE TABLE #RouteList(ID INT IDENTITY(1,1),RouteId VARCHAR(20),ColorCode VARCHAR(10),RouteName VARCHAR(200),CovAreaId INT,CovAreaName VARCHAR(200),StoreCount INT DEFAULT 0 NOT NULL)
	CREATE TABLE #CovAreaList(ID INT IDENTITY(1,1),CovAreaId INT,ColorCode VARCHAR(10),CovAreaName VARCHAR(200),PolygonArea varchar(max),StoreCount INT DEFAULT 0 NOT NULL)
	CREATE TABLE #LatLong(ID INT IDENTITY(1,1),LatCode numeric(26, 22),LonCode numeric(26, 22))
	CREATE TABLE #CategoryList(Id INT IDENTITY(1,1),StoreCategoryId INT,StoreCategory VARCHAR(200))
	CREATE TABLE #OutletTypeList(Id INT IDENTITY(1,1),OutletTypeId INT,OutletType VARCHAR(200))
	
	CREATE TABLE #tmpRsltWithFullHierarchy(RegionID INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200))

	INSERT INTO #tmpRsltWithFullHierarchy(RegionID,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea, RouteId,RouteNodeType,Route)
	EXEC [spRptGetFullSalesHierarchyBasedonLogin] 0,@NodeID,@NodeType,''
	--SELECT * FROM #tmpRsltWithFullHierarchy
		

	CREATE TABLE #tblStoreList (FlgSeq INT IDENTITY(1,1),StoreID INT,[Store Details] VARCHAR(2000),[Owner Info] VARCHAR(2000),LatCode NUMERIC(26,22),LonCode NUMERIC(26,22),StoreCategoryId VARCHAR(200) DEFAULT 0 NOT NULL,[Store Category] VARCHAR(200) DEFAULT '' NOT NULL,RouteId VARCHAR(20),RouteName VARCHAR(200),CoverageAreaId INT,CovAreaName VARCHAR(200),Distributor VARCHAR(200),Salesman VARCHAR(200),[Created Date] datetime,DBRId INT,CoverageTypeID INT,[Coverage Type] VARCHAR(200))

	SET @SQL='INSERT INTO #tblStoreList(StoreID,[Store Details],[Owner Info],LatCode,LonCode,[RouteId],RouteName,CoverageAreaId,CovAreaName,[Created Date],Distributor,Salesman,DBRId,StoreCategoryId,[Store Category])
		SELECT SM.StoreID,SM.StoreName + ''~'' +ISNULL(StoreAdd.StoreAddress1,'''') + ''~'' + ISNULL(StoreAdd.City,'''') +''~'' +ISNULL(CAST(StoreAdd.Pincode AS VARCHAR),'''') ,
		ISNULL(StoreCont.FName,'''') +''$Contact-'' + ISNULL(CAST(StoreCont.MobNo AS VARCHAR),'''') ,SM.[Lat Code],SM.[Long Code], CAST(RCM.RouteNodetype AS VARCHAR) + CAST(RCM.RouteId AS VARCHAR) AS RouteId,R.Route, CAST(R.CovAreaNodeType AS VARCHAR) + CAST(R.CovAreaId AS VARCHAR),R.CovArea,SM.CreatedDate,ISNULL(DBR.Descr,''NA''),ISNULL(Person.Salesman,''Vacant''), SM.DBID,ISNULL(ST.StoreSegmentationID,0),ISNULL(ST.StoreSegment,'''')
		FROM tblStoreMaster SM INNER JOIN tblRouteCoverageStoreMapping RCM ON SM.StoreId= RCM.StoreId
		INNER JOIN #tmpRsltWithFullHierarchy R ON RCM.RouteId=R.RouteId AND RCM.RouteNodetype=R.RouteNodeType
		LEFT JOIN tblDBRSalesStructureDBR DBR ON SM.DistNodeID=DBR.NodeId AND SM.DistNodeType=DBR.NodeType
		LEFT OUTER JOIN tblOutletAddressDet StoreAdd ON StoreAdd.StoreID=SM.StoreID AND StoreAdd.OutAddTypeID=1
		LEFT OUTER JOIN tblOutletContactDet StoreCont ON StoreCont.StoreID=SM.StoreID
		LEFT JOIN (SELECT SPM.NodeId,SPM.NodeType,MP.Descr AS Salesman FROM tblSalesPersonMapping SPM INNER JOIN tblMstrPerson MP ON SPM.PersonNodeID=MP.NodeID AND SPM.Persontype=MP.NodeType WHERE (GETDATE() BETWEEN SPM.FromDate AND SPM.ToDate) AND SPM.NodeType IN(130,160)) Person ON Person.NodeId=R.CovAreaId AND Person.Nodetype=R.CovAreaNodeType
		LEFT OUTER JOIN tblMstrStoreSegment ST ON ST.StoreSegment=SM.Segmentation
		WHERE SM.FlgActive=1 AND (GETDATE() BETWEEN RCM.FromDate AND RCM.ToDate)  ORDER BY CAST(RCM.RouteNodetype AS VARCHAR) + CAST(RCM.RouteId AS VARCHAR),SM.CreatedDate'
	PRINT @SQL
	EXEC (@SQL)

	
	--SELECT * FROM #tblStoreList
	SELECT FlgSeq,StoreID,[Store Details],LatCode,LonCode,StoreCategoryId,[Store Category],RouteId,RouteName,CoverageAreaId,CovAreaName,Distributor, Salesman,[Created Date]
	FROM #tblStoreList ORDER BY RouteId,FlgSeq
		

	SELECT @ColorCount=COUNT(ColorId) FROM tblColorCodesForMap WHERE ColorId<=10
		
	INSERT INTO #RouteList(RouteId,ColorCode,RouteName,CovAreaId,CovAreaName,StoreCount)
	SELECT DISTINCT RouteId,'',RouteName,CoverageAreaId,CovAreaName,COUNT(DISTINCT StoreID)
	FROM #tblStoreList
	GROUP BY RouteId,RouteName,CoverageAreaId,CovAreaName
	ORDER BY CoverageAreaId,RouteId

	UPDATE A SET A.ColorCode =B.ColorCode  FROM #RouteList A INNER JOIN tblColorCodesForMap B ON ((A.ID % @ColorCount)+1)=B.ColorId

	SELECT * FROM #RouteList ORDER BY RouteId

	INSERT INTO #CovAreaList(CovAreaId,CovAreaName,ColorCode,StoreCount)
	SELECT DISTINCT CoverageAreaId,CovAreaName,'',COUNT(DISTINCT StoreID)
	FROM #tblStoreList
	GROUP BY CoverageAreaId,CovAreaName
	--SELECT * FROM #CovAreaList
	UPDATE A SET A.ColorCode =B.ColorCode  FROM #CovAreaList A INNER JOIN tblColorCodesForMap B ON ((A.ID % @ColorCount)+1)=B.ColorId
	
	SELECT * FROM #CovAreaList

	DECLARE @MaxLatCode DECIMAL(26,22)
	DECLARE @MinLatCode DECIMAL(26,22)
	DECLARE @MaxLonCode DECIMAL(26,22)
	DECLARE @MinLonCode DECIMAL(26,22)

	IF NOT EXISTS(SELECT 1 FROM #tblStoreList WHERE FlgSeq>1)
	BEGIN
		SELECT LatCode AS CenterLatCode,LonCode AS CenterLonCode,1 AS Distance
		FROM #tblStoreList
	END
	ELSE
	BEGIN
		SELECT @MaxLatCode=MAX(LatCode),@MinLatCode=MIN(LatCode),@MaxLonCode=MAX(LonCode),@MinLonCode=MIN(LonCode) 
		FROM #tblStoreList
		WHERE LatCode<>0 AND LonCode<>0
		
		--SELECT @MaxLatCode AS MaxLatCode,@MinLatCode AS MinLatCode,@MaxLonCode AS MaxLonCode,@MinLonCode AS MinLonCode

		SELECT MaxLat.LatCode,MaxLat.LonCode,MinLat.LatCode AS LatCode1,MinLat.LonCode AS LonCode1,[dbo].[fnCalcDistanceKM](MaxLat.LatCode,MinLat.LatCode,MaxLat.LonCode,MinLat.LonCode) AS DistanceInKM INTO #Distance FROM 
		(SELECT LatCode,LonCode FROM #tblStoreList WHERE LatCode=@MaxLatCode) MaxLat,
		(SELECT LatCode,LonCode FROM #tblStoreList WHERE LatCode=@MinLatCode) MinLat
		UNION
		SELECT MaxLon.LatCode,MaxLon.LonCode,MinLon.LatCode,MinLon.LonCode,[dbo].[fnCalcDistanceKM](MaxLon.LatCode,MinLon.LatCode,MaxLon.LonCode,MinLon.LonCode) AS DistanceInKM_MaxMinLon FROM 
		(SELECT LatCode,LonCode FROM #tblStoreList WHERE LonCode=@MaxLonCode) MaxLon,
		(SELECT LatCode,LonCode FROM #tblStoreList WHERE LonCode=@MinLonCode) MinLon

		--SELECT * FROM #Distance

		SELECT (@MaxLatCode+@MinLatCode)/2 AS CenterLatCode,(@MaxLonCode+@MinLonCode)/2 AS CenterLonCode,CASE ROUND(MAX(#Distance.DistanceInKM),0) WHEN 0 THEN 1 ELSE ROUND(MAX(#Distance.DistanceInKM),0) END AS Distance
		FROM #Distance
	END
		
	--,DBRId INT,Distributor VARCHAR(200)
	CREATE TABLE #RouteWiseSummary(SOAreaId INT,[SO Area] VARCHAR(200),CoverageAreaId INT,[Coverage Area] VARCHAR(200),RouteId INT,[Route] VARCHAR(200),ColorCode VARCHAR(10),Total INT)
	CREATE TABLE #CovAreaWiseSummary(SOAreaId INT,[SO Area] VARCHAR(200),CoverageAreaId INT,[Coverage Area] VARCHAR(200),ColorCode VARCHAR(10),Total INT)

	INSERT INTO #RouteWiseSummary(SOAreaId,[SO Area],CoverageAreaId,[Coverage Area],RouteId,[Route],ColorCode,Total)
	SELECT 0,'',CovAreaId,CovAreaName,RouteId,RouteName AS [Route],ColorCode,StoreCount 
	FROM #RouteList
	ORDER BY CovAreaId

	INSERT INTO #CovAreaWiseSummary(SOAreaId,[SO Area],CoverageAreaId,[Coverage Area],ColorCode,Total)
	SELECT 0,'',CovAreaId AS CoverageAreaId,CovAreaName AS [Coverage Area],ColorCode,StoreCount AS Total 
	FROM #CovAreaList
	ORDER BY CovAreaId
	
	UPDATE A SET A.[SO Area] =B.SOArea,A.SoAreaId=B.SOAreaId  FROM #RouteWiseSummary A INNER JOIN #tmpRsltWithFullHierarchy B ON A.RouteId=CAST(B.RouteNodeType AS VARCHAR) + CAST(B.RouteId AS VARCHAR)

	UPDATE A SET A.[SO Area] =B.SOArea,A.SOAreaId=B.SOAreaId  FROM #CovAreaWiseSummary A INNER JOIN #tmpRsltWithFullHierarchy B ON A.CoverageAreaId=CAST(B.CovAreaNodeType AS VARCHAR) + CAST(B.CovAreaId AS VARCHAR)
	--SELECT * FROM #RouteWiseSummary
	--SELECT * FROM #CovAreaWiseSummary

		
	SELECT  DBRId,CoverageAreaId,RouteId,StoreCategoryId,COUNT(StoreID) StoreCount INTO #RouteAndCatWiseStoreCount
	FROM #tblStoreList
	GROUP BY DBRId,CoverageAreaId,RouteId,StoreCategoryId

	SELECT  DBRId,CoverageAreaId,StoreCategoryId,COUNT(StoreID) StoreCount INTO #CovAreaAndCatWiseStoreCount
	FROM #tblStoreList
	GROUP BY DBRId,CoverageAreaId,StoreCategoryId

	
	INSERT INTO #CategoryList(StoreCategoryId,StoreCategory)
	SELECT StoreSegmentationID,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(StoreSegment,char(13),''),char(10),''),char(9),'')))  
	FROM tblMstrStoreSegment
	--SELECT * FROM #RouteAndCatWiseStoreCount
	--SELECT * FROM #CovAreaAndCatWiseStoreCount

	SELECT @MaxID=MAX(Id) FROm #CategoryList --where id=0
	SET @Counter=1
	WHILE @Counter<=@MaxID
	BEGIN
		SELECT @StoreCategoryId=StoreCategoryId,@StoreCategory=StoreCategory  FROM #CategoryList WHERE ID=@Counter

		SET @SQL='ALTER TABLE #RouteWiseSummary ADD [' + @StoreCategory + '] INT DEFAULT 0 NOT NULL'
		PRINT @SQL
		EXEC(@SQL)

		SET @SQL='UPDATE A SET A.[' + @StoreCategory + ']=B.StoreCount FROM #RouteWiseSummary A INNER JOIN #RouteAndCatWiseStoreCount B ON A.RouteId=B.RouteId  WHERE B.StoreCategoryId=' + CAST(@StoreCategoryId AS VARCHAR)
		PRINT @SQL
		EXEC(@SQL)

		SET @SQL='ALTER TABLE #CovAreaWiseSummary ADD [' + @StoreCategory + '] INT DEFAULT 0 NOT NULL'
		PRINT @SQL
		EXEC(@SQL)

		SET @SQL='UPDATE A SET A.[' + @StoreCategory + ']=B.StoreCount FROM #CovAreaWiseSummary A INNER JOIN #CovAreaAndCatWiseStoreCount B ON A.CoverageAreaId=B.CoverageAreaId  WHERE B.StoreCategoryId=' + CAST(@StoreCategoryId AS VARCHAR)
		PRINT @SQL
		EXEC(@SQL)

		SET @Counter+=1
	END
	
	SELECT * FROM #RouteWiseSummary ORDER BY [SO Area],[Coverage Area],[Route]
	SELECT * FROM #CovAreaWiseSummary ORDER BY [SO Area],[Coverage Area]


END

