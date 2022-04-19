/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2012 (11.0.6251)
    Source Database Engine Edition : Microsoft SQL Server Standard Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/


--DROP procEDURE [dbo].[spForPDA_Save_Order]
--GO
CREATE procEDURE [dbo].[spForPDA_Save_Order]
( 
	@StoreID INT,
	@InvoiceDate Date,
	@TotalBeforeTaxDis Amount,--TotalBeforeTaxDis(This is actual value after discount & before tax)
	@TaxAmt Amount, --TaxAmt
	@TotalDis Amount, --
	@InvoiceVal Amount,
	@DlvryLocId int,
	@BillLocId int,
	@DlvryDate date,
	@flgDefaultDlvryDatePass bit=0,
	@FreeTotal INT,
	@InvAfterDis  Amount,
	@AddDis  Amount,
	@VisitforDate  Date,
	@AmountCollected  Amount,
	@BalanceAmount  Amount,
	@PDA_IMEI  VARCHAR(100),
	@AmtPrevDue  Amount,
	@NoOfCoupons  INT,
	@TotalCouponsAmounts Amount,
	@RouteID INT,
	@RouteNodeType TINYINT,
	@Remark VARCHAR(100),
	@OrderedDet OrderedProductDet Readonly,
	@OrderSchemeDet udt_OrderSchemeFromPDA Readonly,
	@OrderSchemeSource OrderSchemeSource Readonly,
	@OrderPDAID VARCHAR(100) ,
	@OrderDeliveryTime	OrderDeliveryTime readonly,
	@VanDocNumber VARCHAR(15)=0,
	@CycleID INT,
	@StoreVisitCode	VARCHAR(200),
	@TeleCallingID INT,
	@FileSetID INT
--,
--@OrdPaymentStage OrdPaymentStage readonly
)
AS
BEGIN
PRINT 'A'
DECLARE @VisitDate Date,@VisitStart Date 
--SET @VisitDate=CONVERT(Date,@VisitforDate,105)
SET @VisitDate=@VisitforDate

--set @VisitStart=CONVERT(Date,@VisitStartTS,105)

--if @VisitStart>@VisitDate
--set @VisitDate=@VisitStart

DECLARE @RecalculateScheme TINYINT
SET @RecalculateScheme=0 -- 0=No Calculation Needed,1=Calculation Needed.
DECLARE @InvoiceTaxRecalculation TINYINT
SET @InvoiceTaxRecalculation=0 --0=No REcalculation Needed,1=Calculation Needed.

DECLARE @Channel VARCHAR(100)

IF ISNULL(@RouteID,0)=0
BEGIN
	SELECT @RouteID=RouteID,@RouteNodeType=RouteNodeType FROM [dbo].[tblRouteCoverageStoreMapping] WHERE StoreID=@StoreID AND GETDATE() BETWEEN Fromdate and Todate
END

if @DlvryLocId=0
select @DlvryLocId =OutAddID from tbloutletaddressdet where StoreID=@StoreID and OutAddTypeID=2

if 	@BillLocId =0
select @BillLocId =OutAddID from tbloutletaddressdet where StoreID=@StoreID and OutAddTypeID=1

if year(@DlvryDate)=1900
set @flgDefaultDlvryDatePass=1

--SELECT * FROM @OrderSchemeDet

--SELECT @RouteNodeType=NodeType FROM tblSecMenuContextMenu WHERE flgRoute=1
	SELECT 'Order sp called'

 	DECLARE @StoreVisitID INT, @RouteVisitID INT, @VisitID INT, @OrderID INT, @OrderDetailID INT, @DSRID INT,
	@PersonNodeID INT,@PersonType TINYINT,@OrderPDAIDSys VARCHAR(100)

	--Select @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI
	--PRINT '@DeviceID=' + CAST(ISNULL(@DeviceID,0) AS VARCHAR)
	--SELECT @PersonNodeID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@DeviceID  AND (GETDATE() BETWEEN DateFrom AND DateTo)
	DECLARE @EntryPersonNodeType SMALLINT,@EntryPersonNodeID INT
	
	
	SELECT @EntryPersonNodeID=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@PDA_IMEI) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	SELECT @EntryPersonNodeType=PersonType FROM tblSalesPersonMapping WHERE PersonNodeID=@EntryPersonNodeID

	PRINT '@@EntryPersonNodeID=' + CAST(@EntryPersonNodeID AS VARCHAR)
	PRINT '@@EntryPersonNodeType=' + CAST(@EntryPersonNodeType AS VARCHAR)
	

	SELECT @RouteID=RouteID,@RouteNodeType=Routenodetype  FROM [tblRouteCoverageStoreMapping]
	WHERE StoreID=@StoreID AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate

	SELECT @PersonNodeID=RV.DSENodeId,@PersonType=RV.DSENodeType FROM tblRoutePlanningVisitDetail RV WHERE RV.RouteNodeId=@RouteID AND RV.RouteNodetype=@RouteNodeType AND RV.VisitDate>=CAST(GETDATE() AS DATE)

	IF ISNULL(@PersonNodeID,0)=0
		SELECT @PersonNodeID=RV.DSENodeId,@PersonType=RV.DSENodeType FROM tblRoutePlanningVisitDetail RV WHERE RV.RouteNodeId=@RouteID AND RV.RouteNodetype=@RouteNodeType ORDER BY VisitDate DESC --AND RV.VisitDate>=CAST(GETDATE() AS DATE) 

	----SELECT @PersonNodeID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDA_IMEI) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	PRINT '@PersonNodeID=' + CAST(@PersonNodeID AS VARCHAR)
	PRINT '@PersonType=' + CAST(@PersonType AS VARCHAR)

	SELECT * INTO #CoverageArea FROM dbo.fnGetCoverageAreaBasedOnPDACode(@PDA_IMEI,GETDATE())

	DECLARE @VanID INT,@VanNodeType SMALLINT,@VanDocType VARCHAR(5)
	-- To Get the Van Assigment detail

	DECLARE @WorkingTypeID INT
	SELECT @WorkingTypeID=dbo.fnGetWorkingTypeForCoverageArea(CoverageAreaNodeID,CoverageAreaNodetype) FROM #CoverageArea

	PRINT '@WorkingTypeID=' + CAST(@WorkingTypeID AS VARCHAR)

	IF @WorkingTypeID=1 -- Direct
	BEGIN
		SET @OrderPDAID=@VanDocNumber  --- Just temporary solution till OrderPDAID is coming from PDA for Direct Sales.

		SELECT @VanID=SH.VanID,@VanNodeType=260  FROM tblSalesHierVanMapping SH INNER JOIN tblSalesPersonMapping SM ON SM.NodeID=SH.SalesNodeID AND SM.NodeType=SH.SalesNodetype INNER JOIN tblMstrPerson P ON P.NodeID=SM.PersonNodeID AND P.NodeType=SM.PersonType WHERE @VisitForDate BETWEEN SM.FromDate AND SM.ToDate AND CAST(@VisitForDate AS DATE) BETWEEN CAST(SH.Fromdate AS DATE) AND CAST(SH.Todate AS DATE) AND @VisitForDate BETWEEN P.FromDate AND P.ToDate AND SM.PersonNodeID=@PersonNodeID AND SM.PersonType=@PersonType

		SELECT @VanID=VanID,@VanNodeType=260 FROM tblVanStockMaster V,(SELECT SalesManNodeId,MAX(TransDate) TransDate FROM tblVanStockMaster WHERE SalesManNodeId=@PersonNodeID AND SalesManNodeType=@PersonType AND CAST(TransDate AS DATE)<=CAST(@VisitForDate AS DATE) GROUP BY SalesManNodeId) X WHERE X.TransDate=V.TransDate  AND X.SalesManNodeId=V.SalesManNodeId

		SET @VanDocType='I'
	END
	ELSE
	BEGIN
		SELECT @VanID=0 ,@VanNodeType=0
		----SELECT        @PersonNodeID = tblSalesPersonMapping.PersonNodeID,@PersonType=tblSalesPersonMapping.PersonType
		----FROM            tblSalesPersonMapping WHERE tblSalesPersonMapping.NodeID = @RouteID AND tblSalesPersonMapping.NodeType=@RouteNodeType	
		----AND (@VisitDate BETWEEN  CAST(tblSalesPersonMapping.FromDate AS DATE) AND CAST(tblSalesPersonMapping.ToDate AS DATE)) 
		----AND (@VisitDate BETWEEN  tblSalesPersonMapping.FromDate AND tblSalesPersonMapping.ToDate) 

		SET @VanDocType='D'
	END
	

	PRINT '@VanID=' + CAST(@VanID AS VARCHAR)


		
	
	 
	SET @AmountCollected = @InvoiceVal

	----SELECT @RouteVisitID=MAX(RouteVisitID) FROM tblTranVisitDetails WHERE DeviceID=@DeviceID AND RouteID=@RouteID AND RouteType=@RouteNodeType AND
	----CAST(VisitForDate AS DATE)=@VisitDate 
