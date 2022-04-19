-- =============================================
-- Author:		Avinash Gupta
-- Create date: 23-Jan-2018
-- Description:	
-- =============================================
-- SpPDAGetOutletAddedSummary '866343039427098',1
CREATE PROCEDURE [dbo].[SpPDAGetOutletAddedSummary] 
	@PDACode varchar(50),
	@flgDrillLevel TINYINT=0 --1= drill to Category,2=drill to Route
AS
BEGIN
	-- Change to include the stores added by all the dsr in case of SO summary.

	SELECT SalesPersonNodeId,SalesPersonNodetype,SalesNodeId,SalesNodetype INTO #tblPersonList FROM dbo.[fnGetPersonList](@PDACode)

	--SELECT * FROM #tblPersonList

	IF EXISTS(SELECT 1 FROM #tblPersonList WHERE SalesPersonNodetype=220)
	BEGIN
		--DELETE FROM #tblPersonList
		INSERT INTO #tblPersonList(SalesPersonNodeId,SalesPersonNodetype,SalesNodeId,SalesNodetype)
		SELECT DISTINCT CompanyDSRID,CompanyDSR,DSRAreaID,DSRAreaNodeType FROM [dbo].[VwCompanyDSRFullDetail] INNER JOIN #tblPersonList P ON P.SalesNodeId=SOAreaID AND P.SalesNodetype=SOAreaNodeType
		UNION
		SELECT DISTINCT DistributorDSRID,DistributorDSRNodeType,DBRCoverageID,DBRCoverageNodeType FROM [dbo].[VwDistributorDSRFullDetail] INNER JOIN #tblPersonList P ON P.SalesNodeId=SOAreaID AND P.SalesNodetype=SOAreaNodeType
		UNION
		SELECT DISTINCT CompanyDSRID,CompanyDSR,DSRRouteNodeID,DSRRouteNodeType FROM [dbo].[VwCompanyDSRFullDetail] INNER JOIN #tblPersonList P ON P.SalesNodeId=SOAreaID AND P.SalesNodetype=SOAreaNodeType
		UNION
		SELECT DISTINCT DistributorDSRID,DistributorDSRNodeType,DBRRouteID,RouteNodeType FROM [dbo].[VwDistributorDSRFullDetail] INNER JOIN #tblPersonList P ON P.SalesNodeId=SOAreaID AND P.SalesNodetype=SOAreaNodeType
	END
	--SELECT * FROM #tblPersonList
	--SELECT * FROM #tblPersonList WHERE SalesNodeID=536 AND Salesnodetype=170
	CREATE TABLE #tmpStoreDetails(RouteID INT,RouteNodetype SMALLINT,StoreIdDB INT,flgStoreValidated TINYINT,OutletCategoryID INT)
	-- FOr GT
	INSERT INTO #tmpStoreDetails(RouteID,RouteNodetype,StoreIdDB,flgStoreValidated,OutletCategoryID)
	SELECT A.RouteId,A.RouteNodeType,A.StoreIdDB,ISNULL(flgStoreValidated,0) flgStoreValidated,OutletTypeID 
	FROM tblPDASyncStoreMappingMstr A INNER JOIN #tblPersonList B ON A.RouteId=B.SalesNodeId AND A.RouteNodeType=SalesNodetype
	INNER JOIN tblPDASyncStoreattributeDet C ON A.StoreIdDB=C.StoreIdDB
	WHERE C.OutletChannelId =1 AND ISNULL(A.FlgActive,0)=1

	--SELECT * FROM #tmpStoreDetails

	------ For FSD
	----INSERT INTO #tmpStoreDetails(RouteID,RouteNodetype,StoreIdDB,flgStoreValidated,OutletCategoryID)
	----SELECT A.RouteId,A.RouteNodeType,A.StoreIdDB,ISNULL(flgStoreValidated,0) flgStoreValidated,FSD.StoreCategory
	----FROM tblPDASyncStoreMappingMstr A INNER JOIN #tblPersonList B ON A.RouteId=B.SalesNodeId AND A.RouteNodeType=SalesNodetype
	----INNER JOIN tblPDASyncStoreattributeDet C ON A.StoreIdDB=C.StoreIdDB
	----LEFT OUTER JOIN [tblPDASync_FSDStoreCategory] FSD ON FSD.StoreIDDB=C.StoreIDDB
	----WHERE C.OutletChannelId =1 AND ISNULL(A.FlgActive,0)=1

	CREATE TABLE #tblOutletSummary(RouteID INT,Routenodetype SMALLINT,Routename VARCHAR(200),CategoryID INT,Category VARCHAR(200),TotalStores INT Default 0,Validated INT Default 0,Pending INT Default 0)
	CREATE TABLE #tblOverAllOutletSummary(Header VARCHAR(200),Child VARCHAR(200),TotalStores INT Default 0,Validated INT Default 0,Pending INT Default 0)

	IF @flgDrillLevel=1 -- Drill to category
	BEGIN
		INSERT INTO #tblOutletSummary(RouteID,Routenodetype,Routename,CategoryID,Category)
		SELECT SalesNodeId,SalesNodetype,R.Descr,0,'All' FROM #tblPersonList PL INNER JOIN [tblSecMenuContextMenu] SM ON SM.NodeType=PL.SalesNodetype INNER JOIN tblCompanySalesStructureRouteMstr R ON R.nodeId=PL.SalesNodeId AND R.NOdetype=PL.SalesNodetype WHERE flgRoute=1
		UNION
		SELECT SalesNodeId,SalesNodetype,R.Descr,0,'All' FROM #tblPersonList PL INNER JOIN [tblSecMenuContextMenu] SM ON SM.NodeType=PL.SalesNodetype INNER JOIN tblDBRSalesStructureRouteMstr R ON R.nodeId=PL.SalesNodeId AND R.NOdetype=PL.SalesNodetype WHERE flgRoute=1
		UNION
		-- Category wise Route details
		SELECT SalesNodeId,SalesNodetype,R.Descr,C.NodeID,C.StoreCategory FROM #tblPersonList PL INNER JOIN [tblSecMenuContextMenu] SM ON SM.NodeType=PL.SalesNodetype INNER JOIN tblCompanySalesStructureRouteMstr R ON R.nodeId=PL.SalesNodeId AND R.NOdetype=PL.SalesNodetype CROSS JOIN tblStoreCategoryMstr C  WHERE flgRoute=1
		UNION
		SELECT SalesNodeId,SalesNodetype,R.Descr,C.NodeID,C.StoreCategory FROM #tblPersonList PL INNER JOIN [tblSecMenuContextMenu] SM ON SM.NodeType=PL.SalesNodetype INNER JOIN tblDBRSalesStructureRouteMstr R ON R.nodeId=PL.SalesNodeId AND R.NOdetype=PL.SalesNodetype  CROSS JOIN tblStoreCategoryMstr C WHERE flgRoute=1

		-- Total Stores
		UPDATE O SET TotalStores=X.TotalOutlet FROM #tblOutletSummary O ,(SELECT RouteID,COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails GROUP BY RouteID) X WHERE X.RouteID=O.RouteID AND O.CategoryID=0
		UPDATE O SET TotalStores=X.TotalOutlet FROM #tblOutletSummary O ,(SELECT RouteID,OutletCategoryID,COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails GROUP BY RouteID,OutletCategoryID) X WHERE X.RouteID=O.RouteID AND O.CategoryID=X.OutletCategoryID

		-- Approved Stores
		UPDATE O SET Validated=X.TotalOutlet FROM #tblOutletSummary O ,(SELECT RouteID,COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails WHERE flgStoreValidated=1 GROUP BY RouteID) X WHERE X.RouteID=O.RouteID AND O.CategoryID=0
		UPDATE O SET Validated=X.TotalOutlet FROM #tblOutletSummary O ,(SELECT RouteID,OutletCategoryID,COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails WHERE flgStoreValidated=1 GROUP BY RouteID,OutletCategoryID) X WHERE X.RouteID=O.RouteID AND O.CategoryID=X.OutletCategoryID

		-- Pending Stores
		UPDATE O SET Pending=TotalStores-Validated FROM #tblOutletSummary O

		SELECT Routename Header,Category Child,TotalStores,Validated,Pending FROM #tblOutletSummary ORDER BY RouteID,CategoryID
		INSERT INTO #tblOverAllOutletSummary(Header,Child)
		SELECT 'OverAll' Header,'OverAll' Child

		UPDATE O SET TotalStores=X.TotalOutlet FROM #tblOverAllOutletSummary O ,(SELECT COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails) X
		UPDATE O SET Validated=X.TotalOutlet FROM #tblOverAllOutletSummary O ,(SELECT COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails WHERE flgStoreValidated=1) X
		UPDATE O SET Pending=TotalStores-Validated FROM #tblOverAllOutletSummary O

		SELECT * FROM #tblOverAllOutletSummary
		--SELECT 'OverAll' Header,'OverAll' Child,SUM(TotalStores) TotalStores,SUM(Validated) Validated,SUM(Pending) Pending FROM #tblOutletSummary

	END
	ELSE
	BEGIN
		INSERT INTO #tblOutletSummary(RouteID,Routenodetype,Routename,CategoryID,Category)
		SELECT 0,0,'All',NodeID,StoreCategory FROM tblStoreCategoryMstr
		UNION
		-- Category wise Route details
		SELECT SalesNodeId,SalesNodetype,R.Descr,C.NodeID,C.StoreCategory FROM #tblPersonList PL INNER JOIN [tblSecMenuContextMenu] SM ON SM.NodeType=PL.SalesNodetype INNER JOIN tblCompanySalesStructureRouteMstr R ON R.nodeId=PL.SalesNodeId AND R.NOdetype=PL.SalesNodetype CROSS JOIN tblStoreCategoryMstr C  WHERE flgRoute=1
		UNION
		SELECT SalesNodeId,SalesNodetype,R.Descr,C.NodeID,C.StoreCategory FROM #tblPersonList PL INNER JOIN [tblSecMenuContextMenu] SM ON SM.NodeType=PL.SalesNodetype INNER JOIN tblDBRSalesStructureRouteMstr R ON R.nodeId=PL.SalesNodeId AND R.NOdetype=PL.SalesNodetype  CROSS JOIN tblStoreCategoryMstr C WHERE flgRoute=1

		-- Total Stores
		UPDATE O SET TotalStores=X.TotalOutlet FROM #tblOutletSummary O ,(SELECT OutletCategoryID,COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails GROUP BY OutletCategoryID) X WHERE X.OutletCategoryID=O.CategoryID AND O.RouteID=0
		UPDATE O SET TotalStores=X.TotalOutlet FROM #tblOutletSummary O ,(SELECT RouteID,OutletCategoryID,COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails GROUP BY RouteID,OutletCategoryID) X WHERE X.RouteID=O.RouteID AND O.CategoryID=X.OutletCategoryID

		-- Approved Stores
		UPDATE O SET Validated=X.TotalOutlet FROM #tblOutletSummary O ,(SELECT OutletCategoryID,COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails WHERE flgStoreValidated=1 GROUP BY OutletCategoryID) X WHERE X.OutletCategoryID=O.CategoryID AND O.RouteID=0
		UPDATE O SET Validated=X.TotalOutlet FROM #tblOutletSummary O ,(SELECT RouteID,OutletCategoryID,COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails WHERE flgStoreValidated=1 GROUP BY RouteID,OutletCategoryID) X WHERE X.RouteID=O.RouteID AND O.CategoryID=X.OutletCategoryID

		-- Pending Stores
		UPDATE O SET Pending=TotalStores-Validated FROM #tblOutletSummary O

		SELECT  Category Header,Routename Child,TotalStores,Validated,Pending FROM #tblOutletSummary ORDER BY CategoryID,RouteID
		INSERT INTO #tblOverAllOutletSummary(Header,Child)
		SELECT 'OverAll' Header,'OverAll' Child

		UPDATE O SET TotalStores=X.TotalOutlet FROM #tblOverAllOutletSummary O ,(SELECT COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails) X
		UPDATE O SET Validated=X.TotalOutlet FROM #tblOverAllOutletSummary O ,(SELECT COUNT(StoreIdDB) TotalOutlet FROM #tmpStoreDetails WHERE flgStoreValidated=1) X
		UPDATE O SET Pending=TotalStores-Validated FROM #tblOverAllOutletSummary O

		SELECT * FROM #tblOverAllOutletSummary
		--SELECT 'OverAll' Header,'OverAll' Child,SUM(TotalStores) TotalStores,SUM(Validated) Validated,SUM(Pending) Pending FROM #tblOutletSummary
	END
		
	

END
