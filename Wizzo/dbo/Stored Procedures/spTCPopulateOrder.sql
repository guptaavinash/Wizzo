
CREATE proc [dbo].[spTCPopulateOrder]
@OrderId int,
@OrderDate smalldatetime,
@OrderByCustomerNodeId int,
@OrderByCustomerNodeType int,
@CustomerPONo varchar(50),
@CustomerPODate smalldatetime,
@Remarks varchar(500),
@NetOrderValue NUMERIC(18,2),
@flgInvoiceOnDelivery tinyint=1,
@flgCollectionOnDelivery tinyint=1,
@FreightRuleId tinyint=3,
@CollectionRuleId tinyint=1,
@DlvryRuleId tinyint=1,
@InvRuleId tinyint=2,
@InsRuleId tinyint=4,
@TaxRuleId tinyint=1,
@OrderStatusId tinyint=1,
@flgOrderClosed tinyint=0,
@SalesPersonId int,
@SalesPersonNodeType int,
@OrderSourceID TINYINT=2,
@Loginid int,
@strSchemeBenefit varchar(MAX),
@flgOffline tinyint=1,
@OrdPrcsId tinyint,
@ReasonId int,
@ReasonText varchar(500),
@TeleCallID INT ,
@OrderDetail OrderDetail  readonly,
@DistNodeId int,
@DistNodeType int,
@DeliveryDate date,
@OrderSchemeDet udt_OrderScheme Readonly,
@TotOrderVal NUMERIC(18,2)=0,--Line Value Before Tax
@TotMRPValue NUMERIC(18,2)=0,--Tot MRP Value
@TotLineLevelDisc NUMERIC(18,2)=0,---Line Level Disc
@TotDiscVal NUMERIC(18,2)=0,---Invoice Wise Disc
@GPValue smallint,
@FocBndAlrAch tinyint,
@FocBndNowAch tinyint,
@FocBndSBFOrd int,
@FocBndSBFQtyOrd int,
@FocBndSBFValueOrd numeric(18,2),
@SBDSBFOrd int,
@SBDTotalGap int,
@NoOfLSSAct tinyint=0,
@FiveStar tinyint=0,
@StarsDet  StarDet readonly,
@DSEComments varchar(500)='',
@Breakreason int=0,
@DSEIssueIds varchar(100)='',
@StartTime datetime,
@PhoneNo varchar(100)='',
@flgCallType tinyint,
@DialingFrequency tinyint,
@CloudmonitorUCID varchar(100)
as
BEGIN
Declare @SalesNodeId int=1,
@SalesNodeType int=150
Declare
@TotOrderValWDisc NUMERIC(18,2)=0,
@TotLineOrderVal NUMERIC(18,2)=0,
@ActAddDisc NUMERIC(18,2)=0,
@TotTaxRate NUMERIC(18,2)=0,
@TotOtherCharges NUMERIC(18,2)=0,
@RoleID INT,
@OrderSource TINYINT


Declare @OrderDetailn OrderDetail


insert into @OrderDetailn
select * from @OrderDetail

Declare @CurrDate datetime=GETDATE()
Declare @VisitId int=0,@RouteId int=0,@DbrId int=0,@DbrNodeType int=0,@OrderConfirmationDate DATE,@OrderCompletionDate DATE,@OrderLogId int,@RouteNodeType int=0,@UserCode varchar(10),@UserId int=0

declare @OrderCode varchar(50),@OrderNo int,@NodeId int,@NodeType int
SET @OrderConfirmationDate=CAST(@OrderDate AS DATE)
			SET @OrderCompletionDate=CAST(@OrderDate AS DATE)

select @RoleID =  u.RoleID,@NodeId=u.NodeID,@NodeType=u.NodeType
FROM tblSecUser u(nolock) inner join tblSecUserLogin l(nolock) on u.UserID = l.UserID
where l.LoginID = @Loginid

IF(@RoleID  = 10)
	SET @OrderSource = 2 --DSE
ELSE
	SET @OrderSource = 1 --TC