PRINT 'B'
	Select @VisitID = VisitID FROM [dbo].[tblVisitMaster] WHERE StoreID=@StoreID AND CAST(VisitDate AS DATE)=@VisitDate 
	SELECT @VisitID=ISNULL(@VisitID,0)
	PRINT '@VisitID=' + CAST(ISNULL(@VisitID,0) AS VARCHAR)
	PRINT '@@OrderPDAID=' + CAST(@OrderPDAID AS VARCHAR)
	PRINT '@VanDocNumber=' + CAST(@VanDocNumber AS VARCHAR)
	--- Code to identify the VisitDetID for the Order/Invoice
	DECLARE @VisitDetID INT
	SELECT @VisitDetID=VisitDetID FROM tblVisitDet WHERE StoreVisitCode=@StoreVisitCode

	--BEGIN TRANSACTION	
			SELECT @OrderID = OrderID FROM tblOrderMaster WHERE VisitID = ISNULL(@VisitID,0)  AND OrderPDAID=@OrderPDAID 
			PRINT '@OrderID=' + CAST(ISNULL(@OrderID,0) AS VARCHAR)
			--IF ISNULL(@OrderID,0)>0
			--BEGIN
			--	--DELETE FROM tblOrderMaster WHERE VisitID = @VisitID AND OrderPDAID=@OrderPDAID
			--	--DELETE FROM tblOrderDelivery WHERE OrderId = @OrderID
			--	--DELETE FROM tblOrderDetail WHERE OrderId = @OrderID
			--	--DELETE FROM tblOrderPaymentTerms WHERE OrderId = @OrderID
			--	--DELETE FROM tblOrderAdvChqDetail WHERE OrderId = @OrderID
			--	--DELETE FROM tblOrderBillingCustomerDetail WHERE OrderId = @OrderID
			--	--DELETE FROM tblOrderCollectAmtInfo WHERE OrderId = @OrderID
			--	--DELETE FROM tblOrderDeliveryBillingCustomerMapping WHERE OrderId = @OrderID
			--	--DELETE FROM tblOrderDeliveryCustomerDetail WHERE OrderId = @OrderID
			--	--DELETE FROM tblOrderSchemeSlabMapping WHERE OrderId = @OrderID
			--	--DELETE FROM tblOrderProductBatchDetail WHERE OrderId = @OrderID
			--	--Delete from tblOrderDeliveryTaxDetail WHERE OrderId = @OrderID
			--END

	
		
	
			-- Called sp of Ashwani from here......
			DECLARE @tblOrderVal udt_OrderVal
			DECLARE @tblOrderDet udt_OrderDet
			DECLARE @tblOrderProductDetail udt_OrderProductDetail
			DECLARE @tblOrderFreePrdDetail udt_OrderSchemeFreePrdDet 
			DECLARE @tblOrderPrdDiscountDetail udt_OrderSchemePrdDiscountDet 

			
			
			DECLARE @flgInvoiceOnDelivery TINYINT,@flgCollectionOnDelivery TINYINT,@FreightRuleID TINYINT,@CollectionRuleID TINYINT,@DlvryRuleID TINYINT,@InvRuleID TINYINT,
			@InsRuleID TINYINT,@TaxRuleID TINYINT,@OrderStatusID INT,@flgOrderClosed TINYINT,@OrderConfirmationDate SMALLDATETIME,@OrderCompletionDate SMALLDATETIME,
			@LoginID INT,@Remarks VARCHAR(100),@OrderSourceID INT


			-- Parameters set can be changed for the DMS implementation
			SET @OrderSourceID=1 -- PDA
			SET @flgInvoiceOnDelivery=1 -- YEs
			SET @flgCollectionOnDelivery=1 -- Yes
			SET @FreightRuleID=3 -- Included
			SET @CollectionRuleID=1 --Against Cash
			SET @DlvryRuleID=1 --Single Location , Single Delivery
			SET @InvRuleID=2 -- Invoice Agaist each Delivery
			SET @InsRuleID=4 -- Included
			SET @TaxRuleID=1 -- VAT
			SET @OrderStatusID=1 -- UnApproved
			SET @flgOrderClosed=0-- No
			SET @OrderConfirmationDate=CAST(@VisitDate AS DATE)
			SET @OrderCompletionDate=CAST(@VisitDate AS DATE)
			SET @Remarks=''
			SET @LoginID=0
			PRINT 'C'	
			----Delete [tblVisitStock] where VisitId=@VisitID
			----INSERT INTO [dbo].[tblVisitStock](VisitID,StockDate,ProductID,Qty)
			----SELECT @VisitID,CAST(@VisitDate AS DATE),ProdID,Stock FROM @OrderedDet WHERE isnull(Stock ,0)<>0
			PRINT 'D'			
			if exists(select * from @OrderedDet where OrderQty>0) 
				begin
				Declare @strOrder varchar(max)='',@DbrId int=0,@FYID INT=0,@DbrNodeType int=0
				SELECT @DbrId=DistNodeId,@DbrNodeType=DistNodeType FROM tblStoremaster WHERE StoreId=@StoreID


				
				if @flgDefaultDlvryDatePass=1
				begin

				set @DlvryDate=dateadd(dd,1,@VisitDate)
				set datefirst 1
				while 1=1
				begin
				
					----if exists(select * from [dbo].[tblDistributorHolidayMstr] where DistNodeId=@DBRId AND  DistNodeType=@DbrNodeType and HolidayDate=@DlvryDate)
					----begin
					----	set @DlvryDate=dateadd(dd,1,@DlvryDate)
					----	goto xx 
					----end

					----if exists(select * from [dbo].[tblDBRSalesStructureDBR] where NodeId=@DBRId AND  NodeType=@DbrNodeType and DlvryWeeklyOffDay=datepart(dw,@DlvryDate))
					----begin
					----	set @DlvryDate=dateadd(dd,1,@DlvryDate)
					----	goto xx 
					----end

					----if exists(select * from [dbo].tblDBRSalesStructureRouteMstr where NodeId=@RouteID AND  NodeType=@RouteNodeType and [OffDay]=datepart(dw,@DlvryDate))
					----begin
					----	set @DlvryDate=dateadd(dd,1,@DlvryDate)
					----	goto xx 
					----end
				
					if exists(select * from [dbo].tblCompanySalesStructureRouteMstr where NodeId=@RouteID AND  NodeType=@RouteNodeType and [OffDay]=datepart(dw,@DlvryDate))
					begin
						set @DlvryDate=dateadd(dd,1,@DlvryDate)
						goto xx 
					end
				break;
				xx:
				end
				end


				----select @DbrId=DBRNodeId,@DbrNodeType=DistributorNodeType from VwPersonStoreDetails A join VwAllDistributorHierarchy B
				----ON A.RouteId=B.DBRRouteId
				----where StoreId=@StoreID
				SELECT @FYID=FYID FROM TBLfINANCIALYEAR WHERE @VisitDate Between FYStartDate and FYEndDate
				

					IF @RecalculateScheme=1
					BEGIN
						SELECT 1
						-- Ashwani's sp called
					END
					ELSE
					BEGIN
					
	PRINT 'C'				
