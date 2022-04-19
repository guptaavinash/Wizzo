
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [spGetCombinedHierarchy] 35
CREATE PROCEDURE [dbo].[spGetCombinedHierarchy]
@LoginId INT=0
AS
BEGIN
	DECLARE @LoginPersonId INT=0
	DECLARE @LoginPersonType INT=0
	DECLARE @SalesAreaNodeType INT=0

	SELECT @LoginPersonId=A.NodeId,@LoginPersonType=A.NodeType
	FROM tblsecUser A INNER JOIN  tblSecUserLogin B ON A.UserId=B.UserId
	WHERE B.LoginId=@LoginId
	PRINT 'LoginPersonId-' + CAST(@LoginPersonId AS VARCHAR)
	PRINT 'LoginPersonType-' + CAST(@LoginPersonType AS VARCHAR)

	SELECT @SalesAreaNodeType=ISNULL(MIN(SP.NodeType),0)
	FROM tblSalesPersonMapping SP
	WHERE SP.PersonNodeID=@LoginPersonId AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)
	PRINT 'SalesAreaNodeType-' + CAST(@SalesAreaNodeType AS VARCHAR)
	--SELECT @SalesAreaNodeType
	CREATE TABLE #SalesAreas(SalesAreaNodeId INT,SalesAreaNodeType INT)

	INSERT INTO #SalesAreas(SalesAreaNodeId,SalesAreaNodeType)
	SELECT SP.NodeID,SP.NodeType
	FROM tblSalesPersonMapping SP
	WHERE SP.PersonNodeID=@LoginPersonId AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate) AND SP.NodeType=@SalesAreaNodeType

	--SELECT * FROM #SalesAreas

	CREATE TABLE #tmpRslt(NodeId INT,NodeType INT,PNodeId INT,PNodeType INT,PPNodeId INT,PPNodeType INT,[Sales Area] VARCHAR(200),Lvl TINYINT)
	
	CREATE TABLE #tmpRsltWithFullHierarchy(RegionID INT,RegionType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CompCovAreaId INT,CompCovAreaNodeType INT,CompCovArea VARCHAR(200),CompRouteId INT,CompRouteNodeType INT,CompRoute VARCHAR(200),DBRNodeId INT,DBRNodeType INT,DBR VARCHAR(200),DBRCovAreaId INT,DBRCovAreaNodeType INT,DBRCovArea VARCHAR(200),DBRRouteId INT,DBRRouteNodeType INT,DBRRoute VARCHAR(200))
	
	SELECT * INTO #tblVwSalesHierarchy FROM VwCompanyDSRFullDetail

	INSERT INTO #tmpRsltWithFullHierarchy(RegionID,RegionType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea, CompCovAreaId,CompCovAreaNodeType, CompCovArea,CompRouteId,CompRouteNodeType,CompRoute)
	SELECT DISTINCT RSMAreaID,RSMAreaType,RSMArea,ASMAreaID,ASMAreaNodeType,ASMArea,SOAreaID,SOAreaNodeType,SOArea,DSRAreaID,DSRAreaNodeType,DSRArea,R.NodeID RouteID,R.NodeType RouteType,R.Descr Route
	FROM #tblVwSalesHierarchy T INNER JOIN tblCompanySalesStructureHierarchy H ON H.PNodeID=T.DSRAreaID AND H.PNodeType=T.DSRAreaNodeType INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=H.NodeID AND R.NodeType=H.NodeType
	WHERE R.NodeID IS NOT NULL
	--SELECT * FROM #tmpRsltWithFullHierarchy


	SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RSMAreaID,CS.RSMAreaType,RSMArea,CS.ASMAreaID ASMAreaID,CS.ASMAreaNodeType ASMAreaType,ASMArea,CS.SOAreaID SOID,CS.SOAreaNodeType SOAreaType,SOArea INTO #CompSales
	FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #tblVwSalesHierarchy CS ON Map.SHNodeId=CS.ASMAreaID AND Map.SHNodeType=CS.SOAreaNodeType	
	WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
	UNION ALL
	SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RSMAreaID,CS.RSMAreaType,RSMArea,CS.ASMAreaID ASMAreaID,CS.ASMAreaNodeType ASMAreaType,ASMArea,0,0,'Direct'
	FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #tblVwSalesHierarchy CS ON Map.SHNodeId=CS.ASMAreaID AND Map.SHNodeType=CS.ASMAreaNodeType	
	WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
	UNION ALL
	SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RSMAreaID,RSMAreaType,RSMArea,0,0,'Direct',0,0,'Direct'
	FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #tblVwSalesHierarchy CS ON Map.SHNodeId=CS.RSMAreaID AND Map.SHNodeType=CS.RSMAreaType 
	WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)  


	--SELECT * FROM #CompSales
	----SELECT * FROM #tblVwSalesHierarchy
	----SELECT S.RegNodeId,S.RegNodeType,S.Region,S.ASMAreaNodeId,S.ASMAreaNodeType,S.ASMArea,S.SOAreaNodeId,S.SOAreaNodeType,S.SOArea,DM.DHNodeID,DM.DHNodeType,DBR.Descr,0,0,'',0,0,'' FROM tblCompanySalesStructure_DistributorMapping DM INNER JOIN #tblVwSalesHierarchy S ON DM.SHNodeID=S.ComCoverageAreaID AND DM.SHNodeType=S.ComCoverageAreaType AND CAST(GETDATE() AS DATE) BETWEEN DM.FROmdate AND DM.ToDate LEFT OUTER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=DM.DHNodeID AND DBR.NodeType=DM.DHNodeType


	INSERT INTO #tmpRsltWithFullHierarchy(RegionID,RegionType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea, DBRNodeId,DBRNodeType,DBR,DBRCovAreaId, DBRCovAreaNodeType,DBRCovArea,DBRRouteId,DBRRouteNodeType,DBRRoute)
	SELECT S.RSMAreaID,S.RSMAreaType,S.RSMArea,S.ASMAreaID,S.ASMAreaNodeType,S.ASMArea,S.SOAreaID,S.SOAreaNodeType,S.SOArea,DM.DHNodeID,DM.DHNodeType,DBR.Descr,0,0,'',0,0,'' FROM tblCompanySalesStructure_DistributorMapping DM INNER JOIN #tblVwSalesHierarchy S ON DM.SHNodeID=S.DSRAreaID AND DM.SHNodeType=S.DSRAreaNodeType  LEFT OUTER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=DM.DHNodeID AND DBR.NodeType=DM.DHNodeType WHERE CAST(GETDATE() AS DATE) BETWEEN DM.FROmdate AND DM.ToDate


	----SELECT ISNULL(#CompSales.RegNodeId,0),ISNULL(#CompSales.RegNodeType,100),ISNULL(#CompSales.Region,'NA'),ISNULL(#CompSales.ASMAreaId,0),ISNULL(#CompSales.ASMAreaType,110),ISNULL(#CompSales.ASMArea,'NA'),ISNULL(#CompSales.SOID,0),ISNULL(#CompSales.SOAreaType,120),ISNULL(#CompSales.SOArea,'NA'),vwDBR.DBRNodeID,vwDBR.DistributorNodeType,vwDBR.Distributor, vwDBR.DBRCoverageID,vwDBR.DBRCoverageNodeType,vwDBR.DBRCoverage,vwDBR.DBRRouteID,vwDBR.RouteNodeType,vwDBR.DBRRoute
	----FROM VwAllDistributorHierarchy vwDBR LEFT JOIN #CompSales ON vwDBR.DBRCoverageId=#CompSales.DHNodeId AND vwDBR.DBRCoverageNodeType=#CompSales.DHNodeType
	
	IF @SalesAreaNodeType=100 --Region
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE RegionID NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas)
	END
	ELSE IF @SalesAreaNodeType=110 -- ASM
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE ASMAreaId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas)
	END
	ELSE IF @SalesAreaNodeType=120 --SO
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE SOAreaId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas)
	END

	--SELECT * FROM #tmpRsltWithFullHierarchy --WHERE DBRNodeId=1

	--Zone
	IF @SalesAreaNodeType=0 OR @SalesAreaNodeType=100
	BEGIN
		INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl)
		SELECT DISTINCT RegionID,RegionType,0,0,0,0,Region,0
		FROM #tmpRsltWithFullHierarchy
	END

	--ASMA Area
	IF @SalesAreaNodeType=0 OR @SalesAreaNodeType=100 OR @SalesAreaNodeType=110
	BEGIN
		INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl)
		SELECT DISTINCT ASMAreaId,ASMAreaNodeType,RegionID,RegionType,0,0,ASMArea,CASE @SalesAreaNodeType WHEN 0 THEN 1 WHEN 100 THEN 1 ELSE 0 END
		FROM #tmpRsltWithFullHierarchy
	END

	-- So Area
	INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl)
	SELECT DISTINCT SOAreaId,SOAreaNodeType,ASMAreaId,ASMAreaNodeType,RegionID,RegionType,SOArea,CASE @SalesAreaNodeType WHEN 0 THEN 2 WHEN 100 THEN 2 WHEN 110 THEN 1 ELSE 0 END	FROM #tmpRsltWithFullHierarchy

	--Comp Coverage Area
	INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl)
	SELECT DISTINCT CompCovAreaId,CompCovAreaNodeType,SOAreaId,SOAreaNodeType,ASMAreaId,ASMAreaNodeType,CompCovArea,CASE @SalesAreaNodeType WHEN 0 THEN 3 WHEN 100 THEN 3 WHEN 110 THEN 2 ELSE 1 END
	FROM #tmpRsltWithFullHierarchy
	WHERE CompCovAreaId IS NOT NULL

	--Comp Route
	INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl)
	SELECT DISTINCT CompRouteId,CompRouteNodeType,CompCovAreaId,CompCovAreaNodeType,SOAreaId,SOAreaNodeType,CompRoute,CASE @SalesAreaNodeType WHEN 0 THEN 4 WHEN 100 THEN 4 WHEN 110 THEN 3 ELSE 2 END
	FROM #tmpRsltWithFullHierarchy
	WHERE CompRouteId IS NOT NULL

	--Distributor
	INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl)
	SELECT DISTINCT DBRNodeId,DBRNodeType,SOAreaId,SOAreaNodeType,ASMAreaId,ASMAreaNodeType,DBR,CASE @SalesAreaNodeType WHEN 0 THEN 3 WHEN 100 THEN 3 WHEN 110 THEN 2 ELSE 1 END
	FROM #tmpRsltWithFullHierarchy
	WHERE DBRNodeId IS NOT NULL

	--Distributor Coverage Area
	INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl)
	SELECT DISTINCT DBRCovAreaId, DBRCovAreaNodeType,DBRNodeId,DBRNodeType,SOAreaId,SOAreaNodeType,DBRCovArea,CASE @SalesAreaNodeType WHEN 0 THEN 4 WHEN 100 THEN 4 WHEN 110 THEN 3 ELSE 2 END
	FROM #tmpRsltWithFullHierarchy
	WHERE DBRCovAreaId IS NOT NULL

	--Distributor Route
	INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl)
	SELECT DISTINCT DBRRouteId,DBRRouteNodeType,DBRCovAreaId, DBRCovAreaNodeType,DBRNodeId,DBRNodeType,DBRRoute,CASE @SalesAreaNodeType WHEN 0 THEN 5 WHEN 100 THEN 5 WHEN 110 THEN 4 ELSE 3 END
	FROM #tmpRsltWithFullHierarchy
	WHERE DBRRouteId IS NOT NULL

	
	--Perosn Name update
	  UPDATE A SET A.[Sales Area]=[Sales Area]  + '(' + ISNULL(AA.Person,'Vacant') + ')'  FROM #tmpRslt A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.NodeId AS PersonId,C.Descr AS Person FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate)) AA
    ON A.NodeId=AA.NodeId AND A.NodeType=AA.NodeType
	WHERE A.NodeType NOT IN(150)



	SELECT NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl
	FROM #tmpRslt WHERE NodeId<>0
	ORDER BY Lvl

	SELECT MAX(Lvl) MaxLvl FROm #tmpRslt
END

