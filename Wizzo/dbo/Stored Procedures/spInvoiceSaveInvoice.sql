

CREATE PROC [dbo].[spInvoiceSaveInvoice]
@PDA_IMEI VARCHAR(50),
@strData VARCHAR(MAX), --PrdID^Rate^DelQty^FreeQty^DiscAmount^|PrdID^Rate^DelQty^FreeQty^DiscAmount^|PrdID^Rate^DelQty^FreeQty^DiscAmount^|
@OrderID INT,
@strDate VARCHAR(20),
@AddDisc Amount,
@flgCancel TINYINT, --1: Cancle 
@CancelRemarks VARCHAR(200),
@CancelReasonID INT,
@InvNumber VARCHAR(200),
@InvDate DATE
AS
set @strDate=CONVERT(varchar,getdate(),106)
--Select @strData = '1^10^100^11^|2^10.10^10^12^|3^20.3^300^13^|4^40^400^14^|'
DECLARE @InvID INT, @PrdID INT, @Rate DECIMAL(18,2), @DelQty INT, @FreeQty INT, @strTemp VARCHAR(1000), @TotalInvVal DECIMAL(18,2), @TotalTaxValue DECIMAL(18,2), @NetInvValue DECIMAL(18,2), @StoreID INT,@DiscAmt Amount

CREATE TABLE #TmpData(PrdID INT, PrdRate DECIMAL(18,2), DelQty INT, FreeQty INT, TaxRate DECIMAL(18,2), SchemeID INT,StandardRateBeforeTax Decimal(18,4),ActualRateAfterDiscountBeforeTax Decimal(18,4),TaxAmount Decimal(18,4),NetAmount Decimal(18,4),DiscAmt Decimal(18,4))


SELECT @StoreID = StoreID FROM [dbo].[tblOrderMaster] WHERE OrderID = @OrderID

UPDATE O SET EnteredInvNumber=@InvNumber,EnteredInvDate=@InvDate FROM tblOrderMaster O WHERE OrderID = @OrderID

IF EXISTS(Select * FROM [dbo].tblInvMaster WHERE OrderID = @OrderID)
	BEGIN
			
			Select @InvID = InvID FROM [dbo].tblInvMaster WHERE OrderID = @OrderID

			--DELETE FROM [dbo].[tblInvoiceDetail] WHERE InvID = @InvID
			
	END

Declare @SalesNodeId int,@SalesNodeType int,@RouteId int,@RouteNodeType SMALLINT,@LoginId int=0

select @RouteId=RouteId,@RouteNodeType=RouteNodeType from tblRouteCoverageStoreMapping where CONVERT(DATE,@strDate,105) between FromDate and TODATE

SELECT @SalesNodeId=SalesNodeId,@SalesNodeType=SalesNodeType FROM tblOrderMaster WHERE orderid=@OrderID

IF(@flgCancel = 1)
	BEGIN
			--INSERT INTO [dbo].[tblInvoiceMaster](OrderID, InvDate, StoreID,LoginIDIns, TimestampIns, flgInvStatus,DBRNodeId,DBRNodeType)
			--SELECT @OrderID, CONVERT(DATE,@strDate,105), @StoreID,1, GETDATE(), 2,@DbrNodeId,@DbrNodeType
			update [tblOrderMaster] set OrderStatusID=3,CancelRemarks=@CancelRemarks,CancelReasonID=@CancelReasonID WHERE OrderID = @OrderID
	END