select @strOrder=@strOrder+strScheme FROM
(
select distinct convert(varchar,StoreId)+'~'+convert(varchar,B.PrdId)+'~'+convert(varchar,B.SchemeId)+'~'+convert(varchar,A.SchemeSlabid)+'~0'+'~'+convert(varchar,A.SchemeSalbSubBucketValue)+'~'+convert(varchar,A.SchemeSubBucketValtype)+'~'+convert(varchar,A.SchemeSlabSubBuckettype)+'~0~'+convert(varchar,A.BenefitSubBucketType)+'~'+convert(varchar,A.FreePrdId)+'~'+convert(varchar,A.BenefitSubBucketVal)+'~'+convert(varchar,
						A.BenefitMaxval)+'~'+convert(varchar,
						A.BenefitAssignedVal)+'~0~0~0~0~0~0~0~'+convert(varchar,c.SchemeTypeID)+'~0~0|' as strScheme from @OrderSchemeDet A JOIN @OrderSchemeSource B
						ON A.SchemeSlabid=B.SchemeSlabid
						and A.FreePrdId=B.PrdId
						join tblSchemeMaster C on B.SchemeId=c.SchemeId
						where A.BenefitSubBucketType in(5,6,7,10)) as A
				



						select @strOrder=@strOrder+convert(varchar,StoreId)+'~'+convert(varchar,B.PrdId)+'~'+convert(varchar,B.SchemeId)+'~'+convert(varchar,A.SchemeSlabid)+'~0'+'~'+convert(varchar,A.SchemeSalbSubBucketValue)+'~'+convert(varchar,A.SchemeSubBucketValtype)+'~'+convert(varchar,A.SchemeSlabSubBuckettype)+'~0~'+convert(varchar,A.BenefitSubBucketType)+'~'+convert(varchar,A.FreePrdId)+'~'+convert(varchar,A.BenefitSubBucketVal)+'~'+convert(varchar,
						A.BenefitMaxval)+'~'+convert(varchar,
						A.BenefitAssignedVal)+'~0~0~0~0~0~0~0~'+convert(varchar,c.SchemeTypeID)+'~0~0|' from @OrderSchemeDet A JOIN @OrderSchemeSource B
						ON A.SchemeSlabid=B.SchemeSlabid
						join tblSchemeMaster C on B.SchemeId=c.SchemeId
						where A.BenefitSubBucketType in(1,2,3,8,9)

							-- Comment by Avinash as per RSPL sp .
							--INSERT INTO @tblOrderDet(ProdID,OrderQty,Rate,LineOrderVal,[TotLineDiscVal],[LineOrderValWDisc],[TotTaxValue],TotTaxRate,[NetLineOrderVal],
							--Stock,SampleQty,FreeQTY)
							--SELECT ProdID,OrderQty,o.ProductRate*(1+TaxRate/100),(LineOrderVal-TaxValue)+DisVal,DisVal,LineOrderVal-TaxValue,TaxValue,TaxRate,LineOrderVal,
							--Stock,[flgSalesQuote],0 FROM @OrderedDet O --INNER JOIN tblPrdMstrSKULvl S
							----ON S.NodeID=O.ProdID
							--WHERE OrderQty>0

							 INSERT INTO @tblOrderDet(ProdID,OrderQty,Rate,LineOrderVal,[TotLineDiscVal],[LineOrderValWDisc],[TotTaxValue],TotTaxRate,[NetLineOrderVal],  
							   Stock,SampleQty,FreeQTY)  
							   SELECT ProdID,OrderQty,ProductRate,(LineOrderVal-TaxValue)+DisVal,DisVal,LineOrderVal-TaxValue,TaxValue,TaxRate,LineOrderVal,  
							   Stock,[flgSalesQuote],FreeQty FROM @OrderedDet O --INNER JOIN tblPrdMstrSKULvl S  
							   --ON S.NodeID=O.ProdID  
							   WHERE OrderQty>0 
							
							Update A set FreeQty=B.[BenefitAssignedVal] from @tblOrderDet A join @OrderSchemeDet B
							ON A.ProdID=B.FreePrdID
							WHERE BenefitSubBucketType IN (1,5) 
							
							 INSERT INTO @tblOrderDet(ProdID,OrderQty,Rate,LineOrderVal,[TotLineDiscVal],[LineOrderValWDisc],[TotTaxValue],TotTaxRate,[NetLineOrderVal],
							Stock,SampleQty,FreeQTY)
							
							Select B.FreePrdID,0,C.StandardRate,0,0,0,0,0,0,0,0,B.[BenefitAssignedVal] from @tblOrderDet A RIGHT join @OrderSchemeDet B
							ON A.ProdID=B.FreePrdID
							JOIN VwSFAProductHierarchy  C on C.SKUNodeID=B.FreePrdID
							WHERE BenefitSubBucketType IN (1,5) and A.PRODID is null
							
							INSERT INTO @tblOrderVal(TotOrderVal ,TotDiscVal ,TotOrderValWDisc ,TotTaxVal ,NetOrderValue ,[TotLineOrderVal],[TotLineLevelDisc],ActDiscVal)
							SELECT @TotalBeforeTaxDis ,	@AddDis,@TotalBeforeTaxDis-@AddDis,@TaxAmt ,@InvoiceVal,SUM(LineOrderVal),SUM([TotLineDiscVal]),@AddDis from @tblOrderDet
							
							Update @tblOrderVal set TotTaxVal=TotTaxVal-(TotDiscVal-(TotDiscVal/(1+(TotTaxVal/TotOrderVal)))),
							TotDiscVal=(TotDiscVal/(1+(TotTaxVal/TotOrderVal))) WHERE TotOrderVal>0
							
							Update @tblOrderVal set TotOrderValWDisc=TotOrderVal-TotDiscVal,
							NetOrderValue=(TotOrderVal-TotDiscVal)+TotTaxVal WHERE TotOrderVal>0
													
							INSERT INTO @tblOrderFreePrdDetail(SchemeSlabID,FreePrdID,Qty)
							SELECT SchemeSlabID,FreePrdID,[BenefitAssignedVal] FROM @OrderSchemeDet WHERE BenefitSubBucketType IN (1,5) 
							INSERT INTO @tblOrderPrdDiscountDetail(PrdID,SchemeSlabID,BenefitTypeID,BenefitVal)
							SELECT FreePrdID,[SchemeSlabID],[BenefitSubBucketType],[BenefitAssignedVal] FROM @OrderSchemeDet WHERE BenefitSubBucketType NOT IN (1,5)
						
						--INSERT INTO #tblOrderSchemeDet()
					END
				
			if isnull(@OrderId,0)=0
			begin
			print 'ttt'
					INSERT INTO tblOrderMaster (OrderCode,VisitID,RouteNodeId,RouteNodeType,OrderDate,StoreID,OrderSourceID,SalesPersonID,SalesPersonType,TotalDeliveryBy,TotOrderVal, TotDiscVal, TotOrderValWDisc,TotTaxVal,NetOrderValue,flgInvoiceOnDelivery,flgCollectionOnDelivery,FreightRuleID,CollectionRuleID,DlvryRuleID,InvRuleID,InsRuleID,TaxRuleID, OrderStatusID,flgOrderClosed,LoginIDIns,TimestampIns,OrderConfirmationDate,OrderCompletionDate,[TotLineOrderVal],[TotLineLevelDisc],SalesNodeId,SalesNodeType,strSchemeBenefit, ActAddDisc, OrderLogId,flgOffline,OrdPrcsId,FYID,OrderPDAID,TotOtherCharges,EntryPersonNodeID,EntryPersonNodeType,VanDocnumber,VanDocType,VanLoadUnLoadCycID,VanNodeID,VanNodeType,VisitDetID,TelecallID,FileSetID)

					SELECT CONVERT(VARCHAR(8),CONVERT(DATETIME,@VisitDate,105),112)+CAST(@StoreID AS VARCHAR) AS OrderCode, @VisitID,@RouteID,@RouteNodeType, CONVERT(DATETIME,@VisitDate,105), @StoreID, @OrderSourceID,@PersonNodeID,@PersonType, @DlvryDate,TotOrderVal,TotDiscVal,TotOrderValWDisc,TotTaxVal,NetOrderValue, @flgInvoiceOnDelivery,@flgCollectionOnDelivery, @FreightRuleID,@CollectionRuleID,@DlvryRuleID,@InvRuleID,@InsRuleID,@InsRuleID,@OrderStatusID,@flgOrderClosed,@LoginID,GETDATE(),@OrderConfirmationDate,
