
--select * from mrco_RetailerMaster_Astic
--[spPopulateRetailerAndRouteCalendar] 42870
CREATE proc [dbo].[spPopulateRetailerAndRouteCalendar] 
@CycFileId bigint
as
begin
--Declare @CycFileId bigint=0
Declare @CurrDate datetime=dbo.fnGetCurrentDateTime()
insert into mrco_RetailerMaster_Astic_Error(ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,FileSetId,ErrorId,TimeStampIns)
SELECT        ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,@CycFileId,15,@CurrDate
FROM            mrco_RetailerMaster_Astic 
WHERE        (RetailerFrequency Not IN ('Weekly', 'Fort nightly'))
and CycFileID=@CycFileId
Delete FROM            mrco_RetailerMaster_Astic
WHERE        (RetailerFrequency Not IN ('Weekly', 'Fort nightly'))
and CycFileID=@CycFileId
set @CurrDate=dbo.fnGetCurrentDateTime()
insert into mrco_RetailerMaster_Astic_Error(ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,FileSetId,ErrorId,TimeStampIns)
SELECT        ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,@CycFileId,16,@CurrDate
FROM            mrco_RetailerMaster_Astic
WHERE        (CallDays Not IN ('1','2','3','4','5','6','7'))
and CycFileID=@CycFileId
--Delete FROM            mrco_RetailerMaster_Astic
--WHERE        (CallDays Not IN ('1','2','3','4','5','6','7'))
--and CycFileID=@CycFileId

set @CurrDate=dbo.fnGetCurrentDateTime()
insert into mrco_RetailerMaster_Astic_Error(ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,FileSetId,ErrorId,TimeStampIns)
SELECT        ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,@CycFileId,17,@CurrDate
FROM            mrco_RetailerMaster_Astic
WHERE        (RetailerFrequency='Fort nightly' and isnull(RetailerSequence,0) not in('2','1'))
and CycFileID=@CycFileId
--Delete FROM            mrco_RetailerMaster_Astic
--WHERE        (RetailerFrequency='Fort nightly' and isnull(RetailerSequence,0) not in('2','1'))
--and CycFileID=@CycFileId



set @CurrDate=dbo.fnGetCurrentDateTime()
insert into mrco_RetailerMaster_Astic_Error(ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,FileSetId,ErrorId,TimeStampIns)
SELECT        ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,@CycFileId,18,@CurrDate
FROM            mrco_RetailerMaster_Astic
WHERE        (Len(RtrCode)<1)
and CycFileID=@CycFileId
Delete FROM            mrco_RetailerMaster_Astic
WHERE        (Len(RtrCode)<1)
and CycFileID=@CycFileId

set @CurrDate=dbo.fnGetCurrentDateTime()
insert into mrco_RetailerMaster_Astic_Error(ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,FileSetId,ErrorId,TimeStampIns)
SELECT        ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, a.StateName, RtrPinCode, CityCode, 
                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,@CycFileId,19,@CurrDate
FROM            mrco_RetailerMaster_Astic a left join tblDBRSalesStructureDBR b on a.DistCode=b.DistributorCode
WHERE        b.NodeID is null
and CycFileID=@CycFileId
Delete a   FROM            mrco_RetailerMaster_Astic a left join tblDBRSalesStructureDBR b on a.DistCode=b.DistributorCode
WHERE        b.NodeID is null
and CycFileID=@CycFileId


set @CurrDate=dbo.fnGetCurrentDateTime()
--insert into mrco_RetailerMaster_Astic_Error(ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
--                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
--                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,FileSetId,ErrorId,TimeStampIns)
--SELECT        ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
--                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
--                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,@CycFileId,5,@CurrDate
--FROM            mrco_RetailerMaster_Astic
--WHERE        (Len(DistCode)<1)

--Delete FROM            mrco_RetailerMaster_Astic
--WHERE        (Len(DistCode)<1)


if OBJECT_ID('tempdb..#Lot') is not null
begin
	drop table #Lot
end

select distinct LineofTradeCode  into #Lot from mrco_RetailerMaster_Astic where isnull(LineofTradeCode,'')<>''
and CycFileID=@CycFileId
insert into tblMstrLineOfTrade
select a.LineofTradeCode from #Lot a left join tblMstrLineOfTrade b on a.LineofTradeCode=b.LoTName
where b.lotid  is null



