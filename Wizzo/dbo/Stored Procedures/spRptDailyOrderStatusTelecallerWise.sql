





--select * from tblSecUser where  
--[spRptDailyOrderStatusTelecallerWise] '8-jan-2021','09-feb-2021',0,0,0
CREATE procedure [dbo].[spRptDailyOrderStatusTelecallerWise]
@FromDate date,
@ToDate date,
@SiteNodeId INT=0,
@SiteNodeType INT=0,
@LoginId INT,
@flgActiveProductivityNorms tinyint=0,
@TeleReasonIds varchar(100)='',----'1|2|3|4|5'
@SectorIds varchar(100)=''
AS
BEGIN

SET @flgActiveProductivityNorms=0
Declare @NodeId int,@NodeType int,@RoleId int
select @NodeId=b.UserNodeId,@NodeType=b.UserNodeType,@RoleId=b.RoleId from tblSecUserLogin a join tblSecMapUserRoles b on a.userid=b.UserID where LoginId=@LoginId 

select distinct items  as TeleReasonId into #TeleReason from dbo.Split(@TeleReasonIds,'|') where items<>''

select distinct items  as SectorId into #Sector from dbo.Split(@SectorIds,'|') where items not in('','0')


Create table #ASoList(Zone varchar(100),Region varchar(100),ASMArea varchar(100),SOArea varchar(100),SOAreaNodeId int,SOAreaNodeType int
,ASMAreaNodeId int,ASMAreaNodeType int
,ZoneNodeId int,ZoneNodeType int
,RegionNodeId int,RegionNodeType int
,SONodeId int,SONodeType int
)

Insert into #ASoList
exec [spGetSOList] @LoginId