ELSE
	BEGIN
			WHILE(PATINDEX('%|%',@strData)>0)
			BEGIN
					SET @strTemp = SUBSTRING(@strData,0,PATINDEX('%|%',@strData))
			
					Select @PrdID = SUBSTRING(@strTemp,0,PATINDEX('%^%',@strTemp))
					SET @strTemp = SUBSTRING(@strTemp,PATINDEX('%^%',@strTemp)+1, LEN(@strTemp) - PATINDEX('%^%',@strTemp))
			
					Select @Rate = SUBSTRING(@strTemp,0,PATINDEX('%^%',@strTemp))
					SET @strTemp = SUBSTRING(@strTemp,PATINDEX('%^%',@strTemp)+1, LEN(@strTemp) - PATINDEX('%^%',@strTemp))
			
					Select @DelQty = SUBSTRING(@strTemp,0,PATINDEX('%^%',@strTemp))
					SET @strTemp = SUBSTRING(@strTemp,PATINDEX('%^%',@strTemp)+1, LEN(@strTemp) - PATINDEX('%^%',@strTemp))

					Select @FreeQty = SUBSTRING(@strTemp,0,PATINDEX('%^%',@strTemp))
					SET @strTemp = SUBSTRING(@strTemp,PATINDEX('%^%',@strTemp)+1, LEN(@strTemp) - PATINDEX('%^%',@strTemp))

			Select @DiscAmt = SUBSTRING(@strTemp,0,PATINDEX('%^%',@strTemp))
					SET @strTemp = SUBSTRING(@strTemp,PATINDEX('%^%',@strTemp)+1, LEN(@strTemp) - PATINDEX('%^%',@strTemp))


					INSERT INTO #TmpData(PrdID, PrdRate, DelQty, FreeQty,DiscAmt)
					SELECT @PrdID, @Rate, @DelQty, @FreeQty,@DiscAmt
			
					SET @strData = SUBSTRING(@strData,PATINDEX('%|%',@strData)+1, LEN(@strData) - PATINDEX('%|%',@strData))
			END
			update A SET StandardRateBeforeTax=isnull(B.LineOrderVal,0)/isnull(B.OrderQty,0),TaxRate=isnull(B.TaxRate,0) FROM #TmpData A join tblOrderdetail B ON A.PrdID=B.productID
			where B.OrderId=@OrderId
			 
			update #TmpData SET ActualRateAfterDiscountBeforeTax=(DelQty*StandardRateBeforeTax)-DiscAmt
			update #TmpData SET TaxAmount=(ActualRateAfterDiscountBeforeTax*TaxRate)/100
			update #TmpData SET NetAmount =ActualRateAfterDiscountBeforeTax+TaxAmount
			
			
			IF EXISTS(Select * FROM [dbo].[tblOrderMaster] WHERE OrderID = @OrderID)
				BEGIN

				Declare @PDAOrderActExecDetail [PDAOrderActExecDetail] 
				print 'aaa'
				insert into @PDAOrderActExecDetail
				select PrdID, PrdRate, DelQty, FreeQty,DiscAmt from #TmpData 
				print 'aaa1'

				exec [spRecalculatePDAOrderActualExection] @OrderID,@StoreID,@PDAOrderActExecDetail,0


				Declare @DlvryRouteId int=0,@DlvryDate date=Getdate(),@FYID int

	set @DlvryRouteId =0

	select @DlvryDate=RequiredDeliveryDate from tblOrderConfirmDelivery where orderconfirmid=@orderid
	set @DlvryDate=CONVERT(DATE,@strDate,105)
				
	select @FYID=fyid from tblfinancialyear where @DlvryDate between FYStartDate and FYEndDate
		IF NOT EXISTS(SELECT * FROM [tblDlvryRouteMstr] WHERE Date=@DlvryDate and VehicleId=0 and SalesNodeId=@SalesNodeId and SalesNodeType=@SalesNodeType)
		begin
			INSERT INTO [tblDlvryRouteMstr](Date,VehicleId,RouteRef,DriverNodeId,DriverNodeType,flgStatus,TotalWeightAvailable,TotalWeightUtilized,TotalVolumeAvailable,TotalVolumeUtilized,DeliveryBoyNodeId,DeliveryBoyNodeType,
			SalesNodeId
		,SalesNodeType,
		FYID,LoginIDIns,TimestampIns,LoadingTime,
OutTime,
ReturnTime)
			VALUES (@DlvryDate, 0,null, 0, 0, 3,0,0,0,0, 0, 0, @SalesNodeId, @SalesNodeType, @FYID, @LoginId,Getdate(),Getdate(),Getdate(),Getdate());
	end

	SELECT @DlvryRouteId=DlvryRouteId FROM [tblDlvryRouteMstr] WHERE Date=@DlvryDate and VehicleId=0
	and SalesNodeId=@SalesNodeId and SalesNodeType=@SalesNodeType


