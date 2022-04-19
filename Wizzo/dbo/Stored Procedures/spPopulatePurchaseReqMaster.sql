



CREATE proc [dbo].[spPopulatePurchaseReqMaster]
@PurchReqId int,
@ReqDate date,
@Expectedby date,
@FYID INT,
@SalesNodeId int,
@SalesNodeType int,
@OrderDetail PurchReqDetail  readonly,
@Loginid int,
@TotPurchValue Amount,
@TotDiscValue Amount,
@TotPurchWDisc Amount,
@TotTaxAmt Amount,
@NetAmt Amount,
@Remarks varchar(500),
@StatusId int,
@PaymentReceived numeric(18,2),
@PymtStageId tinyint,
@AttachDoc varchar(500)
as
begin

--if (select count(*) from tblPurchaseReqDetail where PurchReqId=@PurchReqId and StatusId<>0)>0
--begin

--return;
--end
	Declare @PurchDate date=Getdate(),@CurrDate date=Getdate()


select @fyid=fyid from tblFinancialYear where @ReqDate between FYStartDate and FyEndDate

MERGE tblPurchaseReqMaster WITH (HOLDLOCK) PurchaseReq USING (select @PurchReqId PurchReqId,@ReqDate as ReqDate,@Expectedby as Expectedby,@FYID as FYID,@SalesNodeId as SalesNodeId, @SalesNodeType as SalesNodeType,@TotPurchValue as TotPurchValue,@TotDiscValue as TotDiscValue,@TotPurchWDisc as TotPurchWDisc,@TotTaxAmt as TotTaxAmt,
@NetAmt as NetAmt,@Remarks as Remarks,@StatusId as StatusId
 ) as PurchaseReqSrc
  
ON PurchaseReq.PurchReqId = PurchaseReqSrc.PurchReqId  
WHEN MATCHED THEN  
  UPDATE  
  SET PurchaseReq.ReqDate = PurchaseReqSrc.ReqDate  ,
 PurchaseReq.Expectedby = PurchaseReqSrc.Expectedby  ,
 PurchaseReq.TotOrderValue = PurchaseReqSrc.TotPurchValue  ,
 PurchaseReq.TotDiscValue = PurchaseReqSrc.TotDiscValue  ,
 PurchaseReq.TotOrderWDisc = PurchaseReqSrc.TotPurchWDisc  ,
 PurchaseReq.TotTaxAmt = PurchaseReqSrc.TotTaxAmt  ,
  PurchaseReq.Remarks = PurchaseReqSrc.Remarks  ,
  PurchaseReq.NetAmt = PurchaseReqSrc.NetAmt  ,
 PurchaseReq.LoginIDUpd = @LoginId,  
 PurchaseReq.TimeStampUpd = GETDATE()  ,
 PurchaseReq.statusid=PurchaseReqSrc.StatusId
WHEN NOT MATCHED BY TARGET THEN  
  INSERT (ReqDate,Expectedby,FYID,SalesNodeId, SalesNodeType,LoginIDIns, TimeStampIns,TotOrderValue,TotDiscValue,TotOrderWDisc,TotTaxAmt,NetAmt,Remarks,statusid)  
  VALUES (PurchaseReqSrc.ReqDate,PurchaseReqSrc.Expectedby,PurchaseReqSrc.FYID,
  PurchaseReqSrc.SalesNodeId,PurchaseReqSrc.SalesNodeType,
  @LoginId,Getdate(),PurchaseReqSrc.TotPurchValue,PurchaseReqSrc.TotDiscValue,PurchaseReqSrc.TotPurchWDisc,PurchaseReqSrc.TotTaxAmt,PurchaseReqSrc.NetAmt,PurchaseReqSrc.Remarks,PurchaseReqSrc.StatusId);  
  declare @PurchReqCode varchar(50),@SeqNo int
  IF @PurchReqId=0
					BEGIN
						SELECT @PurchReqId=scope_identity()
		
						exec spGenerateTrnSequenceNumber 'tblPurchaseReqMaster','PurchReqNo','PR',@FYID,@SalesNodeId,@SalesNodeType,@SeqNo output,@PurchReqCode output
						Print 'test'
						WHILE EXISTS (SELECT PurchReqNo  FROM tblPurchaseReqMaster WHERE PurchReqNo =@PurchReqCode and SalesNodeId=@SalesNodeId and SalesNodeType=@SalesNodeType)
						BEGIN
							exec spGenerateTrnSequenceNumber 'tblPurchaseReqMaster','PurchReqNo','PR',@FYID,@SalesNodeId,@SalesNodeType,@SeqNo output,@PurchReqCode output
						END
						Print 'test2'
						UPDATE tblPurchaseReqMaster with (ROWLOCK) SET PurchReqNo=@PurchReqCode,PurchReqInitTag='PR',PurchReqSeqNo=@SeqNo WHERE PurchReqId=@PurchReqId
					END
					ELSE
					BEGIN
						SELECT @PurchReqCode = PurchReqNo FROM tblPurchaseReqMaster WHERE PurchReqId=@PurchReqId
					END


	Delete [dbo].[tblPurchaseReqDetail] WHERE PurchReqId= @PurchReqId



	Delete [dbo].[tblPurchaseReqDetail] WHERE PurchReqId= @PurchReqId and PrdId not in(select PrdId from @OrderDetail)

	Update A with (ROWLOCK) set Qty=[OrderQty]*p.PcsInBox,FreeQty=b.[FreeQty]*p.PcsInBox,Rate=b.[ProductPrice]/p.PcsInBox
	,LineOrderVal=b.[OrderVal]
	,DiscAmt=b.[TotLineDiscVal]
	,LineOrderValWDisc=b.LineOrderValWDisc
	,TaxPer=b.[TotTaxRate]
	,TaxAmt=b.[TotTaxValue]
	,NetAmt=b.[NetLineOrderVal]
	
	 from [tblPurchaseReqDetail] A join @OrderDetail B ON A.PrdId=b.PrdId
	 join tblPrdMstrSkuLvl as p on b.[PrdID]=p.NodeId
	  where PurchReqId= @PurchReqId
	  

	Insert into [tblPurchaseReqDetail] with (ROWLOCK)(PurchReqId,PrdId,UOMID,Qty,FreeQty,Rate,LineOrderVal,DiscPer,DiscAmt,LineOrderValWDisc,TaxPer,TaxAmt,NetAmt,PlantDepotId,StatusId,POCategoryId) 
	select @PurchReqId,[PrdID],8,[OrderQty]*b.PcsInBox,[FreeQty]*b.PcsInBox,[ProductPrice]/b.PcsInBox,[OrderVal],0,[TotLineDiscVal],[LineOrderValWDisc],[TotTaxRate],[TotTaxValue],[NetLineOrderVal],0,0,0 from @OrderDetail A join tblPrdMstrSkuLvl as B on A.[PrdID]=B.NodeId
	where PrdId not in(select PrdId from [dbo].[tblPurchaseReqDetail] WHERE PurchReqId= @PurchReqId)


	
