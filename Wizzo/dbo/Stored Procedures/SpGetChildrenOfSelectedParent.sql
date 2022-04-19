

-- =============================================
-- Author:		Avinash Gupta
-- ALTER date: 08Apr2015
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpGetChildrenOfSelectedParent] 
	@NodeID int = 0, --nodeId Of immediate parent 
	@NodeType int = 0, --nodeId Of immediate parent
	@PNodeId INT=0,  -- it could be nodeid of any level of parent. All childs of @NodeType under this PNodeId should come
	@PNodeType INT=0  -- it could be nodeType of any level of parent. All childs of @NodeType under this PNodeType should come
AS
BEGIN
	DECLARE @StrWhere VARCHAR(500)=''
	DECLARE @strSQL VARCHAR(2000)=''

	IF @PNodeType=0 -- if 0 then assume ASM area
		SELECT @PNodeType=110

	CREATE TABLE #ChannelId(ChannelId INT)
	CREATE TABLE #tmpRsltWithFullHierarchy(ZoneID INT,ZoneType INT,Zone VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CompCovAreaId INT,CompCovAreaNodeType INT,CompCovArea VARCHAR(200),CompRouteId INT,CompRouteNodeType INT,CompRoute VARCHAR(200),DBRNodeId INT,DBRNodeType INT,DBR VARCHAR(200),DBRCovAreaId INT,DBRCovAreaNodeType INT,DBRCovArea VARCHAR(200),DBRRouteId INT,DBRRouteNodeType INT,DBRRoute VARCHAR(200))
	CREATE TABLE #Rslt(NodeId INT,NodeName VARCHAR(500),NodeType INT,HierId INT,PHierId INT,PNodeId INT,PNodeType INT)

	INSERT INTO #ChannelId(ChannelId)
	SELECT DISTINCT ChannelID
	FROM tblSalesHierChannelMapping 
	WHERE SalesStructureNodID=@NodeId AND SalesStructureNodType=@NodeType AND (CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate)
	--SELECT * FROM #ChannelId

	SELECT * INTO #CompHier FROM VwSalesHierarchy
	SELECT * INTO #DBRHier FROM VwAllDistributorHierarchy

	INSERT INTO #tmpRsltWithFullHierarchy(ZoneID,ZoneType,Zone,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CompCovAreaId,CompCovAreaNodeType, CompCovArea,CompRouteId,CompRouteNodeType,CompRoute)
	SELECT ZoneID,ZoneType,Zone,ASMAreaId,ASMAreaType,ASMArea,SOID,SOAreaType,SOArea,ComCoverageAreaID,ComCoverageAreaType,ComCoverageArea,RouteID,RouteType,Route
	FROM #CompHier --vw INNER JOIN tblSalesHierChannelMapping CM ON Vw.ComCoverageAreaID=CM.SalesStructureNodID AND Vw.ComCoverageAreaType=CM.SalesStructureNodType
	--WHERE RouteID IS NOT NULL --AND (@strDate BETWEEN CM.FromDate AND CM.ToDate) AND CM.ChannelID=@ChannelId

	SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.ZoneID,ZoneType,Zone,ASMAreaID,ASMAreaType,ASMArea,SOID,SOAreaType,SOArea INTO #CompSales
	FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #CompHier CS ON Map.SHNodeId=CS.ComCoverageAreaID AND Map.SHNodeType=CS.ComCoverageAreaType	
	WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
	UNION ALL
	SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.ZoneID,ZoneType,Zone,ASMAreaID,ASMAreaType,ASMArea,SOID,SOAreaType,SOArea
	FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #CompHier CS ON Map.SHNodeId=CS.SOID AND Map.SHNodeType=CS.SOAreaType	
	WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
	UNION ALL
	SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.ZoneID,ZoneType,Zone,ASMAreaID,ASMAreaType,ASMArea,0,0,'Direct'
	FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #CompHier CS ON Map.SHNodeId=CS.ASMAreaID AND Map.SHNodeType=CS.ASMAreaType		
	WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
	UNION ALL
	SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.ZoneID,ZoneType,Zone,0,0,'Direct',0,0,'Direct'
	FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #CompHier CS ON Map.SHNodeId=CS.ZoneID AND Map.SHNodeType=CS.ZoneType 
	WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)  
	
	--SELECT * FROM #CompSales

	INSERT INTO #tmpRsltWithFullHierarchy(ZoneID,ZoneType,Zone,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,DBRNodeId,DBRNodeType,DBR,DBRCovAreaId, DBRCovAreaNodeType,DBRCovArea,DBRRouteId,DBRRouteNodeType,DBRRoute)
	SELECT ISNULL(#CompSales.ZoneID,0),ISNULL(#CompSales.ZoneType,100),ISNULL(#CompSales.Zone,'NA'),ISNULL(#CompSales.ASMAreaId,0),ISNULL(#CompSales.ASMAreaType,110),ISNULL(#CompSales.ASMArea,'NA'),ISNULL(#CompSales.SOID,0),ISNULL(#CompSales.SOAreaType,120),ISNULL(#CompSales.SOArea,'NA'),vwDBR.DBRNodeID,vwDBR.DistributorNodeType,vwDBR.Distributor, vwDBR.DBRCoverageID,vwDBR.DBRCoverageNodeType,vwDBR.DBRCoverage,vwDBR.DBRRouteID,vwDBR.RouteNodeType,vwDBR.DBRRoute
	FROM #DBRHier vwDBR --INNER JOIN tblSalesHierChannelMapping CM ON vwDBR.DBRCoverageID=CM.SalesStructureNodID AND vwDBR.DBRCoverageNodeType=CM.SalesStructureNodType
	LEFT JOIN #CompSales ON vwDBR.DBRCoverageId=#CompSales.DHNodeId AND vwDBR.DBRCoverageNodeType=#CompSales.DHNodeType
	--WHERE (@strDate BETWEEN CM.FromDate AND CM.ToDate) AND CM.ChannelID=@ChannelId

	--SELECT * FROM #tmpRsltWithFullHierarchy where asmareaid=10 and CompCovAreaId<>40 and CompRouteId IS NOT NULL order by CompRouteId
	--SELECT * FROM #tmpRsltWithFullHierarchy where SOAreaId=6
	IF @PNodeId=0
	BEGIN
		IF @NodeType=100
			SELECT @PNodeId=CASE @PNodeType WHEN 100 THEN ZoneID WHEN 110 THEN ASMAreaId WHEN 120 THEN SOAreaId END  FROM #tmpRsltWithFullHierarchy WHERE ZoneID=@NodeID
		ELSE IF @NodeType=110
			SELECT @PNodeId=CASE @PNodeType WHEN 100 THEN ZoneID WHEN 110 THEN ASMAreaId WHEN 120 THEN SOAreaId END  FROM #tmpRsltWithFullHierarchy WHERE ASMAreaId=@NodeID
		ELSE IF @NodeType=120
			SELECT @PNodeId=CASE @PNodeType WHEN 100 THEN ZoneID WHEN 110 THEN ASMAreaId WHEN 120 THEN SOAreaId END  FROM #tmpRsltWithFullHierarchy WHERE SOAreaId=@NodeID
		ELSE IF @NodeType=130
			SELECT @PNodeId=CASE @PNodeType WHEN 100 THEN ZoneID WHEN 110 THEN ASMAreaId WHEN 120 THEN SOAreaId END  FROM #tmpRsltWithFullHierarchy WHERE CompCovAreaId=@NodeID
		ELSE IF @NodeType=140
			SELECT @PNodeId=CASE @PNodeType WHEN 100 THEN ZoneID WHEN 110 THEN ASMAreaId WHEN 120 THEN SOAreaId END  FROM #tmpRsltWithFullHierarchy WHERE CompRouteId=@NodeID
		ELSE IF @NodeType=150
			SELECT @PNodeId=CASE @PNodeType WHEN 100 THEN ZoneID WHEN 110 THEN ASMAreaId WHEN 120 THEN SOAreaId END  FROM #tmpRsltWithFullHierarchy WHERE DBRNodeId=@NodeID
		ELSE IF @NodeType=160
			SELECT @PNodeId=CASE @PNodeType WHEN 100 THEN ZoneID WHEN 110 THEN ASMAreaId WHEN 120 THEN SOAreaId END  FROM #tmpRsltWithFullHierarchy WHERE DBRCovAreaId=@NodeID
		ELSE IF @NodeType=170
			SELECT @PNodeId=CASE @PNodeType WHEN 100 THEN ZoneID WHEN 110 THEN ASMAreaId WHEN 120 THEN SOAreaId END  FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId=@NodeID
					
	END
	--SELECT @PNodeId
	--SELECT @PNodeType

	------CREATE TABLE #tmpRsltWithFullHierarchy(ZoneID INT,ZoneType INT,Zone VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CompCovAreaId INT,CompCovAreaNodeType INT,CompCovArea VARCHAR(200),CompRouteId INT,CompRouteNodeType INT,CompRoute VARCHAR(200),DBRNodeId INT,DBRNodeType INT,DBR VARCHAR(200),DBRCovAreaId INT,DBRCovAreaNodeType INT,DBRCovArea VARCHAR(200),DBRRouteId INT,DBRRouteNodeType INT,DBRRoute VARCHAR(200))


	IF @PNodeType=0
		SELECT @StrWhere='ZoneID'
	ELSE IF @PNodeType=100
		SELECT @StrWhere='ASMAreaId'
	ELSE IF @PNodeType=110
		SELECT @StrWhere='SOAreaId'
	ELSE IF @PNodeType=120
		SELECT @StrWhere='CompCovAreaId'
	ELSE IF @PNodeType=130
		SELECT @StrWhere='CompRouteId'
	ELSE IF @PNodeType=150
		SELECT @StrWhere='DBRCovAreaId'
	ELSE IF @PNodeType=160
		SELECT @StrWhere='DBRRouteId'

	
	IF @NodeType=100
	BEGIN
		SELECT @strSQL='SELECT DISTINCT A.ASMAreaId AS NodeId,A.Zone + ''~'' + A.ASMArea AS NodeName,A.ASMAreaNodeType AS NodeType,0 AS HierId,0 AS PhierId,A.ZoneID AS PNodeId,A.ZoneType AS PNodeType FROM #tmpRsltWithFullHierarchy A INNER JOIN tblSalesHierChannelMapping B ON A.ASMAreaId=B.SalesStructureNodID AND A.ASMAreaNodeType=B.SalesStructureNodType INNER JOIN #ChannelId C ON B.ChannelID=C.ChannelID WHERE A.ASMAreaId IS NOT NULL AND A.ZoneID<>' + CAST(@NodeID AS VARCHAR) +' AND (CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate) AND ' + @StrWhere + '=' + CAST(@PNodeId AS VARCHAR)
	END
	ELSE IF @NodeType=110
	BEGIN
		SELECT @strSQL='SELECT DISTINCT A.SOAreaId AS NodeId,A.Zone + ''~'' + A.ASMArea + ''~'' + A.SOArea AS NodeName,A.SOAreaNodeType AS NodeType,0 AS HierId,0 AS PhierId,A.ASMAreaId AS PNodeId,A.ASMAreaNodeType AS PNodeType FROM #tmpRsltWithFullHierarchy A INNER JOIN tblSalesHierChannelMapping B ON A.SOAreaId=B.SalesStructureNodID AND A.SOAreaNodeType=B.SalesStructureNodType INNER JOIN #ChannelId C ON B.ChannelID=C.ChannelID WHERE A.SOAreaId IS NOT NULL AND A.ASMAreaId<>' + CAST(@NodeID AS VARCHAR) +' AND (CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate) AND ' + @StrWhere + '=' + CAST(@PNodeId AS VARCHAR)
	END
	ELSE IF @NodeType=120
	BEGIN
		SELECT @strSQL='SELECT DISTINCT A.CompCovAreaId AS NodeId,A.Zone + ''~'' + A.ASMArea + ''~'' + A.SOArea + ''~'' + A.CompCovArea AS NodeName,A.CompCovAreaNodeType AS NodeType,0 AS HierId,0 AS PhierId,A.SOAreaId AS PNodeId,A.SOAreaNodeType AS PNodeType FROM #tmpRsltWithFullHierarchy A INNER JOIN tblSalesHierChannelMapping B ON A.CompCovAreaId=B.SalesStructureNodID AND A.CompCovAreaNodeType=B.SalesStructureNodType INNER JOIN #ChannelId C ON B.ChannelID=C.ChannelID WHERE A.CompCovAreaId IS NOT NULL AND A.SOAreaId<>' + CAST(@NodeID AS VARCHAR) +' AND (CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate) AND ' + @StrWhere + '=' + CAST(@PNodeId AS VARCHAR)
	END
	ELSE IF @NodeType=130
	BEGIN
		SELECT @strSQL='SELECT DISTINCT A.CompRouteId AS NodeId,A.Zone + ''~'' + A.ASMArea + ''~'' + A.SOArea + ''~'' + A.CompCovArea + ''~'' + A.CompRoute AS NodeName,A.CompRouteNodeType AS NodeType,0 AS HierId,0 AS PhierId,A.CompCovAreaId AS PNodeId,A.CompCovAreaNodeType AS PNodeType FROM #tmpRsltWithFullHierarchy A INNER JOIN tblSalesHierChannelMapping B ON A.CompCovAreaId=B.SalesStructureNodID AND A.CompCovAreaNodeType=B.SalesStructureNodType INNER JOIN #ChannelId C ON B.ChannelID=C.ChannelID WHERE A.CompRouteId IS NOT NULL AND A.CompCovAreaId<>' + CAST(@NodeID AS VARCHAR) +' AND (CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate) AND ' + @StrWhere + '=' + CAST(@PNodeId AS VARCHAR)		
	END
	ELSE IF @NodeType=150
	BEGIN
		SELECT @strSQL='SELECT DISTINCT A.DBRCovAreaId AS NodeId,A.DBR + ''~'' + A.DBRCovArea AS NodeName,A.DBRCovAreaNodeType AS NodeType,0 AS HierId,0 AS PhierId,A.DBRNodeId AS PNodeId,A.DBRNodeType AS PNodeType FROM #tmpRsltWithFullHierarchy A INNER JOIN tblSalesHierChannelMapping B ON A.DBRCovAreaId=B.SalesStructureNodID AND A.DBRCovAreaNodeType=B.SalesStructureNodType INNER JOIN #ChannelId C ON B.ChannelID=C.ChannelID WHERE A.DBRCovAreaId IS NOT NULL AND A.DBRNodeId<>' + CAST(@NodeID AS VARCHAR) +' AND (CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate) AND ' + @StrWhere + '=' + CAST(@PNodeId AS VARCHAR)		
	END
	ELSE IF @NodeType=160
	BEGIN
		SELECT @strSQL='SELECT DISTINCT A.DBRRouteId AS NodeId,A.DBR + ''~'' + A.DBRCovArea + ''~'' + A.DBRRoute AS NodeName,A.DBRRouteNodeType AS NodeType,0 AS HierId,0 AS PhierId,A.DBRCovAreaId AS PNodeId,A.DBRCovAreaNodeType AS PNodeType FROM #tmpRsltWithFullHierarchy A INNER JOIN tblSalesHierChannelMapping B ON A.DBRCovAreaId=B.SalesStructureNodID AND A.DBRCovAreaNodeType=B.SalesStructureNodType INNER JOIN #ChannelId C ON B.ChannelID=C.ChannelID WHERE A.DBRRouteId IS NOT NULL AND A.DBRCovAreaId<>' + CAST(@NodeID AS VARCHAR) +' AND (CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate) AND ' + @StrWhere + '=' + CAST(@PNodeId AS VARCHAR)		
	END
	PRINT @strSQL

	--SELECT * FROM #tmpRsltWithFullHierarchy order by ASMAreaId

	INSERT INTO #Rslt(NodeId,NodeName,NodeType,HierId,PHierId,PNodeId,PNodeType)
	EXEC(@strSQL)

	UPDATE A SET A.HierId=B.HierId, A.PHierId=B.PHierId
	FROM #Rslt A INNER JOIN tblCompanySalesStructureHierarchy B ON A.NodeId=B.NodeId AND A.NodeType=B.NodeType

	SELECT * FROM #Rslt ORDER BY NodeName

END







