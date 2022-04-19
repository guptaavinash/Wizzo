-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec [SpGetTCOrderForSFA] @PDACode=N'314D6CE8-0C6A-4635-9D75-04AC1A56F27A'
CREATE PROCEDURE [dbo].[SpGetTCOrderForSFA_tocheck] 
	@PDACOde VARCHAR(100),
	@CoverageAreaNodeID INT=0,
	@CoverageAreaNodeType SMALLINT=0
AS
BEGIN
	DECLARE @PersonID INT     
	DECLARE @PersonType INT
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	CREATE TABLE #CoverageArea(NodeID INT,NodeType SMALLINT)
	IF @PersonType IN (220,230)
	BEGIN
		INSERT INTO  #CoverageArea
		SELECT DISTINCT P.NodeID,P.NodeType  
		FROM tblSalesPersonMapping P     
		INNER JOIN [dbo].[tblSecMenuContextMenu] S ON S.NodeType=P. NodeType     
		WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) AND S.flgCoverageArea=1
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
			WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		END
	END
	--SELECT * FROM #CoverageArea

	PRINT '@PersonID=' + CAST(@PersonID AS VARCHAR)
	PRINT '@PersonType=' + CAST(@PersonType AS VARCHAR)
	CREATE TABLE #Routes(NodeID INT,NodeType SMALLINT)
	INSERT INTO #Routes(Nodeid,Nodetype)
	SELECT DISTINCT  RouteNodeId,RouteNodetype FROM tblRoutePlanningVisitDetail RP INNER JOIN #CoverageArea C ON C.NodeID=RP.CovAreaNodeID AND C.NodeType=RP.CovAreaNodeType WHERE VisitDate>=CAST(GETDATE() AS DATE) 


	--SELECT * FROM #Routes
	CREATE TABLE #DSRStoreList (PersonNodeID INT,PersonNodeType SMALLINT,PersonName VARCHAR(200), RouteNodeID INT,RouteNodeType SMALLINT,Route VARCHAR(500),flgDefaultRoute TINYINT,StoreID INT)

	INSERT INTO #DSRStoreList(PersonNodeID,PersonNodeType,RouteNodeID,RouteNodeType,Route,StoreID)
	SELECT distinct @PersonID,@PersonType,CH.NodeID,CH.NodeType,RM.Descr ,RC.StoreID
	FROM tblSalesPersonMapping P
	INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
	INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID 
	INNER JOIN tblCompanySalesStructureRouteMstr RM ON RM.NodeID=CH.NodeID AND CH.NodeType=RM.NodeType
	INNER JOIN tblRouteCoverageStoreMapping RC ON RC.RouteID=CH.NodeID AND RC.RouteNodeType=CH.NodeType
	INNER JOIN #Routes R ON R.NodeID=RC.RouteID AND R.NodeType=RC.RouteNodeType
	AND CAST(GETDATE() AS DATE) BETWEEN RC.FromDate AND RC.ToDate
	INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
	WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))

	--SELECT * FROM #DSRStoreList


	----SELECT DISTINCT @PersonID,@PersonType,RouteNodeId,RouteNodeType,RM.Descr,RC.StoreId FROM tblRouteCalendar RC INNER JOIN tblCompanySalesStructureRoute RM ON RM.NodeID=RC.RouteNodeId AND RC.RouteNodeType=RM.NodeType WHERE RC.SONodeId=@PersonID AND RC.SONodeType=@PersonType

	DECLARE @tblRawDataInvoiceHeader udt_RawDataInvoiceHeader 
	DECLARE @tblRawDataInvoiceDetail udt_RawDataInvoiceDetail 

	SELECT O.StoreID,MAX(O.OrderID) MaxOrderID,MAX(T.TeleCallingId) TeleCallingId INTO #LastTCOrder FROM tblTCOrderMaster O INNER JOIN [dbo].[tblTeleCallerListForDay] T ON T.TeleCallingId=O.TeleCallingId INNER JOIN #DSRStoreList S ON S.StoreID=O.StoreID  GROUP BY O.StoreID

	--SELECT * FROM #DSRStoreList
	--SELECT * FROM tblTCOrderMaster WHERE StoreID IN (SELECT StoreID FROM #DSRStoreList)
	--SELECT * FROM #LastTCOrder

	INSERT INTO @tblRawDataInvoiceHeader([StoreVisitCode],[InvoiceNumber],[TmpInvoiceCodePDA],[StoreID],[InvoiceDate],[TotalBeforeTaxDis],[TaxAmt],[TotalDis],[InvoiceVal],[FreeTotal],[InvAfterDis],[AddDis],[NoCoupon],[TotalCoupunAmount],[TransDate],[FlgInvoiceType],[flgWholeSellApplicable],[flgProcessedInvoice],[CycleID],[RouteNodeTypeflgDrctslsIndrctSls],RouteNodeID,RouteNodeType,TelecallingID)
	SELECT DISTINCT NULL,TC.OrderID,NULL,TC.StoreID,TC.OrderDate,TC.TotOrderValWDisc,TC.TotTaxVal,TC.TotDiscVal,TC.NetOrderValue,0,TC.NetOrderValue,0,0,0,TC.OrderDAte,1,0,0,0,0,TC.RouteNodeId,TC.RouteNodeType,TC.TeleCallingId FROM tblTCOrderMaster TC INNER JOIN tblTCOrderDetail TD ON TC.OrderID=TD.OrderID INNER JOIN #LastTCOrder S ON S.StoreID=TC.StoreID AND S.MaxOrderID=TC.OrderID

	SELECT * FROM @tblRawDataInvoiceHeader WHERE StoreID=101383

	
	INSERT INTO @tblRawDataInvoiceDetail([InvoiceNumber],[TmpInvoiceCodePDA],[StoreID],[CatID],[ProdID],[ProductPrice],[TaxRate],[flgRuleTaxVal],[OrderQty],[UOMId],[LineValBfrTxAftrDscnt],[LineValAftrTxAftrDscnt],[FreeQty],[DisVal],[SampleQuantity],[ProductShortName],[TaxValue],[OrderIDPDA],[flgIsQuoteRateApplied],[ServingDBRId],	[flgWholeSellApplicable],[ProductExtraOrder],[flgDrctslsIndrctSls],[SuggestedQty],[Discperpcs])

	SELECT DISTINCT  D.OrderID,NULL,H.StoreID,0,D.PrdNodeId,D.ProductRate,D.TaxRate,0,D.OrderQty,3,D.LineOrderValWDisc,D.NetLineOrderVal,D.FreeQty,D.TotLineDiscVal,D.SampleQty,'',D.TotTaxValue,NULL,0,0,0,0,0,0,CASE WHEN D.OrderQty>0 THEN ROUND(CAST(D.NetLineOrderVal AS NUMERIC(18,6))/D.OrderQty,4) ELSE 0 END FROM tblTCOrderDetail D INNER JOIN @tblRawDataInvoiceHeader H ON CAST(H.InvoiceNumber AS INT)=D.OrderID 
	--CROSS JOIN #tblSQTY S 

	--UPDATE D SET [SuggestedQty]=S.SSqty FROM @tblRawDataInvoiceDetail D INNER JOIN #tblSQTY S ON S.PrdNodeId=D.ProdID AND S.StoreId=D.StoreID

	SELECT [StoreVisitCode],[InvoiceNumber],[TmpInvoiceCodePDA],[StoreID],[InvoiceDate],[TotalBeforeTaxDis],[TaxAmt],[TotalDis],[InvoiceVal],[FreeTotal],[InvAfterDis],[AddDis],[NoCoupon],[TotalCoupunAmount],[TransDate],[FlgInvoiceType],[flgWholeSellApplicable],[flgProcessedInvoice],[CycleID],[RouteNodeTypeflgDrctslsIndrctSls] flgDrctslsIndrctSls,RouteNodeID,RouteNodeType,TeleCallingId FROM @tblRawDataInvoiceHeader
	SELECT [InvoiceNumber],[TmpInvoiceCodePDA],R.[StoreID],[CatID],[ProdID],[ProductPrice],[TaxRate],[flgRuleTaxVal],[OrderQty],[UOMId],[LineValBfrTxAftrDscnt],[LineValAftrTxAftrDscnt],[FreeQty],[DisVal],[SampleQuantity],[ProductShortName],[TaxValue],[OrderIDPDA],[flgIsQuoteRateApplied],[ServingDBRId],	[flgWholeSellApplicable],[ProductExtraOrder],[flgDrctslsIndrctSls],[SuggestedQty],[Discperpcs] FROM @tblRawDataInvoiceDetail R --WHERE StoreID=89362

	SELECT S.StoreId,PrdNodeId,AVG(Qty) [SuggestedQty] FROM tblP3MSalesDetail(nolock) P INNER JOIN #DSRStoreList S ON S.StoreID=P.StoreId GROUP BY S.StoreId,PrdNodeId

	SELECT DISTINCT S.StoreId,PrdNodeId FROM tblP3MSalesDetail(nolock) P INNER JOIN #DSRStoreList S ON S.StoreID=P.StoreId GROUP BY S.StoreId,PrdNodeId --- Focus SKU

	SELECT DISTINCT S.StoreId,PrdNodeId FROM tblP3MSalesDetail(nolock) P INNER JOIN #DSRStoreList S ON S.StoreID=P.StoreId GROUP BY S.StoreId,PrdNodeId --- Replenishment SKU

	--SELECT SKUID NodeID,NodeType,BaseUOMID,PackUOMID,RelConversionUnits,flgVanLoading FROM [dbo].[tblPrdMstrPackingUnits_ConversionUnits] 
	--WHERE SKUID=3

	CREATE TABLE #tblDiscount(StoreID INT,[InvoiceNumber] VARCHAR(20),PrdID INT,UOMID INT,RelConversionUnits INT,TotalDisc NUMERIC(26,4),DiscountperUOM NUMERIC(26,4))

	INSERT INTO #tblDiscount(StoreID,[InvoiceNumber],PrdID,UOMID,RelConversionUnits,TOtalDisc,DiscountperUOM)
	SELECT ID.StoreID,ID.InvoiceNumber,C.PrdId,C.UOMID,P.RelConversionUnits,ID.[DisVal],CASE WHEN ID.OrderQty>0 THEN ROUND((CAST(ID.[DisVal] AS NUMERIC(18,6))/ID.OrderQty) * RelConversionUnits,4) ELSE 0 END FROM @tblRawDataInvoiceDetail ID INNER JOIN tblPrdMstrTransactionUOMConfig C ON C.PrdId=ID.ProdID
	LEFT OUTER JOIN (SELECT DISTINCT SKUId,PackUOMID,RelConversionUnits FROM [tblPrdMstrPackingUnits_ConversionUnits]
					UNION
					SELECT DISTINCT SKUId,3,1 FROM [tblPrdMstrPackingUnits_ConversionUnits]) P ON P.PackUOMID=C.UOMID AND P.SKUId=C.PrdId

	SELECT * FROM #tblDiscount



	

END
