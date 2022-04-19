

-- [spRptGetStoreWiseDaySummary]  '354010084603910','22-Dec-2017'

CREATE PROCEDURE [dbo].[spRptGetStoreWiseMTDSummary]  

@PDACode VARCHAR(50)='',

@Date varchar(20),

@SalesmanNodeId INT=0, -- If SO is working, PersonId of Salesman working under him in case of @flgDataScope=2, Distributor Id in case of @flgDataScope=4 

@SalesmanNodeType INT=0,

@flgDataScope TINYINT=1 --1:Self, 2: Salesman working under(in this case only @PersonNodeId is to be used), 3: Self as well salesmen working under,4: Distributor

--@RouteId INT=0  

AS 



BEGIN  



	DECLARE @TotalLines INT=0

	DECLARE @ASMAreaNodeId INT

	DECLARE @ASMAreaNodeType INT

	DECLARE @LinesPerBill FLOAT=0

	DECLARE @PDAID INT  

	DECLARE @PersonID INT  

	DECLARE @PersonType INT 

	DECLARE @VisitDate Date



	CREATE TABLE #tmp([Sr.] INT IDENTITY(1,1),StoreId INT,Store VARCHAR(200),[Lines per Bill] INT,[Stock Value] FLOAT, [Disc Value] FLOAT,[ValAfterTax] FLOAT, [Tax Value] FLOAT, [ValBeforeTax] FLOAT)

	CREATE TABLE #tmpFinal([Sr.] INT,StoreId INT,Store VARCHAR(200),[Lines per Bill] INT,[Stock Value] FLOAT, [Disc Value] FLOAT,[ValAfterTax] FLOAT, [Tax Value] FLOAT, [ValBeforeTax] FLOAT,Lvl Tinyint)

