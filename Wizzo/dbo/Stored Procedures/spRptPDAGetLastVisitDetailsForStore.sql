-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[spRptPDAGetLastVisitDetailsForStore]1881
CREATE PROCEDURE [dbo].[spRptPDAGetLastVisitDetailsForStore]
@StoreId INT
AS
BEGIN
	DECLARE @RptDate DATE=DATEADD(dd,-1,GETDATE())
	PRINT @RptDate
	DECLARE @LastVisitDate DATE
	DECLARE @LastVisitId INT
	DECLARE @LastOrderDate DATE
	DECLARE @LastOrderId INT
	DECLARE @InvId INT=0
	DECLARE @ColString VARCHAR(5000)=''
	DECLARE @strSQL VARCHAR(max) 

	SELECT VisitDate,VisitId INTO #Visits FROM tblVisitMaster WHERE StoreId=@StoreId AND VisitDate<=@RptDate
	--SELECT * FROM #Visits ORDER BY 2 DESC

	SELECT @LastVisitDate=MAX(VisitDate) FROM #Visits --WHERE StoreId=@StoreId AND VisitDate<=@RptDate
	PRINT @LastVisitDate
	SELECT @LastVisitId=VisitId FROM #Visits WHERE VisitDate=@LastVisitDate
	PRINT @LastVisitId
	SELECT @LastOrderDate=MAX(OrderDate) FROM tblOrderMaster WHERE StoreId=@StoreId AND OrderDate<=@RptDate
	PRINT @LastOrderDate
	SELECT @LastOrderId=OrderId FROM tblOrderMaster WHERE StoreId=@StoreId AND OrderDate=@LastOrderDate
	PRINT @LastOrderId

	SELECT CategoryNodeID,Category,SKUNodeId,SKU INTO #SKUList FROM VwSFAProductHierarchy   
	--SELECT * FROM #SKUList

	CREATE TABLE #LastVisitDetails(CategoryID INT,Category VARCHAR(200),SKUNodeId INT,SKU VARCHAR(200),StockQty INT,OrderQty INT,DeliveryQty INT)

	INSERT INTO #LastVisitDetails(CategoryID,Category,SKUNodeId,SKU)
	SELECT CategoryNodeID,Category,SKUNodeId,SKU FROM #SKUList

	UPDATE A SET A.StockQty=B.Qty FROM #LastVisitDetails A INNER JOIN tblVisitStock B ON A.SKUNodeId=B.ProductId WHERE B.VisitId=@LastVisitId
	UPDATE A SET A.OrderQty=B.OrderQty,A.DeliveryQty=0 FROM #LastVisitDetails A INNER JOIN tblOrderDetail B ON A.SKUNodeId=B.ProductId WHERE B.OrderId=@LastOrderId

	----SELECT @InvId=InvId FROM tblInvMaster WHERE OrderId=@LastOrderId AND flgInvStatus<>2
	------SELECT @InvId
	----IF ISNULL(@InvId,0)>0
	----BEGIN
	----	UPDATE A SET A.DeliveryQty=B.InvQty FROM #LastVisitDetails A INNER JOIN tblInvDetail B ON A.SKUNodeId=B.ProductID WHERE B.InvID=@InvId
	----END
	DELETE FROM #LastVisitDetails WHERE OrderQty IS NULL AND StockQty IS NULL
	--SELECT * FROM #LastVisitDetails
	

	--Last 4 visit Trend
	CREATE TABLE #Last4VisitData(VisitId INT,VisitDate VARCHAR(12),CategoryID INT,Category VARCHAR(200),IsStockAvailable TINYINT,IsOrderPlaced TINYINT,ColorCode VARCHAR(10),Ordr TINYINT)
	CREATE TABLE #Last4Visits(ID INT IDENTITY(1,1),VisitId INT,VisitDate VARCHAR(12))

	INSERT INTO #Last4Visits(VisitId,VisitDate)
	SELECT TOP 4 VisitId,FORMAT(VisitDate,'dd-MMM') FROm #Visits ORDER BY VisitDate DESC
	/*
	IF NOT EXISTS(SELECT 1 FROM #Last4Visits)
	BEGIN
		INSERT INTO #Last4Visits(VisitId,VisitDate)
		SELECT 0,'NA'
		UNION ALL
		SELECT 0,'NA'
		UNION ALL
		SELECT 0,'NA'
		UNION ALL
		SELECT 0,'NA'
	END
	ELSE IF NOT EXISTS(SELECT 1 FROM #Last4Visits where ID=2)
	BEGIN
		INSERT INTO #Last4Visits(VisitId,VisitDate)
		SELECT 0,'NA'
		UNION ALL
		SELECT 0,'NA'
		UNION ALL
		SELECT 0,'NA'
	END 
	ELSE IF NOT EXISTS(SELECT 1 FROM #Last4Visits where ID=3)
	BEGIN
		INSERT INTO #Last4Visits(VisitId,VisitDate)
		SELECT 0,'NA'
		UNION ALL
		SELECT 0,'NA'
	END
	ELSE IF NOT EXISTS(SELECT 1 FROM #Last4Visits where ID=4)
	BEGIN
		INSERT INTO #Last4Visits(VisitId,VisitDate)
		SELECT 0,'NA'
	END
	*/
	--SELECT * FROM #Last4Visits
	--SELECT * FROM #Last4Visits
	INSERT INTO #Last4VisitData(VisitId,VisitDate,CategoryID,Category,IsStockAvailable,IsOrderPlaced,ColorCode,Ordr)
	SELECT DISTINCT A.VisitId,A.VisitDate,B.CategoryNodeID,B.Category,0,0,'',Id
	FROM #Last4Visits A,#SKUList B

	SELECT DISTINCT A.VisitId,C.CategoryNodeID INTO #StockData
	FROM tblVisitStock A INNER JOIN #Last4Visits B ON A.VisitId=B.VisitId INNER JOIN #SKUList C ON A.ProductID=C.SKUNodeId --WHERE ISNULL(A.Qty,0)>0
	--SELECT * FROM #StockData
	UPDATE A SET A.IsStockAvailable=1 FROM #Last4VisitData A INNER JOIN #StockData B ON A.VisitId=B.VisitId AND A.CategoryID=B.CategoryNodeID

	SELECT DISTINCT A.VisitId,C.CategoryNodeID INTO #OrderData
	FROM tblOrderMaster A INNER JOIN #Last4Visits B ON A.VisitId=B.VisitId INNER JOIN tblOrderDetail D ON A.OrderId=D.OrderId INNER JOIN #SKUList C ON D.ProductID=C.SKUNodeId 
	WHERE ISNULL(D.OrderQty,0)>0
	--SELECT * FROM #OrderData

	UPDATE A SET A.IsOrderPlaced=1 FROM #Last4VisitData A INNER JOIN #OrderData B ON A.VisitId=B.VisitId AND A.CategoryID=B.CategoryNodeID

	UPDATE #Last4VisitData SET ColorCode='00B050' WHERE IsOrderPlaced=1 AND IsStockAvailable=1
	UPDATE #Last4VisitData SET ColorCode='92D050' WHERE (IsOrderPlaced=1 OR IsStockAvailable=1) AND ColorCode=''
	--SELECT * FROM #Last4VisitData ORDER BY Ordr,Brand

	SELECT @ColString=@ColString + ColString FROM (
	SELECT DISTINCT STUFF((SELECT ',[' + p1.VisitDate + ']'
	FROM #Last4Visits p1  ORDER BY Id
     FOR XML PATH(''), TYPE  
     ).value('.', 'NVARCHAR(MAX)')  
    ,1,1,'') ColString
	FROM #Last4Visits P) AS t
	--SELECT @ColString
	
	SELECT '00B050' AS ColorCode,'Stock available & placed order also'  AS Header
	UNION
	SELECT '92D050' AS ColorCode,'Either stock available or placed order' 

	IF EXISTS(SELECT 1 FROM #Last4VisitData)
	BEGIN	
		SET @strSQL='SELECT Category,'+ @ColString +' FROM (select VisitDate,Category,ColorCode from #Last4VisitData ) p PIVOT ( MAX (ColorCode) FOR VisitDate IN ( '+ @ColString +' ) ) AS pvt ORDER BY pvt.Category;'
		print @strSQL
		--exec sp_executesql @strSQL
		exec(@strSQL)
	END
	ELSE
	BEGIN
		SELECT DISTINCT Category FROM #Last4VisitData
	END

	SELECT ISNULL(FORMAT(@LastVisitDate,'dd-MMM-yy'),'NA') [Last Visit Date],ISNULL(FORMAT(@LastOrderDate,'dd-MMM-yy'),'NA') [Last Order Date]
	SELECT Category,SKU,StockQty [Stock Qty],OrderQty [Order Qty] FROM #LastVisitDetails ORDER BY Category,SKU
END
