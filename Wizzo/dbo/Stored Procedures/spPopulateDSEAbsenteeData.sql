
--[spPopulateDSEAbsenteeData] 0
CREATE proc [dbo].[spPopulateDSEAbsenteeData] 
@FileSetId bigint
as
begin
return;
update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@FileSetId
--if object_id('tempdb..#tempDSEData') is not null
--begin
--	drop table #tempDSEData
--end

--select P.NodeID as DSENodeId,P.NodeType as DSENodeType,d.NodeID as DistNodeId,d.NodeType as DistNodeType,r.NodeID as RouteNodeId,r.NodeType as RouteNodeType into #tempDSEData from mrco_DSRAbsentee_Data a join tblDBRSalesStructureDBR d on a.DistributorCode=d.DistributorCode
--join tblMstrPerson p on p.Descr=a.UserName
--and p.DistNodeId=d.NodeID
--and p.DistNodeType=d.NodeType
--join tblDBRSalesStructureRoute r on r.Descr=a.BeatName
--and p.DistNodeId=d.NodeID
--and p.DistNodeType=d.NodeType
--where DownloadFlag='N'

Declare @currdate datetime=dbo.fnGetCurrentDateTime()

insert into mrco_DSRAbsentee_Data_Error
select a.DivisionHeadCode,a.RSHCode,a.ASMCode,a.TSOTSECode,a.DistributorCode,a.USERID,a.UserName,a.DistUserUniqueID,a.BeatID,a.BeatName,a.DownloadFlag,a.SchedulerCycleDateTime,a.CycFileID,19,@currdate from mrco_DSRAbsentee_Data a left join tblDBRSalesStructureDBR d on a.DistributorCode=d.DistributorCode
where d.NodeID is null  and a.CycFileID=@FileSetId

delete a from mrco_DSRAbsentee_Data a left join tblDBRSalesStructureDBR d on a.DistributorCode=d.DistributorCode
where d.NodeID is null and a.CycFileID=@FileSetId

insert into mrco_DSRAbsentee_Data_Error
select a.DivisionHeadCode,a.RSHCode,a.ASMCode,a.TSOTSECode,a.DistributorCode,a.USERID,a.UserName,a.DistUserUniqueID,a.BeatID,a.BeatName,a.DownloadFlag,a.SchedulerCycleDateTime,@FileSetId,38,@currdate from mrco_DSRAbsentee_Data a  join tblDBRSalesStructureDBR d on a.DistributorCode=d.DistributorCode
join tblMstrPerson p on p.Descr=a.UserName
and p.DistNodeId=d.NodeID
and p.DistNodeType=d.NodeType
where p.NodeID is null and a.CycFileID=@FileSetId

delete a from mrco_DSRAbsentee_Data a  join tblDBRSalesStructureDBR d on a.DistributorCode=d.DistributorCode
join tblMstrPerson p on p.Descr=a.UserName
and p.DistNodeId=d.NodeID
and p.DistNodeType=d.NodeType
where p.NodeID is null and a.CycFileID=@FileSetId


if object_id('tempdb..#tempDSEData') is not null
begin
	drop table #tempDSEData
end


;with ashcte as(
select  P.NodeID as DSENodeId,P.NodeType as DSENodeType,d.NodeID as DistNodeId,d.NodeType as DistNodeType,DownloadFlag,a.DistUserUniqueID ,

ROW_NUMBER() over(partition by  P.NodeID,p.nodetype order by P.NodeID,p.nodetype,a.DistUserUniqueID desc) as rown
from mrco_DSRAbsentee_Data a join tblDBRSalesStructureDBR d on a.DistributorCode=d.DistributorCode
join tblMstrPerson p on p.Descr=a.UserName
and p.DistNodeId=d.NodeID
and p.DistNodeType=d.NodeType
--join tblDBRSalesStructureRoute r on r.Descr=a.BeatName
--and p.DistNodeId=d.NodeID
--and p.DistNodeType=d.NodeType
where a.CycFileID=@FileSetId
)

