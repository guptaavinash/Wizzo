

Create proc [dbo].[spDataLoadSalesData]
as
begin
if object_id('tempdb..#RestatementData') is not null
begin
	drop table #RestatementData
end

select distinct d.NodeID,d.NodeType,a.[INVOICE DATE] into #RestatementData from tmpSalesData a join tblDBRSalesStructureDBR d on a.[DB CODE]=d.DistributorCode

Delete a from tblSalesDetail a join tblSalesMaster b on a.InvId=b.InvId
join #RestatementData r on r.NodeID=b.DistNodeId
and r.NodeType=b.DistNodeType
and r.[INVOICE DATE]=b.InvDate

Delete b from  tblSalesMaster b 
join #RestatementData r on r.NodeID=b.DistNodeId
and r.NodeType=b.DistNodeType
and r.[INVOICE DATE]=b.InvDate



insert into tblSalesMaster 

select a.[INVOICE NO],a.[INVOICE DATE],s.DistNodeId,s.DistNodeType,s.StoreID,s.ChannelId,s.SubChannelId,5,sum(NETAMOUNT),sum(NETAMOUNT),0,Getdate(),null,null from tmpSalesData a join tblStoreMaster s on a.[RETAILER CODE]=s.StoreCode
group by a.[INVOICE NO],a.[INVOICE DATE],s.DistNodeId,s.DistNodeType,s.StoreID,s.ChannelId,s.SubChannelId

order by 3,2




insert into tblSalesDetail
select c.InvId,0,0,0,0,p.NodeID,p.NodeType,'',a.MRP,0,a.Qty,a.RATE,a.[GROSS AMOUNT],0,a.NETAMOUNT,0,0,0,a.NETAMOUNT,'',0,Getdate() from tmpSalesData a join tblStoreMaster s on a.[RETAILER CODE]=s.StoreCode
join tblSalesMaster c on c.InvCode=a.[INVOICE NO]
and c.DistNodeId=s.DistNodeId
and c.DistNodeType=s.DistNodeType
join tblPrdMstrHierLvl2 p on p.Code=a.[Pack Group Name]
order by 1

end
