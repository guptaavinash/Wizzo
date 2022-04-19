
-- [spForPDAGetLastOrderDetails] '05-Jan-2018' ,'354010084603910',17,170,1 
CREATE PROCEDURE [dbo].[spForPDAGetLastOrderDetails] 
@Date varchar(50),
@PDACode VARCHAR(50),
@RouteID INT,
@RouteNodeType INT,
@flgAllRoutesData  TINYINT,  -- 1:to show all routes, 0: to show only given route 
@CoverageAreaNodeID INT = 0,
@CoverageAreaNodeType SMALLINT  =0
AS
BEGIN
	DECLARE @VisitDate Date
	--DECLARE @DeviceID INT
	
	SET @VisitDate=CONVERT(Date,@Date,105)

	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI  
	DECLARE @PersonID INT,@PersonType SMALLINT

	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	
	CREATE TABLE #Routes(RouteID INT,RouteNodeType INT) 

	IF @CoverageAreaNodeID>0 AND @coverageAreaNodeType>0   --- Need the Route list for the DSR.
	BEGIN
		INSERT INTO #Routes(RouteID,RouteNodeType)
		--SELECT DISTINCT DBRRouteID,RouteNodeType
		--FROM  VwDistributorDSRFullDetail V WHERE DBRCoverageID=@CoverageAreaNodeID AND DBRCoverageNodeType=@coverageAreaNodeType AND V.DBRCoverageID>0
		--UNION
		SELECT DISTINCT DSRRouteNodeID,DSRRouteNodeType
		FROM VwCompanyDSRFullDetail V WHERE DSRAreaID=@CoverageAreaNodeID AND DSRAreaNodeType=@coverageAreaNodeType AND V.DSRAreaID>0
	END
	ELSE
	BEGIN
		IF @flgAllRoutesData=1
		BEGIN
			INSERT INTO #Routes(RouteId,RouteNodeType)
			SELECT DISTINCT P.NodeID,P.NodeType 
			FROM tblSalesPersonMapping P  
			INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
			WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		END
		ELSE
		BEGIN
			INSERT INTO #Routes(RouteId,RouteNodeType)
			SELECT @RouteID,@RouteNodeType
		END
	END  
    --SELECT * FROM #Routes

	SELECT  V.StoreID, MAX(V.VisitDate) AS VisitDate INTO [#TMPLastVisit]
	FROM tblVisitMaster V INNER JOIN tblOrderMaster ON V.VisitID = tblOrderMaster.VisitID
	INNER JOIN #Routes R ON V.RouteID=R.RouteId AND V.RouteType=R.RouteNodeType
	WHERE CAST(VisitDate AS DATE)<=@VisitDate --AND (CONVERT(VARCHAR, tblVisitMaster.VisitDate, 112) < CONVERT(VARCHAR, CONVERT(DATE,@Date,105), 112))
	GROUP BY V.StoreID


	SELECT [#TMPLastVisit].StoreID, MAX(tblVisitMaster.VisitID) AS VisitID INTO [#LastVisit]
	FROM [#TMPLastVisit] JOIN tblVisitMaster ON [#TMPLastVisit].StoreID = tblVisitMaster.StoreID AND [#TMPLastVisit].VisitDate = tblVisitMaster.VisitDate
	GROUP BY  [#TMPLastVisit].StoreID

	SELECT DISTINCT OM.StoreID, OM.OrderDate, OD.ProductID, OD.OrderQty, OD.FreeQty Qty,PS.Descr  AS PrdName,OM.RouteNodeId AS RouteId,OM.RouteNodeType
	INTO #Order
	FROM [#LastVisit] AS A INNER JOIN tblOrderMaster OM ON A.VisitID = OM.VisitID INNER JOIN
        tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN
		tblPrdMstrSKULvl PS ON OD.ProductID = PS.NodeID
		--LEFT OUTER JOIN tblPrdSizeMstr S ON S.NodeID=PS.SizeID
        --VwProductHierarchy ON OD.ProductID = VwProductHierarchy.SKUNodeID --LEFT OUTER JOIN
        -- tblOrderSchemeSlabBenefit ON tblOrderDetail.OrderDetailID = tblOrderSchemeSlabBenefit.OrderDetID 

	CREATE TABLE #Stock(PrdName VARCHAR(500),StockDate DATE,Qty int,ProductID INT,StoreID INT)
	----INSERT INTO #Stock
	----SELECT        VwProductHierarchy.SKUShortDescr AS PrdName, tblVisitStock.StockDate, tblVisitStock.Qty, tblVisitStock.ProductID, StoreID
	----INTO              [#Stock]
	----FROM            [#LastVisit] AS A INNER JOIN
	----                         tblVisitStock ON A.VisitID = tblVisitStock.VisitID INNER JOIN
	----                         VwProductHierarchy ON tblVisitStock.ProductID = VwProductHierarchy.SKUNodeID

	
	SELECT ISNULL(#Order.StoreID,#Stock.StoreID) AS StoreID, REPLACE(CONVERT(VARCHAR,ISNULL(OrderDate,StockDate),106),' ','-') AS OrderDate, ISNULL(#Order.ProductID,#Stock.ProductID) AS ProductID,ISNULL(OrderQty,0) AS OrderQty, ISNULL(#Order.Qty,0) AS FreeQty, ISNULL(#Stock.Qty,0) AS Stock, ISNULL(#Order.PrdName, #Stock.PrdName) AS PrdName,
ISNULL(OrderQty,0) AS ExecutionQty,RouteId,RouteNodeType
	FROM #Order FULL OUTER JOIN [#Stock] ON #Order.StoreID = [#Stock].StoreID AND #Order.ProductID = [#Stock].ProductID

END











