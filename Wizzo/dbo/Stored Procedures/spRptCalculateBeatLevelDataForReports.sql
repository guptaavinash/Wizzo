

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRptCalculateBeatLevelDataForReports]
	
AS
BEGIN
	--SET DATEFirst 1

	DECLARE @RptDate DATE=DATEADD(dd,-1,GETDATE())
	--DECLARE @WeekEnding DATE=dbo.fncUTLGetWeekEndDate(@RptDate)
	--DECLARE @FirstDate DATE=DATEADD(dd,-27,@WeekEnding)
	DECLARE @FirstDate DATE=DATEADD(dd,-27,@RptDate)
	DECLARE @RptMonthYear INT=CONVERT(VARCHAR(6),@RptDate,112)
	DECLARE @MonthFirstDate DATE=CAST(CONVERT(VARCHAR(6),@RptDate,112) + '01' AS DATE)
	DECLARE @P3MFirstDate DATE=DATEADD(m,-2,@MonthFirstDate)
	PRINT @RptDate
	PRINT @MonthFirstDate
	--PRINT @WeekEnding
	PRINT @FirstDate	
	PRINT @P3MFirstDate
	PRINT @RptMonthYear
	----CREATE TABLE #DaysInMomth(RptDate DATE)
	----INSERT INTO #DaysInMomth(RptDate)
	----SELECT MonthDate FROM dbo.fnGetAllDatesInMonth(@RptDate)
	----DELETE FROM #DaysInMomth WHERE RptDate>@RptDate
	------SELECT * FROM #DaysInMomth
	
	CREATE TABLE #Tmp(PersonNodeId INT,PersonName VARCHAR(200),AreaNodeId INT,AreaNodeType INT,AreaName VARCHAR(200),NoOFWeeksPlanned INT,VisitFrequency VARCHAR(100),LastVisited DATE,StoreId INT,IsPlanned TINYINT,IsCovered TINYINT,Covered_P4W TINYINT, NotCovered_P4W TINYINT, IsProductive TINYINT,Productive_P4W TINYINT,NonProductive_P4W TINYINT,Productive_P3M TINYINT,NonProductive_P3M TINYINT,NotCoveredInPast2Visits TINYINT,StoreLastVisitDate DATE,SalesmanSalesTarget FLOAT,SalesmanSalesAch FLOAT,MTDVolume FLOAT,NoOfVisits_MTD INT,NoOfProdVisits_MTD INT,flgStarOutlet TINYINT,IsVisitedOnLastVisit TINYINT,IsProductiveOnLastVisit TINYINT,SaleOnLastVisit FLOAT)
	
	SELECT DISTINCT RouteId,RouteNodeType,StoreId,FromDate,ToDate INTO #TmpStoreList
	FROM tblRouteCoverageStoreMapping
	--SELECT * FROM #TmpStoreList order by storeId,fromdate

	UPDATE A SET A.RouteId=B.RouteId,A.RouteNodeType=B.RouteNodeType--,A.FromDate=B.FromDate,A.Todate=B.Todate
	from #TmpStoreList A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=b.StoreID INNER JOIN
	(SELECT StoreID,MAX(ISNULL(Todate,GETDATE())) Todate FROM tblRouteCoverageStoreMapping WHERE FromDate<=GETDATE() GROUP BY StoreID) AA
    ON ISNULL(B.Todate,GETDATE())=AA.Todate AND B.StoreID =AA.StoreID

	--SELECT * FROM #TmpStoreList WHERE StoreId IN(SELECT StoreId FROM #TmpStoreList GROUP BY StoreId HAVING COUNT(DISTINCT RouteId)>1)
	--SELECT * FROM #TmpStoreList order by storeId,fromdate

	INSERT INTO #Tmp(AreaNodeId,AreaNodeType,StoreId,IsPlanned,IsCovered,Covered_P4W,NotCovered_P4W,IsProductive,Productive_P4W,NonProductive_P4W,Productive_P3M, NonProductive_P3M,NotCoveredInPast2Visits,SalesmanSalesTarget,SalesmanSalesAch,MTDVolume,NoOfVisits_MTD,NoOfProdVisits_MTD,flgStarOutlet,IsVisitedOnLastVisit,IsProductiveOnLastVisit,SaleOnLastVisit)
	SELECT DISTINCT RouteId,RouteNodeType,StoreId,0,0,0,1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0 FROM #TmpStoreList 
	WHERE RouteId>0 AND (@RptDate BETWEEN FromDate AND ToDate)

	--remove routes which are not part of SFA
	DELETE A FROM #Tmp A LEFT OUTER JOIN (SELECT DISTINCT RouteNodeId,RouteNodetype FROM tblRoutePlanningVisitDetail) B ON A.AreaNodeId=B.RouteNodeId AND A.AreaNodeType=B.RouteNodetype
	WHERE B.RouteNodeId IS NULL AND B.RouteNodetype IS NULL

	UPDATE A SET flgStarOutlet=1 FROM #Tmp A INNER JOIN StartOutletDump S ON S.StoreID=A.StoreId

	UPDATE A SET A.AreaName=B.Descr FROM #Tmp A INNER JOIN tblCompanySalesStructureRouteMstr B ON A.AreaNodeId=B.NodeId AND A.AreaNodeType=B.NodeTYpe
	
	UPDATE A SET A.NoOFWeeksPlanned=B.NoOFWeeksPlanned 
	FROM #Tmp A INNER JOIN (SELECT RouteNodeId,RouteNodeType,COUNT(DISTINCT WeekNo) As NoOFWeeksPlanned FROM tblRoutePlanningMstr WHERE (@RptDate BETWEEN FromDate AND ToDate) GROUP BY RouteNodeId,RouteNodeType) B ON A.AreaNodeId=B.RouteNodeId AND A.AreaNodeType=B.RouteNodeType

	UPDATE #Tmp SET VisitFrequency=CASE NoOFWeeksPlanned WHEN 1 THEN 'Every Week' WHEN 2 THEN 'Alternate Week' WHEN 3 THEN 'Every 3rd Week' WHEN 4 THEN 'Every 4th Week' END
	--SELECT * FROM #Tmp ORDER BY NoOFWeeksPlanned

	SELECT RouteId,RouteType,MAX(VisitDate) LastVisitDate INTO #LastVisitDateForRoute FROM tblVisitMaster WHERE VisitDate<=@RptDate GROUP BY RouteId,RouteType
	--SELECT * FROM #LastVisitDateForRoute ORDER BY RouteType,RouteId

	UPDATE A SET A.LastVisited=B.LastVisitDate FROM #Tmp A INNER JOIN #LastVisitDateForRoute B ON A.AreaNodeId=B.RouteId AND A.AreaNodeType=B.RouteType

	UPDATE A SET A.IsVisitedOnLastVisit=1 FROM #Tmp A INNER JOIN tblvisitMaster B ON A.StoreId=B.StoreId AND A.LastVisited=B.VisitDate

	UPDATE A SET A.SaleOnLastVisit=B.OrderVolumeKG,A.IsProductiveOnLastVisit=1 
	FROM #Tmp A INNER JOIN (SELECT OM.StoreId,SUM(OD.OrderQty*CAST(SKU.Grammage AS FLOAT)) OrderVolumeKG FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId INNER JOIN tblPrdMstrSKULvl SKU ON OD.ProductId=SKU.NodeId INNER JOIN #Tmp AA ON OM.StoreId=AA.StoreId AND OM.OrderDate=AA.LastVisited GROUP BY OM.StoreId) B ON A.StoreId=B.StoreID


	UPDATE A SET A.StoreLastVisitDate=ISNULL(B.LastVisitDate,'01-Jan-1990') FROM #Tmp A LEFT JOIN (SELECT StoreId,MAX(VisitDate) LastVisitDate FROM tblVisitMaster WHERE VisitDate<=@RptDate GROUP BY StoreId) B ON A.StoreId=B.StoreId

	UPDATE A SET A.Covered_P4W=1,NotCovered_P4W=0 FROM #Tmp A INNER JOIN (SELECT StoreId FROM tblVisitMaster WHERE (VisitDate BETWEEN @FirstDate AND @RptDate)) B ON A.storeId=B.StoreId

	UPDATE A SET A.Productive_P4W=1,NonProductive_P4W=0 FROM #Tmp A INNER JOIN (SELECT StoreId FROM tblOrderMaster WHERE (OrderDate BETWEEN @FirstDate AND @RptDate)) B ON A.storeId=B.StoreId

	UPDATE A SET A.Productive_P3M=1,NonProductive_P3M=0 FROM #Tmp A INNER JOIN (SELECT StoreId FROM tblOrderMaster WHERE (OrderDate BETWEEN @P3MFirstDate AND @RptDate)) B ON A.storeId=B.StoreId
	--SELECT * FROM #Tmp
	--UPDATE A SET A.NonProductive_P3M=0 FROM #Tmp A INNER JOIN (SELECT DISTINCT StoreId FROM tblOrderMaster WHERE OrderDate>=@P3MMonthFirstDate) B ON A.storeId=B.StoreId

	UPDATE A SET A.MTDVolume=B.OrderVolumeKG,A.SalesmanSalesAch=B.OrderVolumeKG,A.NoOfProdVisits_MTD=B.NoOfProdVisits_MTD 
	FROM #Tmp A INNER JOIN (SELECT OM.StoreId,SUM(OD.OrderQty*CAST(SKU.Grammage AS FLOAT)) OrderVolumeKG,COUNT(DISTINCT OM.VisitID) NoOfProdVisits_MTD FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId INNER JOIN tblPrdMstrSKULvl SKU ON OD.ProductId=SKU.NodeId WHERE OM.OrderDate>=@MonthFirstDate AND OM.OrderDate<=@RptDate GROUP BY OM.StoreId) B ON A.StoreId=B.StoreID

	UPDATE A SET A.NoOfVisits_MTD=AA.NoOfMTDVisits FROM #Tmp A LEFT JOIN (SELECT VM.StoreID,COUNT(DISTINCT VM.VisitID) NoOfMTDVisits FROM tblVisitMaster VM INNER JOIN #Tmp AA ON VM.StoreID=AA.StoreId WHERE VM.VisitDate>=@MonthFirstDate AND VM.VisitDate<=@RptDate GROUP BY VM.StoreID) AA ON A.StoreId=AA.StoreID

	UPDATE A SET A.PersonNodeId=B.PersonNodeID,A.PersonName=C.Descr
	FROM #tmp A INNER JOIN tblCompanySalesStructureHierarchy H ON A.AreaNodeId=H.NodeID AND A.AreaNodeType=H.NodeType 
	INNER JOIN tblSalesPersonMapping B ON H.PNodeID=B.NodeID AND H.PNodeType=B.NodeType
	INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID
	WHERE (@RptDate BETWEEN B.FromDate AND B.ToDate)

	UPDATE A SET A.SalesmanSalesTarget=B.SecondaryTarget FROM #Tmp A INNER JOIN tblCompanyTarget B ON A.PersonNodeId=B.PersonNodeId WHERE B.RptMonthYear=@RptMonthYear
	--SELECT * FROM #Tmp --WHERE AreaNodeId=1
	--ORDER BY PersonNodeId--AreaNodeType,AreaNodeId

	TRUNCATE TABLE tblRptBeatProfileData

	INSERT INTO tblRptBeatProfileData(PersonNodeID,AreaNodeId,AreaNodeType,AreaName,Personname,VisitFrequency,LastVisited,StoreId,IsPlanned,IsCovered,Covered_P4W,NotCovered_P4W,IsProductive, Productive_P4W,NonProductive_P4W,Productive_P3M,NonProductive_P3M,NotCoveredInPast2Visits,RptMonthYear,TimeStampIns,SalesmanSalesTarget,SalesmanSalesAch,MTDSales,NoOfVisits_MTD,NoOfProdVisits_MTD,SalesQty,flgStarOutlets,IsVisitedOnLastVisit,IsProductiveOnLastVisit,SaleOnLastVisit)
	SELECT PersonNodeId,AreaNodeId,AreaNodeType,AreaName,PersonName,VisitFrequency,LastVisited,StoreId,IsPlanned,IsCovered,Covered_P4W,NotCovered_P4W,IsProductive,Productive_P4W, NonProductive_P4W,Productive_P3M,NonProductive_P3M,NotCoveredInPast2Visits,@RptMonthYear,GETDATE(),SalesmanSalesTarget,SalesmanSalesAch,MTDVolume,ISNULL(NoOfVisits_MTD,0),ISNULL(NoOfProdVisits_MTD,0),MTDVolume,flgStarOutlet,IsVisitedOnLastVisit,IsProductiveOnLastVisit,SaleOnLastVisit FROM #Tmp
	
	/*
	PRINT 'Distribution data'

	DECLARE @strMDX NVARCHAR(max)
	DECLARE @OPEN_QUERY NVARCHAR(max)  
	DECLARE @LinkedServerName NVARCHAR(50) 
	DECLARE @GroupStr VARCHAR(2000)  
	DECLARE @strMDXProduct NVARCHAR(4000)
	DECLARE @strMDXTime NVARCHAR(4000) 
	DECLARE @strFilter NVARCHAR(MAX)
	DECLARE @MaxNodeType TINYINT

	CREATE TABLE #TmpProduct (NodeID INT, NodeType INT)  
	CREATE TABLE #TmpTime (TimeVal VARCHAR(50),NodeType int)

	CREATE TABLE #LastYearData(RouteId VARCHAR(200),RouteNodeType VARCHAR(20),BrandId VARCHAR(20),ProdStores INT,Ordr INT)
	CREATE TABLE #YTDData(RouteId VARCHAR(200),RouteNodeType VARCHAR(20),BrandId VARCHAR(20),ProdStores INT,NewStore INT,Ordr INT)
	CREATE TABLE #MTDData(RouteId VARCHAR(200),RouteNodeType VARCHAR(20),BrandId VARCHAR(20),ProdStores INT,NewStore INT,Ordr INT)

	SET @LinkedServerName='LTFoods'  

	SELECT BrandId,BrandName INTO #BrandLIst FROM tblBrandMstrMain WHERE BrandID IN(4,5,8,12,34,36,40,47) 
	--SELECT * FROM #BrandLIst

	SELECT @strMDXProduct=''
	SELECT @strMDXProduct= @strMDXProduct+'[ProductHierarchy].[Brand].&['+CAST(BrandID AS VARCHAR(200)) +'],' FROM #BrandLIst

	IF @strMDXProduct <>''  
		SET @strMDXProduct=left(@strMDXProduct,LEN(@strMDXProduct)-1)


	PRINT 'Last Year Data'
	INSERT INTO #TmpTime(TimeVal,NodeType)
	SELECT 201810,3
	UNION
	SELECT 201811,3
	UNION
	SELECT 201812,3
	--SELECT DISTINCT RptMonthYear,3 FROM tblOlapTimeHierarchy_Day WHERE RptMonthYear>=201804
	--SELECT * FROM #TmpTime
				
	SET @strMDXTime=''
	SET @MaxNodeType=0  
	SELECT @MaxNodeType=MAX(NodeType) FROM #TmpTime     
	
	IF @MaxNodeType=1
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Date].&['+convert(varchar(10),convert(datetime,TimeVal) ,121)+'T00:00:00],' from #TmpTime 
	ELSE IF @MaxNodeType=2
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Week Ending].&['+convert(varchar(10),convert(datetime,TimeVal) ,121)+'T00:00:00],' from #TmpTime  
	ELSE IF @MaxNodeType=3
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Month].&['+TimeVal +'],' from #TmpTime  
	ELSE IF @MaxNodeType=4
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Year].&['+TimeVal +'],' from #TmpTime  
	PRINT '@strMDXTime-' + @strMDXTime

	IF @strMDXTime <>''  
		SET @strMDXTime=left(@strMDXTime,LEN(@strMDXTime)-1)

	SET @strFilter=''  
	IF @strMDXTime<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
	--IF @strMDXProduct<>''  
	--	SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

	SET @GroupStr=''  
	SET @GroupStr=@GroupStr + '[CompanySalesStructure].[RouteId].[RouteId].MEMBERS*[CompanySalesStructure].[RouteNodeType].[RouteNodeType].MEMBERS'
	PRINT 'GroupStr-' + @GroupStr

	SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
	SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'
		
	IF @strMDXTime<>''  
		SET @strMDX=@strMDX+')'
	--IF @strMDXProduct<>''  
	--	SET @strMDX=@strMDX+')'	

	PRINT @strMDX   
	SET  @OPEN_QUERY =N'SELECT *  FROM OpenQuery ("'+@LinkedServerName+'",'''+ @strMDX + ''')'  

	PRINT 'OPEN_QUERY-' +@OPEN_QUERY
	--BEGIN TRY  
		IF @strMDXTime<>''
		BEGIN
			INSERT INTO #LastYearData(RouteId,RouteNodeType,ProdStores)
			EXECUTE SP_EXECUTESQL @OPEN_QUERY 
		END
	--END TRY  
	--BEGIN CATCH  
	--	--SELECT ERROR_NUMBER() AS ErrorNumber   
	--END CATCH 
	UPDATE #LastYearData SET BrandId=-1
	UPDATE #LastYearData  SET Ordr=1
	--SELECT * FROM #LastYearData ORDER BY RouteNodeType,RouteId

	PRINT 'Last Year Brand Wise'
	SET @GroupStr=''  
	SET @GroupStr=@GroupStr + '[CompanySalesStructure].[RouteId].[RouteId].MEMBERS*[CompanySalesStructure].[RouteNodeType].[RouteNodeType].MEMBERS*[ProductHierarchy].[BrandId].MEMBERS'
	PRINT 'GroupStr-' + @GroupStr		
	 
	SET @strFilter=''  

	IF @strMDXTime<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
	IF @strMDXProduct<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

	SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
	SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

	IF @strMDXTime<>''  
		SET @strMDX=@strMDX+')'
	IF @strMDXProduct<>''  
		SET @strMDX=@strMDX+')'	

	PRINT @strMDX   
	SET  @OPEN_QUERY =N'SELECT *  FROM OpenQuery ("'+@LinkedServerName+'",'''+ @strMDX + ''')'  

	PRINT 'OPEN_QUERY-' +@OPEN_QUERY
	--BEGIN TRY  
		IF @strMDXTime<>''
		BEGIN
			INSERT INTO #LastYearData(RouteId,RouteNodeType,BrandId,ProdStores)
			EXECUTE SP_EXECUTESQL @OPEN_QUERY 
		END
	--END TRY  
	--BEGIN CATCH  
	--	--SELECT ERROR_NUMBER() AS ErrorNumber   
	--END CATCH 
	UPDATE #LastYearData SET BrandId=0,Ordr=2 WHERE BrandId IS NULL
	UPDATE #LastYearData  SET Ordr=3 WHERE Ordr is nULL 
	ALTER TABLE #LastYearData ALTER COLUMN RouteId INT
	ALTER TABLE #LastYearData ALTER COLUMN RouteNodeType INT
	--SELECT * FROM #LastYearData order by RouteNodeType,RouteId,Ordr,BrandId


	PRINT 'YTD Data'
	TRUNCATE TABLE #TmpTime
	INSERT INTO #TmpTime(TimeVal,NodeType)
	SELECT DISTINCT RptMonthYear,3 FROM tblOlapTimeHierarchy_Day WHERE RptMonthYear>=201904
	--SELECT * FROM #TmpTime
				
	SET @strMDXTime=''
	SET @MaxNodeType=0  
	SELECT @MaxNodeType=MAX(NodeType) FROM #TmpTime     
	
	IF @MaxNodeType=1
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Date].&['+convert(varchar(10),convert(datetime,TimeVal) ,121)+'T00:00:00],' from #TmpTime 
	ELSE IF @MaxNodeType=2
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Week Ending].&['+convert(varchar(10),convert(datetime,TimeVal) ,121)+'T00:00:00],' from #TmpTime  
	ELSE IF @MaxNodeType=3
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Month].&['+TimeVal +'],' from #TmpTime  
	ELSE IF @MaxNodeType=4
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Year].&['+TimeVal +'],' from #TmpTime  
	PRINT '@strMDXTime-' + @strMDXTime

	IF @strMDXTime <>''  
		SET @strMDXTime=left(@strMDXTime,LEN(@strMDXTime)-1)
	
	SET @GroupStr=''  
	SET @GroupStr=@GroupStr + '[CompanySalesStructure].[RouteId].[RouteId].MEMBERS*[CompanySalesStructure].[RouteNodeType].[RouteNodeType].MEMBERS'
	PRINT 'GroupStr-' + @GroupStr		
	 
	SET @strFilter=''  

	IF @strMDXTime<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
	--IF @strMDXProduct<>''  
	--	SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

	SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered],[Measures].[New Stores Distribution Ordered]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
	SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

	IF @strMDXTime<>''  
		SET @strMDX=@strMDX+')'
	--IF @strMDXProduct<>''  
	--	SET @strMDX=@strMDX+')'	

	PRINT @strMDX   
	SET  @OPEN_QUERY =N'SELECT *  FROM OpenQuery ("'+@LinkedServerName+'",'''+ @strMDX + ''')'  

	PRINT 'OPEN_QUERY-' +@OPEN_QUERY
	BEGIN TRY  
		IF @strMDXTime<>''
		BEGIN
			INSERT INTO #YTDData(RouteId,RouteNodeType,ProdStores,NewStore)
			EXECUTE SP_EXECUTESQL @OPEN_QUERY 
		END
	END TRY  
	BEGIN CATCH  
		--SELECT ERROR_NUMBER() AS ErrorNumber   
	END CATCH 
	UPDATE #YTDData SET BrandId=-1
	UPDATE #YTDData  SET Ordr=1
	--SELECT * FROM #YTDData

	PRINT 'YTD Brand Wise'
	SET @GroupStr=''  
	SET @GroupStr=@GroupStr + '[CompanySalesStructure].[RouteId].[RouteId].MEMBERS*[CompanySalesStructure].[RouteNodeType].[RouteNodeType].MEMBERS*[ProductHierarchy].[BrandId].MEMBERS'
	PRINT 'GroupStr-' + @GroupStr		
	 
	SET @strFilter=''  

	IF @strMDXTime<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
	IF @strMDXProduct<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

	SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered],[Measures].[New Stores Distribution Ordered]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
	SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

	IF @strMDXTime<>''  
		SET @strMDX=@strMDX+')'
	IF @strMDXProduct<>''  
		SET @strMDX=@strMDX+')'	

	PRINT @strMDX   
	SET  @OPEN_QUERY =N'SELECT *  FROM OpenQuery ("'+@LinkedServerName+'",'''+ @strMDX + ''')'  

	PRINT 'OPEN_QUERY-' +@OPEN_QUERY
	BEGIN TRY  
		IF @strMDXTime<>''
		BEGIN
			INSERT INTO #YTDData(RouteId,RouteNodeType,BrandId,ProdStores,NewStore)
			EXECUTE SP_EXECUTESQL @OPEN_QUERY 
		END
	END TRY  
	BEGIN CATCH  
		--SELECT ERROR_NUMBER() AS ErrorNumber   
	END CATCH 
	UPDATE #YTDData SET BrandId=0,Ordr=2 WHERE BrandId IS NULL
	UPDATE #YTDData  SET Ordr=3 WHERE Ordr is nULL 
	ALTER TABLE #YTDData ALTER COLUMN RouteId INT
	ALTER TABLE #YTDData ALTER COLUMN RouteNodeType INT
	--SELECT * FROM #YTDData order by RouteNodeType,RouteId,Ordr,BrandId

	
	PRINT 'MTD Data'
	TRUNCATE TABLE #TmpTime
	INSERT INTO #TmpTime(TimeVal,NodeType)
	SELECT @RptMonthYear,3
	--select 201901,3
	--SELECT * FROM #TmpTime
				
	SET @strMDXTime=''
	SET @MaxNodeType=0  
	SELECT @MaxNodeType=MAX(NodeType) FROM #TmpTime     
	
	IF @MaxNodeType=1
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Date].&['+convert(varchar(10),convert(datetime,TimeVal) ,121)+'T00:00:00],' from #TmpTime 
	ELSE IF @MaxNodeType=2
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Week Ending].&['+convert(varchar(10),convert(datetime,TimeVal) ,121)+'T00:00:00],' from #TmpTime  
	ELSE IF @MaxNodeType=3
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Month].&['+TimeVal +'],' from #TmpTime  
	ELSE IF @MaxNodeType=4
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Year].&['+TimeVal +'],' from #TmpTime  
	PRINT '@strMDXTime-' + @strMDXTime
	 
	IF @strMDXTime <>''  
		SET @strMDXTime=left(@strMDXTime,LEN(@strMDXTime)-1)

	SET @GroupStr=''  
	SET @GroupStr=@GroupStr + '[CompanySalesStructure].[RouteId].[RouteId].MEMBERS*[CompanySalesStructure].[RouteNodeType].[RouteNodeType].MEMBERS'
	PRINT 'GroupStr-' + @GroupStr
			 
	SET @strFilter=''  

	IF @strMDXTime<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
	--IF @strMDXProduct<>''  
	--	SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

	SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered],[Measures].[New Stores Distribution Ordered]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
	SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

	IF @strMDXTime<>''  
		SET @strMDX=@strMDX+')'
	--IF @strMDXProduct<>''  
	--	SET @strMDX=@strMDX+')'	

	PRINT @strMDX  
	SET @OPEN_QUERY='' 
	SET  @OPEN_QUERY =N'SELECT *  FROM OpenQuery ("'+@LinkedServerName+'",'''+ @strMDX + ''')'  

	PRINT 'OPEN_QUERY-' +@OPEN_QUERY
	BEGIN TRY  
		IF @strMDXTime<>''
		BEGIN
			INSERT INTO #MTDData(RouteId,RouteNodeType,ProdStores,NewStore)
			EXECUTE SP_EXECUTESQL @OPEN_QUERY 
		END
	END TRY  
	BEGIN CATCH  
		--SELECT ERROR_NUMBER() AS ErrorNumber   
	END CATCH 

	UPDATE #MTDData SET BrandId=-1
	UPDATE #MTDData  SET Ordr=1
	--SELECT * FROM #MTDData --order by lastlvlid

	PRINT 'MTD Brand Wise'
	SET @GroupStr=''  
	SET @GroupStr=@GroupStr + '[CompanySalesStructure].[RouteId].[RouteId].MEMBERS*[CompanySalesStructure].[RouteNodeType].[RouteNodeType].MEMBERS*[ProductHierarchy].[BrandId].MEMBERS'
	PRINT 'GroupStr-' + @GroupStr		
	 
	SET @strFilter=''  

	IF @strMDXTime<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
	IF @strMDXProduct<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

	SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered],[Measures].[New Stores Distribution Ordered]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
	SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

	IF @strMDXTime<>''  
		SET @strMDX=@strMDX+')'
	IF @strMDXProduct<>''  
		SET @strMDX=@strMDX+')'	

	PRINT @strMDX   
	SET  @OPEN_QUERY =N'SELECT *  FROM OpenQuery ("'+@LinkedServerName+'",'''+ @strMDX + ''')'  

	PRINT 'OPEN_QUERY-' +@OPEN_QUERY
	BEGIN TRY  
		IF @strMDXTime<>''
		BEGIN
			INSERT INTO #MTDData(RouteId,RouteNodeType,BrandId,ProdStores,NewStore)
			EXECUTE SP_EXECUTESQL @OPEN_QUERY 
		END
	END TRY  
	BEGIN CATCH  
		--SELECT ERROR_NUMBER() AS ErrorNumber   
	END CATCH 
	UPDATE #MTDData SET BrandId=0,Ordr=2 WHERE BrandId IS NULL
	UPDATE #MTDData  SET Ordr=3 WHERE Ordr is nULL 
	ALTER TABLE #MTDData ALTER COLUMN RouteId INT
	ALTER TABLE #MTDData ALTER COLUMN RouteNodeType INT
	--SELECT * FROM #MTDData order by RouteNodeType,RouteId,Ordr,BrandId

	TRUNCATE TABLE tblRptDistributionDataForBeat

	SELECT NodeId RouteId,NodeType RouteNodeType INTO #RouteList FROM tblCompanySalesStructureRouteMstr
	UNION
	SELECT NodeId,NodeType FROM tblDBRSalesStructureRouteMstr
	--SELECT * FROM #RouteList

	INSERT INTO tblRptDistributionDataForBeat(AreaNodeId,AreaNodeType,PrdNodeId,PrdNodeType,DataLvl,LastYearProdStores,YTD_Distribution,YTD_NewlyAdded,MTD_Distribution, MTD_NewlyAdded,RptMonthYear,TimeStampIns,Ordr)
	SELECT RouteId,RouteNodeType,-1,-1,'Overall',0,0,0,0,0,@RptMonthYear,GETDATE(),1 FROM #RouteList
	UNION
	SELECT RouteId,RouteNodeType,0,0,'Focus Brands',0,0,0,0,0,@RptMonthYear,GETDATE(),2 FROM #RouteList
	UNION
	SELECT A.RouteId,A.RouteNodeType,B.BrandId,0,B.BrandName,0,0,0,0,0,@RptMonthYear,GETDATE(),3 FROM #RouteList A,#BrandList B

	UPDATE A SET A.LastYearProdStores=ISNULL(B.ProdStores,0)
	FROM tblRptDistributionDataForBeat A INNER JOIN #LastYearData B ON A.AreaNodeId=B.RouteId AND A.AreaNodeType=B.RouteNodeType AND A.PrdNodeId=B.BrandId

	UPDATE A SET A.YTD_Distribution=ISNULL(B.ProdStores,0),A.YTD_NewlyAdded=ISNULL(B.NewStore,0)
	FROM tblRptDistributionDataForBeat A INNER JOIN #YTDData B ON A.AreaNodeId=B.RouteId AND A.AreaNodeType=B.RouteNodeType AND A.PrdNodeId=B.BrandId

	UPDATE A SET A.MTD_Distribution=ISNULL(B.ProdStores,0),A.MTD_NewlyAdded=ISNULL(B.NewStore,0)
	FROM tblRptDistributionDataForBeat A INNER JOIN #MTDData B ON A.AreaNodeId=B.RouteId AND A.AreaNodeType=B.RouteNodeType AND A.PrdNodeId=B.BrandId

	--SELECT TOp 2 * from tblRptDistributionDataForBeat
	*/
END

