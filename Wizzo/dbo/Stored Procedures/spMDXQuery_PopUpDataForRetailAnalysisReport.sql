



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spMDXQuery_PopUpDataForRetailAnalysisReport]'','','','',1,'2',0,6
CREATE PROCEDURE [dbo].[spMDXQuery_PopUpDataForRetailAnalysisReport]
@strTime VARCHAR(5000), 
@strProduct VARCHAR(5000),
@strCompanySales VARCHAR(5000),
@StrChannel VARCHAR(500)='',
@SalesLvl INT,
@strKeyVal VARCHAR(500),
@LoginId INT,
@MainMeasureId INT
AS
BEGIN

	DECLARE @strMDX NVARCHAR(max)  
	DECLARE @LinkedServer NVARCHAR(50)  
	DECLARE @OPEN_QUERY NVARCHAR(max)  
	DECLARE @LinkedServerName NVARCHAR(50)  
	DECLARE @TempStr NVARCHAR(4000)  
	DECLARE @ViewStr VARCHAR(2000)  
	DECLARE @GroupStr VARCHAR(2000)
	DECLARE @MaxNodeType TINYINT  
	DECLARE @strSQL VARCHAR(max)
	DECLARE @strMDXProduct NVARCHAR(4000)  
	DECLARE @strMDXSalesStructure NVARCHAR(4000)
	DECLARE @strMDXSalesKey NVARCHAR(4000)
	--DECLARE @strMDXDBRSalesStructure NVARCHAR(MAX)   
	DECLARE @strMDXTime NVARCHAR(4000)  
	DECLARE @strMDXChannel NVARCHAR(1000) 
	DECLARE @strFilter NVARCHAR(MAX)
	DECLARE @MeasureName VARCHAR(200),@PMeasureName VARCHAR(200),@CubeName VARCHAR(200),@strMeasureName VARCHAR(MAX)
	DECLARE @HierId VARCHAR(50),@SalesLevel INT,@NodeId INT,@NodeType INT
	DECLARE @LoginUserNodeID INT=0
	DECLARE @LoginUserNodeType TINYINT=0
	DECLARE @LoginUserMailID VARCHAR(200)=''
	--DECLARE @LoginUser VARCHAR(200)=''
	DECLARE @SalesAreaNodeType INT=0
	DECLARE @TimePeriod INT
	DECLARE @counter INT
	DECLARE @ReportHeader VARCHAR(100)=''
	DECLARE @RptLvlNodeType INT=0

	SELECT @RptLvlNodeType=CASE @SalesLvl WHEN 1 THEN 95 WHEN 2 THEN 100 WHEN 3 THEN 110 WHEN 4 THEN 120 WHEN 5 THEN 150 WHEN 6 THEN 160 END
	--SELECT @RptLvlNodeType
	IF @SalesLvl=1
	BEGIN
		SELECT @ReportHeader=[Zone] FROM tblOLAPFullSalesHierarchy where ZoneHierID=@strKeyVal
	END
	ELSE IF @SalesLvl=2
	BEGIN
		SELECT @ReportHeader=[Zone] + '>>' + Region FROM tblOLAPFullSalesHierarchy where RegionHierID=@strKeyVal
	END
	ELSE IF @SalesLvl=3
	BEGIN
		SELECT @ReportHeader=[Zone] + '>>' + Region + '>>' + ASMArea FROM tblOLAPFullSalesHierarchy where ASMAreaHierID=@strKeyVal
	END
	ELSE IF @SalesLvl=4
	BEGIN
		SELECT @ReportHeader=[Zone] + '>>' + Region + '>>' + ASMArea + '>>' + SOArea FROM tblOLAPFullSalesHierarchy where SOAreaHierId=@strKeyVal
	END
	ELSE IF @SalesLvl=5
	BEGIN
		SELECT @ReportHeader=[Zone] + '>>' + Region + '>>' + ASMArea + '>>' + SOArea + '>>' + DBR FROM tblOLAPFullSalesHierarchy where DBRHierId=@strKeyVal
	END
	ELSE IF @SalesLvl=6
	BEGIN
		SELECT @ReportHeader=[Zone] + '>>' + Region + '>>' + ASMArea + '>>' + SOArea + '>>' + DBR + '>>' + CoverageArea FROM tblOLAPFullSalesHierarchy where CoverageAreaHierID=@strKeyVal
	END
	ELSE IF @SalesLvl=7
	BEGIN
		SELECT @ReportHeader=[Zone] + '>>' + Region + '>>' + ASMArea + '>>' + SOArea + '>>' + DBR + '>>' + CoverageArea + '>>' + Route FROM tblOLAPFullSalesHierarchy where RouteHierId=@strKeyVal
	END


	CREATE TABLE #TempCompanySales(HierId VARCHAR(50), SalesLvl INT) 
	CREATE TABLE #TmpProduct (NodeID INT, NodeType INT)  
	CREATE TABLE #TmpChannel (NodeId INT,NodeType INT) 
	CREATE TABLE #TmpTime (TimeVal VARCHAR(50),NodeType int)  
	SELECT @LoginUserNodeID=NodeID,@LoginUserNodeType=NodeType 
	FROM tblSecUserLogin INNER JOIN tblSecUser ON tblSecUser.UserID=tblSecUserLogin.UserID WHERE LoginID=@LoginID

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
		SELECT @LoginUserMailID=ISNULL(PersonEmailID,'') FROM tblMstrPerson WHERE NodeId=@LoginUserNodeID
		
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
			SELECT DISTINCT B.ASMAreaHierID,1
			FROM #SalesAreas A INNER JOIN [tblOLAPFullSalesHierarchy] B ON A.SalesAreaNodeId=B.ASMAreaID AND A.SalesAreaNodeType=B.ASMAreaNodeType
		END
		ELSE IF @SalesAreaNodeType=120
		BEGIN
			INSERT INTO #TempCompanySales(HierId,SalesLvl)
			SELECT DISTINCT B.SOAreaHierID,2
			FROM #SalesAreas A INNER JOIN [tblOLAPFullSalesHierarchy] B ON A.SalesAreaNodeId=B.SOAreaID AND A.SalesAreaNodeType=B.SOAreaNodeType
		END
		ELSE IF @SalesAreaNodeType=150
		BEGIN
			INSERT INTO #TempCompanySales(HierId,SalesLvl)
			SELECT DISTINCT B.DBRHierID,3
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
	BEGIN  
		Select @TempStr = SUBSTRING(@StrProduct,0, PATINDEX('%|%',@StrProduct))  
		Select @StrProduct = SUBSTRING(@StrProduct,PATINDEX('%|%',@StrProduct)+1, LEN(@StrProduct))  
   
		SELECT @NodeId= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))
		SELECT @TempStr = SUBSTRING(@TempStr, PATINDEX('%^%',@TempStr) + 1 , LEN(@TempStr))
		SELECT @NodeType= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))  
   
		INSERT INTO #TmpProduct  
		SELECT @NodeId,@NodeType	
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

	
	SET @strMDXSalesKey=''
	SET @GroupStr=''  
	
	IF @SalesLvl=1
	BEGIN
		SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[Zone].&['+ @strKeyVal +']'
	END
	ELSE IF @SalesLvl=2
	BEGIN
		SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[Region].&['+ @strKeyVal +']'
	END
	ELSE IF @SalesLvl=3
	BEGIN
		SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[ASM Area].&['+ @strKeyVal +']'
	END
	ELSE IF @SalesLvl=4
	BEGIN
		SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[SO Area].&['+ @strKeyVal +']'
	END
	ELSE IF @SalesLvl=5
	BEGIN
		SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[Distributor].&['+ @strKeyVal +']'
	END
	ELSE IF @SalesLvl=6
	BEGIN
		SELECT @strMDXSalesKey= @strMDXSalesKey+'[SalesStructure].[Sales Hierarchy].[Coverage Area].&['+ @strKeyVal +']'
	END


	CREATE TABLE #Tmp(RowNo INT IDENTITY(1,1))

	CREATE TABLE #GroupLvl(ID INT IDENTITY(1,1), NodeType INT)
	DECLARE @GroupNodeType INT,@GroupType VARCHAR(200)
	DECLARE @strColumnWithAllMeasures VARCHAR(5000)=''

	--SELECT @RptLvlNodeType
	INSERT INTO #GroupLvl(NodeType)
	Select NodeType FROM tblPmstNodeTypes WHERE NodeType>@RptLvlNodeType AND NodeType NOT IN(160,170) AND HierTypeId IN(2,5) ORDER BY NodeType
	--UPDATE #GroupLvl SET NodeType=130 WHERE NodeType=160
	--UPDATE #GroupLvl SET NodeType=140 WHERE NodeType=170
	--SELECT * FROM #GroupLvl

	SET @counter  = 1
	WHILE(@counter <=(Select MAX(ID) FROM #GroupLvl))
	BEGIN
		SELECT @GroupNodeType = NodeType FROM #GroupLvl WHERE ID = @counter		
		SELECT @GroupType=NodeTypeDesc FROM tblPmstNodeTypes WHERE Nodetype=@GroupNodeType
		SELECT @GroupType=REPLACE(@GroupType,'DBR ','')

		IF @GroupNodeType=95
			SET @GroupStr=@GroupStr + '*[SalesStructure].[Zone].[Zone].MEMBERS'
		ELSE IF @GroupNodeType=100
			SET @GroupStr=@GroupStr + '*[SalesStructure].[Region].[Region].MEMBERS'
		ELSE IF @GroupNodeType=110
			SET @GroupStr=@GroupStr + '*[SalesStructure].[ASM Area].[ASM Area].MEMBERS'
		ELSE IF @GroupNodeType=120
			SET @GroupStr=@GroupStr + '*[SalesStructure].[SO Area].[SO Area].MEMBERS'
		ELSE IF @GroupNodeType=150
			SET @GroupStr=@GroupStr + '*[SalesStructure].[Distributor].[Distributor].MEMBERS'
		ELSE IF @GroupNodeType=130
			SET @GroupStr=@GroupStr + '*[SalesStructure].[Coverage Area].[Coverage Area].MEMBERS'
		ELSE IF @GroupNodeType=140
			SET @GroupStr=@GroupStr + '*[SalesStructure].[Route].[Route].MEMBERS'

		SET @strSQL = 'ALTER TABLE #Tmp ADD ['+@GroupType+'] VARCHAR(200)'
		PRINT @strSQL
		EXEC (@strSQL)

		SELECT @strColumnWithAllMeasures=@strColumnWithAllMeasures + '[' + @GroupType + ']' +','
		SET @counter = @counter + 1			
	END
	SET @GroupStr=@GroupStr + '*[SalesStructure].[StoreCode].[StoreCode].MEMBERS*[SalesStructure].[Store].[Store].MEMBERS'
	ALTER TABLE #Tmp ADD [Store Code] VARCHAR(200)
	ALTER TABLE #Tmp ADD [Store] VARCHAR(100)
	--ALTER TABLE #Tmp ADD [Store Class] VARCHAR(200)
	SELECT @strColumnWithAllMeasures=@strColumnWithAllMeasures + '[Store Code],[Store]'

	IF @MainMeasureId IN(6,7,8)--Callage
	BEGIN
		SET @GroupStr=@GroupStr + '*[TimeHierarchyDayLevel].[Date].[Date].MEMBERS'
		ALTER TABLE #Tmp ADD [Date] VARCHAR(20)
		SELECT @strColumnWithAllMeasures=@strColumnWithAllMeasures + ',[Date]'
	END
	SELECT @strColumnWithAllMeasures=@strColumnWithAllMeasures + ','
	--SET @strColumnWithAllMeasures=left(@strColumnWithAllMeasures,LEN(@strColumnWithAllMeasures)-1)
	SET @GroupStr=RIGHT(@GroupStr,LEN(@GroupStr)-1)
	PRINT 'GroupStr-' + @GroupStr
	PRINT 'strColumn-' + @strColumnWithAllMeasures
	--SELECT @GroupStr
	--SELECT @strColumnWithAllMeasures
	--SELECT * FROM #Tmp
	
	CREATE TABLE #tmpMeasure(Id INT, Measure VARCHAR(200), PId INT, PMeasure VARCHAR(200),OLAPMeasureName VARCHAR(200),ColumnName VARCHAR(200),ColumnDataType VARCHAR(20),POrdr INT,Ordr INT,FlgRound TINYINT,NoOfDecimals TINYINT,FlgPercentage TINYINT,flgForPopUp TINYINT)
	CREATE TABLE #MeasureDetails(ID INT IDENTITY(1,1), MeasureId INT,Measure VARCHAR(500),PMeasureId INT,PMeasure VARCHAR(500),OLAPMeasureName VARCHAR(200),ColumnName VARCHAR(200),ColumnDataType VARCHAR(20),POrdr INT,Ordr INT,FlgRound TINYINT,NoOfDecimals TINYINT,FlgPercentage TINYINT,ColorCode_1 VARCHAR(10),ColorCode_2 VARCHAR(10),flgForPopUp TINYINT,strColumnName VARCHAR(200))
			
	DECLARE @MeasureId INT,@OLAPMeasureName VARCHAR(200),@ColumnName VARCHAR(200),@ColumnDataType VARCHAR(20),@strColumnName VARCHAR(200)
	
	IF @MainMeasureId IN(6,7,8)--Callage
	BEGIN
		INSERT INTO #tmpMeasure(Id,Measure,PId,OLAPMeasureName,ColumnName,ColumnDataType,Ordr,FlgRound,NoOfDecimals,FlgPercentage)
		Select DISTINCT Id,Measure,PId,OLAPMeasureName,ColumnName,ColumnDataType,Ordr,FlgRound,NoOfDecimals,FlgPercentage 
		FROM tblMeasureListForMTDRetailRouteReport WHERE Id IN(6,7,8) AND flg=1 ORDER BY Ordr
	END
	ELSE
	BEGIN
		INSERT INTO #tmpMeasure(Id,Measure,PId,OLAPMeasureName,ColumnName,ColumnDataType,Ordr,FlgRound,NoOfDecimals,FlgPercentage)
		Select DISTINCT Id,Measure,PId,OLAPMeasureName,ColumnName,ColumnDataType,Ordr,FlgRound,NoOfDecimals,FlgPercentage 
		FROM tblMeasureListForMTDRetailRouteReport WHERE PId=2 OR (PId=1 AND Id IN(9,10,11)) ORDER BY Ordr
	END

	UPDATE B SET B.PMeasure =A.Measure,B.POrdr=A.Ordr--,B.ColorCode_1=A.ColorCode,B.ColorCode_2=A.ColorCode_2
	FROM tblMeasureListForMTDRetailRouteReport A INNER JOIN #tmpMeasure B ON A.Id=B.PId
	--SELECT * FROM #tmpMeasure

	INSERT INTO #MeasureDetails(MeasureId,Measure,PMeasureId,PMeasure,OLAPMeasureName,ColumnName,ColumnDataType,POrdr,Ordr,FlgRound,NoOfDecimals,FlgPercentage,flgForPopUp)
	Select DISTINCT Id,Measure,PId,PMeasure,OLAPMeasureName,ColumnName,ColumnDataType,POrdr,Ordr,FlgRound,NoOfDecimals,FlgPercentage,flgForPopUp 
	FROM #tmpMeasure WHERE PId<>0 --AND PId NOT IN(38)
	ORDER BY POrdr,Ordr
	
	----IF EXISTS(SELECT 1 FROM #MeasureDetails WHERE MeasureId=24)
	----BEGIN
	----	UPDATE #MeasureDetails SET Measure='Order Val',OLAPMeasureName='[Measures].[Net Order Value]' WHERE MeasureId=24
	----END
	--UPDATE #MeasureDetails SET strColumnName=PMeasure+'^'+Measure+ '|' + ColorCode_1 + '~' + ColorCode_2

	UPDATE #MeasureDetails SET Measure='Is Planned' WHERE MeasureId=9
	UPDATE #MeasureDetails SET Measure='Is Visited' WHERE MeasureId=10
	UPDATE #MeasureDetails SET Measure='Is Productive' WHERE MeasureId=11

	UPDATE #MeasureDetails SET Measure='Is Planned' WHERE MeasureId=6
	UPDATE #MeasureDetails SET Measure='Is Visited' WHERE MeasureId=7
	UPDATE #MeasureDetails SET Measure='Is Productive' WHERE MeasureId=8
	
	UPDATE #MeasureDetails SET strColumnName=Measure

	--SELECT * FROM #MeasureDetails ORDER BY Id
	
	
	--SELECT @strColumnWithAllMeasures='Region,Zone,[ASM Area],[SO Area],Distributor,[Coverage Area],[Route],Store,'
	--SELECT @strColumnWithAllMeasures=@strColumnWithAllMeasures

	SET @strMeasureName=''
	SET @counter  = 1
	WHILE(@counter <=(Select MAX(ID) FROM #MeasureDetails))
		BEGIN
			SELECT @MeasureId = MeasureId,@OLAPMeasureName=OLAPMeasureName,@strColumnName=strColumnName FROM #MeasureDetails WHERE ID = @counter
			
			IF ISNULL(@OLAPMeasureName,'')<>''
			BEGIN
				SET @strMeasureName=@strMeasureName + @OLAPMeasureName + ','
				SET @strColumnWithAllMeasures=@strColumnWithAllMeasures + '['+ @strColumnName + '],'	
			END

			--SET @strSQL = 'ALTER TABLE #Tmp ADD ['+@PMeasureName+'^'+@MeasureName+']' + @ColumnDataType
			SET @strSQL = 'ALTER TABLE #Tmp ADD ['+ @strColumnName + '] VARCHAR(200)'
			PRINT @strSQL
			EXEC (@strSQL)
			SET @counter = @counter + 1			
		END
	--SELECT * FROM #Tmp
	SET @strMeasureName=left(@strMeasureName,LEN(@strMeasureName)-1)
	PRINT '@strMeasureName-' + @strMeasureName
	SET @strColumnWithAllMeasures=left(@strColumnWithAllMeasures,LEN(@strColumnWithAllMeasures)-1)
	PRINT 'strColumnWithAllMeasures-' + @strColumnWithAllMeasures
	--SELECT @strMeasureName
	--SELECT @strColumnWithAllMeasures
	 
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
  	
	SET @strMDX='SELECT {' + @strMeasureName +'} ON COLUMNS, NON EMPTY  ({' + @GroupStr + ' }) DIMENSION PROPERTIES MEMBER_CAPTION ON ROWS '
		  
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
	--BEGIN TRY  
		IF @strMDXTime<>''
		BEGIN
			SET @strSQL = ''
			SET @strSQL = 'INSERT INTO #Tmp('+@strColumnWithAllMeasures+') '
			PRINT @strSQL
			SET @OPEN_QUERY =@strSQL +  @OPEN_QUERY
			EXECUTE SP_EXECUTESQL @OPEN_QUERY 
		END
	--END TRY  
	--BEGIN CATCH  
	--   --SELECT ERROR_NUMBER() AS ErrorNumber   
	--END CATCH 
	--SELECT * FROM #Tmp --order by lastlvlid

	DECLARE @FlgRound TINYINT
	DECLARE @NoOfDecimals TINYINT
	DECLARE @FlgPercentage TINYINT

	SET @counter  = 1
	WHILE(@counter <=(Select MAX(ID) FROM #MeasureDetails))
		BEGIN
			SELECT @MeasureId = MeasureId,@ColumnDataType=ColumnDataType, @FlgRound=FlgRound, @NoOfDecimals=NoOfDecimals,@FlgPercentage=FlgPercentage,@strColumnName=strColumnName
			FROM #MeasureDetails WHERE ID = @counter
			
			IF @FlgRound=1
			BEGIN
				SET @strSQL = 'ALTER TABLE #Tmp ALTER COLUMN ['+ @strColumnName + '] FLOAT'
				PRINT @strSQL
				EXEC (@strSQL)

				SET @strSQL = 'UPDATE #Tmp SET ['+ @strColumnName + ']=ROUND(['+ @strColumnName + '],' + CAST(@NoOfDecimals AS VARCHAR) + ')'
				PRINT @strSQL
				EXEC (@strSQL)
			END

			IF @FlgPercentage=1
			BEGIN
				SET @strSQL = 'ALTER TABLE #Tmp ALTER COLUMN ['+ @strColumnName + '] VARCHAR(50)'
				PRINT @strSQL
				EXEC (@strSQL)

				SET @strSQL = 'UPDATE #Tmp SET ['+ @strColumnName + ']=CAST(CAST(['+ @strColumnName + '] AS FLOAT)*100 AS VARCHAR) + ''%'''
				PRINT @strSQL
				EXEC (@strSQL)
			END
			ELSE
			BEGIN
				SET @strSQL = 'ALTER TABLE #Tmp ALTER COLUMN ['+ @strColumnName + ']' + @ColumnDataType
				PRINT @strSQL
				EXEC (@strSQL)
			END

			SET @strSQL = 'UPDATE #Tmp SET ['+ @strColumnName + ']=ISNULL(['+ @strColumnName + '],0)' 
			PRINT @strSQL
			EXEC (@strSQL)

			SET @counter = @counter + 1			
		END
	
	PRINT 'Grv1'
	ALTER TABLE #Tmp DROP COLUMN RowNo
	SELECT * FROM #Tmp --ORDER BY 1,2,3

	SELECT @ReportHeader AS ReportHeader,ISNULL(@LoginUserMailID,'') AS LoginUserMailID
END