@OrderCompletionDate,[TotLineOrderVal],[TotLineLevelDisc],@DbrId,@DbrNodeType,@strOrder,@AddDis,0,1,1,@FYID,@OrderPDAID,0,@EntryPersonNodeID,@EntryPersonNodeType,@VanDocNumber,@VanDocType,@CycleID,@VanID,@VanNodeType,@VisitDetID,@TeleCallingID,@FileSetID
					FROM @tblOrderVal

					SELECT @OrderID = IDENT_CURRENT('tblOrderMaster')
					SELECT @OrderID 

					declare @OrderCode varchar(50),@SeqNo int
		print @FYID
		print @DbrId
					exec spGenerateTrnSequenceNumber 'tblOrderMaster','OrderCode','O',@FYID,@DbrId,@DbrNodeType,@SeqNo output,@OrderCode output
					Print 'test'
					WHILE EXISTS (SELECT OrderCode  FROM tblOrderMaster WHERE OrderCode =@OrderCode AND SalesNodeId=@DbrId AND SalesNodeType=@DbrNodeType)
					BEGIN
						exec spGenerateTrnSequenceNumber 'tblOrderMaster','OrderCode','O',@FYID,@DbrId,@DbrNodeType,@SeqNo output,@OrderCode output
					END
					Print 'test2'
					UPDATE tblOrderMaster SET OrderCode=@OrderCode,OrderInitTag='O',OrderSeqNo=@SeqNo WHERE OrderId=@OrderId
			    
			  end
			  else
			  begin
			  update A set TotOrderVal=B.TotOrderVal,TotDiscVal=B.TotDiscVal,TotOrderValWDisc=B.TotOrderValWDisc,TotTaxVal=B.TotTaxVal,
			  NetOrderValue=B.NetOrderValue,TotLineOrderVal=B.TotLineOrderVal,TotLineLevelDisc=B.TotLineLevelDisc,RouteNodeId=@RouteID,RouteNodeType=@RouteNodeType,VanNodeID=@VanID,VanNodeType=@VanNodeType,SalesNodeId=@DbrId,SalesNodeType=@DbrNodeType,VisitDetID=@VisitDetID,TelecallID=@TeleCallingID from tblOrderMaster A , @tblOrderVal b 
			  where a.orderid=@orderid
			  end 				


					--INSERT INTO tblOrderDetail(OrderID,ProductID,OrderQty,LineOrderVal,TotLineDiscVal,LineOrderValWDisc,TotTaxValue,NetLineOrderVal,LoginIDIns,TimestampIns,SampleQty,PrcBatchID,ProductRate,TaxRate,FreeQty,SalesUnitId)
					--SELECT @OrderID,ProdID,OrderQty,LineOrderVal,[TotLineDiscVal],[LineOrderValWDisc],[TotTaxValue],[NetLineOrderVal],1,GETDATE(),SampleQty,0,Rate,TotTaxRate,FreeQty,8 FROM @tblOrderDet
	PRINT 'D'
	Declare @OrderDetailN OrderDetailSFA,@OrderDeliveryBillingMappingN OrderDeliveryBillingMapping,@OrderDeliveryN OrderDelivery

	insert into @OrderDeliveryBillingMappingN
	select  1,@orderid,@DlvryLocId,0,0,0,@BillLocId,0,0,0,0,0 
	 
	--insert into @OrderDetailN
	--select row_number() over (order by ProdID) as itemno,@OrderID,ProdID,0,OrderQty,8,0,Rate,LineOrderVal
	--,[TotLineDiscVal],[LineOrderValWDisc],TotTaxRate,[TotTaxValue],[NetLineOrderVal],0,'','',SampleQty,FreeQty,'',0,'',SampleQty,0
	--from @tblOrderDet

	insert into @OrderDetailN
	select row_number() over (order by ProdID) as itemno,@OrderID,ProdID,0,OrderQty,8,0,Rate,LineOrderVal
	,[TotLineDiscVal],[LineOrderValWDisc],TotTaxRate,[TotTaxValue],[NetLineOrderVal],0,'','',SampleQty,FreeQty,'',0,'',SampleQty,0
	from @tblOrderDet

	insert into @OrderDeliveryN
	select item_rowno,1,orderid,[OrderQty],@DlvryDate,0,[TotTaxRate],[TotTaxValue],0 from @OrderDetailN
			  
 PRINT 'E'
 Delete DeliveryCustomerDetail  from tblOrderDeliveryCustomerDetail as DeliveryCustomerDetail where not exists
 (select * from @OrderDeliveryBillingMappingN DeliveryCustomerDetailSrc where DeliveryCustomerDetail.DeliveryLocationNodeId = DeliveryCustomerDetailSrc.DeliveryLocationNodeId  
and DeliveryCustomerDetail.DeliveryLocationNodeType = DeliveryCustomerDetailSrc.DeliveryLocationNodeType  
and DeliveryCustomerDetail.DeliveryContactPersonNodeType = DeliveryCustomerDetailSrc.DeliveryContactPersonNodeType  
and DeliveryCustomerDetail.DeliveryContactPersonNodeId = DeliveryCustomerDetailSrc.DeliveryContactPersonNodeId  
and DeliveryCustomerDetail.OrderID = DeliveryCustomerDetailSrc.OrderID )
and OrderID=@OrderId
  
MERGE tblOrderDeliveryCustomerDetail DeliveryCustomerDetail USING (select distinct OrderID,DeliveryLocationNodeId,DeliveryLocationNodeType,DeliveryContactPersonNodeId, DeliveryContactPersonNodeType
 from  @OrderDeliveryBillingMappingN) as DeliveryCustomerDetailSrc
  