Declare @DlvryStoreId int
SELECT      @DlvryStoreId=tblOrderConfirmDeliveryCustomerDetail.DeliveryLocationNodeId
FROM            tblOrderConfirmMaster INNER JOIN
                         tblOrderConfirmDeliveryCustomerDetail ON tblOrderConfirmMaster.OrderConfirmID = tblOrderConfirmDeliveryCustomerDetail.OrderConfirmID INNER JOIN
                         tblOrderConfirmDelivery ON tblOrderConfirmMaster.OrderConfirmID = tblOrderConfirmDelivery.OrderConfirmID AND tblOrderConfirmDeliveryCustomerDetail.OrderConfirmDeliveryLocationId = tblOrderConfirmDelivery.OrderConfirmDeliveryLocationId
WHERE        (tblOrderConfirmMaster.OrderConfirmID = @OrderId) 

Declare @DlvryNoteID int
set @DlvryNoteId=0
select @DlvryNoteId=DlvryNoteId from [tblDlvryPlanMaster] where [StoreId]= @DlvryStoreId and [DlvryRouteID]=@DlvryRouteId and pcklstid is null

if @DlvryNoteId=0
begin
		INSERT INTO [dbo].[tblDlvryPlanMaster]
           ([StoreId],[DlvryVisitID]
,[DlvryRouteID]
,[TotalTaxAmt]
,[TotalOrderVal]
,[ChallanCreatedOn]
,[flgChallanStatus]
,[TotalWeight]
,[flgFreightCollectable]
,[OrderBarCode]
,[OrderQRCode]
,[flgOrderReceived]
,[PaymentCollectedAmount]
,[PaymentType]
,[PreferredDeliveryTime]
,[flgOffRoute]
,[SalesNodeId]
,[SalesNodeType]
,[PckLstId]
,[FYID]
,[LoginIDIns]
,[TimestampIns])
 SELECT      distinct  tblOrderConfirmDeliveryCustomerDetail.DeliveryLocationNodeId, 0 AS Expr1, @DlvryRouteID AS Expr2, TotTaxVal, NetOrderValue, tblOrderConfirmDelivery.RequiredDeliveryDate AS Expr3, 1 AS Expr4, 0 AS Expr5, 
                         0 AS Expr6, '' AS Expr7, '' AS Expr8, 1 AS Expr9, tblOrderConfirmMaster.NetOrderValue AS Expr10, 1 AS Expr11, NULL AS Expr12, 0 AS Expr13, tblOrderConfirmMaster.SalesNodeId, tblOrderConfirmMaster.SalesNodeType, 
                         null AS Expr14, tblOrderConfirmMaster.FYID, @LoginId AS Expr15, GETDATE() AS Expr16
FROM            tblOrderConfirmMaster INNER JOIN
                         tblOrderConfirmDeliveryCustomerDetail ON tblOrderConfirmMaster.OrderConfirmID = tblOrderConfirmDeliveryCustomerDetail.OrderConfirmID INNER JOIN
                         tblOrderConfirmDelivery ON tblOrderConfirmMaster.OrderConfirmID = tblOrderConfirmDelivery.OrderConfirmID AND tblOrderConfirmDeliveryCustomerDetail.OrderConfirmDeliveryLocationId = tblOrderConfirmDelivery.OrderConfirmDeliveryLocationId
WHERE        (tblOrderConfirmMaster.OrderConfirmID = @OrderId) --AND (tblOrderConfirmDelivery.RequiredDeliveryDate <= @GenerationDate) 
AND Not Exists(select * from tblDlvryPlanDetail where tblOrderConfirmDelivery.OrderConfirmDetailDeliveryID=tblDlvryPlanDetail.OrderDetailDeliveryID)

		   declare @DlvryNoteCode varchar(50),@SeqNo int
		set @DlvryNoteID=ident_current('tblDlvryPlanMaster')
		exec spGenerateTrnSequenceNumber 'tblDlvryPlanMaster','DlvryNoteCode','D',@FYID,@SalesNodeID,@SalesNodeType,@SeqNo output,@DlvryNoteCode output
		Print 'test'
		WHILE EXISTS (SELECT DlvryNoteCode  FROM tblDlvryPlanMaster WHERE DlvryNoteCode =@DlvryNoteCode  and SalesNodeId=@SalesNodeid and SalesNodeType=@SalesNodeType)
		BEGIN
			exec spGenerateTrnSequenceNumber 'tblDlvryPlanMaster','DlvryNoteCode','D',@FYID,@SalesNodeID,@SalesNodeType,@SeqNo output,@DlvryNoteCode output
		END
		Print 'test2'
		UPDATE tblDlvryPlanMaster SET DlvryNoteCode=@DlvryNoteCode,DlvryNoteInitTag='D',DlvryNoteSeqNo=@SeqNo WHERE DlvryNoteID=@DlvryNoteID
