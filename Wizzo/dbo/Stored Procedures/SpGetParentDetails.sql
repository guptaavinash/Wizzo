-- =============================================
-- Author:		Avinash Gupta
-- Create date: 11-Sep-2015
-- Description:	Sp to get the parent details 
-- =============================================

-- SpGetParentDetails 1,6
CREATE PROCEDURE [dbo].[SpGetParentDetails] -- 3,10
	@NodeID int = 0, 
	@NodeType int = 0
AS
BEGIN
	
	DECLARE @tblHier VARCHAR(50)
	DECLARE @tblDesc VARCHAR(50)
	DECLARE @FrameID INT
	DECLARE @HierTypeID INT
	DECLARE @strSQL VARCHAR(4000)
	DECLARE @ParentNodeID INT
	DECLARE @ParentNodeType INT

	SELECT @ParentNodeID=PNodeID ,@ParentNodeType=PNodeType FROM tblCompanySalesStructureHierarchy WHERE NodeID=@NodeID AND NodeType=@NodeType
		
	EXEC spUTLGetSQLTblSource @ParentNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

	PRINT '@tblDesc' + CAST(ISNULL(@tblDesc,'OK') AS VARCHAR)

	IF ISNULL(@tblDesc,0)='0'
		SELECT 0 AS NodeID,'' AS Descr
	ELSE 
	BEGIN
		SET @strSQL='Select B.NodeID, B.Descr FROM '	+ @tblDesc + ' B Where B.NodeID = ' + CAST(@ParentNodeID AS VARCHAR) + ' AND B.NodeType = ' + CAST(@ParentNodeType AS VARCHAR) 
		PRINT @strSQL
		EXEC (@strSQL)
	END
END

