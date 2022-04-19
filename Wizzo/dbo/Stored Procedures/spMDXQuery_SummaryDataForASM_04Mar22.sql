
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spMDXQuery_SummaryDataForASM]'E7682784-6339-4C80-B795-552E9B7C293C','01-Jan-2022',0,0
CREATE Procedure [dbo].[spMDXQuery_SummaryDataForASM_04Mar22]
@IMEINO VARCHAR(50),
@RptDate DATE,
@CoverageAreaNodeID INT,
@CoverageAreaNodeType SMALLINT
AS
BEGIN
	DECLARE @YesterdayDate DATE
	SELECT @YesterdayDate=DATEADD(dd,-1,@RptDate)
	--SELECT @YesterdayDate='25-Feb-2019'

	DECLARE @strMDX NVARCHAR(max)
	DECLARE @OPEN_QUERY NVARCHAR(max)  
	DECLARE @LinkedServerName NVARCHAR(50) 
	DECLARE @GroupStr VARCHAR(2000)  
	DECLARE @MaxNodeType TINYINT  
	DECLARE @strSQL VARCHAR(max)
	DECLARE @strMDXProduct NVARCHAR(4000)  
	DECLARE @strMDXSalesStructure NVARCHAR(4000)
	DECLARE @strMDXTime NVARCHAR(4000)  
	DECLARE @strMDXChannel NVARCHAR(1000) 
	DECLARE @strFilter NVARCHAR(MAX)

	DECLARE @PDAID INT  
	DECLARE @PDAPersonID INT  
	DECLARE @PDAPersonType INT  
	
	CREATE TABLE #TempCompanySales(HierId VARCHAR(50), SalesLvl INT) 
	CREATE TABLE #TmpProduct (NodeID INT, NodeType INT)  
	CREATE TABLE #TmpTime (TimeVal VARCHAR(50),NodeType int) 

	CREATE TABLE #Distribution(BrandId INT,[Description] VARCHAR(200),[Active_Cov] INT,YTD INT,P3M INT,MTD INT,[YesterDay] INT,[New_Dstrbn] INT,[Dstrbn_Lost] INT,flgCollapse TINYINT,flgLevel TINYINT,Ordr INT)
	CREATE TABLE #Distribution2X(BrandId INT,[Description] VARCHAR(200),[Active_Cov] INT,YTD INT,P3M INT,MTD INT,[YesterDay] INT,[New_Dstrbn] INT,[Dstrbn_Lost] INT,flgCollapse TINYINT,flgLevel TINYINT,Ordr INT)
	CREATE TABLE #SecVol(BrandId INT,[Description] VARCHAR(200),MTD_Tgt  VARCHAR(10),MTD_TillDate INT,Yesterday INT,[RR Required] VARCHAR(10),flgCollapse TINYINT,flgLevel TINYINT,Ordr INT)
	CREATE TABLE #PrimaryVol(BrandId INT,[Description] VARCHAR(200),MTD_Tgt VARCHAR(10),MTD_Delivered VARCHAR(10),[Pending Delivery] VARCHAR(10),Yesterday VARCHAR(10),flgCollapse TINYINT,flgLevel TINYINT,Ordr INT)
	CREATE TABLE #ManDays(ValueType INT,PersonType INT,[Description] VARCHAR(200),Planned INT,[In Field_YTD] INT,[In Field_P3M] INT,[In Field_MTD] INT,[In Field_Yesterday] INT,flgCollapse TINYINT,Ordr INT)
	CREATE TABLE #SalesmanData (CovAreaNodeId INT,CovAreaNodeType INT,PersonNodeID INT,[Description] VARCHAR(100),Dstrbn_MTD INT,Dstrbn_Yesterday INT,Sales_MTD VARCHAR(10),Sales_Yesterday VARCHAR(10),Visits_Yesterday VARCHAR(10),flgCollapse TINYINT,flgLevel TINYINT,Ordr INT)
	
	CREATE TABLE #YTDData(ASMArea VARCHAR(200),BrandId VARCHAR(20),ProdStores INT,Ordr INT)
	CREATE TABLE #MTDData(ASMArea VARCHAR(200),BrandId VARCHAR(20),ProdStores INT,SecVol FLOAT,PlannedVisitCount INT,PlannedStores INT,ActualVisitCount INT,ActualStoresVisited INT,Ordr INT)
	CREATE TABLE #YesterdayData(ASMArea VARCHAR(200),BrandId VARCHAR(20),ProdStores INT,NewStore INT,SecVol FLOAT,PlannedVisitCount INT,PlannedStores INT,ActualVisitCount INT,ActualStoresVisited INT,Ordr INT)

	CREATE TABLE #MTDData_SalesmanWise(ASMArea VARCHAR(200),CovAreaNodeId VARCHAR(20),CovAreaNodeType VARCHAR(20),ProdStores INT,SecVol FLOAT,Ordr INT)
	CREATE TABLE #YesterdayData_SalesmanWise(ASMArea VARCHAR(200),CovAreaNodeId VARCHAR(20),CovAreaNodeType VARCHAR(20),ProdStores INT,SecVol FLOAT,ActualVisitCount INT,Ordr INT)
	
	DECLARE @ActiveCoverage INT=0


	SET @LinkedServerName='RajTrader'  

	IF @IMEINo<>''
	BEGIN
		SELECT @PDAPersonID=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@IMEIno) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
		SELECT @PDAPersonType=PersonType FROM tblSalesPersonMapping WHERE PersonNodeID=@PDAPersonID
		 --SELECT @PDAPersonID=144
		 --SELECT @PDAPersonID=26
		 PRINT '@PDAPersonID=' + CAST(@PDAPersonID AS VARCHAR)
		 IF @CoverageAreaNodeID>0 AND @CoverageAreaNodeType IN (220,230)
		 BEGIN
			INSERT INTO #TempCompanySales(HierId,SalesLvl)
			 SELECT DISTINCT B.CoverageAreaHierID,5
			 FROM tblSalesPersonmapping A INNER JOIN tblOLApFullSalesHierarchy B ON A.NodeId=B.CoverageAreaID AND A.NodeType=B.CoverageAreaNodeType
			 WHERE A.NodeID=@CoverageAreaNodeID AND A.NodeType=@CoverageAreaNodeType AND (CAST(GETDATE() AS DATE) BETWEEN A.FromDate AND A.ToDate)
		
		 END
		 ELSE
		 BEGIN
			 INSERT INTO #TempCompanySales(HierId,SalesLvl)
			 SELECT DISTINCT B.ASMAreaHierID,2
			 FROM tblSalesPersonmapping A INNER JOIN tblOLApFullSalesHierarchy B ON A.NodeId=B.ASMAreaID AND A.NodeType=B.ASMAreaNodeType
			 WHERE A.PersonNodeId=@PDAPersonID AND (CAST(GETDATE() AS DATE) BETWEEN A.FromDate AND A.ToDate)
		 END

		 IF @CoverageAreaNodeID>0 AND @CoverageAreaNodeType IN (220,230)
		 BEGIN
			INSERT INTO #SalesmanData(CovAreaNodeId,CovAreaNodeType,PersonNodeID,Description,Dstrbn_MTD,Dstrbn_Yesterday,Sales_MTD,Sales_Yesterday,Visits_Yesterday,flgCollapse,flgLevel,Ordr)
			 SELECT DISTINCT V.CoverageAreaID,V.CoverageAreaNodeType,SM.PersonNodeID,P.Descr,0,0,0,0,0,0,1,1 
			 FROM tblOLApFullSalesHierarchy V INNER JOIN tblSalesPersonMapping SM ON SM.NodeID=V.CoverageAreaID AND SM.NodeType=V.CoverageAreaNodeType INNER JOIN tblMstrPerson P ON P.NodeID=SM.PersonNodeID AND (CAST(GETDATE() AS DATE) BETWEEN SM.FromDate AND SM.ToDate)
			 WHERE V.CoverageAreaNodeType=@CoverageAreaNodeType AND V.CoverageAreaID=@CoverageAreaNodeID
		 END
		 ELSE
		 BEGIN
			 INSERT INTO #SalesmanData(CovAreaNodeId,CovAreaNodeType,PersonNodeID,Description,Dstrbn_MTD,Dstrbn_Yesterday,Sales_MTD,Sales_Yesterday,Visits_Yesterday,flgCollapse,flgLevel,Ordr)
			 SELECT DISTINCT V.CoverageAreaID,V.CoverageAreaNodeType,SM.PersonNodeID,P.Descr,0,0,0,0,0,0,1,1 
			 FROM tblOLApFullSalesHierarchy V INNER JOIN tblSalesPersonMapping SM ON SM.NodeID=V.CoverageAreaID AND SM.NodeType=V.CoverageAreaNodeType INNER JOIN tblMstrPerson P ON P.NodeID=SM.PersonNodeID AND (CAST(GETDATE() AS DATE) BETWEEN SM.FromDate AND SM.ToDate) INNER JOIN tblSalesPersonmapping B ON B.NodeID=V.ASMAreaID AND B.NodeType=V.ASMAreaNodeType AND (CAST(GETDATE() AS DATE) BETWEEN B.FromDate AND B.ToDate)
			 WHERE B.PersonNodeID=@PDAPersonID
			 UNION
			SELECT 0,0,0,'Total',0,0,0,0,0,0,2,2
		END
	 END
	--SELECT * FROM #TempCompanySales
	
	IF EXISTS(SELECT 1 FROM #TempCompanySales)
	BEGIN
		--SELECT 1
		SET @strMDXSalesStructure=''  
		SET @MaxNodeType=0  
		SELECT @MaxNodeType=MAX(SalesLvl) FROM #TempCompanySales 	 

		IF @MaxNodeType=0
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Zone].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=0  

			SELECT @ActiveCoverage=AA.ActiveCoverage FROM (SELECT COUNT(DISTINCT A.StoreID) AS ActiveCoverage FROM tblOLAPFullSalesHierarchy A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=B.StoreID INNER JOIN #TempCompanySales C ON A.ZoneHierID=C.HierId WHERE (@YesterdayDate BETWEEN  B.FromDate AND B.ToDate)) AA
		END
		ELSE IF @MaxNodeType=1
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Region].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=1  

			SELECT @ActiveCoverage=AA.ActiveCoverage FROM (SELECT COUNT(DISTINCT A.StoreID) AS ActiveCoverage FROM tblOLAPFullSalesHierarchy A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=B.StoreID INNER JOIN #TempCompanySales C ON A.RegionHierID=C.HierId WHERE (@YesterdayDate BETWEEN  B.FromDate AND B.ToDate)) AA
			--SELECT @ActiveCoverage
		END
		ELSE IF @MaxNodeType=2
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[ASM Area].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=2

			SELECT @ActiveCoverage=AA.ActiveCoverage FROM (SELECT COUNT(DISTINCT A.StoreID) AS ActiveCoverage FROM tblOLAPFullSalesHierarchy A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=B.StoreID INNER JOIN #TempCompanySales C ON A.ASMAreaHierID=C.HierId WHERE (@YesterdayDate BETWEEN  B.FromDate AND B.ToDate)) AA
			--SELECT @ActiveCoverage
		END
		ELSE IF @MaxNodeType=3
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[SO Area].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=3

			SELECT @ActiveCoverage=AA.ActiveCoverage FROM (SELECT COUNT(DISTINCT A.StoreID) AS ActiveCoverage FROM tblOLAPFullSalesHierarchy A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=B.StoreID INNER JOIN #TempCompanySales C ON A.SOAreaHierID=C.HierId WHERE (@YesterdayDate BETWEEN  B.FromDate AND B.ToDate)) AA
		END
		ELSE IF @MaxNodeType=4
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Distributor].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=4

			SELECT @ActiveCoverage=AA.ActiveCoverage FROM (SELECT COUNT(DISTINCT A.StoreID) AS ActiveCoverage FROM tblOLAPFullSalesHierarchy A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=B.StoreID INNER JOIN #TempCompanySales C ON A.DBRHierID=C.HierId WHERE (@YesterdayDate BETWEEN  B.FromDate AND B.ToDate)) AA
		END
		ELSE IF @MaxNodeType=5
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Coverage Area].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=5

			SELECT @ActiveCoverage=AA.ActiveCoverage FROM (SELECT COUNT(DISTINCT A.StoreID) AS ActiveCoverage FROM tblOLAPFullSalesHierarchy A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=B.StoreID INNER JOIN #TempCompanySales C ON A.CoverageAreaHierID=C.HierId WHERE (@YesterdayDate BETWEEN  B.FromDate AND B.ToDate)) AA
		END
		ELSE IF @MaxNodeType=6
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Route].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=6

			SELECT @ActiveCoverage=AA.ActiveCoverage FROM (SELECT COUNT(DISTINCT A.StoreID) AS ActiveCoverage FROM tblOLAPFullSalesHierarchy A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=B.StoreID INNER JOIN #TempCompanySales C ON A.RouteHierId=C.HierId WHERE (@YesterdayDate BETWEEN  B.FromDate AND B.ToDate)) AA
		END
		--SELECT @ActiveCoverage

		IF @strMDXSalesStructure <>''  
			SET @strMDXSalesStructure=left(@strMDXSalesStructure,LEN(@strMDXSalesStructure)-1) 
		
		SELECT DISTINCT CategoryNodeID INTO #CatList FROM VwSFAProductHierarchy WHERE IsActive=1

		SELECT @strMDXProduct=''
		SELECT @strMDXProduct= @strMDXProduct+'[ProductHierarchy].[Category].&['+CAST(CategoryNodeID AS VARCHAR(200)) +'],' FROM #CatList

		
		IF @strMDXProduct <>''  
			SET @strMDXProduct=left(@strMDXProduct,LEN(@strMDXProduct)-1)
		

		PRINT 'YTD Data'
		INSERT INTO #TmpTime(TimeVal,NodeType)
		SELECT DISTINCT RptMonthYear,3 FROM tblOlapTimeHierarchy_Day WHERE RptMonthYear>=202104
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
		/*
		SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS'
		PRINT 'GroupStr-' + @GroupStr		
	 
		SET @strFilter=''  

		IF @strMDXSalesStructure<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXSalesStructure+'}) ON COLUMNS '  
		IF @strMDXTime<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
		--IF @strMDXProduct<>''  
		--	SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

		SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '
			  
		SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

		IF @strMDXSalesStructure<>''  
			SET @strMDX=@strMDX+')' 
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
				INSERT INTO #YTDData(ASMArea,ProdStores)
				EXECUTE SP_EXECUTESQL @OPEN_QUERY 
			END
		END TRY  
		BEGIN CATCH  
		   --SELECT ERROR_NUMBER() AS ErrorNumber   
		END CATCH 
		UPDATE #YTDData SET BrandId=-1
		UPDATE #YTDData  SET Ordr=1
		SELECT * FROM #YTDData
		*/

		PRINT 'YTD Brand Wise'
		SET @GroupStr=''  
		SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS*[ProductHierarchy].[CategoryNodeId].MEMBERS'
		PRINT 'GroupStr-' + @GroupStr		
	 
		SET @strFilter=''  

		IF @strMDXSalesStructure<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXSalesStructure+'}) ON COLUMNS '  
		IF @strMDXTime<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
		IF @strMDXProduct<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

		SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '
			  
		SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

		IF @strMDXSalesStructure<>''  
			SET @strMDX=@strMDX+')' 
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
				INSERT INTO #YTDData(ASMArea,BrandId,ProdStores)
				EXECUTE SP_EXECUTESQL @OPEN_QUERY 
			END
		END TRY  
		BEGIN CATCH  
		   --SELECT ERROR_NUMBER() AS ErrorNumber   
		END CATCH 
		UPDATE #YTDData SET BrandId=0,Ordr=2 WHERE BrandId IS NULL
		UPDATE #YTDData  SET Ordr=3 WHERE Ordr is nULL 
		--SELECT * FROM #YTDData order by Ordr,BrandId


		PRINT 'MTD Data'
		TRUNCATE TABLE #TmpTime
		INSERT INTO #TmpTime(TimeVal,NodeType)
		SELECT CONVERT(VARCHAR(6),@YesterdayDate,112),3
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
		/*
		SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS'
		PRINT 'GroupStr-' + @GroupStr
			 
		SET @strFilter=''  

		IF @strMDXSalesStructure<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXSalesStructure+'}) ON COLUMNS '  
		IF @strMDXTime<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
		--IF @strMDXProduct<>''  
		--	SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

		SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered],[Measures].[Net Order Volume in Kgs]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
		SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

		IF @strMDXSalesStructure<>''  
			SET @strMDX=@strMDX+')' 
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
				INSERT INTO #MTDData(ASMArea,ProdStores,SecVol)
				EXECUTE SP_EXECUTESQL @OPEN_QUERY 
			END
		END TRY  
		BEGIN CATCH  
		   --SELECT ERROR_NUMBER() AS ErrorNumber   
		END CATCH 

		UPDATE #MTDData SET BrandId=-1
		UPDATE #MTDData  SET Ordr=1
		SELECT * FROM #MTDData --order by lastlvlid
		*/
		PRINT 'MTD Brand Wise'
		SET @GroupStr=''  
		SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS*[ProductHierarchy].[CategoryNodeId].MEMBERS'
		PRINT 'GroupStr-' + @GroupStr		
	 
		SET @strFilter=''  

		IF @strMDXSalesStructure<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXSalesStructure+'}) ON COLUMNS '  
		IF @strMDXTime<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
		IF @strMDXProduct<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

		SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered],[Measures].[Net Order Volume in Kgs],[Measures].[Planned Visit Count],[Measures].[Actual Visit Count],[Measures].[Planned Store Count],[Measures].[Actual Stores Visited]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
		SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

		IF @strMDXSalesStructure<>''  
			SET @strMDX=@strMDX+')' 
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
				INSERT INTO #MTDData(ASMArea,BrandId,ProdStores,SecVol,PlannedVisitCount,ActualVisitCount,PlannedStores,ActualStoresVisited)
				EXECUTE SP_EXECUTESQL @OPEN_QUERY 
			END
		END TRY  
		BEGIN CATCH  
		   --SELECT ERROR_NUMBER() AS ErrorNumber   
		END CATCH 
		UPDATE #MTDData SET BrandId=0,Ordr=2 WHERE BrandId IS NULL
		UPDATE #MTDData  SET Ordr=3 WHERE Ordr is nULL 

		--SELECT * FROM #MTDData order by Ordr,BrandId

		PRINT 'MTD Salesman Wise'
		SET @GroupStr=''  
		SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS*[SalesStructure].[CoverageAreaId].[CoverageAreaId].MEMBERS*[SalesStructure].[CoverageAreaNodeType].[CoverageAreaNodeType].MEMBERS'
		PRINT 'GroupStr-' + @GroupStr		
	 
		SET @strFilter=''  

		IF @strMDXSalesStructure<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXSalesStructure+'}) ON COLUMNS '  
		IF @strMDXTime<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
		IF @strMDXProduct<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

		SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered],[Measures].[Net Order Volume in Kgs]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
		SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

		IF @strMDXSalesStructure<>''  
			SET @strMDX=@strMDX+')' 
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
				INSERT INTO #MTDData_SalesmanWise(ASMArea,CovAreaNodeId,CovAreaNodeType,ProdStores,SecVol)
				EXECUTE SP_EXECUTESQL @OPEN_QUERY 
			END
		END TRY  
		BEGIN CATCH  
		   --SELECT ERROR_NUMBER() AS ErrorNumber   
		END CATCH 
		--UPDATE #MTDData_SalesmanWise  SET Ordr=1 WHERE Ordr is nULL 
		ALTER TABLE #MTDData_SalesmanWise ALTER COLUMN CovAreaNodeId INT
		ALTER TABLE #MTDData_SalesmanWise ALTER COLUMN CovAreaNodeType INT

		--SELECT * FROM #MTDData_SalesmanWise order by CovAreaNodeType,CovAreaNodeId


		PRINT 'Yesterday Data'
		--TRUNCATE TABLE #TmpTime
		--INSERT INTO #TmpTime(TimeVal,NodeType)
		----SELECT CONVERT(VARCHAR,DATEADD(dd,-1,@RptDate),112),1
		--select 20190225,1
		----select 20190104,1
		----SELECT * FROM #TmpTime
	
		SELECT @strMDXTime=''
		SELECT @strMDXTime= @strMDXTime+'[TimeHierarchyDayLevel].[Date].&['+convert(varchar(10),convert(datetime,@YesterdayDate) ,121)+'T00:00:00]' from #TmpTime 	
		PRINT '@strMDXTime-' + @strMDXTime

		SET @GroupStr=''  
		/*
		SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS'
		PRINT 'GroupStr-' + @GroupStr
			 
		SET @strFilter=''  

		IF @strMDXSalesStructure<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXSalesStructure+'}) ON COLUMNS '  
		IF @strMDXTime<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
		--IF @strMDXProduct<>''  
		--	SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

		SET @strMDX='SELECT {[Measures].[New Stores Distribution Ordered],[Measures].[Net Order Volume in Kgs]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
		SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

		IF @strMDXSalesStructure<>''  
			SET @strMDX=@strMDX+')' 
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
				INSERT INTO #YesterdayData(ASMArea,NewStore,SecVol)
				EXECUTE SP_EXECUTESQL @OPEN_QUERY 
			END
		END TRY  
		BEGIN CATCH  
		   --SELECT ERROR_NUMBER() AS ErrorNumber   
		END CATCH 

		UPDATE #YesterdayData SET BrandId=-1
		UPDATE #YesterdayData  SET Ordr=1
		SELECT * FROM #YesterdayData --order by lastlvlid
		*/

		PRINT 'Yesterday Brand Wise'
		SET @GroupStr=''  
		SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS*[ProductHierarchy].[CategoryNodeId].MEMBERS'
		PRINT 'GroupStr-' + @GroupStr		
	 
		SET @strFilter=''  

		IF @strMDXSalesStructure<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXSalesStructure+'}) ON COLUMNS '  
		IF @strMDXTime<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
		IF @strMDXProduct<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

		SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered],[Measures].[New Stores Distribution Ordered],[Measures].[Net Order Volume in Kgs],[Measures].[Planned Visit Count],[Measures].[Actual Visit Count],[Measures].[Planned Store Count],[Measures].[Actual Stores Visited]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
		SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

		IF @strMDXSalesStructure<>''  
			SET @strMDX=@strMDX+')' 
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
				INSERT INTO #YesterdayData(ASMArea,BrandId,ProdStores,NewStore,SecVol,PlannedVisitCount,ActualVisitCount,PlannedStores,ActualStoresVisited)
				EXECUTE SP_EXECUTESQL @OPEN_QUERY 
			END
		END TRY  
		BEGIN CATCH  
		   --SELECT ERROR_NUMBER() AS ErrorNumber   
		END CATCH 
		UPDATE #YesterdayData SET BrandId=0,Ordr=2 WHERE BrandId IS NULL
		UPDATE #YesterdayData  SET Ordr=3 WHERE Ordr is nULL 

		--SELECT * FROM #YesterdayData order by Ordr,BrandId
		
		PRINT 'Yesterday Salesman Wise'
		SET @GroupStr=''  
		SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS*[SalesStructure].[CoverageAreaId].[CoverageAreaId].MEMBERS*[SalesStructure].[CoverageAreaNodeType].[CoverageAreaNodeType].MEMBERS'
		PRINT 'GroupStr-' + @GroupStr		
	 
		SET @strFilter=''  

		IF @strMDXSalesStructure<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXSalesStructure+'}) ON COLUMNS '  
		IF @strMDXTime<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
		IF @strMDXProduct<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 

		SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered],[Measures].[Net Order Volume in Kgs],[Measures].[Actual Visit Count]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
		SET @strMDX=@strMDX + @strFilter + '  FROM [cubAll_Day]'

		IF @strMDXSalesStructure<>''  
			SET @strMDX=@strMDX+')' 
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
				INSERT INTO #YesterdayData_SalesmanWise(ASMArea,CovAreaNodeId,CovAreaNodeType,ProdStores,SecVol,ActualVisitCount)
				EXECUTE SP_EXECUTESQL @OPEN_QUERY 
			END
		END TRY  
		BEGIN CATCH  
		   --SELECT ERROR_NUMBER() AS ErrorNumber   
		END CATCH 
		
		--UPDATE #YesterdayData_SalesmanWise  SET Ordr=1 WHERE Ordr is nULL 
		ALTER TABLE #YesterdayData_SalesmanWise ALTER COLUMN CovAreaNodeId INT
		ALTER TABLE #YesterdayData_SalesmanWise ALTER COLUMN CovAreaNodeType INT

		--SELECT * FROM #YesterdayData_SalesmanWise order by CovAreaNodeType,CovAreaNodeId


		PRINT 'feet on street'
		CREATE TABLE #Rslt(RegionId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),SOId INT,SoNodeType INT,CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),SalesmanId INT,SalesmanNodeType INT)

		IF @CoverageAreaNodeID>0
		BEGIN
			INSERT INTO #Rslt(RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,SOId,SoNodeType,CovAreaId,CovAreaNodeType,CovArea, SalesmanId,SalesmanNodeType)
			SELECT DISTINCT RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,0,0,CoverageAreaID,CoverageAreaNodeType,CoverageArea,0,0
			FROM tblOLApFullSalesHierarchy A INNER JOIN #TempCompanySales B ON A.CoverageAreaHierID=B.HierId WHERE B.SalesLvl=5
		END
		ELSE
		BEGIN
			INSERT INTO #Rslt(RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,SOId,SoNodeType,CovAreaId,CovAreaNodeType,CovArea, SalesmanId,SalesmanNodeType)
			SELECT DISTINCT RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,0,0,CoverageAreaID,CoverageAreaNodeType,CoverageArea,0,0
			FROM tblOLApFullSalesHierarchy A INNER JOIN #TempCompanySales B ON A.ASMAreaHierId=B.HierId WHERE B.SalesLvl=2
		END

		UPDATE A SET A.SOId=Mp.NodeId,A.SONodeType=Mp.NodeType 
		FROM #Rslt A INNER JOIN tblsalesPersonMapping SP ON A.SOAreaId=SP.NodeId AND A.SOAreaNodeType=SP.NodeType INNER JOIN tblMstrPerson MP ON SP.PersonNodeID=MP.NodeID 
		WHERE (@RptDate BETWEEN SP.FromDate AND SP.ToDate) --AND (@RptDate BETWEEN MP.FromDate AND MP.ToDate)

		UPDATE A SET A.SalesmanId=Mp.NodeId,A.SalesmanNodeType=Mp.NodeType 
		FROM #Rslt A INNER JOIN tblsalesPersonMapping SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType INNER JOIN tblMstrPerson MP ON SP.PersonNodeID=MP.NodeID 
		WHERE (@RptDate BETWEEN SP.FromDate AND SP.ToDate) --AND (@RptDate BETWEEN MP.FromDate AND MP.ToDate)

		PRINT 'Insertion for SOs where no route is mapped to SO'
		INSERT INTO #Rslt(RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,SOId,SoNodeType,SalesmanId,SalesmanNodeType)
		SELECT DISTINCT A.RegionId,A.RegionNodeType,A.Region,A.ASMAreaId,A.ASMAreaNodeType,A.ASMArea,A.SOAreaId,A.SOAreaNodeType,A.SOArea,A.SOId,A.SoNodeType,A.SOId, A.SoNodeType FROM #Rslt A LEFT OUTER JOIN #Rslt AA ON A.SOId=AA.SalesmanId
		WHERE AA.SalesmanId IS NULL
		--SELECT * FROM #Rslt

		CREATE TABLE #DaysInMomth(RptDate DATE)
		INSERT INTO #DaysInMomth(RptDate)
		SELECT MonthDate FROM dbo.fnGetAllDatesInMonth(@YesterdayDate)
		DELETE FROM #DaysInMomth WHERE RptDate>@YesterdayDate
		--SELECT * FROM #DaysInMomth

		SELECT DISTINCT B.RptDate,A.SalesmanId,A.SalesmanNodeType,0 AS flgOtherWorking,0 AS flgMarketVisit,CASE A.SalesmanNodeType WHEN 220 THEN 1 ELSE 2 END AS PersonType INTO #Working
		FROM #Rslt A CROSS JOIN #DaysInMomth B WHERE SalesmanId<>0 

		CREATE TABLE #OtherWorking(PersonNodeId INT,PersonNodeType INT,VisitDate DATE,ReasonId INT,ReasonText VARCHAR(500),flgNoVisitOption TINYINT DEFAULT 0 NOT NULL)

		SELECT A. * INTO #tmpReasonDetailForNoVisit
		FROM tblReasonDetailForNoVisit A INNER JOIN #Working B ON A.PersonNodeId=B.SalesmanId AND A.VisitDate=B.RptDate
		--SELECT * FROM #tmpReasonDetailForNoVisit

		INSERT INTO #OtherWorking(PersonNodeId,PersonNodeType,VisitDate,ReasonId,ReasonText)
		SELECT A.PersonNodeId,A.PersonNodeType,A.VisitDate,A.ReasonId,A.ReasonText
		FROM tblReasonDetailForNoVisit A INNER JOIN (SELECT PersonNodeId,PersonNodeType,VisitDate,MAX(Id) Id FROM #tmpReasonDetailForNoVisit GROUP BY PersonNodeId,PersonNodeType,VisitDate) B ON A.PersonNodeId=B.PersonNodeId AND A.PersonNodeType=B.PersonNodeType AND A.VisitDate=B.VisitDate AND A.Id=B.Id
		--SELECT * FROM #OtherWorking

		SELECT AA.PersonAttendanceID,AA.PersonNodeId,AA.PersonNodeType,AA.[Datetime],BB.ReasonID,BB.ReasonDescr INTO #tmpOtherWorking_Pre
		FROM tblPersonAttendance AA INNER JOIN PersonAttReason BB oN AA.PersonAttendanceID=BB.PersonAttendanceID
		INNER JOIN #Working B ON AA.PersonNodeId=B.SalesmanId AND CAST(AA.[Datetime] AS DATE)=B.RptDate

		select A.PersonAttendanceID,A.PersonNodeId,A.PersonNodeType,A.[Datetime],A.ReasonID,A.ReasonDescr,0 AS [Priority],0 AS Priority_rank INTO #tmpOtherWorking
		from #tmpOtherWorking_Pre A INNER JOIN (SELECT PersonNodeId,PersonNodeType,MAX([Datetime]) [Datetime] FROM #tmpOtherWorking_Pre WHERE ReasonID<>0 GROUP BY PersonNodeId,PersonNodeType) C ON A.PersonNodeId=C.PersonNodeId AND A.PersonNodeType=C.PersonNodeType AND A.[Datetime]=C.[Datetime]
		ORDER BY A.PersonAttendanceID
	
		UPDATE A SET A.ReasonDescr=B.ReasonDescr FROM #tmpOtherWorking A INNER JOIN tblMstrReasonsForNoVisit B ON A.ReasonID=B.ReasonID WHERE A.ReasonID<>6
		UPDATE A SET A.[Priority]=B.[Priority] FROM #tmpOtherWorking A INNER JOIN tblMstrReasonsForNoVisit B ON A.ReasonID=B.ReasonID

		UPDATE A SET A.Priority_rank=AA.Priority_rank FROM #tmpOtherWorking A INNER JOIN 
		(select  PersonNodeId,PersonNodeType,[Datetime],ReasonID,ReasonDescr,[Priority],DENSE_RANK() over(partition by PersonNodeId order by [Priority]) Priority_rank  From #tmpOtherWorking) AA ON A.PersonNodeID=AA.PersonNodeID AND A.PersonNodeType=AA.PersonNodeType AND A.ReasonID=AA.ReasonID AND A.[Priority]=AA.[Priority]

		--SELECT * FROM #tmpOtherWorking order by Priority_rank,PersonNodeId,[Priority]
	
		INSERT INTO #OtherWorking(PersonNodeId,PersonNodeType,VisitDate,ReasonId,ReasonText)
		SELECT PersonNodeID,PersonNodeType,CAST(Datetime AS DATE),ReasonID,ReasonDescr FROM #tmpOtherWorking WHERE Priority_rank=1
	
		UPDATE A SET A.flgNoVisitOption=B.flgNoVisitOption FROM #OtherWorking A INNER JOIN tblMstrReasonsForNoVisit B ON A.ReasonId=B.ReasonId
		--SELECT * FROM #OtherWorking ORDER BY PersonNodeId
	
		UPDATE A SET A.flgOtherWorking=1 FROM #Working A INNER JOIN #OtherWorking B ON A.SalesmanId=B.PersonNodeId AND A.RptDate=B.VisitDate WHERE ISNULL(B.flgNoVisitOption,0)<>1

		UPDATE A SET A.flgMarketVisit=1 FROM #Working A INNER JOIN tblVisitMaster B ON A.SalesmanId=ISNULL(B.EntryPersonNodeID,B.SalesPersonID) AND A.RptDate=B.VisitDate

		--SELECT * FROM #Working ORDER BY PersonType,SalesmanId,RptDate
		--SELECT * FROM #Rslt ORDER BY SalesmanId--Region,ASMArea
	END

	INSERT INTO #Distribution(BrandId,[Description],Active_Cov,YTD,P3M,MTD,[YesterDay],New_Dstrbn,Dstrbn_Lost,flgCollapse,Ordr,flgLevel)
	SELECT 0,'Overall',0,0,0,0,0,0,0,1,1,1
	UNION
	SELECT DISTINCT CategoryNodeID,Category,0,0,0,0,0,0,0,0,2,2 FROM VwSFAProductHierarchy WHERE IsActive=1
	
	INSERT INTO #Distribution2X(BrandId,[Description],Active_Cov,YTD,P3M,MTD,[YesterDay],New_Dstrbn,Dstrbn_Lost,flgCollapse,Ordr,flgLevel)
	SELECT 0,'Dstrbn 2X',0,0,0,0,0,0,0,1,3,1
	UNION
	SELECT DISTINCT CategoryNodeID,Category,0,0,0,0,0,0,0,0,4,2 FROM VwSFAProductHierarchy WHERE IsActive=1
	
	INSERT INTO #SecVol(BrandId,[Description],MTD_Tgt,MTD_TillDate,Yesterday,[RR Required],flgCollapse,Ordr,flgLevel)
	SELECT 0,'Total Volume','NA',0,0,'NA',1,1,1
	UNION
	SELECT DISTINCT CategoryNodeID,Category,'NA',0,0,'NA',0,2,2 FROM VwSFAProductHierarchy WHERE IsActive=1
	
	INSERT INTO #PrimaryVol(BrandId,[Description],MTD_Tgt,MTD_Delivered,[Pending Delivery],Yesterday,flgCollapse,Ordr,flgLevel)
	SELECT 0,'Total Volume','NA','NA','NA','NA',1,1,1
	UNION
	SELECT DISTINCT CategoryNodeID,Category,'NA','NA','NA','NA',0,2,2 FROM VwSFAProductHierarchy WHERE IsActive=1
	UNION
	SELECT 0,'# Distributors','NA','NA','NA','NA',0,3,1
	UNION
	SELECT 0,'# Unbilled DIstributors','NA','NA','NA','NA',0,3,1

	INSERT INTO #ManDays(ValueType,[Description],Planned,[In Field_YTD],[In Field_P3M],[In Field_MTD],[In Field_Yesterday],flgCollapse,Ordr)
	--SELECT 1,'# SO',0,0,0,1,1
	--UNION
	SELECT 1,'# Planned Routes',0,0,0,0,0,0,1
	UNION
	SELECT 2,'# Covered Routes',0,0,0,0,0,0,2
	UNION
	SELECT 3,'# TSI',0,0,0,0,0,0,3
	UNION
	SELECT 4,'# UnCovered Routes',0,0,0,0,0,0,4
	UNION
	SELECT 5,'# Planned Stores' ,0,0,0,0,0,0,5
	UNION
	SELECT 6,'# Stores Visited' ,0,0,0,0,0,0,6
	UNION
	SELECT 7,'# Stores Not Visited' ,0,0,0,0,0,0,7
	UNION
	SELECT 8,'# Prod Stores' ,0,0,0,0,0,0,8
	UNION
	SELECT 9,'# Planned Visits' ,0,0,0,0,0,0,9
	UNION
	SELECT 10,'# Visits Made' ,0,0,0,0,0,0,10
	UNION
	SELECT 11,'# Productive Visits Made' ,0,0,0,0,0,0,11

	IF EXISTS(SELECT 1 FROM #TempCompanySales)
	BEGIN
		UPDATE #Distribution SET Active_Cov=@ActiveCoverage
		UPDATE A SET A.YTD=B.ProdStores FROM #Distribution A INNER JOIN #YTDData B ON A.BrandId=B.BrandId
		UPDATE A SET A.P3M=B.ProdStores FROM #Distribution A INNER JOIN #YTDData B ON A.BrandId=B.BrandId
		UPDATE A SET A.MTD=B.ProdStores FROM #Distribution A INNER JOIN #MTDData B ON A.BrandId=B.BrandId
		UPDATE A SET A.[YesterDay]=B.ProdStores FROM #Distribution A INNER JOIN #YesterdayData B ON A.BrandId=B.BrandId

		UPDATE A SET A.MTD_TillDate=ROUND(B.SecVol,0) FROM #SecVol A INNER JOIN #MTDData B ON A.BrandId=B.BrandId
		UPDATE A SET A.Yesterday=ROUND(B.SecVol,0) FROM #SecVol A INNER JOIN #YesterdayData B ON A.BrandId=B.BrandId

		UPDATE A SET A.Planned=B.NoOfPerson
		FROM #ManDays A INNER JOIN (SELECT PersonType,COUNT(DISTINCT SalesmanId) NoOfPerson FROM #Working GROUP BY PersonType) B ON A.PersonType=B.PersonType

		UPDATE A SET A.[In Field_MTD]=B.NoOfPerson
		FROM #ManDays A INNER JOIN (SELECT PersonType,COUNT(DISTINCT SalesmanId) NoOfPerson FROM #Working WHERE (flgOtherWorking=1 OR flgMarketVisit=1) GROUP BY PersonType) B ON 
	A.PersonType=B.PersonType
		
		UPDATE A SET A.[In Field_MTD]=B.ActualStoresVisited,A.Planned=B.PlannedStores FROM #ManDays A,#MTDData B WHERE A.PersonType=2 AND B.BrandId=0
		UPDATE A SET A.[In Field_MTD]=B.ActualVisitCount,A.Planned=B.PlannedVisitCount FROM #ManDays A,#MTDData B WHERE A.PersonType=3 AND B.BrandId=0

		UPDATE A SET A.[In Field_Yesterday]=B.ActualStoresVisited FROM #ManDays A,#YesterdayData B WHERE A.PersonType=2 AND B.BrandId=0
		UPDATE A SET A.[In Field_Yesterday]=B.ActualVisitCount FROM #ManDays A,#YesterdayData B WHERE A.PersonType=3 AND B.BrandId=0

		UPDATE A SET A.[In Field_Yesterday]=B.NoOfPerson
		FROM #ManDays A INNER JOIN (SELECT PersonType,COUNT(DISTINCT SalesmanId) NoOfPerson FROM #Working WHERE (flgOtherWorking=1 OR flgMarketVisit=1) AND RptDate=@YesterdayDate GROUP BY PersonType) B ON A.PersonType=B.PersonType

		UPDATE A SET A.Dstrbn_MTD=B.ProdStores,A.Sales_MTD=B.SecVol
		FROM #SalesmanData A INNER JOIN (SELECT CovAreaNodeId,CovAreaNodeType,SUM(ProdStores) ProdStores,SUM(SecVol) SecVol FROM #MTDData_SalesmanWise GROUP BY CovAreaNodeId,CovAreaNodeType) B ON A.CovAreaNodeId=B.CovAreaNodeId AND A.CovAreaNodeType=B.CovAreaNodeType

		UPDATE A SET A.Dstrbn_Yesterday=B.ProdStores,A.Sales_Yesterday=B.SecVol,A.Visits_Yesterday=B.ActualVisitCount
		FROM #SalesmanData A INNER JOIN (SELECT CovAreaNodeId,CovAreaNodeType,SUM(ProdStores) ProdStores,SUM(SecVol) SecVol,SUM(ActualVisitCount) ActualVisitCount FROM #YesterdayData_SalesmanWise GROUP BY CovAreaNodeId,CovAreaNodeType) B ON A.CovAreaNodeId=B.CovAreaNodeId AND A.CovAreaNodeType=B.CovAreaNodeType
	END
	--SELECT * FROM #Distribution ORDER BY Ordr,[Description]
	--SELECT * FROM #SecVol ORDER BY Ordr,[Description]
	--SELECT * FROM #PrimaryVol ORDER BY Ordr,[Description]
	--SELECT * FROM #ManDays ORDER BY Ordr,[Description]

	SELECT dbo.ConvertFirstLetterinCapital([Description])[Description],Active_Cov,YTD,P3M,MTD,[YesterDay],New_Dstrbn,Dstrbn_Lost,flgCollapse,flgLevel FROM #Distribution ORDER BY Ordr,[Description]
	
	SELECT dbo.ConvertFirstLetterinCapital([Description])[Description],MTD_Tgt,MTD_TillDate,Yesterday,[RR Required],flgCollapse,flgLevel FROM #SecVol ORDER BY Ordr,[Description]
	SELECT dbo.ConvertFirstLetterinCapital([Description])[Description],MTD_Tgt,MTD_Delivered,[Pending Delivery],Yesterday,flgCollapse,flgLevel FROM #PrimaryVol ORDER BY Ordr,[Description]
	SELECT dbo.ConvertFirstLetterinCapital([Description])[Description],[In Field_YTD] AS [In Field_YTD^1],[In Field_P3M] AS [In Field_P3M^2],[In Field_MTD] AS [In Field_MTD^3],[In Field_Yesterday] AS [In Field_Yesterday^4],ValueType FROM #ManDays ORDER BY Ordr,[Description]
	SELECT FORMAT(@YesterdayDate,'dd-MMM-yy') AS RptDate
	SELECT dbo.ConvertFirstLetterinCapital([Description])[Description],Active_Cov,YTD,P3M,MTD,[YesterDay],New_Dstrbn,Dstrbn_Lost,flgCollapse,flgLevel FROM #Distribution2X ORDER BY Ordr,[Description]

	--SELECT * FROM #SalesmanData
	SELECT PersonNodeID ,dbo.ConvertFirstLetterinCapital([Description]) [Description] ,Dstrbn_MTD ,Dstrbn_Yesterday ,Sales_MTD ,Sales_Yesterday ,Visits_Yesterday ,flgCollapse ,flgLevel ,Ordr FROM #SalesmanData ORDER BY Ordr,[Description]

	

END