end
		SELECT  skuid,max(prdbatchid) as prdbatchid into #prod FROm tblprdbatchmapping group by skuid

		

Delete C
FROM            tblOrderConfirmDelivery AS B INNER JOIN
                         tblOrderConfirmDetail AS A ON B.OrderConfirmDetailID = A.OrderConfirmDetailID
						 JOIN tblDlvryPlanDetail AS C ON C.OrderDetailDeliveryID=B.OrderConfirmDetailDeliveryID
WHERE        (A.OrderConfirmID = @OrderId) AND DlvryNoteID=@DlvryNoteID

	insert into tblDlvryPlanDetail( DlvryNoteID, ProductID, PrdBatchId, ProductQty, FreeQty, TotDiscAmt, ValueBeforeTax, TaxValue, NetValue, ProductPrice, UOMID, TaxRate, ChallanVal, ActualQty, ActFreeQty, ActValueBeforeTax, ActTaxValue, 
                         ActNetValue, ActDiscAmt, ReasonId, ReasonForDiff, StkRetActionId, OtherDeliveryRemarks, OrderDetailDeliveryID, LoginIDIns, TimestampIns)

SELECT       @DlvryNoteID,  A.ProductID,  C.prdbatchid, A.OrderQty+ A.FreeQty, A.FreeQty,A.TotLineDiscVal,A.LineOrderVal,A.TotTaxValue, A.NetLineOrderVal, A.ProductRate, A.SalesUnitId, A.TaxRate, A.NetLineOrderVal, 0, 0
,A.LineOrderVal,A.TotTaxValue, A.NetLineOrderVal,A.TotLineDiscVal,0,'',0,''
, B.OrderConfirmDetailDeliveryID, @LoginId AS Expr15, GETDATE() AS Expr16
FROM            tblOrderConfirmDelivery AS B INNER JOIN
                         tblOrderConfirmDetail AS A ON B.OrderConfirmDetailID = A.OrderConfirmDetailID
						 	 INNER JOIN #prod as C on C.skuid=A.ProductID
WHERE        (A.OrderConfirmID = @OrderId)

Update A set ActualQty=B.Qty+B.FreeQty,ActFreeQty=B.FreeQty,ActDiscAmt=B.DiscAmt from tblDlvryPlanDetail A join @PDAOrderActExecDetail B on A.ProductID=B.PrdId
where dlvrynoteid=@DlvryNoteID

update tblDlvryPlanDetail set ProductPriceBeforeTax=(ProductPrice/(1+TaxRate/100)),
ActRate=(ProductPrice),
ActRateBeforeTax=(ProductPrice/(1+TaxRate/100)),
ActValueBeforeTax=(ProductPrice/(1+TaxRate/100))* (ActualQty-ActFreeQty) where  dlvrynoteid=@DlvryNoteID


update tblDlvryPlanDetail set ActTaxValue=(ActValueBeforeTax*TaxRate/100) where  dlvrynoteid=@DlvryNoteID

update tblDlvryPlanDetail set ActNetValue=ActValueBeforeTax-ActDiscAmt+ActTaxValue where  dlvrynoteid=@DlvryNoteID

if isnull(@InvID,0)=0
begin
insert into tblInvMaster(InvDate, StoreID,TotOtherCharges, NetInvoiceValue, TotalTaxAmount, TotalInvoiceValue, TotalDiscountAmount, TotInvoiceValWDisc, TotLineOrderVal, TotLineLevelDisc, InvType, flgInvStatus, 
                         flgCollectCash, Remarks, DBRNodeId, DBRNodeType, LoginIDIns, TimestampIns, FYID, InvCreatedOn,PckLstId,InvActDiscAmt,OrderId,strSchemeBenefit)