if @DbrId=0
	begin
		SET @DbrId=@SalesNodeId
		SET @DbrNodeType=@SalesNodeType
	end

 set @OrderId=0
 select @OrderId=OrderId from tblTCOrderMaster(nolock) where TeleCallingId=@TeleCallID AND flgOrderSource = @OrderSource

 --if(@OrderSource = 2)
	--select @UserCode=UserFullName,@UserId=b.UserId from tblDSECallerListForDay a(nolock) join tblSecUser b(nolock) on a.DSENodeId=b.NodeID where DSECallingId=@TeleCallID
 --ELSE
	select @UserCode=UserFullName,@UserId=b.UserID from tblSecUserLogin a(nolock) join tblsecuser b(nolock) on a.UserID=b.UserID where LoginID=@Loginid

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @FYID int
	SELECT @FYID=FYID from tblFinancialYear(nolock) where @OrderDate between FYStartDate and FYEndDate 

		
				MERGE tblTCOrderMaster WITH (HOLDLOCK) OrderMstr USING (SELECT @OrderId AS OrderId,@VisitId as VisitId,@OrderDate AS OrderDate,@OrderByCustomerNodeId AS OrderByCustomerNodeId,
				@OrderByCustomerNodeType AS OrderByCustomerNodeType,@CustomerPONo AS CustomerPONo,@CustomerPODate AS CustomerPODate,@Remarks AS Remarks,
				@TotOrderVal AS TotOrderVal,@TotDiscVal AS TotDiscVal,@TotOrderValWDisc AS TotOrderValWDisc,@TotTaxRate AS TotTaxRate,@TotLineOrderVal as TotLineOrderVal,
				@TotLineLevelDisc as TotLineLevelDisc,@OrderStatusId as OrderStatusId,@OrderConfirmationDate AS OrderConfirmationDate,
				@OrderCompletionDate AS OrderCompletionDate,@OrderSourceID AS OrderSourceID,@flgOrderClosed AS flgOrderClosed,
				@NetOrderValue AS NetOrderValue,@flgInvoiceOnDelivery AS flgInvoiceOnDelivery,@flgCollectionOnDelivery AS flgCollectionOnDelivery,@FreightRuleId AS FreightRuleId,
				@CollectionRuleId AS CollectionRuleId,@OrdPrcsId as OrdPrcsId,@DlvryRuleId AS DlvryRuleId,@flgOffline as flgOffline,@InvRuleId as InvRuleId,@InsRuleId as InsRuleId,@strSchemeBenefit AS strSchemeBenefit,@ActAddDisc as ActAddDisc,@TaxRuleId as  TaxRuleId,@DbrId as DbrId,@DbrNodeType as DbrNodeType,@SalesPersonId as SalesPersonId,@SalesPersonNodeType AS SalesPersonNodeType,@Loginid AS Loginid,@ReasonId as ReasonId,@ReasonText as ReasonText,@TotOtherCharges as TotOtherCharges,@RouteId as RouteId,@RouteNodeType as RouteNodeType,@TeleCallID as TeleCallID,@DistNodeId as DistNodeId,
				@DistNodeType as DistNodeType,@DeliveryDate as DeliveryDate,@OrderSource AS OrderSource,@TotMRPValue as TotMRPValue,@GPValue as GPValue ,
				
				@FocBndAlrAch as FocBndAlrAch,
@FocBndNowAch  as FocBndNowAch,
@FocBndSBFOrd  as FocBndSBFOrd,
@FocBndSBFQtyOrd  as FocBndSBFQtyOrd,
@FocBndSBFValueOrd  as FocBndSBFValueOrd,
@SBDSBFOrd  as SBDSBFOrd,
@SBDTotalGap  as SBDTotalGap
				
				) OrderMstrSrc
				ON OrderMstr.OrderId = OrderMstrSrc.OrderId
				WHEN MATCHED THEN
				  UPDATE
				  SET OrderMstr.OrderDate = OrderMstrSrc.OrderDate,
				  OrderMstr.VisitId = OrderMstrSrc.VisitId,
				  OrderMstr.SalesPersonId = OrderMstrSrc.SalesPersonId,
				  OrderMstr.SalesPersonType = OrderMstrSrc.SalesPersonNodeType,
				 OrderMstr.STOREID = OrderMstrSrc.OrderByCustomerNodeId,
				 OrderMstr.CustomerPONo = OrderMstrSrc.CustomerPONo,
				 OrderMstr.CustomerPODate = OrderMstrSrc.CustomerPODate,
				 OrderMstr.TotalDeliveryBy = OrderMstrSrc.DeliveryDate,
				 OrderMstr.Remarks = OrderMstrSrc.Remarks,
				 OrderMstr.TotLineOrderVal = OrderMstrSrc.TotLineOrderVal ,
				 OrderMstr.TotLineLevelDisc = OrderMstrSrc.TotLineLevelDisc,
				 OrderMstr.TotOrderVal = OrderMstrSrc.TotOrderVal,
				 OrderMstr.TotDiscVal = OrderMstrSrc.TotDiscVal,
				 OrderMstr.TotOrderValWDisc = OrderMstrSrc.TotOrderValWDisc,
				 OrderMstr.TotOtherCharges = OrderMstrSrc.TotOtherCharges,
				 OrderMstr.TotTaxVal = OrderMstrSrc.TotTaxRate,
				 OrderMstr.NetOrderValue = OrderMstrSrc.NetOrderValue,
				 OrderMstr.FYID = @FYID,
				 OrderMstr.SalesNodeId =  OrderMstrSrc.DbrId,
				 OrderMstr.SalesNodeType =  OrderMstrSrc.DbrNodeType,
				 OrderMstr.flgInvoiceOnDelivery = OrderMstrSrc.flgInvoiceOnDelivery,
				 OrderMstr.flgCollectionOnDelivery = OrderMstrSrc.flgCollectionOnDelivery,
				 OrderMstr.FreightRuleId = OrderMstrSrc.FreightRuleId,
				 OrderMstr.CollectionRuleId = OrderMstrSrc.CollectionRuleId,
				 OrderMstr.DlvryRuleId = OrderMstrSrc.DlvryRuleId,
				 OrderMstr.InvRuleId = OrderMstrSrc.InvRuleId,
				 OrderMstr.InsRuleId = OrderMstrSrc.InsRuleId,
				 OrderMstr.TaxRuleId = OrderMstrSrc.TaxRuleId,
				 OrderMstr.OrderStatusId=OrderMstrSrc.OrderStatusId,
				 OrderMstr.flgOrderClosed=OrderMstrSrc.flgOrderClosed,
				 OrderMstr.OrderConfirmationDate=OrderMstrSrc.OrderConfirmationDate,
				 OrderMstr.OrderCompletionDate=OrderMstrSrc.OrderCompletionDate,
				 OrderMstr.strSchemeBenefit=OrderMstrSrc.strSchemeBenefit,
				 OrderMstr.ActAddDisc=OrderMstrSrc.ActAddDisc,
				 OrderMstr.flgOffline=OrderMstrSrc.flgOffline,
				 OrderMstr.OrdPrcsId=OrderMstrSrc.OrdPrcsId,
				  OrderMstr.ReasonText=OrderMstrSrc.ReasonText,
				 OrderMstr.ReasonId=OrderMstrSrc.ReasonId,
				 OrderMstr.LoginIDUpd = OrderMstrSrc.LoginId,
				  OrderMstr.TimeStampUpd = @CurrDate,
				  OrderMstr.flgOrderSource = OrderMstrSrc.OrderSource,
				  OrderMstr.TotMRPValue=OrderMstrSrc.TotMRPValue,
				  OrderMstr.GPValue=OrderMstrSrc.GPValue,
				  OrderMstr.FocBndAlrAch=OrderMstrSrc.FocBndAlrAch,
				  OrderMstr.FocBndNowAch=OrderMstrSrc.FocBndNowAch,
				  OrderMstr.FocBndSBFOrd=OrderMstrSrc.FocBndSBFOrd,
				  OrderMstr.FocBndSBFQtyOrd=OrderMstrSrc.FocBndSBFQtyOrd,
				  OrderMstr.FocBndSBFValueOrd=OrderMstrSrc.FocBndSBFValueOrd,
				  OrderMstr.SBDSBFOrd=OrderMstrSrc.SBDSBFOrd,
				  OrderMstr.SBDTotalGap=OrderMstrSrc.SBDTotalGap



				WHEN NOT MATCHED BY TARGET THEN
				  INSERT ([VisitID],[OrderDate],[SalesPersonID],[SalesPersonType],[StoreID],[TotalDeliveryBy],[Remarks],[TotLineOrderVal],[TotLineLevelDisc],[TotOrderVal],[TotDiscVal],[TotOrderValWDisc],[TotTaxVal],[NetOrderValue],[CustomerPONo],[CustomerPODate],[flgInvoiceOnDelivery],[flgCollectionOnDelivery],[FreightRuleID],[CollectionRuleID],[DlvryRuleID],[InvRuleID],[InsRuleID],[TaxRuleID],[OrderStatusID],[OrderSourceID],[flgOrderClosed],[FYID],SalesNodeId,SalesNodeType,[OrderConfirmationDate],[OrderCompletionDate],[LoginIDIns],[TimestampIns],strSchemeBenefit,ActAddDisc,flgOffline,OrdPrcsId,ReasonId,ReasonText,TotOtherCharges,RouteNodeId,RouteNodeType,TeleCallingId,DistNodeId,DistNodeType,CycleId,flgOrderSource,TotMRPValue,GPValue,FocBndAlrAch,FocBndNowAch,FocBndSBFOrd,FocBndSBFQtyOrd,FocBndSBFValueOrd,SBDSBFOrd,SBDTotalGap)
				  VALUES (OrderMstrSrc.[VisitID],OrderMstrSrc.[OrderDate],OrderMstrSrc.[SalesPersonID],OrderMstrSrc.[SalesPersonNodeType],OrderMstrSrc.OrderByCustomerNodeId,OrderMstrSrc.DeliveryDate,OrderMstrSrc.[Remarks],OrderMstrSrc.[TotLineOrderVal],OrderMstrSrc.[TotLineLevelDisc],OrderMstrSrc.[TotOrderVal],OrderMstrSrc.[TotDiscVal],OrderMstrSrc.[TotOrderValWDisc],OrderMstrSrc.TotTaxRate,OrderMstrSrc.[NetOrderValue],OrderMstrSrc.[CustomerPONo],OrderMstrSrc.[CustomerPODate],OrderMstrSrc.[flgInvoiceOnDelivery],OrderMstrSrc.[flgCollectionOnDelivery],OrderMstrSrc.[FreightRuleID],OrderMstrSrc.[CollectionRuleID],OrderMstrSrc.[DlvryRuleID]
				,OrderMstrSrc.[InvRuleID],OrderMstrSrc.[InsRuleID],OrderMstrSrc.[TaxRuleID],OrderMstrSrc.[OrderStatusID],OrderMstrSrc.[OrderSourceID],OrderMstrSrc.[flgOrderClosed],@FYID,OrderMstrSrc.[DBrId],OrderMstrSrc.DbrNodeType,OrderMstrSrc.[OrderConfirmationDate],OrderMstrSrc.[OrderCompletionDate],OrderMstrSrc.LoginId,@CurrDate,OrderMstrSrc.strSchemeBenefit,OrderMstrSrc.ActAddDisc,OrderMstrSrc.flgOffline,OrderMstrSrc.OrdPrcsId,OrderMstrSrc.ReasonId,OrderMstrSrc.ReasonText,OrderMstrSrc.TotOtherCharges,OrderMstrSrc.RouteId,OrderMstrSrc.RouteNodeType,OrderMstrSrc.TeleCallID,OrderMstrSrc.DistNodeId,OrderMstrSrc.DistNodeType,0,OrderMstrSrc.OrderSource,OrderMstrSrc.TotMRPValue,OrderMstrSrc.GPValue,OrderMstrSrc.FocBndAlrAch,OrderMstrSrc.FocBndNowAch,OrderMstrSrc.FocBndSBFOrd,OrderMstrSrc.FocBndSBFQtyOrd,OrderMstrSrc.FocBndSBFValueOrd,OrderMstrSrc.SBDSBFOrd,OrderMstrSrc.SBDTotalGap);

					IF @OrderId=0
					BEGIN
						SELECT @OrderId=SCOPE_IDENTITY()
			
			
			--select @OrderNo=count(*) from tblTCOrderMaster b(nolock) join tblSecUserLogin a(nolock) on a.LoginID=b.LoginIDIns
			--where a.userid=@UserId and b.OrderDate=convert(date,@CurrDate)
			
			--SELECT @OrderCode=FORMAT(@CurrDate,'yyyyMMddhhmmss')+@UserCode+ convert(varchar,@OrderNo)
						
			--			WHILE EXISTS (SELECT OrderCode  FROM tblTCOrderMaster(nolock) WHERE OrderCode =@OrderCode)
			--			BEGIN
							
			--			SELECT @OrderCode=FORMAT(@CurrDate,'yyyyMMddhhmmss')+@UserCode+ convert(varchar,@OrderNo)
			--			END
			--			Print 'test2'
			declare @SeqNo int
			exec spGenerateTrnSequenceNumber 'tblTCOrderMaster','OrderCode','T',@FYID,@DistNodeId,@DistNodeType,@SeqNo output,@OrderCode output
					Print 'test'
					WHILE EXISTS (SELECT OrderCode  FROM tblTCOrderMaster WHERE OrderCode =@OrderCode AND DistNodeId=@DistNodeId AND DistNodeType=@DistNodeType)
					BEGIN
						exec spGenerateTrnSequenceNumber 'tblTCOrderMaster','OrderCode','T',@FYID,@DistNodeId,@DistNodeType,@SeqNo output,@OrderCode output
					END
					Print 'test2'
					UPDATE tblTCOrderMaster SET OrderCode=@OrderCode,OrderInitTag='T',OrderSeqNo=@SeqNo WHERE OrderId=@OrderId

						--UPDATE tblTCOrderMaster with (rowlock) SET OrderCode=@OrderId WHERE OrderId=@OrderId
					END
			Declare @NofSKU int
			
		
	SELECT @OrderId as OrderId
	delete tblTCOrderDetail  where orderid=@OrderId
	--/************************************/
	----Added on 31-Aug For New Scheme

	--Declare @RuleId int
	--select @RuleId=RuleId from tblTeleCallerListForDay  WHERE TelecallingID=@TeleCallID 

	--if @RuleId=3 and (select COUNT(*) from @OrderSchemeDet a join tblSchemeSlabDetails b on a.SchemeSlabID=b.SchemeSlabID
	--join tblSchemeMaster c on c.SchemeID=b.SchemeID 
	--where c.SchemeCode in('LSS2101N591','LSS2101N592')
	--)>0 AND (SELECT COUNT(*) FROM @OrderDetailn WHERE PrdNodeID=2048)=0
	--BEGIN
	--insert into @OrderDetailn  values(2048,40,1,8,.01,.01,0,.01,.01,0,0,0,1,0,0,0)
	--END
	--/************************************/
		select @NofSKU=count(*) from @OrderDetailn where OrderQty>0

		--if (@OrderSource = 2)
		--	UPDATE tblDSECallerListForDay  SET flgCallStatus=2,CallMade=@CurrDate,CallAttempt=isnull(CallAttempt,0)+1,Remarks=@Remarks,ReasonId=0,ScheduleCall='' WHERE DSECallingId=@TeleCallID
		--ELSE
		UPDATE tblTeleCallerListForDay  SET DSEComments=@DSEComments, isused=2, flgCallStatus=2,CallMade=@CurrDate,CallAttempt=isnull(CallAttempt,0)+1,ActCallAttempt=isnull(ActCallAttempt,0)+1,Remarks=@Remarks,ReasonId=0,ScheduleCall='',DSEIssueIds=@DSEIssueIds,FiveStarNoOfGPAct=@GPValue,FiveStarNoOfLSSAct=@NoOfLSSAct,NoOfStarsAch=@FiveStar,NoOfSKU=@NofSKU,TotOrderVal=@TotOrderVal,CallStartDate=@StartTime,CloudmonitorUCID=@CloudmonitorUCID,flgCallConversionStatus=1 WHERE TelecallingID=@TeleCallID
				

	;with ashorder as(
	select *,ROW_NUMBER() over(partition by prdnodeid,prdnodetype order by prdnodeid,prdnodetype,orderqty desc) as rown from @OrderDetailn )

	SELECT * INTO #OrderDetails FROM ashorder
