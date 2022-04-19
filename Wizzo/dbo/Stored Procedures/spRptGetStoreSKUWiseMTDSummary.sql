



--[dbo].[spRptGetStoreSKUWiseDaySummary]  '359670066016988','20-09-2017'
CREATE PROCEDURE [dbo].[spRptGetStoreSKUWiseMTDSummary] 
@PDACode VARCHAR(50)='',  
@Date varchar(20),
@SalesmanNodeId INT=0, -- If SO is working, PersonId of Salesman working under him in case of @flgDataScope=2, Distributor Id in case of @flgDataScope=4 
@SalesmanNodeType INT=0,
@flgDataScope TINYINT=1 --1:Self, 2: Salesman working under(in this case only @PersonNodeId is to be used), 3: Self as well salesmen working under,4: Distributor
--@RouteId INT=0  
AS 

BEGIN  
	CREATE TABLE #tmp([Sr.] INT,CategoryNodeID INT,ProductId INT, Product VARCHAR(500),MRP FLOAT, Rate FLOAT,[Stock Qty] INT, [Order Qty] INT,[Free Qty] INT, [Disc Value] FLOAT,	ValBeforeTax FLOAT, [Tax Value] FLOAT, ValAfterTax FLOAT,Lvl tinyint,StoreId int,OrderQtyCS FLOAT,OrderQtyPcs INT)
	CREATE TABLE #tmpProduct([Sr.] INT IDENTITY(1,1),CategoryNodeID INT,ProductId INT, Product VARCHAR(500),MRP FLOAT, Rate FLOAT,[Stock Qty] INT, [Order Qty] INT,[Free Qty] INT, [Disc Value] FLOAT,	ValBeforeTax FLOAT, [Tax Value] FLOAT, ValAfterTax FLOAT,StoreName varchar(500),StoreId int,OrderQtyCS FLOAT,OrderQtyPcs INT)	
	CREATE TABLE #PersonList(PersonNodeId INT,PersonNodeType INT)
	--CREATE TABLE #RouteID (RouteID INT,RouteNodeType TINYINT)

	DECLARE @VisitDate Date
	DECLARE @ASMAreaNodeId INT
	DECLARE @ASMAreaNodeType INT
	DECLARE @PDAID INT  
	DECLARE @PersonID INT  
	DECLARE @PersonType INT  

	 SET @VisitDate=CONVERT(Date,@Date,105)
	 	 
	 IF @PDACode<>''
	 BEGIN
		SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID 
			IF @flgDataScope=1 OR @flgDataScope=0
			BEGIN	
				PRINT 'PersonID=' + CAST(@PersonID AS VARCHAR)
				PRINT 'PersonType=' + CAST(@PersonType AS VARCHAR)

				INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
				SELECT @PersonID,@PersonType
			END
			ELSE IF @flgDataScope=2
			BEGIN
				INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
				SELECT @SalesmanNodeId,@SalesmanNodeType
			END
			ELSE IF @flgDataScope=3
			BEGIN
				INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
				SELECT @PersonID,@PersonType

				--Company Salesmna working under SO
				SELECT * INTO #SalesHier FROM VwCompanyDSRFullDetail

				SELECT @ASMAreaNodeId=NodeId,@ASMAreaNodeType=NodeType
				FROM tblSalesPersonMapping SP
				WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(SP.ToDate,GETDATE())) AND SP.PersonNodeId=@PersonID ANd SP.PersonType=@PersonType AND SP.NodeType=110

				INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
				SELECT DISTINCT SP.PersonNodeId,SP.PersonType
			FROM #SalesHier H INNER JOIN tblSalesPersonMapping SP ON H.DSRAreaID=SP.NodeId AND H.DSRAreaNodeType=SP.NodeType
			WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(SP.ToDate,GETDATE())) ANd H.ASMAreaID=@ASMAreaNodeId AND H.ASMAreaNodeType=@ASMAreaNodeType AND SP.PersonNodeId<>@PersonID

				------Distributor Salesmna working under SO
				----INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
				----SELECT DISTINCT SP.PersonNodeId,SP.PersonType
				----FROM #SalesHier H INNER JOIN tblCompanySalesStructure_DistributorMapping Map ON H.SOID=Map.SHNodeId AND H.SOAreaType=Map.SHNodeType
				----INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=Map.DHNodeType
				----INNER JOIN tblSalesPersonMapping SP ON Map.DHNodeId=SP.NodeId AND Map.DHNodeType=SP.NodeType 
				----WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(SP.ToDate,GETDATE())) AND (GETDATE() BETWEEN Map.FromDate AND ISNULL(Map.ToDate,GETDATE())) ANd H.SOID=@SOAreaNodeId AND H.SOAreaType=@SOAreaNodeType AND ISNULL(C.flgCoverageArea,0)=1 AND SP.PersonNodeId NOT IN(SELECT PersonNodeId FROM #PersonList)
			END
		
	 END
	

	SELECT V.*,C.RelConversionUnits INTO #PrdHier FROm VwSFAProductHierarchy V LEFT OUTER JOIN tblPrdMstrPackingUnits_ConversionUnits C ON C.SKUId=V.SKUNodeID WHERE BaseUOMID=3

	CREATE TABLE #Orders(OrderId INT,StoreId INT,CategoryNodeID INT,ProductId INT,Product VARCHAR(300),MRP FLOAT,Rate FLOAT, OrderQty INT,FreeQty INT, DiscValue FLOAT,ValBeforeTax FLOAT, TaxValue FLOAT, ValAfterTax FLOAT,Category VARCHAR(100),UOM VARCHAR(20),Grammage FLOAT,CategoryOrdr TINYINT,OrderQtyCS FLOAT,OrderQtyPcs INT)
	CREATE TABLE #Orders_StoreLevel(OrderId INT,StoreId INT,Store VARCHAR(200), DiscValue FLOAT,ValBeforeTax FLOAT, TaxValue FLOAT, ValAfterTax FLOAT)

	IF @flgDataScope=4
	BEGIN
		INSERT INTO #Orders_StoreLevel(OrderId,StoreId,Store,DiscValue,ValBeforeTax,TaxValue,ValAfterTax)
		SELECT  OM.OrderId,OM.StoreId,SM.StoreName,OM.TotDiscVal+OM.TotLineLevelDisc,OM.TotOrderValWDisc,OM.TotTaxVal,OM.NetOrderValue
		FROM            tblOrderMaster OM INNER JOIN
					--tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN
					tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN
					--#PrdHier Vw ON OD.ProductID = Vw.SKUNodeID INNER JOIN
					tblStoreMaster SM ON OM.StoreID = SM.StoreID
		WHERE CONVERT(VARCHAR(6),OM.OrderDate,112)=CONVERT(VARCHAR(6),@VisitDate,112) AND ISNULL(OM.OrderStatusId,0)<>3 AND SM.DBId=@SalesmanNodeId AND SM.DBNodeType=@SalesmanNodeType

		INSERT INTO #Orders(OrderId,StoreId,CategoryNodeID,ProductId,Product,MRP,Rate,OrderQty,FreeQty,DiscValue,ValBeforeTax,TaxValue,ValAfterTax,Category,UOM,Grammage,CategoryOrdr,OrderQtyCS,OrderQtyPcs)
		SELECT  OM.OrderId,OM.StoreId,Vw.CategoryNodeID,OD.ProductID,Vw.SKU ,Vw.MRP,OD.ProductRate,OD.OrderQty,OD.FreeQty,OD.TotLineDiscVal,OD.LineOrderValWDisc,OD.TotTaxValue, OD.NetLineOrderVal, Vw.Category,Vw.UOM ,Grammage,Vw.CatOrdr,
		--FLOOR(OD.OrderQty/Vw.RelConversionUnits),CAST(OD.OrderQty-(FLOOR(OD.OrderQty/Vw.RelConversionUnits)*Vw.RelConversionUnits) AS INT)
		ROUND(CAST(OD.OrderQty AS FLOAT)/Vw.RelConversionUnits,2),OD.OrderQty
		FROM            tblOrderMaster OM INNER JOIN
					tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN
					tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN
					#PrdHier Vw ON OD.ProductID = Vw.SKUNodeID INNER JOIN
					tblStoreMaster SM ON OM.StoreID = SM.StoreID
		WHERE CONVERT(VARCHAR(6),OM.OrderDate,112)=CONVERT(VARCHAR(6),@VisitDate,112) AND ISNULL(OM.OrderStatusId,0)<>3 AND SM.DBId=@SalesmanNodeId AND SM.DBNodeType=@SalesmanNodeType
	END
	ELSE
	BEGIN
		INSERT INTO #Orders_StoreLevel(OrderId,StoreId,Store,DiscValue,ValBeforeTax,TaxValue,ValAfterTax)
		SELECT  OM.OrderId,OM.StoreId,SM.StoreName,OM.TotDiscVal+OM.TotLineLevelDisc,OM.TotOrderValWDisc,OM.TotTaxVal,OM.NetOrderValue
		FROM            tblOrderMaster OM INNER JOIN
					--tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN
					--tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN
					--#PrdHier Vw ON OD.ProductID = Vw.SKUNodeID INNER JOIN
					tblStoreMaster SM ON OM.StoreID = SM.StoreID
					INNER JOIN #PersonList P ON OM.SalesPersonId=P.PersonNodeId AND OM.SalesPersonType=P.PersonNodeType
		WHERE CONVERT(VARCHAR(6),OM.OrderDate,112)=CONVERT(VARCHAR(6),@VisitDate,112) AND ISNULL(OM.OrderStatusId,0)<>3

		INSERT INTO #Orders(OrderId,StoreId,CategoryNodeID,ProductId,Product,MRP,Rate,OrderQty,FreeQty,DiscValue,ValBeforeTax,TaxValue,ValAfterTax,Category,UOM,Grammage,CategoryOrdr,OrderQtyCS,OrderQtyPcs)
		SELECT  OM.OrderId,OM.StoreId,Vw.CategoryNodeID,OD.ProductID,Vw.SKU ,Vw.MRP,OD.ProductRate,OD.OrderQty,OD.FreeQty,OD.TotLineDiscVal,OD.LineOrderValWDisc,OD.TotTaxValue, OD.NetLineOrderVal, Vw.Category,Vw.UOM ,Grammage,Vw.CatOrdr,
		--FLOOR(OD.OrderQty/Vw.RelConversionUnits),CAST(OD.OrderQty-(FLOOR(OD.OrderQty/Vw.RelConversionUnits)*Vw.RelConversionUnits) AS INT)
		ROUND(CAST(OD.OrderQty AS FLOAT)/Vw.RelConversionUnits,2),OD.OrderQty
		FROM            tblOrderMaster OM INNER JOIN
					tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN
					--tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN
					#PrdHier Vw ON OD.ProductID = Vw.SKUNodeID INNER JOIN
					tblStoreMaster SM ON OM.StoreID = SM.StoreID --INNER JOIN #Routes ON VM.RouteID = #Routes.RouteID 
					INNER JOIN #PersonList P ON OM.SalesPersonId=P.PersonNodeId AND OM.SalesPersonType=P.PersonNodeType
		WHERE CONVERT(VARCHAR(6),OM.OrderDate,112)=CONVERT(VARCHAR(6),@VisitDate,112) AND ISNULL(OM.OrderStatusId,0)<>3
	END
	--SELECT * FROM #Orders_StoreLevel
	--SELECT * FROM #Orders
	
	INSERT INTO #tmp(Product,[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,Lvl)
	SELECT DISTINCT 'GRAND TOTAL: ',SUM(OM.DiscValue),SUM(ValBeforeTax),SUM(TaxValue), SUM(OM.ValAfterTax),0
	FROM      #Orders_StoreLevel OM

	INSERT INTO #tmp(Product,[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,Lvl,StoreId)
	SELECT  OM.Store,SUM(OM.DiscValue),SUM(ValBeforeTax),SUM(TaxValue), SUM(OM.ValAfterTax),1,OM.StoreID
	FROM   #Orders_StoreLevel OM
	group by OM.Store,OM.StoreID
	
	INSERT INTO #tmpProduct(CategoryNodeID,ProductId,Product,MRP,Rate,[Order Qty],[Free Qty],[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,StoreId,OrderQtyCS,OrderQtyPcs)
	SELECT   OM.CategoryNodeID,OM.ProductID,OM.Product,MAX(MRP),MAX(Rate),SUM(OM.OrderQty),SUM(OM.FreeQty),SUM(OM.DiscValue), SUM(OM.ValBeforeTax),SUM(OM.TaxValue), SUM(OM.ValAfterTax),OM.StoreID,SUM(OrderQtyCS),SUM(OrderQtyPcs)
	FROM    #Orders OM  
	GROUP BY OM.CategoryNodeID,OM.ProductID, OM.Product,OM.StoreID
	
	INSERT INTO #tmp([Sr.],CategoryNodeID,ProductId,Product,MRP,Rate,[Stock Qty],[Order Qty],[Free Qty],[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,Lvl,StoreId,OrderQtyCS,OrderQtyPcs)
	SELECT [Sr.],CategoryNodeID,ProductId,Product,MRP,Rate,[Stock Qty],[Order Qty],[Free Qty],[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,2,StoreId,OrderQtyCS,OrderQtyPcs FROM #tmpProduct 
	--SELECT * FROM #tmp

	SELECT ProductId,Product,MRP,ROUND(Rate,2) Rate,[Order Qty] as [OrderQty],CAST([Free Qty] AS INT) as [FreeQty],ROUND([Disc Value],0) [DiscValue],ROUND(ValBeforeTax,0) ValBeforeTax,ROUND([Tax Value],0) [TaxValue],ROUND(ValAfterTax,0) ValAfterTax ,Lvl,StoreId,isnull([Stock Qty],0) as [StockQty],dbo.fnGetOrderString(OrderQtyCS,OrderQtyPcs) OrderStr
	FROM #tmp ORDER BY StoreId,Lvl,Product

End