ON DeliveryCustomerDetail.DeliveryLocationNodeId = DeliveryCustomerDetailSrc.DeliveryLocationNodeId  
and DeliveryCustomerDetail.DeliveryLocationNodeType = DeliveryCustomerDetailSrc.DeliveryLocationNodeType  
and DeliveryCustomerDetail.OrderID = DeliveryCustomerDetailSrc.OrderID  
WHEN MATCHED THEN  
  UPDATE  
  SET DeliveryCustomerDetail.DeliveryContactPersonNodeType = DeliveryCustomerDetailSrc.DeliveryContactPersonNodeType  ,
 DeliveryCustomerDetail.DeliveryContactPersonNodeId = DeliveryCustomerDetailSrc.DeliveryContactPersonNodeId  ,
 DeliveryCustomerDetail.LoginIDUpd = @LoginId,  
 DeliveryCustomerDetail.TimeStampUpd = GETDATE()  
WHEN NOT MATCHED BY TARGET THEN  
  INSERT (OrderID,DeliveryLocationNodeId,DeliveryLocationNodeType,DeliveryContactPersonNodeId, DeliveryContactPersonNodeType,
		LoginIDIns, TimeStampIns)  
  VALUES (DeliveryCustomerDetailSrc.OrderID,DeliveryCustomerDetailSrc.DeliveryLocationNodeId,DeliveryCustomerDetailSrc.DeliveryLocationNodeType,
  DeliveryCustomerDetailSrc.DeliveryContactPersonNodeId,DeliveryCustomerDetailSrc.DeliveryContactPersonNodeType,
  @LoginId,Getdate());  
  PRINT 'F'
Update DeliveryCustomerDetailSrc Set OrderDeliveryLocationId=DeliveryCustomerDetail.OrderDeliveryLocationId FROM @OrderDeliveryBillingMappingN AS DeliveryCustomerDetailSrc JOIN tblOrderDeliveryCustomerDetail DeliveryCustomerDetail ON
 DeliveryCustomerDetail.DeliveryLocationNodeId = DeliveryCustomerDetailSrc.DeliveryLocationNodeId  
and DeliveryCustomerDetail.DeliveryLocationNodeType = DeliveryCustomerDetailSrc.DeliveryLocationNodeType  
--and DeliveryCustomerDetail.DeliveryContactPersonNodeType = DeliveryCustomerDetailSrc.DeliveryContactPersonNodeType  
--and DeliveryCustomerDetail.DeliveryContactPersonNodeId = DeliveryCustomerDetailSrc.DeliveryContactPersonNodeId  
and DeliveryCustomerDetail.OrderID = DeliveryCustomerDetailSrc.OrderID  



 Delete BillingCustomerDetail  from tblOrderBillingCustomerDetail as BillingCustomerDetail where not exists
 (select * from @OrderDeliveryBillingMappingN BillingCustomerDetailSrc where BillingCustomerDetail.BillingLocationNodeId = BillingCustomerDetailSrc.BillingLocationNodeId  
and BillingCustomerDetail.BillingLocationNodeType = BillingCustomerDetailSrc.BillingLocationNodeType  
and BillingCustomerDetail.BillingDeptNodeId = BillingCustomerDetailSrc.BillingDeptNodeId  
and BillingCustomerDetail.BillingDeptNodeType = BillingCustomerDetailSrc.BillingDeptNodeType  
and BillingCustomerDetail.OrderID = BillingCustomerDetailSrc.OrderID  )
and OrderID=@OrderId

PRINT 'G'
MERGE tblOrderBillingCustomerDetail BillingCustomerDetail USING (select distinct OrderID,
BillingLocationNodeId,
BillingLocationNodeType,
BillingDeptNodeId,
BillingDeptNodeType from  @OrderDeliveryBillingMappingN) as BillingCustomerDetailSrc
  
ON BillingCustomerDetail.BillingLocationNodeId = BillingCustomerDetailSrc.BillingLocationNodeId  
and BillingCustomerDetail.BillingLocationNodeType = BillingCustomerDetailSrc.BillingLocationNodeType  
and BillingCustomerDetail.BillingDeptNodeId = BillingCustomerDetailSrc.BillingDeptNodeId  
and BillingCustomerDetail.BillingDeptNodeType = BillingCustomerDetailSrc.BillingDeptNodeType  
and BillingCustomerDetail.OrderID = BillingCustomerDetailSrc.OrderID  
WHEN NOT MATCHED BY TARGET THEN  
Insert (OrderID,BillingLocationNodeId,BillingLocationNodeType,BillingDeptNodeId,BillingDeptNodeType  ,LoginIDIns, TimeStampIns)
values(BillingCustomerDetailSrc.OrderID,BillingCustomerDetailSrc.BillingLocationNodeId,BillingCustomerDetailSrc.BillingLocationNodeType,BillingCustomerDetailSrc.BillingDeptNodeId,
BillingCustomerDetailSrc.BillingDeptNodeType ,@LoginId,Getdate());

Update BillingCustomerDetailSrc Set OrderBillingLocationId=BillingCustomerDetail.OrderBillingLocationId FROM @OrderDeliveryBillingMappingN AS BillingCustomerDetailSrc 
JOIN tblOrderBillingCustomerDetail BillingCustomerDetail ON
BillingCustomerDetail.BillingLocationNodeId = BillingCustomerDetailSrc.BillingLocationNodeId  
and BillingCustomerDetail.BillingLocationNodeType = BillingCustomerDetailSrc.BillingLocationNodeType  
and BillingCustomerDetail.BillingDeptNodeId = BillingCustomerDetailSrc.BillingDeptNodeId  
and BillingCustomerDetail.BillingDeptNodeType = BillingCustomerDetailSrc.BillingDeptNodeType  
and BillingCustomerDetail.OrderID = BillingCustomerDetailSrc.OrderID  
 
 Delete from tblOrderDeliveryBillingCustomerMapping where OrderID=@OrderId
 
 Insert into tblOrderDeliveryBillingCustomerMapping
 select OrderDeliveryLocationId,OrderBillingLocationId,OrderID from @OrderDeliveryBillingMappingN
 
 PRINT 'H'
 Delete OrderDetail  from tblOrderDetail OrderDetail where not exists
 (select * from @OrderDetailN as OrderDetailSrc where OrderDetail.ProductID = OrderDetailSrc.PrdId  
and OrderDetail.OrderID = OrderDetailSrc.OrderID    )
and OrderID=@OrderId

 
 
MERGE tblOrderDetail OrderDetail USING @OrderDetailN as OrderDetailSrc
  
