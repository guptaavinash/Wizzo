
Create proc spPopulateRoutePlanningVisitDetail
as
begin
Declare @MinDate date=Getdate()
delete tblrouteplanningvisitdetail where VisitDate>=@MinDate

;with ashcte as(
select @MinDate as dt
union all
select DATEADD(dd,1,dt) from ashcte where DATEADD(dd,1,dt)<=DATEADD(dd,56,@MinDate))
select * into #dt from ashcte  a 

select * from #dt
set datefirst 1
insert into tblrouteplanningvisitdetail
select distinct a.RouteNodeId,a.RouteNodeType,d.dt,a.DSENodeId,a.DSENodeType,a.FileSetId,
a.CovAreaNodeId,a.CovAreaNodeType
from tblRoutePlanningMstr a 
join tblRouteWeekMstr w on a.FromDate<=w.EndDate
join #dt d on d.dt between w.StartDate and w.EndDate
and a.FromDate<=d.dt  and a.[DayOfWeek]=DATEPART(DW,d.dt) and a.WeekNo=w.WeekNo

set datefirst 7

end