-- =============================================
-- Author:		Avinash Gupta
-- Create date: 27Mar2017
-- Description:	
-- =============================================

CREATE PROCEDURE [dbo].[SpPDAManageDistributorTodaysStock] 
	@CustomerNodeID INT,
	@CustomerNodeType SMALLINT,
	@StockDate DATE,
	@IMEINo VARCHAR(100),
	@flgPackType TINYINT,
	@tblDistProductStock udt_DistProductStock Readonly -- flgProductType 1=Regular,2=Free,3=Sample,4=Expired
AS
BEGIN	
	DECLARE @ChannelId INT=0
	DECLARE @DeviceID INT
	DECLARE @PersonNodeID INT
	DECLARE @PersonNodeType SMALLINT
	
	SELECT @PersonNodeID=NodeID,@PersonNodeType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@IMEINO) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID


	IF EXISTS(SELECT 1 FROM [tblDistributorStockDet] WHERE CustomerNodeID=@CustomerNodeID AND CustomerNodeType=@CustomerNodeType AND StockDate=@StockDate)
	BEGIN
		PRINT 'A'
		DELETE FROM [tblDistributorStockDet] WHERE CustomerNodeID=@CustomerNodeID AND CustomerNodeType=@CustomerNodeType AND StockDate=@StockDate
	END

	INSERT INTO [tblDistributorStockDet](CustomerNodeID,CustomerNodeType,ProductNodeID,ProductNodeType,StockDate,PersonNodeid,PersonNodeType,flgpackType)
	SELECT DISTINCT @CustomerNodeID,@CustomerNodeType,[ProductNodeID],[ProductNodeType],@StockDate,@PersonNodeID,@PersonNodeType,@flgPackType FROM
	@tblDistProductStock --WHERE flgProductType=1  -- Enter only regular product
	
	INSERT INTO tblDistributorMonthWiseStockDet(DistStockID,Monthval,Yearval,monthname,StockQty)
	SELECT S.DistStockID,MOnthval,YEarval,MonthName,P.[StockQty] FROM @tblDistProductStock P INNER JOIN [tblDistributorStockDet] S ON S.ProductNodeID=P.ProductNodeID 
	AND S.ProductNodeType=P.ProductNodeType AND S.CustomerNodeID=@CustomerNodeID AND S.CustomerNodeType=@CustomerNodeType AND S.StockDate=@StockDate --WHERE flgProductType=1

	UPDATE SD Set StockQty =X.TotStockQty FROM tblDistributorStockDet SD,(SELECT @CustomerNodeID CustomerNodeID,@CustomerNodeType CustomerNodeType,SD.ProductNodeID,SD.ProductNodeType,SUM(StockQty) TotStockQty 
	FROM @tblDistProductStock SD --WHERE flgProductType=1 
	GROUP BY SD.ProductNodeID,SD.ProductNodeType) X WHERE X.CustomerNodeID=SD.CustomerNodeID AND X.CustomerNodeType=SD.CustomerNodeType
	AND X.ProductNodeID=SD.ProductNodeID AND X.ProductNodeType=SD.ProductNodeType AND StockDate=@StockDate
	
END

