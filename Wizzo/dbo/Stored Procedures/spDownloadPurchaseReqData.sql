CREATE proc [dbo].[spDownloadPurchaseReqData]
@PurchReqId OrderReasonMap readonly,
@LoginId int
as
begin
select b.PurchReqId into #PurchReqIds from @PurchReqId a join tblPurchaseReqMaster b on a.OrderID=b.PurchReqId
where b.StatusId in(1,2)

select d.DistributorCode,d.Descr as Distributor,a.PurchReqNo,a.ReqDate,p.Category,p.SKUCode,p.SKU,b.Qty/p.PcsInBox as Qty from tblPurchaseReqMaster a join tblPurchaseReqDetail b on a.PurchReqId=b.PurchReqId
join VwSFAProductHierarchy p on p.SKUNodeID=b.PrdId
join tblDBRSalesStructureDBR d on d.NodeID=a.SalesNodeId
and d.NodeType=a.SalesNodeType
join #PurchReqIds r on r.PurchReqId=a.PurchReqId

update b set StatusId=2,TimestampUpd=GETDATE() from #PurchReqIds a join tblPurchaseReqMaster b on a.PurchReqId=b.PurchReqId
where b.StatusId=1

insert into [dbo].[tblPurchaseReqLogDetail]
select distinct b.PurchReqId,1,2,@LoginId,Getdate() from [dbo].tblPurchaseReqMaster A join #PurchReqIds B on A.PurchReqId=B.PurchReqId
end
