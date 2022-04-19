-- [SpPDAMasterFlags] '8BBDDE4E-E06D-4F75-A75F-E4941B438619'

CREATE PROCEDURE [dbo].[SpPDAMasterFlags] 
	@PDACode VARCHAR(50)=''
AS
BEGIN
DECLARE @HierTypeID INT
DECLARE @DeviceID INT,@PersonNodeID INT,@PersonNodetype INT
--SELECT @DeviceID=U.PDAID,@PersonNodeID=U.PersonID,@PersonNodetype=U.PersonType FROM [dbo].[tblPDA_UserMapMaster] U INNER JOIN [dbo].[tblPDAMaster] P ON U.PDAID=P.PDAID WHERE (PDA_IMEI=@IMEIno OR PDA_IMEI_Sec= @IMEIno) AND GETDATE() BETWEEN U.DateFrom AND U.DateTo

SELECT @PersonNodeID=NodeID,@PersonNodetype=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

DECLARE @SalesAreaNodeType INT=0
SELECT @SalesAreaNodeType=ISNULL(MIN(SP.NodeType),0)
	FROM tblSalesPersonMapping SP
	WHERE SP.PersonNodeID=@PersonNodeID AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)
	PRINT 'SalesAreaNodeType-' + CAST(@SalesAreaNodeType AS VARCHAR)

PRINT '1=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
CREATE TABLE #SalesAreas(SalesAreaNodeId INT,SalesAreaNodeType INT)
INSERT INTO #SalesAreas(SalesAreaNodeId,SalesAreaNodeType)
SELECT SP.NodeID,SP.NodeType
FROM tblSalesPersonMapping SP
WHERE SP.PersonNodeID=@PersonNodeID AND SP.PersonType=@PersonNodetype AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate) AND SP.NodeType=@SalesAreaNodeType
--select * from #SalesAreas

