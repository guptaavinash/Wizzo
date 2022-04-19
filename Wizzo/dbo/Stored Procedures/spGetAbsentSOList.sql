--exec spGetAbsentSOList @ASMAreaNodeId=N'2',@ASMAreaNodeType=N'110'
--select * from tblDBRSalesStructureDBR where DistributorCode='349'
--select * from tblMstrPerson where DistNodeId=824
--exec [spGetAbsentSOList] 4,110
CREATE proc [dbo].[spGetAbsentSOList]
@ASMAreaNodeId int,
@ASMAreaNodeType int
as
begin
select DISTINCT  SOAreaID as SOAreaNodeId ,SOAreaNodeType  into #SOList from VwCompanyDSRFullDetail where ASMAreaID=@ASMAreaNodeId
and ASMAreaNodeType=@ASMAreaNodeType

Declare @CurrDate date
set @CurrDate=dbo.fnGetCurrentDateTime()
Declare @VisitDate date

set @VisitDate=DATEADD(dd,1,@currdate)
IF datename(dw,@VISITDATE)='Sunday'
begin
set @VisitDate=DATEADD(dd,1,@VisitDate)
end
declare @RetailerSequence tinyint=1,@WeekNo tinyint=0,@MaxWeekNo tinyint=0
SELECT @WeekNo=(DATEPART(week, @CurrDate) - DATEPART(week, DATEADD(day, 1, EOMONTH(@CurrDate, -1)))) + 1;

SELECT @MaxWeekNo=(DATEPART(week, EOMONTH(@CurrDate)) - DATEPART(week, DATEADD(day, 1, EOMONTH(@CurrDate, -1)))) + 1;
set datefirst 7
 if @WeekNo IN(1,3,5)
 begin
 set @RetailerSequence=1
 end
 else if @WeekNo IN(2,4)
 begin
 set @RetailerSequence=2
 end


Declare @CallDays tinyint=1
set datefirst 1
select @CallDays=DATEPART(dw,@VisitDate)
set datefirst 7
PRINT '@CallDays'
PRINT @CallDays
select  0 as AttendDetId,A.SOAreaNodeId AS SONodeId,A.SOAreaNodeType as SONodeType,A.RouteNodeId,A.RouteNodeType,P.Descr AS  SOArea,r.Descr as Route,Format(@VisitDate,'dd-MMM-yyyy') as VisitDate,case @CallDays when '1' then 'Monday'
when '2' then 'Tuesday'
when '3' then 'Wednesday'
when '4' then 'Thursday'
when '5' then 'Friday'
when '6' then 'Saturday'
when '7' then 'Sunday' end as WkDay,@CallDays AS CallDays,0 as flgDownloadStatus,0 as flgAbsent,Count(*) as StoreCnt into #AbsentData from tblRouteCalendar a join #SOList b on a.SOAreaNodeId=b.SOAreaNodeId
and a.SOAreaNodeType=b.SOAreaNodeType
 join tblCompanySalesStructureSprvsnLvl1 p on p.NodeID=a.SOAreaNodeId and p.NodeType=a.SOAreaNodeType

JOIN tblCompanySalesStructureRouteMstr r on r.NodeID=a.RouteNodeId
and r.NodeType=a.RouteNodeType
where a.VisitDate=@VisitDate
group by A.SOAreaNodeId,A.SOAreaNodeType,A.RouteNodeId,A.RouteNodeType,P.Descr,r.Descr

----select * from #AbsentData
--print 'tad'
insert into #AbsentData 
select distinct 0,a.SOAreaNodeId,a.SOAreaNodeType,0,0,P.Descr,'',Format(@CurrDate,'dd-MMM-yyyy') as VisitDate,'',0,0,0,0 from 
#SOList A 
join tblCompanySalesStructureSprvsnLvl1 p on p.NodeID=a.SOAreaNodeId and p.NodeType=a.SOAreaNodeType
--AND A.DBNodeType=B.DistNodeType

 left join #AbsentData b on a.SOAreaNodeId=b.SONodeId and a.SOAreaNodeType=b.SONodeType
where b.SONodeId is null

Declare @DistNodeId int,@DistNodeType int,@AttendId int

select  @AttendId=AttenId from tblAttendanceMstr where ASMAreaNodeId=@ASMAreaNodeId and ASMAreaNodeType=@ASMAreaNodeType	
and AttenDate=convert(date,@CurrDate)

--select @AttendId

--select * from tblAttendanceDet a 
--join #AbsentData c on a.SOAreaNodeId=c.SOAreaNodeId
--and a.SOAreaNodeType=c.SOAreaNodeType
--where  a.AttendId=@AttendId

