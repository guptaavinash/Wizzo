


--[spGetPDAQuestionDepOptionMstr]1,'123'

CREATE PROCEDURE [dbo].[spGetPDAQuestionDepOptionMstr]

@ApplicationID int,  
@PDACode VARCHAR(50)
AS

BEGIN

	DECLARE @HiertypeID INT
	DECLARE @PersonNodeID INT,@PersonType SMALLINT
	--- Option 
	SELECT    NodeID,SP.NodeType INTO #SalesAreaIDs 
	FROM         
	tblSalesPersonMapping SP  
	WHERE (SP.PersonNodeID=@PersonNodeID AND SP.PersonType=@PersonType) AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate) 

	SELECT @HiertypeID=HiertypeID FROM tblpmstnodetypes P INNER JOIN #SalesAreaIDs S ON S.NodeType=P.NodeType

	CREATE TABLE #cte(NodeID INT,NodeType SMALLINT)
	IF @HiertypeID=2
	BEGIN
		PRINT '@HiertypeID=' + CAST(@HiertypeID AS VARCHAR)
		;WITH CTE AS 
		( 
		--initialization 
		SELECT DISTINCT H.NodeID, H.NodeType
		FROM tblCompanySalesStructureHierarchy H INNER JOIN  #SalesAreaIDs S ON S.NodeID=H.NodeID AND S.NodeType=H.NodeType
		UNION  All
		--recursive execution 
		SELECT C.PNodeID, C.PNodeType
		FROM tblCompanySalesStructureHierarchy C INNER JOIN CTE O
		ON C.NodeID = O.NodeID AND C.NodeType=O.NodeType 
		) 
		INSERT INTO #cte
		SELECT DISTINCT NodeID,NodeType FROM CTE
	END
	ELSE
	BEGIN
		PRINT '@HiertypeID=' + CAST(@HiertypeID AS VARCHAR)
		;with CTE as
		(
		SELECT  DISTINCT    SHNodeId NodeID , SHNodeType NodeType
		FROM            tblCompanySalesStructure_DistributorMapping DM INNER JOIN #SalesAreaIDs S ON S.NodeID=DM.DHNodeID AND S.NodeType=DM.DHNodeType INNER JOIN tblCompanySalesStructureHierarchy H ON S.NodeID=H.NodeID AND S.NodeType=H.NodeType
		WHERE GETDATE() between FromDate and ToDate
		UNION All
		select A.PNodeID,A.PNodeType from tblCompanySalesStructureHierarchy A join CTE B
		ON B.NodeId=A.NodeId	and B.NodeType=A.NodeType 
		)
		INSERT INTO #cte
		SELECT DISTINCT NodeID,NodeType FROM CTE
	END

	SELECT D.QstId,D.DepQstId,D.GrpQuestID,D.GrpDepQuestID 

	FROM tblDynamic_PDAQuestDepOptionsMstr D INNER JOIN [dbo].[tblDynamic_PDAQuestMstr] Q ON Q.QuestID=D.DepQstId

	WHERE Q.ActiveQuest=1



	CREATE TABLE #QstnDepOptions(DepQstId INT,DepOptID VARCHAR(200),QuestId  INT,OptID VARCHAR(200),OptDescr VARCHAR(200),Sequence INT,GrpQuestID INT,GrpDepQuestID INT,DepNodeID INT,DepNodeType SMALLINT,NodeID INT,NodeType SMALLINT )  

	

	INSERT INTO #QstnDepOptions(DepQstId,DepOptID,QuestId,OptID,OptDescr,Sequence,GrpQuestID,GrpDepQuestID,DepNodeID,DepNodeType,NodeID,NodeType) 

	SELECT D.DepQuestId,CAST(ISNULL(D.DepOptID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.DepNodeID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.DepNodeType,0) AS VARCHAR) AS DepOptID,

	D.QuestId,CAST(ISNULL(D.OptID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.NodeID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.NodeType,0) AS VARCHAR) AS OptID,

	OptDescr,ISNULL(D.Sequence,0),GrpQuestID,GrpDepQuestID,DepNodeID,D.DepNodeType,D.NodeID,D.NodeType

	FROM tblDynamic_PDAQuestOptionsWithDepOptions D INNER JOIN [dbo].[tblDynamic_PDAQuestMstr] Q ON Q.QuestID=D.DepQuestId

	INNER JOIN [dbo].[tblDynamic_PDAQuestMstr] PQ ON PQ.QuestID=D.QuestId
	INNER JOIN [tblDynamic_ApplicationQuestMappingMstr] AM ON AM.QuestID= PQ.QuestID  
	WHERE Q.ActiveQuest=1  AND ISNULL(PQ.AnsSourceTypeID,0)<>2 AND AM.ApplicationTypeID=@ApplicationID --AND ISNULL(Q.AnsSourceTypeID,0)<>2



	CREATE TABLE #tblLoop(ID INT IDENTITY(1,1),QstID INT,DepQstID INT,GrpQuestID INT,GrpDepQuestID INT)  

	INSERT INTO #tblLoop(QstID,DepQstID,GrpQuestID,GrpDepQuestID)  

	SELECT DISTINCT PD.QstID,PD.DepQstId,PD.GrpQuestID,PD.GrpDepQuestID FROM tblDynamic_PDAQuestDepOptionsMstr PD INNER JOIN [tblDynamic_PDAQuestMstr] PQ ON PQ.QuestID=PD.QstID

	INNER JOIN [tblDynamic_PDAQuestMstr] PQ1 ON PQ1.QuestID=PD.DepQstId

	WHERE ISNULL(PQ.AnsSourceTypeID,0)=2  AND  ISNULL(PQ1.AnsSourceTypeID,0)=2 AND PQ.ActiveQuest=1 AND PQ.AnsSourceOptionDep=1

 

	 DECLARE @MAXID INT  

	DECLARE @Count INT  

	DECLARE @QuestID INT 

	DECLARE @DepQuestID INT 

	DECLARE @GrpQuestID INT 

	DECLARE @GrpDepQuestID INT 



	DECLARE @CurrentNodeType SMALLINT 

	DECLARE @ParentNodeType SMALLINT  

	DECLARE @tablename VARCHAR(200)  

	DECLARE @DetTableColumnname VARCHAR(200)  

	DECLARE @DetTableIDColumn VARCHAR(200)

	DECLARE @Parenttablename VARCHAR(200)  

	DECLARE @ParentDetTableColumnname VARCHAR(200)  

	DECLARE @ParentDetTableIDColumn VARCHAR(200)

	DECLARE @IsPartHierarchy TINYINT --0=No,1=Yes

	DECLARE @HierarchyTable VARCHAR(200)

	DECLARE @SQL VARCHAR(MAX)=''  

	SET @Count=1 

  

	SELECT @MAXID=MAX(ID) FROM #tblLoop  

	PRINT '@MAXID' + CAST(@MAXID AS VARCHAR)  

	WHILE (@MAXID>=@Count)  

	BEGIN  

	 PRINT '@Count' + CAST(@Count AS VARCHAR)  

	 SELECT @QuestID=QstID,@DepQuestID=DepQstID,@GrpQuestID=GrpQuestID,@GrpDepQuestID=GrpDepQuestID FROM #tblLoop WHERE ID=@Count  

	 SELECT @CurrentNodeType=AnsSourceNodeType FROM tblDynamic_PDAQuestMstr WHERE QuestID=@QuestID AND tblDynamic_PDAQuestMstr.ActiveQuest=1 

	 SELECT @ParentNodeType= AnsSourceNodeType FROM tblDynamic_PDAQuestMstr WHERE QuestID=@DepQuestID AND tblDynamic_PDAQuestMstr.ActiveQuest=1 



	 SELECT @tablename=DetTable,@DetTableColumnname=Dettablenamedcolumn,@DetTableIDColumn=Deltableidcolumn,@IsPartHierarchy=CASE ISNULL(Hierarchytable,'') WHEN '' THEN 0 ELSE 1 END ,@HierarchyTable=Hierarchytable FROM tblPMstNodeTypes WHERE NodeType=@CurrentNodeType 

	 SELECT @Parenttablename=DetTable,@ParentDetTableColumnname=Dettablenamedcolumn,@ParentDetTableIDColumn=Deltableidcolumn FROM tblPMstNodeTypes WHERE NodeType=@ParentNodeType

	  

	 PRINT '@tablename=' + @tablename  
	 PRINT  '@DetTableColumnname=' + @DetTableColumnname
	 PRINT '@DetTableIDColumn=' + @DetTableIDColumn
	 PRINT '@IsPartHierarchy=' + CAST(@IsPartHierarchy AS VARCHAR)
	 PRINT '@HierarchyTable=' + @HierarchyTable
	  PRINT '@Parenttablename=' + @Parenttablename  

	 --SELECT 1,'0-' + CAST(NodeID AS VARCHAR) + '-' + CAST(NodeType AS VARCHAR) ,'',ROW_NUMBER() OVER (ORDER BY NodeID) FROM tblChannelMstr 



	---- SELECT D.DepQuestId,CAST(ISNULL(D.DepOptID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.DepNodeID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.DepNodeType,0) AS VARCHAR) AS DepOptID,

	----D.QuestId,CAST(ISNULL(D.OptID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.NodeID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.NodeType,0) AS VARCHAR) AS OptID,

	----OptDescr,D.Sequence,GrpQuestID,GrpDepQuestID,DepNodeID,D.DepNodeType,D.NodeID,D.NodeType

	----FROM tblDynamic_PDAQuestOptionsWithDepOptions D INNER JOIN [dbo].[tblDynamic_PDAQuestMstr] Q ON Q.QuestID=D.DepQuestId

	----INNER JOIN [dbo].[tblDynamic_PDAQuestMstr] PQ ON PQ.QuestID=D.QuestId

	----WHERE Q.ActiveQuest=1 AND ISNULL(Q.AnsSourceTypeID,0)<>2 AND ISNULL(PQ.AnsSourceTypeID,0)<>2



	IF @IsPartHierarchy=1

	BEGIN

		SET @SQL='INSERT INTO #QstnDepOptions(DepQstId,DepOptID,QuestId,OptID,OptDescr,Sequence,GrpQuestID,GrpDepQuestID,DepNodeID,DepNodeType,NodeID,NodeType) '  

		SET @SQL=@SQL + 'SELECT ' + CAST(@DepQuestID AS VARCHAR) + ',''0-''' + ' + CAST(' + @HierarchyTable + '.' + 'PNodeID AS VARCHAR)+' + '''-''' + '+CAST(' + @HierarchyTable + '.' + 'PNodeType AS VARCHAR),' + CAST(@QuestID AS VARCHAR) + ',' + '''0-''' + '+ 
