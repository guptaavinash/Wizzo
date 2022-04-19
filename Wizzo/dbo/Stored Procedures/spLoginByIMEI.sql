

--spLoginByIMEI '225B1D18-CB70-47EB-8819-C428673CE937','l3altk51qlrj3m25qxohxra2','157.36.249.27','Chrome89',''

--spLoginByIMEI '7243B64B-F519-4140-AFA1-B23169442213','ss','ss','ss','ss'
CREATE  PROCEDURE [dbo].[spLoginByIMEI] 
	@IMEI varChar(50),
	@SessionIdNw varChar(100),
	@IPAddress varChar(16),
	@BrwsrVer varChar(20),
	@ScrRsltn varChar(10)

AS
BEGIN

Declare @UserName varChar(50),
	@UserPwd varChar(50),@NodeId int,@NodeType int

select distinct @NodeId=A.SalesPersonNodeId,@NodeType=A.SalesPersonNodetype from dbo.fnGetPersonList(@IMEI) A 

select @UserName=UserName,@UserPwd=Password from tblSecMapUserRoles a join tblSecUser b on a.userid=b.userid  where a.UserNodeId=@NodeId and a.UserNodeType=@NodeType
--select @UserName,@UserPwd,@NodeId,@NodeType
exec [spSecUserLoginByIMEI] @UserName,@UserPwd,@SessionIdNw,@IPAddress,@BrwsrVer,@ScrRsltn

END

