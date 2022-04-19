
CREATE proc [dbo].[spSubmitForNoOrder]
@TeleCallingId int,
@LoginId int,
@ReasonId int,
@ScheduleCall varchar(100),
@Remarks varchar(500)='',
@DSEComments varchar(500)='',
@Breakreason int=0,
@StartTime datetime,
@PhoneNo varchar(100)='',
@flgCallType tinyint,
@DialingFrequency tinyint,
@DSEIssueIds varchar(100)='',
@CloudmonitorUCID varchar(100)
as
begin
Declare @ActReasonId int=@ReasonId,@NodeId int,@NodeType int
DECLARE @RoleID INT, @flgOrderSource TINYINT,@flgCallStatus tinyint
Declare @Curr_Date datetime
set @Curr_Date=GETDATE()

select @RoleID =  u.RoleID,@NodeId=u.NodeID,@NodeType=u.NodeType
FROM tblSecUser u inner join tblSecUserLogin l on u.UserID = l.UserID
where l.LoginID = @Loginid


	
	Declare @OldReasonId int=0,@CallAttempt tinyint =0

	select @OldReasonId=ReasonId,@CallAttempt=isnull(CallAttempt,0) from tblTeleCallerListForDay where TeleCallingId=@TeleCallingId

	if @OldReasonId=8 and @CallAttempt<3
	begin
	--2,15,14,17,18
			if @ReasonId in(2,15,17)
			begin

			--set @ReasonId=@OldReasonId
			set @ScheduleCall=format(dateadd(MINUTE,10 ,@Curr_Date),'hh:mm tt')
			end
	end
	else if @CallAttempt<3
	begin
	--2,15,14,17,18
		if @ReasonId in(2,15,17)
		begin
			set @ScheduleCall=format(dateadd(MINUTE,30 ,@Curr_Date),'hh:mm tt')
		end

	end

	--8,2,15,14,17,18
		SET @flgOrderSource = 1
		set @flgCallStatus=case when (@ReasonId in(2,15,17) and isnull(@CallAttempt,0)<3) or @ReasonId=8 then 3 else 1 end
		Update tblTeleCallerListForDay  set IsUsed=case when @ReasonId =8  THEN  3
		when @ReasonId in(2,15,17)  THEN  5
		ELSE 2 END, CallMade=@Curr_Date,ReasonId=@ReasonId,
		
		ScheduleCall=case when 
		
		--(@ReasonId in(2,15,17) and isnull(CallAttempt,0)<3) or 
		
		@ReasonId=8 then @ScheduleCall else '' end ,
		 flgCallStatus=case when (@ReasonId in(2,15,17) and isnull(CallAttempt,0)<3) or @ReasonId=8 then 3 else 1 end  ,CallAttempt=case when @ReasonId=8 then 1 else isnull(CallAttempt,0)+1 end,ActCallAttempt=isnull(ActCallAttempt,0)+1,DSEIssueIds=@DSEIssueIds,
	
	Remarks=@Remarks,DSEComments=@DSEComments,FiveStarNoOfGPAct=0,FiveStarNoOfLSSAct=0,NoOfStarsAch=0,NoOfSKU=0,TotOrderVal=0,
	LoginIdUpd=@LoginId,TimeSTampUpd=@Curr_Date,CallStartDate=@StartTime,CloudmonitorUCID=@CloudmonitorUCID,flgCallConversionStatus=0 where TeleCallingId=@TeleCallingId
	Delete tblTeleCallingStarDet where TeleCallingId=@TeleCallingId
--	insert into tblTeleCallingStarDet 
--select @TeleCallingId,StarParamId,0 from tblMstrStarParameter
--	exec spUpdateTCDailyMeasureBySingle @NodeId ,@NodeType,@Curr_Date
	insert into tblTeleCallerCallDetail(TeleCallingId ,flgOrderSource ,CallType,CallDateTime,ReasonId,ScheduleCall) values (@TeleCallingId,@flgOrderSource,2,@Curr_Date,@ActReasonId,@ScheduleCall)
	
	EXEC [spPopulateTeleCallerCallLogDetail] @TeleCallingId ,1,@StartTime,@flgCallStatus,@ActReasonId,@ScheduleCall,
	@LoginId,@PhoneNo,@DSEComments,0,0,@flgCallType,@DialingFrequency

	--EXEC [spPopulateMessageDetail] @TeleCallingId

