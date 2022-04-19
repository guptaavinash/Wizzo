





CREATE   PROCEDURE [dbo].[spMakeTreeLastLevelStatus] 
	@HierID INT,
	@NodeType INT,
	@HierStyle TINYINT, --1=full tree at one go, 2=tree through webservices
	@LstLvelReqd INT,
	@LstLvl TINYINT OUTPUT
AS
SET NOCOUNT ON
	DECLARE @SQLStr VarChar(2000)
	DECLARE @tblHierarchy varChar(80)
	DECLARE @tblDesc varChar(60)
	DECLARE @SQLCursor Cursor
	DECLARE @NodeID INT
	DECLARE @FrameID TINYINT
	DECLARE @HierarchyID INT

EXEC spUTLGetNodeDetFromHierID @HierID, @NodeId OUTPUT, @NodeType OUTPUT
EXEC spUTLGetSQLTblSource @NodeType, @tblHierarchy OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierarchyID OUTPUT

CREATE TABLE #tmpTbl ([NodeID][INT])

IF @HierStyle=1
	BEGIN
		INSERT  INTO #tmpTbl (NodeID) SELECT  #tmpHierTable.NodeID FROM #tmpHierTable  WHERE ( #tmpHierTable.PHierID =@HierID)
	END
ELSE IF @HierStyle=2
	BEGIN
		SET @SQLStr='INSERT  INTO #tmpTbl (NodeID) SELECT  '+ @tblHierarchy + '.NodeID FROM ' +  @tblHierarchy + '  WHERE  (' +  @tblHierarchy + '.PHierID = ' + CAST(@HierID AS VarChar(8)) + ')'			
	END
PRINT @SQLSTR
EXEC (@SQLStr)
IF EXISTS (SELECT * FROM #tmpTbl)
	SET @LstLvl=10
ELSE
	SET @LstLvl=20
