
--select * from tblSecUser where NodeType=800

--select * from tblTeleCallerCallLogDetail where TeleCallingId=36070

--select * from tblAutoDialTeleCallerListForDay where ContactNo='9971032660'
--select * from tblAutoDialTeleCallerListForDay where storecode='1005681' and  date='25-Nov-2020'

--select * from tblAutoDialTeleCallerListForDay where DbrNodeId=4490 and date='25-Nov-2020' and StartHour<14
--and IsUsed<>2
-- [spGetNextStoreIdForTeleCaller] 8,800,'14-SEP-2021'
CREATE proc [dbo].[spGetNextStoreIdForTeleCaller] --12,800,'25-Nov-2020'
@TCNodeId int,
@TCNodeType int,
@CallDate date
as
begin
Declare @currdate datetime=GETDATE(),@DialerTypeId tinyint
select LanguageId,b.IsPriority into #Lang from tblTeleCallerLanguageMapping a join tblLanguageMaster b on a.LanguageId=b.LngID where TelecallerId=@TCNodeId

select @DialerTypeId=DialerTypeId from tblTeleCallerMstr where TeleCallerId=@TCNodeId and NodeType=@TCNodeType

--select StateId into #State from tblTeleCallerStateMapping a where TelecallerId=@TCNodeId


--select DbrNodeId,DbrNodeType into #DBNodeIds from tblTeleCallerDistributorMapping where TelecallerId=@TCNodeId

select distinct DistNodeId into #Distributor from tblPrdActivePrdList

Declare @TeleCallingId bigint=0,@Storeid int=0

select @TeleCallingId=TeleCallingId,@Storeid=Storeid from tblTeleCallerListForDay where TCNodeId=@TCNodeId and TCNodeType=@TCNodeType and IsUsed  =1
and date= @CallDate
if @TeleCallingId=0
begin
PRINT 'ASH'
select Top 1 @TeleCallingId=tblTeleCallerListForDay.TeleCallingId,@StoreId=tblTeleCallerListForDay.StoreId  from tblTeleCallerListForDay
--join #DBNodeIds b on a.DistNodeId=b.DbrNodeId
--and a.DistNodeType=b.DbrNodeType
join #Lang on #Lang.LanguageId=isnull(tblTeleCallerListForDay.LanguageId,1) 
--join #State on #State.StateId=tblTeleCallerListForDay.StateId 
where tblTeleCallerListForDay.Date=@CallDate 
--and tblTeleCallerListForDay.isused IN(0,3)
--and exists(select * from #Distributor z   where z.DistNodeId=tblTeleCallerListForDay.DistNodeId) 
and (isnull(callattempt,0)<2 
--or isnull(tblTeleCallerListForDay.ReasonId,0)=8
) AND (isnull(TCNodeId,0)=0 or (TCNodeId=@TCNodeId AND TCNodeType=@TCNodeType))
 --AND LEN(CONTACTNo)>=7 and left(ContactNo,1) in('6','7','8','9','1','0','2') 
and IsValidContactNo=1 AND DistNodeId<>0
and ((IsUsed=3  and DATEDIFF(MINUTE,CONVERT(TIME,@currdate),convert(time,ScheduleCall))<3)
or IsUsed in(0,5))
--and SectorId=2

--AND LEN(CONTACTNo)=10 and TblTeleCallerListForDay.DistNodeId=514
--and  (case when a.IsUsed=4 then 10 
--when a.IsUsed=3  and DATEDIFF(MINUTE,CONVERT(TIME,GETDATE()),convert(time,ScheduleCall))<3
--then 10
--when a.IsUsed=3  and DATEDIFF(MINUTE,CONVERT(TIME,GETDATE()),convert(time,ScheduleCall))>=3
--then 18
--else  StartHour end)<=datepart(hour,getdate()) ---and isnull(EndHour,18)-1
order by CASE 
--WHEN IsUsed=4  then   -9999 
WHEN IsUsed=3  and DATEDIFF(MINUTE,CONVERT(TIME,@currdate),convert(time,ScheduleCall))<3
then   1 
WHEN IsUsed=3  and DATEDIFF(MINUTE,CONVERT(TIME,@currdate),convert(time,ScheduleCall))>=3
then   99
WHEN IsUsed=5  
then   98
---WHEN IsUsed=5  then  8 
else 2  end
,
--case when IsUsed=5 then callmarktimeforbusycall else @currdate end,
RouteName ,SectorId,#Lang.IsPriority

,totalsales desc, TeleCallingId

Update a set TCNodeId=@TCNodeId,TCNodeType=@TCNodeType,IsUsed=1,DialerTypeId=@DialerTypeId from tblTeleCallerListForDay a where TeleCallingId=@TeleCallingId
end
select StoreId ,TeleCallingId,RouteNodeId as RouteId,RouteNodeType,a.DistNodeId,a.DistNodeType,ContactNo AS MobNo,b.Descr as DistributorName,a.AlternateContactNo,a.RouteName,a.SOName as DSENAME
from tblTeleCallerListForDay(nolock) a join tblDBRSalesStructureDBR b on a.DistNodeId=b.NodeID 
where TeleCallingId=@TeleCallingId
end