SELECT   distinct   @DlvryDate,  tblOrderConfirmBillingCustomerDetail.BillingLocationNodeId,TotOtherCharges,NetOrderValue,TotTaxVal,TotLineOrderVal,TotDiscVal,TotOrderValWDisc,
TotLineOrderVal,TotLineLevelDisc,1,1,1, NULL AS Expr12, tblOrderConfirmMaster.SalesNodeId, tblOrderConfirmMaster.SalesNodeType, 
                          @LoginId AS Expr15, GETDATE() AS Expr16, @FYID,GETDATE(),null AS Expr14,ActAddDisc,tblOrderConfirmMaster.OrderConfirmId,tblOrderConfirmMaster.strSchemeBenefit
FROM            tblOrderConfirmMaster INNER JOIN
                         tblOrderConfirmBillingCustomerDetail ON tblOrderConfirmMaster.OrderConfirmID = tblOrderConfirmBillingCustomerDetail.OrderConfirmID INNER JOIN
                         tblOrderConfirmDelivery ON tblOrderConfirmMaster.OrderConfirmID = tblOrderConfirmDelivery.OrderConfirmId AND tblOrderConfirmBillingCustomerDetail.OrderConfirmBillingLocationId = tblOrderConfirmDelivery.OrderConfirmBillingLocationId
WHERE        (tblOrderConfirmMaster.OrderConfirmID = @OrderId) --AND (tblOrderConfirmDelivery.RequiredDeliveryDate <= @GenerationDate) 
AND Exists(select * from tblDlvryPlanDetail where tblOrderConfirmDelivery.OrderConfirmDetailDeliveryID=tblDlvryPlanDetail.OrderDetailDeliveryID AND tblDlvryPlanDetail.DlvryNoteID=@DlvryNoteID)

   declare @InvCode varchar(50)
   set @InvID =0
		set @InvID=ident_current('tblInvMaster')
		exec spGenerateTrnSequenceNumber 'tblInvMaster','InvCode','I',@FYID,@SalesNodeID,@SalesNodeType,@SeqNo output,@InvCode output
		Print 'test'
		WHILE EXISTS (SELECT InvCode  FROM tblInvMaster WHERE InvCode =@InvCode  and DBRNodeId=@SalesNodeid and DBRNodeType=@SalesNodeType)
		BEGIN
			exec spGenerateTrnSequenceNumber 'tblInvMaster','InvCode','I',@FYID,@SalesNodeID,@SalesNodeType,@SeqNo output,@InvCode output
		END
		Print 'test2'
		UPDATE tblInvMaster SET InvCode=@InvCode,InvInitTag='I',InvSeqNo=@SeqNo WHERE InvID=@InvID

end
Delete tblInvDetail where invid=@invid
INSERT INTO tblInvDetail( InvID, ProductID, PrdBatchID,SalesUnitId, InvQty, PriceTermId, ProductRate, LineInvVal,TotLineDiscVal, LineOrderValWDisc, TaxRefID, TaxRate, TotTaxValue, NetLineInvVal, FreeQty, LoginIDIns, TimestampIns,strSchemeSource)
	SELECT    @InvID   , c.ProductID , D.prdbatchid,c.SalesUnitId, OrderQty,0, ProductRate, LineOrderVal, TotLineDiscVal
	, LineOrderValWDisc, 0, c.TaxRate, c.TotTaxValue, c.NetLineOrderVal, c.FreeQty,@LoginId,Getdate(),''
FROM             tblOrderConfirmDetail C INNER JOIN #prod as D on D.skuid=C.ProductID
						where OrderConfirmID = @OrderId


Update A set InvQty=B.Qty,FreeQty=B.FreeQty,TotLineDiscVal=B.DiscAmt from tblInvDetail A join @PDAOrderActExecDetail B on A.ProductID=B.PrdId
where InvID=@InvID

Update A set  LineInvVal=InvQty*(ProductRate/(1+TaxRate/100)) from tblInvDetail A 
where InvID=@InvID

Update A set  LineOrderValWDisc=LineInvVal-TotLineDiscVal,TotTaxValue=((LineInvVal-TotLineDiscVal)*TaxRate)/100 from tblInvDetail A 
where InvID=@InvID


Update A set  NetLineInvVal=LineOrderValWDisc+TotTaxValue from tblInvDetail A 
where InvID=@InvID

