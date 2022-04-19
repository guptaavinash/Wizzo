
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spMDXQuery_SummaryDataForASM_Grv]'DFD7BFE6-0299-423B-AE7B-48A3681E0141','08-Dec-2021',0,0
CREATE Procedure [dbo].[spMDXQuery_SummaryDataForASM_08Feb2022]
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
	CREATE TABLE #ManDays(PersonType INT,[Description] VARCHAR(200),Planned INT,[In Field_MTD] INT,[In Field_Yesterday] INT,flgCollapse TINYINT,Ordr INT)
	CREATE TABLE #SalesmanData (PersonNodeID INT,[Description] VARCHAR(100),Dstrbn_MTD INT,Dstrbn_Yesterday INT,Sales_MTD VARCHAR(10),Sales_Yesterday VARCHAR(10),Visits_Yesterday VARCHAR(10),flgCollapse TINYINT,flgLevel TINYINT,Ordr INT)
	
	CREATE TABLE #YTDData(ASMArea VARCHAR(200),BrandId VARCHAR(20),ProdStores INT,Ordr INT)
	CREATE TABLE #MTDData(ASMArea VARCHAR(200),BrandId VARCHAR(20),ProdStores INT,SecVol FLOAT,Ordr INT)
	CREATE TABLE #YesterdayData(ASMArea VARCHAR(200),BrandId VARCHAR(20),ProdStores INT,NewStore INT,SecVol FLOAT,Ordr INT)
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

		 INSERT INTO #SalesmanData(PersonNodeID,Description,Dstrbn_MTD,Dstrbn_Yesterday,Sales_MTD,Sales_Yesterday,Visits_Yesterday,flgCollapse,flgLevel,Ordr)
		 SELECT DISTINCT SM.PersonNodeID,P.Descr,0,0,0,0,0,0,1,1 FROM tblOLApFullSalesHierarchy V INNER JOIN tblSalesPersonMapping SM ON SM.NodeID=V.CoverageAreaID AND SM.NodeType=V.CoverageAreaNodeType INNER JOIN tblMstrPerson P ON P.NodeID=SM.PersonNodeID AND (CAST(GETDATE() AS DATE) BETWEEN SM.FromDate AND SM.ToDate) INNER JOIN tblSalesPersonmapping B ON B.NodeID=V.ASMAreaID AND B.NodeType=V.ASMAreaNodeType AND (CAST(GETDATE() AS DATE) BETWEEN B.FromDate AND B.ToDate)
		 WHERE B.PersonNodeID=@PDAPersonID
	 END
	
	
	IF EXISTS(SELECT 1 FROM #TempCompanySales)
	BEGIN
		--SELECT 1
		SET @strMDXSalesStructure=''  
		SET @MaxNodeType=0  
		SELECT @MaxNodeType=MAX(SalesLvl) FROM #TempCompanySales 	 

		IF @MaxNodeType=0
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Zone].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=0  
		END
		ELSE IF @MaxNodeType=1
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Region].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=1  
		END
		ELSE IF @MaxNodeType=2
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[ASM Area].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=2
		END
		ELSE IF @MaxNodeType=3
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[SO Area].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=3
		END
		ELSE IF @MaxNodeType=4
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Distributor].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=4
		END
		ELSE IF @MaxNodeType=5
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Coverage Area].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=5
		END
		ELSE IF @MaxNodeType=6
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Route].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=6

		IF @strMDXSalesStructure <>''  
			SET @strMDXSalesStructure=left(@strMDXSalesStructure,LEN(@strMDXSalesStructure)-1) 
	
		SELECT @strMDXProduct=''
		SELECT @strMDXProduct= @strMDXProduct+'[ProductHierarchy].[Category].&['+CAST(CategoryNodeID AS VARCHAR(200)) +'],' FROM VwSFAProductHierarchy WHERE IsActive=1

		
		IF @strMDXProduct <>''  
			SET @strMDXProduct=left(@strMDXProduct,LEN(@strMDXProduct)-1)
		
		--SELECT * FROM #TempCompanySales
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
				INSERT INTO #MTDData(ASMArea,BrandId,ProdStores,SecVol)
				EXECUTE SP_EXECUTESQL @OPEN_QUERY 
			END
		END TRY  
		BEGIN CATCH  
		   --SELECT ERROR_NUMBER() AS ErrorNumber   
		END CATCH 
		UPDATE #MTDData SET BrandId=0,Ordr=2 WHERE BrandId IS NULL
		UPDATE #MTDData  SET Ordr=3 WHERE Ordr is nULL 

		--SELECT * FROM #MTDData order by Ordr,BrandId


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

		SET @strMDX='SELECT {[Measures].[Distinct Stores Ordered],[Measures].[New Stores Distribution Ordered],[Measures].[Net Order Volume in Kgs]} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '			  
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
				INSERT INTO #YesterdayData(ASMArea,BrandId,ProdStores,NewStore,SecVol)
				EXECUTE SP_EXECUTESQL @OPEN_QUERY 
			END
		END TRY  
		BEGIN CATCH  
		   --SELECT ERROR_NUMBER() AS ErrorNumber   
		END CATCH 
		UPDATE #YesterdayData SET BrandId=0,Ordr=2 WHERE BrandId IS NULL
		UPDATE #YesterdayData  SET Ordr=3 WHERE Ordr is nULL 

		--SELECT * FROM #YesterdayData order by Ordr,BrandId
		SELECT * FROM #TempCompanySales

		PRINT 'feet on street'
		CREATE TABLE #Rslt(RegionId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),SOId INT,SoNodeType INT,CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),SalesmanId INT,SalesmanNodeType INT)

		INSERT INTO #Rslt(RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,SOId,SoNodeType,CovAreaId,CovAreaNodeType,CovArea, SalesmanId,SalesmanNodeType)
		SELECT DISTINCT RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,0,0,CoverageAreaID,CoverageAreaNodeType,CoverageArea,0,0
		FROM tblOLApFullSalesHierarchy A INNER JOIN #TempCompanySales B ON A.ASMAreaHierId=B.HierId WHERE B.SalesLvl=1


		

		UPDATE A SET A.SOId=Mp.NodeId,A.SONodeType=Mp.NodeType 
		FROM #Rslt A INNER JOIN tblsalesPersonMapping SP ON A.SOAreaId=SP.NodeId AND A.SOAreaNodeType=SP.NodeType INNER JOIN tblMstrPerson MP ON SP.PersonNodeID=MP.NodeID 
		WHERE (@RptDate BETWEEN SP.FromDate AND SP.ToDate) AND (@RptDate BETWEEN MP.FromDate AND MP.ToDate)

		UPDATE A SET A.SalesmanId=Mp.NodeId,A.SalesmanNodeType=Mp.NodeType 
		FROM #Rslt A INNER JOIN tblsalesPersonMapping SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType INNER JOIN tblMstrPerson MP ON SP.PersonNodeID=MP.NodeID 
		WHERE (@RptDate BETWEEN SP.FromDate AND SP.ToDate) AND (@RptDate BETWEEN MP.FromDate AND MP.ToDate)

		

		PRINT 'Insertion for SOs where no route is mapped to SO'
		INSERT INTO #Rslt(RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,SOId,SoNodeType,SalesmanId,SalesmanNodeType)
		SELECT DISTINCT A.RegionId,A.RegionNodeType,A.Region,A.ASMAreaId,A.ASMAreaNodeType,A.ASMArea,A.SOAreaId,A.SOAreaNodeType,A.SOArea,A.SOId,A.SoNodeType,A.SOId, A.SoNodeType FROM #Rslt A LEFT OUTER JOIN #Rslt AA ON A.SOId=AA.SalesmanId
		WHERE AA.SalesmanId IS NULL

		SELECT * FROM #Rslt

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
	SELECT 0,'No Of DIstributors','NA','NA','NA','NA',0,3,1

	INSERT INTO #ManDays(PersonType,[Description],Planned,[In Field_MTD],[In Field_Yesterday],flgCollapse,Ordr)
	--SELECT 1,'# SO',0,0,0,1,1
	--UNION
	SELECT 1,'# DSM',0,0,0,0,1
	UNION
	SELECT 2,'Stores Visited' ,0,0,0,0,2
	UNION
	SELECT 2,'Visits Made' ,0,0,0,0,3

	IF EXISTS(SELECT 1 FROM #TempCompanySales)
	BEGIN
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

		UPDATE A SET A.[In Field_Yesterday]=B.NoOfPerson
		FROM #ManDays A INNER JOIN (SELECT PersonType,COUNT(DISTINCT SalesmanId) NoOfPerson FROM #Working WHERE (flgOtherWorking=1 OR flgMarketVisit=1) AND RptDate=@YesterdayDate GROUP BY PersonType) B ON A.PersonType=B.PersonType
	END
	--SELECT * FROM #Distribution ORDER BY Ordr,[Description]
	--SELECT * FROM #SecVol ORDER BY Ordr,[Description]
	--SELECT * FROM #PrimaryVol ORDER BY Ordr,[Description]
	--SELECT * FROM #ManDays ORDER BY Ordr,[Description]

	SELECT dbo.ConvertFirstLetterinCapital([Description])[Description],Active_Cov,YTD,P3M,MTD,[YesterDay],New_Dstrbn,Dstrbn_Lost,flgCollapse,flgLevel FROM #Distribution ORDER BY Ordr,[Description]
	
	SELECT dbo.ConvertFirstLetterinCapital([Description])[Description],MTD_Tgt,MTD_TillDate,Yesterday,[RR Required],flgCollapse,flgLevel FROM #SecVol ORDER BY Ordr,[Description]
	SELECT dbo.ConvertFirstLetterinCapital([Description])[Description],MTD_Tgt,MTD_Delivered,[Pending Delivery],Yesterday,flgCollapse,flgLevel FROM #PrimaryVol ORDER BY Ordr,[Description]
	SELECT dbo.ConvertFirstLetterinCapital([Description])[Description],Planned,[In Field_MTD],[In Field_Yesterday] FROM #ManDays ORDER BY Ordr,[Description]
	SELECT FORMAT(@YesterdayDate,'dd-MMM-yy') AS RptDate
	SELECT dbo.ConvertFirstLetterinCapital([Description])[Description],Active_Cov,YTD,P3M,MTD,[YesterDay],New_Dstrbn,Dstrbn_Lost,flgCollapse,flgLevel FROM #Distribution2X ORDER BY Ordr,[Description]
	SELECT PersonNodeID ,dbo.ConvertFirstLetterinCapital([Description]) [Description] ,Dstrbn_MTD ,Dstrbn_Yesterday ,Sales_MTD ,Sales_Yesterday ,Visits_Yesterday ,flgCollapse ,flgLevel ,Ordr FROM #SalesmanData ORDER BY Ordr,[Description]

	

END






