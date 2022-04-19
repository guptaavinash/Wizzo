Create PROCEDURE [dbo].[spForPDAIsSchemeApplicable]  --'09-03-2013'
	@Date varchar(50),
	@RouteID INT,
	 @RouteNodeType INT
AS
BEGIN
	
	IF EXISTS(SELECT 1 AS IsSchemeApplicable FROM dbo.tblSchemeMaster
				--INNER JOIN tblSchemeRouteMap ON tblSchemeRouteMap.SchemeID = tblMstrSchemeMaster.SchemeID
				--WHERE ISNULL(flgActive,1) = 1 AND NodeID = @RouteID
				)
	BEGIN
		SELECT 1  AS IsSchemeApplicable                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
	END
	ELSE
	BEGIN
		SELECT 0 AS IsSchemeApplicable
	END
	
END
