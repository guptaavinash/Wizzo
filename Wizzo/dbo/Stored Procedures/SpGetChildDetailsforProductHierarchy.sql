
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 27-Apr-2015
-- Description:	Sp to get the Product Hierarchy Details list
-- =============================================
-- SpGetChildDetailsforProductHierarchy 3,30,2914,1
CREATE PROCEDURE [dbo].[SpGetChildDetailsforProductHierarchy] 
	@NodeID int = 0, 
	@NodeType int = 0,
	@HierID INT,
	@flg INT=1, -- 0-All,1-Immediate
	@ManufacturerID INT=0
AS
BEGIN

DECLARE @tblHier VARCHAR(50)
DECLARE @tblDesc VARCHAR(50)
DECLARE @FrameID INT
DECLARE @HierTypeID INT
DECLARE @strSQL VARCHAR(4000)

DECLARE @ChildNodeType INT	

CREATE TABLE #tblChildList (HierID INT ,Descr VARCHAR(200),PHierID INT,NodeID INT,NodeType INT,LstLevel INT)

;WITH CTEAllChilds AS 
	( 
	--initialization 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM tblPrdMstrHierarchy  
	WHERE (NodeID= @NodeID AND NodeType=@NodeType AND HierID=@HierID) 
	UNION ALL 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM tblPrdMstrHierarchy  
	WHERE PNodeID= @NodeID AND PNodeType=@NodeType AND @NodeID=0 AND @NodeType=0
	UNION ALL 
	--recursive execution 
	SELECT C.NodeID, C.NodeType, C.HierID ,C.PNodeID,C.PNodeType,C.PHierID,O.LstLevel + 1
	FROM tblPrdMstrHierarchy C INNER JOIN CTEAllChilds O
	ON C.PHierID = O.HierID 
	) 

SELECT * INTO #cteallchilds FROM CTEAllChilds

--SELECT * FROM #cteallchilds --WHERE PNodeType=@NodeType

IF @flg=1
BEGIN
	SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@NodeType

	EXEC spUTLGetSQLTblSource @ChildNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

	SET @strSQL='INSERT INTO #tblChildList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel) '
	SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,C.LstLevel FROM ' + @tblDesc + ' T INNER JOIN #cteallchilds C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE PNodeType=' + CAST(@NodeType AS VARCHAR)
	PRINT @strSQL
	EXEC (@strSQL)
END
ELSE
BEGIN
	SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@NodeType
	PRINT '@ChildNodeType=' + CAST(ISNULL(@ChildNodeType,0) AS VARCHAR)
	WHILE (ISNULL(@ChildNodeType,0)>0)
	BEGIN
		PRINT '@ChildNodeType=' + CAST(@ChildNodeType AS VARCHAR)
		EXEC spUTLGetSQLTblSource @ChildNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

		SET @strSQL='INSERT INTO #tblChildList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel) '
		SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,C.LstLevel FROM ' + @tblDesc + ' T INNER JOIN #cteallchilds C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE T.NodeType=' + CAST(@ChildNodeType AS VARCHAR)
		PRINT @strSQL
		EXEC (@strSQL)

		IF EXISTS(SELECT 1 FROM #cteallchilds WHERE PNodeType=@ChildNodeType)
			SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@ChildNodeType
		ELSE 
			SELECT @ChildNodeType=0
		PRINT '@ChildNodeType=' + CAST(@ChildNodeType AS VARCHAR)
	END
	
END
--SELECT * FROM #tblChildList ORDER BY NodeType,NodeId
----IF ISNULL(@ManufacturerID,0)<>0
----BEGIN
----	IF @NodeType=10
----	BEGIN
----		DELETE FROM #tblChildList WHERE NodeType=@NodeType AND NodeID NOT IN (SELECT SegmentNodeID FROM VwProductHierarchy WHERE ManufacturerID=@ManufacturerID)
----	END
----	ELSE IF @NodeType=20
----	BEGIN
----		DELETE FROM #tblChildList WHERE NodeType=@NodeType AND NodeID NOT IN (SELECT CategoryNodeId FROM VwProductHierarchy WHERE ManufacturerID=@ManufacturerID)
----	END
----	ELSE IF @NodeType=30
----	BEGIN
----		DELETE FROM #tblChildList WHERE NodeType=@NodeType AND NodeID NOT IN (SELECT SKUNodeID FROM VwProductHierarchy WHERE ManufacturerID=@ManufacturerID)
----	END
----END

UPDATE #tblChildList SET PHierID=NULL WHERE PHierID =0

IF @NodeType=30 --- in case of product click only
BEGIN
	UPDATE C SET C.Descr=C.Descr FROM #tblChildList C INNER JOIN [dbo].[tblPrdMstrSKULvl] PS ON PS.nodeid=C.NodeID AND PS.nodetype=C.NodeType 
END

SELECT * FROM #tblChildList ORDER BY NodeType,NodeId

SELECT COUNT(DISTINCT NodeID) SKUCount FROM #cteallchilds WHERE NodeType=40


END