where rown=1

insert into tblTCOrderDetail(OrderID, PrdNodeId, PrdNodeType, PrcBatchID, OrderQty, PriceTermId, ProductRate, LineOrderVal, TotLineDiscVal, LineOrderValWDisc, TaxRefID, TaxRate, TotTaxValue, NetLineOrderVal, LoginIDIns, 
                         TimestampIns, LoginIDUpd, TimestampUpd, SampleQty, SalesUnitId, FreeQty, strSchemeSource, flgRateChange, strBatchPrice, ProductRateBeforeTax, flgQuotationApplied, SalesQuoteDetId,InvLevelDisc,flgSBD
,flgFB
,flgInitiative
,SBDGroupid,flgSBDGap,FBID)
select @OrderId,PrdNodeId,PrdNodeType,0,(orderqty),0,ProductPrice,LineOrderValue, DiscValue,LineOrderValueAfterDisc, 0,0,0,NetValue, @LoginId,@CurrDate,0,null,0,SalesUnitId,FreeQty,'',0,'',ProductPrice,0,0,InvLevelDisc,flgSBD
,flgFB
,flgInitiative
,SBDGroupid,flgSBDGap,FBId from #OrderDetails
--select @OrderId,PrdNodeId,PrdNodeType,0,orderqty,0,ProductPrice,orderqty*ProductPrice,0,orderqty*ProductPrice,0,0,0,orderqty*ProductPrice,@LoginId,@CurrDate,0,null,0,SalesUnitId,0,'',0,'',ProductPrice,0,0 from @OrderDetail