ON OrderDetail.ProductID   = OrderDetailSrc.PrdID  
and OrderDetail.OrderID = OrderDetailSrc.OrderID  
WHEN MATCHED  THEN  Update SET OrderDetail.OrderQty=OrderDetailSrc.OrderQty,
OrderDetail.PrcBatchID=OrderDetailSrc.PrcBatchID,
OrderDetail.SalesUnitId=OrderDetailSrc.SalesUnitId,
OrderDetail.PriceTermId=OrderDetailSrc.PriceTermId,
OrderDetail.ProductRate=OrderDetailSrc.ProductPrice,
OrderDetail.ProductRateBeforeTax=OrderDetailSrc.ProductPrice/(1+OrderDetailSrc.TotTaxRate/100),
OrderDetail.LineOrderVal=OrderDetailSrc.OrderVal,
OrderDetail.TotLineDiscVal=OrderDetailSrc.TotLineDiscVal,
OrderDetail.LineOrderValWDisc=OrderDetailSrc.LineOrderValWDisc,
OrderDetail.TaxRate=OrderDetailSrc.TotTaxRate,
OrderDetail.TotTaxValue=OrderDetailSrc.TotTaxValue,
OrderDetail.NetLineOrderVal=OrderDetailSrc.NetLineOrderVal,
OrderDetail.SampleQty=OrderDetailSrc.SampleQty,
OrderDetail.FreeQty=OrderDetailSrc.FreeQty,
OrderDetail.strSchemeSource=OrderDetailSrc.strSchemeSource,
OrderDetail.flgRateChange=1,
OrderDetail.flgQuotationApplied=OrderDetailSrc.flgQuotationApplied,
OrderDetail.strBatchPrice=OrderDetailSrc.strBatchPrice,
OrderDetail.LoginIDUpd=@LoginId,
OrderDetail.TimeStampUpd=Getdate()
WHEN NOT MATCHED BY TARGET THEN  
Insert (OrderID,ProductID,PrcBatchID,OrderQty,SalesUnitId,PriceTermId,ProductRate,LineOrderVal,TotLineDiscVal,LineOrderValWDisc,TaxRate,TotTaxValue,NetLineOrderVal,SampleQty, LoginIDIns,FreeQty, TimeStampIns,strSchemeSource,flgRateChange,strBatchPrice,ProductRateBeforeTax,flgQuotationApplied)
values(OrderDetailSrc.OrderID,OrderDetailSrc.PrdID,OrderDetailSrc.PrcBatchID,OrderDetailSrc.OrderQty,OrderDetailSrc.SalesUnitId,OrderDetailSrc.PriceTermId,OrderDetailSrc.ProductPrice,OrderDetailSrc.OrderVal,OrderDetailSrc.TotLineDiscVal,OrderDetailSrc.LineOrderValWDisc,OrderDetailSrc.TotTaxRate,OrderDetailSrc.TotTaxValue,OrderDetailSrc.NetLineOrderVal,OrderDetailSrc.SampleQty ,@LoginId,
OrderDetailSrc.FreeQty,Getdate(),OrderDetailSrc.strSchemeSource,1,OrderDetailSrc.strBatchPrice,OrderDetailSrc.ProductPrice/(1+OrderDetailSrc.TotTaxRate/100),OrderDetailSrc.flgQuotationApplied);

Update OrderDetailSrc set OrderDetailSrc.OrderDetailId=OrderDetail.OrderDetailID from @OrderDetailN as OrderDetailSrc JOIN tblOrderDetail OrderDetail
ON OrderDetail.ProductID = OrderDetailSrc.PrdId  
and OrderDetail.OrderID = OrderDetailSrc.OrderID 
 

 
 
 

 
MERGE tblOrderDelivery OrderDelivery USING (select A.OrderId, A.OrderDetailId,C.OrderBillingLocationId,C.OrderDeliveryLocationId,B.OrderQty,SUM(B.TaxAmount) AS TaxAmt,B.RequiredDeliveryDate from  @OrderDetailN A join @OrderDeliveryN B
ON A.Item_ROWNO=b.Item_ROWNO
JOIN @OrderDeliveryBillingMappingN C on B.Del_ROWNO=C.Del_ROWNO
GROUP BY A.OrderId,A.OrderDetailId,C.OrderBillingLocationId,C.OrderDeliveryLocationId,B.RequiredDeliveryDate,B.OrderQty) as OrderDeliverySrc
  
ON OrderDelivery.OrderDetailId = OrderDeliverySrc.OrderDetailId  
and OrderDelivery.OrderBillingLocationId = OrderDeliverySrc.OrderBillingLocationId  
and OrderDelivery.OrderDeliveryLocationId = OrderDeliverySrc.OrderDeliveryLocationId
and OrderDelivery.RequiredDeliveryDate = OrderDeliverySrc.RequiredDeliveryDate
and OrderDelivery.OrderId = OrderDeliverySrc.OrderId

WHEN MATCHED  THEN  Update SET OrderDelivery.Qty=OrderDeliverySrc.OrderQty,
OrderDelivery.TaxRate=OrderDeliverySrc.TaxAmt,
OrderDelivery.LoginIDUpd=@LoginId,
OrderDelivery.TimeStampUpd=Getdate()

--WHEN NOT MATCHED BY Source THEN  delete

WHEN NOT MATCHED BY TARGET THEN  
Insert (OrderDetailID,OrderId,Qty,RequiredDeliveryDate,OrderDeliveryLocationId,OrderBillingLocationId,TaxRate  ,LoginIDIns, TimeStampIns)
values(OrderDeliverySrc.OrderDetailID,OrderDeliverySrc.OrderId,OrderDeliverySrc.OrderQty,OrderDeliverySrc.RequiredDeliveryDate,OrderDeliverySrc.OrderDeliveryLocationId,
OrderDeliverySrc.OrderBillingLocationId,OrderDeliverySrc.TaxAmt ,@LoginId,
Getdate());


--SELECT * from 
--@OrderDetailN A join @OrderDeliveryN B
--ON A.Item_ROWNO=b.Item_ROWNO
--JOIN @OrderDeliveryBillingMappingN C on B.Del_ROWNO=C.Del_ROWNO
--JOIN tblOrderDelivery OrderDelivery ON
--OrderDelivery.OrderDetailId = A.OrderDetailId  
--and OrderDelivery.OrderBillingLocationId = C.OrderBillingLocationId  
--and OrderDelivery.OrderDeliveryLocationId = C.OrderDeliveryLocationId
--and OrderDelivery.RequiredDeliveryDate = B.RequiredDeliveryDate
PRINT 'I'
Update B SET B.OrderDetailDeliveryID=OrderDelivery.OrderDetailDeliveryID from 
@OrderDetailN A join @OrderDeliveryN B
ON A.Item_ROWNO=b.Item_ROWNO
JOIN @OrderDeliveryBillingMappingN C on B.Del_ROWNO=C.Del_ROWNO
JOIN tblOrderDelivery OrderDelivery ON
OrderDelivery.OrderDetailId = A.OrderDetailId  
and OrderDelivery.OrderBillingLocationId = C.OrderBillingLocationId  
and OrderDelivery.OrderDeliveryLocationId = C.OrderDeliveryLocationId
and OrderDelivery.RequiredDeliveryDate = B.RequiredDeliveryDate
--sELECT * FROM @OrderDeliveryN




Delete OrderDelivery  from tblOrderDelivery OrderDelivery where not exists
 (select * from @OrderDeliveryN as OrderDetailSrc where OrderDelivery.OrderDetailDeliveryID = OrderDetailSrc.OrderDetailDeliveryID)
and OrderId=@OrderId