CAST(' + @HierarchyTable + '.' + 'NodeID AS VARCHAR) +' + '''-''' + '+CAST(' + @HierarchyTable + '.' + 'NodeType AS VARCHAR),' + @tablename + '.' + @DetTableColumnname + ',ROW_NUMBER () OVER(ORDER BY ' + @tablename + '.' + @DetTableIDColumn + ') ,' +  CAST(@GrpQuestID AS VARCHAR) + ' ,' + CAST(@GrpDepQuestID AS VARCHAR) + ',' + 'CAST(' + @HierarchyTable + '.' + 'PNodeID AS VARCHAR)' + ',' + 'CAST(' + @HierarchyTable + '.' + 'PNodeType AS VARCHAR),' + 'CAST(' + @HierarchyTable + '.' + 'NodeID AS VARCHAR),'
 + 'CAST(' + @HierarchyTable + '.' + 'NodeType AS VARCHAR)' + '	FROM ' + @HierarchyTable + ' INNER JOIN ' + @tablename + ' ON ' + @tablename + '.' + @DetTableIDColumn + '=' + @HierarchyTable + '.NodeID' + ' AND ' +  @HierarchyTable + '.NodeType=' +  CAST(
@CurrentNodeType AS VARCHAR) + ''

	END

	





	----SET @SQL=@SQL + 'SELECT ' + CAST(@QuestID AS VARCHAR) + ',''0-''+' + 'CAST(' + @tablename + '.' + @DetTableIDColumn + ' AS VARCHAR) +' + '''-''+' + 'CAST(' + @tablename + '.' + 'NodeType AS VARCHAR),' + @DetTableColumnname + ',ROW_NUMBER () OVER(ORDER BY ' + @tablename + '.' + @DetTableIDColumn + ') FROM ' + @tablename + ' INNER JOIN #RouteIDs R ON R.NodeID=' + @tablename + '.' + @DetTableIDColumn 

	 	 

	 PRINT '@SQL=' + @SQL  

	 EXEC (@SQL)  

	 SET @Count=@Count + 1  

	END  


	--CREATE TABLE #QstnDepOptions(DepQstId INT,DepOptID VARCHAR(200),QuestId  INT,OptID VARCHAR(200),OptDescr VARCHAR(200),Sequence INT,GrpQuestID INT,GrpDepQuestID INT,DepNodeID INT,DepNodeType SMALLINT,NodeID INT,NodeType SMALLINT )  

	SELECT DepQstId,DepOptID,QuestId,OptID,OptDescr,ISNULL(Sequence,0) Sequence,GrpQuestID,GrpDepQuestID FROM #QstnDepOptions

END



