-- =============================================
-- Author:		Avinash Gupta
-- Create date: 22-Dec-2021
-- Description:	
-- =============================================
-- SpGetDailyReportDistributorStock 'E1736117-8A5C-4508-BFE9-6368F84A8663','22-Dec-2021',2,687,150
CREATE PROCEDURE [dbo].[SpGetDailyReportDistributorStock] 
	@PDACode VARCHAR(50),
	@EntryDate Date , 
	@flgReportLevel TINYINT=1,
	@CustomerNodeID INT =0,
	@CustomerNodeType SMALLINT=0

AS
BEGIN
	DECLARE @PersonID INT     
	DECLARE @PersonType INT    
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	PRINT 'PersonID=' + CAST(@PersonID AS VARCHAR)          
	PRINT 'PersonType=' + CAST(@PersonType AS VARCHAR)

	 -- to get coverage area list for the person
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
		PRINT 'AA GAYA'
		INSERT INTO  #CoverageArea
		SELECT DISTINCT V.DSRAreaID,V.DSRAreaNodeType  
		FROM tblSalesPersonMapping P INNER JOIN [dbo].[VwCompanySalesHierarchy] V ON V.ASMAreaID=P.NodeID AND V.ASMAreaNodeType=P.NodeType 
		WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		
	END
	CREATE TABLE #DBRList(ident int identity(1,1),CustomerNodeID INT,CustomerNodeType INT,Customer VARCHAR(200),StateID INT,PersonNodeID INT,PersonNodeType SMALLINT,Personname VARCHAR(200))
	INSERT INTO #DBRList(CustomerNodeID,CustomerNodeType,Customer,StateID,PersonNodeID,PersonNodeType,Personname)
	SELECT DISTINCT Map.DHNodeId,DHNodeType,D.Descr,D.StateID,P.NodeID,P.NodeType,P.Descr  --INTO #DBRList
	FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN [dbo].[tblDBRSalesStructureDBR] D ON D.NodeID=Map.DHNodeID AND D.NodeType=Map.DHNodeType INNER JOIN #CoverageArea C ON Map.SHNodeId=C.NodeId AND Map.SHNodeType=C.NodeType
	LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.NodeID=C.NodeID AND SP.NodeType=C.NodeType AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate
	LEFT OUTER JOIN tblmstrperson P ON P.NodeID=SP.PersonNodeID
	WHERE DHNodeType=150 AND (GETDATE() BETWEEN Map.FromDate AND Map.ToDate)


	DECLARE @PrcRegionID INT
	CREATE TABLE #StockEntry (CustomerNodeID INT,CustomerNodeType SMALLINT,Customer VARCHAR(200),Personname VARCHAR(200),[LastEntryDate] Date)
	CREATE TABLE #tblStockData(CustomerNodeID int,CustomerNodeType int,CategoryNodeID INT,CategoryNodeType SMALLINT,Category VARCHAR(100),ProductNodeID INT,ProductNodeType INT,SKUName VARCHAR(200),[StockQty(Kg)] FLOAT,[StockQty(Cases)] FLOAT,[Stock(Value)] FLOAT)


	INSERT INTO #StockEntry(CustomerNodeID,CustomerNodeType,Customer,Personname,[LastEntryDate])
	SELECT D.CustomerNodeID,D.CustomerNodeType,DBR.Descr,D.Personname,MAX(StockDate) LastStockDate 
	FROM #DBRList D 
	INNER JOIN tblDBRSalesStructureDBR DBR  ON D.CustomerNodeID=DBR.NodeID AND D.CustomerNodeType=DBR.NodeType
	LEFT OUTER JOIN [tblDistributorStockDet] DS ON D.CustomerNodeID=DS.CustomerNodeID AND DS.CustomerNodeType=D.CustomerNodeType
	
	GROUP BY  D.CustomerNodeID,D.CustomerNodeType,DBR.Descr,D.Personname



	SELECT DISTINCT DBR.NodeID CustomerNodeID,DBR.NodeType CustomerNodeType,SM.* INTO #tblPrdSKUSalesMapping FROM tblDBRSalesStructureDBR DBR INNER JOIN [dbo].[tblPriceRegionMstr] PR ON PR.StateID=DBR.StateId 
	INNER JOIN #DBRList D ON D.CustomerNodeID=DBR.NodeID AND D.CustomerNodeType=DBR.NodeType
	INNER JOIN tblPrdSKUSalesMapping SM ON SM.PrcLocationId=PR.PrcRgnNodeId AND UOMID=3 AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate
	--WHERE NodeID=@CustomerNodeID AND NodeType=@CustomerNodeType

	--SELECT * INTO #tblPrdSKUSalesMapping FROM tblPrdSKUSalesMapping SM WHERE PrcLocationId=@PrcRegionID AND UOMID=3 AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate

	INSERT INTO #tblStockData(CustomerNodeID,CustomerNodeType,CategoryNodeID,CategoryNodeType,Category,ProductNodeID,ProductNodeType,SKUName,[StockQty(Kg)],[StockQty(Cases)],[Stock(Value)])
	SELECT DISTINCT S.CustomerNodeID,S.CustomerNodeType,V.CategoryNodeID,V.CategoryNodeType,V.Category,
	V.SKUNodeID,V.SKUNodeType,V.SKUShortDescr,CAST(ROUND((S.StockQty * V.UOMValue)/1000,0) AS INT),CAST(ROUND(StockQty/RelConversionUnits,0) AS INT),CAST(ROUND(StockQty * P.StandardRate,0) AS INT)
	FROM [VwSFAProductHierarchy] V INNER JOIN tblPrdMstrPackingUnits_ConversionUnits C ON C.SKUId=V.SKUNodeID AND C.BaseUOMID=3
	INNER JOIN tblDistributorStockDet S ON V.SKUNodeID=S.ProductNodeId AND V.SKUNodeType=S.ProductNodeType
	INNER JOIN #StockEntry SE ON SE.CustomerNodeID=S.CustomerNodeID AND SE.CustomerNodeType=S.CustomerNodeType AND SE.LastEntryDate=S.StockDate
	LEFT OUTER JOIN #tblPrdSKUSalesMapping P ON P.SKUNodeId=V.SKUNodeID AND P.SKUNodeType=V.SKUNodeType
	AND P.CustomerNodeID=S.CustomerNodeID AND P.CustomerNodeType=S.CustomerNodeType
	--WHERE IsActive=1 --AND D.StateID=B.PrcLocationID

	--SELECT * FROM [tblDistributorStockDet]
	IF @flgReportLevel=1
	BEGIN
		--SELECT * FROM #tblStockData
		SELECT SE.CustomerNodeID,SE.CustomerNodeType,Customer,SE.Personname,FORMAT([LastEntryDate],'dd-MMM') [LastEntryDate],SUM(SD.[StockQty(Kg)]) [StockQty(Kg)],SUM(SD.[StockQty(Cases)]) [StockQty(Cases)],ROUND(CAST(SUM(SD.[Stock(Value)]) AS FLOAT)/100000,2) [Stock(Value in Lacs)] FROM #StockEntry SE LEFT OUTER JOIN #tblStockData SD ON SD.CustomerNodeID=SE.CustomerNodeID AND SD.CustomerNodeType=SE.CustomerNodeType GROUP BY SE.CustomerNodeID,SE.CustomerNodeType,Customer,SE.Personname,FORMAT([LastEntryDate],'dd-MMM') ORDER BY Customer  

	END
	ELSE
	BEGIN
				 
		 SELECT DISTINCT CustomerNodeID ,CustomerNodeType ,CategoryNodeID ,CategoryNodeType ,Category ,ProductNodeID ,ProductNodeType ,SKUName ,[StockQty(Kg)],[StockQty(Cases)] ,[Stock(Value)] [Stock(Value in Rs)] FROM #tblStockData WHERE [Stock(Value)]>0 AND CustomerNodeID=@CustomerNodeID AND CustomerNodeType=@CustomerNodeType
	END
	
END
