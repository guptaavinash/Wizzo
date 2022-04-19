﻿-- =============================================
-- Author:		Avinash Gupta
-- Create date: 09-Sep-2015
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpGetChildSalesChannelDetails] --1,7,0
	@NodeID int = 0,
	@NodeType INT=0,
	@flg INT
AS
BEGIN
	DECLARE @tblHier VARCHAR(50)
	DECLARE @tblDesc VARCHAR(50)
	DECLARE @FrameID INT
	DECLARE @HierTypeID INT
	DECLARE @strSQL VARCHAR(4000)

	DECLARE @ChildNodeType INT
	DECLARE @PHierID INT
	CREATE TABLE #tblChildList (HierID INT ,Descr VARCHAR(200),PHierID INT,NodeID INT,NodeType INT,LstLevel INT,PNodeID INT,PNodeType INT,PPHierID INT,PPNodeID INT,PPNodeType INT
	,Seq INT DEFAULT 1)

	;WITH CTEAllChilds AS 
		( 
		--initialization 
		SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
		FROM tblCompanySalesStructureHierarchy  
		WHERE (NodeID= @NodeID AND NodeType=@NodeType) 
		UNION ALL 
		SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
		FROM tblCompanySalesStructureHierarchy  
		WHERE PNodeID= @NodeID AND PNodeType=@NodeType AND @NodeID=0 AND @NodeType=0
		UNION ALL 
		--recursive execution 
		SELECT C.NodeID, C.NodeType, C.HierID ,C.PNodeID,C.PNodeType,C.PHierID,O.LstLevel + 1
		FROM tblCompanySalesStructureHierarchy C INNER JOIN CTEAllChilds O
		ON C.PHierID = O.HierID 
		) 

	SELECT * INTO #cteallchilds FROM CTEAllChilds

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
	DECLARE Cur_Sales CURSOR FOR
	SELECT DISTINCT HierID,NodeType FROM #cteallchilds WHERE PNodeType=@NodeType
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

			IF @ChildNodeType=170
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

--DELETE FROM #tblChildList WHERE NodeType=8 AND NodeID NOT IN (SELECT DISTINCT PNodeID FROM #tblChildList WHERE NodeType=9)

UPDATE #tblChildList SET PPNodeID=ISNULL(CL.PNodeID,0),PPNodeType=ISNULL(CL.PNodeType,0) FROM #tblChildList C INNER JOIN #cteallchilds CL ON CL.NodeID=C.PNodeID AND CL.NodeType=C.PNodeType
UPDATE #tblChildList SET PPNodeID=ISNULL(PPNodeID,0),PPNodeType=ISNULL(PPNodeType,0) FROM #tblChildList

--UPDATE #tblChildList SET Seq=0 WHERE NodeID=@CurrentNodeID AND NodeType=@CurrentNodeType

--- Code For identifying the channel for subordinates##################################################
--SELECT * FROM #tblChildList
CREATE TABLE #tblChildChannelMappingList (HierID INT ,Descr VARCHAR(200),PHierID INT,NodeID INT,NodeType INT,LstLevel INT,PNodeID INT,PNodeType INT,PPHierID INT,PPNodeID INT,PPNodeType INT
,Seq INT DEFAULT 1,ChannelID INT,flgChannelMapped TINYINT DEFAULT 0)

SET @strSQL='INSERT INTO #tblChildChannelMappingList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType,ChannelID)'
SET @strSQL=@strSQL + 'SELECT C.NodeID,C.Descr,C.NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType,CM.OutChannelID FROM #tblChildList C CROSS JOIN tblOutletChannelMaster CM '
PRINT @strSQL
EXEC (@strSQL)

SET @strSQL='UPDATE C SET flgChannelMapped=1 FROM #tblChildChannelMappingList C INNER JOIN tblSalesHierChannelMapping SM ON SM.SalesStructureNodID=C.NodeID 
AND SM.SalesStructureNodType=C.NodeType AND SM.ChannelID=C.ChannelID'
PRINT @strSQL
EXEC (@strSQL)

-- #######################################################################################################


SELECT * FROM #tblChildChannelMappingList ORDER BY Nodetype

END

