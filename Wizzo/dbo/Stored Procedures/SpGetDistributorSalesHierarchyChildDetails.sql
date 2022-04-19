

-- =============================================
-- Author:		Avinash Gupta
-- Create date: 27-Apr-2015
-- Description:	Sp to get the Child Details list for route mapping
-- =============================================
-- SpGetDistributorSalesHierarchyChildDetails 0,0,0,0
CREATE PROCEDURE [dbo].[SpGetDistributorSalesHierarchyChildDetails] 
	@NodeID int = 0, 
	@NodeType int = 0,
	@flg INT=1, -- 0-All,1-Immediate
	@CurrentNodeID INT =0
	
AS
BEGIN

DECLARE @tblHier VARCHAR(50)
DECLARE @tblDesc VARCHAR(50)
DECLARE @FrameID INT
DECLARE @HierTypeID INT
DECLARE @strSQL VARCHAR(4000)

DECLARE @ChildNodeType INT
DECLARE @PHierID INT	

CREATE TABLE #tblChildList (HierID INT ,Descr VARCHAR(200),PHierID INT,NodeID INT,NodeType INT,LstLevel INT,PNodeID INT,PNodeType INT,PPHierID INT,PPNodeID INT,PPNodeType INT,Seq INT DEFAULT 1)

;WITH CTEAllChilds AS 
	( 
	--initialization 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM tblCompanySalesStructureHierarchy -- INNER JOIN [db_RSPL].[dbo].[tblDBR_LiveMarking] ON tblCompanySalesStructureHierarchy.HIERID = [db_RSPL].[dbo].[tblDBR_LiveMarking].DBRHIERID
	WHERE (NodeID= @NodeID AND NodeType=@NodeType AND HierTypeID=5) 
	UNION ALL 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM tblCompanySalesStructureHierarchy  INNER JOIN [db_RSPL].[dbo].[tblDBR_LiveMarking] ON tblCompanySalesStructureHierarchy.HIERID = [db_RSPL].[dbo].[tblDBR_LiveMarking].DBRHIERID
	WHERE PNodeID= @NodeID AND PNodeType=@NodeType AND @NodeID=0 AND @NodeType=0 AND HierTypeID=5
	UNION ALL 
	--recursive execution 
	SELECT C.NodeID, C.NodeType, C.HierID ,C.PNodeID,C.PNodeType,C.PHierID,O.LstLevel + 1
	FROM tblCompanySalesStructureHierarchy C INNER JOIN CTEAllChilds O
	ON C.PHierID = O.HierID 
	) 

SELECT * INTO #cteallchilds FROM CTEAllChilds

PRINT 'Step A'
Print GetDate()
--SELECT * FROM #cteallchilds --WHERE PNodeType=@NodeType
DECLARE @HierTable VARCHAR(200)
DECLARE @WorkingNodeType INT

IF @flg=1
BEGIN
	SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@NodeType

	EXEC spUTLGetSQLTblSource @ChildNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

	SET @strSQL='INSERT INTO #tblChildList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType) '
	SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,C.LstLevel,C.PNodeID,C.PNodeType FROM ' + @tblDesc + ' T INNER JOIN #cteallchilds C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE PNodeType=' + CAST(@NodeType AS VARCHAR)
	PRINT @strSQL
	EXEC (@strSQL)
		PRINT 'Step B1'
		Print GetDate()
