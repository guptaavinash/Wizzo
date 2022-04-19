
-- [spDownloadOrders] '84AD54C9-9692-44C0-BB1E-A90A28C7E293','26-Sep-2019'

CREATE PROCEDURE [dbo].[spDownloadOrders] 
	-- Add the parameters for the stored procedure here
	@PDA_IMEI VARCHAR(50),    
	@Date date
AS
BEGIN


	DECLARE @PersonNodeID INT,@PersonNodetype SMALLINT
	SELECT @PersonNodeID=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@PDA_IMEI) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	SELECT @PersonNodetype=PersonType FROM tblSalesPersonMapping WHERE PersonNodeID=@PersonNodeID

	PRINT '@PersonNodeID=' + CAST(@PersonNodeID AS VARCHAR)
	PRINT '@@PersonNodetype=' + CAST(@PersonNodetype AS VARCHAR)

	SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY tblPrdMstrSKULvl.SKUCode) AS Sno,V.Category,tblPrdMstrSKULvl.SKUCode, tblPrdMstrSKULvl.Descr as SKU, SUM(b.OrderQty) OrderQty FROM tblOrderMaster AS a INNER JOIN
                         tblOrderDetail AS b ON a.OrderID = b.OrderID INNER JOIN
						 tblStoremaster(readpast) c ON c.StoreID=a.StoreID 
                         INNER JOIN tblPrdMstrSKULvl ON b.ProductID = tblPrdMstrSKULvl.NodeID
						 INNER JOIN VwSFAProductHierarchy V ON V.SKUNodeID=tblPrdMstrSKULvl.NodeID
WHERE       a.OrderDate=@Date AND (a.EntryPersonNodeId = @PersonNodeID) AND (a.EntryPersonNodetype = @PersonNodetype) AND (a.flgOffline = 1) AND (a.OrderStatusID <> 3) 
GROUP BY V.Category,tblPrdMstrSKULvl.SKUCode, tblPrdMstrSKULvl.Descr 


SELECT       DISTINCT ROW_NUMBER() OVER(ORDER BY StoreCode,tblPrdMstrSKULvl.SKUCode) AS Sno, a.OrderCode, a.OrderDate, c.StoreCode, c.StoreName, tblPrdMstrSKULvl.SKUCode, tblPrdMstrSKULvl.Descr as SKU, b.OrderQty, b.ProductRate, b.NetLineOrderVal,b.FreeQty,b.TotLineDiscVal
FROM            tblOrderMaster AS a INNER JOIN
                         tblOrderDetail AS b ON a.OrderID = b.OrderID INNER JOIN
						 tblStoremaster(readpast) c ON c.StoreID=a.StoreID 
                         INNER JOIN tblPrdMstrSKULvl ON b.ProductID = tblPrdMstrSKULvl.NodeID
WHERE       a.OrderDate=@Date AND (a.EntryPersonNodeId = @PersonNodeID) AND (a.EntryPersonNodetype = @PersonNodetype) AND (a.flgOffline = 1) AND (a.OrderStatusID <> 3)  
	end
