-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spOLAPPopulateDailyTables]'05-Dec-2021'
CREATE PROCEDURE [dbo].[spOLAPPopulateDailyTables] 
@WeekEnding DATE
AS
BEGIN
	PRINT @WeekEnding
	SET DATEFirst 1
	
	UPDATE A SET A.SalesPersonID=B.PersonNodeID,A.SalesPersonType=B.PersonType
	FROM tblVisitMaster A INNER JOIN tblSalesPersonMapping B ON A.RouteID=B.NodeID AND A.RouteType=B.NodeType AND (A.VisitDate BETWEEN B.FromDate AND B.ToDate) 
	WHERE ISNULL(SalesPersonID,0)=0

	CREATE TABLE #tmp([ChannelId] [int] NOT NULL DEFAULT 0,[SEId] [int]  NOT NULL DEFAULT 0,[SENodeType] [int]  NOT NULL DEFAULT 0,[RouteId] [int]  NOT NULL DEFAULT 0,[RouteId_Org] [int]  NOT NULL DEFAULT 0,[RouteNodeType] [int]  NOT NULL DEFAULT 0,[RouteNodeType_Org] [int]  NOT NULL DEFAULT 0,[StoreId] [int] NOT NULL,[SKUId] [int] NOT NULL,[Date] [date] NOT NULL,[WeekEnding] [date] NOT NULL,[WeekEndingMonthly] [date] NOT NULL,[RptMonthYear] [int] NOT NULL,[TotalLinesOrdered] [int] NOT NULL DEFAULT 0,[OrderQty] [int] NOT NULL DEFAULT 0,[TotPrice] [numeric](38, 6) NOT NULL DEFAULT 0,[OrderVolumeInCase] [numeric](38, 6),[OrderVolumeKG] [numeric](38, 6),[OrderVolumeLt] [numeric](38, 6),[OrderGrossVal] [numeric](38, 6) NOT NULL DEFAULT 0,[OrderTaxVal] [numeric](38, 6) NOT NULL DEFAULT 0,[OrderNetVal] [numeric](38, 6) NOT NULL DEFAULT 0,[FreeOrderQty] [int] NOT NULL DEFAULT 0,[FreeOrderVolumeKG] [numeric](38, 6),[FreeOrderVolumeLt] [numeric](38, 6),[ValueForFreeOrderProduct] [numeric](38, 6) NOT NULL DEFAULT 0,[FlgDistrbn] [tinyint] NOT NULL DEFAULT 0,[FlgDistrbn2X] [tinyint] NOT NULL DEFAULT 0,[FlgNewStore] [tinyint] NOT NULL DEFAULT 0,[FlgNewStore_SKULvl] [tinyint] NOT NULL DEFAULT 0,[WeeksSinceLastBought] [int] NOT NULL DEFAULT 0,[FlgFirstTimeBought] [tinyint] NOT NULL DEFAULT 0,flgOrderType TINYINT DEFAULT 0 NOT NULL,flgOrderSource TINYINT DEFAULT 0 NOT NULL,StoreCategoryId [int] NOT NULL DEFAULT 0,StoreClassId [int] NOT NULL DEFAULT 0,StoreTypeId [int] NOT NULL DEFAULT 0)

	CREATE TABLE #tmp_Inv([ChannelId] [int] NOT NULL DEFAULT 0,[SEId] [int]  NOT NULL DEFAULT 0,[SENodeType] [int]  NOT NULL DEFAULT 0,[RouteId] [int]  NOT NULL DEFAULT 0,[RouteId_Org] [int]  NOT NULL DEFAULT 0,[RouteNodeType] [int]  NOT NULL DEFAULT 0,[RouteNodeType_Org] [int]  NOT NULL DEFAULT 0,[StoreId] [int] NOT NULL,[SKUId] [int] NOT NULL,BrandId INT,[Date] [date] NOT NULL,[WeekEnding] [date] NOT NULL,[WeekEndingMonthly] [date] NOT NULL,[RptMonthYear] [int] NOT NULL,[TotalLinesInvoiced] [int] NOT NULL DEFAULT 0,[InvQty] [int] NOT NULL DEFAULT 0,[InvVolumeKG] [numeric](38, 6),[InvVolumeLt] [numeric](38, 6),[InvGrossVal] [numeric](38, 6) NOT NULL DEFAULT 0,[InvTaxVal] [numeric](38, 6) NOT NULL DEFAULT 0,	[InvNetVal] [numeric](38, 6) NOT NULL DEFAULT 0,[InvFreeQty] [int] NOT NULL DEFAULT 0,[InvFreeVolumeKG] [numeric](38, 6),[InvFreeVolumeLt] [numeric](38, 6),[ValueForInvFreeProduct] [numeric](38, 6) NOT NULL DEFAULT 0,[FlgDistrbn_Invoice] [tinyint] NOT NULL DEFAULT 0,flgInvUpdateSource TINYINT DEFAULT 0 NOT NULL,StoreCategoryId [int] NOT NULL DEFAULT 0,StoreClassId [int] NOT NULL DEFAULT 0,StoreTypeId [int] NOT NULL DEFAULT 0,[FlgNewStore] [tinyint] NOT NULL DEFAULT 0)

	SELECT OM.RouteNodeId AS RouteId,OM.RouteNodeType,ISNULL(OM.VisitId,0) AS VisitId,OM.OrderId,ISNULL(OM.EntryPersonNodeId,SalesPersonID) SalesPersonID,ISNULL(OM.EntryPersonNodetype,SalesPersonType) SalesPersonType, OM.StoreId,SM.ChannelId StoreChannelId,OM.OrderDate, OD.ProductId,SKU.Descr AS SKUName,OD.ProductRate,SKU.Grammage,sku.PcsInBox, ISNULL(SKU.UOMId,0) AS UOMId,OD.OrderQty,OD.OrderQty*OD.ProductRate AS TotPrice,OD.LineOrderVal, OD.TotTaxValue,OD.NetLineOrderVal,OrderStatusID,ISNULL(OD.FreeQty,0) AS FreeQty,OD.FreeQty*(OD.ProductRate-((OD.ProductRate/((1)+OD.[TaxRate]/(100)))*(OD.[TaxRate]/(100)))) AS ValueForFreeProduct,CASE WHEN OM.OrderSourceid=1 AND ISNULL(OM.VisitId,0)<>0 THEN 1 WHEN  OM.OrderSourceid=1 AND ISNULL(OM.VisitId,0)=0 THEN 2 WHEN OM.OrderSourceid=2 THEN 3 END AS flgOrderType, dbo.fncUTLGetWeekEndDate(OM.OrderDate) AS WeekEnding, CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, OM.OrderDate)), OM.OrderDate))<>DATEPART(mm, OM.OrderDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,OM.OrderDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, OM.OrderDate)), OM.OrderDate)END AS WeekEndingMonthly,CONVERT(VARCHAR(6),OM.OrderDate,112) AS RptMonthYear,ISNULL(OM.LoginIDIns,0) LoginIDIns,0 AS flgOrderSource INTO #Orders
	FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
	INNER JOIN tblPrdMstrSKULvl SKU ON OD.ProductId=SKU.NodeId
	INNER JOIN tblStoreMaster  SM ON OM.StoreId=SM.StoreID
	--LEFT JOIN tblVisitMaster VM ON  OM.VisitId=VM.VisitId
	WHERE dbo.fncUTLGetWeekEndDate(OM.OrderDate)=@WeekEnding --and ISNULL(OM.OrderStatusID,0)<>3

	--UPDATE #Orders SET SalesPersonID=0,SalesPersonType=0 WHERE VisitId=0
	UPDATE #Orders SET SalesPersonID=0,SalesPersonType=0 WHERE VisitId=0 AND flgOrderType=3

	UPDATE A SET A.RouteId=B.RouteId,A.RouteNodeType=B.RouteNodeType from #Orders A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=b.StoreID 
	WHERE (A.OrderDate BETWEEN B.FromDate AND B.ToDate) AND A.RouteId=0
	
	UPDATE #Orders SET flgOrderSource=3 WHERE LoginIDIns>0	--DMS
	UPDATE #Orders SET flgOrderSource=2 WHERE flgOrderSource=0 AND SalesPersonType=220
	UPDATE #Orders SET flgOrderSource=1 WHERE flgOrderSource=0

	--SELECT * FROM #Orders ORDER BY flgOrderSource,SToreid,ProductId,orderdate
	

	PRINT 'Orders'
	INSERT INTO #tmp([ChannelId],[SEId],[SENodeType],[RouteId],[RouteId_Org],[RouteNodeType],[RouteNodeType_Org],[StoreId],[SKUId],[Date],[WeekEnding],[WeekEndingMonthly],[RptMonthYear],[TotalLinesOrdered],[OrderQty],OrderVolumeInCase,[OrderVolumeKG],[OrderVolumeLt],[OrderGrossVal],[OrderTaxVal],[OrderNetVal],FreeOrderQty,FreeOrderVolumeKG,FreeOrderVolumeLT, ValueForFreeOrderProduct,flgOrderType,flgOrderSource)
	SELECT StoreChannelId,SalesPersonID,SalesPersonType,RouteId,RouteId,RouteNodeType,RouteNodeType,StoreId,ProductId,OM.OrderDate,dbo.fncUTLGetWeekEndDate(OM.OrderDate) AS WeekEnding,CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, OM.OrderDate)), OM.OrderDate))<>DATEPART(mm, OM.OrderDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,OM.OrderDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, OM.OrderDate)), OM.OrderDate)END AS WeekEndingMonthly,CONVERT(VARCHAR(6),OM.OrderDate,112) AS RptMonthYear,COUNT(ProductId) TotalLinesOrdered,SUM(OrderQty) OrderQty,SUM(OrderQty/CAST(PcsInBox AS float)),SUM(OrderQty*CAST(Grammage AS FLOAT)) OrderVolumeKG,0 AS OrderVolumeLt ,SUM(LineOrderVal) OrderGrossVal,SUM(TotTaxValue) OrderTaxVal,SUM(NetLineOrderVal) OrderNetVal,SUM(FreeQty) FreeQty,SUM(FreeQty*CAST(Grammage AS FLOAT)) FreeOrderVolumeKG,0,SUM(ValueForFreeProduct) AS ValueForFreeProduct,flgOrderType, flgOrderSource
	FROM #Orders OM
	WHERE (OrderQty>0 OR FreeQty>0)  AND UOMId IN(11,14,15)