PRINT 'J'
Delete  tblOrderDeliveryTaxDetail where OrderId=@OrderId
insert into tblOrderDeliveryTaxDetail (OrderDetailDeliveryID,PriceTermId,OrderId,TaxPercentage,TaxAmount)
select OrderDetailDeliveryID,TaxPriceTermId,OrderId,TaxPercentage,TaxAmount from @OrderDeliveryN 

	Delete tblOrderSchemeSlabMapping where OrderId=@OrderId
			insert into tblOrderSchemeSlabMapping(SchemeSlabID,OrderID,SchemeTypeID)
			select Distinct A.[SchemeSlabID],@OrderId,[SchemeTypeID] FROM @OrderSchemeDet A join [dbo].[tblSchemeSlabDetails]
			B ON A.[SchemeSlabID]=B.[SchemeSlabID]
			JOIN [dbo].[tblSchemeMaster] C ON B.[SchemeID]=C.[SchemeID]
			where SchemeTypeId<>3

			insert into tblOrderSchemeSlabSource(OrdSchemeSlabMappingID,OrderDetID,SchemeSlabBucketTypeID,BenExceptionAssignedVal)
			SELECT Distinct C.OrdSchemeSlabMappingID,B.OrderDetailID,[SchemeSlabSubBucketType],D.BenefitAssignedVal FROM
			 @OrderSchemeSource A 
			join tblOrderSchemeSlabMapping C ON C.[SchemeSlabID]=A.[SchemeSlabID]
			join tblOrderDetail B ON B.ProductID=A.PrdID
			AND C.OrderID=B.OrderID
			join @OrderSchemeDet D ON A.[SchemeSlabID]=D.[SchemeSlabID]
			WHERE C.OrderID=@OrderId and SchemeTypeId<>3


			insert into tblOrderSchemeSlabBenefit(OrdSchemeSlabMappingID,OrderDetID,FreeQty,DiscValue,BenTypeId)
			SELECT Distinct C.OrdSchemeSlabMappingID,B.OrderDetailID,CASE WHEN [BenefitSubBucketType]  IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,CASE WHEN [BenefitSubBucketType] NOT IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,[BenefitSubBucketType] FROM
			 @OrderSchemeDet A 
			join tblOrderSchemeSlabMapping C ON C.[SchemeSlabID]=A.[SchemeSlabID]
			join tblOrderDetail B ON B.ProductID=A.[FreePrdID]
			AND C.OrderID=B.OrderID
			WHERE C.OrderID=@OrderId AND [BenefitSubBucketType] not IN(8,9) and SchemeTypeId<>3

			insert into tblOrderSchemeSlabBenefit(OrdSchemeSlabMappingID,OrderDetID,FreeQty,DiscValue,BenTypeId)
			SELECT Distinct C.OrdSchemeSlabMappingID,0,CASE WHEN [BenefitSubBucketType]  IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,CASE WHEN [BenefitSubBucketType] NOT IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,[BenefitSubBucketType] FROM
			 @OrderSchemeDet A 
			join tblOrderSchemeSlabMapping C ON C.[SchemeSlabID]=A.[SchemeSlabID]
			WHERE C.OrderID=@OrderId AND [BenefitSubBucketType] IN(8,9) and SchemeTypeId<>3

			select A.*,Convert(int,0) as OrdSchemeSlabMappingID,Convert(int,0) AS Rown into #tmpOrderSchemeDet from @OrderSchemeDet A join [dbo].[tblSchemeSlabDetails]
			B ON A.[SchemeSlabID]=B.[SchemeSlabID]
			JOIN [dbo].[tblSchemeMaster] C ON B.[SchemeID]=C.[SchemeID]
			where [SchemeTypeID]=3

			insert into tblOrderSchemeSlabMapping(SchemeSlabID,OrderID,SchemeTypeID)
			select  A.[SchemeSlabID],@OrderId,[SchemeTypeID] FROM #tmpOrderSchemeDet A join [dbo].[tblSchemeSlabDetails]
			B ON A.[SchemeSlabID]=B.[SchemeSlabID]
			JOIN [dbo].[tblSchemeMaster] C ON B.[SchemeID]=C.[SchemeID]
			where [SchemeTypeID]=3
			group by A.[SchemeSlabID],[SchemeTypeID],PrdID

			Update B set Rown=A.Rown from 
			(select  SchemeSlabId,OrdSchemeSlabMappingID,PrdID,Row_Number() over(Partition by SchemeSlabId order by SchemeSlabId,PrdID) as Rown from #tmpOrderSchemeDet
			GROUP BY SchemeSlabId,OrdSchemeSlabMappingID,PrdID) AS A
			join #tmpOrderSchemeDet AS B on  A.SchemeSlabId=B.SchemeSlabId
			AND A.PrdID=B.PrdID


			Update A set OrdSchemeSlabMappingID=B.OrdSchemeSlabMappingID From 
			#tmpOrderSchemeDet AS A
			join 
			(SELECT SchemeSlabID,OrdSchemeSlabMappingID,Row_Number() over(Partition by SchemeSlabId order by SchemeSlabId,OrdSchemeSlabMappingID) as Rown2 FROM tblOrderSchemeSlabMapping WHERE OrderID=@OrderId and SchemeTypeID=3) 
			as B
			on A.SchemeSlabId=B.SchemeSlabId AND A.Rown=B.Rown2


			insert into tblOrderSchemeSlabSource(OrdSchemeSlabMappingID,OrderDetID,SchemeSlabBucketTypeID,BenExceptionAssignedVal)
			SELECT Distinct A.OrdSchemeSlabMappingID,B.OrderDetailID,[SchemeSlabSubBucketType],BenefitAssignedVal FROM
			 #tmpOrderSchemeDet A 
			join tblOrderDetail B ON B.ProductID=A.PrdID
			AND B.OrderID=@OrderId

			insert into tblOrderSchemeSlabBenefit(OrdSchemeSlabMappingID,OrderDetID,FreeQty,DiscValue,BenTypeId)
			SELECT Distinct A.OrdSchemeSlabMappingID,B.OrderDetailID,CASE WHEN [BenefitSubBucketType]  IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,CASE WHEN [BenefitSubBucketType] NOT IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,[BenefitSubBucketType] FROM
			 #tmpOrderSchemeDet A 
			join tblOrderDetail B ON B.ProductID=A.[FreePrdID]
			WHERE B.OrderID=@OrderId AND [BenefitSubBucketType] not IN(8,9) 

			insert into tblOrderSchemeSlabBenefit(OrdSchemeSlabMappingID,OrderDetID,FreeQty,DiscValue,BenTypeId)
			SELECT Distinct A.OrdSchemeSlabMappingID,0,CASE WHEN [BenefitSubBucketType]  IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,CASE WHEN [BenefitSubBucketType] NOT IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,[BenefitSubBucketType] FROM
			 #tmpOrderSchemeDet A 
			WHERE  [BenefitSubBucketType] IN(8,9) 
					
					--INSERT INTO [dbo].[tblOrderSchemeApplication_FreePrd](OrderID,SchemeSlabID,FreePrdID,Qty,TimesSlabApplied,TimeStampIns)
					--SELECT @OrderID,SchemeSlabID,FreePrdID,Qty,0,GETDATE() FROM @tblOrderFreePrdDetail

					

					--INSERT INTO [dbo].[tblOrderSchemeApplication_Discount](OrderID,OrderDetID,SchemeSlabID,BenefitTypeID,TimesSlabApplied,BenefitVal,TimeStampIns)
					--SELECT @OrderID,OD.OrderDetailID,[SchemeSlabID],[BenefitTypeID],0,[BenefitVal],GETDATE() FROM @tblOrderPrdDiscountDetail PD INNER JOIN tblOrderDetail OD
					--ON OD.OrderID=@OrderID AND OD.ProductID=PD.PrdID
					
			
			Update A SET         A.BenCost= C.LineOrderVal* A.DiscValue/100
FROM            tblOrderSchemeSlabBenefit AS A INNER JOIN
                         tblOrderSchemeSlabMapping AS B ON A.OrdSchemeSlabMappingID = B.OrdSchemeSlabMappingID INNER JOIN
                         tblOrderDetail AS C ON A.OrderDetID = C.OrderDetailID
WHERE        (B.OrderID = @OrderId) AND (C.OrderID = @OrderId) AND (A.BenTypeId IN (2, 6))

Update A SET         A.BenCost= A.DiscValue
FROM            tblOrderSchemeSlabBenefit AS A INNER JOIN
                         tblOrderSchemeSlabMapping AS B ON A.OrdSchemeSlabMappingID = B.OrdSchemeSlabMappingID INNER JOIN
                         tblOrderDetail AS C ON A.OrderDetID = C.OrderDetailID
WHERE        (B.OrderID = @OrderId) AND (C.OrderID = @OrderId) AND (A.BenTypeId IN (3, 7))

