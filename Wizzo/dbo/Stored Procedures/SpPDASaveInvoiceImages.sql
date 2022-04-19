-- =============================================
-- Author:		Avinash Gupta
-- Create date: 30-Aug-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpPDASaveInvoiceImages] 
	@PDA_IMEI VARCHAR(50),
	@OrderID INT,
	@StoreID INT,
	@InvNumber VARCHAR(50),
	@InvDate DATE,
	@InvoiceImageName udt_Image ReadOnly
AS
BEGIN
	--SELECT * FROM tblInvImages
	DECLARE @SalesPersonNodeID INT
	DECLARE @SalesPersonNodeType INT

	SELECT @SalesPersonNodeID=SalesPersonNodeId,@SalesPersonNodeType=SalesPersonNodetype FROM dbo.fnGetPersonList(@PDA_IMEI)

	--DELETE FROM tblInvImages WHERE StoreID=@StoreID AND IMEINo=@PDA_IMEI AND InvDate=@InvDate AND OrderID=@OrderID
	DELETE FROM tblInvImages WHERE OrderID=@OrderID

	INSERT INTO tblInvImages(IMEINo,OrderID,StoreID,InvNumber,InvDate,ImageName,SalesPersonNodeID,SalesPersonNodetype)
	SELECT DISTINCT @PDA_IMEI,@OrderID,@StoreID,@InvNumber,@InvDate,M.ImageName,@SalesPersonNodeID,@SalesPersonNodeType FROM @InvoiceImageName M 

	
END
