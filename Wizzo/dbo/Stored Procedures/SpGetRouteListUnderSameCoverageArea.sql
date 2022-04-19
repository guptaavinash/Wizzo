-- =============================================
-- Author:		Avinash Gupta
-- Create date: 
-- Description:	
-- =============================================
-- SpGetRouteListUnderSameCoverageArea 48,140
CREATE PROCEDURE [dbo].[SpGetRouteListUnderSameCoverageArea] 
	@RouteNodeID INT,
	@RouteNodetype SMALLINT
AS
BEGIN
	DECLARE @HierTypeID INT
	SELECT @HierTypeID=HierTypeID FROM [dbo].[tblSecMenuContextMenu] WHERE NodeType=@RouteNodetype
	DECLARE @CoverageAreaID INT
	IF @HierTypeID=2
	BEGIN
		SELECT @CoverageAreaID=[DSRAreaID] FROM [dbo].[VwCompanyDSRFullDetail] WHERE [DSRRouteNodeID]=@RouteNodeID AND [DSRRouteNodeType]=@RouteNodetype
	END
	ELSE IF @HierTypeID=5
	BEGIN
		SELECT @CoverageAreaID=DBRCoverageID FROM [dbo].[VwDistributorDSRFullDetail] WHERE DBRRouteID=@RouteNodeID AND RouteNodeType=@RouteNodetype
	END


	SELECT DISTINCT [DSRRouteNodeID],[DSRRouteNodeType],[DSRRoute] FROM [dbo].[VwCompanyDSRFullDetail] WHERE [DSRAreaID]=@CoverageAreaID
	UNION
	SELECT DISTINCT DBRRouteID,RouteNodeType,DBRRoute FROM [dbo].[VwDistributorDSRFullDetail] WHERE DBRCoverageID=@CoverageAreaID
	
END
