  CREATE proc [dbo].[spDataLoadRoutePlanData]
  @VisitDate date
  as
  begin
  GOTO XX
  Declare @currdate datetime=Getdate()

  select *,0 as SONodeId,0 as SONodeType,0 AS DistNodeid,0 as DistNodeType,1 as SectorId,0 as StoreId,0 as RouteNodeId,0 as RouteNodeType,0 as CovNodeId,0 as CovNodeType into #RoutePlan from [tmpRawDataRouteAPI] 

  Update a set SONodeId=p.nodeid,SONodeType=p.nodetype from #RoutePlan a join tblMstrPerson p on a.SOERPID=p.Code


Delete a from  #RoutePlan a join tblMstrPerson p on a.SOERPID=p.Code
where p.flgSFAUser=1
  Update a set DistNodeid=p.DistNodeid,DistNodeType=p.DistNodeType,StoreId=p.Storeid from #RoutePlan a join tblstoremaster p on a.[ShopErpId]=p.storecode

  Update a set RouteNodeId=p.nodeid,RouteNodeType=p.nodetype from #RoutePlan a join tblCompanySalesStructureRouteMstr p on a.RouteErpId=p.Code

  insert into tblCompanySalesStructureRouteMstr(NodeType,Code,Descr,ShortName,RouteCode,RouteName,ISActive,CovFrqID,CoveredStoreCount,OffDay,
LoginIDIns,
TimestampIns)
  select distinct 140,RouteErpId,RouteName,RouteName,RouteErpId,RouteName,1,0,0,0,0,@currdate from #RoutePlan where RouteNodeId=0
  
  Update a set RouteNodeId=p.nodeid,RouteNodeType=p.nodetype from #RoutePlan a join tblCompanySalesStructureRouteMstr p on a.RouteErpId=p.Code
  --and a.RouteErpId=p.RouteCode
  where RouteNodeId=0


  

  Update a set CovNodeId=p.nodeid,CovNodeType=p.nodetype from #RoutePlan a join tblCompanySalesStructureCoverage p on  a.SOERPID=p.SOERPID

 -- insert into tblCompanySalesStructureCoverage
 -- select distinct RouteName,130,1,SOERPID,'',0,@currdate,null,null,0 from #RoutePlan where CovNodeId=0

 --   Update a set CovNodeId=p.nodeid,CovNodeType=p.nodetype from #RoutePlan a join tblCompanySalesStructureCoverage p on a.RouteName=p.Descr
	-- and a.SOERPID=p.SOERPID
	--where CovNodeId=0

	--insert into tblCompanySalesStructureHierarchy
	--select distinct b.NodeID,b.NodeType,c.NodeID,c.NodeType,2,c.HierID,GETDATE(),'2050-12-31',0 from tblCompanySalesStructureSprvsnLvl1 a join tblCompanySalesStructureCoverage b on a.UnqCode=b.SOERPID
	--join tblCompanySalesStructureHierarchy c on c.NodeID=a.NodeID
	--and c.NodeType=a.NodeType
	--left join tblCompanySalesStructureHierarchy d on d.NodeID=b.NodeID
	--and d.NodeType=b.NodeType
	--where d.NodeID is null

  select distinct sonodeid,sonodetype into #solist from #RoutePlan

delete b from #solist a join tblroutecalendar b on a.sonodeid=b.sonodeid
and a.sonodetype=b.sonodetype
where b.visitdate=@VisitDate
insert into tblroutecalendar
select distinct sonodeid,sonodetype,distnodeid,distnodetype,storeid,1,routenodeid,routenodetype,CovNodeId,CovNodeType,@VisitDate,0,@currdate,0 from #RoutePlan
where exists(select * from tblStoreMaster s where s.StoreID=#RoutePlan.StoreId
and s.flgActive=1)

--update tblCompanySalesStructure_DistributorMapping set ToDate=DATEADD(dd,-1,Getdate()) where CONVERT(date,getdate()) between convert(date,FromDate) and convert(date,ToDate) and CONVERT(date,TimestampIns)<>CONVERT(date,getdate()) and not exists(select * from tblSalesPersonMapping p
--join tblmstrperson pr on pr.NodeID=p.PersonNodeID
--and pr.NodeType=p.PersonType
--where p.NodeID=tblCompanySalesStructure_DistributorMapping.SHNodeID
--and p.NodeType=tblCompanySalesStructure_DistributorMapping.SHNodeType
--and isnull(pr.flgSFAUser,0)=1 and CONVERT(date,getdate()) between convert(date,p.FromDate) and convert(date,p.ToDate))

--insert into tblCompanySalesStructure_DistributorMapping
--select distinct DistNodeid,DistNodeType,CovNodeId,CovNodeType,GETDATE(),0,GETDATE(),'2050-12-31',1 from #RoutePlan a where not exists(select * from tblSalesPersonMapping p
--join tblmstrperson pr on pr.NodeID=p.PersonNodeID
--and pr.NodeType=p.PersonType
--where p.NodeID=a.CovNodeId
--and p.NodeType=a.CovNodeType
--and isnull(pr.flgSFAUser,0)=1 and CONVERT(date,getdate()) between convert(date,p.FromDate) and convert(date,p.ToDate))



--delete tblSalesPersonMapping  where NodeType in(130,140) and FromDate=CONVERT(date,GETDATE())

--update tblSalesPersonMapping set ToDate=CONVERT(date,dateadd(dd,-1,GETDATE())) where NodeType in(130,140) and GETDATE() between FromDate and ToDate

--insert into tblSalesPersonMapping 
--select distinct SONodeId,SONodeType,CovNodeId,CovNodeType,CONVERT(date,getdate()),'2050-12-31',0,GETDATE(),null,null,0 from tblRouteCalendar where VisitDate>=CONVERT(date,getdate())
--union all
--select distinct SONodeId,SONodeType,RouteNodeType,RouteNodeType,CONVERT(date,getdate()),'2050-12-31',0,GETDATE(),null,null,0 from tblRouteCalendar where VisitDate>=CONVERT(date,getdate())
--select * from tblSalesPersonMapping 
XX:
exec [sppopulaterouteCalenderforsfauser] @VisitDate
  end

