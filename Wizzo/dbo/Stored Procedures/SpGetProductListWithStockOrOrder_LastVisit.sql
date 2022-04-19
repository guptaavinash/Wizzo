-- =============================================
-- Author:		Avinash Gupta
-- Create date: 07-May-2018
-- Description:	
-- ============================================
-- [SpGetProductListWithStockOrOrder_LastVisit] @PDACode=N'EC96DE03-AD24-45CF-91DE-F7330AA5B5BE',@Date=N'29-Dec-2021',@RouteID=0,@RouteNodeType=0,@flgAllRoutesData=1,@CoverageAreaNodeID=92,@coverageAreaNodeType=130
CREATE PROCEDURE [dbo].[SpGetProductListWithStockOrOrder_LastVisit] 
	@PDACode VARCHAR(50) ,
	@Date Date,
	@flgAllRoutesData  TINYINT,  -- 1:to show all routes, 0: to show only given route 
	@RouteID INT,    
	@RouteNodeType SMALLINT,    
	@CoverageAreaNodeID INT = 0,
	@coverageAreaNodeType SMALLINT  =0
AS
BEGIN
	DECLARE @VisitDate Date
	--DECLARE @DeviceID INT
	SET @VisitDate=@Date
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMEINo OR PDA_IMEI_Sec=@IMEINo
	DECLARE @PersonNodeID INT,@PersonType SMALLINT
	 SELECT @PersonNodeID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	 DECLARE @CoverageArea VARCHAR(200)
	CREATE TABLE #tblOutletList (StoreID int,flgLastVisitStock TINYINT,flgLastVisitOrder TINYINT)
	CREATE TABLE #DSRRouteList (CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT,CoverageArea VARCHAR(500),PersonNodeID INT,
	PersonNodeType SMALLINT,PersonName VARCHAR(200),RouteNodeID INT,RouteNodeType SMALLINT,Route VARCHAR(500),flgDefaultRoute TINYINT)
	----IF @CoverageAreaNodeID>0 AND @coverageAreaNodeType>0   --- Need the Store list for the DSR.
	----BEGIN
	----	SELECT @CoverageArea=NodeID FROM tblCompanySalesStructureCoverage WHERE  NodeID=@CoverageAreaNodeID AND NodeType=@coverageAreaNodeType

	----	INSERT INTO #DSRRouteList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,RouteNodeID,RouteNodeType,Route)
		
	----	SELECT DISTINCT @CoverageAreaNodeID,@coverageAreaNodeType,@CoverageArea,@PersonNodeID,@PersonType,RouteNodeId,RouteNodeType,RM.Descr FROM tblRouteCalendar RC INNER JOIN tblCompanySalesStructureRoute RM ON RM.NodeID=RC.RouteNodeId AND RC.RouteNodeType=RM.NodeType WHERE RC.SONodeId=@PersonNodeID AND RC.SONodeType=@PersonType 
	----END

	CREATE TABLE #CoverageArea(NodeID INT,NodeType SMALLINT)

	IF @PersonType IN (220,230)
	BEGIN
		INSERT INTO  #CoverageArea
		SELECT DISTINCT P.NodeID,P.NodeType  
		FROM tblSalesPersonMapping P     
		INNER JOIN [dbo].[tblSecMenuContextMenu] S ON S.NodeType=P. NodeType     
		WHERE P.PersonNodeID=@PersonNodeID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) AND S.flgCoverageArea=1
	END
	ELSE IF @PersonType=210
	BEGIN
		IF @CoverageAreaNodeID>0 AND @coverageAreaNodeType>0
		BEGIN
			INSERT INTO  #CoverageArea
			SELECT @CoverageAreaNodeID,@coverageAreaNodeType
		END
		ELSE
		BEGIN
			INSERT INTO  #CoverageArea
			SELECT DISTINCT V.DSRAreaID,V.DSRAreaNodeType  
			FROM tblSalesPersonMapping P INNER JOIN [dbo].[VwCompanySalesHierarchy] V ON V.ASMAreaID=P.NodeID AND V.ASMAreaNodeType=P.NodeType 
			WHERE P.PersonNodeID=@PersonNodeID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		END
	END



	INSERT INTO #DSRRouteList(RouteNodeID,RouteNodeType)
	SELECT DISTINCT  RouteNodeId,RouteNodetype FROM tblRoutePlanningVisitDetail(nolock) RP INNER JOIN #CoverageArea C ON C.NodeID=RP.CovAreaNodeID AND C.NodeType=RP.CovAreaNodeType


	--SELECT * FROM #DSRRouteList

	INSERT INTO #tblOutletList (StoreID) 
	----SELECT DISTINCT RC.StoreId FROM tblRouteCalendar RC WHERE RC.SONodeId=@PersonNodeID AND RC.SONodeType=@PersonType AND VisitDate>=CAST(GETDATE() AS DATE)  

	SELECT DISTINCT tblStoreMaster.StoreID 
	FROM    tblRouteCoverageStoreMapping(nolock) RCM INNER JOIN tblStoreMaster(nolock) ON RCM.StoreID = tblStoreMaster.StoreID    
	INNER JOIN tblMstrChannel on tblMstrChannel.ChannelId=tblStoreMaster.ChannelId
	INNER JOIN #DSRRouteList R ON RCM.RouteId=R.RouteNodeID AND RCM.RouteNodeType=R.RouteNodeType
	--LEFT OUTER JOIN tblStoreTypeMstr ST ON ST.NodeID=tblStoreMaster.StoreTypeID
	WHERE  (CONVERT(VARCHAR, RCM.FromDate, 112) <= CONVERT(VARCHAR, @Date, 112)) AND (ISNULL(tblStoreMaster.flgActive, 1) = 1) AND      (GETDATE() BETWEEN RCM.FromDate AND RCM.ToDate)   

	SELECT  O.StoreID, MAX(O.InvDate) AS VisitDate INTO [#TMPLastVisit]
	FROM  tblP3MSalesDetail O 
	INNER JOIN #tblOutletList S ON S.StoreID=O.StoreID
	WHERE CAST(InvDate AS DATE)<=@VisitDate -- and (tblVisitMaster.RouteID = @RouteID) AND (tblVisitMaster.RouteType = @RouteNodeType)
	GROUP BY O.StoreID


	Select [#TMPLastVisit].StoreID, MAX(tblP3MSalesDetail.InvDate) AS MaxInvDate INTO [#LastVisit]
	FROM [#TMPLastVisit] JOIN tblP3MSalesDetail ON [#TMPLastVisit].StoreID = tblP3MSalesDetail.StoreID AND [#TMPLastVisit].VisitDate = tblP3MSalesDetail.InvDate
	GROUP BY  [#TMPLastVisit].StoreID
	--SELECT * FROm [#LastVisit]

	SELECT DISTINCT OM.StoreID,OM.InvDate OrderDate,OM.PrdNodeId ProductID,OM.Qty OrderQty INTO #Order
	FROM    [#LastVisit] AS A INNER JOIN tblP3MSalesDetail OM ON A.MaxInvDate = OM.InvDate AND OM.StoreId=A.StoreId 

	CREATE TABLE #Stock(StockDate DATE,Qty int,ProductID INT,StoreID INT)
	INSERT INTO #Stock
	SELECT        tblVisitStock.StockDate, tblVisitStock.Qty, tblVisitStock.ProductID, A.StoreId
	FROM            [#LastVisit] AS A INNER JOIN
	tblVisitStock ON A.MaxInvDate = tblVisitStock.StockDate AND A.StoreId=tblVisitStock.StoreID  WHERE ISNULL(tblVisitStock.Qty,0)<>0

	----SELECT * FROM #Stock
	----SELECT * FROM #Order

	CREATE TABLE #ProductWithStockOrOrder(StoreID INT,PrdID INT,OrderQty INT,StockQty INT,OrderDate Date)
	INSERT INTO #ProductWithStockOrOrder(StoreID,OrderDate,PrdID,OrderQty,StockQty)
	SELECT ISNULL(#Order.StoreID,#Stock.StoreID) AS StoreID, [dbo].[fncSetDateFormat](ISNULL(OrderDate,StockDate)) AS OrderDate, ISNULL(#Order.ProductID,#Stock.ProductID) AS ProductID,ISNULL(OrderQty,0) AS OrderQt, ISNULL(#Stock.Qty,0) AS Stock
	FROM #Order FULL OUTER JOIN [#Stock] ON #Order.StoreID = [#Stock].StoreID AND #Order.ProductID = [#Stock].ProductID

	SELECT StoreID,PrdID FROM #ProductWithStockOrOrder

	--- Cursor for the Competitors brand.
	--SELECT DISTINCT CompetitorBrandID,CompetitorBrand,BusinessUnitID,V.Descr BusinessUnit FROM tblCompetitorBrandMaster_GT C INNER JOIN tblPrdBusinessUnitMstr V ON V.NodeID=C.BusinessUnitID
	--SELECT DISTINCT ProductCategoryAvailable ProductCategoryID,V.Descr Category,C.items FROM tblStoreProductCategoryCompetitorSurvey_GT G CROSS APPLY dbo.split(CompetitorBrand,'^') C 
	--INNER JOIN tblPrdBusinessUnitMstr V ON V.NodeID=G.ProductCategoryAvailable WHERE ISNULL(items,'')<>''


	---#######################################################################################################################################################

END
