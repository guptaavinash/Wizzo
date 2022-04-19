
CREATE proc [dbo].[spGetRoutePlan]
as
select DistributorCode,d.Descr as Distributor,s.StoreCode,s.StoreName,se.SectorCode,p.Code as SOCode,p.Descr as SOName,r.Descr as Route,c.ChannelName,sc.SubChannel from tblRouteCalendar a join tblStoreMaster s on a.StoreId=s.StoreID
join tblDBRSalesStructureDBR d on d.NodeID=a.DistNodeId
join tblMstrSector se on se.SectorId=a.SectorId
left join tblMstrPerson p on p.NodeID=a.DSENodeId
join tblDBRSalesStructureRoute r on r.NodeID=a.RouteNodeId
join tblMstrChannel c on c.ChannelId=s.ChannelId
join tblMstrSUBChannel sc on sc.SubChannelId=s.SubChannelId
where a.VisitDate=convert(date,dateadd(dd,1,getdate())) and s.StateId=25
