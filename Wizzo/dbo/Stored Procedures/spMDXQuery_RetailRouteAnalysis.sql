


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spMDXQuery_RetailRouteAnalysis]1,'20200103^1^|','','','143~1|','',0,'',3402
CREATE PROCEDURE [dbo].[spMDXQuery_RetailRouteAnalysis]
@ReportLvl INT,
@strTime VARCHAR(5000), 
@strMeasure VARCHAR(1000),
@strProduct VARCHAR(5000),
@strCompanySales VARCHAR(5000),
@StrChannel VARCHAR(500)='',
@SalesLvl INT,
@strKeyVal VARCHAR(500),
@LoginId INT
AS
BEGIN

	DECLARE @strMDX NVARCHAR(max)  
	DECLARE @LinkedServer NVARCHAR(50)  
	DECLARE @OPEN_QUERY NVARCHAR(max)  
	DECLARE @LinkedServerName NVARCHAR(50)  
	DECLARE @TempStr NVARCHAR(4000)  
	DECLARE @ViewStr VARCHAR(2000)  
	DECLARE @GroupStr VARCHAR(2000)  
	DECLARE @GroupStrForDays VARCHAR(2000)  
	DECLARE @MaxNodeType TINYINT  
	DECLARE @strSQL VARCHAR(max)
	DECLARE @strMDXProduct NVARCHAR(4000)  
	DECLARE @strMDXSalesStructure NVARCHAR(4000)
	DECLARE @strMDXSalesKey NVARCHAR(4000)
	--DECLARE @strMDXDBRSalesStructure NVARCHAR(MAX)   
	DECLARE @strMDXTime NVARCHAR(4000)  
	DECLARE @strMDXChannel NVARCHAR(1000) 
	DECLARE @strFilter NVARCHAR(MAX)
	DECLARE @LastLvlName VARCHAR(200)
	DECLARE @MeasureName VARCHAR(200),@PMeasureName VARCHAR(200),@CubeName VARCHAR(200),@strMeasureName VARCHAR(MAX)
	DECLARE @HierId VARCHAR(50),@SalesLevel INT,@NodeId INT,@NodeType INT
	DECLARE @LoginUserNodeID INT=0
	DECLARE @LoginUserNodeType TINYINT=0
	DECLARE @SalesAreaNodeType INT=0
	DECLARE @TimePeriod INT
	DECLARE @counter INT
	DECLARE @ReportHeader VARCHAR(100)

	IF @strTime=''
		SELECT @ReportHeader='Retail Analysis Report: ' + FORMAT(GETDATE(),'MMM-yy')
	ELSE
		SELECT @ReportHeader='Retail Analysis Report'


	CREATE TABLE #TempCompanySales(HierId VARCHAR(50), SalesLvl INT) 
	--CREATE TABLE #TempDBRSales(PNodeID INT, PNodeType INT,NodeID VARCHAR(20), NodeType INT)   
	CREATE TABLE #TmpProduct (NodeID INT, NodeType INT)  
	CREATE TABLE #TmpChannel (NodeId INT,NodeType INT) 
	CREATE TABLE #TmpTime (TimeVal VARCHAR(50),NodeType int)  
	--CREATE TABLE #LevelsToNotShow(NodeType INT)
	SELECT @LoginUserNodeID=NodeID,@LoginUserNodeType=NodeType 
	FROM tblSecUserLogin INNER JOIN tblSecUser ON tblSecUser.UserID=tblSecUserLogin.UserID WHERE LoginID=@LoginID
	PRINT @LoginUserNodeID
	PRINT @LoginUserNodeType

	SET @LinkedServerName='RajTrader'  

	
	PRINT 'TimeFilter'
	IF @strTime=''
	BEGIN
		INSERT INTO #TmpTime
		SELECT CONVERT(VARCHAR(6),GETDATE(),112),3
	END
	ELSE
	BEGIN
		WHILE (PATINDEX('%|%',@strTime)>0)  
		BEGIN  
			Select @TempStr = SUBSTRING(@strTime,0, PATINDEX('%|%',@strTime))  
			Select @strTime = SUBSTRING(@strTime,PATINDEX('%|%',@strTime)+1, LEN(@strTime))  
			PRINT @TempStr
			--PRINT @strTime
			SELECT @TimePeriod=SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))
			SELECT @TempStr = SUBSTRING(@TempStr, PATINDEX('%^%',@TempStr) + 1 , LEN(@TempStr))
			SELECT @NodeType=SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))
			PRINT @TimePeriod
			PRINT @NodeType
		
			INSERT INTO #TmpTime
			SELECT @TimePeriod,@NodeType
		END 	
	END	
	--SELECT * FROM #TmpTime
	

	PRINT 'Company Sales'
	IF @strCompanySales='' AND @LoginUserNodeType<>0
	BEGIN		
		CREATE TABLE #SalesAreas(SalesAreaNodeId INT,SalesAreaNodeType INT)

		IF @LoginUserNodeType=150
		BEGIN
			SELECT @SalesAreaNodeType=150

			INSERT INTO #SalesAreas(SalesAreaNodeId,SalesAreaNodeType)
			SELECT @LoginUserNodeID,@LoginUserNodeType
		END
		ELSE
		BEGIN
			SELECT @SalesAreaNodeType=ISNULL(MIN(SP.NodeType),0)
			FROM tblSalesPersonMapping SP
			WHERE SP.PersonNodeID=@LoginUserNodeID AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)

			INSERT INTO #SalesAreas(SalesAreaNodeId,SalesAreaNodeType)
			SELECT SP.NodeID,SP.NodeType
			FROM tblSalesPersonMapping SP
			WHERE SP.PersonNodeID=@LoginUserNodeID AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate) AND SP.NodeType=@SalesAreaNodeType
		END
		PRINT 'SalesAreaNodeType-' + CAST(@SalesAreaNodeType AS VARCHAR)
		--SELECT @SalesAreaNodeType
		--SELECT * FROM #SalesAreas

		IF @SalesAreaNodeType=95
		BEGIN
			INSERT INTO #TempCompanySales(HierId,SalesLvl)
			SELECT DISTINCT B.ZoneHierID,0
			FROM #SalesAreas A INNER JOIN [tblOLAPFullSalesHierarchy] B ON A.SalesAreaNodeId=B.ZoneID AND A.SalesAreaNodeType=B.ZoneNodeType
		END
		ELSE IF @SalesAreaNodeType=100
		BEGIN
			INSERT INTO #TempCompanySales(HierId,SalesLvl)
			SELECT DISTINCT B.RegionHierID,1
			FROM #SalesAreas A INNER JOIN [tblOLAPFullSalesHierarchy] B ON A.SalesAreaNodeId=B.RegionID AND A.SalesAreaNodeType=B.RegionNodeType
		END
		ELSE IF @SalesAreaNodeType=110
		BEGIN
			INSERT INTO #TempCompanySales(HierId,SalesLvl)
			SELECT DISTINCT B.ASMAreaHierID,2
			FROM #SalesAreas A INNER JOIN [tblOLAPFullSalesHierarchy] B ON A.SalesAreaNodeId=B.ASMAreaID AND A.SalesAreaNodeType=B.ASMAreaNodeType
		END
		ELSE IF @SalesAreaNodeType=120
		BEGIN
			INSERT INTO #TempCompanySales(HierId,SalesLvl)
			SELECT DISTINCT B.SOAreaHierID,3
			FROM #SalesAreas A INNER JOIN [tblOLAPFullSalesHierarchy] B ON A.SalesAreaNodeId=B.SOAreaID AND A.SalesAreaNodeType=B.SOAreaNodeType
		END
		ELSE IF @SalesAreaNodeType=150
		BEGIN
			INSERT INTO #TempCompanySales(HierId,SalesLvl)
			SELECT DISTINCT B.DBRHierID,4
			FROM #SalesAreas A INNER JOIN [tblOLAPFullSalesHierarchy] B ON A.SalesAreaNodeId=B.DBRNodeID AND A.SalesAreaNodeType=B.DBRNodeType
		END
	END
	ELSE
	BEGIN
		WHILE (PATINDEX('%|%',@strCompanySales)>0)  
		 BEGIN  
		   SELECT @TempStr = SUBSTRING(@strCompanySales,0, PATINDEX('%|%',@strCompanySales))  
		   SELECT @strCompanySales = SUBSTRING(@strCompanySales,PATINDEX('%|%',@strCompanySales)+1, LEN(@strCompanySales))
	   		
		   SELECT @HierId= SUBSTRING(@TempStr,0, PATINDEX('%~%',@TempStr))
		   SELECT @SalesLevel = SUBSTRING(@TempStr, PATINDEX('%~%',@TempStr) + 1 , LEN(@TempStr))
		   --SELECT @SalesLevel= SUBSTRING(@TempStr,0, PATINDEX('%~%',@TempStr))
	   
		   INSERT INTO #TempCompanySales(HierId,SalesLvl)
		   SELECT @HierId,@SalesLevel
		 END
	END  
	--SELECT * FROM #TempCompanySales

	PRINT 'Product'
	WHILE (PATINDEX('%|%',@StrProduct)>0)  
	 Begin  
		Select @TempStr = SUBSTRING(@StrProduct,0, PATINDEX('%|%',@StrProduct))  
	   Select @StrProduct = SUBSTRING(@StrProduct,PATINDEX('%|%',@StrProduct)+1, LEN(@StrProduct))  
   
	   SELECT @NodeId= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))
	   SELECT @TempStr = SUBSTRING(@TempStr, PATINDEX('%^%',@TempStr) + 1 , LEN(@TempStr))
	   SELECT @NodeType= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))  
   
	   INSERT INTO #TmpProduct  
		SELECT @NodeId,@NodeType
	
	   --Select @TempStr = SUBSTRING(@StrProduct,0, PATINDEX('%|%',@StrProduct))  
	   --Select @StrProduct = SUBSTRING(@StrProduct,PATINDEX('%|%',@StrProduct)+1, LEN(@StrProduct))  
	   --INSERT INTO #TempProduct  
	   --Select SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr)), SUBSTRING(@TempStr,PATINDEX('%^%',@TempStr)+1, LEN(@TempStr))  
	 End   

	PRINT 'Channel'
	WHILE (PATINDEX('%|%',@StrChannel)>0)  
	BEGIN  
	   Select @TempStr = SUBSTRING(@StrChannel,0, PATINDEX('%|%',@StrChannel))  
	   Select @StrChannel = SUBSTRING(@StrChannel,PATINDEX('%|%',@StrChannel)+1, LEN(@StrChannel))  
   
	   SELECT @NodeId= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))
	   SELECT @TempStr = SUBSTRING(@TempStr, PATINDEX('%^%',@TempStr) + 1 , LEN(@TempStr))
	   SELECT @NodeType= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))  
   
	   INSERT INTO #TmpChannel  
		SELECT @NodeId,@NodeType 
	END  
	--select * from #TmpChannel


	SET @strMDXSalesStructure=''  
	SET @MaxNodeType=0  
	SELECT @MaxNodeType=MAX(SalesLvl) FROM #TempCompanySales 	 

	IF @MaxNodeType=0
		SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Zone].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=0  
	ELSE IF @MaxNodeType=1
		SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Region].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=1  
	ELSE IF @MaxNodeType=2
		SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[ASM Area].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=2
	ELSE IF @MaxNodeType=3
		SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[SO Area].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=3
	ELSE IF @MaxNodeType=4
		SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Distributor].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=4
	ELSE IF @MaxNodeType=5
		SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Coverage Area].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=5
	ELSE IF @MaxNodeType=6
		SELECT @strMDXSalesStructure= @strMDXSalesStructure+'[SalesStructure].[Sales Hierarchy].[Route].&['+ HierId +'],' FROM #TempCompanySales WHERE SalesLvl=6
		

	SET @strMDXProduct='' 
	SET @MaxNodeType=0  
	SELECT @MaxNodeType=MAX(NodeType) FROM #TmpProduct  

	IF @MaxNodeType=10
		SELECT @strMDXProduct= @strMDXProduct+'[ProductHierarchy].[Category].&['+CAST(NodeID AS VARCHAR(200)) +'],' FROM #TmpProduct WHERE NodeType=10
	ELSE IF @MaxNodeType=20
		SELECT @strMDXProduct= @strMDXProduct+'[ProductHierarchy].[SKU].&['+CAST(NodeID AS VARCHAR(200)) +'],' FROM #TmpProduct WHERE NodeType=20


	SET @strMDXChannel='' 
	SELECT @strMDXChannel= @strMDXChannel+'[StoreChannel].[StoreChannel].&['+CAST(NodeID AS VARCHAR(200)) +'],' from #TmpChannel  
	PRINT '@strMDXChannel-' + @strMDXChannel

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

	
	IF @strMDXSalesStructure <>''  
		SET @strMDXSalesStructure=left(@strMDXSalesStructure,LEN(@strMDXSalesStructure)-1) 
 
	IF @strMDXProduct <>''  
		SET @strMDXProduct=LEFT(@strMDXProduct,LEN(@strMDXProduct)-1)
	
	IF @strMDXChannel <>''  
		SET @strMDXChannel=left(@strMDXChannel,LEN(@strMDXChannel)-1)  

	IF @strMDXTime <>''  
		SET @strMDXTime=left(@strMDXTime,LEN(@strMDXTime)-1)


	CREATE TABLE #Tmp(SalesLvl INT,SalesKey VARCHAR(200),flgHasChild TINYINT DEFAULT 1 NOT NULL,DataLvl TINYINT DEFAULT 1 NOT NULL,[Sales Area^] VARCHAR(500))
	
	SET @strMDXSalesKey=''
	SET @GroupStr=''  
	IF @SalesLvl=0
	BEGIN
		IF @ReportLvl=1
			SET @GroupStr=@GroupStr + '[SalesStructure].[Zone].MEMBERS'
		ELSE IF @ReportLvl=2
			SET @GroupStr=@GroupStr + '[SalesStructure].[Region].MEMBERS'
		ELSE IF @ReportLvl=3
			SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].MEMBERS'
		ELSE IF @ReportLvl=4
			SET @GroupStr=@GroupStr + '[SalesStructure].[SO Area].MEMBERS'
		ELSE IF @ReportLvl=5
			SET @GroupStr=@GroupStr + '[SalesStructure].[Distributor].MEMBERS'
		ELSE IF @ReportLvl=6
			SET @GroupStr=@GroupStr + '[SalesStructure].[Coverage Area].MEMBERS'
		ELSE IF @ReportLvl=7
			SET @GroupStr=@GroupStr + '[SalesStructure].[Route].MEMBERS'
	END
	ELSE
	BEGIN
		IF @SalesLvl=1
		BEGIN
			SET @GroupStr=@GroupStr + '[SalesStructure].[Region].[Region].MEMBERS'
			SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[Zone].&['+ @strKeyVal +']'
		END
		ELSE IF @SalesLvl=2
		BEGIN
			SET @GroupStr=@GroupStr + '[SalesStructure].[ASM Area].[ASM Area].MEMBERS'
			SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[Region].&['+ @strKeyVal +']'
		END
		ELSE IF @SalesLvl=3
		BEGIN
			SET @GroupStr=@GroupStr + '[SalesStructure].[SO Area].[SO Area].MEMBERS'
			--SET @GroupStr=@GroupStr + '[SalesStructure].[Coverage Area].[Coverage Area].MEMBERS'
			SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[ASM Area].&['+ @strKeyVal +']'
		END
		ELSE IF @SalesLvl=4
		BEGIN
			SET @GroupStr=@GroupStr + '[SalesStructure].[Distributor].[Distributor].MEMBERS'
			--SET @GroupStr=@GroupStr + '[SalesStructure].[Coverage Area].[Coverage Area].MEMBERS'
			SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[SO Area].&['+ @strKeyVal +']'
		END
		ELSE IF @SalesLvl=5
		BEGIN
			SET @GroupStr=@GroupStr + '[SalesStructure].[Coverage Area].[Coverage Area].MEMBERS'
			SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[Distributor].&['+ @strKeyVal +']'
		END
		ELSE IF @SalesLvl=6
		BEGIN
			SET @GroupStr=@GroupStr + '[SalesStructure].[Route].[Route].MEMBERS'
			SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[Coverage Area].&['+ @strKeyVal +']'
		END
	END
	
	PRINT 'GroupStr-' + @GroupStr
	--PRINT 'strColumn-' + @strColumn
	--SELECT @GroupStr	
	--SELECT @strColumn	


	--SELECT * FROM #Tmp
	CREATE TABLE #tmpMeasure(Id INT, Measure VARCHAR(200), PId INT, PMeasure VARCHAR(200),OLAPMeasureName VARCHAR(200),ColumnName VARCHAR(200),ColumnDataType VARCHAR(20),POrdr INT,Ordr INT,FlgRound TINYINT,NoOfDecimals TINYINT,FlgPercentage TINYINT,flgForPopUp TINYINT)
	CREATE TABLE #MeasureDetails(ID INT IDENTITY(1,1), MeasureId INT,Measure VARCHAR(500),PMeasureId INT,PMeasure VARCHAR(500),OLAPMeasureName VARCHAR(200),ColumnName VARCHAR(200),ColumnDataType VARCHAR(20),POrdr INT,Ordr INT,FlgRound TINYINT,NoOfDecimals TINYINT,FlgPercentage TINYINT,ColorCode_1 VARCHAR(10),ColorCode_2 VARCHAR(10),flgForPopUp TINYINT,strColumnName VARCHAR(200))

	--SELECT @strMeasure
	IF @strMeasure=''
	BEGIN
		INSERT INTO #tmpMeasure(Id)
		SELECT id FROM tblMeasureListForMTDRetailRouteReport WHERE Flg=1
	END
	ELSE
	BEGIN
		INSERT INTO #tmpMeasure(Id)
		SELECT Item FROM dbo.SplitString(@strMeasure, '^') WHERE Item<>''	
	END

	UPDATE B SET B.Measure =A.Measure,B.PId=A.PId,B.ordr=A.Ordr,B.OLAPMeasureName=A.OLAPMeasureName,B.ColumnName=A.ColumnName,B.ColumnDataType=A.ColumnDataType,B.FlgRound=A.FlgRound, B.NoOfDecimals=A.NoOfDecimals,B.FlgPercentage=A.FlgPercentage,B.flgForPopUp=A.flgForPopUp    
	FROM tblMeasureListForMTDRetailRouteReport A INNER JOIN #tmpMeasure B ON A.Id=B.Id

	UPDATE B SET B.PMeasure =A.Measure,B.POrdr=A.Ordr--,B.ColorCode_1=A.ColorCode,B.ColorCode_2=A.ColorCode_2
	FROM tblMeasureListForMTDRetailRouteReport A INNER JOIN #tmpMeasure B ON A.Id=B.PId
	--SELECT * FROM #tmpMeasure ORDER BY Pordr,Ordr
		
	DECLARE @MeasureId INT,@OLAPMeasureName VARCHAR(200),@ColumnName VARCHAR(200),@ColumnDataType VARCHAR(20),@strColumnName VARCHAR(200)
	DECLARE @ColorCode_1 VARCHAR(10)
	DECLARE @ColorCode_2 VARCHAR(10)
	DECLARE @strColumnWithAllMeasures VARCHAR(MAX)
	
	INSERT INTO #MeasureDetails(MeasureId,Measure,PMeasureId,PMeasure,OLAPMeasureName,ColumnName,ColumnDataType,POrdr,Ordr,FlgRound,NoOfDecimals,FlgPercentage,flgForPopUp)
	Select DISTINCT Id,Measure,PId,PMeasure,OLAPMeasureName,ColumnName,ColumnDataType,POrdr,Ordr,FlgRound,NoOfDecimals,FlgPercentage,flgForPopUp 
	FROM #tmpMeasure WHERE PId<>0 AND PId NOT IN(38)
	ORDER BY POrdr,Ordr

	UPDATE B SET B.ColorCode_1=A.ColorCode,B.ColorCode_2=A.ColorCode_2
	FROM tblMeasureListForMTDRetailRouteReport A INNER JOIN #MeasureDetails B ON A.Id=B.PMeasureId

	UPDATE #MeasureDetails SET strColumnName=PMeasure+'^'+Measure+ '|' + ColorCode_1 + '~' + ColorCode_2

	UPDATE #MeasureDetails SET strColumnName= strColumnName + '@' + CAST(MeasureId AS VARCHAR) WHERE flgForPopUp=1

	--SELECT * FROM #MeasureDetails ORDER BY Id
	
	SELECT @strColumnWithAllMeasures='[Sales Area^],SalesLvl,SalesKey,'
	--SELECT @strColumnWithAllMeasures=@strColumnWithAllMeasures

	SET @strMeasureName=''
	SET @counter  = 1
	WHILE(@counter <=(Select MAX(ID) FROM #MeasureDetails))
		BEGIN
			SELECT @MeasureId = MeasureId,@OLAPMeasureName=OLAPMeasureName,@PMeasureName=PMeasure, @MeasureName=Measure,@ColumnName=ColumnName,@ColumnDataType=ColumnDataType, @ColorCode_1=ColorCode_1, @ColorCode_2=ColorCode_2,@strColumnName=strColumnName
			FROM #MeasureDetails WHERE ID = @counter
			
			IF ISNULL(@OLAPMeasureName,'')<>''
			BEGIN
				SET @strMeasureName=@strMeasureName + @OLAPMeasureName + ','
				SET @strColumnWithAllMeasures=@strColumnWithAllMeasures + '['+ @strColumnName + '],'	
				--SET @strColumnWithAllMeasures=@strColumnWithAllMeasures + '['+@PMeasureName+'^'+@MeasureName+ '|' + @ColorCode_1 + '~' + @ColorCode_2 + '],'	
			END

			--SET @strSQL = 'ALTER TABLE #Tmp ADD ['+@PMeasureName+'^'+@MeasureName + '|' + @ColorCode_1 + '~' + @ColorCode_2 + '] VARCHAR(200)'
			SET @strSQL = 'ALTER TABLE #Tmp ADD [' + @strColumnName + '] VARCHAR(200)'
			PRINT @strSQL
			EXEC (@strSQL)
			SET @counter = @counter + 1			
		END
	--SELECT * FROM #Tmp
	SET @strMeasureName=left(@strMeasureName,LEN(@strMeasureName)-1)
	PRINT '@strMeasureName-' + @strMeasureName
	SET @strColumnWithAllMeasures=left(@strColumnWithAllMeasures,LEN(@strColumnWithAllMeasures)-1)
	PRINT 'strColumnWithAllMeasures-' + @strColumnWithAllMeasures

	 
	SET @strFilter=''  

	IF @strMDXSalesStructure<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXSalesStructure+'}) ON COLUMNS '  
	IF @strMDXTime<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXTime+'}) ON COLUMNS '
	IF @strMDXProduct<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXProduct+'}) ON COLUMNS '  
	IF @strMDXSalesKey<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXSalesKey+'}) ON COLUMNS '  
	IF @strMDXChannel<>''  
		SET  @strFilter=@strFilter+'FROM (SELECT ({'+@strMDXChannel+'}) ON COLUMNS '

	SET @CubeName='[cubAll_Day]'
  
	--SET @strMDX='SELECT  ( {' + @strMeasureName +'} ) ON COLUMNS, NON EMPTY ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '  
	--SET @strMDX=@strMDX + @strFilter + '  FROM ' + @CubeName 

	--SET @strMDX='WITH MEMBER [Measures].[Lvl] AS [SalesStructure].[Sales Hierarchy].Currentmember.level_number
	--	member [Measures].[Key] AS [SalesStructure].[Sales Hierarchy].Currentmember.properties("KEY") 
	--	SELECT {[Measures].[Lvl],[Measures].[Key],' + @strMeasureName +'} ON 0, hierarchize({' + @GroupStr + ' }) ON 1 '
		
	SET @strMDX='WITH MEMBER [Measures].[Lvl] AS [SalesStructure].[Sales Hierarchy].Currentmember.level_number
		member [Measures].[Key] AS [SalesStructure].[Sales Hierarchy].Currentmember.properties("KEY") 
		SELECT {[Measures].[Lvl],[Measures].[Key],' + @strMeasureName +'} ON COLUMNS, NONEMPTY  ({' + @GroupStr + ' },[Measures].[Target Store Count]) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '
		  
	SET @strMDX=@strMDX + @strFilter + '  FROM ' + @CubeName
	--SET @strMDX=@strMDX + '  FROM ' + @CubeName

	IF @strMDXSalesStructure<>''  
		SET @strMDX=@strMDX+')' 
	IF @strMDXTime<>''  
		SET @strMDX=@strMDX+')'
	IF @strMDXProduct<>''  
		SET @strMDX=@strMDX+')' 
	IF @strMDXSalesKey<>''  
		SET @strMDX=@strMDX+')' 
	IF @strMDXChannel<>''  
		SET @strMDX=@strMDX+')'	

	PRINT @strMDX   
	SET  @OPEN_QUERY =N'SELECT *  FROM OpenQuery ("'+@LinkedServerName+'",'''+ @strMDX + ''')'  

	PRINT 'OPEN_QUERY-' +@OPEN_QUERY
	BEGIN TRY  
		IF @strMDXTime<>''
		BEGIN
			SET @strSQL = ''
			SET @strSQL = 'INSERT INTO #Tmp('+@strColumnWithAllMeasures+') '
			PRINT @strSQL
			SET @OPEN_QUERY =@strSQL +  @OPEN_QUERY
			EXECUTE SP_EXECUTESQL @OPEN_QUERY 
		END
	END TRY  
	BEGIN CATCH  
	   --SELECT ERROR_NUMBER() AS ErrorNumber   
	END CATCH 
	--SELECT * FROM #Tmp --order by lastlvlid

	DECLARE @FlgRound TINYINT
	DECLARE @NoOfDecimals TINYINT
	DECLARE @FlgPercentage TINYINT

	SET @counter  = 1
	WHILE(@counter <=(Select MAX(ID) FROM #MeasureDetails))
		BEGIN
			SELECT @MeasureId = MeasureId,@OLAPMeasureName=OLAPMeasureName,@PMeasureName=PMeasure, @MeasureName=Measure,@ColumnName=ColumnName,@ColumnDataType=ColumnDataType, @FlgRound=FlgRound, @NoOfDecimals=NoOfDecimals,@FlgPercentage=FlgPercentage , @ColorCode_1=ColorCode_1, @ColorCode_2=ColorCode_2,@strColumnName=strColumnName
			FROM #MeasureDetails WHERE ID = @counter
			
			IF @FlgRound=1
			BEGIN
				SET @strSQL = 'ALTER TABLE #Tmp ALTER COLUMN [' + @strColumnName + '] FLOAT'
				PRINT @strSQL
				EXEC (@strSQL)

				SET @strSQL = 'UPDATE #Tmp SET ['+ @strColumnName + ']=ROUND([' + @strColumnName + '],' + CAST(@NoOfDecimals AS VARCHAR) + ')'
				PRINT @strSQL
				EXEC (@strSQL)
			END

			IF @FlgPercentage=1
			BEGIN
				SET @strSQL = 'ALTER TABLE #Tmp ALTER COLUMN [' + @strColumnName + '] VARCHAR(50)'
				PRINT @strSQL
				EXEC (@strSQL)

				SET @strSQL = 'UPDATE #Tmp SET [' + @strColumnName + ']=CAST(CAST([' + @strColumnName + '] AS FLOAT)*100 AS VARCHAR) + ''%'''
				PRINT @strSQL
				EXEC (@strSQL)
			END
			ELSE
			BEGIN
				SET @strSQL = 'ALTER TABLE #Tmp ALTER COLUMN [' + @strColumnName + ']' + @ColumnDataType
				PRINT @strSQL
				EXEC (@strSQL)
			END

			SET @counter = @counter + 1			
		END
	
	PRINT 'Grv1'
	IF @ReportLvl=6 OR @SalesLvl=5
	BEGIN
		UPDATE #tmp SET flgHasChild=0
	END

	DECLARE @CountOfRows INT
	SELECT @CountOfRows=COUNT(*) FROM #Tmp WHERE SalesLvl>0

	IF @CountOfRows=1
	BEGIN
		DELETE FROM #Tmp WHERE SalesLvl=0
	END
	ELSE
	BEGIN
		IF @SalesLvl=0
		BEGIN
			UPDATE #Tmp SET [Sales Area^]='Grand Total' WHERE SalesLvl=0 AND SalesKey=0
			UPDATE #tmp SET DataLvl=2 WHERE SalesLvl>0
		END
	END

	SELECT * FROM #Tmp --ORDER BY 1,2,3

	SELECT @ReportHeader AS ReportHeader
END







