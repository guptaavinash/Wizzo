
CREATE proc [dbo].[spRefreshDailyNeighbourHoodPrdData]
as
begin
Declare @FromDate date=dateadd(dd,-90,dbo.fnGetCurrentDateTime())


select NodeID,NodeType into #DBRList from tblDBRSalesStructureDBR  where IsActive=1

truncate table tblP3MBeatWiseSales
insert into tblP3MBeatWiseSales

select b.RouteNodeId,b.RouteNodeType,b.SKUNodeId,b.SKUNodeType,sum(b.quantity) as quantity,sum(b.Line_Net_Val) as Line_Net_Val from tblSalesMaster a join tblSalesDetail b on a.InvId=b.InvId 
join #DBRList c on a.DistNodeId=c.NodeID
and a.DistNodeType=c.NodeType
where a.statusid in(2,4,5)
group by b.RouteNodeId,b.RouteNodeType,b.SKUNodeId,b.SKUNodeType

end