if (select count(*) from #TeleReason)=0
	begin
		insert into #TeleReason
		select TeleReasonId from tblTeleReasonMstr
		union all
		select 0
	end

	if (select count(*) from #Sector)=0
	begin
		insert into #Sector
		select SectorId from tblMstrSector
	end
select c.TeleCallingId, c.TCNodeId,c.DistNodeId,c.DistNodeType,a.PrdNodeId,b.TotOrderVal as NetLineOrderVal into #OrderData 
from tblTCOrderDetail a(nolock) join tblTCordermaster b(nolock) on a.orderid=b.orderid
join vwTeleCallerListForDay c(nolock) on c.TeleCallingId=b.TeleCallingId
--inner join tblSecUserLogin ul on ul.LoginID = b.LoginIDIns inner join tblSecUser u on u.UserID = ul.UserID and u.RoleID <>10
join #ASoList l on l.SONodeId=c.SONodeId
and l.SONodeType=c.SONodeType
where (b.OrderDate between @FromDate and @ToDate) and a.OrderQty>0
UNION

select c.TeleCallingId, c.TCNodeId,c.DistNodeId,c.DistNodeType,a.PrdNodeId,b.TotOrderVal as NetLineOrderVal
from tblTCOrderDetail_history a(nolock) join tblTCordermaster_history b(nolock) on a.orderid=b.orderid
join vwTeleCallerListForDay c(nolock) on c.TeleCallingId=b.TeleCallingId
--inner join tblSecUserLogin ul on ul.LoginID = b.LoginIDIns inner join tblSecUser u on u.UserID = ul.UserID and u.RoleID <>10
join #ASoList l on l.SONodeId=c.SONodeId
and l.SONodeType=c.SONodeType
where (b.OrderDate between @FromDate and @ToDate) and a.OrderQty>0


--select TeleCallingId, TeleUserId,SiteNodeId,sum(NetLineOrderVal) as NetLineOrderVal into #OrderData_1 
--from #OrderData group by TeleCallingId, TeleUserId,SiteNodeId


select c.TCNodeId,c.distnodeid,c.DistNodeType,a.PrdNodeId,a.Qty,a.RETAILING as NetValue,0 as RetNetValue,a.RETAILING as InvNetValue,c.StoreId into #Inv from tblTeleCallingInvDetail a(nolock) join vwTeleCallerListForDay c(nolock) on c.TeleCallingId=a.TeleCallingId 
join #ASoList l on l.SOAreaNodeId=c.SOAreaNodeId
and l.SOAreaNodeType=c.SOAreaNodeType
where c.Date between @FromDate and @ToDate
and a.flgOrderSource=1 and StatusId=5

select  0 as flgorder, b.TeleCallerCode+' ['+b.TeleCallerName+']' as  [Tele Caller],dr.Descr+' ['+dr.DistributorCode+']' as Distributor,Count(*) as [# Calls Planned],sum(convert(int,IsValidContactNo)
) as [# Phone Available],
sum(case when callmade is not null then 1 else 0 end) as [# Calls Made],
sum(case when flgCallStatus=3 and a.ReasonId=8 then 1 when flgCallStatus=2 then 1
when flgCallStatus=1 and isnull(rc.reasnfor,0)=2  then 1 else 0 end) as [# Calls Picked]

,sum(case when flgCallStatus=2 then case when (@flgActiveProductivityNorms=1 and a.TotOrderVal>=th.ThresholdAmount) or @flgActiveProductivityNorms=0 then 1 else 0 end else 0 end) as [# Calls Productive]
--,sum(case when flgCallStatus=2 then 1 else 0 end) as [# Calls Productive]
,sum(a.NoOfSKU) as [# Lines Ordered]

 ,isnull(sum(a.TotOrderVal),0) AS [Value Ordered]
 --,isnull(sum(a.NoOfStarsAch),0) AS [# of Star Points]
 --,isnull(sum(case when a.NoOfStarsAch=5 then 1 else 0 end),0) AS [# of 5 Star Calls]
 --,isnull(sum(og.GPValue),0) AS [GP GAPs Ordered]
 --,isnull(sum(og.[SBDSBFOrd]),0) AS [GP Lines Added]
 --,isnull(sum(og.[FocBndNowAch]),0) AS [FB Achieved in Order]
 --,isnull(sum(og.[FocBndSBFOrd]),0) AS [# of FB SBF Ordered]
-- (select isnull(sum(c1.NetLineOrderVal),0) from #OrderData c1 where c1.TeleUserId=a.TeleUserId  and c1.SiteNodeId=C.SiteNodeId) AS [Value Ordered]
  ,(select Count(*) from #Inv c1 where c1.TCNodeId=a.TCNodeId   and c1.DistNodeId=a.DistNodeId
   and Qty>0)  AS [Net Lines Supplied]
	  ,(select isnull(sum(c1.InvNetValue),0) from #Inv c1 where c1.TCNodeId=a.TCNodeId   and c1.DistNodeId=a.DistNodeId)  AS [Value Supplied]
	  ,(select isnull(sum(c1.RetNetValue),0) from #Inv c1 where c1.TCNodeId=a.TCNodeId   and c1.DistNodeId=a.DistNodeId)  AS [Return Value]
	 ,(select isnull(sum(c1.NetValue),0) from #Inv c1 where c1.TCNodeId=a.TCNodeId   and c1.DistNodeId=a.DistNodeId)  AS [Net Value Supplied]
	  ,(select count(distinct StoreId) from #Inv c1 where c1.TCNodeId=a.TCNodeId   and c1.DistNodeId=a.DistNodeId) AS [# Stores Served]
	  ,convert(numeric(20,2),0)  AS [Throughput]
	  , 
convert(numeric(15,0),0) AS Productivity
	  , 
convert(numeric(15,0),0) AS [Call Conversion %]
,convert(numeric(10,1),0)  AS LPB 

 into #TeleData
 from vwTeleCallerListForDay a(nolock) join tblTeleCallerMstr b on a.TCNodeId=b.TeleCallerId 
 join #ASoList c on c.SOAreaNodeId=a.SOAreaNodeId
 and c.SOAreaNodeType=a.SOAreaNodeType
 left join tblChannelWiseProductivityThreshold th on th.ChannelId=a.ChannelId
 
 and a.Date between th.FromDate and th.ToDate
 join #TeleReason t on t.TeleReasonId=a.TeleReasonId
   left join tblReasonCodeMstr rc on rc.reasoncodeid=a.reasonid
   	join #Sector sc on sc.SectorId=a.SectorId
	join tblDBRSalesStructureDBR dr on dr.NodeID=a.DistNodeId
	and dr.NodeType=a.DistNodeType
 where a.date between @FromDate and @ToDate 


group by a.tcnodeid,b.TeleCallerCode,b.TeleCallerName,dr.Descr,dr.DistributorCode , a.DistNodeId,a.DistNodeType
order by [# Calls Planned] desc

Update #TeleData set Productivity= convert(numeric(15,0),(CONVERT(FLOAT,[# Calls Productive])*100)/([# Phone Available]))
where [# Phone Available]>0

Update #TeleData set [Call Conversion %]= convert(numeric(15,0),(CONVERT(FLOAT,[# Calls Productive])*100)/([# Calls Picked]))
where [# Calls Picked]>0

Update #TeleData set [Throughput]= convert(numeric(20,2),(([Value Ordered]))/([# Calls Productive]))
where [# Calls Productive]>0

Update #TeleData set LPB= convert(numeric(10,1),(([# Lines Ordered])))/([# Calls Productive])
where [# Calls Productive]>0


--select * from #TeleData --where TASSiteName='Uttarakhand [2001596299]'
PRINT 'TTTTAA'
insert into #TeleData
select 1,[Tele Caller],'Total',case when sum([# Calls Planned])<85 then 85 else sum([# Calls Planned]) end,sum([# Phone Available]),
sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive]),sum([# Lines Ordered]),
sum([Value Ordered])

,Sum([Net Lines Supplied]),Sum([Value Supplied]),Sum([Return Value]),Sum([Net Value Supplied]),Sum([# Stores Served]),convert(numeric(20,2),
case when sum([# Calls Productive])>0 then 
(sum([Value Ordered]))/sum([# Calls Productive]) else 0 end),convert(numeric(15,0),

case when sum([# Phone Available])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Phone Available]) else 0 end)
,convert(numeric(15,0),
case when sum([# Calls Picked])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Picked]) else 0 end)
,
case when sum([# Calls Productive])>0 then 
convert(numeric(10,1),sum([# Lines Ordered]))/sum([# Calls Productive]) else 0 end

 from #TeleData group by [Tele Caller]
 PRINT 'SSDSSDF'


--if (select Count(distinct TASSiteName) from #BranchList)>1 and (select count(*) from #TeleData)<>0
--BEGIN
--insert into #TeleData
--select 2,'Grand Total','zzzzzzzzz','aaaaa',sum([# Calls Planned]),sum([# Phone Available]),sum([# Calls Made]),sum([# Calls Picked]),
--sum([# Calls Productive]),sum([# Lines Ordered]),sum([Value Ordered]),sum([# of Star Points]),
--sum([# of 5 Star Calls]),sum([GP GAPs Ordered]) ,isnull(sum([GP Lines Added]),0)  
-- ,isnull(sum([FB Achieved in Order]),0)
-- ,isnull(sum([# of FB SBF Ordered]),0) ,Sum([Net Lines Supplied]),Sum([Value Supplied]),Sum([Return Value]),Sum([Net Value Supplied]),Sum([# Stores Served]),
--convert(numeric(20,2),
--case when sum([# Calls Productive])>0 then 
--(sum([Value Ordered]))/sum([# Calls Productive]) else 0 end),convert(numeric(15,0),

--case when sum([# Phone Available])>0 then 
--convert(float,(sum([# Calls Productive])*100))/sum([# Phone Available]) else 0 end)
--,convert(numeric(15,0),
--case when sum([# Calls Picked])>0 then 
--convert(float,(sum([# Calls Productive])*100))/sum([# Calls Picked]) else 0 end)
--,
--case when sum([# Calls Productive])>0 then 
--convert(numeric(10,1),sum([# Lines Ordered]))/sum([# Calls Productive]) else 0 end from #TeleData where flgorder=1
--END
PRINT 'SSDSSDFSDDDFF'
select  [Tele Caller],--Distributor,
[# Calls Planned],
[# Phone Available],[# Calls Made],[# Calls Picked],[# Calls Productive],[# Lines Ordered],[Value Ordered]
 --,[# of FB SBF Ordered] 

,[Net Lines Supplied],[Value Supplied],[Return Value],[Net Value Supplied],[# Stores Served],[Throughput],CONVERT(VARCHAR,Productivity)+'%' AS Productivity,Convert(varchar,[Call Conversion %])+'%' as [Call Conversion %],LPB from #TeleData where flgorder=1 order by [Tele Caller],flgOrder
  END