GROUP BY SalesPersonID,SalesPersonType,RouteId,RouteId,RouteNodeType,StoreId,ProductId,OM.OrderDate,dbo.fncUTLGetWeekEndDate(OM.OrderDate),CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, OM.OrderDate)), OM.OrderDate))<>DATEPART(mm, OM.OrderDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,OM.OrderDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, OM.OrderDate)), OM.OrderDate)END,CONVERT(VARCHAR(6),OM.OrderDate,112),StoreChannelId,flgOrderType,flgOrderSource
	UNION
	SELECT StoreChannelId,SalesPersonID,SalesPersonType,RouteId,RouteId,RouteNodeType,RouteNodeType,StoreId,ProductId,OM.OrderDate,dbo.fncUTLGetWeekEndDate(OM.OrderDate) AS WeekEnding,CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, OM.OrderDate)), OM.OrderDate))<>DATEPART(mm, OM.OrderDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,OM.OrderDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, OM.OrderDate)), OM.OrderDate)END AS WeekEndingMonthly,CONVERT(VARCHAR(6),OM.OrderDate,112) AS RptMonthYear,COUNT(ProductId) TotalLinesOrdered,SUM(OrderQty) OrderQty,SUM(OrderQty/CAST(PcsInBox AS float)),0 AS OrderVolumeKG,SUM(OrderQty*CAST(Grammage AS FLOAT)) OrderVolumeLT,SUM(LineOrderVal) OrderGrossVal,SUM(TotTaxValue) OrderTaxVal,SUM(NetLineOrderVal) OrderNetVal,SUM(FreeQty) FreeQty,0,SUM(FreeQty*CAST(Grammage AS FLOAT)) FreeOrderVolumeLT,SUM(ValueForFreeProduct) AS ValueForFreeProduct,flgOrderType, flgOrderSource
	FROM #Orders OM
	WHERE (OrderQty>0 OR FreeQty>0)  AND UOMId NOT IN(11,14,15)
