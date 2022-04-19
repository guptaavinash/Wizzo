
--EXEC [spRptCallEfficiencyReport] '15-Mar-2021','18-Mar-2021','','',95
CREATE procedure [dbo].[spRptCallEfficiencyReport]
@FromDate date,
@ToDate date,
@SiteNodeIds varchar(100)='',-----'1|2|3|4|5'
@TeleReasonIds varchar(100),----'1|2|3|4|5'
@LoginId INT,
@SectorIds varchar(100)=''
AS
BEGIN

Select 'Call Efficiency' as SheetName

Declare @NodeId int,@NodeType int,@RoleId int
select @NodeId=b.UserNodeId,@NodeType=b.UserNodeType,@RoleId=b.RoleId from tblSecUserLogin a join tblSecMapUserRoles b on a.userid=b.UserID where LoginId=@LoginId 


select distinct items  as SiteNodeId into #Sites from dbo.Split(@SiteNodeIds,'|') where items<>''

select distinct items  as TeleReasonId into #TeleReason from dbo.Split(@TeleReasonIds,'|') where items<>''

select distinct items  as SectorId into #Sector from dbo.Split(@SectorIds,'|') where items not in('','0')


	if (select count(*) from #Sector)=0
	begin
		insert into #Sector
		select SectorId from tblMstrSector
	end
	
Create table #ASoList(Zone varchar(100),Region varchar(100),ASMArea varchar(100),SOArea varchar(100),SOAreaNodeId int,SOAreaNodeType int
,ASMAreaNodeId int,ASMAreaNodeType int
,ZoneNodeId int,ZoneNodeType int
,RegionNodeId int,RegionNodeType int
,SONodeId int,SONodeType int
)

Insert into #ASoList
exec [spGetSOList] @LoginId


select * into #tblTeleCallerListForDay from vwTeleCallerListForDay where Date between @FromDate and @ToDate

if object_id('tempdb..#TeleCalling') is not null
begin
	drop table #TeleCalling
end
select TeleCallingId into #TeleCalling from #tblTeleCallerListForDay



print 'ff222'
if object_id('tempdb..#CallDetails') is not null
begin
	drop table #CallDetails
end
select identity(int,1,1) as CallId,a.TeleCallingId,flgOrderSource,CallType,CallDateTime,ReasonId into #CallDetails from #TeleCalling a join tblTeleCallerCallDetail b on a.TeleCallingId=b.TeleCallingId
order by a.TeleCallingId,flgOrderSource,CallDateTime
if object_id('tempdb..#TeleCallDetail') is not null
begin
	drop table #TeleCallDetail
end
select a.TeleCallingId,b.CallId as StartCallId,0 as EndCallId,b.CallDateTime as StartTime,convert(datetime,null) as EndTime,0 as ReasonId into #TeleCallDetail from #TeleCalling a join #CallDetails b on a.TeleCallingId=b.TeleCallingId and b.CallType=1
order by 1
--select * from #TeleCallDetail



print 'ff'

Update a set EndCallId=(select isnull(Min(CallId),0) from #CallDetails b where a.TeleCallingId=b.TeleCallingId
and a.StartCallId<b.CallId
and b.CallType=2
) from #TeleCallDetail a 


update a set endcallid=0 from #TeleCallDetail a join #TeleCallDetail b on a.EndCallId=b.EndCallId
and a.StartCallId<b.StartCallId
where a.EndCallId<>0

Update a set EndTime=b.CallDateTime,ReasonId=isnull(b.ReasonId,0) from #TeleCallDetail a join #CallDetails b on a.EndCallId=b.CallId


select format(a.Date,'dd-MMM-yyyy') as [Call Date],u.TeleCallerCode as [Tele Caller],B.Zone,b.Region,b.ASMArea,b.SOArea,dr.Descr+' ['+dr.DistributorCode+']' as [Distributor],a.SOName,a.StoreCode,a.StoreName,a.Channel ,a.ContactNo,a.RouteName,u.TeleCallerName as [TC Name],format(convert(datetime,tu.StartCall,109),'HH:mm:ss') as [Tele Caller Start Time For the Day],rl.RuleCode as [Tele Reason],l.Language,'Yes' as [Planned Call],
'Yes' as [Call Made],case when flgCallStatus=3 and tcStart.reasonid=8 then 'Yes' when flgCallStatus=2 then 'Yes'
			when flgCallStatus=1 and isnull(rs.reasnfor,0)=2 then 'Yes' else 'No' end as [Calls Picked],case when
