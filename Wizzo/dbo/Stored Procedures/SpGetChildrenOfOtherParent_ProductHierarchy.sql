-- =============================================
-- Author:		Avinash Gupta
-- ALTER date: 30Aug2016
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpGetChildrenOfOtherParent_ProductHierarchy] --1,23
	@NodeID int = 0, 
	@NodeType int = 0
AS
BEGIN
	DECLARE @tblHier VARCHAR(50)
	DECLARE @tblDesc VARCHAR(50)
	DECLARE @FrameID INT
	DECLARE @HierTypeID INT
	DECLARE @strSQL VARCHAR(4000)

	DECLARE @ChildNodeType INT
	DECLARE @ParentNodeID INT
	DECLARE @ParentNodeType INT

	CREATE TABLE #tblChildList (HierID INT ,Descr VARCHAR(200),PHierID INT,NodeID INT,NodeType INT,LstLevel INT,PNodeID INT,PNodeType INT)


	EXEC spUTLGetSQLTblSource @NodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

	;WITH CTEAllChilds AS 
	( 
	--initialization 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM [dbo].[tblPrdMstrHierarchy]  
	WHERE (NodeID<> @NodeID AND NodeType=@NodeType) 
	UNION ALL 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM [dbo].[tblPrdMstrHierarchy]  
	WHERE PNodeID<> @NodeID AND PNodeType=@NodeType AND @NodeID=0 AND @NodeType=0
	UNION ALL 
	--recursive execution 
	SELECT C.NodeID, C.NodeType, C.HierID ,C.PNodeID,C.PNodeType,C.PHierID,O.LstLevel + 1
	FROM [dbo].[tblPrdMstrHierarchy] C INNER JOIN CTEAllChilds O
	ON C.PHierID = O.HierID 
	) 

	SELECT * INTO #cteallchilds FROM CTEAllChilds
--SELECT *  FROM #cteallchilds


	SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@NodeType

	EXEC spUTLGetSQLTblSource @ChildNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

	SET @strSQL='INSERT INTO #tblChildList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType) '
	SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,C.LstLevel,C.PNodeID,C.PNodeType FROM ' + @tblDesc + ' T INNER JOIN #cteallchilds C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE PNodeType=' + CAST(@NodeType AS VARCHAR)
	PRINT @strSQL
	EXEC (@strSQL)

	SELECT NodeID,Descr NodeName,NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType FROM #tblChildList

	----IF @NodeType =10
	----	SELECT RegionID AS NodeID,Region NodeName FROM VwSalesHierarchy WHERE BusinessID<>@NodeID
	----ELSE IF @NodeType =4
	----	SELECT AreaID AS NodeID,Area NodeName FROM VwSalesHierarchy WHERE AreaID<>@NodeID
	----ELSE IF @NodeType =5
	----	SELECT SEAreaID AS NodeID,SEArea NodeName FROM VwSalesHierarchy WHERE SEAreaID<>@NodeID
END



