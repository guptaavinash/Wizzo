-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetWorkingTypeForCoverageArea] 
(
	@SalesNodeID INT,
	@SalesNodeType SMALLINT
)
RETURNS TINYINT 
AS
BEGIN
	DECLARE @WorkingType TINYINT=0
	SELECT @WorkingType=WorkingTypeId FROM tblCompanySalesStructureCoverage WHERE NodeID=@SalesNodeID AND NodeType=@SalesNodeType
	SELECT @WorkingType=WorkingTypeId FROM tblDBRSalesStructureCoverage WHERE NodeID=@SalesNodeID AND NodeType=@SalesNodeType
	RETURN @WorkingType
END
