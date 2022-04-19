





CREATE     PROCEDURE [dbo].[spMakeTreeGetUserSec] 
@LoginId INT,
@NodeId INT,
@NodeType INT,
@CrrntSec TINYINT, --This tells us the security the user has for the parent node. If type1, then this propgates down unless redefined here.
@SecFlag TINYINT OUTPUT  --1=Full control. 2=viewing only, 3=no display
-- WITH ENCRYPTION
AS
	DECLARE @UserNodeId INT
	DECLARE @UserNodeType INT
	DECLARE @UserID INT
	DECLARE @RoleID TINYINT
	DECLARE @FNAMe varChar(300)
	DECLARE @LNAMe varChar(300)

	EXEC spUTLGetUserDetailsFromLoginID @LoginId, @UserID OUTPUT, @UserNodeId OUTPUT, @UserNodeType OUTPUT
SET @SecFlag=99
PRINT @UserId
PRINT @NodeId
PRINT @NodeType
PRINT @UserNodeId
PRINT @UserNodeType
SELECT     @SecFlag=SecType FROM tblSecUserRoleBasedPermissions WHERE     (UserId = @UserId)   AND (NodeID = @NodeId) AND (NodeType = @NodeType)
IF @SecFlag=99
	BEGIN
		SET @SecFlag=@CrrntSec
	END