Declare @orderval udt_OrderVal


 insert into @orderval
 select sum(LineInvVal),sum(TotLineDiscVal),sum(LineOrderValWDisc),0,sum(LineOrderValWDisc),sum(TotTaxValue),Sum(NetLineInvVal),0 from tblInvDetail

 where InvID=@InvID

 
 
 update @orderval set [ActDiscVal]=[ActDiscVal]+@AddDisc

 Update @orderval set TotTaxVal=TotTaxVal-([ActDiscVal]-([ActDiscVal]/(1+(TotTaxVal/TotOrderVal)))),
							TotDiscVal=([ActDiscVal]/(1+(TotTaxVal/TotOrderVal))) 
								
 update @orderval set [TotOrderValWDisc]=[TotOrderVal]-[TotDiscVal]
 
 update @orderval set [NetOrderValue]=[TotOrderValWDisc]+[TotTaxVal]

 
Update A SET NetInvoiceValue=B.[NetOrderValue],TotalTaxAmount=B.[TotTaxVal],
TotalInvoiceValue=B.[TotOrderVal],TotalDiscountAmount=B.[TotDiscVal], TotInvoiceValWDisc=B.[TotOrderValWDisc], 
TotLineOrderVal=B.[TotLineOrderVal], TotLineLevelDisc=B.[TotLineLevelDisc],InvActDiscAmt=B.[ActDiscVal] FROM tblInvMaster A , @orderval B
where InvID=@InvID

Delete tblInvOrderMapMstr where invid=@invid
						insert into tblInvOrderMapMstr([InvID],[DlvryNoteDetailsID],[Qty])
						select @InvID,DlvryNoteDetailsID,ActualQty from tblDlvryPlanDetail where DlvryNoteID=@DlvryNoteID
						and exists (select * from tblorderconfirmdelivery b where b. OrderConfirmDetailDeliveryID=OrderDetailDeliveryID and OrderConfirmId=@orderid)

Delete [tblInvSchemeSlabMapping] where invid=@invid
insert into [dbo].[tblInvSchemeSlabMapping]([SchemeSlabID],[InvID],[SchemeTypeID],OrdSchemeSlabMappingId)

select [SchemeSlabID],@InvID,[SchemeTypeID],OrdConfirmSchemeSlabMappingID from tblOrderConfirmSchemeSlabMapping where OrderConfirmId=@OrderId

insert into [dbo].[tblInvSchemeSlabSource]([InvSchemeSlabMappingID],[InvDetailID],[SchemeSlabBucketTypeID],[BenExceptionAssignedVal])
select DISTINCT D.[InvSchemeSlabMappingID],C.[InvDetailID],A.SchemeSlabBucketTypeID,A.BenExceptionAssignedVal from [tblOrderConfirmSchemeSlabSource] A 
	join tblOrderConfirmDetail B on A.OrderConfirmDetID=B.OrderConfirmDetailID
join tblInvDetail C ON C.ProductId=B.PRODUCTiD
JOIN [tblInvSchemeSlabMapping] D ON  C.InvId=D.InvId
AND
D.OrdSchemeSlabMappingId=A.OrdConfirmSchemeSlabMappingID
 WHERE B.OrderConfirmId=@OrderId and C.InvId=@InvId 

INSERT INTO [dbo].[tblInvSchemeSlabBenefit]([InvSchemeSlabMappingID],[InvDetailID],[FreeQty],[DiscValue],[BenTypeId])
select DISTINCT D.[InvSchemeSlabMappingID],C.[InvDetailID],C.[FreeQty],A.[DiscValue],A.[BenTypeId] from [tblOrderConfirmSchemeSlabBenefit] A join tblOrderConfirmDetail B on A.OrderConfirmDetID=B.OrderConfirmDetailID
join tblInvDetail C ON C.ProductId=B.PRODUCTiD
JOIN [tblInvSchemeSlabMapping] D ON D.OrdSchemeSlabMappingId=A.OrdConfirmSchemeSlabMappingID
AND C.InvId=D.InvId
 WHERE B.OrderConfirmId=@OrderId and C.InvId=@InvId --and C.[FreeQty]<>0

 Delete [tblInvAdvChqDetail] where InvId=@InvId
 insert into [dbo].[tblInvAdvChqDetail](InvId,AdvChqId,ChqAmt,ChqDate)
 select @InvId,AdvChqId,ChqAmt,ChqDate from [dbo].[tblOrderConfirmAdvChqDetail]
 where orderconfirmid=@OrderId

 Delete [dbo].[tblInvCollectAmtInfo] where InvId=@InvId
 insert into [dbo].[tblInvCollectAmtInfo](InvId,SettlementMode,AmtToCollect,CreditAmount,CreditDays)
 select @InvId,SettlementMode,AmtToCollect,CreditAmount,CreditDays from [dbo].[tblOrderConfirmCollectAmtInfo]
 where orderconfirmid=@OrderId

 
 