--	insert into [dbo].[tblPurchaseReqLogDetail] with (ROWLOCK)
--	select distinct @PurchReqId,POCategoryId,0,@LoginId,Getdate() from [tblPurchaseReqDetail](nolock) where PurchReqId=@PurchReqId


--	select PurchReqDetId,PurchReqId,PrdId,Rate as OldRate,TaxPer as OldTaxPer,Convert(numeric(18,10),0) as NewRate,Convert(numeric(18,10),0) as NewRateBefore,
--	Convert(numeric(18,2),0) as NewTaxPer
--	 into #tmpReqProductLevelData from [tblPurchaseReqDetail](nolock) where PurchReqId= @PurchReqId

	
--Create table #ProductPrice(SKUNodeId int,MRP numeric(18,2),Tax numeric(18,2),RetMarginPer numeric(18,10),
--StandardRate numeric(18,10),StandardRateBeforeTax numeric(18,10),DistMarginPer numeric(18,10),StandardRateForDist   numeric(18,10),StandardRateBeforeTaxForDist   numeric(18,10)
--,SSMarginPer numeric(18,10)
--,
--StandardRateForSS   numeric(18,10),StandardRateBeforeTaxForSS   numeric(18,10),BusinessSegmentId int,PrcLocationId INT,TaxLocationId INT)


--insert into #ProductPrice
--exec [spGetProductWiseCurrentPriceDetail] @SalesNodeId,@SalesNodeType,@ReqDate

--Update A set NewRate=b.StandardRateForDist,NewTaxPer=b.Tax,NewRateBefore=b.StandardRateBeforeTaxForDist from #tmpReqProductLevelData A join #ProductPrice B on A.PrdId=B.SKUNodeId
	
--	insert into [tblPurchaseReqPriceCheckDetail](PurchReqId,PurchReqDetId,OldRate,OldTaxRate,NewRate,NewTaxRate,NewRateBeforeTax,LoginID,TimestampUpd)
--	select @PurchReqId,PurchReqDetId,OldRate,OldTaxPer,NewRate,NewTaxPer,NewRateBefore,@LoginId,Getdate() from #tmpReqProductLevelData where Round(OldRate,2)<>Round(NewRate,2)
--	or Round(OldTaxPer,2)<>Round(NewTaxPer,2)

--	update A with (ROWLOCK) set Rate=B.[NewRate],LineOrderVal=A.Qty*B.NewRateBeforeTax,LineOrderValWDisc=A.Qty*B.NewRateBeforeTax,
--	TaxPer=B.NewTaxRate,TaxAmt=((A.Qty*B.NewRateBeforeTax)*B.NewTaxRate)/100,NetAmt=A.Qty*b.NewRate
--	 from  [tblPurchaseReqDetail] A join [tblPurchaseReqPriceCheckDetail] b on a.PurchReqDetId=b.PurchReqDetId
--	where A.PurchReqId=@PurchReqId and isnull(b.flgUpdate,0)=0

--	update [tblPurchaseReqPriceCheckDetail] set flgUpdate=1 where PurchReqId=@PurchReqId and isnull(flgUpdate,0)=0
--	--Insert into [tblPurchaseReqDetail](PurchReqId,PrdId,UOMID,Qty,FreeQty,Rate,LineOrderVal,DiscPer,DiscAmt,LineOrderValWDisc,TaxPer,TaxAmt,NetAmt,PlantDepotId) 
--	--select @PurchReqId,[PrdID],8,[OrderQty]*b.PcsInBox,[FreeQty]*b.PcsInBox,[ProductPrice]/b.PcsInBox,[OrderVal],0,[TotLineDiscVal],[LineOrderValWDisc],[TotTaxRate],[TotTaxValue],[NetLineOrderVal],@PlantDepotId from @OrderDetail AS A join tblPrdMstrSkuLvl as B on A.[PrdID]=B.NodeId
if @StatusId in(0,1)
begin
Update tblPurchaseReqMaster set PaymentReceived= @PaymentReceived,PaymentStageId=@PymtStageId,
AttachDoc=@AttachDoc where PurchReqId=@PurchReqId
end
	SELECT convert(varchar,@PurchReqId)+'_'+convert(varchar,@PurchReqCode) AS PurchReqNo
End