delete c from tblAttendanceDet a 
join #AbsentData c on a.SOAreaNodeId=c.SONodeId
and a.SOAreaNodeType=c.SONodeType
and a.RouteNodeId=c.RouteNodeId
and a.RouteNodetype=c.RouteNodetype
where  a.AttendId=@AttendId
and a.Absent=1
--select * from #AbsentData
set datefirst 1

insert into #AbsentData
select  a.AttendDetId,a.SOAreaNodeId,a.SOAreaNodeType,A.RouteNodeId,A.RouteNodeType, m.Descr,r.Descr as Route,Format(a.VisitDate,'dd-MMM-yyyy'),case DATEPART(dw,a.VisitDate) when '1' then 'Monday'
when '2' then 'Tuesday'
when '3' then 'Wednesday'
when '4' then 'Thursday'
when '5' then 'Friday'
when '6' then 'Saturday'
when '7' then 'Sunday' end WkDay ,DATEPART(dw,a.VisitDate),0,Absent,count(*) from tblAttendanceDet a join #SOList p on a.SOAreaNodeId=p.SOAreaNodeId
and a.SOAreaNodeType=p.SOAreaNodeType
join tblCompanySalesStructureSprvsnLvl1 m on m.NodeID=p.SOAreaNodeId
and m.NodeType=p.SOAreaNodeType
join tblCompanySalesStructureRouteMstr r on r.NodeID=a.RouteNodeId and r.NodeType=a.RouteNodetype
join tblTeleCallerListForDay c on c.AttendDetId=a.AttendDetId 
where a.AttendId=@AttendId and a.Absent=1 and c.date=	@CurrDate
group by a.AttendDetId,a.SOAreaNodeId,a.SOAreaNodeType,A.RouteNodeId,A.RouteNodeType, m.Descr,Absent,case DATEPART(dw,a.VisitDate) when '1' then 'Monday'
when '2' then 'Tuesday'
when '3' then 'Wednesday'
when '4' then 'Thursday'
when '5' then 'Friday'
when '6' then 'Saturday'
when '7' then 'Sunday' end,DATEPART(dw,a.VisitDate),Format(a.VisitDate,'dd-MMM-yyyy') ,r.Descr

set datefirst 7
update a set SOArea=SOArea+' ('+p.Descr+')' from #AbsentData a join tblsalespersonmapping b on a.SONodeId=b.NodeID
and a.SONodeType=b.NodeType
join tblMstrPerson p on p.nodeid=b.PersonNodeID
where convert(date,getdate()) between convert(date, b.fromdate) and convert(date,b.todate)
select * from #AbsentData order by 2,4


set datefirst 1
select  B.SOAreaNodeId AS  SONodeId, B.SOAreaNodeType AS SONodeType,A.RouteNodeId,A.RouteNodeType, m.Descr+isnull(' ('+p.Descr+')','') as SOArea,r.Descr as Route,Format(a.VisitDate,'dd-MMM-yyyy') as VisitDate,case DATEPART(dw,VisitDate) when '1' then 'Monday'
when '2' then 'Tuesday'
when '3' then 'Wednesday'
when '4' then 'Thursday'
when '5' then 'Friday'
when '6' then 'Saturday'
when '7' then 'Sunday' end as WkDay,DATEPART(dw,VisitDate) AS CallDays,Count(*) as StoreCnt  from tblRouteCalendar a join #SOList b on a.SOAreaNodeId=b.SOAreaNodeId
and a.SOAreaNodeType=b.SOAreaNodeType
join tblCompanySalesStructureSprvsnLvl1 m on m.NodeID=b.SOAreaNodeId
and m.NodeType=b.SOAreaNodeType
JOIN tblCompanySalesStructureRouteMstr r on r.NodeID=a.RouteNodeId
and r.NodeType=a.RouteNodeType

left join tblsalespersonmapping y 
join tblMstrPerson p on p.nodeid=y.PersonNodeID
on m.NodeID=y.NodeID
and m.NodeType=y.NodeType and
convert(date,getdate()) between convert(date, y.fromdate) and convert(date,y.todate)

where 

a.VisitDate between dateadd(dd,-14,@VisitDate) and dateadd(dd,30,@VisitDate) and a.VisitDate<>@VisitDate
group by B.SOAreaNodeId,B.SOAreaNodeType,A.RouteNodeId,A.RouteNodeType, m.Descr+isnull(' ('+p.Descr+')',''),r.Descr,DATEPART(dw,VisitDate),Format(a.VisitDate,'dd-MMM-yyyy')
set datefirst 7
end
