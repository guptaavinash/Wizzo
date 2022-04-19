--exec spDownloadOrderData @FromDate=N'09-Feb-2022',@ToDate=N'09-Feb-2022',@LoginId=N'19313'

CREATE proc [dbo].[spDownloadOrderData] 
@FromDate date,
@ToDate date,
@LoginId int
as
begin
select d.DistributorCode,a.OrderCode + '/' + d.DistributorCode as  OrderCode,a.OrderDate,pr.Code as PersonCode,pr.Descr as Person,s.StoreCode,s.StoreName,p.SKUCode as ProductCode,p.Descr AS Product ,b.OrderQty,b.ProductRate,b.FreeQty,b.TotLineDiscVal as Disc,b.NetLineOrderVal as NetLineAmount,'SFA Order' as OrderType from tblOrderMaster a join tblOrderDetail b on a.OrderID=b.OrderID
join tblStoreMaster s on s.StoreID=a.StoreID
left join tblPrdMstrSKULvl p on p.NodeID=b.ProductID
join tblDBRSalesStructureDBR d on d.NodeID=a.SalesNodeId
and d.NodeType=a.SalesNodeType
left join tblMstrPerson pr on pr.NodeID=a.SalesPersonID
where a.OrderStatusID<>3 and OrderDate between @FromDate and @ToDate
union all
select d.DistributorCode,a.OrderCode + '/' + d.DistributorCode as  OrderCode,a.OrderDate,tc.TeleCallerCode as PersonCode,tc.TeleCallerName as Person,s.StoreCode,s.StoreName,p.SKUCode as ProductCode,p.Descr AS Product ,b.OrderQty,b.ProductRate,b.FreeQty,b.TotLineDiscVal as Disc,b.NetLineOrderVal as NetLineAmount,'Tele Order' as OrderType from tblTCOrderMaster a join tblTCOrderDetail b on a.OrderID=b.OrderID
join tblStoreMaster s on s.StoreID=a.StoreID
left join tblPrdMstrSKULvl p on p.NodeID=b.PrdNodeId	
join tblDBRSalesStructureDBR d on d.NodeID=a.DistNodeId
and d.NodeType=a.DistNodeType
join tblTeleCallerListForDay t on t.TeleCallingId=a.TeleCallingId
join tblTeleCallerMstr tc on tc.TeleCallerId=t.TCNodeId
and tc.NodeType=t.TCNodeType
where a.OrderStatusID<>3 and OrderDate between @FromDate and @ToDate

order by 3,2

end