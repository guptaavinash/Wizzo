





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[spMakeTreeSHGetStartNode] 4364,5
CREATE   PROCEDURE [dbo].[spMakeTreeSHGetStartNode] 

	@LoginId INT,
	@HierType TINYINT

AS

--[spMakeTreeSHGetStartNode] '6747','1'

	DECLARE @UserID INT
	DECLARE @RoleID TINYINT
	DECLARE @NodeID INT
	DECLARE @NodeType TINYINT
	DECLARE @SecType TINYINT
	DECLARE @HierID INT
	DECLARE @tblHier VARCHAR(50)
	DECLARE @tblDesc VARCHAR(50)
	DECLARE @FrameID INT
	DECLARE @HierTypeID INT
	DECLARE @strSQL VARCHAR(MAX)

EXEC spUTLGetUserDetailsFromLoginID @LoginId, @UserID OUTPUT, @NodeID OUTPUT, @NodeType OUTPUT

EXEC spUTLGetSQLTblSource @NodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

PRINT @UserID
PRINT @RoleID
PRINT '@tblHier=' + @tblHier
SET @SecType=2

SET @NodeID=0
SET @NodeType=0

SELECT     @NodeID=ISNULL(NodeID,0), @NodeType=ISNULL(NodeType,0), @SecType=ISNULL(SecType,2)
FROM         tblSecUserRoleBasedPermissions
WHERE     (UserId = @UserID) AND (HierTypeID = @HierType)

PRINT @NodeID
PRINT @NodeType
PRINT @HierTypeID
PRINT @tblHier
CREATE TABLE #tmpHierId(HierId int)
	SET @strSQL='SELECT    HierID FROM ' + @tblHier + ' 
	WHERE     (NodeId = ' + CAST(@NodeID AS VARCHAR) + ') AND (NodeType = ' + CAST(@NodeType AS VARCHAR) + ') AND HierTypeID=' + CAST(@HierTypeID AS VARCHAR) + '
	AND (VldFrom <= GETDATE()) AND (VldTo >= GETDATE())'
	insert into #tmpHierId
	EXEC (@strSQL)
	select @HierID=Hierid from #tmpHierId

PRINT '@strSQL=' + @strSQL
SELECT @NodeID NodeID, @NodeType NodeType, ISNULL(@HierID,0) HierID, @SecType SecType
