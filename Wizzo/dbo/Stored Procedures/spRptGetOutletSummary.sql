-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec [spRptGetOutletSummary] 0,1,1,'11-Jan-2022'
--exec [spRptGetOutletSummary] 83189,1
--exec [spRptGetOutletSummary] 12246,1
--exec [spRptGetOutletSummary] 12249
CREATE PROCEDURE [dbo].[spRptGetOutletSummary]
@LoginId INT=0,
@ChannelId INT=1,
@flgOverAll TINYINT=0,  -- 1=When OverAll data is needed.
@DateFrom Date='01-Jan-2021'
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
		
	CREATE TABLE #SalesAreas(SalesAreaNodeId INT,SalesAreaNodeType INT)

	IF @LoginPersonType=0
	BEGIN
		INSERT INTO #SalesAreas(SalesAreaNodeId,SalesAreaNodeType)
		SELECT SP.NodeID,SP.NodeType
		FROM tblSalesPersonMapping SP INNER JOIN tblMstrPerson P ON P.NodeID=SP.PersonNodeID AND P.NodeType=SP.PersonType
		WHERE (GETDATE() BETWEEN SP.FromDate AND SP.ToDate) 
	END
	ELSE IF @LoginPersonType=150
	BEGIN
		SELECT @SalesAreaNodeType=@LoginPersonType

		INSERT INTO #SalesAreas(SalesAreaNodeId,SalesAreaNodeType)
		SELECT @LoginPersonId,@LoginPersonType
		--SELECT @SalesAreaNodeType
		--SELECT * FROM #SalesAreas
	END
	ELSE
	BEGIN
		SELECT @SalesAreaNodeType=ISNULL(MIN(SP.NodeType),0)
		FROM tblSalesPersonMapping SP
		WHERE SP.PersonNodeID=@LoginPersonId AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)

		IF @flgOverAll=1
		BEGIN
			INSERT INTO #SalesAreas(SalesAreaNodeId,SalesAreaNodeType)
			SELECT SP.NodeID,SP.NodeType
			FROM tblSalesPersonMapping SP
			WHERE (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)
		END
		ELSE
		BEGIN
			INSERT INTO #SalesAreas(SalesAreaNodeId,SalesAreaNodeType)
			SELECT SP.NodeID,SP.NodeType
			FROM tblSalesPersonMapping SP
			WHERE SP.PersonNodeID=@LoginPersonId AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate) AND SP.NodeType=@SalesAreaNodeType
		END
	END
	PRINT 'SalesAreaNodeType-' + CAST(@SalesAreaNodeType AS VARCHAR)
	--SELECT @SalesAreaNodeType
	--SELECT * FROM #SalesAreas

	CREATE TABLE #tmpRslt(NodeId INT,NodeType INT,PNodeId INT,PNodeType INT,PPNodeId INT,PPNodeType INT,[Sales Area] VARCHAR(200),Lvl TINYINT,TotStoreAdded VARCHAR(10) ,Approved VARCHAR(10),Rejected VARCHAR(10),ReMap VARCHAR(10),ApprovalPending VARCHAR(10))
	
	CREATE TABLE #tmpRsltWithFullHierarchy(RegionId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CompCovAreaId INT,CompCovAreaNodeType INT,CompCovArea VARCHAR(200),CompRouteId INT,CompRouteNodeType INT,CompRoute VARCHAR(200),DBRNodeId INT,DBRNodeType INT,DBR VARCHAR(200),TotStoreAdded INT,Approved INT,Rejected INT,ReMap INT,ApprovalPending INT)
	
	SELECT * INTO #SalesHier FROM VwCompanyDSRFullDetail
	--SELECT * INTO #DBRHier FROM VwAllDistributorHierarchy

	INSERT INTO #tmpRsltWithFullHierarchy(RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CompCovAreaId,CompCovAreaNodeType, CompCovArea,CompRouteId,CompRouteNodeType,CompRoute,TotStoreAdded,Approved,Rejected,ReMap,ApprovalPending)
	SELECT DISTINCT RSMAreaID,RSMAreaType,RSMArea,ASMAreaID,ASMAreaNodeType,ASMArea,SOAreaID,SOAreaNodeType,SOArea,DSRAreaID,DSRAreaNodeType,DSRArea,RouteNodeId,RouteNodetype,R.Descr,0,0,0,0,0
	FROM #SalesHier S INNER JOIN tblRoutePlanningVisitDetail RP ON RP.CovAreaNodeID=S.DSRAreaID AND RP.CovAreaNodeType=S.DSRAreaNodeType INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=RP.RouteNodeId AND R.NodeType=RP.RouteNodetype 
	WHERE RouteNodeId IS NOT NULL --AND RP.VisitDate>=CAST(GETDATE() AS DATE)

	--SELECT * FROM #tmpRsltWithFullHierarchy

	----SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegNodeId,RegNodeType,Region,ASMAreaNodeId,ASMAreaNodeType,ASMArea,SOAreaNodeId,SOAreaNodeType,SOArea INTO #CompSales
	----FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #SalesHier CS ON Map.SHNodeId=CS.SOAreaNodeId AND Map.SHNodeType=CS.SOAreaNodeType	
	----WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
	----UNION ALL
	----SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegNodeId,RegNodeType,Region,ASMAreaNodeId,ASMAreaNodeType,ASMArea,0,0,'Direct'
	----FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #SalesHier CS ON Map.SHNodeId=CS.ASMAreaNodeId AND Map.SHNodeType=CS.ASMAreaNodeType		
	----WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
	----UNION ALL
	----SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegNodeId,RegNodeType,Region,0,0,'Direct',0,0,'Direct'
	----FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #SalesHier CS ON Map.SHNodeId=CS.RegNodeId AND Map.SHNodeType=CS.RegNodeType 
	----WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate) 

	--SELECT * FROM #CompSales
	
	----INSERT INTO #tmpRsltWithFullHierarchy(RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,DBRNodeId,DBRNodeType,DBR,DBRCovAreaId, DBRCovAreaNodeType,DBRCovArea,DBRRouteId,DBRRouteNodeType,DBRRoute,TotStoreAdded,Approved, Rejected,ReMap,ApprovalPending)
	----SELECT ISNULL(#CompSales.RegionID,0),ISNULL(#CompSales.RegionType,100),ISNULL(#CompSales.Region,'NA'),ISNULL(#CompSales.ASMAreaId,0),ISNULL(#CompSales.ASMAreaType,110),ISNULL(#CompSales.ASMArea,'NA'),ISNULL(#CompSales.SOID,0),ISNULL(#CompSales.SOAreaType,120),ISNULL(#CompSales.SOArea,'NA'),vwDBR.DBRNodeID,vwDBR.DistributorNodeType,vwDBR.Distributor, vwDBR.DBRCoverageID,vwDBR.DBRCoverageNodeType,vwDBR.DBRCoverage,vwDBR.DBRRouteID,vwDBR.RouteNodeType,vwDBR.DBRRoute,0,0,0,0,0
	----FROM #DBRHier vwDBR LEFT JOIN #CompSales ON vwDBR.DBRCoverageId=#CompSales.DHNodeId AND vwDBR.DBRCoverageNodeType=#CompSales.DHNodeType
	

	----IF @SalesAreaNodeType=0
	----BEGIN
	----	--DELETE A FROM #tmpRsltWithFullHierarchy A WHERE 1=0
	----	DELETE A FROM #tmpRsltWithFullHierarchy A LEFT OUTER JOIN tblSalesHierChannelMapping B ON A.RegionId=B.SalesStructureNodID AND A.RegionNodeType=B.SalesStructureNodType AND B.ChannelID=@ChannelId AND (CAST(GETDATE() AS DATE) BETWEEN B.FromDate AND B.ToDate)
	----	WHERE B.SalesStructureNodID IS NULL AND B.SalesStructureNodType IS NULL

	----	--SELECT * FROM #tmpRsltWithFullHierarchy
	----END	
	----ELSE 
	IF @SalesAreaNodeType=100 --Region
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE RegionId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas WHERE SalesAreaNodeType=100)
	END
	ELSE IF @SalesAreaNodeType=110 -- ASM
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE ASMAreaId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas WHERE SalesAreaNodeType=110)
	END
	ELSE IF @SalesAreaNodeType=120 --SO
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE SOAreaId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas WHERE SalesAreaNodeType=120)
	END
	ELSE IF @SalesAreaNodeType=150
	BEGIN
		CREATE TABLE #CovAreaListForDBR(CovAreaNodeId INT,CovAreaNodeType INT)

		INSERT INTO #CovAreaListForDBR(CovAreaNodeId,CovAreaNodeType)
		SELECT NodeId,NodeType FROM tblCompanySalesStructureHierarchy WHERE PNodeId=@LoginPersonId AND PNodeType=@LoginPersonType
		--SELECT * FROM #CovAreaListForDBR

		INSERT INTO #CovAreaListForDBR(CovAreaNodeId,CovAreaNodeType)
		SELECT SHNodeID,SHNodeType FROM tblCompanySalesStructure_DistributorMapping 
		WHERE DHNodeId=@LoginPersonId AND DHNodeType=@LoginPersonType AND (CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate) AND SHNodeType=130

		----DELETE A FROM #tmpRsltWithFullHierarchy A LEFT OUTER JOIN #CovAreaListForDBR B ON A.DBRCovAreaId=B.CovAreaNodeId AND A.DBRCovAreaNodeType=B.CovAreaNodeType AND B.CovAreaNodeType=160
		----WHERE B.CovAreaNodeId IS NULL AND B.CovAreaNodeType IS NULL AND A.DBRCovAreaId IS NOT NULL

		DELETE A FROM #tmpRsltWithFullHierarchy A LEFT OUTER JOIN #CovAreaListForDBR B ON A.CompCovAreaId=B.CovAreaNodeId AND A.CompCovAreaNodeType=B.CovAreaNodeType AND B.CovAreaNodeType=130
		WHERE B.CovAreaNodeId IS NULL AND B.CovAreaNodeType IS NULL AND A.CompCovAreaId IS NOT NULL
	END
	--SELECT * FROM #tmpRsltWithFullHierarchy

	--ELSE IF @LoginPersonType>0
	--BEGIN
	--	DELETE A FROM #tmpRsltWithFullHierarchy A 
	--END
	--DELETE FROM #tmpRsltWithFullHierarchy WHERE RegionId<>13
	--SELECT * FROM #tmpRsltWithFullHierarchy --where DBRRouteId=0 OR CompRouteId=0 order by SOAreaId --WHERE DBRNodeId=1

	--SELECT A.StoreIdDB,A.OutletName,B.Address,B.City,B.Pincode,B.State,C.OutletCategory,A.VisitEndTS AS StoreAdditionTime,A.ModifyDate AS ModifiedTime,ISNULL(flgStoreValidated,0) flgStoreValidated
	--FROM tblPDASyncStoreMappingMstr A LEFT JOIN tblPDASyncAddressDet B ON A.StoreIdDB=B.StoreIdDB
	--LEFT JOIN tblPDASyncStoreattributeDet C ON A.StoreIdDB=C.StoreIdDB

	----SELECT A.RouteId,A.RouteNodeType,A.StoreIdDB,ISNULL(flgStoreValidated,0) flgStoreValidated INTO #tmpStoreDetails
	----FROM tblPDASyncStoreMappingMstr A INNER JOIN #tmpRsltWithFullHierarchy B ON A.RouteId=B.DBRRouteId AND A.RouteNodeType=DBRRouteNodeType
	----INNER JOIN tblPDASyncStoreattributeDet C ON A.StoreIdDB=C.StoreIdDB
	----WHERE C.OutletChannelId =@ChannelId AND ISNULL(A.FlgActive,0)=1 AND ISNULL(A.OrgStoreId,0)=0
	----UNION
	----SELECT A.RouteId,A.RouteNodeType,A.StoreIdDB,ISNULL(flgStoreValidated,0) flgStoreValidated
	----FROM tblPDASyncStoreMappingMstr A INNER JOIN #tmpRsltWithFullHierarchy B ON A.RouteId=B.CompRouteId AND A.RouteNodeType=CompRouteNodeType
	----INNER JOIN tblPDASyncStoreattributeDet C ON A.StoreIdDB=C.StoreIdDB
	----WHERE C.OutletChannelId =@ChannelId AND ISNULL(A.FlgActive,0)=1 AND ISNULL(A.OrgStoreId,0)=0
	----UNION
	----SELECT A.RouteId,A.RouteNodeType,C.StoreIdPDA,ISNULL(flgvalidated,0) flgStoreValidated
	----FROM tblRouteCoverageStoreMapping A INNER JOIN #tmpRsltWithFullHierarchy B ON A.RouteId=B.DBRRouteId AND A.RouteNodeType=DBRRouteNodeType
	----INNER JOIN tblStoreMaster C ON A.StoreId=C.StoreId
	----WHERE C.StoreChannelID =@ChannelId AND ISNULL(C.flgActive,0)=1 AND (CAST(GETDATE() AS DATE) BETWEEN A.FromDate AND A.ToDate)
	----UNION
	--SELECT * FROM tblRoutePlanningVisitDetail WHERE RouteNodeId NOT IN (SELECT CompRouteid FROM #tmpRsltWithFullHierarchy)
	--SELECT * FROM #tmpRsltWithFullHierarchy

	SELECT DISTINCT A.RouteId,A.RouteNodeType,C.StoreId StoreIdDB,ISNULL(flgvalidated,0) flgStoreValidated,C.CreatedDate INTO #tmpStoreDetails
	FROM tblRouteCoverageStoreMapping A INNER JOIN #tmpRsltWithFullHierarchy B ON A.RouteId=B.CompRouteId AND A.RouteNodeType=CompRouteNodeType
	INNER JOIN tblStoreMaster C ON A.StoreId=C.StoreId
	WHERE ISNULL(C.flgActive,0)=1 AND (CAST(GETDATE() AS DATE) BETWEEN A.FromDate AND A.ToDate)

	--SELECT COUNT(DISTINCT StoreIdDB) Storecount FROM #tmpStoreDetails
	--SELECT *  FROM #tmpStoreDetails --WHERE CAST(CreatedDate AS DATE)<@DateFrom
	DELETE S FROM #tmpStoreDetails S WHERE CAST(ISNULL(CreatedDate,'01-Nov-2021') AS DATE)<@DateFrom

	SELECT DISTINCT RouteId,RouteNodeType,COUNT(DISTINCT StoreIdDB) AS TotStoreAdded,0 AS Approved,0 AS Rejected,0 AS ReMap,0 AS ApprovalPending INTO #tmpStoreCount 
	FROM #tmpStoreDetails
	GROUP BY RouteId,RouteNodeType

	UPDATE  A SET A.Approved=AA.Approved FROM #tmpStoreCount A INNER JOIN (SELECT RouteId,RouteNodeType,COUNT(DISTINCT StoreIdDB) AS Approved FROM #tmpStoreDetails WHERE ISNULL(flgStoreValidated,0)=1 GROUP BY RouteId,RouteNodeType) AA ON A.RouteId=AA.RouteId AND A.RouteNodeType=AA.RouteNodeType

	UPDATE  A SET A.Rejected=AA.Rejected FROM #tmpStoreCount A INNER JOIN (SELECT RouteId,RouteNodeType,COUNT(DISTINCT StoreIdDB) AS Rejected FROM #tmpStoreDetails WHERE ISNULL(flgStoreValidated,0)=2 GROUP BY RouteId,RouteNodeType) AA ON A.RouteId=AA.RouteId AND A.RouteNodeType=AA.RouteNodeType

	UPDATE  A SET A.ReMap=AA.ReMap FROM #tmpStoreCount A INNER JOIN (SELECT RouteId,RouteNodeType,COUNT(DISTINCT StoreIdDB) AS ReMap FROM #tmpStoreDetails WHERE ISNULL(flgStoreValidated,0)=3 GROUP BY RouteId,RouteNodeType) AA ON A.RouteId=AA.RouteId AND A.RouteNodeType=AA.RouteNodeType

	UPDATE  A SET A.ApprovalPending=AA.ApprovalPending FROM #tmpStoreCount A INNER JOIN (SELECT RouteId,RouteNodeType,COUNT(DISTINCT StoreIdDB) AS ApprovalPending FROM #tmpStoreDetails WHERE ISNULL(flgStoreValidated,0)=0 GROUP BY RouteId,RouteNodeType) AA ON A.RouteId=AA.RouteId AND A.RouteNodeType=AA.RouteNodeType
	
	--SELECT * FROM #tmpStoreCount ORDER BY RouteNodeType,CAST(RouteId AS INT)

	----UPDATE A SET A.TotStoreAdded=B.TotStoreAdded,A.Approved=B.Approved,A.Rejected=B.Rejected,A.ReMap=B.ReMap,A.ApprovalPending=B.ApprovalPending  
	----FROM #tmpRsltWithFullHierarchy A INNER JOIN #tmpStoreCount B ON A.DBRRouteId=B.RouteId AND A.DBRRouteNodeType=B.RouteNodeType
	
	UPDATE A SET A.TotStoreAdded=B.TotStoreAdded,A.Approved=B.Approved,A.Rejected=B.Rejected,A.ReMap=B.ReMap,A.ApprovalPending=B.ApprovalPending  
	FROM #tmpRsltWithFullHierarchy A INNER JOIN #tmpStoreCount B ON A.CompRouteId=B.RouteId AND A.CompRouteNodeType=B.RouteNodeType

	--SELECT * FROM #tmpRsltWithFullHierarchy
	--SELECT * FROM #tmpRsltWithFullHierarchy where Rejected>0 AND Approved=0 AND ReMap=0 AND ApprovalPending=0
	PRINT 'Remove Inactive Route'
	----DELETE A FROM #tmpRsltWithFullHierarchy A INNER JOIN tblDBRSalesStructureroutemstr B ON A.DBRRouteId=B.NodeId AND A.DBRRouteNodeType=B.NodeType WHERE B.IsActive=0 AND ISNULL(TotStoreAdded,0)=0
	----DELETE A FROM #tmpRsltWithFullHierarchy A INNER JOIN tblDBRSalesStructureroutemstr B ON A.DBRRouteId=B.NodeId AND A.DBRRouteNodeType=B.NodeType WHERE B.IsActive=0 AND Rejected>0 AND Approved=0 AND ReMap=0 AND ApprovalPending=0
	DELETE A FROM #tmpRsltWithFullHierarchy A INNER JOIN tblCompanySalesStructureRouteMstr B ON A.CompRouteId=B.NodeId AND A.CompRouteNodeType=B.NodeType WHERE B.IsActive=0 AND ISNULL(TotStoreAdded,0)=0
	DELETE A FROM #tmpRsltWithFullHierarchy A INNER JOIN tblCompanySalesStructureRouteMstr B ON A.CompRouteId=B.NodeId AND A.CompRouteNodeType=B.NodeType WHERE B.IsActive=0 AND Rejected>0 AND Approved=0 AND ReMap=0 AND ApprovalPending=0
	--SELECT * FROM #tmpRsltWithFullHierarchy

	-- National
	IF @SalesAreaNodeType=0 
	BEGIN
	INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl,TotStoreAdded,Approved,Rejected,ReMap,ApprovalPending)
	SELECT DISTINCT 0,0,-1,-1,0,0,'Total',0,CAST(SUM(TotStoreAdded) AS VARCHAR) + '^999',CAST(SUM(Approved) AS VARCHAR) + '^1',CAST(SUM(Rejected) AS VARCHAR) + '^2',CAST(SUM(ReMap) AS VARCHAR) + '^3',CAST(SUM(ApprovalPending) AS VARCHAR) + '^0'
		FROM #tmpRsltWithFullHierarchy
	END
	--Region
	IF @SalesAreaNodeType=0 OR @SalesAreaNodeType=100
	BEGIN
		INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl,TotStoreAdded,Approved,Rejected,ReMap,ApprovalPending)
		SELECT DISTINCT RegionId,RegionNodeType,0,0,-1,-1,Region,CASE @SalesAreaNodeType WHEN 0 THEN 1 ELSE 0 END,CAST(SUM(TotStoreAdded) AS VARCHAR) + '^999',CAST(SUM(Approved) AS VARCHAR) + '^1',CAST(SUM(Rejected) AS VARCHAR) + '^2',CAST(SUM(ReMap) AS VARCHAR) + '^3',CAST(SUM(ApprovalPending) AS VARCHAR) + '^0'
		FROM #tmpRsltWithFullHierarchy
		GROUP BY RegionId,RegionNodeType,Region
	END

	--ASMA Area
	IF @SalesAreaNodeType=0 OR @SalesAreaNodeType=100 OR @SalesAreaNodeType=110
	BEGIN
		INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl,TotStoreAdded,Approved,Rejected,ReMap,ApprovalPending)
		SELECT DISTINCT ASMAreaId,ASMAreaNodeType,RegionId,RegionNodeType,0,0,ASMArea,CASE @SalesAreaNodeType WHEN 0 THEN 2 WHEN 100 THEN 1 ELSE 0 END,CAST(SUM(TotStoreAdded) AS VARCHAR) + '^999',CAST(SUM(Approved) AS VARCHAR) + '^1',CAST(SUM(Rejected) AS VARCHAR) + '^2',CAST(SUM(ReMap) AS VARCHAR) + '^3',CAST(SUM(ApprovalPending) AS VARCHAR) + '^0'
		FROM #tmpRsltWithFullHierarchy
		GROUP BY ASMAreaId,ASMAreaNodeType,RegionId,RegionNodeType,ASMArea
	END

	-- So Area
	IF @SalesAreaNodeType=0 OR @SalesAreaNodeType=100 OR @SalesAreaNodeType=110 OR @SalesAreaNodeType=120
	BEGIN
		INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl,TotStoreAdded,Approved,Rejected,ReMap,ApprovalPending)
		SELECT DISTINCT SOAreaId,SOAreaNodeType,ASMAreaId,ASMAreaNodeType,RegionId,RegionNodeType,SOArea,CASE @SalesAreaNodeType WHEN 0 THEN 3 WHEN 100 THEN 2 WHEN 110 THEN 1 ELSE 0 END,CAST(SUM(TotStoreAdded) AS VARCHAR) + '^999',CAST(SUM(Approved) AS VARCHAR) + '^1',CAST(SUM(Rejected) AS VARCHAR) + '^2',CAST(SUM(ReMap) AS VARCHAR) + '^3',CAST(SUM(ApprovalPending) AS VARCHAR) + '^0'
		FROM #tmpRsltWithFullHierarchy
		GROUP BY SOAreaId,SOAreaNodeType,ASMAreaId,ASMAreaNodeType,SOArea,RegionId,RegionNodeType
	END

	--Comp Coverage Area
	INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl,TotStoreAdded,Approved,Rejected,ReMap,ApprovalPending)
	SELECT DISTINCT CompCovAreaId,CompCovAreaNodeType,SOAreaId,SOAreaNodeType,ASMAreaId,ASMAreaNodeType,CompCovArea,CASE @SalesAreaNodeType WHEN 0 THEN 4 WHEN 100 THEN 3 WHEN 110 THEN 2 WHEN 120 THEN 1 ELSE 0 END,CAST(SUM(TotStoreAdded) AS VARCHAR) + '^999',CAST(SUM(Approved) AS VARCHAR) + '^1',CAST(SUM(Rejected) AS VARCHAR) + '^2',CAST(SUM(ReMap) AS VARCHAR) + '^3',CAST(SUM(ApprovalPending) AS VARCHAR) + '^0'
	FROM #tmpRsltWithFullHierarchy
	WHERE CompCovAreaId IS NOT NULL
	GROUP BY CompCovAreaId,CompCovAreaNodeType,SOAreaId,SOAreaNodeType,CompCovArea,ASMAreaId,ASMAreaNodeType

	--Comp Route
	INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl,TotStoreAdded,Approved,Rejected,ReMap,ApprovalPending)
	SELECT DISTINCT CompRouteId,CompRouteNodeType,CompCovAreaId,CompCovAreaNodeType,SOAreaId,SOAreaNodeType,CompRoute,CASE @SalesAreaNodeType WHEN 0 THEN 5 WHEN 100 THEN 4 WHEN 110 THEN 3 WHEN 120 THEN 2 ELSE 1 END,CAST(SUM(TotStoreAdded) AS VARCHAR) + '^999',CAST(SUM(Approved) AS VARCHAR) + '^1',CAST(SUM(Rejected) AS VARCHAR) + '^2',CAST(SUM(ReMap) AS VARCHAR) + '^3',CAST(SUM(ApprovalPending) AS VARCHAR) + '^0'
	FROM #tmpRsltWithFullHierarchy
	WHERE CompRouteId IS NOT NULL
	GROUP BY CompRouteId,CompRouteNodeType,CompCovAreaId,CompCovAreaNodeType,CompRoute,SOAreaId,SOAreaNodeType

	------Distributor
	----INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl,TotStoreAdded,Approved,Rejected,ReMap,ApprovalPending)
	----SELECT DISTINCT DBRNodeId,DBRNodeType,SOAreaId,SOAreaNodeType,ASMAreaId,ASMAreaNodeType,DBR,CASE @SalesAreaNodeType WHEN 0 THEN 4 WHEN 100 THEN 3 WHEN 110 THEN 2 WHEN 120 THEN 1 ELSE 0 END,CAST(SUM(TotStoreAdded) AS VARCHAR) + '^999',CAST(SUM(Approved) AS VARCHAR) + '^1',CAST(SUM(Rejected) AS VARCHAR) + '^2',CAST(SUM(ReMap) AS VARCHAR) + '^3',CAST(SUM(ApprovalPending) AS VARCHAR) + '^0'
	----FROM #tmpRsltWithFullHierarchy
	----WHERE DBRNodeId IS NOT NULL
	----GROUP BY DBRNodeId,DBRNodeType,SOAreaId,SOAreaNodeType,DBR,ASMAreaId,ASMAreaNodeType

	------Distributor Coverage Area
	----INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl,TotStoreAdded,Approved,Rejected,ReMap,ApprovalPending)
	----SELECT DISTINCT DBRCovAreaId, DBRCovAreaNodeType,DBRNodeId,DBRNodeType,SOAreaId,SOAreaNodeType,DBRCovArea,CASE @SalesAreaNodeType WHEN 0 THEN 5 WHEN 100 THEN 4 WHEN 110 THEN 3  WHEN 120 THEN 2 ELSE 1 END,CAST(SUM(TotStoreAdded) AS VARCHAR) + '^999',CAST(SUM(Approved) AS VARCHAR) + '^1',CAST(SUM(Rejected) AS VARCHAR) + '^2',CAST(SUM(ReMap) AS VARCHAR) + '^3',CAST(SUM(ApprovalPending) AS VARCHAR) + '^0'
	----FROM #tmpRsltWithFullHierarchy
	----WHERE DBRCovAreaId IS NOT NULL
	----GROUP BY DBRCovAreaId, DBRCovAreaNodeType,DBRNodeId,DBRNodeType,DBRCovArea,SOAreaId,SOAreaNodeType

	------Distributor Route
	----INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl,TotStoreAdded,Approved,Rejected,ReMap,ApprovalPending)
	----SELECT DISTINCT DBRRouteId,DBRRouteNodeType,DBRCovAreaId, DBRCovAreaNodeType,DBRNodeId,DBRNodeType,DBRRoute,CASE @SalesAreaNodeType WHEN 0 THEN 6 WHEN 100 THEN 5 WHEN 110 THEN 4 WHEN 120 THEN 3 ELSE 2 END,CAST(SUM(TotStoreAdded) AS VARCHAR) + '^999',CAST(SUM(Approved) AS VARCHAR) + '^1',CAST(SUM(Rejected) AS VARCHAR) + '^2',CAST(SUM(ReMap) AS VARCHAR) + '^3',CAST(SUM(ApprovalPending) AS VARCHAR) + '^0'
	----FROM #tmpRsltWithFullHierarchy
	----WHERE DBRRouteId IS NOT NULL
	----GROUP BY DBRRouteId,DBRRouteNodeType,DBRCovAreaId, DBRCovAreaNodeType,DBRRoute,DBRNodeId,DBRNodeType

	
	--Perosn Name update
	  UPDATE A SET A.[Sales Area]=[Sales Area]  + '(' + ISNULL(AA.Person,'Vacant') + ')'  FROM #tmpRslt A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.NodeId AS PersonId,C.Descr AS Person FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID --AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate)) AA
    ON A.NodeId=AA.NodeId AND A.NodeType=AA.NodeType
	WHERE A.NodeType NOT IN(140,150,0)


	IF @flgOverAll=1
	BEGIN
		SELECT NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl,TotStoreAdded [Tot Store Added],Approved,Rejected,ReMap [Re Map],ApprovalPending [Approval Pending] 
		FROM #tmpRslt WHERE NodeType IN (100,110,0)
		ORDER BY Lvl
	END
	ELSE
	BEGIN
		SELECT NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl,TotStoreAdded [Tot Store Added],Approved,Rejected,ReMap [Re Map],ApprovalPending [Approval Pending] 
		FROM #tmpRslt
		ORDER BY Lvl
	END

	

	SELECT MAX(Lvl) MaxLvl FROm #tmpRslt
END