if OBJECT_ID('tempdb..#ChannelDetail') is not null
begin
	drop table #ChannelDetail
end

select distinct ChannelCode,ChannelName,SubChannelCode,SubChannelName  into #ChannelDetail from mrco_RetailerMaster_Astic 
where  CycFileID=@CycFileId
set @CurrDate=dbo.fnGetCurrentDateTime()
insert into tblMstrChannel
select a.ChannelCode,Max(a.ChannelName),@CycFileId,@CurrDate from #ChannelDetail a left join tblMstrChannel b on a.ChannelCode=b.ChannelCode
where b.ChannelCode is null and isnull(a.channelCode,'')<>''
group by a.ChannelCode 

insert into tblMstrSUBChannel
select a.SubChannelCode,Max(a.SubChannelName),isnull(c.ChannelId,0),@CycFileId,@CurrDate from #ChannelDetail a left JOIN tblMstrChannel c on a.ChannelCode=c.ChannelCode left join tblMstrSUBChannel b on a.SubChannelCode=b.SubChannelCode
where b.SubChannelCode is null and isnull(a.SubChannelCode,'')<>''
group by a.SubChannelCode ,isnull(c.ChannelId,0)



if object_id('tempdb..#Retailer') is not null
begin
drop table #Retailer
end
select distinct ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, Mobileno1, Mobileno2, Lattitude, Longitude,CSRtrCode,0 as ChannelId,0 as SubChannelId,0 as DistNodeId,0 as DistNodeType,0 as LotId,
						 RetailerFrequency,CallDays,RetailerSequence,0 as TotalVisits,0 as PendingVisits
						   into #Retailer from mrco_RetailerMaster_Astic
						 where  CycFileID=@CycFileId