update a  set NetOrderValue=(select isnull(sum(NetLineOrderVal),0) from tblTCOrderDetail(nolock) where OrderID=@OrderId)-TotDiscVal
from tblTCOrderMaster a(rowlock)
where orderid=@OrderId

			Delete tblTCOrderSchemeSlabMapping  where OrderId=@OrderId

			insert into tblTCOrderSchemeSlabMapping(SchemeSlabID,OrderID,SchemeTypeID,IsApply)
			select Distinct A.[SchemeSlabID],@OrderId,[SchemeTypeID],A.IsApply FROM @OrderSchemeDet A join [dbo].[tblSchemeSlabDetails]
			B(nolock) ON A.[SchemeSlabID]=B.[SchemeSlabID]
			JOIN [dbo].[tblSchemeMaster] C(nolock) ON B.[SchemeID]=C.[SchemeID]
			where [SchemeTypeID]<>3

			insert into tblTCOrderSchemeSlabSource(OrdSchemeSlabMappingID,OrderDetID,SchemeSlabBucketTypeID,BenExceptionAssignedVal)
			SELECT Distinct C.OrdSchemeSlabMappingID,B.OrderDetailID,[SchemeSlabSubBucketType],BenefitAssignedVal FROM
			 @OrderSchemeDet A 
			join tblTCOrderSchemeSlabMapping C(nolock) ON C.[SchemeSlabID]=A.[SchemeSlabID]
			join tblTCOrderDetail B(nolock) ON B.PrdNodeId=A.PrdID
			AND C.OrderID=B.OrderID
			WHERE C.OrderID=@OrderId and [SchemeTypeID]<>3

			insert into tblTCOrderSchemeSlabBenefit(OrdSchemeSlabMappingID,OrderDetID,FreeQty,DiscValue,BenTypeId,flgDiscOnTotAmt)
			SELECT Distinct C.OrdSchemeSlabMappingID,B.OrderDetailID,CASE WHEN [BenefitSubBucketType]  IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,CASE WHEN [BenefitSubBucketType] NOT IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,[BenefitSubBucketType],
			A.flgDiscOnTotAmt
			 FROM
			 @OrderSchemeDet A 
			join tblTCOrderSchemeSlabMapping C(nolock) ON C.[SchemeSlabID]=A.[SchemeSlabID]
			join tblTCOrderDetail B(nolock) ON B.PrdNodeId=A.[FreePrdID]
			AND C.OrderID=B.OrderID
			WHERE C.OrderID=@OrderId  and [SchemeTypeID]<>3
			--AND [BenefitSubBucketType] not IN(8,9)
			--insert into tblTCOrderSchemeSlabBenefit(OrdSchemeSlabMappingID,OrderDetID,FreeQty,DiscValue,BenTypeId,flgDiscOnTotAmt)
			--SELECT Distinct C.OrdSchemeSlabMappingID,0,CASE WHEN [BenefitSubBucketType]  IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,CASE WHEN [BenefitSubBucketType] NOT IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,[BenefitSubBucketType],
			--A.flgDiscOnTotAmt
			-- FROM
			-- @OrderSchemeDet A 
			--join tblTCOrderSchemeSlabMapping C ON C.[SchemeSlabID]=A.[SchemeSlabID]
			--WHERE C.OrderID=@OrderId AND [BenefitSubBucketType] IN(8,9) and [SchemeTypeID]<>3

			select A.*,Convert(int,0) as OrdSchemeSlabMappingID,Convert(int,0) AS Rown into #tmpOrderSchemeDet from @OrderSchemeDet A join [dbo].[tblSchemeSlabDetails]
			B(nolock) ON A.[SchemeSlabID]=B.[SchemeSlabID]
			JOIN [dbo].[tblSchemeMaster] C(nolock) ON B.[SchemeID]=C.[SchemeID]
			where [SchemeTypeID]=3

			insert into tblTCOrderSchemeSlabMapping(SchemeSlabID,OrderID,SchemeTypeID,IsApply)
			select  A.[SchemeSlabID],@OrderId,[SchemeTypeID],A.IsApply FROM #tmpOrderSchemeDet A join [dbo].[tblSchemeSlabDetails]
			B(nolock) ON A.[SchemeSlabID]=B.[SchemeSlabID]
			JOIN [dbo].[tblSchemeMaster] C(nolock) ON B.[SchemeID]=C.[SchemeID]
			where [SchemeTypeID]=3
			group by A.[SchemeSlabID],[SchemeTypeID],PrdID,A.IsApply

			Update B set Rown=A.Rown from 
			(select  SchemeSlabId,OrdSchemeSlabMappingID,PrdID,Row_Number() over(Partition by SchemeSlabId order by SchemeSlabId,PrdID) as Rown from #tmpOrderSchemeDet
			GROUP BY SchemeSlabId,OrdSchemeSlabMappingID,PrdID) AS A
			join #tmpOrderSchemeDet AS B on  A.SchemeSlabId=B.SchemeSlabId
			AND A.PrdID=B.PrdID


			Update A set OrdSchemeSlabMappingID=B.OrdSchemeSlabMappingID From 
			#tmpOrderSchemeDet AS A
			join 
			(SELECT SchemeSlabID,OrdSchemeSlabMappingID,Row_Number() over(Partition by SchemeSlabId order by SchemeSlabId,OrdSchemeSlabMappingID) as Rown2 FROM tblTCOrderSchemeSlabMapping(nolock) WHERE OrderID=@OrderId and SchemeTypeID=3) 
			as B
			on A.SchemeSlabId=B.SchemeSlabId AND A.Rown=B.Rown2


			insert into tblTCOrderSchemeSlabSource(OrdSchemeSlabMappingID,OrderDetID,SchemeSlabBucketTypeID,BenExceptionAssignedVal)
			SELECT Distinct A.OrdSchemeSlabMappingID,B.OrderDetailID,[SchemeSlabSubBucketType],BenefitAssignedVal FROM
			 #tmpOrderSchemeDet A 
			join tblTCOrderDetail B(nolock) ON B.PrdNodeId=A.PrdID
			AND B.OrderID=@OrderId

			insert into tblTCOrderSchemeSlabBenefit(OrdSchemeSlabMappingID,OrderDetID,FreeQty,DiscValue,BenTypeId,flgDiscOnTotAmt)
			SELECT Distinct A.OrdSchemeSlabMappingID,B.OrderDetailID,CASE WHEN [BenefitSubBucketType]  IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,CASE WHEN [BenefitSubBucketType] NOT IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,[BenefitSubBucketType],A.flgDiscOnTotAmt FROM
			 #tmpOrderSchemeDet A 
			join tblTCOrderDetail B(nolock) ON B.PrdNodeId=A.[FreePrdID]
			WHERE B.OrderID=@OrderId 
			--AND [BenefitSubBucketType] not IN(8,9) 

			--insert into tblTCOrderSchemeSlabBenefit(OrdSchemeSlabMappingID,OrderDetID,FreeQty,DiscValue,BenTypeId,flgDiscOnTotAmt)
			--SELECT Distinct A.OrdSchemeSlabMappingID,0,CASE WHEN [BenefitSubBucketType]  IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,CASE WHEN [BenefitSubBucketType] NOT IN(1,5) THEN [BenefitSubBucketVal] ELSE 0 END,[BenefitSubBucketType],a.flgDiscOnTotAmt FROM
			-- #tmpOrderSchemeDet A 
			--WHERE  [BenefitSubBucketType] IN(8,9) 

				Update A SET         A.BenCost= C.LineOrderVal* A.DiscValue/100