select DSENodeId,DSENodeType,DistNodeId,DistNodeType,DownloadFlag into #tempDSEData  from 
ashcte where rown=1

Update a set Absent=case when b.DownloadFlag='N' then 1 ELSE 0 END,FileSetIdUpd=@FileSetId,TimeStampUpd=@currdate from tblAttendanceDetail a join #tempDSEData b on a.DSENodeId=b.DSENodeId
and a.DSENodeType=b.DSENodeType 
where a.AttendDate=convert(date,@currdate)  

--Update a set Absent=0,FileSetIdUpd=@FileSetId,TimeStampUpd=@currdate from tblAttendanceDetail a  join #tempDSEData b on a.DSENodeId=b.DSENodeId
--and a.DSENodeType=b.DSENodeType 
--where a.AttendDate=convert(date,@currdate) and b.DSENodeId is null

Insert   into tblAttendanceDetail(AttendDate,DistNodeId,DistNodeType,DSENodeId,DSENodeType,RouteNodeId,RouteNodetype,Absent,FileSetIdIns,TimeStampIns)

select distinct @currdate,b.DistNodeId,b.DistNodeType,b.DSENodeId,b.DSENodeType,0,0,case when b.DownloadFlag='N' then 1 ELSE 0 END,@FileSetId,@currdate from tblAttendanceDetail a right join #tempDSEData b on a.DSENodeId=b.DSENodeId
and a.DSENodeType=b.DSENodeType 
and a.AttendDate=convert(date,@currdate) 
where a.DSENodeId is null


delete b from tblAttendanceDetail a join tblTeleCallerListForDay b on a.AttendDetId=b.AttendDetId
where Absent=0 and a.AttendDate=convert(date,@currdate) and b.IsUsed=0 

Declare @TeleCallingId bigint=0
Select @TeleCallingId=isnull(Max(TeleCallingId),1) from tblTeleCallerListForDay

 DBCC CHECKIDENT ('tblTeleCallerListForDay', RESEED, @TeleCallingId); 


--select a.RouteNodeId,a.RouteNodeType,a.DSENodeId,a.DSENodeType,a.StoreId,a.SectorId,convert(numeric(18,2),0) as Total,convert(float,0) as #OfInv into #StoresList  from tblRouteCalendar a join #tempDSEData b on a.RouteNodeId=b.RouteNodeId and a.RouteNodeType=b.RouteNodeType
--and a.DSENodeId=b.DSENodeId
--and a.DSENodeType=b.DSENodeType