Declare @NetInvAmt amount
select @NetInvAmt=NetRoundedAmount from tblInvMaster where invid=@invid
 
 Delete tblInvPaymentStageMap where InvId=@InvId
 insert into [dbo].[tblInvPaymentStageMap](InvId,PymtStageId,Percentage,PymtStageAmt,CreditDays,CreditLimit)
 select @InvId,PymtStageId,Percentage,@NetInvAmt*(Percentage/100),CreditDays,CreditLimit from [dbo].[tblOrderConfirmPaymentStageMap]
 where orderconfirmid=@OrderId

 ;with ashcte as(
 select *,case when sum(Round(PymtStageAmt,0)) over (order by PymtStageId)<=@NetInvAmt then Round(PymtStageAmt,0) else @NetInvAmt-(sum(Round(PymtStageAmt,0)) over (order by PymtStageId)-Round(PymtStageAmt,0)) end as AdjAmt  from tblInvPaymentStageMap where InvId=@InvId)



 update ashcte set PymtStageAmt=AdjAmt

 Declare @RcvdAmt amount=0,@ActCollectAmt amount=0,@AdvAmt amount=0
 INSERT INTO tblReceiptAdjustMent
 SELECT        A.RcptId,1, @InvId, @NetInvAmt, A.AdjustedAmount
FROM            tblReceiptAdjustment AS A INNER JOIN
                         tblReceiptMaster AS B ON A.RcptId = B.RcptId
WHERE        (B.StatusId = 1) AND (A.RefType = 3) AND (A.RefId = @OrderId)

 select @RcvdAmt=isnull(sum(AdjustedAmount),0) from tblReceiptAdjustMent A  where  RefType=1 and RefId=@InvId

 select @AdvAmt=PymtStageAmt from tblInvPaymentStageMap where InvId=@InvId and pymtstageid=1
 select @ActCollectAmt=PymtStageAmt from tblInvPaymentStageMap where InvId=@InvId and pymtstageid=2

 set @ActCollectAmt=@ActCollectAmt+(@AdvAmt-@RcvdAmt)

 update [tblInvCollectAmtInfo] set AmtToCollect=@ActCollectAmt where InvId=@InvId


 Delete tblInvPaymentModeMap where InvId=@InvId
 insert into tblInvPaymentModeMap(InvPaymentStageMapId,InvId,PaymentModeId)
SELECT      distinct  c.InvPaymentStageMapId,@InvId, B.PaymentModeId
FROM            tblOrderConfirmPaymentStageMap AS A INNER JOIN
                         tblOrderConfirmPaymentModeMap AS B ON A.OrderConfirmPaymentStageMapId = B.OrderConfirmPaymentStageMapId INNER JOIN
                         tblInvPaymentStageMap AS c ON A.PymtStageId = c.PymtStageId
WHERE        (c.InvId = @InvId) AND (A.OrderConfirmId = @OrderId)


 Delete [dbo].[tblInvOtherChargesDetail] where InvId=@InvId
		insert into [tblInvOtherChargesDetail](InvId,OthChrgsReason,OthChrgsAmt)
		select @InvId,[OthChrgsReason],[OthChrgsAmt] from [tblOrderconfirmOtherChargesDetail] where orderconfirmid=@orderid


 Update tblOrderConfirmMaster set OrdPrcsId=5,OrderStatusID=2 where OrderId=@OrderId
 Update [tblOrderMaster] set OrdPrcsId=5,OrderStatusID=2 where OrderId=@OrderId

				END
	END