GROUP BY SalesPersonID,SalesPersonType,RouteId,RouteId,RouteNodeType,StoreId,ProductId,OM.OrderDate,dbo.fncUTLGetWeekEndDate(OM.OrderDate),CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, OM.OrderDate)), OM.OrderDate))<>DATEPART(mm, OM.OrderDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,OM.OrderDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, OM.OrderDate)), OM.OrderDate)END,CONVERT(VARCHAR(6),OM.OrderDate,112),StoreChannelId,flgOrderType,flgOrderSource
		
	--SELECT * FROM #tmp ORDER BY SToreid
	 
	 PRINT 'Invoice'
	SELECT DISTINCT OM.RouteNodeId AS RouteId,OM.RouteNodeType,ISNULL(OM.VisitId,0) AS VisitId,ISNULL(OM.EntryPersonNodeId,0) SalesPersonID,ISNULL(OM.EntryPersonNodetype,0) SalesPersonType, OM.StoreId,SM.ChannelId StoreChannelId,SKU.NodeId AS SKUId,SKU.NodeType AS SKUNodeType,IM.InvId,IM.DBRNodeId,IM.DBRNodeType,IM.InvDate,Id.ProductId,Id.PrdBatchId,ISNULL(ID.ProductRate,0) ProductRate,SKU.Grammage,ISNULL(SKU.UOMId,0) AS UOMId,ID.InvQty, ISNULL(ID.LineInvVal,0) LineInvVal,ISNULL(ID.TotTaxValue,0) TotTaxValue,ISNULL(ID.NetLineInvVal,0) NetLineInvVal,flgInvStatus, ID.FreeQty,ISNULL(ID.FreeQty*(ID.ProductRate-((ID.ProductRate/((1)+ID.[TaxRate]/(100)))*(ID.[TaxRate]/(100)))),0) AS ValueForFreeProduct,CASE WHEN OM.OrderSourceid=1 AND ISNULL(OM.VisitId,0)<>0 THEN 1 WHEN  OM.OrderSourceid=1 AND ISNULL(OM.VisitId,0)=0 THEN 2 WHEN OM.OrderSourceid=2 THEN 3 END AS flgOrderType,CASE ISNULL(IM.LoginIDIns,0) WHEN 0 THEN 2 ELSE 1 END AS flgInvUpdateSource,ISNULL(OM.LoginIDIns,0) OrderLoginIDIns,0 AS flgOrderSource INTO #Invoice
	FROM tblInvMaster IM  INNER JOIN tblInvDetail ID ON IM.InvId=ID.InvId
	INNER JOIN tblOrderMaster OM ON IM.OrderID=OM.OrderID
	INNER JOIN tblStoreMaster  SM ON OM.StoreId=SM.StoreID
	INNER JOIN tblPrdMstrSKULvl SKU ON ID.ProductId=SKU.NodeId
	WHERE IM.flgInvStatus<>2 AND (ID.InvQty>0 OR ID.FreeQty>0)
	AND dbo.fncUTLGetWeekEndDate(IM.InvDate)=@WeekEnding	
	
	UPDATE #Invoice SET SalesPersonID=0,SalesPersonType=0 WHERE VisitId=0 AND flgOrderType=3

	UPDATE A SET A.RouteId=B.RouteId,A.RouteNodeType=B.RouteNodeType from #Invoice A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=b.StoreID 
	WHERE (A.InvDate BETWEEN B.FromDate AND B.ToDate) AND A.RouteId=0
		
	UPDATE #Invoice SET flgOrderSource=3 WHERE OrderLoginIDIns>0	--DMS
	UPDATE #Invoice SET flgOrderSource=2 WHERE flgOrderSource=0 AND SalesPersonType=220
	UPDATE #Invoice SET flgOrderSource=1 WHERE flgOrderSource=0
	
	--SELECT * FROM #Invoice order by StoreId
		
	INSERT INTO #tmp_Inv([ChannelId],[SEId],[SENodeType],[RouteId],[RouteId_Org],[RouteNodeType],[RouteNodeType_Org],[StoreId],[SKUId],BrandId,[Date],[WeekEnding],[WeekEndingMonthly],[RptMonthYear],[TotalLinesInvoiced],[InvQty],[InvVolumeKG],[InvVolumeLt],[InvGrossVal],[InvTaxVal],[InvNetVal],[InvFreeQty],[InvFreeVolumeKG],[InvFreeVolumeLt],[ValueForInvFreeProduct],flgInvUpdateSource)
	SELECT StoreChannelId,SalesPersonID,SalesPersonType,RouteId,RouteId,RouteNodeType,RouteNodeType,StoreId,SKUId,0,InvDate,dbo.fncUTLGetWeekEndDate(IM.InvDate) AS WeekEnding,CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, IM.InvDate)), IM.InvDate))<>DATEPART(mm, IM.InvDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,IM.InvDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, IM.InvDate)), IM.InvDate)END AS WeekEndingMonthly,CONVERT(VARCHAR(6),IM.InvDate,112) AS RptMonthYear,COUNT(SKUId) AS TotalLinesInvoiced,SUM(InvQty) AS InvQty, SUM(InvQty*CAST(Grammage AS FLOAT)) InvVolumeKG,0 AS InvVolumeLt,SUM(LineInvVal) InvGrossVal,SUM(TotTaxValue) InvTaxValue,SUM(NetLineInvVal) InvNetVal,SUM(FreeQty) AS FreeQty, SUM(FreeQty*CAST(Grammage AS FLOAT)) InvFreeVolumeKG,0 AS InvFreeVolumeLt,SUM(ValueForFreeProduct) ValueForFreeProduct,flgInvUpdateSource
	FROM #Invoice IM
	WHERE UOMId IN(11,14,15)
	GROUP BY SalesPersonID,SalesPersonType,RouteId,RouteId,RouteNodeType,StoreId,StoreChannelId,SKUId,InvDate,dbo.fncUTLGetWeekEndDate(IM.InvDate),CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, IM.InvDate)), IM.InvDate))<>DATEPART(mm, IM.InvDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,IM.InvDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, IM.InvDate)), IM.InvDate)END,CONVERT(VARCHAR(6),IM.InvDate,112),flgInvUpdateSource
	UNION
	SELECT StoreChannelId,SalesPersonID,SalesPersonType,RouteId,RouteId,RouteNodeType,RouteNodeType,StoreId,SKUId,0,InvDate,dbo.fncUTLGetWeekEndDate(IM.InvDate) AS WeekEnding,CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, IM.InvDate)), IM.InvDate))<>DATEPART(mm, IM.InvDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,IM.InvDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, IM.InvDate)), IM.InvDate)END AS WeekEndingMonthly,CONVERT(VARCHAR(6),IM.InvDate,112) AS RptMonthYear,COUNT(SKUId) AS TotalLinesInvoiced,SUM(InvQty) AS InvQty, SUM(InvQty*CAST(Grammage AS FLOAT)) InvVolumeKG,0 AS InvVolumeLt,SUM(LineInvVal) InvGrossVal,SUM(TotTaxValue) InvTaxValue,SUM(NetLineInvVal) InvNetVal,SUM(FreeQty) AS FreeQty, SUM(FreeQty*CAST(Grammage AS FLOAT)) InvFreeVolumeKG,0 AS InvFreeVolumeLt,SUM(ValueForFreeProduct) ValueForFreeProduct,flgInvUpdateSource
	FROM #Invoice IM
	WHERE UOMId NOT IN(11,14,15)
	GROUP BY SalesPersonID,SalesPersonType,RouteId,RouteId,RouteNodeType,StoreId,StoreChannelId,SKUId,InvDate,dbo.fncUTLGetWeekEndDate(IM.InvDate),CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, IM.InvDate)), IM.InvDate))<>DATEPART(mm, IM.InvDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,IM.InvDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, IM.InvDate)), IM.InvDate)END,CONVERT(VARCHAR(6),IM.InvDate,112),flgInvUpdateSource



	UPDATE #tmp SET FlgDistrbn=1 WHERE OrderQty>0	
	UPDATE #tmp_Inv SET FlgDistrbn_Invoice=1 WHERE ISNULL(InvQty,0)>0
	--SELECT * FROM #tmp_Inv ORDER By Storeid


	PRINT 'NewStore based on first time ordered'
	SELECT A.StoreId,MIN(A.OrderDate) AS StartDate INTO #ToCheckForNewStores 
	FROM tblOrderMaster A INNER JOIN #tmp B ON A.StoreId=B.StoreId
	INNER JOIN tblOrderDetail OD ON A.OrderId=OD.OrderId
	WHERE OD.OrderQty>0 GROUP BY A.StoreId

	UPDATE B SET B.FlgNewStore=1 FROM #ToCheckForNewStores A INNER JOIN #tmp B ON A.StoreId=B.StoreId AND CONVERT(VARCHAR,A.StartDate,112)=CONVERT(VARCHAR,B.[Date],112)

	SELECT A.StoreId,OD.ProductID,MIN(A.OrderDate) AS StartDate INTO #ToCheckForNewStores_SKULvl
	FROM tblOrderMaster A INNER JOIN #tmp B ON A.StoreId=B.StoreId
	INNER JOIN tblOrderDetail OD ON A.OrderId=OD.OrderId
	WHERE OD.OrderQty>0 GROUP BY A.StoreId,OD.ProductID

	UPDATE B SET B.FlgNewStore_SKULvl=1 FROM #ToCheckForNewStores_SKULvl A INNER JOIN #tmp B ON A.StoreId=B.StoreId AND A.ProductID=B.SkuId AND CONVERT(VARCHAR,A.StartDate,112)=CONVERT(VARCHAR,B.[Date],112)
	--SELECT * FROM #ToCheckForNewStores ORDER BY StoreId

	PRINT 'NewStore based on first time Invoiced'
	SELECT OM.StoreId,MIN(IM.InvDate) AS StartDate INTO #ToCheckForNewStores_Inv 
	FROM tblInvMaster IM  INNER JOIN tblInvDetail ID ON IM.InvId=ID.InvId
	INNER JOIN tblOrderMaster OM ON IM.OrderID=OM.OrderID
	INNER JOIN #tmp_Inv B ON OM.StoreId=B.StoreId
	WHERE ID.InvQty>0 GROUP BY OM.StoreId
		
	UPDATE B SET B.FlgNewStore=1 FROM #ToCheckForNewStores_Inv A INNER JOIN #tmp_Inv B ON A.StoreId=B.StoreId AND CONVERT(VARCHAR,A.StartDate,112)=CONVERT(VARCHAR,B.[Date],112)



	PRINT 'Update for SEId'
	UPDATE #tmp SET #tmp.SEId=AA.SEId,#tmp.SENodeType=AA.SENodeType FROM #tmp INNER JOIN
	(SELECT DISTINCT #tmp.[Date],SPM.NodeID AS RouteId,SPM.NodeType AS RouteNodeType,SPM.PersonNodeID AS SEId,SPM.PersonType AS SENodeType
	FROM tblSalesPersonMapping SPM INNER JOIN #tmp ON SPM.NodeID=#tmp.RouteId_Org AND SPM.NodeType=#tmp.RouteNodeType_Org AND (#tmp.[Date] BETWEEN SPM.FromDate AND SPM.ToDate)
	WHERE NodeType IN(140,170)) AA
	ON #tmp.[Date]=AA.[Date] AND #tmp.RouteId_Org=AA.RouteId AND #tmp.RouteNodeType_Org=AA.RouteNodeType
	WHERE #tmp.RouteId_Org<>0 AND ISNULL(#tmp.SEId,0)=0

	UPDATE #tmp_Inv SET #tmp_Inv.SEId=AA.SEId,#tmp_Inv.SENodeType=AA.SENodeType FROM #tmp_Inv INNER JOIN
	(SELECT DISTINCT #tmp_Inv.[Date],SPM.NodeID AS RouteId,SPM.NodeType AS RouteNodeType,SPM.PersonNodeID AS SEId,SPM.PersonType AS SENodeType
	FROM tblSalesPersonMapping SPM INNER JOIN #tmp_Inv ON SPM.NodeID=#tmp_Inv.RouteId_Org AND SPM.NodeType=#tmp_Inv.RouteNodeType_Org AND (#tmp_Inv.[Date] BETWEEN SPM.FromDate AND SPM.ToDate)
	WHERE NodeType IN(140,170)) AA
	ON #tmp_Inv.[Date]=AA.[Date] AND #tmp_Inv.RouteId_Org=AA.RouteId AND #tmp_Inv.RouteNodeType_Org=AA.RouteNodeType
	WHERE #tmp_Inv.RouteId_Org<>0 AND ISNULL(#tmp_Inv.SEId,0)=0
	
	--UPDATE A SET A.StoreClassId=ISNULL(B.StoreClassID,0),A.StoreTypeID=ISNULL(B.StoreTypeID,0) FROM #tmp A INNER JOIN tblStoreMaster B ON A.StoreId=B.StoreId
	--UPDATE A SET A.StoreClassId=ISNULL(B.StoreClassID,0),A.StoreTypeID=ISNULL(B.StoreTypeID,0) FROM #tmp_Inv A INNER JOIN tblStoreMaster B ON A.StoreId=B.StoreId

	--SELECT * FROM #tmp ORDER By SKUId
	--SELECT * FROM #tmp_Inv ORDER By SKUId

	Print 'Final insert in tblRptSalesMonthly_Day'
	DELETE FROM tblRptSalesMonthly_Day WHERE WeekEnding=@WeekEnding

	INSERT INTO tblRptSalesMonthly_Day(ChannelId,SEId,SENodeType,RouteId,RouteId_Org,RouteNodeType,RouteNodeType_Org,flgOrderType,StoreId,SKUId,[Date],WeekEnding,WeekEndingMonthly, RptMonthYear,TotalLinesOrdered,OrderQty,OrderQtyInCase,OrderVolumeKG,OrderVolumeLt,OrderGrossVal,OrderTaxVal,OrderNetVal,FreeOrderQty,FreeOrderVolumeKG,FreeOrderVolumeLt,ValueForFreeOrderProduct,FlgDistrbn,FlgDistrbn2X,FlgNewStore,FlgNewStore_SKULvl,WeeksSinceLastBought,FlgFirstTimeBought,StoreCategoryId,StoreClassId,StoreTypeId,flgOrderSource) 
	SELECT ChannelId,SEId,SENodeType,RouteId,RouteId_Org,RouteNodeType,RouteNodeType_Org,ISNULL(flgOrderType,0),StoreId,SKUId,[Date],WeekEnding,WeekEndingMonthly,RptMonthYear, TotalLinesOrdered,OrderQty,OrderVolumeInCase,ISNULL(OrderVolumeKG,0),ISNULL(OrderVolumeLt,0),OrderGrossVal,OrderTaxVal,OrderNetVal,FreeOrderQty,ISNULL(FreeOrderVolumeKG,0),ISNULL(FreeOrderVolumeLt,0),ValueForFreeOrderProduct,ISNULL(FlgDistrbn,0),FlgDistrbn2X,ISNULL(FlgNewStore,0),ISNULL(FlgNewStore_SKULvl,0),WeeksSinceLastBought,FlgFirstTimeBought,ISNULL(StoreCategoryId,0),ISNULL(StoreClassId,0),ISNULL(StoreTypeId,0),ISNULL(flgOrderSource,0) FROM #tmp
	
	UPDATE tblRptSalesMonthly_Day SET ChannelId=1 WHERE ISNULL(ChannelId,0)=0

	PRINT 'Update for current route'

	UPDATE A SET A.RouteId=B.RouteId,A.RouteNodeType=B.RouteNodeType
	from tblRptSalesMonthly_Day A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=b.StoreID INNER JOIN
	(SELECT StoreID,MAX(ISNULL(Todate,GETDATE())) Todate FROM tblRouteCoverageStoreMapping WHERE FromDate<=GETDATE() GROUP BY StoreID) AA
    ON ISNULL(B.Todate,GETDATE())=AA.Todate AND B.StoreID =AA.StoreID
	
	UPDATE A SET A.CovAreaId=(PNodeType*1000000) + PNodeID from tblRptSalesMonthly_Day A INNER JOIN tblCompanySalesStructureHierarchy B ON A.RouteId=B.NodeID AND A.RouteNodeType=B.NodeType

	update tblRptSalesMonthly_Day set ManDay=(CAST(CovAreaId AS BIGINT)* 100000000) + CONVERT(VARCHAR,Date,112)

	UPDATE tblRptSalesMonthly_Day SET flgActiveStore=0
	UPDATE A SET flgActiveStore=1 FROM tblRptSalesMonthly_Day A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreId=B.StoreID AND (CAST(GETDATE() AS DATE) BETWEEN B.FromDate AND B.ToDate)

	Print 'Final insert in [tblOLAPDailyInvData]'
	DELETE FROM [tblOLAPDailyInvData] WHERE WeekEnding=@WeekEnding

	INSERT INTO [tblOLAPDailyInvData](ChannelId,SEId,SENodeType,RouteId,RouteId_Org,RouteNodeType,RouteNodeType_Org,StoreId,SKUId,[Date],WeekEnding,WeekEndingMonthly, RptMonthYear,TotalLinesInvoiced,InvQty,InvVolumeKG,InvVolumeLt,InvGrossVal,InvTaxVal,InvNetVal,InvFreeQty,InvFreeVolumeKG,InvFreeVolumeLt,ValueForInvFreeProduct,FlgDistrbn_Invoice, StoreCategoryId,StoreClassId,StoreTypeId,flgInvUpdateSource,FlgNewStore) 
	SELECT ChannelId,SEId,SENodeType,RouteId,RouteId_Org,RouteNodeType,RouteNodeType_Org,StoreId,SKUId,[Date],WeekEnding,WeekEndingMonthly,RptMonthYear,TotalLinesInvoiced,InvQty, ISNULL(InvVolumeKG,0),ISNULL(InvVolumeLt,0),InvGrossVal,InvTaxVal,InvNetVal,InvFreeQty,ISNULL(InvFreeVolumeKG,0),ISNULL(InvFreeVolumeLt,0),ValueForInvFreeProduct,ISNULL(FlgDistrbn_Invoice,0),ISNULL(StoreCategoryId,0), ISNULL(StoreClassId,0),ISNULL(StoreTypeId,0),ISNULL(flgInvUpdateSource,0),ISNULL(FlgNewStore,0) FROM #tmp_Inv

	UPDATE [tblOLAPDailyInvData] SET ChannelId=1 WHERE ISNULL(ChannelId,0)=0

	PRINT 'Update for current route'

	UPDATE A SET A.RouteId=B.RouteId,A.RouteNodeType=B.RouteNodeType
	from [tblOLAPDailyInvData] A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=b.StoreID INNER JOIN
	(SELECT StoreID,MAX(ISNULL(Todate,GETDATE())) Todate FROM tblRouteCoverageStoreMapping WHERE FromDate<=GETDATE() GROUP BY StoreID) AA
    ON ISNULL(B.Todate,GETDATE())=AA.Todate AND B.StoreID =AA.StoreID
	
	UPDATE A SET A.CovAreaId=(PNodeType*1000000) + PNodeID from [tblOLAPDailyInvData] A INNER JOIN tblCompanySalesStructureHierarchy B ON A.RouteId=B.NodeID AND A.RouteNodeType=B.NodeType

	update [tblOLAPDailyInvData] set ManDay=(CAST(CovAreaId AS BIGINT)* 100000000) + CONVERT(VARCHAR,Date,112)

	
	UPDATE [tblOLAPDailyInvData] SET flgActiveStore=0
	UPDATE A SET flgActiveStore=1 FROM [tblOLAPDailyInvData] A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreId=B.StoreID AND (CAST(GETDATE() AS DATE) BETWEEN B.FromDate AND B.ToDate)


	
	PRINT 'Productive Calls'
	select StoreChannelId ChannelId,RouteId,RouteNodeType,VisitId,OrderId,SalesPersonID AS SEId,SalesPersonType AS SENodeType,FlgOrderType,StoreId,ProductId,OrderDate AS [Date],dbo.fncUTLGetWeekEndDate(OrderDate) AS WeekEnding,CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, OrderDate)), OrderDate))<>DATEPART(mm, OrderDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,OrderDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, OrderDate)), OrderDate)END AS WeekEndingMonthly,CONVERT(VARCHAR(6),OrderDate,112) AS RptMonthYear,1 AS FlgProductive,0 AS StoreCategoryId,0 AS StoreClassId,0 AS StoreTypeId,flgOrderSource INTO #tmpProductiveCalls
	FROM #Orders
	WHERE OrderQty>0 --AND VisitId>0

	--UPDATE A SET A.StoreClassId=ISNULL(B.StoreClassID,0),A.StoreTypeID=ISNULL(B.StoreTypeID,0) FROM #tmpProductiveCalls A INNER JOIN tblStoreMaster B ON A.StoreId=B.StoreId

	--SELECT * FROM #tmpProductiveCalls ORDER By Channelid

	PRINT 'Update for SEId'
	UPDATE #tmpProductiveCalls SET #tmpProductiveCalls.SEId=AA.SEId,#tmpProductiveCalls.SENodeType=AA.SENodeType FROM #tmpProductiveCalls INNER JOIN
	(SELECT DISTINCT #tmpProductiveCalls.[Date],SPM.NodeID AS RouteId,SPM.NodeType AS RouteNodeType,SPM.PersonNodeID AS SEId,SPM.PersonType AS SENodeType
	FROM tblSalesPersonMapping SPM INNER JOIN #tmpProductiveCalls ON SPM.NodeID=#tmpProductiveCalls.RouteId AND SPM.NodeType=#tmpProductiveCalls.RouteNodeType AND (#tmpProductiveCalls.[Date] BETWEEN SPM.FromDate AND SPM.ToDate)
	WHERE NodeType IN(140,170)) AA
	ON #tmpProductiveCalls.[Date]=AA.[Date] AND #tmpProductiveCalls.RouteId=AA.RouteId AND #tmpProductiveCalls.RouteNodeType=AA.RouteNodeType
	WHERE #tmpProductiveCalls.RouteId<>0 AND ISNULL(#tmpProductiveCalls.SEId,0)=0

	--SELECT * FROM #tmpProductiveCalls

	DELETE FROM tblOLAPProductiveCallsDaily WHERE WeekEnding=@WeekEnding

	INSERT INTO tblOLAPProductiveCallsDaily(ChannelId,SEId,SENodeType,RouteId,RouteId_Org,RouteNodeType,RouteNodeType_Org,flgOrderType,StoreId,SKUId,[Date],WeekEnding,WeekEndingMonthly,RptMonthYear,VisitId,OrderId,FlgProductive,StoreCategoryId,StoreClassId,StoreTypeId,flgOrderSource)
	SELECT ChannelId,ISNULL(SEId,0),ISNULL(SENodeType,0),RouteId,RouteId,RouteNodeType,RouteNodeType,flgOrderType,StoreId,ProductId,[Date],WeekEnding,WeekEndingMonthly,RptMonthYear, VisitId,OrderId,FlgProductive,ISNULL(StoreCategoryId,0),ISNULL(StoreClassId,0),ISNULL(StoreTypeId,0),ISNULL(flgOrderSource,0)
	FROM #tmpProductiveCalls

	UPDATE tblOLAPProductiveCallsDaily SET ChannelId=1 WHERE ISNULL(ChannelId,0)=0

	PRINT 'Update for current route'

	UPDATE A SET A.RouteId=B.RouteId,A.RouteNodeType=B.RouteNodeType
	from tblOLAPProductiveCallsDaily A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=b.StoreID INNER JOIN
	(SELECT StoreID,MAX(ISNULL(Todate,GETDATE())) Todate FROM tblRouteCoverageStoreMapping WHERE FromDate<=GETDATE() GROUP BY StoreID) AA
    ON ISNULL(B.Todate,GETDATE())=AA.Todate AND B.StoreID =AA.StoreID
	
	UPDATE A SET A.CovAreaId=(PNodeType*1000000) + PNodeID from tblOLAPProductiveCallsDaily A INNER JOIN tblCompanySalesStructureHierarchy B ON A.RouteId=B.NodeID AND A.RouteNodeType=B.NodeType

	update tblOLAPProductiveCallsDaily set ManDay=(CAST(CovAreaId AS BIGINT)* 100000000) + CONVERT(VARCHAR,Date,112)
	
	UPDATE tblOLAPProductiveCallsDaily SET flgActiveStore=0
	UPDATE A SET flgActiveStore=1 FROM tblOLAPProductiveCallsDaily A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreId=B.StoreID AND (CAST(GETDATE() AS DATE) BETWEEN B.FromDate AND B.ToDate)


	CREATE TABLE #Target(ChannelId INT,SEId INT DEFAULT 0 NOT NULL,[SENodeType] [int] DEFAULT 0 NOT NULL,RouteId INT DEFAULT 0 NOT NULL,RouteId_Org INT DEFAULT 0 NOT NULL,[RouteNodeType] [int] DEFAULT 0 NOT NULL,[RouteNodeType_Org] [int] DEFAULT 0 NOT NULL,StoreId INT,[Date] DATE,WeekEnding DATE,WeekEndingMonthly DATE,RptMonthYear INT,OrderVolumeKG NUMERIC(38,6) DEFAULT 0,OrderVolumeLt NUMERIC(38,6) DEFAULT 0,OrderGrossValue NUMERIC(38,6) DEFAULT 0,OrderTaxValue NUMERIC(38,6) DEFAULT 0,OrderNetValue NUMERIC(38,6) DEFAULT 0,TotalLinesOrdered INT DEFAULT 0,TotalDistinctLinesOrdered INT DEFAULT 0,FlgPlanned TINYINT DEFAULT 0,FlgCovered TINYINT DEFAULT 0,FlgProductiveCall TINYINT DEFAULT 0,PlannedCalls INT DEFAULT 0,ActualCalls INT DEFAULT 0,ProductiveCalls INT DEFAULT 0,FlgNewStore TINYINT DEFAULT 0,StoreCategoryId [int] NOT NULL DEFAULT 0,StoreClassId [int] NOT NULL DEFAULT 0,StoreTypeID [int] NOT NULL DEFAULT 0)
	
	PRINT 'Target Start'
	DECLARE @PreWeekEnding DATE,@DistinctWeek INT,@WeekNumber INT,@WeekEndingMonthly DATE
	SET DATEFirst 1
	SET @PreWeekEnding=DATEADD(week,-1,@WeekEnding)
	PRINT @PreWeekEnding
	--drop table #tmpDays
	CREATE TABLE #tmpDays(Dt DATE, WeekNo INT, DayNo INT IDENTITY(1,1));
	with dateRange as
	(	
	  select dt = dateadd(dd, 1, @PreWeekEnding)
	  where dateadd(dd, 1, @PreWeekEnding) <= @WeekEnding
	  union all
	  select dateadd(dd, 1, dt)
	  from dateRange
	  where dateadd(dd, 1, dt) <= @WeekEnding
	)
	INSERT INTO #tmpDays(Dt)
	select * from dateRange ORDER BY dt
	UPDATE #tmpDays SET WeekNo=DATEPART(WEEK, Dt)  -  DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,Dt), 0))+ 1
	--select * from #tmpDays
	/*
	SET DATEFIRST 1
	SELECT DISTINCT RCM.RouteId,RCM.NodeType AS RouteNodeType,D.Dt,dbo.[fnGetPlannedVisit](RCM.RouteId,RCM.NodeType,D.Dt) AS FlgPlanned INTO #tmpRoute
	FROM tblRouteCoverage RCM CROSS JOIN #tmpDays D
	ORDER BY NodeType,RouteId,Dt
	--SELECT * FROM #tmpRoute
	DELETE FROM #tmpRoute WHERE FlgPlanned=0
	*/

	SELECT DISTINCT RC.RouteNodeId RouteId,RC.RouteNodeType,D.Dt,1 AS FlgPlanned INTO #tmpRoute
	FROM tblRoutePlanningVisitDetail RC INNER JOIN #tmpDays D ON RC.VisitDate=D.Dt
	--SELECT * FROM #tmpRoute

	INSERT INTO #Target(ChannelId,SEId,SENodeType,RouteId,RouteId_Org,RouteNodeType,RouteNodeType_Org,StoreId,[Date],WeekEnding,WeekEndingMonthly,RptMonthYear,FlgPlanned, PlannedCalls)
	SELECT SM.ChannelId,0,0,A.RouteId,A.RouteId,A.RouteNodeType,A.RouteNodeType,B.StoreId,A.Dt,dbo.fncUTLGetWeekEndDate(A.Dt) AS WeekEnding,CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, A.Dt)), A.Dt))<>DATEPART(mm, A.Dt) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,A.Dt)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, A.Dt)), A.Dt)END AS WeekEndingMonthly,CONVERT(VARCHAR(6),A.Dt,112) AS RptMonthYear,1,COUNT(Dt) AS PlannedCalls
	FROM  #tmpRoute A INNER JOIN tblRouteCoverageStoreMapping B ON A.routeId=B.RouteId AND A.RouteNodeType=B.RouteNodeType AND (A.Dt BETWEEN B.FromDate AND B.ToDate)
	INNER JOIN tblStoreMaster  SM ON B.StoreId=SM.StoreID
	GROUP BY SM.ChannelId,A.RouteId,A.RouteNodeType,B.StoreId,A.Dt,dbo.fncUTLGetWeekEndDate(A.Dt),CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, A.Dt)), A.Dt))<>DATEPART(mm, A.Dt) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,A.Dt)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, A.Dt)), A.Dt) END,CONVERT(VARCHAR(6),A.Dt,112)
	ORDER BY B.Storeid
	--SELECT * FROM #Target

	PRINT 'Actua Calls'
	 SELECT A.RouteId,A.RouteType AS RouteNodeType,ISNULL(A.EntryPersonNodeID,0) SalesPersonID,ISNULL(A.EntryPersonNodeType,0) SalesPersonType,A.StoreId,A.VisitDate AS [Date],COUNT(DISTINCT A.VisitId) AS ActualCalls, dbo.fncUTLGetWeekEndDate(A.VisitDate) AS WeekEnding, CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, A.VisitDate)), A.VisitDate))<>DATEPART(mm, A.VisitDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,A.VisitDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, A.VisitDate)), A.VisitDate)END AS WeekEndingMonthly,CONVERT(VARCHAR(6),A.VisitDate,112) AS RptMonthYear
	 INTO #Actual FROM tblVisitMaster A 
	 WHERE dbo.fncUTLGetWeekEndDate(A.VisitDate) =@WeekEnding 
	 GROUP BY A.RouteId,A.RouteType,A.EntryPersonNodeID,A.EntryPersonNodeType,A.StoreId,A.VisitDate,dbo.fncUTLGetWeekEndDate(A.VisitDate),CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, A.VisitDate)), A.VisitDate))<>DATEPART(mm, A.VisitDate) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,A.VisitDate)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, A.VisitDate)), A.VisitDate)END,CONVERT(VARCHAR(6),A.VisitDate,112)
	 --SELECT * FROM #Actual --WHERE storeid=460

	  UPDATE A SET A.FlgCovered=1,A.ActualCalls=B.ActualCalls ,A.SEId=B.SalesPersonID,A.SENodeType=B.SalesPersonType
	  from #Target A INNER JOIN #Actual  B ON A.StoreId=B.StoreId AND A.[Date]=B.[Date] AND A.RouteId=B.RouteId AND A.RouteNodeType=B.RouteNodeType

	PRINT 'Insertion for stores visited but not in target'
	INSERT INTO #Target(ChannelId,RouteId,RouteId_Org,RouteNodeType,RouteNodeType_Org,SEId,SENodeType,StoreId,[Date],WeekEnding,WeekEndingMonthly,RptMonthYear,FlgCovered,ActualCalls)
	SELECT SM.ChannelId,#Actual.RouteId,#Actual.RouteId,#Actual.RouteNodeType,#Actual.RouteNodeType,#Actual.SalesPersonID,#Actual.SalesPersonType,#Actual.StoreId,#Actual.[Date],#Actual.WeekEnding,#Actual.WeekEndingMonthly, #Actual.RptMonthYear,1 AS FlgCovered,#Actual.ActualCalls AS ActualCalls 
	FROM #Actual INNER JOIN tblStoreMaster SM ON #Actual.StoreId=SM.StoreID LEFT OUTER JOIN  #Target 
 ON #Actual.StoreId=#Target.StoreId AND #Actual.[Date]=#Target.[Date] AND #Actual.RouteId=#Target.RouteId AND #Actual.RouteNodeType=#Target.RouteNodeType
	WHERE #Target.StoreId IS NULL AND #Target.[Date] IS NULL AND #Target.RouteId IS NULL AND #Target.RouteNodeType IS NULL
	
	--SELECT * FROM #Target

	PRINT 'Update for Productive Calls'
	INSERT INTO #Target(ChannelId,RouteId,RouteId_Org,RouteNodeType,RouteNodeType_Org,SEId,SENodeType,StoreId,[Date],WeekEnding,WeekEndingMonthly,RptMonthYear)
	SELECT DISTINCT SM.ChannelId,#Orders.RouteId,#Orders.RouteId,#Orders.RouteNodeType,#Orders.RouteNodeType,#Orders.SalesPersonID,#Orders.SalesPersonType, #Orders.StoreId,#Orders.OrderDate,#Orders.WeekEnding,#Orders.WeekEndingMonthly,#Orders.RptMonthYear
	FROM #Orders INNER JOIN tblStoreMaster SM ON #Orders.StoreId=SM.StoreID LEFT OUTER JOIN  #Target 
 ON #Orders.StoreId=#Target.StoreId AND #Orders.[OrderDate]=#Target.[Date] AND #Orders.RouteId=#Target.RouteId AND #Orders.RouteNodeType=#Target.RouteNodeType
	WHERE #Target.StoreId IS NULL AND #Target.[Date] IS NULL AND #Target.RouteId IS NULL AND #Target.RouteNodeType IS NULL
	ORDER BY #Orders.StoreId,#Orders.OrderDate

	UPDATE A SET A.ProductiveCalls=B.ProductiveCalls
	FROM #Target A INNER JOIN (SELECT RouteId,RouteNodeType,StoreId,OrderDate,COUNT(DISTINCT VisitId) AS ProductiveCalls FROM #Orders WHERE VisitId>0 AND OrderQty>0 GROUP BY RouteId,RouteNodeType,StoreId,OrderDate) B ON A.RouteId=B.RouteId AND A.RouteNodeType=B.RouteNodeType AND A.StoreId=B.StoreID AND A.[Date]=B.OrderDate

	UPDATE A SET A.FlgProductiveCall=1
	FROM #Target A INNER JOIN (SELECT RouteId,RouteNodeType,StoreId,OrderDate FROM #Orders WHERE OrderQty>0) B ON A.RouteId=B.RouteId AND A.RouteNodeType=B.RouteNodeType AND A.StoreId=B.StoreID AND A.[Date]=B.OrderDate


	PRINT 'Stores Visited first time'
	SELECT A.StoreId,MIN(A.VisitDate) AS StartDate INTO #ToCheckForNewVisitedStores 
	FROM tblVisitMaster A INNER JOIN #Target B ON A.StoreId=B.StoreId
	GROUP BY A.StoreId
	
	UPDATE B SET B.FlgNewStore=1 FROM #ToCheckForNewVisitedStores A INNER JOIN #Target B ON A.StoreId=B.StoreId  AND CONVERT(VARCHAR,A.StartDate,112)=CONVERT(VARCHAR,B.[Date],112) 
	--SELECT * FROM #ToCheckForNewVisitedStores order by StartDate	
	--SELECT * FROM #Target
	

	DECLARE @ActiveSKUs INT
	SELECT @ActiveSKUs=COUNT(NodeID) FROM tblPrdMstrSKULvl WHERE IsActive=1

	--DELETE FROM #Target WHERE CONVERT(VARCHAR,[Date],112)>CONVERT(VARCHAR,GETDATE(),112)

	PRINT 'Update for SEId'
	UPDATE #Target SET #Target.SEId=AA.SEId,#Target.SENodeType=AA.SENodeType FROM #Target INNER JOIN
	(SELECT DISTINCT #Target.[Date],SPM.NodeID AS RouteId,SPM.NodeType AS RouteNodeType,SPM.PersonNodeID AS SEId,SPM.PersonType AS SENodeType
	FROM tblSalesPersonMapping SPM INNER JOIN #Target ON SPM.NodeID=#Target.RouteId_Org AND SPM.NodeType=#Target.RouteNodeType_Org AND (#Target.[Date] BETWEEN SPM.FromDate AND SPM.ToDate)
	WHERE NodeType IN(140,170)) AA
	ON #Target.[Date]=AA.[Date] AND #Target.RouteId_Org=AA.RouteId AND #Target.RouteNodeType_Org=AA.RouteNodeType
	WHERE #Target.RouteId_Org<>0 AND ISNULL(#Target.SEId,0)=0

	--Dummy SEId for the routes which are still active in route plan but not assigned to any person
	UPDATE #Target SET #Target.SEId=10000 WHERE ISNULL(#Target.SEId,0)=0 		
	UPDATE #Target SET RptMonthYear=CONVERT(VARCHAR(6),WeekEndingMonthly,112)
	
	--UPDATE A SET A.StoreClassId=ISNULL(B.StoreClassID,0),A.StoreTypeID=ISNULL(B.StoreTypeID,0) FROM #Target A INNER JOIN tblStoreMaster B ON A.StoreId=B.StoreId
	--SELECT * FROM #Target ORDER BY StoreId

	DELETE FROM tblRptSalesMonthlyWithTarget_Day WHERE  WeekEnding=@WeekEnding

	 INSERT INTO tblRptSalesMonthlyWithTarget_Day(ChannelId,SEId,SENodeType,RouteId,RouteId_Org,RouteNodeType,RouteNodeType_Org,StoreId,[Date],WeekEnding,WeekEndingMonthly, RptMonthYear,ActiveSKUs,OrderVolumeKG,OrderVolumeLt,OrderGrossVal,OrderTaxVal,OrderNetVal,TotalLinesOrdered,TotalDistinctLinesOrdered,FlgPlanned,FlgCovered,FlgProductive,PlannedCalls,ActualCalls,ProductiveCalls,FlgNewStore,StoreCategoryId,StoreClassId,StoreTypeID) 
	SELECT ChannelId,ISNULL(SEId,0),ISNULL(SENodeType,0),RouteId,RouteId_Org,RouteNodeType,RouteNodeType_Org,StoreId,[Date],WeekEnding,WeekEndingMonthly, RptMonthYear, @ActiveSKUs,ISNULL(OrderVolumeKG,0),ISNULL(OrderVolumeLt,0),ISNULL(OrderGrossValue,0),ISNULL(OrderTaxValue,0),ISNULL(OrderNetValue,0),ISNULL(TotalLinesOrdered,0),ISNULL(TotalDistinctLinesOrdered,0),ISNULL(FlgPlanned,0),ISNULL(FlgCovered,0),ISNULL(FlgProductiveCall,0),ISNULL(PlannedCalls,0),ISNULL(ActualCalls,0),ISNULL(ProductiveCalls,0),ISNULL(FlgNewStore,0),ISNULL(StoreCategoryId,0),ISNULL(StoreClassId,0),ISNULL(StoreTypeID,0)
	from #Target
 --select * from tblRptSalesMonthlyWithTarget_Day
	
	UPDATE tblRptSalesMonthlyWithTarget_Day SET ChannelId=1 WHERE ISNULL(ChannelId,0)=0

	PRINT 'Update for current route'
	UPDATE A SET A.RouteId=B.RouteId,A.RouteNodeType=B.RouteNodeType
	from tblRptSalesMonthlyWithTarget_Day A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreID=b.StoreID INNER JOIN
	(SELECT StoreID,MAX(ISNULL(Todate,GETDATE())) Todate FROM tblRouteCoverageStoreMapping WHERE FromDate<=GETDATE() GROUP BY StoreID) AA
    ON ISNULL(B.Todate,GETDATE())=AA.Todate AND B.StoreID =AA.StoreID
			
	UPDATE A SET A.CovAreaId=(PNodeType*1000000) + PNodeID from tblRptSalesMonthlyWithTarget_Day A INNER JOIN tblCompanySalesStructureHierarchy B ON A.RouteId=B.NodeID AND A.RouteNodeType=B.NodeType

	update tblRptSalesMonthlyWithTarget_Day set ManDay=(CAST(CovAreaId AS BIGINT)* 100000000) + CONVERT(VARCHAR,Date,112)

	
	UPDATE tblRptSalesMonthlyWithTarget_Day SET flgActiveStore=0
	UPDATE A SET flgActiveStore=1 FROM tblRptSalesMonthlyWithTarget_Day A INNER JOIN tblRouteCoverageStoreMapping B ON A.StoreId=B.StoreID AND (CAST(GETDATE() AS DATE) BETWEEN B.FromDate AND B.ToDate)


	DELETE FROM tblOLAPTimeHierarchy_Day WHERE WeekEnding=@WeekEnding
	--SELECT * FROM #tmpDays
	IF @WeekEnding=CAST(GETDATE() AS DATE)
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM tblOLAPTimeHierarchy_Day WHERE Date=DATEADD(dd,1,@WeekEnding))
		BEGIN
			INSERT INTO #tmpDays(Dt)
			SELECT DATEADD(dd,1,@WeekEnding)
		END
	END
	--SELECT * FROM #tmpDays

	SELECT DISTINCT Dt AS [Date],RIGHT(CONVERT(VARCHAR,Dt,112),2)+'-'+LEFT(DATENAME(m,Dt),3)+'-'+RIGHT(YEAR(Dt),2)+' ('+LEFT(DATENAME(dw,Dt),3)+')' AS strDate, 
