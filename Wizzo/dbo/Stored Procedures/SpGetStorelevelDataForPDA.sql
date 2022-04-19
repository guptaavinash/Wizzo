-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--DECLARE @tblStoreID udt_StoreID
--INSERT INTO @tblStoreID
--SELECT 6952
--EXEC [SpGetStorelevelDataForPDA] '22-Mar-2019',@tblStoreID
CREATE PROCEDURE [dbo].[SpGetStorelevelDataForPDA] 
	 @RptDate DATE,
	 @tblStoreID udt_StoreID ReadOnly
AS
BEGIN
	IF @RptDate=CAST(GETDATE() AS DATE)
		SET @RptDate=DATEADD(dd,-1,GETDATE())

	DECLARE @FirstDate DATE=CAST(CAST(CONVERT(VARCHAR(6),@RptDate,112) AS VARCHAR) + '01' AS DATE)
	DECLARE @P3MMonthFirstDate DATE=DATEADD(mm,-2,@FirstDate)
	--SELECT @FirstDate=DATEADD(dd,-28,@RptDate)
	DECLARE @RptMonthYear INT=CONVERT(VARCHAR(6),@RptDate,112)
	PRINT @RptDate
	PRINT @FirstDate
	PRINT @RptMonthYear	
	PRINT @P3MMonthFirstDate

	CREATE TABLE #StoreList(StoreId INT,P3MVolumeInKG FLOAT,MTDVolumeInKG FLOAT,NoOfBrands INT,FlgProductive TINYINT)
	INSERT INTO #StoreList(StoreId,P3MVolumeInKG,MTDVolumeInKG,NoOfBrands,FlgProductive)
	SELECT StoreId,0,0,0,0 FROM @tblStoreID
	
	SELECT SKUNodeId,CategoryNodeID,Grammage INTO #PrdHier FROM VwSFAProductHierarchy
	--SELECT * FROM #PrdHier

	SELECT OM.StoreId,OM.OrderId,OM.OrderDate,CONVERT(VARCHAR(6),OM.OrderDate,112) RptMonthYear,OD.ProductId,P.CategoryNodeID,OD.OrderQty,OD.OrderQty*CAST(Grammage AS FLOAT) OrderVolumeKG INTO #OrderData
	FROM tblOrderMaster(nolock) OM INNER JOIN #StoreList S ON OM.StoreId=S.StoreId
	INNER JOIN tblOrderDetail(nolock) OD ON OM.OrderId=Od.OrderId
	INNER JOIN #PrdHier P ON OD.ProductId=P.SKUNodeId
	WHERE OM.OrderDate>=@P3MMonthFirstDate AND OM.OrderDate<=@RptDate
	--SELECT * FROM #OrderData

	UPDATE A SET A.P3MVolumeInKG=B.OrderVolumeKG FROM #StoreList A INNER JOIN (SELECT StoreId,SUM(OrderVolumeKG) OrderVolumeKG FROM #OrderData GROUP BY StoreId) B ON A.StoreId=B.StoreId

	UPDATE A SET A.MTDVolumeInKG=B.OrderVolumeKG FROM #StoreList A INNER JOIN (SELECT StoreId,SUM(OrderVolumeKG) OrderVolumeKG FROM #OrderData WHERE RptMonthYear=@RptMonthYear GROUP BY StoreId) B ON A.StoreId=B.StoreId

	UPDATE A SET A.NoOfBrands=B.NoOfBrands
	FROM #StoreList A INNER JOIN (SELECT StoreId,COUNT(DISTINCT CategoryNodeID) NoOfBrands FROM #OrderData GROUP BY StoreId) B ON A.StoreId=B.StoreId

	SELECT S.StoreId,MAX(VM.VisitDate) LastVisitDate INTO #LastVisit 
	FROM #StoreList S INNER JOIN tblVisitMaster VM ON S.StoreId=VM.StoreId WHERE VM.VisitDate<=@RptDate GROUP BY S.StoreId
	--SELECT * FROM #LastVisit

	UPDATE A SET A.FlgProductive=1 
	FROM #StoreList A INNER JOIN #LastVisit V ON A.StoreId=V.StoreId INNER JOIN tblVisitMaster VM ON V.StoreId=VM.StoreId AND V.LastVisitDate=VM.VisitDate
	INNER JOIN tblOrderMaster OM ON VM.VisitId=OM.VisitId

	SELECT * FROM #StoreList
END
