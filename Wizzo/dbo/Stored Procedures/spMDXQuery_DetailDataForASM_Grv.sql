-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spMDXQuery_DetailDataForASM_Grv]'A2B8D6C0-6815-4A66-8D3D-9D534BA6A04B','22-Mar-2022',0,0,4,5,11
CREATE PROCEDURE [dbo].[spMDXQuery_DetailDataForASM_Grv] 
@PDACode varchar(200),
@RptDate DATE,
@CoverageAreaNodeID INT,
@CoverageAreaNodeType SMALLINT,
@SectionId INT,
@ValueType SMALLINT,
@PeriodType SMALLINT
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
	DECLARE @strMeasure NVARCHAR(1000) 
	DECLARE @strFilter NVARCHAR(MAX)

	DECLARE @PDAID INT  
	DECLARE @PDAPersonID INT  
	DECLARE @PDAPersonType INT  
	
	CREATE TABLE #TempCompanySales(HierId VARCHAR(50), SalesLvl INT) 
	CREATE TABLE #TmpProduct (NodeID INT, NodeType INT)  
	CREATE TABLE #TmpTime (TimeVal VARCHAR(50),NodeType int) 

	
	SET @LinkedServerName='RajTrader'  

	IF @PDACode<>''
	BEGIN
		SELECT @PDAPersonID=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
		SELECT @PDAPersonType=PersonType FROM tblSalesPersonMapping WHERE PersonNodeID=@PDAPersonID
		 --SELECT @PDAPersonID=144
		 --SELECT @PDAPersonID=26
		 PRINT '@PDAPersonID=' + CAST(@PDAPersonID AS VARCHAR)
		 IF @CoverageAreaNodeID>0 AND @CoverageAreaNodeType IN (130)
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
	 END
	--SELECT * FROM #TempCompanySales

	CREATE TABLE #Data(ASMArea VARCHAR(200),RouteId VARCHAR(20),RouteNodeType VARCHAR(20),[Route] VARCHAR(200),StoreId VARCHAR(20),StoreCode VARCHAR(20),Store VARCHAR(200),Val FLOAT)
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
		BEGIN
			SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Route].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=6
		END

		IF @strMDXSalesStructure <>''  
			SET @strMDXSalesStructure=left(@strMDXSalesStructure,LEN(@strMDXSalesStructure)-1) 
		
		SELECT DISTINCT CategoryNodeID INTO #CatList FROM VwSFAProductHierarchy WHERE IsActive=1

		SELECT @strMDXProduct=''
		--SELECT @strMDXProduct= @strMDXProduct+'[ProductHierarchy].[Category].&['+CAST(CategoryNodeID AS VARCHAR(200)) +'],' FROM #CatList

		
		IF @strMDXProduct <>''  
			SET @strMDXProduct=left(@strMDXProduct,LEN(@strMDXProduct)-1)
		
		IF @PeriodType IN(1)	--YTD
		BEGIN
			INSERT INTO #TmpTime(TimeVal,NodeType)
			SELECT DISTINCT RptMonthYear,3 FROM tblOlapTimeHierarchy_Day WHERE RptMonthYear>=202104
		END
		ELSE IF @PeriodType IN(11)	--P3M
		BEGIN
			INSERT INTO #TmpTime(TimeVal,NodeType)
			SELECT DISTINCT TOP 3 RptMonthYear,3 FROM tblOlapTimeHierarchy_Day WHERE RptMonthYear<=CONVERT(VARCHAR(6),@YesterdayDate,112) ORDER By RptMonthYear DESC
		END
		ELSE IF @PeriodType IN(21,22)	--MTD
		BEGIN
			INSERT INTO #TmpTime(TimeVal,NodeType)
			SELECT CONVERT(VARCHAR(6),@YesterdayDate,112),3
		END
		ELSE IF @PeriodType IN(31,32,33)	--Yesterday
		BEGIN
			INSERT INTO #TmpTime(TimeVal,NodeType)
			SELECT CONVERT(VARCHAR(8),@YesterdayDate,112),1
		END
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
		--If @SectionId=4 AND @ValueType IN(5,6,7,8,9,10,11)
		--BEGIN
			SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS*[SalesStructure].[RouteNodeId].[RouteNodeId].MEMBERS*[SalesStructure].[RouteNodeType].[RouteNodeType].MEMBERS*[SalesStructure].[Route].[Route].MEMBERS*[SalesStructure].[StoreId].[StoreId].MEMBERS*[SalesStructure].[StoreCode].[StoreCode].MEMBERS*[SalesStructure].[Store].[Store].MEMBERS'
		--END
		--ELSE If @SectionId=6
		--BEGIN
		--	SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS*[SalesStructure].[CoverageAreaId].[CoverageAreaId].MEMBERS*[SalesStructure].[CoverageAreaNodeType].[CoverageAreaNodeType].MEMBERS'
		--END
		--SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS*[CompanySalesStructure].[RouteNodeId].[RouteNodeId].MEMBERS*[CompanySalesStructure].[RouteNodeType].[RouteNodeType].MEMBERS'
		PRINT 'GroupStr-' + @GroupStr		
	 	
		SET @strFilter=''  

		IF @strMDXSalesStructure<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXSalesStructure+'}) ON COLUMNS '  
		IF @strMDXTime<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
		IF @strMDXProduct<>''  
			SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS ' 
			
		--UPDATE A SET A.SalesmanId=C.PersonNodeID
		--FROM #YTDData_RouteLvl A INNER JOIN tblCompanySalesStructureHierarchy B ON A.RouteId=B.NodeId AND A.RouteNodeType=B.NodeType
		--INNER JOIN tblSalesPersonMapping C ON B.PnodeId=C.NodeID AND B.PNodeType=C.NodeType AND (@RptDate BETWEEN C.FromDate AND C.ToDate)
		--SELECT * FROM #YTDData_RouteLvl order by ActualVisitCount

		If (@SectionId=4 AND @ValueType=5)
		BEGIN
			SELECT @strMeasure='[Measures].[PlannedStoreCount_ActiveCoverage]'
		END
		ELSE If (@SectionId=4 AND @ValueType=6)
		BEGIN
			SELECT @strMeasure='[Measures].[ActualStoresVisited_ActiveCoverage]'
		END
		ELSE If (@SectionId=4 AND @ValueType=7)
		BEGIN
			SELECT @strMeasure='[Measures].[ActualStoresVisited_ActiveCoverage]'
		END
		ELSE If (@SectionId=4 AND @ValueType=8) OR (@SectionId=6 AND @PeriodType IN(21,31))
		BEGIN
			SELECT @strMeasure='[Measures].[Distinct Stores Ordered - Active Coverage]'
		END
		ELSE If (@SectionId=4 AND @ValueType=9)
		BEGIN
			SELECT @strMeasure='[Measures].[PlannedVisitCount_ActiveCoverage]'
		END
		ELSE If (@SectionId=4 AND @ValueType=10) OR (@SectionId=6 AND @PeriodType IN(33))
		BEGIN
			SELECT @strMeasure='[Measures].[ActualVisitCount_ActiveCoverage]'
		END
		ELSE If (@SectionId=4 AND @ValueType=11)
		BEGIN
			SELECT @strMeasure='[Measures].[EffectiveVisitCount_ActiveCoverage]'
		END
		ELSE If (@SectionId=6 AND @PeriodType IN(22,32))
		BEGIN
			SELECT @strMeasure='[Measures].[Net Order Volume in Kgs - Active Coverage]'
		END
	END
	--SELECT @GroupStr
	--SELECT @strMeasure

	SET @strMDX='SELECT {' + @strMeasure + '} ON COLUMNS,  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '	

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
			INSERT INTO #Data(ASMArea,RouteId,RouteNodeType,[Route],StoreId,StoreCode,Store,Val)
			EXECUTE SP_EXECUTESQL @OPEN_QUERY 
		END
	END TRY  
	BEGIN CATCH  
		--SELECT ERROR_NUMBER() AS ErrorNumber   
	END CATCH 
	--SELECT * FROM #Data ORDER BY ASMArea
	--SELECT COUNT(DISTINCT StoreId) FROM #Data
	DELETE FROM #Data WHERE Val IS NULL
	SELECT [Route],Store FROM #Data

END