FROM            tblTCOrderSchemeSlabBenefit AS A(rowlock) INNER JOIN
                         tblTCOrderSchemeSlabMapping AS B(nolock) ON A.OrdSchemeSlabMappingID = B.OrdSchemeSlabMappingID INNER JOIN
                         tblTCOrderDetail AS C(nolock) ON A.OrderDetID = C.OrderDetailID
WHERE        (B.OrderID = @OrderId) AND (C.OrderID = @OrderId) AND (A.BenTypeId IN (2, 6,8))

Update A SET         A.BenCost= A.DiscValue
FROM            tblTCOrderSchemeSlabBenefit AS A(rowlock) INNER JOIN
                         tblTCOrderSchemeSlabMapping AS B(nolock) ON A.OrdSchemeSlabMappingID = B.OrdSchemeSlabMappingID INNER JOIN
                         tblTCOrderDetail AS C(nolock) ON A.OrderDetID = C.OrderDetailID
WHERE        (B.OrderID = @OrderId) AND (C.OrderID = @OrderId) AND (A.BenTypeId IN (3, 7,9))

Update A SET         A.BenCost= C.TotLineDiscVal
FROM            tblTCOrderSchemeSlabBenefit AS A(rowlock) INNER JOIN
                         tblTCOrderSchemeSlabMapping AS B(nolock) ON A.OrdSchemeSlabMappingID = B.OrdSchemeSlabMappingID INNER JOIN
                         tblTCOrderDetail AS C(nolock) ON A.OrderDetID = C.OrderDetailID