/*
CREATE TABLE #tmpRslt(NodeId INT,NodeType INT,PNodeId INT,PNodeType INT,PPNodeId INT,PPNodeType INT,[Sales Area] VARCHAR(200),Lvl TINYINT)

CREATE TABLE #tmpRsltWithFullHierarchy(ZoneID INT,ZoneType INT,Zone VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CompCovAreaId INT,CompCovAreaNodeType INT,CompCovArea VARCHAR(200),CompRouteId INT,CompRouteNodeType INT,CompRoute VARCHAR(200),DBRNodeId INT,DBRNodeType INT,DBR VARCHAR(200),DBRCovAreaId INT,DBRCovAreaNodeType INT,DBRCovArea VARCHAR(200),DBRRouteId INT,DBRRouteNodeType INT,DBRRoute VARCHAR(200))
		
	SELECT * INTO #VwSalesHierarchyFull FROM VwSalesHierarchyFull
	INSERT INTO #tmpRsltWithFullHierarchy(ZoneID,ZoneType,Zone,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea, CompCovAreaId,CompCovAreaNodeType, CompCovArea,CompRouteId,CompRouteNodeType,CompRoute)
	SELECT DISTINCT ZnNodeID,ZnNodeType,Zone,ASMAreaNodeId,ASMAreaNodeType,ASMArea,SOAreaNodeID,SOAreaNodeType,SOArea,ComCoverageAreaID,ComCoverageAreaType,ComCoverageArea, 0 RouteID,0 RouteType,'' Route
	FROM #VwSalesHierarchyFull
	--WHERE RouteID IS NOT NULL
	--SELECT * FROM #tmpRsltWithFullHierarchy
	PRINT '2=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.ZnNodeId ZoneID,ZnNodeType ZoneType,Zone,ASMAreaNodeId ASMAreaID,ASMAreaNodeType ASMAreaType,ASMArea,SOAreaNodeID SOID,SOAreaNodeType SOAreaType,SOArea INTO #CompSales
	FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #VwSalesHierarchyFull CS ON Map.SHNodeId=CS.SOAreaNodeID AND Map.SHNodeType=CS.SOAreaNodeType	
	WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
	UNION ALL
	SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.ZnNodeId ZoneID,ZnNodeType ZoneType,Zone,ASMAreaNodeId ASMAreaID,ASMAreaNodeType ASMAreaType,ASMArea,0,0,'Direct'
	FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #VwSalesHierarchyFull CS ON Map.SHNodeId=CS.ASMAreaNodeID AND Map.SHNodeType=CS.ASMAreaNodeType		
	WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
	UNION ALL
	SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.ZnNodeId ZoneID,ZnNodeType ZoneType,Zone,0,0,'Direct',0,0,'Direct'
	FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #VwSalesHierarchyFull CS ON Map.SHNodeId=CS.ZnNodeID AND Map.SHNodeType=CS.ZnNodeType 
	WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)  
	--SELECT * FROM #CompSales
	PRINT '3=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	--INSERT INTO #tmpRsltWithFullHierarchy(ZoneID,ZoneType,Zone,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea, DBRNodeId,DBRNodeType,DBR,DBRCovAreaId, DBRCovAreaNodeType,DBRCovArea,DBRRouteId,DBRRouteNodeType,DBRRoute)
	--SELECT ISNULL(#CompSales.ZoneID,0),ISNULL(#CompSales.ZoneType,100),ISNULL(#CompSales.Zone,'NA'),ISNULL(#CompSales.ASMAreaId,0),ISNULL(#CompSales.ASMAreaType,110),ISNULL(#CompSales.ASMArea,'NA'),ISNULL(#CompSales.SOID,0),ISNULL(#CompSales.SOAreaType,120),ISNULL(#CompSales.SOArea,'NA'),vwDBR.DBRNodeID,vwDBR.DistributorNodeType,vwDBR.Distributor, vwDBR.DBRCoverageID,vwDBR.DBRCoverageNodeType,vwDBR.DBRCoverage,vwDBR.DBRRouteID,vwDBR.RouteNodeType,vwDBR.DBRRoute
	--FROM VwAllDistributorHierarchy vwDBR LEFT JOIN #CompSales ON vwDBR.DBRCoverageId=#CompSales.DHNodeId AND vwDBR.DBRCoverageNodeType=#CompSales.DHNodeType
	--select * from #tmpRsltWithFullHierarchy
	IF @SalesAreaNodeType=100 --Zone
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE ZoneID NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas)
	END
	ELSE IF @SalesAreaNodeType=110 -- ASM
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE ASMAreaId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas)
	END
	ELSE IF @SalesAreaNodeType=120 --SO
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE SOAreaId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas)
	END
	ELSE IF @SalesAreaNodeType=140 --Company DSR
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE CompCovAreaId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas) OR CompCovAreaId IS NULL
	END
	ELSE IF @SalesAreaNodeType=160 --Distributor DSR
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE DBRCovAreaId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas) OR DBRCovAreaId IS NULL
	END
	--select * from #tmpRsltWithFullHierarchy
	--Zone
	IF @SalesAreaNodeType=0 OR @SalesAreaNodeType=100
	BEGIN
		INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl)
		SELECT DISTINCT ZoneID,ZoneType,0,0,0,0,Zone,0
		FROM #tmpRsltWithFullHierarchy
	END
	PRINT '4=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	--ASMA Area
	IF @SalesAreaNodeType=0 OR @SalesAreaNodeType=100 OR @SalesAreaNodeType=110
	BEGIN
		INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl)
		SELECT DISTINCT ASMAreaId,ASMAreaNodeType,ZoneID,ZoneType,0,0,ASMArea,CASE @SalesAreaNodeType WHEN 0 THEN 1 WHEN 100 THEN 1 ELSE 0 END
		FROM #tmpRsltWithFullHierarchy
	END

	-- So Area
	INSERT INTO #tmpRslt(NodeId,NodeType,PNodeId,PNodeType,PPNodeId,PPNodeType,[Sales Area],Lvl)
	SELECT DISTINCT SOAreaId,SOAreaNodeType,ASMAreaId,ASMAreaNodeType,ZoneID,ZoneType,SOArea,CASE @SalesAreaNodeType WHEN 0 THEN 2 WHEN 100 THEN 2 WHEN 110 THEN 1 ELSE 0 END	FROM #tmpRsltWithFullHierarchy

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
	PRINT '5=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	--SELECT * FROM #tmpRslt

	*/
	CREATE TABLE #Flaghierarchy(flgDistributorCheckIn TINYINT,flgDBRStockInApp TINYINT,flgDBRStockEdit TINYINT,flgDBRStockCalculate TINYINT,flgDBRStockControl TINYINT,flgCollRequired TINYINT,flgCollReqOrdr TINYINT,flgCollTab TINYINT,flgCollDefControl TINYINT,flgCashDiscount TINYINT,flgCollControlRule TINYINT,flgSchemeAvailable TINYINT,flgSchemeAllowEntry TINYINT,flgSchemeAllowEdit TINYINT,flgQuotationIsAvailable TINYINT,flgExecutionIsAvailable TINYINT,flgExecutionPhotoCompulsory TINYINT,flgTargetShowatStart TINYINT,flgIncentiveShowatStart TINYINT,flgInvoicePrint TINYINT,flgShowPOSM TINYINT,flgVisitStartOutstandingDetails TINYINT,flgVisitStartSchemeDetails TINYINT,flgStoreDetailsEdit TINYINT,flgShowDeliveryAddressButtonOnOrder TINYINT,flgShowManagerOnStoreList TINYINT,flgRptTargetVsAchived TINYINT,SalesNodeID TINYINT,SalesNodetype TINYINT,WorkingTypeID TINYINT,flgVanStockInApp TINYINT,flgVanStockEdit TINYINT,flgVanStockCalculate TINYINT,flgVanStockControl TINYINT,flgStockRefillReq TINYINT,flgDayEnd TINYINT,flgStockUnloadAtCycleEnd TINYINT,flgStockUnloadAtDayEnd TINYINT,flgCollReqATCycleEnd TINYINT,flgCollReqATDayEnd TINYINT,flgDayEndSummary TINYINT,flgStoreCheckInApplicable TINYINT,flgStoreCheckInPhotoCompulsory TINYINT,flgDBRStockCanSkipFillInDayStart TINYINT)

	DECLARE @LowestNodeFlagDefAvailable INT
	--INSERT INTO #Flaghierarchy
	--SELECT M.*  FROM [dbo].[tblMasterFlags] M INNER JOIN #tmpRslt R ON R.NodeId=M.SalesNodeID AND R.NodeType=M.SalesNodetype
	
	IF NOT EXISTS (SELECT 1 FROM #Flaghierarchy)
	BEGIN
		SELECT * FROM [tblMasterFlags] WHERE SalesNodetype=0
	END
	ELSE
	BEGIN
		SELECT  @LowestNodeFlagDefAvailable=MAX(SalesNodetype) FROM #Flaghierarchy
		SELECT * FROM #Flaghierarchy WHERE SalesNodetype=@LowestNodeFlagDefAvailable
	END
	
	PRINT '6=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	----DECLARE @WorkingTypeID INT
	------SELECT @WorkingTypeID=dbo.fnGetWorkingTypeForCoverageArea(@CoverageAreaNodeID,@CoverageAreaNodeType)
	----IF @WorkingTypeID=1 -- Van Sales
	----BEGIN
	----	--SELECT * FROM #Flaghierarchy WHERE SalesNodetype=@LowestNodeFlagDefAvailable
	----	SELECT * FROM #Flaghierarchy WHERE SalesNodetype=0
	----	--Select 1 As flgShowSalesTargetValue,0 AS flgShowDistributorStock,0 As flgShowInvoice,0 As flgShowPOSM,0 As flgShowPaymentStageAtLastVisitPage,0 As flgShowDeliveryAddressButtonOnOrder,1 As flgShowManagerOnStoreList,1 As flgShowTragetVsAchived,1 AS flgFilterProductOnCategoryOrSearchBasis,1 AS flgNeedStock,1 AS flgCalculateStock,1 AS flgControlStock,1 AS flgManageCollection,1 AS flgControlCollection,1 AS flgManageScheme,1 AS flgManageSalesQuotation,1 AS flgManageExecution
	----END	
	----ELSE  -- Order Booking
	----BEGIN
	----	--SELECT * FROM #Flaghierarchy WHERE SalesNodetype=@LowestNodeFlagDefAvailable
	----	SELECT * FROM #Flaghierarchy WHERE SalesNodetype=0
	----	--Select 1 As flgShowSalesTargetValue,0 AS flgShowDistributorStock,0 As flgShowInvoice,0 As flgShowPOSM,0 As flgShowPaymentStageAtLastVisitPage,0 As flgShowDeliveryAddressButtonOnOrder,1 As flgShowManagerOnStoreList,1 As flgShowTragetVsAchived,1 AS flgFilterProductOnCategoryOrSearchBasis,0 AS flgNeedStock,0 AS flgCalculateStock,0 AS flgControlStock,1 AS flgManageCollection,1 AS flgControlCollection,1 AS flgManageScheme,1 AS flgManageSalesQuotation,1 AS flgManageExecution
	----END

END





--SELECT * from tblVErsionMstr