Declare @OrderId int=0
select @OrderId=OrderId from tblTCordermaster(nolock) where TeleCallingId=@TeleCallingId  AND flgOrderSource  =@flgOrderSource

insert into [tblTCOrderMaster_Cancel](OrderID, OrderCode, VisitID, OrderDate, SalesPersonID, SalesPersonType, RouteNodeId, RouteNodeType, StoreID, TotalDeliveryBy, Remarks, TotLineOrderVal, TotLineLevelDisc, TotOrderVal, TotDiscVal, TotOrderValWDisc, 
                         TotTaxVal, NetOrderValue, CustomerPONo, CustomerPODate, flgInvoiceOnDelivery, flgCollectionOnDelivery, FreightRuleID, CollectionRuleID, DlvryRuleID, InvRuleID, InsRuleID, TaxRuleID, OrderStatusID, OrderSourceID, 
                         flgOrderClosed, LoginIDIns, TimestampIns, LoginIDUpd, TimestampUpd, FYID, OrderConfirmationDate, OrderCompletionDate, strSchemeBenefit, OrderInitTag, OrderSeqNo, SalesNodeId, SalesNodeType, ActAddDisc, OrderLogId,
                          flgOffline, OrdPrcsId, flgInvoicePrinted, ReasonId, ReasonText, OrderPDAID, TotOtherCharges, TeleCallingId, DistNodeId, DistNodeType, CycleId, flgSent)
select OrderID, OrderCode, VisitID, OrderDate, SalesPersonID, SalesPersonType, RouteNodeId, RouteNodeType, StoreID, TotalDeliveryBy, Remarks, TotLineOrderVal, TotLineLevelDisc, TotOrderVal, TotDiscVal, TotOrderValWDisc, 
                         TotTaxVal, NetOrderValue, CustomerPONo, CustomerPODate, flgInvoiceOnDelivery, flgCollectionOnDelivery, FreightRuleID, CollectionRuleID, DlvryRuleID, InvRuleID, InsRuleID, TaxRuleID, OrderStatusID, OrderSourceID, 
                         flgOrderClosed, LoginIDIns, TimestampIns, LoginIDUpd, TimestampUpd, FYID, OrderConfirmationDate, OrderCompletionDate, strSchemeBenefit, OrderInitTag, OrderSeqNo, SalesNodeId, SalesNodeType, ActAddDisc, OrderLogId,
                          flgOffline, OrdPrcsId, flgInvoicePrinted, ReasonId, ReasonText, OrderPDAID, TotOtherCharges, TeleCallingId, DistNodeId, DistNodeType, CycleId, flgSent
						  from tblTCordermaster(nolock) where OrderId=@OrderId 


insert into tblTCOrderDetail_Cancel( OrderDetailID, OrderID, PrdNodeId, PrdNodeType, PrcBatchID, OrderQty, PriceTermId, ProductRate, LineOrderVal, TotLineDiscVal, LineOrderValWDisc, TaxRefID, TaxRate, TotTaxValue, NetLineOrderVal, LoginIDIns, 
                         TimestampIns, LoginIDUpd, TimestampUpd, SampleQty, SalesUnitId, FreeQty, strSchemeSource, flgRateChange, strBatchPrice, ProductRateBeforeTax, flgQuotationApplied, SalesQuoteDetId
						 ) 
SELECT        OrderDetailID, OrderID, PrdNodeId, PrdNodeType, PrcBatchID, OrderQty, PriceTermId, ProductRate, LineOrderVal, TotLineDiscVal, LineOrderValWDisc, TaxRefID, TaxRate, TotTaxValue, NetLineOrderVal, LoginIDIns, 
                         TimestampIns, LoginIDUpd, TimestampUpd, SampleQty, SalesUnitId, FreeQty, strSchemeSource, flgRateChange, strBatchPrice, ProductRateBeforeTax, flgQuotationApplied, SalesQuoteDetId
FROM            tblTCOrderDetail(nolock)  where OrderId=@OrderId 

Delete tblTCordermaster  where TeleCallingId=@TeleCallingId AND flgOrderSource  =@flgOrderSource



end
