
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 21-Sep-2015
-- Description:	Sp to get the store details capture from PDA
--z =============================================
--exec [SpRptGet_SyncStoreDetails] 1,100,0,0,0,0,999,1
CREATE PROCEDURE [dbo].[SpRptGet_SyncStoreDetails] 
@NodeID INT,
@NodeType INT,
@PNodeID INT,
@PNodeType INT,
@PPNodeID INT,
@PPNodeType INT,
@flgStoreType INT, --all/validated/pending/rejected/Remap
@ChannelId INT=1, --1:GT,2:FS,3:MT
@DateFrom Date='01-Nov-2021'
AS
BEGIN
	DECLARE @SQL VARCHAR(MAX)
	DECLARE @strWhere VARCHAR(200)=''
	DECLARE @strWhereForApproved VARCHAR(200)=''
	SET @SQL=''

	IF @flgStoreType=999
	BEGIN
		SET @strWhere=''
		SET @strWhereForApproved=''
	END
	ELSE
	BEGIN 
		SET @strWhere=' AND ISNULL(flgStoreValidated,0)=' + CAST(@flgStoreType AS VARCHAR)
		SET @strWhereForApproved=' AND ISNULL(flgValidated,0)=' + CAST(@flgStoreType AS VARCHAR)
	END
	--DECLARE @HierTypeID TINYINT
	--SELECT @HierTypeID=HierTypeID FROM tblSecMenuContextMenu WHERE NodeType=@NodeType
	
	CREATE TABLE #tmpRsltWithFullHierarchy(RegionId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CompCovAreaId INT,CompCovAreaNodeType INT,CompCovArea VARCHAR(200),CompRouteId INT,CompRouteNodeType INT,CompRoute VARCHAR(200),DBRNodeId INT,DBRNodeType INT,DBR VARCHAR(200),TotStoreAdded INT,Approved INT,Rejected INT,ReMap INT,ApprovalPending INT)
	
	SELECT * INTO #SalesHier FROM VwCompanyDSRFullDetail

	CREATE TABLE #RouteList(RouteId INT,RouteNodeType INT)

	INSERT INTO #tmpRsltWithFullHierarchy(RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CompCovAreaId,CompCovAreaNodeType, CompCovArea,CompRouteId,CompRouteNodeType,CompRoute)
	SELECT DISTINCT RSMAreaID,RSMAreaType,RSMArea,ASMAreaID,ASMAreaNodeType,ASMArea,SOAreaID,SOAreaNodeType,SOArea,DSRAreaID,DSRAreaNodeType,DSRArea,RouteNodeId,RouteNodetype,R.Descr
	FROM #SalesHier S INNER JOIN tblRoutePlanningVisitDetail RP ON RP.CovAreaNodeID=S.DSRAreaID AND RP.CovAreaNodeType=S.DSRAreaNodeType INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=RP.RouteNodeId AND R.NodeType=RP.RouteNodetype
	WHERE RouteNodeId IS NOT NULL AND RP.VisitDate>=CAST(GETDATE() AS DATE)
	

	----SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegionID,RegionType,Region,ASMAreaID,ASMAreaType,ASMArea,SOID,SOAreaType,SOArea INTO #CompSales
	----FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN VwSalesHierarchy CS ON Map.SHNodeId=CS.SOID AND Map.SHNodeType=CS.SOAreaType	
	----WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
	----UNION ALL
	----SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegionID,RegionType,Region,ASMAreaID,ASMAreaType,ASMArea,0,0,'Direct'
	----FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN VwSalesHierarchy CS ON Map.SHNodeId=CS.ASMAreaID AND Map.SHNodeType=CS.ASMAreaType		
	----WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
	----UNION ALL
	----SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegionID,RegionType,Region,0,0,'Direct',0,0,'Direct'
	----FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN VwSalesHierarchy CS ON Map.SHNodeId=CS.RegionID AND Map.SHNodeType=CS.RegionType 
	----WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate) 

	--SELECT * FROM #CompSales
	
	----INSERT INTO #tmpRsltWithFullHierarchy(RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,DBRNodeId,DBRNodeType,DBR,DBRCovAreaId, DBRCovAreaNodeType,DBRCovArea,DBRRouteId,DBRRouteNodeType,DBRRoute)
	----SELECT ISNULL(#CompSales.RegionID,0),ISNULL(#CompSales.RegionType,100),ISNULL(#CompSales.Region,'NA'),ISNULL(#CompSales.ASMAreaId,0),ISNULL(#CompSales.ASMAreaType,110),ISNULL(#CompSales.ASMArea,'NA'),ISNULL(#CompSales.SOID,0),ISNULL(#CompSales.SOAreaType,120),ISNULL(#CompSales.SOArea,'NA'),vwDBR.DBRNodeID,vwDBR.DistributorNodeType,vwDBR.Distributor, vwDBR.DBRCoverageID,vwDBR.DBRCoverageNodeType,vwDBR.DBRCoverage,vwDBR.DBRRouteID,vwDBR.RouteNodeType,vwDBR.DBRRoute
	----FROM VwAllDistributorHierarchy vwDBR LEFT JOIN #CompSales ON vwDBR.DBRCoverageId=#CompSales.DHNodeId AND vwDBR.DBRCoverageNodeType=#CompSales.DHNodeType
	
	--SELECT * FROM #tmpRsltWithFullHierarchy ORDER BY ASMAreaId
	IF @NodeType=0  --Full
	BEGIN
		INSERT INTO #RouteList(RouteId,RouteNodeType)
		SELECT DISTINCT CompRouteId,CompRouteNodeType
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL
		--UNION
		--SELECT DISTINCT DBRRouteId,DBRRouteNodeType
		--FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL
	END
	ELSE IF @NodeType=95  --Country
	BEGIN
		INSERT INTO #RouteList(RouteId,RouteNodeType)
		SELECT DISTINCT CompRouteId,CompRouteNodeType
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL 
		--UNION
		--SELECT DISTINCT DBRRouteId,DBRRouteNodeType
		--FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL
	END
	ELSE IF @NodeType=100 --Region
	BEGIN
		INSERT INTO #RouteList(RouteId,RouteNodeType)
		SELECT DISTINCT CompRouteId,CompRouteNodeType
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL AND RegionId=@NodeId
		--UNION
		--SELECT DISTINCT DBRRouteId,DBRRouteNodeType
		--FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND RegionId=@NodeId
	END
	ELSE IF @NodeType=110  -- ASM Area
	BEGIN
		INSERT INTO #RouteList(RouteId,RouteNodeType)
		SELECT DISTINCT CompRouteId,CompRouteNodeType
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL AND ASMAreaId=@NodeId AND RegionId=@PNodeId
		--UNION
		--SELECT DISTINCT DBRRouteId,DBRRouteNodeType
		--FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND ASMAreaId=@NodeId AND RegionId=@PNodeId
	END
	ELSE IF @NodeType=120  -- SO Area
	BEGIN
		INSERT INTO #RouteList(RouteId,RouteNodeType)
		SELECT DISTINCT CompRouteId,CompRouteNodeType
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL AND SOAreaId=@NodeId AND ASMAreaId=@PNodeId AND RegionId=@PPNodeId
		--UNION
		--SELECT DISTINCT DBRRouteId,DBRRouteNodeType
		--FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND SOAreaId=@NodeId AND ASMAreaId=@PNodeId AND RegionId=@PPNodeId
	END
	ELSE IF @NodeType=130  -- Company Salesman Coverage Area
	BEGIN
		INSERT INTO #RouteList(RouteId,RouteNodeType)
		SELECT DISTINCT CompRouteId,CompRouteNodeType
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL AND CompCovAreaId=@NodeId AND SOAreaId=@PNodeId AND ASMAreaId=@PPNodeId
		--UNION
		--SELECT DISTINCT DBRRouteId,DBRRouteNodeType
		--FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND CompCovAreaId=@NodeId AND SOAreaId=@PNodeId AND ASMAreaId=@PPNodeId
	END
	ELSE IF @NodeType=140  -- Company Sales Route
	BEGIN
		INSERT INTO #RouteList(RouteId,RouteNodeType)
		SELECT @NodeId,@NodeType
	END
	----ELSE IF @NodeType=150  -- Distributor
	----BEGIN
	----	INSERT INTO #RouteList(RouteId,RouteNodeType)
	----	--SELECT DISTINCT CompRouteId,CompRouteNodeType
	----	--FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL AND DBRNodeId=@NodeId AND SOAreaId=@PNodeId AND ASMAreaId=@PPNodeId
	----	--UNION
	----	SELECT DISTINCT DBRRouteId,DBRRouteNodeType
	----	FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND DBRNodeId=@NodeId AND SOAreaId=@PNodeId AND ASMAreaId=@PPNodeId
	----END
	----ELSE IF @NodeType=160  -- DBR Coverage Area
	----BEGIN
	----	INSERT INTO #RouteList(RouteId,RouteNodeType)
	----	SELECT DISTINCT DBRRouteId,DBRRouteNodeType
	----	FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND DBRCovAreaId=@NodeId AND DBRNodeId=@PNodeId AND SOAreaId=@PPNodeId
	----END
	----ELSE IF @NodeType=170  -- DBR Route
	----BEGIN
	----	INSERT INTO #RouteList(RouteId,RouteNodeType)
	----	SELECT @NodeId,@NodeType
	----	--SELECT DISTINCT DBRRouteId,DBRRouteNodeType
	----	--FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND DBRRouteId=@NodeId AND DBRCovAreaId=@PNodeId AND DBRNodeId=@PPNodeId
	----END
	--SELECT * FROM #RouteList

	IF @ChannelId=1 --GT
	BEGIN
		CREATE TABLE #tblStoreList_GT (StoreIDDB INT,OrgStoreId INT,[Store Info] VARCHAR(2000),[Store Details] VARCHAR(2000),[Owner Info] VARCHAR(2000),[Owner Details] VARCHAR(2000),LatCode NUMERIC(26,22),LonCode NUMERIC(26,22),[Store Category] VARCHAR(500),[Store Type] VARCHAR(2000),RouteId VARCHAR(200), FlgForInactiveRoute TINYINT DEFAULT 0,FlgApproved TINYINT,[New/Old] VARCHAR(20),[Created Date] VARCHAR(20),[Payment Stage] VARCHAR(50))

		----SET @SQL='INSERT INTO #tblStoreList_GT(StoreIDDB,OrgStoreId,[Store Info],[Store Details],[Owner Info],[Owner Details],[Store Category],[Annual Business] ,[LT Foods],[DB Billed],LatCode,LonCode,FlgApproved,[Created Date],[Payment Stage])
		----SELECT P.StoreIDDB,0,ISNULL(V.StoreCategory,'''') ,
		----OutletName + ''~'' +ISNULL(StoreAdd.Address,'''') + ''~'' + ISNULL(StoreAdd.City,'''')  +''~'' +ISNULL(CAST(StoreAdd.State AS VARCHAR),'''') +''~'' +ISNULL(CAST(StoreAdd.Pincode AS VARCHAR),''''),
		----ISNULL(StoreCont.Ownername,'''') +''$Contact-'' + ISNULL(CAST(StoreCont.OwnerMobNo AS VARCHAR),'''') +''$Email-'' + ISNULL(StoreCont.OwnerEmailID,''''),
		----ISNULL(StoreCont.Ownername,'''') +''~'' + ISNULL(CAST(StoreCont.OwnerMobNo AS VARCHAR),'''') +''~'' + ISNULL(StoreCont.OwnerEmailID,''''),ISNULL(V.StoreCategory,''NA'') + ''^'' + CAST(ISNULL(V.NodeID,0) AS VARCHAR) ,I.IndustryClassification,CASE StoreAttr.IsLTStock WHEN 1 THEN ''Yes'' ELSE ''NO'' END IsLTStock,CASE StoreAttr.IsDBBilled WHEN 1 THEN ''Yes'' ELSE ''NO'' END IsDBBilled,P.ActualLatitude,P.ActualLongitude,ISNULL(flgStoreValidated,0),dbo.fncUtlDateString(P.VisitEndTS),CASE StoreAttr.PaymentStage WHEN 2 THEN ''On Delivery'' WHEN 3 THEN ''Credit'' END
		----FROM [tblPDASyncStoreMappingMstr] P INNER JOIN #RouteList ON P.RouteId=#RouteList.RouteId AND P.RouteNodetype=#RouteList.RouteNodeType
		----INNER JOIN tblPDASyncStoreattributeDet StoreAttr ON StoreAttr.StoreIDDB=P.StoreIDDB
		----LEFT OUTER JOIN tblPDASyncAddressDet StoreAdd ON StoreAdd.StoreIDDB=P.StoreIDDB
		----LEFT OUTER JOIN tblPDASyncContDet StoreCont ON StoreCont.StoreIDDB=P.StoreIDDB		
		----LEFT OUTER JOIN tblStoreCategoryMstr V ON V.NodeID=StoreAttr.OutletCategory
		----LEFT OUTER JOIN tblIndustryClassificationMstr I ON I.IndustryClassificationID=StoreAttr.OutletBusiness
		------LEFT OUTER JOIN tblDBRSalesStructureRouteMstr R ON R.NodeID=P.RouteID
		----WHERE P.FlgActive=1 AND ISNULL(P.OrgStoreId,0)=0 AND StoreAttr.OutletChannelId=' + CAST(@ChannelId AS VARCHAR) + @strWhere		
		----PRINT @SQL
		----EXEC (@SQL)
		
		--from final table
		INSERT INTO #tblStoreList_GT(StoreIDDB,OrgStoreId,[Store Info],[Store Details],[Owner Info],[Owner Details],[Store Category],[Store Type] ,LatCode,LonCode,FlgApproved,[New/Old],[Created Date],[Payment Stage])	
		SELECT DISTINCT SM.StoreId,SM.StoreId,ISNULL(V.SubChannel,'') ,
		SM.StoreName + '~' +ISNULL(StoreAdd.StoreAddress1,'') + '~' + ISNULL(StoreAdd.City,'')  +'~' +ISNULL(CAST(StoreAdd.State AS VARCHAR),'') +'~' +ISNULL(CAST(StoreAdd.Pincode AS VARCHAR),''),
		ISNULL(StoreCont.FName,'') +'$Contact-' + ISNULL(CAST(StoreCont.MobNo AS VARCHAR),''),
		ISNULL(StoreCont.FName,'') +'~' + ISNULL(CAST(StoreCont.MobNo AS VARCHAR),'') +'~' + ISNULL(StoreCont.EMailID,''),ISNULL(V.SubChannel,'NA') + '^' + CAST(ISNULL(V.SubChannelId,0) AS VARCHAR) ,I.StoreSegment,SM.[Lat Code],SM.[Long Code],ISNULL(flgvalidated,0),CASE ISNULL(SM.StoreIdDB,0) WHEN 0 THEN 'OLD' ELSE 'NEW' END ,dbo.fncUtlDateString(SM.CreatedDate),'On Delivery'	
		FROM [tblStoreMaster] SM INNER JOIN tblRouteCoverageStoreMapping RCM ON SM.StoreId=RCM.StoreId 
		INNER JOIN #RouteList R ON RCM.RouteId=R.RouteId AND RCM.RouteNodetype=R.RouteNodeType
		LEFT OUTER JOIN tblOutletAddressDet StoreAdd ON StoreAdd.StoreID=SM.StoreID AND StoreAdd.OutAddTypeID=1
		LEFT OUTER JOIN tblOutletContactDet StoreCont ON StoreCont.StoreID=SM.StoreID AND StoreCont.OutCnctpersonTypeID=1
		LEFT OUTER JOIN tblMstrSUBChannel V ON V.SubChannelId=SM.SubChannelId
		LEFT OUTER JOIN tblMstrStoreSegment I ON I.StoreSegmentationID=SM.SegmentationID
		WHERE SM.FlgActive=1 AND (CAST(GETDATE() AS DATE) BETWEEN RCM.FromDate AND RCM.ToDate)  AND CASE @flgStoreType WHEN 999 THEN 0 ELSE  @flgStoreType END =ISNULL(flgValidated,0)	
		

		DELETE S FROM #tblStoreList_GT S WHERE ISNULL([Created Date],'01-Nov-2021')<@DateFrom		
		

		--SELECT P.StoreIDDB,P.StoreImagename,P.ImageType,P.flgmanagerUploaded  INTO #GT_Images
		--FROM #tblStoreList_GT S INNER JOIN tblPDASyncStoreImages P ON P.StoreIDDB=S.StoreIDDB WHERE S.OrgStoreId=0 --Images
		--UNION
		SELECT S.StoreIDDB,P.StoreImagename,P.ImageType,P.flgmanagerUploaded  INTO #GT_Images
		FROM #tblStoreList_GT S INNER JOIN tblStoreImages P ON P.StoreID=S.OrgStoreId  --Images

		----SELECT A.StoreId,MAX(SurveyDate) SurveyDate INTO #LastSurveyDate
		----FROM tblStoreProductCategoryCompetitorSurvey_GT A INNER JOIN #tblStoreList_GT S ON A.StoreId=S.OrgStoreId
		----GROUP BY A.StoreId

		----SELECT P.StoreIDDB,O.OptionDescr,REPLACE(SUBSTRING(P.Competitor,0,LEN(P.Competitor)),'^',',') Competitorbrand INTO #Gt_Competitorbrand
		----FROM #tblStoreList_GT S INNER JOIN tblPDASync_CategoryCompetitor P ON P.StoreIDDB=S.StoreIDDB
		----INNER JOIN tblDynamic_PDAQuestOptionMstr O ON P.ProductCategoryAvailable=O.AnsVal  -- Competitors
		----WHERE O.QuestID=11 AND S.OrgStoreId=0
		----UNION
		----SELECT S.StoreIDDB,O.OptionDescr,REPLACE(SUBSTRING(P.CompetitorBrand,0,LEN(P.CompetitorBrand)),'^',',') Competitorbrand 
		----FROM #tblStoreList_GT S INNER JOIN tblStoreProductCategoryCompetitorSurvey_GT P ON P.StoreID=S.OrgStoreId
		----INNER JOIN #LastSurveyDate D ON P.StoreId=D.StoreId AND P.SurveyDate=D.SurveyDate
		----INNER JOIN tblDynamic_PDAQuestOptionMstr O ON P.ProductCategoryAvailable=O.AnsVal  -- Competitors
		----WHERE O.QuestID=11


		ALTER TABLE #tblStoreList_GT DROP COLUMN orgStoreId
	
		SELECT * FROM #tblStoreList_GT ORDER BY FlgApproved,StoreIdDB desc

		SELECT * FROM #GT_Images
		--SELECT * FROM #Gt_Competitorbrand
	END
	

END