--select storeid,count(distinct InvCode) as #OfInv, isnull(sum(Tot_Net_Val),0) as NetValue into #NetSales from tblsalesmaster(nolock) 
--where exists (select * from #StoresList where storeid=tblsalesmaster.StoreId)
--group by storeid



select 0 as AttendDetId, a.RouteNodeId,a.RouteNodeType,a.DSENodeId,a.DSENodeType,a.StoreId,a.DistNodeId,a.DistNodeType,a.SectorId,convert(numeric(18,2),0) as Total,convert(float,0) as #OfInv into #StoresList  from tblRouteCalendar a join #tempDSEData b on a.DSENodeId=b.DSENodeId and a.DSENodeType=b.DSENodeType
where a.VisitDate=convert(date,@currdate)

--select * from #StoresList
Update a set RouteNodeId=b.RouteNodeId,RouteNodetype=b.RouteNodeType from tblAttendanceDetail a join #StoresList b on a.DSENodeId=b.DSENodeId
and a.DSENodeType=b.DSENodeType
where a.AttendDate=convert(date,@currdate)


Update b set AttendDetId=a.AttendDetId from tblAttendanceDetail a join #StoresList b on a.DSENodeId=b.DSENodeId
and a.DSENodeType=b.DSENodeType
where a.AttendDate=convert(date,@currdate)



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
RouteName nvarchar(100),
DSEName varchar(250)

Update a set RouteName=b.Descr from #StoresList a join tblDBRSalesStructureRoute b on a.RouteNodeId=b.NodeID
and a.RouteNodeType=b.NodeType

Update a set DSEName=b.Descr from #StoresList a join tblMstrPerson b on a.DSENodeId=b.NodeID
and a.DSENodeType=b.NodeType
--select * from #StoresList
--Update a set FiveStarNoOfGPTgt=b.GPTgt,
--FiveStarNoOfLSSTgt=b.LSSTgt,
--FiveStarTotIndTgtDlvryVal=case when b.TargetValue>0 then 0 else b.TargetValue end,
--FiveStarAlrdyAchIndTgtDlvryVal=b.ActualSalesValue,NoOfPendingVisits=case when b.flgFullMonthDRCP<>1 then b.PendingVisit else 0 end,
--flgFullMonthDRCP=b.flgFullMonthDRCP,PassedVisits=b.VisitDone,NoOfVisitsInCM=b.NoOfVisitInCM
--from #StoresList a join  tblP3MRetailerWiseTargetVAlue b  on a.StoreId=b.StoreId

--select  b.StoreId,count(b.VisitDate)  as  NoOfPendingVisit  into  #NoOfPendingVisit from #StoresList  a join tblRouteCalendar b on a.StoreId=b.StoreId
--where b.VisitDate>convert(date,@Curr_Date) and month(b.VisitDate)=month(@Curr_Date)
--and year(b.VisitDate)=year(@Curr_Date) 
--group by b.StoreId

--Update a set NoOfPendingVisits=b.NoOfPendingVisit
--from #StoresList a join  #NoOfPendingVisit b  on a.StoreId=b.StoreId 
--where flgFullMonthDRCP=1
--Update a set FiveStarIndTgtDlvryVal=
--case  when  PassedVisits=0 then case when NoOfVisitsInCM between 2 and 3 
--then  (FiveStarTotIndTgtDlvryVal-FiveStarAlrdyAchIndTgtDlvryVal)*.6
--when NoOfVisitsInCM >3 
--then  (FiveStarTotIndTgtDlvryVal-FiveStarAlrdyAchIndTgtDlvryVal)*.3
--else (FiveStarTotIndTgtDlvryVal-FiveStarAlrdyAchIndTgtDlvryVal) end

--else 
--((FiveStarTotIndTgtDlvryVal-FiveStarAlrdyAchIndTgtDlvryVal)/(NoOfPendingVisits+1)) end from #StoresList a


--select  StoreID,ChannelId,SubChannelId,BranchSubdNodeId,BranchSubdNodeType
--,0 as ActBranchSubdNodeId,0 as ActBranchSubdNodeType

--,0 as DistributorNodeId,0 as DistributorNodeType into  #store from tblStoreMaster a 
--where exists (select * from  #StoresList b where b.StoreId=a.StoreID)

--update a set ActBranchSubdNodeId=BranchSubdNodeId,ActBranchSubdNodeType=BranchSubdNodeType from #store a where BranchSubdNodeType=140

--update a set ActBranchSubdNodeId=b.BrnNodeId,ActBranchSubdNodeType=b.BrnNodeType from #store a
--join tblSalesHierarchyUptoSUBD b on a.BranchSubdNodeId=b.SubdNodeId
--and a.BranchSubdNodeType=b.SubdNodeType
-- where BranchSubdNodeType=145

--update a set  DistributorNodeId=b.ActDBRNodeId,DistributorNodeType=b.ActDBRNodeType from #store a join tblCompanySalesStructureBranch b on a.ActBranchSubdNodeId=b.NodeID
--and a.ActBranchSubdNodeType=b.NodeType


-- Select sd.StoreID,count(distinct b.SchemeID) as NofSchmeme  into #LSSScheme  from tblSchemeApplicabilityDetail a join tblSchemeDetail b on a.SchemeDetID=b.SchemeDetID
--join tblSchemeMaster c on c.SchemeID=b.SchemeID
--join #store sd on 
-- ((a.StoreId=sd.StoreID or a.StoreId=0) and (a.ChannelId=sd.ChannelId or a.ChannelId=0)

--and (a.SubChannelId=sd.SubChannelId or a.SubChannelId=0)
--and ((a.DistributorNodeId =sd.DistributorNodeId and a.DistributorNodeType=sd.DistributorNodeType) or a.DistributorNodeId=0)
--and ((a.BranchSubDNodeId =sd.BranchSubDNodeId and a.BranchSubDNodeType=sd.BranchSubDNodeType) or a.BranchSubDNodeId=0)
--)
--where @AttendDate between b.SchemeFromDate and b.SchemeToDate and c.flgActive=1
-- and c.SchemeCode like 'LSS%' and c.schemetypeid=2
-- group by sd.StoreID

--Update a set FiveStarNoOfLSSTgt=0  from #StoresList a where not exists (select * from  #LSSScheme b where b.StoreId=a.StoreID)

--Update a set FiveStarNoOfLSSTgt=b.NofSchmeme  from #StoresList a join  #LSSScheme b on b.StoreId=a.StoreID 
--and b.NofSchmeme<a.FiveStarNoOfLSSTgt


--select a.StoreId,Max(OrderID) as OrderID into #Order from tblOrderMaster a join #StoresList b on a.StoreID=b.StoreId
--where flgOrderSource=1 and OrderDate<convert(date,@Curr_Date)
--group by a.StoreId

--Update b set lastOrderDate=a.OrderDate,LastOrderValue=a.NetOrderValue,OrderBy=u.UserFullName from  tblOrderMaster a join #StoresList b on a.StoreID=b.StoreId
--join #Order c on c.OrderID=a.OrderID
--join tblSecUserLogin l on l.LoginID=a.LoginIDIns
--join tblSecUser u on u.UserID=l.UserID


--select a.StoreId,Max(OrderID) as OrderID into #Orderhist from tblOrderMaster_History a join #StoresList b on a.StoreID=b.StoreId
--where flgOrderSource=1 and b.lastorderdate is null
--group by a.StoreId

--Update b set lastOrderDate=a.OrderDate,LastOrderValue=a.NetOrderValue,OrderBy=u.UserFullName from  tblOrderMaster_History a join #StoresList b on a.StoreID=b.StoreId
--join #Orderhist c on c.OrderID=a.OrderID
--join tblSecUserLogin l on l.LoginID=a.LoginIDIns
--join tblSecUser u on u.UserID=l.UserID


-- select a.storeid,isnull(max(BranchCCRDataId),0) as BranchCCRDataId into #CCRData from tblBranchCCRData a join #StoresList b on a.StoreId=b.StoreId and a.VisitDate>isnull(b.lastorderdate,'2010-01-01') 
-- where  OrderValue>0 and VisitDate<convert(date,@Curr_Date)
-- group by a.storeid

-- Update b set lastOrderDate=a.VisitDate,LastOrderValue=a.OrderValue,OrderBy=p.Descr from  tblBranchCCRData a join #StoresList b on a.StoreID=b.StoreId
--join #CCRData c on c.BranchCCRDataId=a.BranchCCRDataId
--join tblMstrPerson p on p.NodeID=a.DSENodeId

select a.* into #vwTeleCallerListForDay from vwTeleCallerListForDay  a join #StoresList b on a.StoreID=b.StoreId

select a.StoreId,max(a.TeleCallingId) as TeleCallingId into #TeleCallData from #vwTeleCallerListForDay a 
where flgCallStatus<>0 and Date<convert(date,@currdate)
group by a.StoreId

Update b set LastCall=a.Date,LastCallStatus=case when a.flgCallStatus=2 then 'Productive' else r.REASNCODE_LVL2NAME end ,LastCalledBY=u.TeleCallerCode,
AlternateNo=a.AlternateContactNo
 from  #vwTeleCallerListForDay a  join #StoresList b on a.StoreID=b.StoreId
join #TeleCallData c on c.TeleCallingId=a.TeleCallingId
join tblTeleCallerMstr u on u.TeleCallerId=a.TCNodeId
left join tblReasonCodeMstr r on r.ReasonCodeID=a.ReasonId


-- select a.storeid,isnull(max(BranchCCRDataId),0) as BranchCCRDataId into #CCRData2 from tblBranchCCRData a join #StoresList b on a.StoreId=b.StoreId 
-- where VisitDate<convert(date,@Curr_Date)
-- group by a.storeid

--  Update b set LastVisit=a.VisitDate,LastVisitStatus=case when a.OrderValue>0 then 'Productive' else a.[Reason Code] end,VisitedBy=p.Descr from  tblBranchCCRData a join #StoresList b on a.StoreID=b.StoreId
--join #CCRData2 c on c.BranchCCRDataId=a.BranchCCRDataId
--join tblMstrPerson p on p.NodeID=a.DSENodeId

 --select * from #StoresList
insert into tblTeleCallerListForDay(AttendDetId,StoreId,Date,DSENodeId,DSENodetype,RouteNodeId,RouteNodeType,DistNodeId,DistNodeType,
StoreCode,StoreName,ContactPerson,ContactNo,Channel,flgCallStatus,ScheduleCall,ReasonId,Priority,TotalSales,NoOfInv,TeleReasonId,TCNodeId,TCNodeType,IsUsed,SectorId,OutStandingAmt,OutStandingDate,ChannelId,LoginIdIns,RuleId,LastOrderDate,LastOrderValue,OrderBy,LastVisit,LastVisitStatus,VisitedBy,LastCall,LastCallStatus,LastCalledBY,SubChannelId,SubChannel,AlternateContactNo,FiveStarNoOfGPTgt,FiveStarNoOfLSSTgt,FiveStarIndTgtDlvryVal,FiveStarProductivityTgt,FiveStarTotIndTgtDlvryVal,
FiveStarAlrdyAchIndTgtDlvryVal
,NoOfPendingVisits,RouteName,DSEName,LanguageId,RouteGTMType,LotId)

select a.AttendDetId,a.StoreId,convert(date,getdate()),a.DSENodeId,a.DSENodeType,a.RouteNodeId,a.RouteNodeType,a.DistNodeId,a.DistNodeType,b.storecode,b.storename,isnull(b.contactperson,''),isnull(b.contactno,'')+isnull(','+b.MobileNo1,'')+isnull(','+b.MobileNo2,''),ch.ChannelName,0,null,0,row_number() over(order by case when [#OfInv]>0 then Total/[#OfInv] else 0 end desc),Total,[#OfInv],1,0,0,0,a.SectorId,b.OutStandingAmt,b.OutStandingDate,b.ChannelId,0,1,
a.LastOrderDate,a.LastOrderValue,a.OrderBy,a.LastVisit,a.LastVisitStatus,a.VisitedBy,a.LastCall,a.LastCallStatus,a.LastCalledBY
,b.SubChannelId,sh.SubChannel,a.AlternateNo,a.FiveStarNoOfGPTgt,a.FiveStarNoOfLSSTgt,
case when isnull(cw.ThresholdAmount,0)>a.FiveStarIndTgtDlvryVal then isnull(cw.ThresholdAmount,0)*1.1
else a.FiveStarIndTgtDlvryVal end,



isnull(cw.ThresholdAmount,0),
a.FiveStarTotIndTgtDlvryVal,
a.FiveStarAlrdyAchIndTgtDlvryVal
,a.NoOfPendingVisits,a.RouteName,A.DSEName,b.LanguageId,b.RouteGTMType,b.LotId
 from 
#StoresList a join tblstoremaster b on a.storeid=b.storeid
join tblMstrChannel ch on ch.channelid=b.channelid
join tblMstrSubChannel sh on sh.SubChannelId=b.SubChannelId
left join tblChannelWiseProductivityThreshold cw on cw.ChannelId=b.ChannelId and convert(date,getdate()) between cw.FromDate and cw.ToDate
left join tblTeleCallerListForDay z on a.StoreId=z.StoreId and z.Date=convert(date,getdate())
where z.StoreId is null
update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID=@FileSetId
end