isnull(tcStart.ReasonId,0)<>0 then 'No'
when
a.flgCallStatus=2 then 'Yes'
else 'No' end  as [Productive Call],
case when
isnull(tcStart.ReasonId,0)<>0 then 0.00
when
a.flgCallStatus=2 then a.TotOrderVal
else 0.00 end

 as [Order Value],case when
isnull(tcStart.ReasonId,0)<>0 then isnull(rs.REASNCODE_LVL2NAME,'')
when
a.flgCallStatus=2 then 'Ordered'
else isnull(rs.REASNCODE_LVL2NAME,'') end as Reason,format(tcStart.StartTime,'HH:mm:ss') as [Start of call]
,format(tcStart.EndTime,'HH:mm:ss') as [Close of call],case when tcStart.EndTime is not null then DATEDIFF(ss,tcStart.StartTime,tcStart.EndTime) else 0 end  [Call Duration in Seconds],
			case when datepart(hour,tcStart.StartTime) between 9 and 10 then '9 AM-11 AM'
			when datepart(hour,tcStart.StartTime) between 11 and 12 then '11 AM-1 PM'
			when datepart(hour,tcStart.StartTime) between 13 and 14 then '1 PM-3 PM'
			when datepart(hour,tcStart.StartTime) between 15 and 16 then '3 PM-5 PM'
			when datepart(hour,tcStart.StartTime) between 17 and 18 then '5 PM-7 PM'
			ELSE ''
			END as [Call Slot]
from #tblTeleCallerListForDay a join #ASoList b on a.SONodeId=b.SONodeId

and a.SONodeType=b.SONodeType
join  tblTeleCallerMstr u on u.TeleCallerId=a.TCNodeId and u.NodeType=a.TCNodeType
join tblMstrTeleCallRule rl on rl.RuleId=a.RuleId
left join #TeleCallDetail tcStart on tcStart.TeleCallingId=a.TeleCallingId 
left join tblReasonCodeMstr rs on rs.ReasonCodeID=tcStart.ReasonId
 join tblTeleCallerDailyMstr tu on tu.TCNodeId=a.TCNodeId
and tu.TCNodeType=a.TCNodeType and tu.CallDate=a.Date
join tblLanguageMaster l on l.LngID=isnull(a.languageid,1)
join #Sector sc on sc.SectorId=a.SectorId
join tblDBRSalesStructureDBR dr on dr.NodeID=a.DistNodeId
and dr.NodeType=a.DistNodeType
union all


select format(a.Date,'dd-MMM-yyyy') as [Call Date],'' as [Tele Caller],B.Zone,b.Region,b.ASMArea,b.SOArea,dr.Descr+' ['+dr.DistributorCode+']' as [Distributor],a.SOName,a.StoreCode,a.StoreName,a.Channel ,a.ContactNo,a.RouteName,'' as [TC Name],'' as [Start Time For the Day],rl.RuleCode as [Tele Reason],l.Language,'Yes' as [Planned Call],
'No' as [Call Made],'No' as [Calls Picked], 'No'
 as [Productive Call],
0.00 as [Order Value],'No Call' as Reason,'' as [Start of call]
,'' as [Close of call], 0   [Call Duration in Seconds],
			 ''
			 as [Call Slot] from
#tblTeleCallerListForDay a join #ASoList b on a.SONodeId=b.SONodeId

and a.SONodeType=b.SONodeType
join tblMstrTeleCallRule rl on rl.RuleId=a.RuleId
join tblLanguageMaster l on l.LngID=isnull(a.languageid,1)
join #Sector sc on sc.SectorId=a.SectorId
join tblDBRSalesStructureDBR dr on dr.NodeID=a.DistNodeId
and dr.NodeType=a.DistNodeType
where a.IsUsed=0 
order by [Call Date],StoreName,[Start of call]

END