WHERE        (B.OrderID = @OrderId) AND (C.OrderID = @OrderId) AND (A.BenTypeId=10)


Update A SET         A.BenCost= A.FreeQty*C.ProductRateBeforeTax
FROM            tblTCOrderSchemeSlabBenefit AS A (rowlock) INNER JOIN
                         tblTCOrderSchemeSlabMapping AS B(nolock) ON A.OrdSchemeSlabMappingID = B.OrdSchemeSlabMappingID INNER JOIN
                         tblTCOrderDetail AS C(nolock) ON A.OrderDetID = C.OrderDetailID
WHERE        (B.OrderID = @OrderId) AND (C.OrderID = @OrderId) AND (A.BenTypeId IN (1, 5))

insert into tblTeleCallerCallDetail(TeleCallingId ,flgOrderSource ,CallType,CallDateTime,ReasonId) values (@TelecallId,@OrderSource,2,@CurrDate,0)


EXEC [spPopulateTeleCallerCallLogDetail] @TeleCallID ,1,@StartTime,2,0,'',
	@LoginId,@PhoneNo,@DSEComments,@TotOrderVal,@NofSKU,@flgCallType,@DialingFrequency
--Delete tblTeleCallingStarDet where TeleCallingId=@TeleCallID
--insert into tblTeleCallingStarDet 
--select @TelecallId,[ParametrId],[IsAchieved] from @StarsDet
-----Added by Ashwani on 06 Oct 2020
--Delete tblTeleCallerProductiveCallSBDGaps where TeleCallingId=@TeleCallID
--insert into tblTeleCallerProductiveCallSBDGaps(TeleCallingId,SBDGroupId,SBFNodeId,SBFNodeType)
--select @TeleCallID,SBDGroupID,SBFNodeID,SBFNodeType from tblINITSBDStoreWiseGaps where StoreID=@OrderByCustomerNodeId
-----
--exec spUpdateTCDailyMeasureBySingle @NodeId ,@NodeType,@OrderDate

