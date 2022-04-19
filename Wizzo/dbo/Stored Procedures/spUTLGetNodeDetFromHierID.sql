





CREATE     PROCEDURE [dbo].[spUTLGetNodeDetFromHierID] 
/********************************************************************************

***********************************************************************************/
 	@HierId INT, 
	@NodeID INT OUTPUT,
	@NodeType INT OUTPUT
AS
	DECLARE @SQLstr varChar(1000)
	DECLARE @tblHier varChar(70)
	DECLARE @tblDesc varChar(70)
	DECLARE @FrameID TINYINT
	DECLARE @HierarchyID TINYINT
	EXEC spUTLGetSQLTblSource @NodeType,@tblHier OUTPUT , @tblDesc OUTPUT,  @FrameID OUTPUT, @HierarchyID OUTPUT
	CREATE TABLE #tmpOutput (NodeID INT, NodeType INT) 
SET @SQLstr = 'INSERT INTO #tmpOutput (NodeID, NodeType)  SELECT  NodeId, NodeType FROM ' + @tblHier + ' WHERE HierID = ' + Cast(@HierId as varChar(9))
PRINT @SQLstr
EXEC (@SQLstr)
SELECT @NodeID=NodeID, @NodeType=NodeType FROM #tmpOutput