Update A SET         A.BenCost= C.TotLineDiscVal
FROM            tblOrderSchemeSlabBenefit AS A INNER JOIN
                         tblOrderSchemeSlabMapping AS B ON A.OrdSchemeSlabMappingID = B.OrdSchemeSlabMappingID INNER JOIN
                         tblOrderDetail AS C ON A.OrderDetID = C.OrderDetailID
WHERE        (B.OrderID = @OrderId) AND (C.OrderID = @OrderId) AND (A.BenTypeId=10)


Update A SET         A.BenCost= A.FreeQty*C.ProductRateBeforeTax
FROM            tblOrderSchemeSlabBenefit AS A INNER JOIN
                         tblOrderSchemeSlabMapping AS B ON A.OrdSchemeSlabMappingID = B.OrdSchemeSlabMappingID INNER JOIN
                         tblOrderDetail AS C ON A.OrderDetID = C.OrderDetailID
WHERE        (B.OrderID = @OrderId) AND (C.OrderID = @OrderId) AND (A.BenTypeId IN (1, 5))

Update A SET         A.BenCost= A.DiscValue
FROM            tblOrderSchemeSlabBenefit AS A INNER JOIN
                         tblOrderSchemeSlabMapping AS B ON A.OrdSchemeSlabMappingID = B.OrdSchemeSlabMappingID 
WHERE        (B.OrderID = @OrderId)  AND (A.BenTypeId IN (9))

Update A SET         A.BenCost= C.TotOrderVal* A.DiscValue/100
FROM            tblOrderSchemeSlabBenefit AS A INNER JOIN
                         tblOrderSchemeSlabMapping AS B ON A.OrdSchemeSlabMappingID = B.OrdSchemeSlabMappingID INNER JOIN
                         tblOrderMaster AS C ON B.OrderID = C.OrderID
WHERE        (B.OrderID = @OrderId)  AND (A.BenTypeId IN (8))	

PRINT 'K'
Delete [tblOrderPaymentModeMap] where orderid=@OrderId
Delete [tblOrderPaymentStageMap] where orderid=@OrderId
Declare @NetOrderValue amount=0
select @NetOrderValue=NetOrderValue from tblOrderMaster where OrderId=@OrderId
insert into [dbo].[tblOrderPaymentStageMap](OrderId,PymtStageId,Percentage,PymtStageAmt,CreditDays,CreditLimit,ExtendedCreditDays,InvoiceSettlementType,CreditPeriodType,GracePeriodinDays)
select @OrderId,PymtStageId,Percentage,@NetOrderValue*Percentage/100,dbo.fnGetActCreditDays(CreditPeriodType,@DlvryDate,CreditDays),CreditLimit,CreditDays,InvoiceSettlementType,CreditPeriodType,GracePeriodinDays from tblStorePaymentStageMap where StoreId=@StoreID and CONVERT(DATETIME,@VisitDate,105) between FromDate and ToDate 

insert into [dbo].[tblOrderPaymentModeMap]
select C.OrderPaymentStageMapId,@ORDERID,A.PaymentModeId from [tblStorePaymentModeMap] A join tblStorePaymentStageMap B on A.StorePaymentStageMappingId=B.StorePaymentStageMappingId
JOIN [tblOrderPaymentStageMap] C on C.PymtStageId=b.PymtStageId
WHERE B.StoreId=@StoreId   and CONVERT(DATETIME,@VisitDate,105) between B.FromDate and B.ToDate 
and C.orderid=@orderid


--insert into @OrdPaymentStage
--select * from tblstorepaymentstagemap where storeid=@storeid

--	Delete A FROM tblOrderPaymentStageMap A Left join @OrdPaymentStage B 
--on A.PymtStageId=b.PymtStageId
--WHERE A.OrderId=@OrderId AND B.PymtStageId is null 



--MERGE tblOrderPaymentStageMap OrderPaymentStageMap USING @OrdPaymentStage OrderPaymentStageMapSrc
--				ON OrderPaymentStageMap.PymtStageId = OrderPaymentStageMapSrc.PymtStageId
--			and
--				OrderPaymentStageMap.OrderId=@OrderId
--				WHEN MATCHED THEN
--				  UPDATE
--				  SET 
--				  OrderPaymentStageMap.Percentage = OrderPaymentStageMapSrc.Percentage,
--				   OrderPaymentStageMap.PymtStageAmt = OrderPaymentStageMapSrc.PymtStageAmt,
--				  OrderPaymentStageMap.CreditDays = OrderPaymentStageMapSrc.CreditDays,
--				  OrderPaymentStageMap.CreditLimit = OrderPaymentStageMapSrc.CreditLimit
--				WHEN NOT MATCHED BY TARGET THEN
--				  INSERT (OrderId,PymtStageId,PymtStageAmt,Percentage,CreditDays,CreditLimit)
--				  VALUES (@OrderId,OrderPaymentStageMapSrc.PymtStageId,OrderPaymentStageMapSrc.PymtStageAmt,OrderPaymentStageMapSrc.Percentage,OrderPaymentStageMapSrc.CreditDays,OrderPaymentStageMapSrc.CreditLimit);




--						Delete [dbo].tblOrderPaymentModeMap where OrderId=@OrderId
					
--					insert into tblOrderPaymentModeMap
--					select distinct b.OrderPaymentStageMapId,@OrderId,c.items from @OrdPaymentStage A join tblOrderPaymentStageMap B on A.PymtStageId=B.PymtStageId
--					cross apply dbo.split(A.PymtMode,'|') c
--					WHERE B.OrderId=@OrderId
					  
--					AND c.items<>''

PRINT 'L'
UPDATE A SET DlvryStartTime=B.DlvryStartTime,DlvryEndTime=B.DlvryEndTime FROM tblOrderDeliveryTimeDetail A  join @OrderDeliveryTime b
		on  A.DlvryTimeType=B.DlvryTimeType
		WHERE A.OrderId=@OrderId

		INSERT INTO tblOrderDeliveryTimeDetail(OrderId,DlvryTimeType,DlvryStartTime,DlvryEndTime)
		select DISTINCT @OrderId,B.DlvryTimeType,B.DlvryStartTime,B.DlvryEndTime from tblOrderDeliveryTimeDetail A RIGHT join @OrderDeliveryTime b
		on  A.DlvryTimeType=B.DlvryTimeType
		AND A.OrderId=@OrderId
		WHERE A.DlvryTimeType IS NULL
		Delete A FROM
		tblOrderDeliveryTimeDetail A left join @OrderDeliveryTime b
		on  A.DlvryTimeType=B.DlvryTimeType
		
		WHERE B.DlvryTimeType IS NULL 
		AND A.OrderId=@OrderId

		PRINT' @WorkingTypeID' + CAST(@WorkingTypeID AS VARCHAR)
		--IF @WorkingTypeID=1 -- Direct
		--BEGIN
		--	exec [spInvoiceDirectSaveInvoice] 	'',@OrderId,@VisitforDate,2
		--	PRINT 'Called 111'
		--	DECLARE @InvoiceIntegerNumber INT
		--	SET @InvoiceIntegerNumber=CAST(SUBSTRING(@VanDocNumber,PATINDEX('%-%',@VanDocNumber)+1,PATINDEX('%/%',@VanDocNumber)-PATINDEX('%-%',@VanDocNumber)-1) AS INT)
		--	EXEC spUpdateTrnSequenceNumber 'tblInvMaster','InvCode','I',@FYID,@VanID,@vanNodeType, @InvoiceIntegerNumber
		--END
		
		EXEC SpSendOrderSMS @StoreID,@OrderID
end
	--COMMIT TRANSACTION	

END