--Declare @NoOfdlvryDays tinyint

--select @NoOfdlvryDays=isnull(NoOfDlvryDays,2) from tblDBRSalesStructureDBR where nodeid=@DistNodeId

--select PrdNodeId,PrdNodeType,BrndNodeID,BrndNodeType,PcsInBox into #ProductHierarchy from vwProductHierarchy
--Declare @CatRSW varchar(50)='0'
--Declare @CatTS varchar(50)='0'
--Declare @CatXACT varchar(50)='0'
--Declare @CatPOWDER varchar(50)='0'
--Declare @CatAB varchar(50)='0'
--Declare @StoreName varchar(150)
--Declare @MobNo varchar(10)

--Select  @CatRSW=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.PrdNodeID=p.PrdNodeId
--and a.PrdNodeType=p.PrdNodeType
--where p.BrndNodeID=1  
--having sum(a.OrderQty)>0

--Select  @CatTS=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.PrdNodeID=p.PrdNodeId
--and a.PrdNodeType=p.PrdNodeType
--where p.BrndNodeID=5
--having sum(a.OrderQty)>0

--Select  @CatPOWDER=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.PrdNodeID=p.PrdNodeId
--and a.PrdNodeType=p.PrdNodeType
--where p.BrndNodeID=4
--having sum(a.OrderQty)>0

