--update tmpRoutePlanRawData set filesetid=0
--spImportRoutePlanningMstr 0,0
CREATE proc [dbo].[spImportRoutePlanningMstr]
@LoginId int,
@FileSetId int
as
begin


insert into tblCompanySalesStructureRouteMstr 
select distinct 140,a.RouteCode,a.RouteName,a.RouteName,a.RouteCode,a.RouteName,1,0,0,null,7,@LoginId,GETDATE(),null,null,
@FileSetId from tmpRoutePlanRawData a left join tblCompanySalesStructureRouteMstr b on a.RouteCode=b.Code
where b.NodeID is null and a.filesetid=@FileSetId

insert into tblMstrPerson 
select distinct a.DSECode,a.DSEName,'DSE','','',220,GETDATE(),'2050-12-31',@FileSetId,@LoginId, Getdate(),NULL,NULL,NULL,1,0,0,0,0,0,0,NULL,NULL,null,1 from tmpRoutePlanRawData a left join tblMstrPerson b
on a.dsecode=b.Code and b.NodeType=220
where b.NodeID is null and a.filesetid=@FileSetId and DSEType='SO'

insert into tblMstrPerson 
select distinct a.DSECode,a.DSEName,'ASM','','',210,GETDATE(),'2050-12-31',@FileSetId,@LoginId, Getdate(),NULL,NULL,NULL,1,0,0,0,0,0,0,NULL,NULL,null,1 from tmpRoutePlanRawData a left join tblMstrPerson b
on a.dsecode=b.Code and b.NodeType=210
where b.NodeID is null and a.filesetid=@FileSetId and DSEType='ASM'


select RouteCycId,MIN(StartDate) as CycStartDate,MAX(EndDate) as CycEndDate into #CycleMstr from tblRouteWeekMstr group by RouteCycId


update a set ApplicableStartDate=b.ApplicableStartDate from tmpRoutePlanRawData a join 
(select RouteCode,MIN(ApplicableStartDate) as ApplicableStartDate from tmpRoutePlanRawData group by RouteCode)b on a.RouteCode=b.RouteCode


--UPDATE tmpRoutePlanRawData SET ApplicableStartDate=DATEADD(DD,1,GETDATE()) WHERE ApplicableStartDate<=CONVERT(DATE,GETDATE()) and filesetid=@FileSetId

select distinct r.NodeID,r.NodeType,a.ApplicableStartDate INTO #RouteData from tmpRoutePlanRawData a 
join tblCompanySalesStructureRouteMstr r on a.RouteCode=r.Code

delete a from tblRoutePlanningMstr a join #RouteData  b on a.RouteNodeId=b.NodeID
and a.RouteNodeType=b.NodeType
where a.FromDate>CONVERT(date,getdate())


set identity_insert tblRoutePlanningMstr  on
insert into tblRoutePlanningMstr (RouteWkPlnId, RouteNodeId, RouteNodeType, WeekNo, DayOfWeek, RouteCycId, RouteWkId,dsenodeid,dsenodetype, FromDate, ToDate, LoginIdIns, TmeStampIns, FileSetId)
select a.RouteWkPlnId,a.RouteNodeId,a.RouteNodeType,a.WeekNo,a.[DayOfWeek] ,a.RouteCycId,a.RouteWkId,a.dsenodeid,a.dsenodetype,a.FromDate,'2050-12-31',a.LoginIdIns,a.TmeStampIns,a.FileSetId from [tblRoutePlanningMstr_History] a join #RouteData  b on a.RouteNodeId=b.NodeID
and a.RouteNodeType=b.NodeType
where convert(date,GETDATE()) between a.FromDate and a.ToDate
set identity_insert tblRoutePlanningMstr  off


delete a from [tblRoutePlanningMstr_History] a join #RouteData  b on a.RouteNodeId=b.NodeID
and a.RouteNodeType=b.NodeType
where convert(date,GETDATE()) between a.FromDate and a.ToDate

insert into [tblRoutePlanningMstr_History](RouteWkPlnId, RouteNodeId, RouteNodeType, WeekNo, DayOfWeek, RouteCycId, RouteWkId,dsenodeid,dsenodetype, FromDate, ToDate, LoginIdIns, TmeStampIns, FileSetId)
select a.RouteWkPlnId,a.RouteNodeId,a.RouteNodeType,a.WeekNo,a.[DayOfWeek] ,a.RouteCycId,a.RouteWkId,a.dsenodeid,a.dsenodetype,a.FromDate,dateadd(dd,-1,b.ApplicableStartDate),a.LoginIdIns,a.TmeStampIns,a.FileSetId from tblRoutePlanningMstr a join #RouteData  b on a.RouteNodeId=b.NodeID
and a.RouteNodeType=b.NodeType

delete a from tblRoutePlanningMstr a join #RouteData  b on a.RouteNodeId=b.NodeID
and a.RouteNodeType=b.NodeType

insert into tblRoutePlanningMstr
select distinct r.NodeID,r.NodeType,a.WeekNo,a.[DayOfWeek],wk.RouteCycId,wk.RouteWkId,d.NodeId,d.NodeType,isnull(cv.NodeID,0),isnull(cv.NodeType,0),a.ApplicableStartDate,'2050-12-31',@LoginId,GETDATE(),@FileSetId from tmpRoutePlanRawData a join #CycleMstr b on a.ApplicableStartDate between b.CycStartDate and b.CycEndDate
join tblRouteWeekMstr wk on wk.WeekNo=a.WeekNo and b.RouteCycId=wk.RouteCycId
join tblCompanySalesStructureRouteMstr r on a.RouteCode=r.Code
join tblMstrPerson d on a.DSECode=d.Code and d.NodeType=220
left join tblCompanySalesStructureCoverage cv on cv.SOERPID=d.Code
WHERE a.DSEType='SO'

