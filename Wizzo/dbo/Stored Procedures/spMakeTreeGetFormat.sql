






CREATE PROCEDURE [dbo].[spMakeTreeGetFormat] 

	@NodeType smallint,
	@SSClass varchar(100) output,
	@ImageName varchar(100) output


AS
	SELECT     @SSClass=SSClass, @ImageName=ImageName FROM  tblBMstSsImg WHERE     (NodeType = @NodeType)
