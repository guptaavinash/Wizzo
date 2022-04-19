



--[dbo].[spRptGetSKUWiseDaySummary]'11340C89-D778-44BB-BA8E-F6152ECB3A65','30-Apr-2020',0,0,1
CREATE PROCEDURE [dbo].[spRptGetSKUWiseMTDSummary] 
@PDACode VARCHAR(50)='',
@Date varchar(20),
@SalesmanNodeId INT=0, -- If SO is working, PersonId of Salesman working under him in case of @flgDataScope=2, Distributor Id in case of @flgDataScope=4 
@SalesmanNodeType INT=0,
@flgDataScope TINYINT=1 --1:Self, 2: Salesman working under(in this case only @PersonNodeId is to be used), 3: Self as well salesmen working under,4: Distributor
--@RouteId INT=0  
AS 

Begin  
CREATE TABLE #tmp([Sr.] INT,CategoryID INT,ProductId INT, Product VARCHAR(200),MRP FLOAT, Rate FLOAT,StoreCount INT,[Stock Qty] INT, [Order Qty] float,[Free Qty] float, [Disc Value] FLOAT,	ValBeforeTax FLOAT, [Tax Value] FLOAT, ValAfterTax FLOAT,Lvl tinyint,Category varchar(500),UOM varchar(20),CategoryOrdr TINYINT,OrderQtyCS FLOAT,OrderQtyPcs INT)
CREATE TABLE #tmpProduct([Sr.] INT IDENTITY(1,1),CategoryID INT,ProductId INT, Product VARCHAR(200),MRP FLOAT, Rate FLOAT,StoreCount INT,[Stock Qty] INT, [Order Qty] INT,[Free Qty] INT, [Disc Value] FLOAT,	ValBeforeTax FLOAT, [Tax Value] FLOAT, ValAfterTax FLOAT,Category varchar(500),UOMID int,UOM varchar(20),Grammage float,CategoryOrdr TINYINT,OrderQtyCS FLOAT,OrderQtyPcs INT)	

	 DECLARE @VisitDate Date
	 SET @VisitDate=CONVERT(Date,@Date,105)

	CREATE TABLE #RouteID (RouteID INT,RouteNodeType TINYINT)
	CREATE TABLE #PersonList(PersonNodeId INT,PersonNodeType INT)
	
	DECLARE @ASMAreaNodeId INT
	DECLARE @ASMAreaNodeType INT
	DECLARE @PDAID INT  
	DECLARE @PersonID INT  
	DECLARE @PersonType INT  
	 
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

				--Distributor Salesmna working under SO
				----INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
				----SELECT DISTINCT SP.PersonNodeId,SP.PersonType
				----FROM #SalesHier H INNER JOIN tblCompanySalesStructure_DistributorMapping Map ON H.SOID=Map.SHNodeId AND H.ASMAreaNodeType=Map.SHNodeType
				----INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=Map.DHNodeType
				----INNER JOIN tblSalesPersonMapping SP ON Map.DHNodeId=SP.NodeId AND Map.DHNodeType=SP.NodeType 
				----WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(SP.ToDate,GETDATE())) AND (GETDATE() BETWEEN Map.FromDate AND ISNULL(Map.ToDate,GETDATE())) ANd H.SOID=@SOAreaNodeId AND H.SOAreaType=@SOAreaNodeType AND ISNULL(C.flgCoverageArea,0)=1 AND SP.PersonNodeId NOT IN(SELECT PersonNodeId FROM #PersonList)
			END   	
		  
		  INSERT INTO #RouteID(RouteID,RouteNodeType)
		  SELECT distinct CH.NodeID,CH.NodeType
				FROM tblSalesPersonMapping(nolock) P
				INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
				INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
				INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
				INNER JOIN #PersonList PL ON P.PersonNodeId=PL.PersonNodeId AND P.PersonType=PL.PersonNodeType
				WHERE ISNULL(C.flgRoute,0)=1  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) 
				

		  --SELECT DISTINCT RouteNodeId,RouteNodeType FROM tblRouteCalendar(Nolock) WHERE SONodeId=@PersonID AND SONodeType=@PersonType AND MONTH(VisitDate)=MONTH(GETDATE())
		  --SELECT R.NodeID,R.NodeType FROM tblSalesPersonMapping PM INNER JOIN tblDBRSalesStructureRouteMstr R ON R.NodeID=PM.NodeID AND R.NodeType=PM.NodeType
		  --WHERE PersonNodeID=@PersonID AND PersonType=@PersonType AND GETDATE() BETWEEN FROMDATE AND TODATE  
		 
	 END
	
	SELECT V.*,C.RelConversionUnits INTO #PrdHier FROm VwSFAProductHierarchy V LEFT OUTER JOIN tblPrdMstrPackingUnits_ConversionUnits C ON C.SKUId=V.SKUNodeID WHERE BaseUOMID=3

	CREATE TABLE #Orders(OrderId INT,StoreId INT,CategoryID INT,ProductId INT,Product VARCHAR(300),MRP FLOAT,Rate FLOAT, OrderQty INT,FreeQty INT, DiscValue FLOAT,ValBeforeTax FLOAT, TaxValue FLOAT, ValAfterTax FLOAT,Category VARCHAR(100),UOMId INT,UOM VARCHAR(20),Grammage FLOAT,CategoryOrdr TINYINT,OrderQtyCS FLOAT,OrderQtyPcs INT)
	CREATE TABLE #Orders_StoreLevel(OrderId INT,StoreId INT, DiscValue FLOAT,ValBeforeTax FLOAT, TaxValue FLOAT, ValAfterTax FLOAT)

	IF @flgDataScope=4
	BEGIN
		INSERT INTO #Orders_StoreLevel(OrderId,StoreId,DiscValue,ValBeforeTax,TaxValue,ValAfterTax)
		SELECT  OM.OrderId,OM.StoreId,OM.TotDiscVal+OM.TotLineLevelDisc,OM.TotOrderValWDisc,OM.TotTaxVal,OM.NetOrderValue
		FROM            tblOrderMaster OM INNER JOIN
					--tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN
					tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN
					--#PrdHier Vw ON OD.ProductID = Vw.SKUNodeID INNER JOIN
					tblStoreMaster SM ON OM.StoreID = SM.StoreID
		WHERE CONVERT(VARCHAR(6),(OM.OrderDate),112)=CONVERT(VARCHAR(6),@VisitDate,112) AND ISNULL(OM.OrderStatusId,0)<>3 AND SM.DBId=@SalesmanNodeId AND SM.DBNodeType=@SalesmanNodeType

		INSERT INTO #Orders(OrderId,StoreId,CategoryID,ProductId,Product,MRP,Rate,OrderQty,FreeQty,DiscValue,ValBeforeTax,TaxValue,ValAfterTax,Category,UOMId,UOM,Grammage,CategoryOrdr,OrderQtyCS,OrderQtyPcs)
		SELECT  OM.OrderId,OM.StoreId,VW.CategoryNodeID,OD.ProductID,Vw.SKU,Vw.MRP,OD.ProductRate,OD.OrderQty,OD.FreeQty,OD.TotLineDiscVal,OD.LineOrderValWDisc,OD.TotTaxValue, OD.NetLineOrderVal, Vw.Category,Vw.UOMId,Vw.UOM, Grammage,Vw.CatOrdr,
		--FLOOR(OD.OrderQty/Vw.RelConversionUnits),CAST(OD.OrderQty-(FLOOR(OD.OrderQty/Vw.RelConversionUnits)*Vw.RelConversionUnits) AS INT)
		ROUND(CAST(OD.OrderQty AS FLOAT)/Vw.RelConversionUnits,2),OD.OrderQty
		FROM            tblOrderMaster OM INNER JOIN
					tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN
					tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN
					#PrdHier Vw ON OD.ProductID = Vw.SKUNodeID INNER JOIN
					tblStoreMaster SM ON OM.StoreID = SM.StoreID
		WHERE CONVERT(VARCHAR(6),(OM.OrderDate),112)=CONVERT(VARCHAR(6),@VisitDate,112) AND ISNULL(OM.OrderStatusId,0)<>3 AND SM.DBId=@SalesmanNodeId AND SM.DBNodeType=@SalesmanNodeType
	END
	ELSE
	BEGIN
		INSERT INTO #Orders_StoreLevel(OrderId,StoreId,DiscValue,ValBeforeTax,TaxValue,ValAfterTax)
		SELECT  OM.OrderId,OM.StoreId,OM.TotDiscVal+OM.TotLineLevelDisc,OM.TotOrderValWDisc,OM.TotTaxVal,OM.NetOrderValue
		FROM            tblOrderMaster OM INNER JOIN
					--tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN
					--tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN
					--#PrdHier Vw ON OD.ProductID = Vw.SKUNodeID INNER JOIN
					tblStoreMaster SM ON OM.StoreID = SM.StoreID
					INNER JOIN #PersonList P ON OM.SalesPersonId=P.PersonNodeId AND OM.SalesPersonType=P.PersonNodeType
		WHERE CONVERT(VARCHAR(6),(OM.OrderDate),112)=CONVERT(VARCHAR(6),@VisitDate,112) AND ISNULL(OM.OrderStatusId,0)<>3

		INSERT INTO #Orders(OrderId,StoreId,CategoryID,ProductId,Product,MRP,Rate,OrderQty,FreeQty,DiscValue,ValBeforeTax,TaxValue,ValAfterTax,Category,UOMId,UOM,Grammage,CategoryOrdr,OrderQtyCS,OrderQtyPcs)
		SELECT  OM.OrderId,OM.StoreId,Vw.CategoryNodeID,OD.ProductID,Vw.SKU,Vw.MRP,OD.ProductRate,OD.OrderQty,OD.FreeQty,OD.TotLineDiscVal,OD.LineOrderValWDisc,OD.TotTaxValue, OD.NetLineOrderVal, Vw.Category,Vw.UOMId,Vw.UOM, Grammage,Vw.CatOrdr,
		--FLOOR(OD.OrderQty/Vw.RelConversionUnits),CAST(OD.OrderQty-(FLOOR(OD.OrderQty/Vw.RelConversionUnits)*Vw.RelConversionUnits) AS INT)
		ROUND(CAST(OD.OrderQty AS FLOAT)/Vw.RelConversionUnits,2),OD.OrderQty
		FROM            tblOrderMaster OM INNER JOIN
					tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN
					--tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN
					#PrdHier Vw ON OD.ProductID = Vw.SKUNodeID INNER JOIN
					tblStoreMaster SM ON OM.StoreID = SM.StoreID --INNER JOIN #Routes ON VM.RouteID = #Routes.RouteID 
					INNER JOIN #PersonList P ON OM.SalesPersonId=P.PersonNodeId AND OM.SalesPersonType=P.PersonNodeType
		WHERE CONVERT(VARCHAR(6),(OM.OrderDate),112)=CONVERT(VARCHAR(6),@VisitDate,112) AND ISNULL(OM.OrderStatusId,0)<>3
	END
	UPDATE #Orders SET UOMId=11,UOM='KG' WHERE UOMId IN(14,15)
	UPDATE #Orders SET UOMId=12,UOM='Lt' WHERE UOMId IN(13)
	--SELECT * FROM #Orders_StoreLevel
	--SELECT * FROM #Orders

	INSERT INTO #tmp(Product,StoreCount,[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,Lvl)
	SELECT DISTINCT 'GRAND TOTAL: ',COUNT(DISTINCT OM.StoreId),SUM(DiscValue),SUM(ValBeforeTax),SUM(TaxValue), SUM(OM.ValAfterTax),0
	FROM      #Orders_StoreLevel OM

	INSERT INTO #tmpProduct(CategoryID,ProductId,Product,MRP,Rate,StoreCount,[Order Qty],[Free Qty],[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,Category,UOM,Grammage,CategoryOrdr,OrderQtyCS,OrderQtyPcs)
	SELECT   OM.CategoryID,OM.ProductID,OM.Product,MAX(MRP),MAX(Rate),COUNT(DISTINCT OM.StoreId),SUM(OM.OrderQty),SUM(OM.FreeQty),SUM(OM.DiscValue), SUM(OM.ValBeforeTax),SUM(OM.TaxValue), SUM(OM.ValAfterTax),OM.Category,OM.UOM ,OM.Grammage,OM.CategoryOrdr,SUM(OM.OrderQtyCS),SUM(OM.OrderQtyPcs)
	FROM    #Orders OM
	GROUP BY OM.CategoryID,OM.ProductID, OM.Product,OM.Grammage,OM.UOM,OM.Category,OM.CategoryOrdr

  
	SELECT CategoryID,Category,COUNT(DISTINCT OM.StoreId) as StoreCnt --,case when UOMID in(1,4) then 'Lt' ELSE 'Kg' end  AS UOM 
	INTO #CatStoreCnt
	FROM   #Orders OM
	GROUP BY CategoryID,Category
	
	INSERT INTO #tmp([Sr.],CategoryID,ProductId,Product,MRP,Rate,StoreCount,[Stock Qty],[Order Qty],[Free Qty],[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,Lvl,Category,UOM,CategoryOrdr,OrderQtyCS,OrderQtyPcs)
	SELECT NULL,CategoryID,0,'CATEGORY :'+Category,null,null,0,ROUND(SUM([Stock Qty]*Grammage),2),ROUND(SUM([Order Qty]*Grammage),2),ROUND(SUM([Free Qty]*Grammage),2),SUM([Disc Value]),SUM(ValBeforeTax),SUM([Tax Value]),SUM(ValAfterTax),1, Category,'Kg',CategoryOrdr,SUM(OrderQtyCS),SUM(OrderQtyPcs) FROM #tmpProduct
	Group by CategoryID,Category,CategoryOrdr

	update A set StoreCount=B.StoreCnt FROM #tmp A join #CatStoreCnt B ON A.Category=B.Category AND Lvl=1
	
	INSERT INTO #tmp([Sr.],CategoryID,ProductId,Product,MRP,Rate,StoreCount,[Stock Qty],[Order Qty],[Free Qty],[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,Lvl,Category,UOM,CategoryOrdr,OrderQtyCS,OrderQtyPcs)
	SELECT [Sr.],CategoryID,ProductId,Product,MRP,Rate,StoreCount,[Stock Qty],[Order Qty],[Free Qty],[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,2,Category,'Pcs',CategoryOrdr ,OrderQtyCS,OrderQtyPcs
	FROM #tmpProduct
	--SELECT * FROM #tmp

--UPDATE #tmp SET #tmp.[Disc Value]=#tmp.[Disc Value] + AA.[Discount Value] FROM #tmp, (SELECT SUM([Disc Value]) [Discount Value] FROM #tmp WHERE ISNULL(ProductId,0)<>0) AA 
--WHERE #tmp.ProductId IS NULL
	
	SELECT CategoryID,ProductId,Product,MRP,ROUND(Rate,2) Rate,ISNULL(StoreCount,0) [NoofStores],CAST([Order Qty] AS VARCHAR) as  [OrderQty],CAST([Free Qty] AS INT) as [FreeQty],ROUND([Disc Value],0) [DiscValue],ROUND(ValBeforeTax,0) ValBeforeTax,ROUND([Tax Value],0) [TaxValue],ROUND(ValAfterTax,0) ValAfterTax ,Lvl,Category,UOM,dbo.fnGetOrderString(OrderQtyCS,OrderQtyPcs) OrderStr
	FROM #tmp ORDER BY CategoryOrdr,Lvl,Product


End


