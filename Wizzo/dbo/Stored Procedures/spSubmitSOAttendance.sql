--DROP proc [dbo].[spSubmitManualDSEAttendance]
--go
CREATE proc [dbo].[spSubmitSOAttendance]
@ASMAreaNodeId int,
@ASMAreaNodeType int,
@Attendance [Attendance] readonly,
@LoginId int,
@SubmitDate date
--,
--@flgUpdate tinyint output---1=Updated,0=Not Updated
as
begin
--set @flgUpdate=0
Declare @CurrDate datetime=gETDATE()


select *,0 as AttendDetId  into #ManualAtt from @Attendance


Declare @AttendId int=0

select @AttendId=AttenId from tblAttendanceMstr where AttenDate=@SubmitDate and ASMAreaNodeId=@ASMAreaNodeId
and ASMAreaNodeType=@ASMAreaNodeType

if @AttendId=0
begin
insert into tblAttendanceMstr values(@SubmitDate,@ASMAreaNodeId,@ASMAreaNodeType,@LoginId,@CurrDate,null,null)
set @AttendId=SCOPE_IDENTITY()
end

Delete a from #ManualAtt a join tblAttendanceDet b on a.SONodeId=b.SOAreaNodeId
and a.SONodeType=b.SOAreaNodeType
and a.RouteNodeId=b.RouteNodeId
and a.RouteNodeType=b.RouteNodetype
and a.flgAbsent=b.Absent
and b.VisitDate=a.VisitDate 
where a.flgAbsent=1 and b.AttendId=@AttendId
--select * from #ManualAtt

