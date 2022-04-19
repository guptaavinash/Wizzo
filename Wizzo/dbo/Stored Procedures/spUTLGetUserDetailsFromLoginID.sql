





CREATE  PROCEDURE [dbo].[spUTLGetUserDetailsFromLoginID] 

	@LoginId INT,
	@UserID INT OUTPUT,
	@NodeID INT OUTPUT,
	@NodeType INT OUTPUT

AS



SELECT    @NodeID= dbo.tblSecUser.NodeID, @NodeType=dbo.tblSecUser.NodeType, @UserID=dbo.tblSecUser.UserID
FROM         dbo.tblSecUserLogin INNER JOIN
                      dbo.tblSecUser ON dbo.tblSecUserLogin.UserID = dbo.tblSecUser.UserID
WHERE     (dbo.tblSecUserLogin.LoginID = @LoginId)

SET @NodeID=ISNULL(@NodeID,0)
SET @NodeType=ISNULL(@NodeType,0)
