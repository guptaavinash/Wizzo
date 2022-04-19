
--truncate table tbltelecallerlistforday
--[spPopulateFailedOutletCall] 0
CREATE proc [dbo].[spPopulateFailedOutletCall]  
@FileSetId bigint
as
begin
return;
update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@FileSetId
Declare @currdate datetime=dbo.fnGetCurrentDateTime()



select r.nodeid as RouteNodeId,r.nodetype as RouteNodeType,p.nodeid as DSENodeId,p.NodeType as DSENodeType,s.StoreId,d.nodeid as DistNodeId,d.nodetype as DistNodeType,1 as SectorId,convert(numeric(18,2),0) as Total,convert(float,0) as #OfInv,FailedReason into #StoresList from mrco_FailedVisitOutlet_Data a join tblDBRSalesStructureDBR d on a.DistributorCode=d.DistributorCode
join tblMstrPerson p on p.Descr=a.console_SMName
and p.DistNodeId=d.NodeID
and p.DistNodeType=d.NodeType
join tblDBRSalesStructureRoute r on r.Descr=a.console_beatName
and r.DistNodeId=d.NodeID
and r.DistNodeType=d.NodeType
join tblStoreMaster s on s.StoreCode=a.ConsoleCode
where CycFileID=@FileSetId

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
DSEName varchar(250),
ReasonId tinyint


Update a set ReasonId=b.TeleReasonId from #StoresList a join tblTeleReasonMstr b on a.FailedReason=b.TeleReason

insert into tblTeleReasonMstr

select distinct FailedReason,1,1 from #StoresList a  where isnull(ReasonId,0)=0

Update a set ReasonId=b.TeleReasonId from #StoresList a join tblTeleReasonMstr b on a.FailedReason=b.TeleReason
where isnull(ReasonId,0)=0

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


--select b.StoreId,max(a.TeleCallingId) as TeleCallingId into #TeleCallData from vwTeleCallerListForDay a join #StoresList b on a.StoreId=b.StoreId
--where flgCallStatus<>0 and Date<convert(date,@Curr_Date)
--group by b.StoreId

--Update b set LastCall=a.Date,LastCallStatus=case when a.flgCallStatus=2 then 'Productive' else r.REASNCODE_LVL2NAME end ,LastCalledBY=u.UserFullName,
--AlternateNo=a.AlternateContactNo
-- from  vwTeleCallerListForDay a join #StoresList b on a.StoreID=b.StoreId
--join #TeleCallData c on c.TeleCallingId=a.TeleCallingId
--join tblSecUser u on u.UserID=a.TeleUserId
--left join tblReasonCodeMstr r on r.ReasonCodeID=a.ReasonId


-- select a.storeid,isnull(max(BranchCCRDataId),0) as BranchCCRDataId into #CCRData2 from tblBranchCCRData a join #StoresList b on a.StoreId=b.StoreId 
-- where VisitDate<convert(date,@Curr_Date)
-- group by a.storeid

--  Update b set LastVisit=a.VisitDate,LastVisitStatus=case when a.OrderValue>0 then 'Productive' else a.[Reason Code] end,VisitedBy=p.Descr from  tblBranchCCRData a join #StoresList b on a.StoreID=b.StoreId
--join #CCRData2 c on c.BranchCCRDataId=a.BranchCCRDataId
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

 
insert into tblTeleCallerListForDay(AttendDetId,StoreId,Date,DSENodeId,DSENodetype,RouteNodeId,RouteNodeType,DistNodeId,DistNodeType,
StoreCode,StoreName,ContactPerson,ContactNo,Channel,flgCallStatus,ScheduleCall,ReasonId,Priority,TotalSales,NoOfInv,TeleReasonId,TCNodeId,TCNodeType,IsUsed,SectorId,OutStandingAmt,OutStandingDate,ChannelId,LoginIdIns,RuleId,LastOrderDate,LastOrderValue,OrderBy,LastVisit,LastVisitStatus,VisitedBy,LastCall,LastCallStatus,LastCalledBY,SubChannelId,SubChannel,AlternateContactNo,FiveStarNoOfGPTgt,FiveStarNoOfLSSTgt,FiveStarIndTgtDlvryVal,FiveStarProductivityTgt,FiveStarTotIndTgtDlvryVal,
FiveStarAlrdyAchIndTgtDlvryVal
,NoOfPendingVisits,RouteName,DSEName,LanguageId,RouteGTMType,LotId)

select 0,a.StoreId,convert(date,getdate()),a.DSENodeId,a.DSENodeType,a.RouteNodeId,a.RouteNodeType,a.DistNodeId,a.DistNodeType,b.storecode,b.storename,isnull(b.contactperson,''),isnull(b.contactno,'')+isnull(','+b.MobileNo1,'')+isnull(','+b.MobileNo2,''),ch.ChannelName,0,null,0,row_number() over(order by case when [#OfInv]>0 then Total/[#OfInv] else 0 end desc),Total,[#OfInv],a.ReasonId,0,0,0,a.SectorId,b.OutStandingAmt,b.OutStandingDate,b.ChannelId,0,2,
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