insert into tblRoutePlanningMstr
select distinct r.NodeID,r.NodeType,a.WeekNo,a.[DayOfWeek],wk.RouteCycId,wk.RouteWkId,d.NodeId,d.NodeType,isnull(cv.NodeID,0),isnull(cv.NodeType,0),a.ApplicableStartDate,'2050-12-31',@LoginId,GETDATE(),@FileSetId from tmpRoutePlanRawData a join #CycleMstr b on a.ApplicableStartDate between b.CycStartDate and b.CycEndDate
join tblRouteWeekMstr wk on wk.WeekNo=a.WeekNo and b.RouteCycId=wk.RouteCycId
join tblCompanySalesStructureRouteMstr r on a.RouteCode=r.Code
join tblMstrPerson d on a.DSECode=d.Code and d.NodeType=210
left join tblCompanySalesStructureCoverage cv on cv.SOERPID=d.Code
WHERE a.DSEType='ASM'

delete b from #RouteData a join tblrouteplanningvisitdetail b on a.NodeID=b.routenodeid
and a.NodeType=b.RouteNodetype
and a.ApplicableStartDate<=b.VisitDate

Declare @MinDate date
select @MinDate=Min(ApplicableStartDate) from #RouteData

;with ashcte as(
select @MinDate as dt
union all
select DATEADD(dd,1,dt) from ashcte where DATEADD(dd,1,dt)<=DATEADD(dd,56,@MinDate))
select * into #dt from ashcte  a 

set datefirst 1
insert into tblrouteplanningvisitdetail
select distinct a.RouteNodeId,a.RouteNodeType,d.dt,a.DSENodeId,a.DSENodeType,@FileSetId,
a.CovAreaNodeId,a.CovAreaNodeType
from tblRoutePlanningMstr a join #RouteData b on a.RouteNodeId=b.NodeID
and a.RouteNodeType=b.NodeType
join tblRouteWeekMstr w on a.FromDate<=w.EndDate
join #dt d on d.dt between w.StartDate and w.EndDate
and a.FromDate<=d.dt  and a.[DayOfWeek]=DATEPART(DW,d.dt) and a.WeekNo=w.WeekNo

set datefirst 7


select distinct r.NodeID AS RouteNodeId,r.NodeType as RouteNodeType,hr.NodeID as CovNodeid,hr.NodeType as ConvNodeType,hr.HierID as CovHierId into #NewRoute from  tmpRoutePlanRawData a 
join tblCompanySalesStructureRouteMstr r on a.RouteCode=r.Code
join tblMstrPerson d on a.DSECode=d.Code and d.NodeType=220
join tblSalesPersonMapping sp on sp.personnodeid=d.nodeid
and sp.persontype=d.nodetype
join tblCompanySalesStructureHierarchy hr on hr.NodeID=sp.NodeID
and hr.NodeType=sp.NodeType
WHERE a.dseTYPE='SO'

and  convert(date,getdate()) between convert(date,sp.fromdate) and convert(date,sp.todate) and sp.nodetype=130
and convert(date,getdate()) between convert(date,hr.VldFrom) and convert(date,hr.VldTo) 
union all

select distinct r.NodeID AS RouteNodeId,r.NodeType as RouteNodeType,hr.NodeID as CovNodeid,hr.NodeType as ConvNodeType,hr.HierID as CovHierId  from  tmpRoutePlanRawData a 
join tblCompanySalesStructureRouteMstr r on a.RouteCode=r.Code
join tblMstrPerson d on a.DSECode=d.Code and d.NodeType=210
join tblSalesPersonMapping sp on sp.personnodeid=d.nodeid
and sp.persontype=d.nodetype
join tblCompanySalesStructureHierarchy hr on hr.NodeID=sp.NodeID
and hr.NodeType=sp.NodeType
WHERE a.dseTYPE='ASM'

and  convert(date,getdate()) between convert(date,sp.fromdate) and convert(date,sp.todate) and sp.nodetype=130
and convert(date,getdate()) between convert(date,hr.VldFrom) and convert(date,hr.VldTo) 


insert  into tblCompanySalesStructureHierarchy_Backup
SELECT        a.HierID, a.NodeID, a.NodeType, a.PNodeID, a.PNodeType, a.HierTypeID, a.PHierId, a.VldFrom, DATEADD(dd,-1,Getdate()), a.FileSetIdIns,@LoginId,GETDATE()
FROM            tblCompanySalesStructureHierarchy AS a INNER JOIN
                         [#NewRoute] AS b ON a.NodeID = b.RouteNodeId AND a.NodeType = b.RouteNodeType AND NOT (a.PNodeID = b.CovNodeid AND a.PNodeType = b.ConvNodeType)

delete a from tblCompanySalesStructureHierarchy AS a INNER JOIN
                         [#NewRoute] AS b ON a.NodeID = b.RouteNodeId AND a.NodeType = b.RouteNodeType AND NOT (a.PNodeID = b.CovNodeid AND a.PNodeType = b.ConvNodeType)

insert into tblCompanySalesStructureHierarchy
select a.RouteNodeId,a.RouteNodeType,a.CovNodeid,a.ConvNodeType,2,a.CovHierId,CONVERT(date,getdate()),'2050-12-31 00:00:00.000',0 from  [#NewRoute] a 
left join tblCompanySalesStructureHierarchy rthr on rthr.NodeID=a.RouteNodeId
and rthr.NodeType=a.RouteNodeType
where
 rthr.NodeID is null
end


