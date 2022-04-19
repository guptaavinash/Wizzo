   
-- [spGetPDAQuestOptionMstr] 2,'359670066016988'  
CREATE PROCEDURE [dbo].[spGetPDAQuestOptionMstr]   
@ApplicationID int,    
@PDACode VARCHAR(50)     
AS  
  
BEGIN  
	CREATE TABLE #PDAQuestOptionMaster(QuestID INT,OptID VARCHAR(200),OptionDescr VARCHAR(200),Sequence INT) 

	--SELECT * FROM tblDynamic_PDAQuestMstr  
	INSERT INTO #PDAQuestOptionMaster
	SELECT     tblDynamic_PDAQuestMstr.QuestID, CAST(tblDynamic_PDAQuestOptionMstr.OptID AS VARCHAR) + '-0-0' , tblDynamic_PDAQuestOptionMstr.OptionDescr, ISNULL(tblDynamic_PDAQuestOptionMstr.Sequence,0)           
	FROM         tblDynamic_PDAQuestMstr INNER JOIN    
	tblDynamic_PDAQuestOptionMstr ON tblDynamic_PDAQuestMstr.QuestID=tblDynamic_PDAQuestOptionMstr.QuestID 
	INNER JOIN [tblDynamic_ApplicationQuestMappingMstr] AM ON AM.QuestID= tblDynamic_PDAQuestMstr.QuestID  
	WHERE tblDynamic_PDAQuestOptionMstr.[ActiveOption]=1 AND tblDynamic_PDAQuestMstr.ActiveQuest=1 AND ISNULL(AnsSourceTypeID,0)<>2 AND AM.ApplicationTypeID=@ApplicationID --AND tblDynamic_PDAQuestOptionMstr.QuestID<>1  
  
	DECLARE @MAXID INT  
	DECLARE @Count INT  
	DECLARE @QuestID INT  
	DECLARE @CurrentNodeType SMALLINT  
	DECLARE @tablename VARCHAR(200)  
	DECLARE @DetTableColumnname VARCHAR(200)  
	DECLARE @DetTableIDColumn VARCHAR(200)
	DECLARE @SQL VARCHAR(MAX)=''  
	DECLARE @HierTypeID TINYINT
	SET @Count=1 
	DECLARE @DeviceID INT
	DECLARE @PersonID INT     
	DECLARE @PersonType INT  

	SELECT NodeType INTO #RouteNodeTypes FROM tblSecMenuContextMenu WHERE flgRoute=1
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMEINo OR PDA_IMEI_Sec=@IMEINo  
	--SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@DeviceID  AND (GETDATE() BETWEEN DateFrom AND DateTo)
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	PRINT '@PersonID=' + CAST(@PersonID AS VARCHAR)
	PRINT '@@PersonType=' + CAST(@PersonType AS VARCHAR)

	CREATE TABLE #TodaysCoverageArea(SalesAreaNodeID INT,SalesAreaNodeType INT)

	CREATE TABLE #SalesAreaIDs(NodeID INT,NodeType INT)

	INSERT INTO #TodaysCoverageArea(SalesAreaNodeID,SalesAreaNodeType)
	SELECT DISTINCT SalesAreaNodeID,SalesAreaNodeType FROM tblVanStockMaster WHERE SalesmanNodeID=@PersonID AND SalesmanNodeType=@PersonType AND CAST(TransDate AS DATE)=CAST(GETDATE() AS DATE)

	--SELECT * FROM #TodaysCoverageArea

	----IF EXISTS(SELECT 1 FROM #TodaysCoverageArea)
	----BEGIN
	----	PRINT 'MM'
	----	INSERT INTO #SalesAreaIDs(NodeID,NodeType)
	----	SELECT SalesAreaNodeID,SalesAreaNodeType FROM #TodaysCoverageArea
	----	UNION
	----	SELECT DSRRouteNodeID,DSRRouteNodeType FROM [VwCompanyDSRFullDetail] V INNER JOIN #TodaysCoverageArea C ON C.SalesAreaNodeID=V.DSRAreaID AND C.SalesAreaNodeType=V.DSRAreaNodeType
	----	UNION
	----	SELECT DBRRouteID,RouteNodeType FROM [VwDistributorDSRFullDetail] V INNER JOIN #TodaysCoverageArea C ON C.SalesAreaNodeID=V.DBRCoverageID AND C.SalesAreaNodeType=V.DBRCoverageNodeType

	----	--SELECT * FROM #SalesAreaIDs
	----END
	----ELSE
	----BEGIN
		INSERT INTO #SalesAreaIDs(NodeID,NodeType)
		SELECT  DISTINCT NodeID,SP.NodeType 
		FROM   tblSalesPersonMapping SP WHERE ( SP.PersonNodeID=@PersonID AND SP.PersonType=@PersonType) AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)
	----END

	

	--SELECT * FROM #SalesAreaIDs
	CREATE TABLE #CoverageArea(NodeID INT,NodeType SMALLINT)
	IF @PersonType IN (220,230)
	BEGIN
		INSERT INTO  #CoverageArea
		SELECT P.NodeID,P.NodeType  
		FROM tblSalesPersonMapping P     
		INNER JOIN [dbo].[tblSecMenuContextMenu] S ON S.NodeType=P. NodeType     
		WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) AND S.flgCoverageArea=1
	END
	ELSE IF @PersonType=210
		INSERT INTO  #CoverageArea
		SELECT V.DSRAreaID,V.DSRAreaNodeType  
		FROM tblSalesPersonMapping P INNER JOIN [dbo].[VwCompanySalesHierarchy] V ON V.ASMAreaID=P.NodeID AND V.ASMAreaNodeType=P.NodeType 
		WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) 

	

	CREATE TABLE #RouteIDs(NodeID INT,NodeType SMALLINT)
	CREATE TABLE #DBRList(NodeID INT,NodeType INT,Distributor VARCHAR(200))

	INSERT INTO #RouteIDs(NodeID,NodeType)
	SELECT DISTINCT  RouteNodeId,RouteNodetype FROM tblRoutePlanningVisitDetail R INNER JOIN #CoverageArea C ON C.NodeID=R.CovAreaNodeID AND C.NodeType=R.CovAreaNodeType
	
	--SELECT * FROM #RouteIDs
 
	SELECT @HierTypeID=HierTypeID FROM [dbo].[tblSecMenuContextMenu] WHERE NodeType IN (SELECT TOP 1 NodeType FROM #RouteIDs)
	PRINT '@HierTypeID=' + CAST(ISNULL(@HierTypeID,0) AS VARCHAR)
	
	----IF @HierTypeID=5
	----BEGIN
	----	INSERT INTO #DBRList(NodeID,NodeType,Distributor)
	----	SELECT DISTINCT A.DBRNodeID,A.DistributorNodeType,A.Distributor
	----	FROM VwAllDistributorHierarchy A INNER JOIN #RouteIDs C on C.NodeId=A.DBRRouteId AND C.NodeType=A.RouteNodeType	
	----END
	----ELSE
	BEGIN
		PRINT 'BB'
		INSERT INTO #DBRList(NodeID,NodeType,Distributor)
		SELECT DISTINCT DBR.NodeID,DBR.NodeType,DBR.Descr
		FROM #CoverageArea C INNER JOIN tblCompanySalesStructure_DistributorMapping Map ON C.NodeId=Map.SHNodeId AND C.NodeType=Map.SHNodeType
		INNER JOIN tblDBRSalesStructureDBR DBR ON Map.DHNodeId=DBR.NodeID AND Map.DHNodeType=DBR.NodeType
		WHERE DBR.IsActive=1 AND (GETDATE() BETWEEN Map.FromDate AND Map.ToDate)
	END
	--SELECT * FROM #DBRList

	CREATE TABLE #tblLoop(ID INT IDENTITY(1,1),QstID INT)  
	INSERT INTO #tblLoop(QstID)  
	SELECT DISTINCT QuestID FROM tblDynamic_PDAQuestMstr WHERE ISNULL(AnsSourceTypeID,0)=2  
 
  
	SELECT @MAXID=MAX(ID) FROM #tblLoop  
	PRINT '@MAXID' + CAST(@MAXID AS VARCHAR)  
	WHILE (@MAXID>=@Count)  
	BEGIN  
	 PRINT '@Count' + CAST(@Count AS VARCHAR)  
	 SELECT @QuestID=QstID FROM #tblLoop WHERE ID=@Count  
	 SELECT @CurrentNodeType=AnsSourceNodeType FROM tblDynamic_PDAQuestMstr WHERE QuestID=@QuestID AND tblDynamic_PDAQuestMstr.ActiveQuest=1
		PRINT '@CurrentNodeType'
		PRINT @CurrentNodeType
	 SELECT @tablename=DetTable,@DetTableColumnname=Dettablenamedcolumn,@DetTableIDColumn=Deltableidcolumn FROM tblPMstNodeTypes WHERE NodeType=@CurrentNodeType  

	 PRINT '@tablename=' + @tablename  
	 --SELECT 1,'0-' + CAST(NodeID AS VARCHAR) + '-' + CAST(NodeType AS VARCHAR) ,'',ROW_NUMBER() OVER (ORDER BY NodeID) FROM tblChannelMstr 
	 IF  @tablename='tblDBRSalesStructureRouteMstr'
	 BEGIN
		 SET @SQL='INSERT INTO #PDAQuestOptionMaster(QuestID,OptID,OptionDescr,Sequence) '  
		 SET @SQL=@SQL + 'SELECT ' + CAST(@QuestID AS VARCHAR) + ',''0-''+' + 'CAST(' + @tablename + '.' + @DetTableIDColumn + ' AS VARCHAR) +' + '''-''+' + 'CAST(' + @tablename + '.' + 'NodeType AS VARCHAR),' + @DetTableColumnname + ',ROW_NUMBER () OVER(ORDER BY ' + @tablename + '.' + @DetTableIDColumn + ') FROM ' + @tablename + ' INNER JOIN #RouteIDs R ON R.NodeID=' + @tablename + '.' + @DetTableIDColumn + ' AND R.NodeType=' + @tablename + '.NodeType'
		 PRINT '@SQL=' + @SQL  
		 EXEC (@SQL)  
		 --SET @Count=@Count + 1 

		  -- added by gaurav for hardcoded entry of company route
		 SELECT @tablename='tblCompanySalesStructureRouteMstr'
		  SET @SQL='INSERT INTO #PDAQuestOptionMaster(QuestID,OptID,OptionDescr,Sequence) '  
		 SET @SQL=@SQL + 'SELECT ' + CAST(@QuestID AS VARCHAR) + ',''0-''+' + 'CAST(' + @tablename + '.' + @DetTableIDColumn + ' AS VARCHAR) +' + '''-''+' + 'CAST(' + @tablename + '.' + 'NodeType AS VARCHAR),' + @DetTableColumnname + ',ROW_NUMBER () OVER(ORDER BY ' + @tablename + '.' + @DetTableIDColumn + ') FROM ' + @tablename + ' INNER JOIN #RouteIDs R ON R.NodeID=' + @tablename + '.' + @DetTableIDColumn  + ' AND R.NodeType=' + @tablename + '.NodeType'
		 PRINT '@SQL=' + @SQL  
		 EXEC (@SQL)  

	  END
	ELSE IF @tablename='tblCompanySalesStructureRouteMstr'
		BEGIN
		 SELECT @tablename='tblCompanySalesStructureRouteMstr'
		 PRINT @QuestID
		 PRINT @tablename
		 PRINT @DetTableIDColumn
		 PRINT @DetTableColumnname
		  SET @SQL='INSERT INTO #PDAQuestOptionMaster(QuestID,OptID,OptionDescr,Sequence) '  
		 SET @SQL=@SQL + 'SELECT ' + CAST(@QuestID AS VARCHAR) + ',''0-''+' + 'CAST(' + @tablename + '.' + @DetTableIDColumn + ' AS VARCHAR) +' + '''-''+' + 'CAST(' + @tablename + '.' + 'NodeType AS VARCHAR),' + @DetTableColumnname + ',ROW_NUMBER () OVER(ORDER BY ' + @tablename + '.' + @DetTableIDColumn + ') FROM ' + @tablename + ' INNER JOIN #RouteIDs R ON R.NodeID=' + @tablename + '.' + @DetTableIDColumn  + ' AND R.NodeType=' + @tablename + '.NodeType'
		 PRINT 'BEFORE'
		 PRINT '@SQL=' + @SQL  
		 EXEC (@SQL)  
		 PRINT 'AFTER'

		 -- Added by Avinash to include the distributor routes
		 ---- SELECT @tablename='tblDBRSalesStructureRouteMstr'
		 ---- SET @SQL='INSERT INTO #PDAQuestOptionMaster(QuestID,OptID,OptionDescr,Sequence) '  
		 ----SET @SQL=@SQL + 'SELECT ' + CAST(@QuestID AS VARCHAR) + ',''0-''+' + 'CAST(' + @tablename + '.' + @DetTableIDColumn + ' AS VARCHAR) +' + '''-''+' + 'CAST(' + @tablename + '.' + 'NodeType AS VARCHAR),' + @DetTableColumnname + ',ROW_NUMBER () OVER(ORDER BY ' + @tablename + '.' + @DetTableIDColumn + ') FROM ' + @tablename + ' INNER JOIN #RouteIDs R ON R.NodeID=' + @tablename + '.' + @DetTableIDColumn + ' AND R.NodeType=' + @tablename + '.NodeType'
		 ----PRINT '@SQL=' + @SQL  
		 ----EXEC (@SQL)  
		-- SET @Count=@Count + 1 
		END

	 ELSE IF  @tablename='tblDBRSalesStructureDBR'
	 BEGIN
		PRINT @tablename
		SET @SQL='INSERT INTO #PDAQuestOptionMaster(QuestID,OptID,OptionDescr,Sequence) '  
		 SET @SQL=@SQL + 'SELECT ' + CAST(@QuestID AS VARCHAR) + ',''0-''+' + 'CAST(' + @tablename + '.' + @DetTableIDColumn + ' AS VARCHAR) +' + '''-''+' + 'CAST(' + @tablename + '.' + 'NodeType AS VARCHAR),' + @DetTableColumnname + ',ROW_NUMBER () OVER(ORDER BY ' + @tablename + '.' + @DetTableIDColumn + ') FROM ' + @tablename + ' INNER JOIN #DBRList R ON R.NodeID=' + @tablename + '.' + @DetTableIDColumn + ' AND R.NodeType=' + @tablename + '.NodeType'
		 PRINT '@SQL=' + @SQL  
		 EXEC (@SQL) 
	 END
	 ELSE
	 BEGIN

		 SET @SQL='INSERT INTO #PDAQuestOptionMaster(QuestID,OptID,OptionDescr,Sequence) '  
		 SET @SQL=@SQL + 'SELECT ' + CAST(@QuestID AS VARCHAR) + ',''0-''+' + 'CAST(' + @DetTableIDColumn + ' AS VARCHAR) +' + '''-''+' + 'CAST(NodeType AS VARCHAR),' + @DetTableColumnname + ',ROW_NUMBER () OVER(ORDER BY ' + @DetTableIDColumn + ') FROM ' + @tablename 
		 --+ ' WHERE ' +  @tablename + '.ISACTIVE=1'
		 PRINT '@SQL=' + @SQL  
		 EXEC (@SQL)  
		 --SET @Count=@Count + 1 
	 END  
	 --PRINT '@SQL=' + @SQL  
	 --EXEC (@SQL)  
	 SET @Count=@Count + 1  
	END  



	SELECT * FROM #PDAQuestOptionMaster P 
  
END  
  
  
  
  
  
  