select distinct b.AttendDetId into #ExtraRecord from #ManualAtt a join tblAttendanceDet b 
on a.SONodeId=b.SOAreaNodeId
and a.SONodeType=b.SOAreaNodeType
and a.RouteNodeId=b.RouteNodeId
and a.RouteNodeType=b.RouteNodetype
and b.VisitDate=a.VisitDate 
where  b.AttendId=@AttendId AND A.flgAbsent=0 AND b.Absent=1
--select * from #ManualAtt
--select * from #ExtraRecord
Delete a from tblTeleCallerListForDay a join #ExtraRecord b on a.AttendDetId=b.AttendDetId
where a.Date=@SubmitDate and IsUsed=0
--select * from #ManualAtt
--UPDATE tblManualAttendanceDet SET Absent=0,LoginIdUpd=@LoginId,TimeStampUpd=@CurrDate
--where ManAttendId=@ManAttendId and existS(SELECT * FROM #ExtraRecord e where e.ManAttendDetId=tblManualAttendanceDet.ManAttendDetId)
update b set Absent=a.flgAbsent,LoginIdUpd=@LoginId,TimeStampUpd=@CurrDate from #ManualAtt a join tblAttendanceDet b on a.SONodeId=b.SOAreaNodeId
and a.SONodeType=b.SOAreaNodeType
and a.RouteNodeId=b.RouteNodeId
and a.RouteNodeType=b.RouteNodetype
and b.VisitDate=a.VisitDate 
where b.AttendId=@AttendId
--select * from #ManualAtt
insert into tblAttendanceDet(AttendId,SOAreaNodeId,SOAreaNodeType,RouteNodeId,RouteNodetype,
Absent,VisitDate,LoginIdIns,TimeStampIns,LoginIdUpd,TimeStampUpd)
select distinct @AttendId,a.SONodeId,a.SONodeType,a.RouteNodeId,a.RouteNodeType,a.flgAbsent,a.VisitDate,@LoginId,@CurrDate,null,null from #ManualAtt a left join tblAttendanceDet b on a.SONodeId=b.SOAreaNodeId
and a.SONodeType=b.SOAreaNodeType
and a.RouteNodeId=b.RouteNodeId
and a.RouteNodeType=b.RouteNodetype
and b.VisitDate=a.VisitDate AND b.AttendId=@AttendId
where b.SOAreaNodeId is null
--select * from #ManualAtt
update A set AttendDetId=b.AttendDetId from #ManualAtt a join tblAttendanceDet b on  a.SONodeId=b.SOAreaNodeId
and a.SONodeType=b.SOAreaNodeType
and a.RouteNodeId=b.RouteNodeId
and a.RouteNodeType=b.RouteNodetype
and b.VisitDate=a.VisitDate 
where b.AttendId=@AttendId
--select * from #ManualAtt
DELETE #ManualAtt WHERE flgAbsent=0
--select * from #ManualAtt
select z.RouteNodeId,z.RouteNodeType,d.SONodeId,d.SONodeType,d.SOAreaNodeId,d.SOAreaNodeType,s.StoreCode,s.StoreId,d.DistNodeId,d.DistNodeType,d.SectorId,convert(numeric(18,2),0) as Total,convert(float,0) as #OfInv,'Todays Planned Calls' as Reason,r.Descr as  RouteName,so.Descr as SO,s.ContactNo as ContactNo,z.AttendDetId into #StoresList
 from  tblStoreMaster s 
 join tblRouteCalendar d on d.StoreId=s.StoreID
 join tblCompanySalesStructureRouteMstr r on r.NodeID=d.RouteNodeId
 left join tblMstrPerson so on so.NodeID=d.SONodeId
 join #ManualAtt z on d.SOAreaNodeId=z.SONodeId
and d.SOAreaNodeType=z.SONodeType
and d.RouteNodeId=z.RouteNodeId
and d.RouteNodeType=z.RouteNodetype
and d.VisitDate=z.VisitDate 
--where exists(select * from tmpPlannedCallsData f where f.[Shop ERP Id]=s.storecode)
--select * from #StoresList
;with ashcte as(
select *,ROW_NUMBER() over(partition by storeid order by storeid,SO,RouteName) as rown from #StoresList)
delete ashcte where rown>1

Delete a from tblTeleCallerListForDay b join #StoresList a on a.StoreId=b.StoreId
where b.Date=dateadd(dd,-1,CONVERT(date,@currdate)) and b.callmade is not null

select storeid,count(distinct InvId) as #OfInv, isnull(sum(NetValue),0) as NetValue into #NetSales from tblp3msalesdetail(nolock) 
where exists (select * from #StoresList where storeid=tblp3msalesdetail.StoreId)
group by storeid




Update a set Total=b.NetValue,#OfInv=b.#OfInv from #StoresList a  join #NetSales b on a.storeid=b.storeid

alter table #StoresList add  LastOrderDate	date,
LastOrderValue	numeric(18,2),
OrderBy	varchar(100),
LastVisit	date,
LastVisitStatus	varchar(250),
VisitedBy	varchar(100),
LastCall	date,
LastCallStatus	varchar(250),
LastCalledBY	varchar(100),
AlternateNo	varchar(100),
FiveStarNoOfGPTgt  int,
FiveStarNoOfLSSTgt int, 
FiveStarIndTgtDlvryVal  numeric(18,0)
,NoOfPendingVisits tinyint
,FiveStarTotIndTgtDlvryVal  numeric(18,0)
,FiveStarAlrdyAchIndTgtDlvryVal  numeric(18,0)
,flgFullMonthDRCP tinyint,
PassedVisits  tinyint,
NoOfVisitsInCM tinyint,
ReasonId tinyint,
SOArea varchar(100)


Update a set ReasonId=b.TeleReasonId from #StoresList a join tblTeleReasonMstr b on a.Reason=b.TeleReason


if object_id('tempdb..#vwTeleCallerListForDay') is not null
begin
drop table #vwTeleCallerListForDay
end

select a.* into #vwTeleCallerListForDay from vwTeleCallerListForDay  a join #StoresList b on a.StoreID=b.StoreId
--Declare @currDate datetime=dbo.fnGetCurrentDateTime()
if object_id('tempdb..#TeleCallData') is not null
begin
drop table #TeleCallData
end
select a.StoreId,max(a.TeleCallingId) as TeleCallingId into #TeleCallData from #vwTeleCallerListForDay a 
where flgCallStatus<>0 and Date<convert(date,@currdate)
group by a.StoreId

Update b set LastCall=a.Date,LastCallStatus=case when a.flgCallStatus=2 then 'Productive' else r.REASNCODE_LVL2NAME end ,LastCalledBY=u.TeleCallerCode,
AlternateNo=a.AlternateContactNo
 from  #vwTeleCallerListForDay a  join #StoresList b on a.StoreID=b.StoreId
join #TeleCallData c on c.TeleCallingId=a.TeleCallingId
join tblTeleCallerMstr u on u.TeleCallerId=a.TCNodeId
left join tblReasonCodeMstr r on r.ReasonCodeID=a.ReasonId

update a set SOArea=C.Descr from #StoresList a join tblSalesPersonMapping b on a.SONodeId=b.PersonNodeID
and a.SONodeType=b.PersonType
join tblCompanySalesStructureCoverage c on c.NodeID=b.NodeID
and c.NodeType=b.NodeType
where convert(date,getdate()) between convert(date,FromDate) and 
convert(date,ToDate)

insert into tblTeleCallerListForDay(AttendDetId,StoreId,Date,soNodeId,SONodeType,RouteNodeId,RouteNodeType,DistNodeId,DistNodeType,
StoreCode,StoreName,ContactPerson,ContactNo,Channel,flgCallStatus,ScheduleCall,ReasonId,Priority,TotalSales,NoOfInv,TeleReasonId,TCNodeId,TCNodeType,IsUsed,SectorId,OutStandingAmt,OutStandingDate,ChannelId,LoginIdIns,RuleId,LastOrderDate,LastOrderValue,OrderBy,LastVisit,LastVisitStatus,VisitedBy,LastCall,LastCallStatus,LastCalledBY,SubChannelId,SubChannel,AlternateContactNo,FiveStarNoOfGPTgt,FiveStarNoOfLSSTgt,FiveStarIndTgtDlvryVal,FiveStarProductivityTgt,FiveStarTotIndTgtDlvryVal,
FiveStarAlrdyAchIndTgtDlvryVal
,NoOfPendingVisits,RouteName,SOName,LanguageId,RouteGTMType,LotId,City,StateId,IsDiscountApplicable,PrcRegionId,SOAreaNodeId,SOAreaNodeType,SOArea)

select a.AttendDetId,a.StoreId,@SubmitDate,a.SONodeId,a.SONodeType,a.RouteNodeId,a.RouteNodeType,a.DistNodeId,a.DistNodeType,b.storecode,b.storename,isnull(b.contactperson,''),a.ContactNo,isnull(ch.ChannelName,''),0,null,0,row_number() over(order by case when [#OfInv]>0 then Total/[#OfInv] else 0 end desc),Total,[#OfInv],a.ReasonId,0,0,0,a.SectorId,b.OutStandingAmt,b.OutStandingDate,b.ChannelId,0,3,
a.LastOrderDate,a.LastOrderValue,a.OrderBy,a.LastVisit,a.LastVisitStatus,a.VisitedBy,a.LastCall,a.LastCallStatus,a.LastCalledBY
,b.SubChannelId,isnull(sh.SubChannel,''),a.AlternateNo,a.FiveStarNoOfGPTgt,a.FiveStarNoOfLSSTgt,
a.FiveStarIndTgtDlvryVal ,



0,
a.FiveStarTotIndTgtDlvryVal,
a.FiveStarAlrdyAchIndTgtDlvryVal
,a.NoOfPendingVisits,a.RouteName,A.SO,isnull(b.LanguageId,1),b.RouteGTMType,b.LotId,b.City,b.StateId,b.IsDiscountApplicable,b.RegionId,a.SOAreaNodeId,a.SOAreaNodeType,a.SOArea
 from 
#StoresList a join tblstoremaster b on a.storeid=b.storeid
left join tblMstrChannel ch on ch.channelid=b.channelid
left join tblMstrSubChannel sh on sh.SubChannelId=b.SubChannelId
--left join tblChannelWiseProductivityThreshold cw on cw.ChannelId=b.ChannelId and @SubmitDate between cw.FromDate and cw.ToDate
left join tblTeleCallerListForDay z on a.StoreId=z.StoreId and z.Date=@SubmitDate
where z.StoreId is null


--update a set regionSeq=c.flgSeq,regionid=b.RegionNodeId from tblTeleCallerListForDay a join vwSalesHierarchy b on a.DistNodeId=b.DbNodeId
--join tblCompanySalesStructureMgnrLvl2 c on c.NodeID=b.RegionNodeId
--where a.Date=@SubmitDate 

--exec spUpdateTeleCallingSchTime
--set @flgUpdate=1
update a set TCNodeId=b.TCNodeId,TCNodeType=b.TCNodeType from tblTeleCallerListForDay a join tblTeleCallerSalesManMapping b
on a.SOAreaNodeId=b.SoNodeId
and a.SOAreaNodeType=b.SoNodeType
where IsUsed=0 and convert(date,GETDATE()) between FromDate and ToDate
and a.Date=CONVERT(date,getdate())
EXEC [spMarkInvalidNumber]
end