;with ashcte as(
select *,ROW_NUMBER() over (partition  by RtrCode order by RtrCode) as rown from #Retailer)

insert into mrco_RetailerMaster_Astic_Error(ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, SMCode, SMName, Positioncode, 
                         RMCode, RMName, LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, RetailerFrequency, RetailerSequence, RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, CallDays, Mobileno1, Mobileno2, Lattitude, Longitude, Createddate,CSRtrCode,FileSetId,ErrorId,TimeStampIns)
SELECT        ASMArea, DistCode, DistributorName, RtrCode, Registered, ParentCompRtrCode, RtrName, ParentRtrName, RelationStatus, RtrAddress1, RtrAddress2, RtrAddress3, RtrPhoneNo, RtrType, '', '', '', 
                         '', '', LineofTradeCode, ChannelCode, ChannelName, SubChannelCode, SubChannelName, programName, RetailerStatus, '', '', RelatedParty, StateName, RtrPinCode, CityCode, 
                         RouteGTMType, '', Mobileno1, Mobileno2, Lattitude, Longitude, null,CSRtrCode,@CycFileId,20,@CurrDate
FROM            ashcte where rown>1

;with ashcte as(
select *,ROW_NUMBER() over (partition  by RtrCode order by RtrCode) as rown from #Retailer)
delete ashcte where rown>1

set datefirst 1
if OBJECT_ID('tempdb..#CallDaysWeek') is not null
begin
drop table #CallDaysWeek
end

select * INTO #CallDaysWeek from dbo.[fnGetWeekDaysWiseNoOfDays](MOnth(@CurrDate),year(@CurrDate))
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


Update a set TotalVisits=b.NoOfTimes,PendingVisits= case when b.NoOfTimes>=@WeekNo then (b.NoOfTimes-@WeekNo)+1 else 0 end  from #Retailer a join #CallDaysWeek b on a.CallDays=b.WeekDayNo where RetailerFrequency='Weekly'

Update a set TotalVisits=case when isnull(RetailerSequence,1)=1 and  b.NoOfTimes>4 then 3 else 2 end
,PendingVisits= case when isnull(RetailerSequence,1)=1 
and b.NoOfTimes>4 THEN
 case when  @WeekNo in(1,2) then 3
when @WeekNo in (3,4) then 2
when @WeekNo=5 then 1 end

when RetailerSequence in(1,2) 
and b.NoOfTimes>=4 THEN case  when @WeekNo in(1,2) then 2
when @WeekNo in(3,4,5) then 1
end else 1 end
 from #Retailer a join #CallDaysWeek b on a.CallDays=b.WeekDayNo where RetailerFrequency='Fort nightly'

Update a set ChannelId=b.ChannelId from #Retailer a join tblmstrchannel b on a.ChannelCode=b.ChannelCode
Update a set SubChannelId=b.SubChannelId from #Retailer a join tblMstrSUBChannel b on a.SubChannelCode=b.SubChannelCode

Update a set LotId=b.LoTId from #Retailer a join tblMstrLineOfTrade b on a.LineofTradeCode=b.LoTName

Update a set DistNodeId=b.NodeID,DistNodeType=b.NodeType from #Retailer a join tblDBRSalesStructureDBR b on a.DistCode=b.DistributorCode

--select * from #Retailer where PendingVisits=10
set @CurrDate=dbo.fnGetCurrentDateTime()

Update a set StoreName=b.RtrName,Address=b.RtrAddress1,[Address 2]=b.RtrAddress2,[Address 3]=b.RtrAddress3,LineOfTradeCode=b.LineofTradeCode,City=b.CityCode,StateName=b.StateName,RelationStatus=b.RelationStatus,flgActive=case when b.RetailerStatus='Active' then 1 else 0 end,TimeStampUpd=@CurrDate,FileSetIdUpd=@CycFileId,
ChannelId=b.ChannelId,SubChannelId=b.SubChannelId,LotId=b.LotId,RouteGTMType=b.RouteGTMType,CSRtrCode=b.CSRtrCode,
RetailerFrequency=b.RetailerFrequency,
RetailerSequence=b.RetailerSequence,
CallDays=b.CallDays,
TotalVisits=b.TotalVisits,
PendingVisits=isnull(b.PendingVisits,0)
from tblStoreMaster a join #Retailer b on a.StoreCode=b.RtrCode

insert into tblStoreMaster(StoreCode, StoreName, TimeStampIns, TimeStampUpd, DistNodeId, DistNodeType, flgActive, ParentCompRtrCode, RelationStatus, ContactNo, MobileNo1, MobileNo2, ContactPerson, ChannelId, SubChannelId, 
                         OutstandingAmt, OutstandingDate,  Address, [Address 2], [Address 3], StateName, City, [Pin Code], RelatedParty, LineOfTradeCode, programName, GPS_Lat, GPS_Long, FileSetIdIns,LotId,CSRtrCode,RouteGTMType,RetailerFrequency,RetailerSequence,CallDays,TotalVisits,
						 PendingVisits)

select RtrCode,RtrName,@CurrDate,null,a.DistNodeId,a.DistNodeType,case when a.RetailerStatus='Active' then 1 else 0 end,a.ParentCompRtrCode,a.RelationStatus,a.RtrPhoneNo,a.Mobileno1,a.Mobileno2,'',a.ChannelId,a.SubChannelId,0,@CurrDate,a.RtrAddress1,a.RtrAddress2,a.RtrAddress3,a.StateName,a.CityCode,a.RtrPinCode,a.RelatedParty,a.LineofTradeCode,a.programName,a.Lattitude,a.Longitude,@CycFileId,a.LotId,a.CSRtrCode,a.RouteGTMType,a.RetailerFrequency,a.RetailerSequence,a.CallDays,a.TotalVisits,
						 isnull(a.PendingVisits,0) from #Retailer a left join tblStoreMaster b on a.RtrCode=b.StoreCode
where b.StoreID		is null


Update a set StateId=b.StateId from tblStoreMaster a join tblStateMasterSearchList b on a.StateName=b.StateName
where a.StateId is null


Update a set LanguageId=b.LanguageId from tblStoreMaster a join tblstatemaster b on a.stateid=b.NodeID
where a.LanguageId is null

set @CurrDate=dbo.fnGetCurrentDateTime()
if object_id('tempdb..#Person') is not null
begin
drop table #Person
end
select distinct  DistCode,SMCode,SMName,0 as DistNodeId,0 as DistNodeType into #Person from mrco_RetailerMaster_Astic where  CycFileID=@CycFileId


Update a set DistNodeId=b.NodeID,DistNodeType=b.NodeType from #Person a join tblDBRSalesStructureDBR b on a.DistCode=b.DistributorCode


insert into tblMstrPerson(Code,Descr,Designation,NodeType,FromDate,ToDate,FileSetIdIns,TimestampIns,flgCompanyPerson,flgDeliveryBoy,flgDriver,flgRegistered,DistNodeId,DistNodeType)
select distinct  SMCode, SMName,'DSR',240,@CurrDate,'2050-12-31',@CycFileId,@CurrDate,0,0,0,0,A.DistNodeId,A.DistNodeType from #Person a left join tblMstrPerson b on a.DistNodeId=b.DistNodeId
and a.DistNodeType=b.DistNodeType
and a.SMName=b.Descr
where b.NodeID is null


set @CurrDate=dbo.fnGetCurrentDateTime()
if object_id('tempdb..#Route') is not null
begin
drop table #Route
end
select distinct  DistCode,RMCode,RMName,0 as DistNodeId,0 as DistNodeType into #Route from mrco_RetailerMaster_Astic where  CycFileID=@CycFileId


Update a set DistNodeId=b.NodeID,DistNodeType=b.NodeType from #Route a join tblDBRSalesStructureDBR b on a.DistCode=b.DistributorCode

insert into [tblDBRSalesStructureRoute](Code,Descr,NodeType,IsActive,DistNodeId,DistNodeType,FileSetIDIns,TimestampIns)

select distinct RMCode,RMName,170,1,a.DistNodeId,a.DistNodeType,@CycFileId,@CurrDate  from #Route a left join [tblDBRSalesStructureRoute] b on a.DistNodeId=b.DistNodeId
and a.DistNodeType=b.DistNodeType
and a.RMCode=b.Code
where b.Code is null

--declare @CurrDate datetime
set @CurrDate=dbo.fnGetCurrentDateTime()
Declare @CallDays tinyint=1
set datefirst 1
select @CallDays=DATEPART(dw,@CurrDate)
set datefirst 7

delete [tblRouteCalendar] where VisitDate=convert(date,@CurrDate)

Declare @RouteCalendarId bigint=0
Select @RouteCalendarId=isnull(Max(RouteCalendarId),1) from [tblRouteCalendar]

 DBCC CHECKIDENT ('tblRouteCalendar', RESEED, @RouteCalendarId); 

--select @CallDays 
insert into [tblRouteCalendar](DSENodeId, DSENodeType, DistNodeId, DistNodeType, StoreId, SectorId, RouteNodeId, RouteNodeType, VisitDate, FileSetId, TimeStamps, FrqTypeId)

select distinct p.NodeID,p.NodeType,b.NodeID,b.NodeType,s.StoreID,1,r.NodeID,r.NodeType,@CurrDate,@CycFileId,@CurrDate,2 from mrco_RetailerMaster_Astic a join tblDBRSalesStructureDBR b on a.DistCode=b.DistributorCode
join tblMstrPerson p on p.Code=a.SMCode and p.DistNodeId=b.NodeID
and p.DistNodeType=b.NodeType
join tblDBRSalesStructureRoute r on  r.Code=a.RMCode and r.DistNodeId=b.NodeID
and r.DistNodeType=b.NodeType
join tblStoreMaster s on s.StoreCode=a.RtrCode
where a.RetailerFrequency='Weekly' and a.CallDays=@CallDays and  CycFileID=@CycFileId


 insert into [tblRouteCalendar](DSENodeId, DSENodeType, DistNodeId, DistNodeType, StoreId, SectorId, RouteNodeId, RouteNodeType, VisitDate, FileSetId, TimeStamps, FrqTypeId)

select distinct p.NodeID,p.NodeType,b.NodeID,b.NodeType,s.StoreID,1,r.NodeID,r.NodeType,@CurrDate,@CycFileId,@CurrDate,2 from mrco_RetailerMaster_Astic a join tblDBRSalesStructureDBR b on a.DistCode=b.DistributorCode
join tblMstrPerson p on p.Code=a.SMCode and p.DistNodeId=b.NodeID
and p.DistNodeType=b.NodeType
join tblDBRSalesStructureRoute r on  r.Code=a.RMCode and r.DistNodeId=b.NodeID
and r.DistNodeType=b.NodeType
join tblStoreMaster s on s.StoreCode=a.RtrCode
where a.RetailerFrequency='Fort nightly' and a.CallDays=@CallDays and a.RetailerSequence=@RetailerSequence  and  CycFileID=@CycFileId
end
