

-- =============================================
-- Author:		Avinash Gupta
-- Create date: 28 April 2016
-- Description:	
-- =============================================
--[SpGetNodebasedOnLevels]5
CREATE PROCEDURE [dbo].[SpGetNodebasedOnLevels] --5
	@NodeType TINYINT
AS
BEGIN
	DECLARE @tblHier VARCHAR(50)
	DECLARE @tblDesc VARCHAR(50)
	DECLARE @FrameID INT
	DECLARE @HierTypeID INT
	DECLARE @strSQL VARCHAR(4000)
	
	
	EXEC spUTLGetSQLTblSource @NodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT
	
	CREATE TABLE #tblNodeList (HierID INT ,Descr VARCHAR(200),PHierID INT,NodeID INT,NodeType INT,LstLevel INT,PNodeID INT,PNodeType INT,PPHierID INT,PPNodeID INT,PPNodeType INT,Seq INT DEFAULT 1)

SET @strSQL='INSERT INTO #tblNodeList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType) '
	SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,0,C.PNodeID,C.PNodeType FROM ' + @tblDesc + ' T INNER JOIN tblCompanySalesStructureHierarchy C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE T.NodeType=' + CAST(@NodeType AS VARCHAR)
	PRINT @strSQL
	EXEC (@strSQL)
	
	DECLARE @SalesLevelName VARCHAR(200)
	SELECT @SalesLevelName=NodeTypeDesc FROM tblPMstNodeTypes where NodeType=@NodeType
	SELECT *,@SalesLevelName AS LevelGroupName FROM 	#tblNodeList
	
END