DATEADD(dd, 7-(DATEPART(dw, Dt)), Dt) AS WeekEnding,CONVERT(VARCHAR(50),'') AS strWeekEnding,CASE WHEN DATEPART(mm,DATEADD(dd, 7-(DATEPART(dw, Dt)), Dt))<>DATEPART(mm, Dt) THEN CAST(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,Dt)+1,0)) AS DATE) ELSE DATEADD(dd, 7-(DATEPART(dw, Dt)), Dt)END AS WeekEndingMonthly,LEFT(DATENAME(m,Dt),3)+'-'+CAST(DATEPART(yyyy,Dt) AS VARCHAR) AS [Month],DATEPART(m,Dt) AS MonthVal,DATEPART(yyyy,Dt) AS YearVal,DATEPART(yyyy,Dt) AS YearValNew,CONVERT(VARCHAR(6),Dt,112) AS RptMonthYear INTO #tmpDates
FROM #tmpDays
	
	UPDATE #tmpDates SET strWeekEnding='WE : '+RIGHT(CONVERT(VARCHAR,WeekEnding,112),2)+'-'+LEFT(DATENAME(m,WeekEnding),3)+'-'+RIGHT(YEAR(WeekEnding),2)+' ('+LEFT(DATENAME(dw,WeekEnding),3)+')'
	
	--SELECT * FROM #tmpDates
	INSERT INTO tblOLAPTimeHierarchy_Day(Date,strDate,WeekEnding,WeekEndingNew,strWeekEnding,WeekEndingMonthly,Month,MonthVal,YearVal,YearValNew,RptMonthYear)
	SELECT [Date],strDate,WeekEnding,WeekEnding,strWeekEnding,WeekEndingMonthly,[Month],MonthVal,YearVal,YearValNew,RptMonthYear
	FROM #tmpDates  --WHERE CONVERT(VARCHAR,[Date],112)<=CONVERT(VARCHAR,DATEADD(d,1,GETDATE()),112)

 
	
END






