END
ELSE
BEGIN
	SELECT NodeType,DetTable,Hierarchytable INTO #SalesNodeType FROM tblPMstNodeTypes P WHERE HierTypeID IN (2,5)

	DECLARE Cur_Sales CURSOR FOR
	SELECT DISTINCT NodeType,DetTable,Hierarchytable FROM #SalesNodeType
	OPEN Cur_Sales
	FETCH NEXT FROM Cur_Sales INTO @WorkingNodeType,@tblDesc,@HierTable
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @strSQL='INSERT INTO #tblChildList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType) '
		IF @NodeType=150 OR @NOdeType=160 Or @NodeType=170
			BEGIN
				SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,C.LstLevel,C.PNodeID,C.PNodeType FROM ' + @tblDesc + ' T INNER JOIN [db_RSPL].[dbo].[tblDBR_LiveMarking] ON T.HIERID = [db_RSPL].[dbo].[tblDBR_LiveMarking].DBRHIERID 	INNER JOIN #cteallchilds C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE T.NodeType=' + CAST(@WorkingNodeType AS VARCHAR)
			END
		ELSE
			BEGIN
				SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,C.LstLevel,C.PNodeID,C.PNodeType FROM ' + @tblDesc + ' T 	INNER JOIN #cteallchilds C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE T.NodeType=' + CAST(@WorkingNodeType AS VARCHAR)
			END
		PRINT @strSQL
		EXEC (@strSQL)

		FETCH NEXT FROM Cur_Sales INTO @WorkingNodeType,@tblDesc,@HierTable
	END
	CLOSE Cur_Sales
	DEALLOCATE Cur_Sales
		PRINT 'Step B2'
		Print GetDate()
	----DECLARE Cur_Sales CURSOR FOR
	----SELECT DISTINCT HierID,NodeType FROM #cteallchilds WHERE PNodeType=@NodeType
	----OPEN Cur_Sales
	----FETCH NEXT FROM Cur_Sales INTO @PHierID,@ChildNodeType
	----WHILE @@FETCH_STATUS = 0
	----BEGIN
	----	PRINT '@ChildNodeType=' + CAST(@ChildNodeType AS VARCHAR)
	----	WHILE (ISNULL(@ChildNodeType,0)>0)
	----	BEGIN
	----		PRINT '@ChildNodeType=' + CAST(@ChildNodeType AS VARCHAR)
	----		EXEC spUTLGetSQLTblSource @ChildNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

	----		SET @strSQL='INSERT INTO #tblChildList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType) '
	----		SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,C.LstLevel,C.PNodeID,C.PNodeType FROM ' + @tblDesc + ' T INNER JOIN #cteallchilds C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE T.NodeType=' + CAST(@ChildNodeType AS VARCHAR)
	----		PRINT @strSQL
	----		EXEC (@strSQL)

	----		IF @ChildNodeType=170
	----		BEGIN
	----			IF EXISTS(SELECT 1 FROM #cteallchilds WHERE PNodeType=@ChildNodeType AND PHierID=@PHierID)
	----				SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@ChildNodeType AND PHierID=@PHierID
	----			ELSE 
	----				SELECT @ChildNodeType=0
	----		END
	----		ELSE
	----		BEGIN
	----			IF EXISTS(SELECT 1 FROM #cteallchilds WHERE PNodeType=@ChildNodeType)
	----				SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@ChildNodeType
	----			ELSE 
	----				SELECT @ChildNodeType=0
	----		END
			
	----	END
	----	FETCH NEXT FROM Cur_Sales INTO @PHierID,@ChildNodeType
		
	----END
	----CLOSE Cur_Sales
	----DEALLOCATE Cur_Sales
END

UPDATE #tblChildList SET PHierID=NULL WHERE PHierID =0

;WITH TempEmp (HierID,duplicateRecCount)
AS
(
SELECT HierID,ROW_NUMBER() OVER(PARTITION by HierID, Descr ORDER BY HierID) 
AS duplicateRecCount
FROM #tblChildList
)
--Now Delete Duplicate Records
DELETE FROM TempEmp
WHERE duplicateRecCount > 1  

		PRINT 'Step C'
		Print GetDate()
--DELETE FROM #tblChildList WHERE NodeType=8 AND NodeID NOT IN (SELECT DISTINCT PNodeID FROM #tblChildList WHERE NodeType=9)

UPDATE #tblChildList SET PPNodeID=ISNULL(CL.PNodeID,0),PPNodeType=ISNULL(CL.PNodeType,0) FROM #tblChildList C INNER JOIN #cteallchilds CL ON CL.NodeID=C.PNodeID AND CL.NodeType=C.PNodeType
UPDATE #tblChildList SET PPNodeID=ISNULL(PPNodeID,0),PPNodeType=ISNULL(PPNodeType,0) FROM #tblChildList

		PRINT 'Step D'
		Print GetDate()
--UPDATE #tblChildList SET Seq=0 WHERE NodeID=@CurrentNodeID AND NodeType=@CurrentNodeType

Update a set Descr=b.Descr  from #tblChildList a join tblDBRSalesStructureDBR b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType
SELECT * FROM #tblChildList ORDER BY lstLevel, Seq


END








