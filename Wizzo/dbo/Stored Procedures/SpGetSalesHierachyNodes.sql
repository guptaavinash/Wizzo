



-- =============================================
-- Author:		Avinash Gupta
-- Create date: 27-Apr-2015
-- Description:	Sp to get the Child Details list for route mapping
-- =============================================
-- [SpGetSalesHierachyNodes] 0,0,0,0,0,5
 CREATE PROCEDURE [dbo].[SpGetSalesHierachyNodes] 
	@NodeID int = 0, 
	@NodeType int = 0,
	@flg INT=1, -- 0-All,1-Immediate
	@CurrentNodeID INT =0,
	@CurrentNodeType INT =0,
	@SalesHierTypeId INT=0
	
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
	FROM tblCompanySalesStructureHierarchy  
	WHERE (NodeID= @NodeID AND NodeType=@NodeType)  AND NodeType in(select NodeType from tblPMstNodeTypes where HierTypeId=@SalesHierTypeId)
	UNION ALL 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM tblCompanySalesStructureHierarchy  
	WHERE PNodeID= @NodeID AND PNodeType=@NodeType AND @NodeID=0 AND @NodeType=0   AND NodeType in(select NodeType from tblPMstNodeTypes where HierTypeId=@SalesHierTypeId)
	UNION ALL 
	--recursive execution 
	SELECT C.NodeID, C.NodeType, C.HierID ,C.PNodeID,C.PNodeType,C.PHierID,O.LstLevel + 1
	FROM tblCompanySalesStructureHierarchy C INNER JOIN CTEAllChilds O
	ON C.PHierID = O.HierID 
	) 

SELECT * INTO #cteallchilds FROM CTEAllChilds
--SELECT * FROM #cteallchilds
--SELECT DISTINCT NodeType FROM #cteallchilds WHERE PNodeType=@NodeType

IF @flg=1
BEGIN
	SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@NodeType

	EXEC spUTLGetSQLTblSource @ChildNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

	SET @strSQL='INSERT INTO #tblChildList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType) '
	SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,C.LstLevel,C.PNodeID,C.PNodeType FROM ' + @tblDesc + ' T INNER JOIN #cteallchilds C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE PNodeType=' + CAST(@NodeType AS VARCHAR)
	PRINT @strSQL
	EXEC (@strSQL)
END
ELSE
BEGIN
	--SELECT DISTINCT HierID,NodeType FROM #cteallchilds WHERE PNodeType=@NodeType
	CREATE TABLE #tmpType(HierID INT,NodeType INT)
	IF @NodeType=0
	BEGIN
		INSERT INTo #tmpType(HierID,NodeType)
		SELECT DISTINCT HierID,NodeType FROM #cteallchilds WHERE PNodeType= @NodeType
	END
	ELSE
	BEGIN
		INSERT INTo #tmpType(HierID,NodeType)
		SELECT DISTINCT HierID,NodeType FROM #cteallchilds WHERE NodeType= @NodeType
	END
	
	DECLARE Cur_Sales CURSOR FOR
	SELECT HierID,NodeType FROM #tmpType
	OPEN Cur_Sales
	FETCH NEXT FROM Cur_Sales INTO @PHierID,@ChildNodeType
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT '@ChildNodeType=' + CAST(@ChildNodeType AS VARCHAR)
		WHILE (ISNULL(@ChildNodeType,0)>0)
		BEGIN
			PRINT '@ChildNodeType=' + CAST(@ChildNodeType AS VARCHAR)
			EXEC spUTLGetSQLTblSource @ChildNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

			SET @strSQL='INSERT INTO #tblChildList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType) '
			SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,C.LstLevel,C.PNodeID,C.PNodeType FROM ' + @tblDesc + ' T INNER JOIN #cteallchilds C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE T.NodeType=' + CAST(@ChildNodeType AS VARCHAR)
			PRINT @strSQL
			EXEC (@strSQL)

			IF @ChildNodeType=140
			BEGIN
				IF EXISTS(SELECT 1 FROM #cteallchilds WHERE PNodeType=@ChildNodeType AND PHierID=@PHierID)
					SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@ChildNodeType AND PHierID=@PHierID
				ELSE 
					SELECT @ChildNodeType=0
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT 1 FROM #cteallchilds WHERE PNodeType=@ChildNodeType)
					SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@ChildNodeType
				ELSE 
					SELECT @ChildNodeType=0
			END
			
		END
		FETCH NEXT FROM Cur_Sales INTO @PHierID,@ChildNodeType
		
	END
	CLOSE Cur_Sales
	DEALLOCATE Cur_Sales
END
--SELECT * FROM #tblChildList
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

DELETE FROM #tblChildList WHERE NodeType=140 AND NodeID NOT IN (SELECT DISTINCT PNodeID FROM #tblChildList WHERE NodeType=150)

UPDATE #tblChildList SET PPNodeID=ISNULL(CL.PNodeID,0),PPNodeType=ISNULL(CL.PNodeType,0) FROM #tblChildList C INNER JOIN #cteallchilds CL ON CL.NodeID=C.PNodeID AND CL.NodeType=C.PNodeType
UPDATE #tblChildList SET PPNodeID=ISNULL(PPNodeID,0),PPNodeType=ISNULL(PPNodeType,0) FROM #tblChildList

UPDATE #tblChildList SET Seq=0 WHERE NodeID=@CurrentNodeID AND NodeType=@CurrentNodeType

--SELECT * FROM #tblChildList ORDER BY NodeType,NodeID --Seq

	UPDATE A SET A.Descr= A.Descr + '(' + ISNULL(AA.PersonName,'Vacant') + ')' FROM #tblChildList A LEFT JOIN
	(SELECT SP.NodeID,SP.NodeType,P.Descr AS PersonName  FROM tblSalesPersonMapping SP INNER JOIN tblMstrPerson P ON SP.PersonNodeID=p.NodeID AND SP.PersonType=P.NodeType WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(Sp.ToDate,GETDATE())) AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))) AA
	ON A.NodeID=AA.NodeID AND A.NodeType=AA.NodeType
	WHERE A.NodeType<>150


UPDATE #tblChildList SET PHierID=NULL,PNodeID=0,PNodeType=0 WHERE LstLevel=1

select HierID ,Descr,PHierID,NodeID,NodeType,LstLevel,PNodeID,PNodeType,PPHierID,PPNodeID,PPNodeType,Seq 
FROM #tblChildList
ORDER BY NodeType,Descr


END









