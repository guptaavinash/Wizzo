






--select * from tblpurchasereqdetail where purchreqid=8 and prdid= 4


--exec spGetPurchaseReqDetail @PurchReqId=5
--select * from tblPurchaseReqMaster
-- [spGetPurchaseReqDetail] 1
CREATE proc [dbo].[spGetPurchaseReqDetail] --469
@PurchReqId int
as
Begin


	SELECT     A.PurchReqId as PurchReqId, A.PurchReqNo,Replace(convert(varchar,A.ReqDate,106),' ','-') as ReqDate,Replace(convert(varchar,A.Expectedby,106),' ','-') as Expectedby,
	
		
		k.POProcessStatus  as Status,A.StatusId as StatusId, A.FYID, A.SalesNodeId, A.SalesNodeType,
	a.TotOrderValue,
a.TotDiscValue,
a.TotOrderWDisc,
a.TotTaxAmt,
a.NetAmt,a.Remarks,B.Descr as DBRName,
B.DistributorCode,A.PaymentStageId,
A.PaymentReceived,
A.PaymentDetail,
A.AttachDoc
	FROM         tblPurchaseReqMaster AS A join tblDBRSalesStructureDBR AS B on a.salesnodeid=b.nodeid and a.salesnodetype=b.nodetype
	join [tblMstrPurchaseReqProcessStatus] k on a.StatusId=k.POProcessStatusId
	WHERE     (A.PurchReqId = @PurchReqId)
	group by a.PurchReqId,a.PurchReqNo ,a.ReqDate,a.Expectedby, A.FYID, A.SalesNodeId, A.SalesNodeType,
	a.TotOrderValue,
a.TotDiscValue,
a.TotOrderWDisc,
a.TotTaxAmt,
a.NetAmt,a.Remarks,B.Descr ,
B.DistributorCode,A.StatusId,k.POProcessStatus,A.PaymentStageId,
A.PaymentReceived,
A.PaymentDetail,
A.AttachDoc

	Declare @SalesNodeId int,@SalesNodeType int,@StatusId int

select @SalesNodeId=SalesNodeId,@SalesNodeType=SalesNodeType,@StatusId=StatusId
FROM            tblPurchaseReqMaster
WHERE        (PurchReqId = @PurchReqId)

	Declare @IsSuperStockiest bit,@CaseUomId int=4

select @IsSuperStockiest=IsSuperStockiest from [dbo].[tblDBRSalesStructureDBR] WHERE NodeId=@SalesNodeId and NodeType=@SalesNodeType

DECLARE @dATE DATE=CONVERT(DATE,geTDATE())

Create table #ProductPrice(SKUNodeId int,MRP numeric(18,2),Tax numeric(18,2),RetMarginPer numeric(18,10),
StandardRate numeric(18,10),StandardRateBeforeTax numeric(18,10),DistMarginPer numeric(18,10),StandardRateForDist   numeric(18,10),StandardRateBeforeTaxForDist   numeric(18,10)
,SSMarginPer numeric(18,10)
,
StandardRateForSS   numeric(18,10),StandardRateBeforeTaxForSS   numeric(18,10),BusinessSegmentId int,PrcLocationId INT,TaxLocationId INT)


insert into #ProductPrice
exec [spGetProductWiseCurrentPriceDetail] @SalesNodeId,@SalesNodeType,@dATE


;with ashdup as (
select *,row_number() over(partition by SKUNodeId order by SKUNodeId,MRP desc)as rown from #ProductPrice )
delete ashdup where rown>1

	
	SELECT      P.SKUNodeID as SKUNodeIDPrdId, P.SKUCode as PrdCode,P.SKUShortDescr ,P.SKU,P.UOMID AS UOMID,case when @IsSuperStockiest=1 then ISNULL(T.StandardRateForSS, 0)*P.PcsInBox   else  ISNULL(T.StandardRateForDist, 0)*P.PcsInBox  end AS  StandardRate,
	case when @IsSuperStockiest=1 then  ISNULL(T.StandardRateBeforeTaxForSS, 0)*P.PcsInBox   else   ISNULL(T.StandardRateBeforeTaxForDist, 0)*P.PcsInBox end AS StandardRateBeforeTax,ISNULL(T.Tax,0) AS Tax,ISNULL(T.MRP,0)*P.PcsInBox AS MRP, A.Qty /P.PcsInBox as Qty, A.Rate*P.PcsInBox as Rate, ((A.Rate*P.PcsInBox)/(1+a.TaxPer/100))  as RateTax, A.LineOrderVal AS LineOrderVal, A.TaxAmt AS TaxAmt,A.LineOrderValWDisc AS LineOrderValWDisc, 
						  A.NetAmt AS NetAmt, A.PurchReqDetId,a.DiscAmt AS DiscAmt, FreeQty/P.PcsInBox AS FreeQty,T.RetMarginPer,case when @IsSuperStockiest=1 then ISNULL(T.StandardRateForSS, 0)*P.PcsInBox  else  ISNULL(T.StandardRateForDist, 0)*P.PcsInBox end As SystemRate,
			  B.ManufacturerID
	FROM         tblPurchaseReqDetail AS A INNER JOIN
						  [dbo].VwSFAProductHierarchy AS P ON A.PrdId = P.SKUNodeID 
							INNER JOIN tblPrdMstrSKULvl AS B on B.NodeId=P.SKUNodeID
								left JOIN #ProductPrice T on T.SKUNodeId= P.SKUNodeID 
						  where (A.PurchReqId = @PurchReqId) 
            
end                      




