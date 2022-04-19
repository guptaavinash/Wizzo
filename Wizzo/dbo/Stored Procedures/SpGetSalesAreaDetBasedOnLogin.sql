-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpGetSalesAreaDetBasedOnLogin] --2591
	@LoginID INT
AS
BEGIN
	DECLARE @PersonNodeID INT
	DECLARE @PersonNodeType SMALLINT

	SELECT @PersonNodeID=S.NodeID,@PersonNodeType=S.NodeType  FROM tblSecUserLogin L INNER JOIN tblSecUser S ON S.UserID=L.UserID WHERE L.LoginID=@LoginID

	IF @PersonNodeType=0 -- Admin
		SELECT DISTINCT SOAreaID,SOAreaNodeType,SOArea FROM [dbo].[VwCompanyDSRFullDetail] WHERE SOID IS NOT NULL
	ELSE IF @PersonNodeType=220  --SO
		SELECT DISTINCT SOAreaID,SOAreaNodeType,SOArea FROM [dbo].[VwCompanyDSRFullDetail] WHERE SOID=@PersonNodeID AND SONodeType=@PersonNodeType
	ELSE IF @PersonNodeType=150  --Distributor
		SELECT DISTINCT SOAreaID,SOAreaNodeType,SOArea FROM [dbo].[VwDistributorDSRFullDetail] WHERE DBRNodeID=@PersonNodeID AND DistributorNodeType=@PersonNodeType
END