--Select  @CatXACT=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.PrdNodeID=p.PrdNodeId
--and a.PrdNodeType=p.PrdNodeType
--where p.BrndNodeID=7
--having sum(a.OrderQty)>0

--Select  @CatAB=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.PrdNodeID=p.PrdNodeId
--and a.PrdNodeType=p.PrdNodeType
--where p.BrndNodeID=6
--having sum(a.OrderQty)>0

--select @MobNo=z.Items,@StoreName=a.StoreName from tblTeleCallerListForDay a 
--	cross apply dbo.Split(A.contactno,',') z
--	 where TeleCallingId=@TeleCallID and len(z.Items)=10
--	 --set @MobNo=@PhoneNo
--	--+convert(varchar,convert(float,@NetOrderValue))
--Declare @DistCode varchar(50)
--select @DistCode=DistributorCode from tblDBRSalesStructureDBR where NodeId= @DistNodeId
--and NodeType=@DistNodeType
--INSERT INTO [67SERVERSMSDB].SmsDB.dbo.tblOutGoingMsgDetails(SMSTo,Msg,DateTimeStamp,FlgStatus,IsRecdPicked,AppType,ServiceProvider,SenderId,EntityId,TemplateId)
--SELECT @MobNo,'Dear '+@StoreName + CHAR(13) + CHAR(10) + 'Odr id-'+@OrderCode+'/'+@DistCode + CHAR(13) + CHAR(10) + 'RSW-'+@CatRSW + CHAR(13) + CHAR(10) + 'TS-'+@CatTS + CHAR(13) + CHAR(10) + 'XACT-'+@CatXACT + CHAR(13) + CHAR(10) + 'POWDER-'+@CatPOWDER + CHAR(13) + CHAR(10) + 'AB-'+@CatAB + CHAR(13) + CHAR(10) + 'Will reach in 2 days' + CHAR(13) + CHAR(10) + 'Any query call@9302700090' + CHAR(13) + CHAR(10) + 'Thanks-Raj Soap' AS MSg,GETDATE(),0,0,120,'RajTraders','RAJSOP','1201161492702308055','1207164302496529719'

--SELECT @MobNo,'Dear '+@StoreName + CHAR(13) + CHAR(10) + 'Odr id-'+@OrderCode + CHAR(13) + CHAR(10) + 'Odr Amt-XXX' + CHAR(13) + CHAR(10) + 'RSW-'+@CatRSW + CHAR(13) + CHAR(10) + 'TS-'+@CatTS + CHAR(13) + CHAR(10) + 'XACT-'+@CatXACT + CHAR(13) + CHAR(10) + 'POWDER-'+@CatPOWDER + CHAR(13) + CHAR(10) + 'AB-'+@CatAB + CHAR(13) + CHAR(10) + 'Will reach in 2 days' + CHAR(13) + CHAR(10) + 'Any query call@9302700090' + CHAR(13) + CHAR(10) + 'Thanks-Raj Soap' AS MSg,GETDATE(),0,0,120,'RajTraders','RAJSOP','1201161492702308055','1207164146511847437'




/*
Declare @OrderString varchar(100)=''
Select  @OrderString=BrandCode+'-'+case when sum(a.OrderQty/p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join vwProductHierarchy p on a.PrdNodeID=p.PrdNodeId
and a.PrdNodeType=p.PrdNodeType
GROUP BY BrandCode


INSERT INTO tblOutGoingMsgDetails(NodeId,NodeType,Msg,SMSTo,SenderId,AppType,ServiceProvider,TeleUserId,RuleId,SMSTypeId)
	select @OrderID NodeId,0 AS NodeType,'Dear ' + a.StoreName + Char(13)+' Odr id-'+convert(varchar,@orderid)+Char(13)+' Odr Amt-' + CONVERT(VARCHAR,@NetOrderValue) + CHAR(13)+@OrderString+' Will reach in 2days'+Char(13)+' Any query call @'+char(13)+'Thanks-Raj Sop' as MsgTxt,z.Items,'' SenderId,108,'24X7SMS',TCNodeId,RuleId,1 from tblTeleCallerListForDay a join tblDBRSalesStructureDBR d on d.NodeID=a.DistNodeId
	and d.NodeType=a.DistNodeType 
	cross apply dbo.Split(A.contactno,',') z
	 where TeleCallingId=@TeleCallID and z.Items<>''
*/
--EXEC [spPopulateMessageDetail] @TeleCallID
END
