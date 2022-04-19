-- =============================================
-- Author:		Avinash Gupta
-- Create date: 22-Dec-2021
-- Description:	
-- =============================================
-- SpGetDailyReportDistributorStock_Web 22,110,'21-Dec-2021'
CREATE PROCEDURE [dbo].[SpGetDailyReportDistributorStock_Web] 
	@NodeID INT,
	@NodeType SMALLINT,
	@StockDate Date 
AS
BEGIN
	Select * into #DBRList from dbo.fnGetDistributorList(@NodeId ,@NodeType,Getdate())
	--SELECT * FROM #DBRList
	 
	DECLARE @PrcRegionID INT
	CREATE TABLE #StockEntry (CustomerNodeID INT,CustomerNodeType SMALLINT,Customer VARCHAR(200),[LastEntryDate] Date)
	CREATE TABLE #tblStockData(CustomerNodeID int,CustomerNodeType int,Customer VARCHAR(200),CategoryNodeID INT,CategoryNodeType SMALLINT,Category VARCHAR(100),ProductNodeID INT,ProductNodeType INT,SKUCode VARCHAR(50),SKUName VARCHAR(200),[StockQty(Kg)] INT,[StockQty(Cases)] INT,[Stock(Value)] INT)


	INSERT INTO #StockEntry(CustomerNodeID,CustomerNodeType,Customer,[LastEntryDate])
	SELECT D.DBRNodeId,D.DBRNodetype,DBR.Descr,MAX(StockDate) LastStockDate 
	FROM #DBRList D 
	INNER JOIN tblDBRSalesStructureDBR DBR  ON D.DBRNodeId=DBR.NodeID AND D.DBRNodetype=DBR.NodeType
	LEFT OUTER JOIN [tblDistributorStockDet] DS ON D.DBRNodeId=DS.CustomerNodeID AND DS.CustomerNodeType=D.DBRNodetype
	AND DS.StockDate<=@StockDate
	GROUP BY  D.DBRNodeId,D.DBRNodetype,DBR.Descr
	

	SELECT DISTINCT DBR.NodeID CustomerNodeID,DBR.NodeType CustomerNodeType,DBR.Descr Customer,SM.* INTO #tblPrdSKUSalesMapping FROM tblDBRSalesStructureDBR DBR INNER JOIN [dbo].[tblPriceRegionMstr] PR ON PR.StateID=DBR.StateId 
	INNER JOIN #DBRList D ON D.DBRNodeId=DBR.NodeID AND D.DBRNodetype=DBR.NodeType
	INNER JOIN tblPrdSKUSalesMapping SM ON SM.PrcLocationId=PR.PrcRgnNodeId AND UOMID=3 AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate
	--WHERE NodeID=@CustomerNodeID AND NodeType=@CustomerNodeType

	--SELECT * INTO #tblPrdSKUSalesMapping FROM tblPrdSKUSalesMapping SM WHERE PrcLocationId=@PrcRegionID AND UOMID=3 AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate

	INSERT INTO #tblStockData(CustomerNodeID,CustomerNodeType,Customer,CategoryNodeID,CategoryNodeType,Category,ProductNodeID,ProductNodeType,SKUCode,SKUName,[StockQty(Kg)],[StockQty(Cases)],[Stock(Value)])
	SELECT DISTINCT S.CustomerNodeID,S.CustomerNodeType,P.Customer,V.CategoryNodeID,V.CategoryNodeType,V.Category,
	V.SKUNodeID,V.SKUNodeType,V.SKUCode,V.SKUShortDescr,CAST(ROUND((S.StockQty * V.UOMValue)/1000,0) AS INT),CAST(ROUND(StockQty/RelConversionUnits,0) AS INT),CAST(ROUND(StockQty * P.StandardRate,0) AS INT)
	FROM [VwSFAProductHierarchy] V INNER JOIN tblPrdMstrPackingUnits_ConversionUnits C ON C.SKUId=V.SKUNodeID AND C.BaseUOMID=3
	INNER JOIN tblDistributorStockDet S ON V.SKUNodeID=S.ProductNodeId AND V.SKUNodeType=S.ProductNodeType
	INNER JOIN #StockEntry SE ON SE.CustomerNodeID=S.CustomerNodeID AND SE.CustomerNodeType=S.CustomerNodeType AND SE.LastEntryDate=S.StockDate
	LEFT OUTER JOIN #tblPrdSKUSalesMapping P ON P.SKUNodeId=V.SKUNodeID AND P.SKUNodeType=V.SKUNodeType
	AND P.CustomerNodeID=S.CustomerNodeID AND P.CustomerNodeType=S.CustomerNodeType
	--WHERE IsActive=1 --AND D.StateID=B.PrcLocationID

	--SELECT * FROM [tblDistributorStockDet]
					 
	SELECT DISTINCT CategoryNodeID ,CategoryNodeType ,Category ,ProductNodeID ,ProductNodeType ,SKUCode,SKUName ,SUM([StockQty(Kg)]) [StockQty(Kg)],SUM([StockQty(Cases)]) [StockQty(Cases)] ,SUM([Stock(Value)]) [Stock(Value in Rs)] FROM #tblStockData WHERE [Stock(Value)]>0 
	GROUP BY CategoryNodeID ,CategoryNodeType ,Category ,ProductNodeID ,ProductNodeType ,SKUCode,SKUName

	SELECT DISTINCT CustomerNodeID,CustomerNodeType,CategoryNodeID ,CategoryNodeType,ProductNodeID ,ProductNodeType  ,Customer,Category ,SKUCode,SKUName , [StockQty(Kg)], [StockQty(Cases)] , [Stock(Value)] [Stock(Value in Rs)] FROM #tblStockData WHERE [Stock(Value)]>0  
	
	
END
