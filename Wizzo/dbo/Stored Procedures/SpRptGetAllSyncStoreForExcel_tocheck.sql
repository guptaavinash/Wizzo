-- =============================================
-- Author:		Avinash Gupta
-- Create date: 21-Sep-2015
-- Description:	Sp to get the store details capture from PDA
--z =============================================
--exec [SpRptGetAllSyncStoreForExcel] 0,0,0,0,0,0,999,1
CREATE PROCEDURE [dbo].[SpRptGetAllSyncStoreForExcel_tocheck] 
@NodeID INT=0,
@NodeType INT=0,
@PNodeID INT=0,
@PNodeType INT=0,
@PPNodeID INT=0,
@PPNodeType INT=0,
@flgStoreType INT=999, --all/validated/pending/rejected/Remap
@ChannelId INT=1, --1:GT,2:FS,3:MT,
@DateFrom Date ='01-Jan-2021'

AS
BEGIN
	DECLARE @Counter INT
	DECLARE @MaxCount INT
	DECLARE @Sql VARCHAR(5000)
	DECLARE @CategoryId INT
	DECLARE @QuestId INT
	DECLARE @Category VARCHAR(200)
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

	CREATE TABLE #tmpRsltWithFullHierarchy(RegionId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CompCovAreaId INT,CompCovAreaNodeType INT,CompCovArea VARCHAR(200),CompRouteId INT,CompRouteNodeType INT,CompRoute VARCHAR(200),DBRNodeId INT,DBRNodeType INT,DBR VARCHAR(200),DBRCovAreaId INT,DBRCovAreaNodeType INT,DBRCovArea VARCHAR(200),DBRRouteId INT,DBRRouteNodeType INT,DBRRoute VARCHAR(200),TotStoreAdded INT,Approved INT,Rejected INT,ReMap INT,ApprovalPending INT)
	
	CREATE TABLE #RouteList(RouteId INT,RouteNodeType INT)
	SELECT * INTO #SalesHier FROM VwCompanyDSRFullDetail
	INSERT INTO #tmpRsltWithFullHierarchy(RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CompCovAreaId,CompCovAreaNodeType, CompCovArea,CompRouteId,CompRouteNodeType,CompRoute)
	SELECT DISTINCT RSMAreaID,RSMAreaType,RSMArea,ASMAreaID,ASMAreaNodeType,ASMArea,SOAreaID,SOAreaNodeType,SOArea,DSRAreaID,DSRAreaNodeType,DSRArea,RouteNodeId,RouteNodetype,R.Descr
	FROM #SalesHier S INNER JOIN tblRoutePlanningVisitDetail RP ON RP.CovAreaNodeID=S.DSRAreaID AND RP.CovAreaNodeType=S.DSRAreaNodeType INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=RP.RouteNodeId AND R.NodeType=RP.RouteNodetype
	WHERE RouteNodeId IS NOT NULL --AND RP.VisitDate>=CAST(GETDATE() AS DATE)

	SELECT * FROM #tmpRsltWithFullHierarchy WHERE CompRouteId=49421

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
	
	  UPDATE A SET A.Region=Region  + '(' + ISNULL(AA.Person,'Vacant') + ')'  FROM #tmpRsltWithFullHierarchy A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.NodeId AS PersonId,C.Descr AS Person FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=100) AA
    ON A.RegionId=AA.NodeId AND A.RegionNodeType=AA.NodeType
	
	 UPDATE A SET A.ASMArea=ASMArea  + '(' + ISNULL(AA.Person,'Vacant') + ')'  FROM #tmpRsltWithFullHierarchy A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.NodeId AS PersonId,C.Descr AS Person FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=110) AA
    ON A.ASMAreaId=AA.NodeId AND A.ASMAreaNodeType=AA.NodeType

	 UPDATE A SET A.SOArea=SOArea  + '(' + ISNULL(AA.Person,'Vacant') + ')'  FROM #tmpRsltWithFullHierarchy A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.NodeId AS PersonId,C.Descr AS Person FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=120) AA
    ON A.SOAreaId=AA.NodeId AND A.SOAreaNodeType=AA.NodeType

	--SELECT * FROM #tmpRsltWithFullHierarchy ORDER BY ASMAreaId

	CREATE TABLE #RsltRouteList(Region VARCHAR(200),ASMArea VARCHAR(200),SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,[Coverage Area] VARCHAR(200),RouteId INT,RouteNodeType INT,[Route] VARCHAR(200))

	IF @NodeType=0 OR @NodeType=95
	BEGIN
		INSERT INTO #RsltRouteList(Region,ASMArea,SOArea,CovAreaId,CovAreaNodeType,[Coverage Area],RouteId,RouteNodeType,[Route])
		SELECT Region,ASMArea,SOArea,DBRCovAreaId AS CovAreaId,DBRCovAreaNodeType AS CovAreaNodeType,DBRCovArea AS [Coverage Area],DBRRouteId AS RouteId,DBRRouteNodeType AS RouteNodeType,DBRRoute AS [Route] --INTO #RsltRouteList
		FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL
		UNION
		SELECT Region,ASMArea,SOArea,CompCovAreaId,CompCovAreaNodeType,CompCovArea AS [Coverage Area],CompRouteId,CompRouteNodeType,CompRoute AS [Route]
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL
	END
	ELSE IF @NodeType=100
	BEGIN
		INSERT INTO #RsltRouteList(Region,ASMArea,SOArea,CovAreaId,CovAreaNodeType,[Coverage Area],RouteId,RouteNodeType,[Route])
		SELECT Region,ASMArea,SOArea,DBRCovAreaId AS CovAreaId,DBRCovAreaNodeType AS CovAreaNodeType,DBRCovArea AS [Coverage Area],DBRRouteId AS RouteId,DBRRouteNodeType AS RouteNodeType,DBRRoute AS [Route] --INTO #RsltRouteList
		FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND RegionId=@NodeId
		UNION
		SELECT Region,ASMArea,SOArea,CompCovAreaId,CompCovAreaNodeType,CompCovArea AS [Coverage Area],CompRouteId,CompRouteNodeType,CompRoute AS [Route]
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL AND RegionId=@NodeId
	END
	ELSE IF @NodeType=110
	BEGIN
		INSERT INTO #RsltRouteList(Region,ASMArea,SOArea,CovAreaId,CovAreaNodeType,[Coverage Area],RouteId,RouteNodeType,[Route])
		SELECT Region,ASMArea,SOArea,DBRCovAreaId AS CovAreaId,DBRCovAreaNodeType AS CovAreaNodeType,DBRCovArea AS [Coverage Area],DBRRouteId AS RouteId,DBRRouteNodeType AS RouteNodeType,DBRRoute AS [Route] --INTO #RsltRouteList
		FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND ASMAreaId=@NodeId AND RegionId=@PNodeId
		UNION
		SELECT Region,ASMArea,SOArea,CompCovAreaId,CompCovAreaNodeType,CompCovArea AS [Coverage Area],CompRouteId,CompRouteNodeType,CompRoute AS [Route]
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL AND ASMAreaId=@NodeId AND RegionId=@PNodeId
	END
	ELSE IF @NodeType=120
	BEGIN
		INSERT INTO #RsltRouteList(Region,ASMArea,SOArea,CovAreaId,CovAreaNodeType,[Coverage Area],RouteId,RouteNodeType,[Route])
		SELECT Region,ASMArea,SOArea,DBRCovAreaId AS CovAreaId,DBRCovAreaNodeType AS CovAreaNodeType,DBRCovArea AS [Coverage Area],DBRRouteId AS RouteId,DBRRouteNodeType AS RouteNodeType,DBRRoute AS [Route] --INTO #RsltRouteList
		FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND SOAreaId=@NodeId AND ASMAreaId=@PNodeId AND RegionId=@PPNodeId
		UNION
		SELECT Region,ASMArea,SOArea,CompCovAreaId,CompCovAreaNodeType,CompCovArea AS [Coverage Area],CompRouteId,CompRouteNodeType,CompRoute AS [Route]
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL AND SOAreaId=@NodeId AND ASMAreaId=@PNodeId AND RegionId=@PPNodeId
	END
	ELSE IF @NodeType=130
	BEGIN
		INSERT INTO #RsltRouteList(Region,ASMArea,SOArea,CovAreaId,CovAreaNodeType,[Coverage Area],RouteId,RouteNodeType,[Route])
		SELECT Region,ASMArea,SOArea,DBRCovAreaId AS CovAreaId,DBRCovAreaNodeType AS CovAreaNodeType,DBRCovArea AS [Coverage Area],DBRRouteId AS RouteId,DBRRouteNodeType AS RouteNodeType,DBRRoute AS [Route] --INTO #RsltRouteList
		FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND CompCovAreaId=@NodeId AND SOAreaId=@PNodeId AND ASMAreaId=@PPNodeId
		UNION
		SELECT Region,ASMArea,SOArea,CompCovAreaId,CompCovAreaNodeType,CompCovArea AS [Coverage Area],CompRouteId,CompRouteNodeType,CompRoute AS [Route]
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL AND CompCovAreaId=@NodeId AND SOAreaId=@PNodeId AND ASMAreaId=@PPNodeId
	END
	ELSE IF @NodeType=140
	BEGIN
		INSERT INTO #RsltRouteList(Region,ASMArea,SOArea,CovAreaId,CovAreaNodeType,[Coverage Area],RouteId,RouteNodeType,[Route])
		SELECT Region,ASMArea,SOArea,CompCovAreaId,CompCovAreaNodeType,CompCovArea AS [Coverage Area],CompRouteId,CompRouteNodeType,CompRoute AS [Route]
		FROM #tmpRsltWithFullHierarchy WHERE CompRouteId IS NOT NULL AND CompRouteId=@NodeId AND CompRouteNodeType=@NodeType
	END
	ELSE IF @NodeType=150
	BEGIN
		INSERT INTO #RsltRouteList(Region,ASMArea,SOArea,CovAreaId,CovAreaNodeType,[Coverage Area],RouteId,RouteNodeType,[Route])
		SELECT Region,ASMArea,SOArea,DBRCovAreaId,DBRCovAreaNodeType,DBRCovArea,DBRRouteId,DBRRouteNodeType,DBRRoute
		FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND DBRNodeId=@NodeId AND SOAreaId=@PNodeId AND ASMAreaId=@PPNodeId
	END
	ELSE IF @NodeType=160
	BEGIN
		INSERT INTO #RsltRouteList(Region,ASMArea,SOArea,CovAreaId,CovAreaNodeType,[Coverage Area],RouteId,RouteNodeType,[Route])
		SELECT Region,ASMArea,SOArea,DBRCovAreaId,DBRCovAreaNodeType,DBRCovArea,DBRRouteId,DBRRouteNodeType,DBRRoute
		FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND DBRCovAreaId=@NodeId AND DBRNodeId=@PNodeId AND SOAreaId=@PPNodeId
	END
	ELSE IF @NodeType=170
	BEGIN
		INSERT INTO #RsltRouteList(Region,ASMArea,SOArea,CovAreaId,CovAreaNodeType,[Coverage Area],RouteId,RouteNodeType,[Route])
		SELECT Region,ASMArea,SOArea,DBRCovAreaId,DBRCovAreaNodeType,DBRCovArea,DBRRouteId,DBRRouteNodeType,DBRRoute
		FROM #tmpRsltWithFullHierarchy WHERE DBRRouteId IS NOT NULL AND DBRRouteId=@NodeId AND DBRRouteNodeType=@NodeType
	END
	
	 UPDATE A SET A.[Coverage Area]=[Coverage Area]  + '(' + ISNULL(AA.Person,'Vacant') + ')'  FROM #RsltRouteList A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.NodeId AS PersonId,C.Descr AS Person FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType IN(130,160)) AA
    ON A.CovAreaId=AA.NodeId AND A.CovAreaNodeType=AA.NodeType
	
	--SELECT * FROM #RsltRouteList
	--SELECT R.Region,R.ASMArea AS [ASM Area],R.SOArea AS [SO Area],[Coverage Area],[Route],P.StoreIDDB,OutletName + '~' + ISNULL(StoreAdd.Address,'') + '~' + ISNULL(P.City,'')  +'~' +ISNULL(CAST(P.State AS VARCHAR),'') + '~' + ISNULL(CAST(P.Pincode AS VARCHAR),'') AS [Store Details],ISNULL(StoreCont.Ownername,'') + '$Contact-' + ISNULL(CAST(StoreCont.OwnerMobNo AS VARCHAR),'') + '$Email-' + ISNULL(StoreCont.OwnerEmailID,'') AS [Owner Info],ISNULL(V.StoreCategory,'NA') AS [Store Category],ISNULL(I.IndustryClassification,'NA') AS [Annual Business],CASE StoreAttr.IsLTStock WHEN 1 THEN 'Yes' ELSE 'NO' END [LT Foods],CASE StoreAttr.IsDBBilled WHEN 1 THEN 'Yes' ELSE 'NO' END [DB Billed],CASE StoreAttr.PaymentStage WHEN 2 THEN 'On Delivery' WHEN 3 THEN 'Credit' ELSE 'NA' END AS [Payment Stage],dbo.fncUtlDateString(P.VisitEndTS) AS [Created Date],CASE ISNULL(flgStoreValidated,0) WHEN 0 THEN 'Approval Pending' WHEN 1 THEN 'Approved' WHEN 2 THEN 'Rejected' WHEN 3 THEN 'ReMap' END AS Status INTO #tblStoreList_GT

	IF @ChannelId=1 --GT
	BEGIN
		CREATE TABLE #tblStoreList_GT (Region VARCHAR(200),[ASM Area] VARCHAR(200),[SO Area] VARCHAR(200),[Coverage Area] VARCHAR(200),Route VARCHAR(200),DIstributorCode VARCHAR(20),DistributorName VARCHAR(200),RouteCode VARCHAR(20),RouteName VARCHAR(100),CoveredBy VARCHAR(50),StoreIDDB INT,StoreID INT,[Store Code] VARCHAR(20),[Store Name] VARCHAR(200),[Store Address] VARCHAR(500),City VARCHAR(200),State VARCHAR(200),[Pin Code] VARCHAR(200),[Owner Name] VARCHAR(200),[Contact No] VARCHAR(20),[Store Category] VARCHAR(500),[Store Segment] VARCHAR(500),[Lat Code] VARCHAR(50),[Long Code] VARCHAR(50),[New/Old] VARCHAR(10),[Created Date] VARCHAR(20),[Status] VARCHAR(50),[FirstProductive] Date)

		--from final table
		--INSERT INTO #tblStoreList_GT(Region,[ASM Area],[SO Area],[Coverage Area],RouteCode,Route,DIstributorCode,DistributorName,CoveredBy,
		--StoreIDDB,StoreID,[Store Code],[Store Name],[Store Address],City,State,[Pin Code],[Owner Name],[Contact No],[Store Category],[Store Segment],[Lat Code],[Long Code],[New/Old],[Created Date],[Status])	
		SELECT DISTINCT R.Region,R.ASMArea AS [ASM Area],R.SOArea AS [SO Area],[Coverage Area],[Route]
		--,ISNULL(P.Descr,'Not COvered')
		,SM.StoreIdDB,SM.StoreId,SM.StoreCode,
		--SM.StoreName AS [Store Name] ISNULL(StoreAdd.City,'') AS City,ISNULL(CAST(StoreAdd.State AS VARCHAR),'') State,ISNULL(CAST(StoreAdd.Pincode AS VARCHAR),'') AS [Pin Code],ISNULL(StoreCont.FName,'') [Owner Name],ISNULL(CAST(StoreCont.MobNo AS VARCHAR),'''') [Contact No],
		--ISNULL(V.SubChannel,'NA') AS [Store Category],ISNULL(I.StoreSegment,'NA'),
		SM.[Lat Code],SM.[Long Code],CASE ISNULL(StoreIDDB,0) WHEN 0 THEN 'Old' ELSE 'New' END,dbo.fncUtlDateString(SM.TimeStampIns) AS [Created Date],CASE ISNULL(SM.flgValidated,0) WHEN 0 THEN 'Approval Pending' WHEN 1 THEN 'Approved' WHEN 2 THEN 'Rejected' WHEN 3 THEN 'ReMap' END AS Status
		FROM [tblStoreMaster] SM 
		INNER JOIN tblRouteCoverageStoreMapping RCM ON SM.StoreId=RCM.StoreId 
		INNER JOIN #RsltRouteList R ON RCM.RouteId=R.RouteId AND RCM.RouteNodetype=R.RouteNodeType
		--LEFT OUTER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=SM.DistNodeId AND DBR.NodeType=SM.DistNodeType
		--LEFT OUTER JOIN tblCompanySalesStructureRouteMstr RM ON RM.NodeID=R.RouteID AND RM.NodeType=R.RouteNodeType
		--LEFT OUTER JOIN tblSalespersonmapping PM ON PM.NodeID=R.CovAreaId AND PM.NodeType=R.CovAreaNodeType AND CAST(GETDATE() AS DATE) BETWEEN PM.FromDate AND PM.ToDate LEFT OUTER JOIN tblMstrPerson P ON P.NodeID=PM.PersonNodeID 
		--LEFT OUTER JOIN tblOutletAddressDet StoreAdd ON StoreAdd.StoreID=SM.StoreID AND StoreAdd.OutAddTypeID=1
		--LEFT OUTER JOIN tblOutletContactDet StoreCont ON StoreCont.StoreID=SM.StoreID AND StoreCont.OutCnctpersonTypeID=1
		--LEFT OUTER JOIN tblMstrSUBChannel V ON V.SubChannelId=SM.SubChannelId
		--LEFT OUTER JOIN tblMstrStoreSegment I ON I.StoreSegmentationID=SM.SegmentationID
		--WHERE SM.FlgActive=1 AND (CAST(GETDATE() AS DATE) BETWEEN RCM.FromDate AND RCM.ToDate)  
		--AND CASE @flgStoreType WHEN 999 THEN 0 ELSE  @flgStoreType END =ISNULL(flgValidated,0)
		WHERE SM.StoreID=60535
		
		SELECT * FROM #RsltRouteList WHERE RouteId=49421
		---SELECT 		* FROM #tblStoreList_GT WHERE StoreID=82659


		UPDATE S SET [FirstProductive]=X.FirstOrder FROM #tblStoreList_GT S ,(SELECT StoreID,MIN(OrderDAte) FirstOrder FROM tblOrderMaster GROUP BY StoreID) X WHERE X.StoreID=S.StoreID


		--DELETE S FROM #tblStoreList_GT S WHERE CAST(ISNULL([Created Date],'01-Nov-2021') AS DATE)<@DateFrom


		CREATE TABLE #CompetitorBrands(ID INT IDENTITY(1,1),CategoryId INT,Category VARCHAR(200))

		----INSERT INTO #CompetitorBrands(CategoryId,Category)
		----SELECT AnsVal,OptionDescr
		----FROM tblDynamic_PDAQuestOptionMstr
		----WHERE  Questid=11
		----ORDER BY Sequence

		--SELECT * FROM #CompetitorBrands
	
		----SELECT P.StoreIDDB,O.AnsVal AS CategoryId,O.OptionDescr AS Category,REPLACE(SUBSTRING(P.Competitor,0,LEN(P.Competitor)),'^',',') Competitorbrand  INTO #OtherCompetitorBrandDetails
		----FROM #tblStoreList_GT S INNER JOIN tblPDASync_CategoryCompetitor P ON P.StoreIDDB=S.StoreIDDB
		----INNER JOIN tblDynamic_PDAQuestOptionMstr O ON P.ProductCategoryAvailable=O.AnsVal  -- Competitors
		----WHERE O.QuestID=11
		------SELECT * FROM #OtherCompetitorBrandDetails ORDER BY StoreIDDB

		----SELECT @Counter=1
		----SELECT @MaxCount=MAX(Id) FROM #CompetitorBrands

		----WHILE @Counter<=@MaxCount
		----BEGIN
		----	SELECT @CategoryId=CategoryId,@Category=Category FROM #CompetitorBrands WHERE Id=@Counter

		----	SELECT @Sql='ALTER TABLE #tblStoreList_GT ADD [Other ' + @Category + ' Brands] VARCHAR(500) DEFAULT '''' NOT NULl'
		----	PRINT @Sql
		----	EXEC (@Sql)

		----	SELECT @Sql='UPDATE A SET A.[Other ' + @Category + ' Brands]=B.Competitorbrand FROM #tblStoreList_GT A INNER JOIN #OtherCompetitorBrandDetails B ON A.StoreIDDB=B.StoreIDDB WHERE B.CategoryId=' +CAST(@CategoryId AS VARCHAR)
		----	PRINT @Sql
		----	EXEC (@Sql)

		----	SET @Counter+=1
		----END

		--ALTER TABLE #tblStoreList_GT DROP COLUMN StoreIDDB
		SELECT Region,[ASM Area],[Coverage Area],DIstributorCode,DistributorName,RouteCode,Route,CoveredBy,StoreID,[Store Code],[Store Name],[Store Address],City,State,[Pin Code],[Owner Name],[Contact No],[Store Category],[Store Segment],[Lat Code],[Long Code],[New/Old],[Created Date],[FirstProductive] [FirstProductive Date],Status FROM #tblStoreList_GT 
		--ORDER BY StoreIdDB desc
		ORDER BY Region,[ASM Area],[SO Area],[Coverage Area],[Route]
	END

END

