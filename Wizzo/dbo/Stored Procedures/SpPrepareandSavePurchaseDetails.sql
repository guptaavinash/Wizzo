-- =============================================
-- Author:		Avinash
-- Create date: 14-Jun-2019
-- Description:	
-- =============================================
--DROP PROC [SpPrepareandSavePurchaseDetails]
CREATE PROCEDURE [dbo].[SpPrepareandSavePurchaseDetails]
	@FileSetId INT,
	@StoreId INT,
	@VisitId INT,
	@VisitForDate Date,
	@StoreVisitCode VARCHAR(100),
	@tblRawDataPurchaseHeader udt_rawdatainvoiceheader READONLY,
	@tblRawDataPurchaseDetail udt_rawdatainvoicedetail READONLY,
	@tblRawDataDeliveryDetails udt_RawDataDeliveryDetails READONLY,
	@PDA_IMEI VARCHAR(50)

AS	
BEGIN
	PRINT '@StoreId For Order=' + CAST(ISNULL(@StoreId,0) AS VARCHAR)
	PRINT '@VisitId For Order=' + CAST(ISNULL(@VisitId,0) AS VARCHAR)
	PRINT '@StoreVisitCode For Order=' + ISNULL(@StoreVisitCode,'')

	DECLARE @OrderID INT
	DECLARE @InvoiceDate Date,@TotalBeforeTaxDis Amount,@TaxAmt Amount,@TotalDis Amount,@InvoiceVal Amount,@DlvryLocId INT=0,@BillLocId INT=0,@DlvryDate date='01-Jan-1900',@flgDefaultDlvryDatePass bit=0,	@FreeTotal INT,@InvAfterDis  Amount,@AddDis  Amount,@AmountCollected  Amount=0,@BalanceAmount  Amount=0,@AmtPrevDue  Amount=0,@NoOfCoupons  INT,@TotalCouponsAmounts Amount,
	@RouteID INT=0,@RouteNodeType TINYINT=0,@Remark VARCHAR(100)='',@OrderPDAID VARCHAR(100),@VanDocNumber VARCHAR(15)='0',@CycleID INT=0 , @TeleCallingID INT

	DECLARE @OrderedDet OrderedProductDet ,@OrderSchemeSource OrderSchemeSource ,@OrderSchemeDet udt_OrderSchemeFromPDA ,@OrderDeliveryTime	OrderDeliveryTime
	
	DECLARE @BillToAddress VARCHAR(500),@ShipToAddress VARCHAR(500),@DlvryStartTime Time,@DlvryEndTime Time,@NotDlvryStartTime Time,@NotDlvryEndTime Time

	IF ISNULL(@StoreVisitCode,'')=''
	BEGIN
		SELECT @InvoiceDate=[InvoiceDate],@TotalBeforeTaxDis=[TotalBeforeTaxDis],@TaxAmt=[TaxAmt],@TotalDis=[TotalDis],@InvoiceVal=[InvoiceVal],@FreeTotal=[FreeTotal],@InvAfterDis=[InvAfterDis],@AddDis=[AddDis],@NoOfCoupons=[NoCoupon],@TotalCouponsAmounts=[TotalCoupunAmount],@OrderPDAID=InvoiceNumber,@TeleCallingID=TeleCallingId FROM @tblRawDataPurchaseHeader WHERE StoreID=@StoreId

		-- Orderdeatil data comes from PDA is coming seperately for flgcarton and non carton which will be combined for the main table entry.

		---OLD Code
		--INSERT INTO @OrderedDet(ProdID,Stock,OrderQty,ProductRate,LineOrderVal,DisVal,TaxRate,TaxValue,SampleQty,flgSalesQuote,FreeQty)
		--SELECT DISTINCT [ProdID],0,[OrderQty],[ProductPrice],CAST([LineValAftrTxAftrDscnt] AS FLOAT)-CAST(DisVal AS FLOAT),DisVal,[TaxRate],[TaxValue],[FreeQty],[flgIsQuoteRateApplied],[FreeQty] FROM @tblRawDataPurchaseDetail D INNER JOIN @tblRawDataPurchaseHeader H ON H.[InvoiceNumber]=D.[InvoiceNumber] WHERE  H.StoreID=@StoreId 

		--- New Code
		INSERT INTO @OrderedDet(ProdID,Stock,OrderQty,ProductRate,LineOrderVal,DisVal,TaxRate,TaxValue,SampleQty,flgSalesQuote,FreeQty)
		SELECT DISTINCT [ProdID],0,SUM(CAST([OrderQty] AS INT)),[ProductPrice],CAST(SUM(CAST([LineValAftrTxAftrDscnt] AS FLOAT)) AS FLOAT),SUM(CAST(DisVal AS FLOAT)),[TaxRate],SUM(CAST([TaxValue] AS FLOAT)),SUM(CAST([FreeQty] AS INT)),[flgIsQuoteRateApplied],SUM(CAST([FreeQty] AS INT)) FROM @tblRawDataPurchaseDetail D INNER JOIN @tblRawDataPurchaseHeader H ON H.[InvoiceNumber]=D.[InvoiceNumber] WHERE  H.StoreID=@StoreId
		GROUP BY [ProdID],[ProductPrice],[TaxRate],[flgIsQuoteRateApplied]
	END
	ELSE
	BEGIN
		SELECT 'Saving Invoice'
		SELECT * FROM @tblRawDataPurchaseHeader
		SELECT @InvoiceDate=[InvoiceDate],@TotalBeforeTaxDis=[TotalBeforeTaxDis],@TaxAmt=[TaxAmt],@TotalDis=[TotalDis],@InvoiceVal=[InvoiceVal],@FreeTotal=[FreeTotal],@InvAfterDis=[InvAfterDis],@AddDis=[AddDis],@NoOfCoupons=[NoCoupon],@TotalCouponsAmounts=[TotalCoupunAmount],@OrderPDAID=InvoiceNumber,@TeleCallingID=TeleCallingId FROM @tblRawDataPurchaseHeader WHERE StoreVisitCode=@StoreVisitCode

		-- Orderdeatil data comes from PDA is coming seperately for flgcarton and non carton which will be combined for the main table entry.

		-- OLD Code
		--INSERT INTO @OrderedDet(ProdID,Stock,OrderQty,ProductRate,LineOrderVal,DisVal,TaxRate,TaxValue,SampleQty,flgSalesQuote,freeqty)
		--SELECT DISTINCT [ProdID],0,[OrderQty],[ProductPrice],CAST([LineValAftrTxAftrDscnt] AS FLOAT)-CAST(DisVal AS FLOAT),DisVal,[TaxRate],[TaxValue],[FreeQty],[flgIsQuoteRateApplied],[FreeQty] FROM @tblRawDataPurchaseDetail D INNER JOIN @tblRawDataPurchaseHeader H ON H.[InvoiceNumber]=D.[InvoiceNumber] WHERE H.StoreVisitCode=@StoreVisitCode
		
		-- NEw Code
		SELECT * FROM @tblRawDataPurchaseDetail
		SELECT DISTINCT [ProdID],0,SUM(CAST([OrderQty] AS INT)),[ProductPrice],CAST(SUM(CAST([LineValAftrTxAftrDscnt] AS FLOAT)) AS FLOAT),SUM(CAST(DisVal AS FLOAT)),[TaxRate],SUM(CAST([TaxValue] AS FLOAT)),SUM(CAST([FreeQty] AS INT)),[flgIsQuoteRateApplied],SUM(CAST([FreeQty] AS INT)) FROM @tblRawDataPurchaseDetail D INNER JOIN @tblRawDataPurchaseHeader H ON H.[InvoiceNumber]=D.[InvoiceNumber] WHERE H.StoreVisitCode=@StoreVisitCode
		GROUP BY [ProdID],[ProductPrice],[TaxRate],[flgIsQuoteRateApplied]

		INSERT INTO @OrderedDet(ProdID,Stock,OrderQty,ProductRate,LineOrderVal,DisVal,TaxRate,TaxValue,SampleQty,flgSalesQuote,freeqty)
		SELECT DISTINCT [ProdID],0,SUM(CAST([OrderQty] AS INT)),[ProductPrice],CAST(SUM(CAST([LineValAftrTxAftrDscnt] AS FLOAT)) AS FLOAT),SUM(CAST(DisVal AS FLOAT)),[TaxRate],SUM(CAST([TaxValue] AS FLOAT)),SUM(CAST([FreeQty] AS INT)),[flgIsQuoteRateApplied],SUM(CAST([FreeQty] AS INT)) FROM @tblRawDataPurchaseDetail D INNER JOIN @tblRawDataPurchaseHeader H ON H.[InvoiceNumber]=D.[InvoiceNumber] WHERE H.StoreVisitCode=@StoreVisitCode
		GROUP BY [ProdID],[ProductPrice],[TaxRate],[flgIsQuoteRateApplied]
	END
	 


	SELECT @BillToAddress=BillToAddress,@ShipToAddress=ShipToAddress FROM @tblRawDataDeliveryDetails WHERE StoreVisitCode=@StoreVisitCode

	IF LEN(@BillToAddress)>0
	SELECT @BillLocId=CAST(@BillToAddress AS INT)

	CREATE TABLE #DlvryDetails (ID INT IDENTITY(1,1),Value VARCHAR(200))
	IF LEN(ISNULL(@ShipToAddress,''))>0
	BEGIN
		INSERT INTO #DlvryDetails(Value)
		SELECT items FROM dbo.Split(@ShipToAddress,'^')

		SELECT @DlvryLocId=Value FROM #DlvryDetails WHERE ID=1
		SELECT @DlvryStartTime=Value FROM #DlvryDetails WHERE ID=2
		SELECT @DlvryEndTime=Value FROM #DlvryDetails WHERE ID=3
		SELECT @NotDlvryStartTime=Value FROM #DlvryDetails WHERE ID=4
		SELECT @NotDlvryEndTime=Value FROM #DlvryDetails WHERE ID=5
		SELECT @DlvryDate=Value FROM #DlvryDetails WHERE ID=6

		INSERT INTO @OrderDeliveryTime
		SELECT 1,@DlvryStartTime,@DlvryEndTime
		UNION
		SELECT 2,@NotDlvryStartTime,@NotDlvryEndTime

		IF CAST(@DlvryDate AS DATE)<>'01-Jan-1900'
		BEGIN
			SET @flgDefaultDlvryDatePass=1
		END


	END

	EXEC [spForPDA_Save_Order] @StoreID,@InvoiceDate,@TotalBeforeTaxDis,@TaxAmt,@TotalDis,@InvoiceVal,@DlvryLocId,@BillLocId,@DlvryDate,@flgDefaultDlvryDatePass,@FreeTotal,@InvAfterDis,@AddDis,@VisitforDate,@AmountCollected,@BalanceAmount,@PDA_IMEI,@AmtPrevDue,@NoOfCoupons,@TotalCouponsAmounts,@RouteID,@RouteNodeType,@Remark,@OrderedDet,@OrderSchemeDet,@OrderSchemeSource,@OrderPDAID,@OrderDeliveryTime,@VanDocNumber,@CycleID,@StoreVisitCode,@TeleCallingID,@FileSetId

	
	--UPDATE T SEt flgCallConversionStatus=2 FROM tblteleCallerListForDay T INNER JOIN @tblRawDataPurchaseHeader H ON H.TeleCallingID=T.TeleCallingId
	--WHERE H.StoreVisitCode=@StoreVisitCode
				
			

	

END