--CREATE TABLE #tmpProduct([Sr.] INT IDENTITY(1,1),ProductId INT, Product VARCHAR(200),MRP FLOAT, Rate FLOAT,[Stock Qty] INT, [Order Qty] INT,[Free Qty] INT, [Disc Value] FLOAT,	[Net Value] FLOAT, [Tax Value] FLOAT, [Gross Value] FLOAT)	

	CREATE TABLE #PersonList(PersonNodeId INT,PersonNodeType INT)

	 CREATE TABLE #RouteID (RouteID INT,RouteNodeType TINYINT)



	 SET @VisitDate=CONVERT(Date,@Date,105) 



	  

	 

	  IF @PDACode<>''

	 BEGIN

		 SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

			IF @flgDataScope=1 OR @flgDataScope=0

			BEGIN	

				--SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@PDAID  

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

				--Self 

				--SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@PDAID  AND GETDATE() BETWEEN DateFrom AND DateTo

	  

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



	----			--Distributor Salesmna working under SO

	----			INSERT INTO #PersonList(PersonNodeId,PersonNodeType)

	----			SELECT DISTINCT SP.PersonNodeId,SP.PersonType

	----			FROM #SalesHier H INNER JOIN tblCompanySalesStructure_DistributorMapping Map ON H.SOID=Map.SHNodeId AND H.SOAreaType=Map.SHNodeType

	----			INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=Map.DHNodeType

	----			INNER JOIN tblSalesPersonMapping SP ON Map.DHNodeId=SP.NodeId AND Map.DHNodeType=SP.NodeType 

	----			WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(SP.ToDate,GETDATE())) AND (GETDATE() BETWEEN Map.FromDate AND ISNULL(Map.ToDate,GETDATE())) ANd H.SOID=@SOAreaNodeId AND H.SOAreaType=@SOAreaNodeType AND ISNULL(C.flgCoverageArea,0)=1 AND SP.PersonNodeId
 ----NOT IN(SELECT PersonNodeId FROM #PersonList)

			END   	

		  
		    INSERT INTO #RouteID(RouteID,RouteNodeType)
			SELECT distinct CH.NodeID,CH.NodeType
				FROM tblSalesPersonMapping(nolock) P
				INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
				INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
				INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
				INNER JOIN #PersonList PL ON P.PersonNodeId=PL.PersonNodeId AND P.PersonType=PL.PersonNodeType
				WHERE ISNULL(C.flgRoute,0)=1  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) 


		  ----SELECT DISTINCT RouteNodeId,RouteNodeType FROM tblRouteCalendar(Nolock) WHERE SONodeId=@PersonID AND SONodeType=@PersonType AND MONTH(VisitDate)=MONTH(GETDATE())

		  ----INSERT INTO #RouteID(RouteID,RouteNodeType)

		  ----SELECT R.NodeID,R.NodeType FROM tblSalesPersonMapping PM INNER JOIN tblDBRSalesStructureRouteMstr R ON R.NodeID=PM.NodeID AND R.NodeType=PM.NodeType  

		  ----WHERE PersonNodeID=@PersonID AND PersonType=@PersonType AND GETDATE() BETWEEN FROMDATE AND TODATE  
  

	 END



	SELECT * INTO #PrdHier FROm VwSFAProductHierarchy



	CREATE TABLE #Orders(OrderId INT,StoreId INT,ProductId INT,Product VARCHAR(300),Rate FLOAT, OrderQty INT,FreeQty INT, DiscValue FLOAT,ValBeforeTax FLOAT, TaxValue FLOAT, ValAfterTax FLOAT,Grammage FLOAT)

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



		INSERT INTO #Orders(OrderId,StoreId,ProductId,Product,Rate,OrderQty,FreeQty,DiscValue,ValBeforeTax,TaxValue,ValAfterTax,Grammage)

		SELECT  OM.OrderId,OM.StoreId,OD.ProductID,Vw.SKUShortDescr,OD.ProductRate,OD.OrderQty,OD.FreeQty,OD.TotLineDiscVal,OD.LineOrderValWDisc,OD.TotTaxValue,OD.NetLineOrderVal, Grammage

		FROM        tblOrderMaster OM INNER JOIN

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

		FROM        tblOrderMaster OM INNER JOIN

					--tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN

					--tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN

					--#PrdHier Vw ON OD.ProductID = Vw.SKUNodeID INNER JOIN

					tblStoreMaster SM ON OM.StoreID = SM.StoreID

					INNER JOIN #PersonList P ON OM.SalesPersonId=P.PersonNodeId AND OM.SalesPersonType=P.PersonNodeType

		WHERE CONVERT(VARCHAR(6),OM.OrderDate,112)=CONVERT(VARCHAR(6),@VisitDate,112) AND ISNULL(OM.OrderStatusId,0)<>3



		INSERT INTO #Orders(OrderId,StoreId,ProductId,Product,Rate,OrderQty,FreeQty,DiscValue,ValBeforeTax,TaxValue,ValAfterTax,Grammage)

		SELECT  OM.OrderId,OM.StoreId,OD.ProductID,Vw.SKUShortDescr,OD.ProductRate,OD.OrderQty,OD.FreeQty,OD.TotLineDiscVal,OD.LineOrderValWDisc,OD.TotTaxValue,OD.NetLineOrderVal, Grammage

		FROM        tblOrderMaster OM INNER JOIN

					tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN

					--tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN

					#PrdHier Vw ON OD.ProductID = Vw.SKUNodeID INNER JOIN

					tblStoreMaster SM ON OM.StoreID = SM.StoreID --INNER JOIN #Routes ON VM.RouteID = #Routes.RouteID 

					INNER JOIN #PersonList P ON OM.SalesPersonId=P.PersonNodeId AND OM.SalesPersonType=P.PersonNodeType

		WHERE CONVERT(VARCHAR(6),OM.OrderDate,112)=CONVERT(VARCHAR(6),@VisitDate,112) AND ISNULL(OM.OrderStatusId,0)<>3

	END

	--SELECT * FROM #Orders_StoreLevel

	--SELECT * FROM #Orders





	INSERT INTO #tmp(StoreId,Store,[Disc Value],[ValBeforeTax],[Tax Value],[ValAfterTax])

	SELECT DISTINCT OM.StoreID,OM.Store,SUM(OM.DiscValue),SUM(ValBeforeTax),SUM(TaxValue), SUM(OM.ValAfterTax)

	FROM   #Orders_StoreLevel OM

	GROUP BY OM.StoreID,OM.Store

	

	--store level

	SELECT   OM.StoreId,COUNT(CAST(OM.ProductId AS VARCHAR)+'-'+ CAST(OM.OrderId AS VARCHAR)) AS Lines,COUNT(DISTINCT OM.OrderId) ProdCalls INTO #TmpProduct

	FROM      #Orders OM

	GROUP BY OM.StoreId

	--SELECT * FROM #TmpProduct

	

	UPDATE A SET [Lines per Bill]=CASE B.ProdCalls WHEN 0 THEN 0 ELSE ROUND(B.Lines/CAST(B.ProdCalls AS FLOAT),2) END

	FROM #tmp A INNER JOIN #TmpProduct B ON A.StoreId=B.StoreId



	--Overall

	SELECT @LinesPerBill=CASE COUNT(DISTINCT OM.OrderId) WHEN 0 THEN 0 ELSE ROUND(COUNT(CAST(OM.ProductId AS VARCHAR)+'-'+ CAST(OM.OrderId AS VARCHAR))/CAST(COUNT(DISTINCT OM.OrderId) AS FLOAT),2) END

	FROM   #Orders OM

	PRINT '@LinesPerBill=' + CAST(@LinesPerBill AS VARCHAR)



	INSERT INTO #tmpFinal(Store,[Lines per Bill],[Stock Value],[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,Lvl)

	SELECT 'GRAND TOTAL: ',@LinesPerBill,SUM([Stock Value]),SUM([Disc Value]),SUM(ValBeforeTax),SUM([Tax Value]),SUM(ValAfterTax),0 FROM #tmp

	

	INSERT INTO #tmpFinal([Sr.],StoreId, Store,[Lines per Bill],[Stock Value],[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,Lvl)

	SELECT [Sr.],StoreId, Store,[Lines per Bill],[Stock Value],[Disc Value],ValBeforeTax,[Tax Value],ValAfterTax,1 FROM #tmp

	--SELECT * FROM #tmp





	SELECT Store,[Lines per Bill] as [LinesperBill],ISNULL(ROUND([Stock Value],0.0),0.0) [StockValue],ROUND([Disc Value],0) [DiscValue],ROUND(ValBeforeTax,0) ValBeforeTax,ROUND([Tax Value],0) [TaxValue],ROUND(ValAfterTax,0) ValAfterTax ,Lvl

	FROM #tmpFinal ORDER BY Lvl



End










