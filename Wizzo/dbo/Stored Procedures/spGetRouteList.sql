
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[spGetRouteList]'1^100|2^100|'
CREATE PROCEDURE [dbo].[spGetRouteList] 
	@strSalesHierarchy VARCHAR(500)
AS
BEGIN
	 DECLARE @TempStr NVARCHAR(MAX) ,@NodeId INT, @NodeType INT
	 CREATE TABLE #Routes(DBRRouteID INT,DBRRoute VARCHAR(500),RouteNodeType INT)
	 
	WHILE (PATINDEX('%|%',@strSalesHierarchy)>0)  
	Begin  
		Select @TempStr = SUBSTRING(@strSalesHierarchy,0, PATINDEX('%|%',@strSalesHierarchy))  
		Select @strSalesHierarchy = SUBSTRING(@strSalesHierarchy,PATINDEX('%|%',@strSalesHierarchy)+1, LEN(@strSalesHierarchy))  

		SELECT @NodeId= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))
		--SELECT @TempStr = SUBSTRING(@TempStr, PATINDEX('%^%',@TempStr) + 1 , LEN(@TempStr))
		--SELECT @NodeType= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))  
		SELECT @NodeType = SUBSTRING(@TempStr, PATINDEX('%^%',@TempStr) + 1 , LEN(@TempStr))
		
		INSERT INTO #Routes(DBRRouteID ,RouteNodeType,DBRRoute)
		SELECT RouteNodeId,RouteNodetype,Routename FROM dbo.fnGetRouteListWithname(@NodeId,@NodeType,GETDATE())
		--EXEC spGetRouteListOnLevel @NodeId, @NodeType
		
		--SELECT @NodeId,@NodeType 
	End 

	SELECT DBRRouteID,RouteNodeType,DM.DHNodeID DBRNodeID,DM.DHNodetype DistributorNodeType INTO #Routesmapping  FROM #Routes R INNER JOIN [tblCompanySalesStructure_DistributorMapping] DM ON DM.SHNodeId=R.DBRRouteID AND DM.SHNodeType=R.RouteNodeType
	UNION
	SELECT R.DBRRouteID,R.RouteNodeType,V.DBRNodeID,V.DistributorNodeType FROM #Routes R INNER JOIN VwAllDistributorHierarchy V ON V.DBRRouteID=R.DBRRouteID AND V.RouteNodeType=R.RouteNodeType

	
	--UPDATE R SET  DBRNodeId=DM.DHNodeID,DBRNodetype=DM.DHNodetype FROM #Routes R INNER JOIN [tblCompanySalesStructure_DistributorMapping] DM ON DM.SHNodeId=R.DBRRouteID AND DM.SHNodeType=R.RouteNodeType

	--UPDATE R SET  DBRNodeId=V.DBRNodeID,DBRNodetype=V.DistributorNodeType FROM #Routes R INNER JOIN VwAllDistributorHierarchy V ON V.DBRRouteID=R.DBRRouteID AND V.RouteNodeType=R.RouteNodeType

	SELECT DISTINCT DBRRouteID,DBRRoute,RouteNodeType FROM #Routes ORDER BY DBRRoute
	SELECT * FROM #Routesmapping
	SELECT DISTINCT R.DBRNodeId,R.DistributorNodeType,D.Descr Distributor FROM #Routesmapping R INNER JOIN tblDBRSalesStructureDBR D ON D.NodeID=R.DBRNodeId AND D.NodeType=R.DistributorNodeType
END

