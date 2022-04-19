









--select * from tblTeleReasonMstr

--exec [spGetDistributorList] 95
--EXEC [spRptPerfomanceOverViewn] '14-Apr-2021','14-Apr-2021','','',95,1,0
CREATE procedure [dbo].[spRptPerfomanceOverViewn]
@FromDate date,
@ToDate date,
@SiteNodeIds varchar(100),-----'1|2|3|4|5'
@TeleReasonIds varchar(100),----'1|2|3|4|5'
@LoginId INT,
@flgActiveProductivityNorms tinyint=0,
@flgReportLevel smallint=0,---0--Default,140=Branch,145=SUBD
@flgDSETC TINYINT = 1 --1: TC, 2: DSE
AS
BEGIN

set @flgActiveProductivityNorms =0
Declare @NodeId int,@NodeType int,@RoleId int
select @NodeId=b.UserNodeId,@NodeType=b.UserNodeType,@RoleId=b.RoleId from tblSecUserLogin a join tblSecMapUserRoles b on a.userid=b.UserID where LoginId=@LoginId 


select distinct items  as SiteNodeId into #Sites from dbo.Split(@SiteNodeIds,'|') where items<>''

select distinct items  as TeleReasonId into #TeleReason from dbo.Split(@TeleReasonIds,'|') where items<>''


Create table #ADistributorList(DistNodeId int,DistNodeType int,DistrbutorCode varchar(50),DistributorName varchar(150),Cntry varchar(100),Region varchar(100),Branch varchar(100),Zone varchar(100),ASMArea varchar(100),SOArea varchar(100),SOAreaNodeId int,SOAreaNodeType int
,ASMAreaNodeId int,ASMAreaNodeType int
,ZoneNodeId int,ZoneNodeType int
,BranchNodeId int,BranchNodeType int
,RegionNodeId int,RegionNodeType int
,CntNodeId int,CntNodeType int
)

Insert into #ADistributorList
exec [spGetDistributorList] @LoginId


Create nonclustered index IDX_BranchList ON #ADistributorList(DistNodeId,DistNodeType) include(Cntry ,Region ,Branch,Zone ,ASMArea ,SOArea ,SOAreaNodeId ,SOAreaNodeType 
,ASMAreaNodeId ,ASMAreaNodeType 
,ZoneNodeId ,ZoneNodeType 
,BranchNodeId ,BranchNodeType 
,RegionNodeId ,RegionNodeType 
,CntNodeId ,CntNodeType )


if (select count(*) from #TeleReason)=0
	begin
		insert into #TeleReason
		select TeleReasonId from tblTeleReasonMstr
	end

	Create nonclustered index IDX_TeleReason ON #TeleReason(TeleReasonId)

CREATE TABLE #TeleCaller (UserId INT, TeleCallerId INT,DT DATE,Present INT)

print '1'
print CONVERT(varchar, dbo.fnGetCurrentDateTime(),108)

		;With ashcte as(
		select @FromDate as Dt
		union all
		select dateadd(dd,1,Dt) from ashcte where dt<@ToDate)


		INSERT INTO #TeleCaller
		select DISTINCT 0,TeleCallerId,Dt,0 as Present --into #TeleCaller 
		from [dbo].[tblTeleCallerMstr] a
		cross join ashcte d
		where a.flgActive=1

		--DELETE a from #TeleCaller a join tblTCAttendanceDetail b on a.TeleCallerId=b.TeleCallerId
		--join tblTCAttendanceMstr c on c.TCAttendId=b.TCAttendId and a.Dt=c.AttndDate
		--where b.Absent=1
		
	

print '2'
print CONVERT(varchar, dbo.fnGetCurrentDateTime(),108)

select * INTO #vwTeleCallerListForDay from vwTeleCallerListForDay where date between @FromDate and @ToDate
Create table #OrderData(TeleCallingId int,PrdNodeId int,OrderVal numeric(18,2), RoleID INT)
Create table #OrderGPValue(TeleCallingId int,flgOrderSource tinyint,GPValue int,FocBndNowAch INT,[FocBndSBFOrd] int,[SBDSBFOrd] INT)
Create table #InvGPValue(StoreId int,GPValue int)

Create nonclustered index IDX_vwTeleCallerListForDay1 ON #vwTeleCallerListForDay(tcnodeid)
Create nonclustered index IDX_vwTeleCallerListForDay2 ON #vwTeleCallerListForDay(distnodeid,distnodetype)
Create nonclustered index IDX_vwTeleCallerListForDay3 ON #vwTeleCallerListForDay(TeleReasonId)
Create nonclustered index IDX_vwTeleCallerListForDay4 ON #vwTeleCallerListForDay(StoreId)
Create clustered index IDX_vwTeleCallerListForDay5 ON #vwTeleCallerListForDay(TeleCallingId)
Create nonclustered index IDX_vwTeleCallerListForDay6 ON #vwTeleCallerListForDay(date)



print '3'
print CONVERT(varchar, dbo.fnGetCurrentDateTime(),108)

		INSERT INTO #OrderData
		select c.TeleCallingId,a.PrdNodeId,b.totorderval,u.roleID  
		from tblOrderDetail a(nolock) join tblordermaster b(nolock) on a.orderid=b.orderid
		join #vwTeleCallerListForDay c(nolock) on c.TeleCallingId=b.TeleCallingId
		join #ADistributorList l on l.DistNodeId=b.DistNodeId
		and l.DistNodeType=b.DistNodeType
		join #TeleReason t on t.TeleReasonId=c.TeleReasonId
		inner join tblsecUserLogin ul(nolock) on b.LoginIDIns = ul.loginID inner join tblsecuser(nolock) u on u.userid = ul.userid and b.flgOrderSource=1
		where (b.OrderDate between @FromDate and @ToDate) and a.OrderQty>0
		UNION
		select c.TeleCallingId,a.PrdNodeId,b.totorderval,u.roleID  
		from tblOrderDetail_history a(nolock) join tblOrderMaster_history b(nolock) on a.orderid=b.orderid
		join #vwTeleCallerListForDay c(nolock) on c.TeleCallingId=b.TeleCallingId
		join #ADistributorList l on l.DistNodeId=b.DistNodeId
		and l.DistNodeType=b.DistNodeType
		join #TeleReason t on t.TeleReasonId=c.TeleReasonId
		inner join tblsecUserLogin ul(nolock) on b.LoginIDIns = ul.loginID inner join tblsecuser(nolock) u on u.userid = ul.userid and b.flgOrderSource=1
		where (b.OrderDate between @FromDate and @ToDate) and a.OrderQty>0


--	insert into #OrderGPValue
--select TeleCallingId,flgOrderSource,sum(GPValue),SUM(FocBndNowAch),SUM([FocBndSBFOrd]),SUM([SBDSBFOrd])  from(
--select a.TeleCallingId,flgOrderSource,GPValue,[FocBndNowAch],[FocBndSBFOrd] ,[SBDSBFOrd] from tblOrderMaster a   where OrderDate between @FromDate and @ToDate 
--union all
--select a.TeleCallingId,flgOrderSource,GPValue,[FocBndNowAch],[FocBndSBFOrd] ,[SBDSBFOrd] from tblOrderMaster_History a   where OrderDate between @FromDate and @ToDate
-- --and @ToDate=convert(date,dbo.fnGetCurrentDateTime())
----and flgSBD=1
----union all
----select StoreID,SBDGroupid,0 from [tblINITSBDStoreFirstDayOfOrder] where FirstDayOfOrder between @FromDate and @ToDate and @ToDate<>convert(date,dbo.fnGetCurrentDateTime())
--)

--as a 
--group by TeleCallingId,flgOrderSource

--	insert into #InvGPValue


--select StoreID,Count(Distinct SBDGroupid) from [tblINITSBDStoreFirstDayOfSALE] where FirstDayOfSale between @FromDate and @ToDate 

--group by storeid


Create nonclustered index IDX_OrderData ON #OrderData(TeleCallingId,OrderVal) include(RoleId)

Create nonclustered index IDX_InvGPValue ON #InvGPValue(StoreId) include(GPValue)
Create nonclustered index IDX_OrderGPValue ON #OrderGPValue(TeleCallingId,flgOrderSource) include(GPValue,SBDSBFOrd,FocBndNowAch,FocBndSBFOrd)

print '4'
print CONVERT(varchar, dbo.fnGetCurrentDateTime(),108)

CREATE TABLE #TeleData(flgorder INT,DistNodeId INT,DistNodeType INT, [Tele Caller] VARCHAR(1000),[# Calls Planned] INT,[# Phone Available] INT, [# Calls Made] INT, [# Calls Picked] INT, [# Failed Calls] INT,[# Unproductive Calls] INT, [# Calls Productive] INT, [# Lines Ordered] INT, [Value Ordered] DECIMAL(18,2),[Order Golden Points Added] int
,[Order Golden Points SBF Added] int
,[FB Achieved in Order] int
,[# of FB SBF Ordered] int

, [Net Lines Supplied] DECIMAL(18,2), [Value Supplied] DECIMAL(18,2), [Return Value] DECIMAL(18,2), [Net Value Supplied] decimal(18,2),[Supplied Golden Points Added] int, StoreIdServed INT, [Throughput] numeric(20,2), Productivity numeric(5,2),[Call Conversion %] numeric(5,2),LPB numeric(5,1),[ThroughputPerTC]  numeric(20,2),TeleUserId int, Date date,StoreId int,ChannelId int,ThresholdAmount int,flgSupplyPending tinyint,
[# of Star Points] int,[# of 5 Star Calls] int, [Pending Supplied] decimal(18,2),StartTime datetime,ActualTimeInSec int,ProdTimeInSec int
)


print '5'
print CONVERT(varchar, dbo.fnGetCurrentDateTime(),108)


	select TeleCallingId,OrderVal into #ActOrderVal from #OrderData  group by TeleCallingId,OrderVal
	
Create nonclustered index IDX_ActOrderData ON #ActOrderVal(TeleCallingId) include(OrderVal)

		INSERT INTO #TeleData
		select  0,c.DistNodeId,c.DistNodeType, b.TeleCallerCode as  [Tele Caller],Count(*) as [# Calls Planned],
		sum(case when len(isnull(ContactNo,''))>=7 or flgCallStatus>0  then 1 else 0 end) as [# Phone Available],
		sum(case when callmade is not null then 1 else 0 end) as [# Calls Made],
		sum(case when flgCallStatus=3 and ReasonId=8 then 1 when flgCallStatus=2 then 1 when flgCallStatus=1 and isnull(rc.reasnfor,0)=2 then 1 else 0 end) as [# Calls Picked],
		sum(case when flgCallStatus=3 then 1 when flgCallStatus=1 and isnull(rc.reasnfor,0)=1 then 1 else 0 end) as [# Failed Calls],
		sum(case when (flgCallStatus=1 and isnull(rc.reasnfor,0)=2)  or (@flgActiveProductivityNorms=1 and od.OrderVal<th.ThresholdAmount) then 1 else 0 end) as [# Unproductive Calls],
		sum(case when flgCallStatus=2 then case when (@flgActiveProductivityNorms=1 and od.OrderVal>=th.ThresholdAmount) or @flgActiveProductivityNorms=0 then 1 else 0 end else 0 end) as [# Calls Productive],
		(select count(c1.PrdNodeId) from #OrderData c1 where c1.TeleCallingId=a.TeleCallingId and c1.RoleID<>10) as [# Lines Ordered],
		isnull(sum(od.OrderVal),0) AS [Value Ordered],
		isnull(sum(gp.GPValue),0) AS [Order Golden Points],
		isnull(sum(gp.SBDSBFOrd),0) AS [GP SBF Added],
		isnull(sum(gp.FocBndNowAch),0) AS [FB Achieved in Order],
		isnull(sum(gp.FocBndSBFOrd),0) AS [# of FB SBF Ordered],
		--isnull((gpach1.GoldenPoints),0) +isnull((gpach.GPValue),0) AS [Order Golden Points],
		--isnull((gpsuppach.GoldenPoints),0),
		(select Count(*) from tblTeleCallingInvDetail c1(nolock) where c1.TeleCallingId=a.TeleCallingId and Qty>0 AND c1.flgOrderSource=1  and StatusId=5)  AS [Net Lines Supplied],
		(select isnull(sum(c1.RETAILING),0) from tblTeleCallingInvDetail c1(nolock) where c1.TeleCallingId=a.TeleCallingId AND c1.flgOrderSource=1 and StatusId=5)  AS [Value Supplied],
		0  AS [Return Value],
		(select isnull(sum(c1.RETAILING),0) from tblTeleCallingInvDetail c1(nolock) where c1.TeleCallingId=a.TeleCallingId AND c1.flgOrderSource=1 and StatusId=5)  AS [Net Value Supplied],
		isnull(sum(igp.GPValue),0) AS [Inv Golden Points]
		,a.StoreId StoreIdServed,0,0,0,0,0,a.TCNodeId,a.Date,a.StoreId,a.ChannelId,0,0,
		sum(isnull(a.NoOfStarsAch,0)),sum(case when isnull(a.NoOfStarsAch,0)=5 then 1 else 0 end),
		(select isnull(sum(c1.RETAILING),0) from tblTeleCallingInvDetail c1(nolock) where c1.TeleCallingId=a.TeleCallingId AND c1.flgOrderSource=1 and StatusId in(1,3))  AS [Value Supplied],
		Min(a.CallStartDate),Max(case when a.CallStartDate<a.CallMade and  ((flgCallStatus=1 and isnull(rc.reasnfor,0)=2) or flgCallStatus=2) then DATEDIFF(ss,CallStartDate,CallMade) else 0 end),Max(case when a.CallStartDate<a.CallMade and  ( flgCallStatus=2) then DATEDIFF(ss,CallStartDate,CallMade) else 0 end)
		from #vwTeleCallerListForDay a(nolock) left join tblTeleCallerMstr b on a.TCNodeId=b.TeleCallerId 
			join #ADistributorList c on c.DistNodeId=a.DistNodeId
			and c.DistNodeType=a.DistNodeType
			join #TeleReason t on t.TeleReasonId=a.TeleReasonId
			left join #ActOrderVal od on od.TeleCallingId=a.TeleCallingId
			left join #OrderGPValue gp on gp.TeleCallingId=a.TeleCallingId and gp.flgOrderSource in(1,0)
			left join #InvGPValue igp on igp.StoreId=a.StoreId 
			--left join #OrderGPValue gpach on gpach.StoreId=a.StoreId and gpach.flgOrderSource =1
			--left join [tblINITSBDStoreOrderGoldenPoints] gpach1 on gpach1.StoreId=a.StoreId
			--left join [tblINITSBDStoreInvoiceGoldenPoints] gpsuppach on gpsuppach.StoreId=a.StoreId
			 left join tblReasonCodeMstr rc on rc.reasoncodeid=a.reasonid
			left join tblChannelWiseProductivityThreshold th on th.ChannelId=a.ChannelId
			and a.Date between th.FromDate and th.ToDate
			where a.date between @FromDate and @ToDate and IsUsed<7
		group by a.TeleCallingId,b.TeleCallerCode,c.DistNodeId,c.DistNodeType
		,a.TCNodeId,a.Date,a.StoreId,a.ChannelId
		order by [# Calls Planned] desc
	--SELECT * FROM #vwTeleCallerListForDay
	--select * from #ADistributorList
print '6'
print CONVERT(varchar, dbo.fnGetCurrentDateTime(),108)

Update a set ThresholdAmount=th.ThresholdAmount from #TeleData a join  tblChannelWiseProductivityThreshold th on th.ChannelId=a.ChannelId

		 and convert(date,getdate()) between th.FromDate and th.ToDate

Update a set Present=1 from #TeleCaller a join (select distinct TeleUserId from #TeleData where [# Calls Made] >0) b on a.TeleCallerId=b.TeleUserId

--Update a set Present=1 from #TeleCaller a join #TeleData b on a.UserId=b.TeleUserId

Update #TeleData set Productivity= convert(numeric(5,2),(([# Calls Productive])*100)/([# Calls Made])) where [# Calls Made]>0

Update #TeleData set [Call Conversion %]= convert(numeric(5,2),(([# Calls Productive])*100)/([# Calls Picked])) where [# Calls Picked]>0

Update #TeleData set [Throughput]= convert(numeric(20,2),(([Value Ordered]))/([# Calls Productive])) where [# Calls Productive]>0

Update #TeleData set LPB= convert(numeric(5,1),(([# Lines Ordered])))/([# Calls Productive]) where [# Calls Productive]>0

--SELECT * FROM #TeleData

--Update #TeleData set LPB= convert(numeric(5,1),(([# Lines Ordered])))/([# Calls Productive])
--where [# Calls Productive]>0
UPDATE #TeleData SET StoreIdServed=0 WHERE [Value Supplied]=0
--select * from #TeleData

Update #TeleData set  flgSupplyPending =1 where  [Pending Supplied]>0

create table #text(id int identity(1,1), txt VARCHAR(1000), [VALUE] VARCHAR(1000), Color varchar(100))
print '7'
print CONVERT(varchar, dbo.fnGetCurrentDateTime(),108)
INSERT INTO #text
select 'Calls Planned'AS Txt,convert(varchar,sum([# Calls Planned])) as Value,'bfbfbf' as Color from #TeleData 
union all
select 'Calls Made'AS Txt,convert(varchar,sum([# Calls Made])) as Value,'8ab96a' as Color from #TeleData 
union all
select 'Failed Calls'AS Txt,convert(varchar,sum([# Failed Calls])) as Value,'ffb9b9' as Color from #TeleData 
union all
select 'UnProductive Calls'AS Txt,convert(varchar,sum([# Unproductive Calls])) as Value,'ffb9b9' as Color from #TeleData 
union all
select 'Productive Calls'AS Txt,convert(varchar,sum([# Calls Productive])) as Value,'9856c9' as Color from #TeleData 
union all
select 'Total Order Value'AS Txt,convert(varchar,sum([Value Ordered])) as Value,'d3824b' as Color from #TeleData 
union all
select 'Total Lines'AS Txt,convert(varchar,sum([# Lines Ordered])) as Value,'ffc000' as Color from #TeleData
union all
select '# of Distributor'AS Txt,convert(varchar,Count(*)) as Value,'d5fca0' as Color from   
#ADistributorList b WHERE EXISTS(SELECT * FROM #TeleData WHERE DistNodeId=B.DistNodeId)

print '8'
print CONVERT(varchar, dbo.fnGetCurrentDateTime(),108)
--if(@flgDSETC = 1)
	INSERT INTO #text
	select '# of Active TES/Total TES'AS Txt,convert(varchar,Sum(Present))+'/'+convert(varchar,count(*)) as Value,'' as Color from #TeleCaller
--ELSE
--	INSERT INTO #text
--	select '# of Active DSE/Total DSE'AS Txt,convert(varchar,Sum(Present))+'/'+convert(varchar,count(*)) as Value,'' as Color from #TeleCaller

select txt,value,color from #text 

Create table #FinalReport(Lvl tinyint,NodeId int,NodeType int,PNodeId int,PNodeType int, [Total\Cntry\Region\RSH\ASM\SO\DB] varchar(500),
[# Of TES^1] int,
[# Calls Planned^1] int,[# Phone Available^1] int,
[# Calls Made^1] int,
[# Calls Picked^1] int, [# Calls Productive^1] int 
,[# Lines Ordered^1] int
 ,[Value Ordered^1] numeric(18,2)
 ,[Throughput^1] numeric(20,2)
	  ,[Productivity^1] varchar(100)
	  , 
 [Call Conversion^1] varchar(100) 
,[LPO^1]  numeric(5,1)
,[Throughput Per TES^1] numeric(20,2)

	  ,[Net Lines Supplied^2] int
	  ,[Value Supplied^2] numeric(18,2)
	  ,[Return Value^2] numeric(18,2)
	  ,[Net Value Supplied^2] numeric(18,2)
	  ,[# Stores Delivered^2] int
 ,[# Stores Pending Dlvry^2] int
 ,[Throughput^2] numeric(20,2)
	  ,[Productivity^2] varchar(100)
	   
,[LPB^2]  numeric(5,1)
,[Throughput Per TES^2] numeric(20,2)
,[Cutover %^2] varchar(100)
,[SRN %^2] varchar(100)
,[Start Time^1] varchar(100)
,[Actual Call Time in Min^1] varchar(100)
,[Average Time Per Productive Call in Min^1] varchar(100)
)

print '9'
print CONVERT(varchar, dbo.fnGetCurrentDateTime(),108)
--select isnull(sum(GPOrderd),0) from #TotStoreGP
insert into #FinalReport
select 1,0,0,-1,-1,'Total',
--COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)),

COUNT(Distinct  case when [Tele Caller] is not null then  convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106) end),

sum([# Calls Planned]),sum([# Phone Available]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive])

,sum([# Lines Ordered]),
sum([Value Ordered]),

convert(numeric(20,2),
case when sum([# Calls Productive])>0 then 
(sum([Value Ordered]))/sum([# Calls Productive]) else 0 end),Convert(varchar,convert(numeric(15,0),

case when sum([# Calls Made])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Made]) else 0 end))+' %'

,Convert(varchar,convert(numeric(15,0),
case when sum([# Calls Picked])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Picked]) else 0 end))+' %'

,
case when sum([# Calls Productive])>0 then 
convert(float,sum([# Lines Ordered]))/sum([# Calls Productive]) else 0 end,convert(numeric(20,2)

,
case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Ordered]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end)

,Sum([Net Lines Supplied]),Sum([Value Supplied]),Sum([Return Value]),Sum([Net Value Supplied])
,0,0 as [Productive Stores],
0 as [Throughput],

'' as [Productivity],0 as LPB,

(case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Supplied]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end) as [Throughput Per TES],

Convert(varchar,convert(numeric(15,0),
case when sum([Value Ordered])>0 then (((sum([Value Ordered])-sum([Value Supplied]))*100)/sum([Value Ordered])) else 0 end)) [Cutover%], 


Convert(varchar,convert(numeric(15,0),
case when sum([Value Supplied])>0 then (sum([Return Value])*100)/sum([Value Supplied]) else 0 end)) [SRN%],format(Min(StartTime),'HH:mm'),sum(ActualTimeInSec)/60,Avg(case when isnull(ProdTimeInSec,0)<>0 then ProdTimeInSec end)/60

 from #TeleData 
 
 UPDATE A SET A.[# Stores Delivered^2]=B.StoresServed FROM #FinalReport A,(SELECT COUNT(DISTINCT StoreIdServed) StoresServed FROM #TeleData WHERE StoreIdServed>0) B WHERE A.NodeType=0
 
 UPDATE A SET A.[# Stores Pending Dlvry^2]=B.StoresServed FROM #FinalReport A,(SELECT COUNT(DISTINCT StoreId) StoresServed FROM #TeleData WHERE flgSupplyPending>0) B WHERE A.NodeType=0
 
 
 print '10'
print CONVERT(varchar, dbo.fnGetCurrentDateTime(),108)
insert into #FinalReport
select 2,b.CntNodeId,b.CntNodeType,0,0,b.Cntry,COUNT(Distinct case when [Tele Caller] is not null then  convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106) end),sum([# Calls Planned]),sum([# Phone Available]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive])
,sum([# Lines Ordered]),
sum([Value Ordered])
,convert(numeric(20,2),
case when sum([# Calls Productive])>0 then 
(sum([Value Ordered]))/sum([# Calls Productive]) else 0 end),Convert(varchar,convert(numeric(15,0),

case when sum([# Calls Made])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Made]) else 0 end))+' %'

,Convert(varchar,convert(numeric(15,0),
case when sum([# Calls Picked])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Picked]) else 0 end))+' %'

,
case when sum([# Calls Productive])>0 then 
convert(float,sum([# Lines Ordered]))/sum([# Calls Productive]) else 0 end,convert(numeric(20,2)

,
case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Ordered]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end)

,Sum([Net Lines Supplied]),Sum([Value Supplied]),Sum([Return Value]),Sum([Net Value Supplied])

,0,0 as [Productive Stores],
0 as [Throughput],

'' as [Productivity],0 as LPB,

(case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Supplied]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end) as [Throughput Per TES],

Convert(varchar,convert(numeric(15,0),
case when sum([Value Ordered])>0 then (((sum([Value Ordered])-sum([Value Supplied]))*100)/sum([Value Ordered])) else 0 end)) [Cutover%], 

Convert(varchar,convert(numeric(15,0),
case when sum([Value Supplied])>0 then (sum([Return Value])*100)/sum([Value Supplied]) else 0 end)) [SRN%]
,format(Min(StartTime),'HH:mm'),sum(ActualTimeInSec)/60,Avg(case when isnull(ProdTimeInSec,0)<>0 then ProdTimeInSec end)/60

 from #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType group by b.CntNodeId,b.CntNodeType,b.Cntry
 ORDER BY Cntry

 UPDATE A SET A.[# Stores Delivered^2]=B.StoresServed FROM #FinalReport A INNER JOIN (SELECT CntNodeId,CntNodeType,COUNT(DISTINCT StoreIdServed) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE StoreIdServed>0 GROUP BY CntNodeId,CntNodeType) B ON A.NodeId=B.CntNodeId AND A.NodeType=B.CntNodeType
 
 
 UPDATE A SET A.[# Stores Pending Dlvry^2]=B.StoresServed  FROM #FinalReport A INNER JOIN (SELECT CntNodeId,CntNodeType,COUNT(DISTINCT StoreId) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE flgSupplyPending>0 GROUP BY CntNodeId,CntNodeType) B ON A.NodeId=B.CntNodeId AND A.NodeType=B.CntNodeType
 


 ----------------------------------Region
 insert into #FinalReport
select 3,b.RegionNodeId,b.RegionNodeType,b.CntNodeId,b.CntNodeType,b.Region,COUNT(Distinct case when [Tele Caller] is not null then  convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106) end),sum([# Calls Planned]),sum([# Phone Available]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive])
,sum([# Lines Ordered]),
sum([Value Ordered])
,convert(numeric(20,2),
case when sum([# Calls Productive])>0 then 
(sum([Value Ordered]))/sum([# Calls Productive]) else 0 end),Convert(varchar,convert(numeric(15,0),

case when sum([# Calls Made])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Made]) else 0 end))+' %'

,Convert(varchar,convert(numeric(15,0),
case when sum([# Calls Picked])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Picked]) else 0 end))+' %'

,
case when sum([# Calls Productive])>0 then 
convert(float,sum([# Lines Ordered]))/sum([# Calls Productive]) else 0 end,convert(numeric(20,2)

,
case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Ordered]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end)

,Sum([Net Lines Supplied]),Sum([Value Supplied]),Sum([Return Value]),Sum([Net Value Supplied])

,0,0 as [Productive Stores],
0 as [Throughput],

'' as [Productivity],0 as LPB,

(case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Supplied]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end) as [Throughput Per TES],

Convert(varchar,convert(numeric(15,0),
case when sum([Value Ordered])>0 then (((sum([Value Ordered])-sum([Value Supplied]))*100)/sum([Value Ordered])) else 0 end)) [Cutover%], 

Convert(varchar,convert(numeric(15,0),
case when sum([Value Supplied])>0 then (sum([Return Value])*100)/sum([Value Supplied]) else 0 end)) [SRN%]
,format(Min(StartTime),'HH:mm'),sum(ActualTimeInSec)/60,Avg(case when isnull(ProdTimeInSec,0)<>0 then ProdTimeInSec end)/60

 from #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType group by b.RegionNodeId,b.RegionNodeType,b.CntNodeId,b.CntNodeType,b.Region
 ORDER BY Region

 UPDATE A SET A.[# Stores Delivered^2]=B.StoresServed FROM #FinalReport A INNER JOIN (SELECT RegionNodeId,RegionNodeType,COUNT(DISTINCT StoreIdServed) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE StoreIdServed>0 GROUP BY RegionNodeId,RegionNodeType) B ON A.NodeId=B.RegionNodeId AND A.NodeType=B.RegionNodeType
 
 
 UPDATE A SET A.[# Stores Pending Dlvry^2]=B.StoresServed  FROM #FinalReport A INNER JOIN (SELECT RegionNodeId,RegionNodeType,COUNT(DISTINCT StoreId) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE flgSupplyPending>0 GROUP BY RegionNodeId,RegionNodeType) B ON A.NodeId=B.RegionNodeId AND A.NodeType=B.RegionNodeType




 ----------------------------------RSH
 insert into #FinalReport
select 4,b.BranchNodeId,b.BranchNodeType,b.RegionNodeId,b.RegionNodeType,b.Branch,COUNT(Distinct case when [Tele Caller] is not null then  convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106) end),sum([# Calls Planned]),sum([# Phone Available]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive])
,sum([# Lines Ordered]),
sum([Value Ordered])
,convert(numeric(20,2),
case when sum([# Calls Productive])>0 then 
(sum([Value Ordered]))/sum([# Calls Productive]) else 0 end),Convert(varchar,convert(numeric(15,0),

case when sum([# Calls Made])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Made]) else 0 end))+' %'

,Convert(varchar,convert(numeric(15,0),
case when sum([# Calls Picked])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Picked]) else 0 end))+' %'

,
case when sum([# Calls Productive])>0 then 
convert(float,sum([# Lines Ordered]))/sum([# Calls Productive]) else 0 end,convert(numeric(20,2)

,
case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Ordered]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end)

,Sum([Net Lines Supplied]),Sum([Value Supplied]),Sum([Return Value]),Sum([Net Value Supplied])

,0,0 as [Productive Stores],
0 as [Throughput],

'' as [Productivity],0 as LPB,

(case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Supplied]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end) as [Throughput Per TES],

Convert(varchar,convert(numeric(15,0),
case when sum([Value Ordered])>0 then (((sum([Value Ordered])-sum([Value Supplied]))*100)/sum([Value Ordered])) else 0 end)) [Cutover%], 

Convert(varchar,convert(numeric(15,0),
case when sum([Value Supplied])>0 then (sum([Return Value])*100)/sum([Value Supplied]) else 0 end)) [SRN%]
,format(Min(StartTime),'HH:mm'),sum(ActualTimeInSec)/60,Avg(case when isnull(ProdTimeInSec,0)<>0 then ProdTimeInSec end)/60

 from #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType group by b.BranchNodeId,b.BranchNodeType,b.RegionNodeId,b.RegionNodeType,b.Branch
 ORDER BY Branch

 UPDATE A SET A.[# Stores Delivered^2]=B.StoresServed FROM #FinalReport A INNER JOIN (SELECT BranchNodeId,BranchNodeType,COUNT(DISTINCT StoreIdServed) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE StoreIdServed>0 GROUP BY BranchNodeId,BranchNodeType) B ON A.NodeId=B.BranchNodeId AND A.NodeType=B.BranchNodeType
 
 
 UPDATE A SET A.[# Stores Pending Dlvry^2]=B.StoresServed  FROM #FinalReport A INNER JOIN (SELECT BranchNodeId,BranchNodeType,COUNT(DISTINCT StoreId) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE flgSupplyPending>0 GROUP BY BranchNodeId,BranchNodeType) B ON A.NodeId=B.BranchNodeId AND A.NodeType=B.BranchNodeType



 
 ----------------------------------RSH
 insert into #FinalReport
select 5,b.ZoneNodeId,b.ZoneNodeType,b.BranchNodeId,b.BranchNodeType,b.Zone,COUNT(Distinct case when [Tele Caller] is not null then  convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106) end),sum([# Calls Planned]),sum([# Phone Available]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive])
,sum([# Lines Ordered]),
sum([Value Ordered])
,convert(numeric(20,2),
case when sum([# Calls Productive])>0 then 
(sum([Value Ordered]))/sum([# Calls Productive]) else 0 end),Convert(varchar,convert(numeric(15,0),

case when sum([# Calls Made])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Made]) else 0 end))+' %'

,Convert(varchar,convert(numeric(15,0),
case when sum([# Calls Picked])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Picked]) else 0 end))+' %'

,
case when sum([# Calls Productive])>0 then 
convert(float,sum([# Lines Ordered]))/sum([# Calls Productive]) else 0 end,convert(numeric(20,2)

,
case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Ordered]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end)

,Sum([Net Lines Supplied]),Sum([Value Supplied]),Sum([Return Value]),Sum([Net Value Supplied])

,0,0 as [Productive Stores],
0 as [Throughput],

'' as [Productivity],0 as LPB,

(case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Supplied]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end) as [Throughput Per TES],

Convert(varchar,convert(numeric(15,0),
case when sum([Value Ordered])>0 then (((sum([Value Ordered])-sum([Value Supplied]))*100)/sum([Value Ordered])) else 0 end)) [Cutover%], 

Convert(varchar,convert(numeric(15,0),
case when sum([Value Supplied])>0 then (sum([Return Value])*100)/sum([Value Supplied]) else 0 end)) [SRN%]
,format(Min(StartTime),'HH:mm'),sum(ActualTimeInSec)/60,Avg(case when isnull(ProdTimeInSec,0)<>0 then ProdTimeInSec end)/60

 from #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType group by b.BranchNodeId,b.BranchNodeType,b.ZoneNodeId,b.ZoneNodeType,b.Zone
 ORDER BY Zone

 UPDATE A SET A.[# Stores Delivered^2]=B.StoresServed FROM #FinalReport A INNER JOIN (SELECT ZoneNodeId,ZoneNodeType,COUNT(DISTINCT StoreIdServed) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE StoreIdServed>0 GROUP BY ZoneNodeId,ZoneNodeType) B ON A.NodeId=B.ZoneNodeId AND A.NodeType=B.ZoneNodeType
 
 
 UPDATE A SET A.[# Stores Pending Dlvry^2]=B.StoresServed  FROM #FinalReport A INNER JOIN (SELECT ZoneNodeId,ZoneNodeType,COUNT(DISTINCT StoreId) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE flgSupplyPending>0 GROUP BY ZoneNodeId,ZoneNodeType) B ON A.NodeId=B.ZoneNodeId AND A.NodeType=B.ZoneNodeType


 
 ----------------------------------ASM
 insert into #FinalReport
select 6,b.ASMAreaNodeId,b.ASMAreaNodeType,b.ZoneNodeId,b.ZoneNodeType,b.ASMArea,COUNT(Distinct case when [Tele Caller] is not null then  convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106) end),sum([# Calls Planned]),sum([# Phone Available]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive])
,sum([# Lines Ordered]),
sum([Value Ordered])
,convert(numeric(20,2),
case when sum([# Calls Productive])>0 then 
(sum([Value Ordered]))/sum([# Calls Productive]) else 0 end),Convert(varchar,convert(numeric(15,0),

case when sum([# Calls Made])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Made]) else 0 end))+' %'

,Convert(varchar,convert(numeric(15,0),
case when sum([# Calls Picked])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Picked]) else 0 end))+' %'

,
case when sum([# Calls Productive])>0 then 
convert(float,sum([# Lines Ordered]))/sum([# Calls Productive]) else 0 end,convert(numeric(20,2)

,
case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Ordered]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end)

,Sum([Net Lines Supplied]),Sum([Value Supplied]),Sum([Return Value]),Sum([Net Value Supplied])

,0,0 as [Productive Stores],
0 as [Throughput],

'' as [Productivity],0 as LPB,

(case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Supplied]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end) as [Throughput Per TES],

Convert(varchar,convert(numeric(15,0),
case when sum([Value Ordered])>0 then (((sum([Value Ordered])-sum([Value Supplied]))*100)/sum([Value Ordered])) else 0 end)) [Cutover%], 

Convert(varchar,convert(numeric(15,0),
case when sum([Value Supplied])>0 then (sum([Return Value])*100)/sum([Value Supplied]) else 0 end)) [SRN%]

,format(Min(StartTime),'HH:mm'),sum(ActualTimeInSec)/60,Avg(case when isnull(ProdTimeInSec,0)<>0 then ProdTimeInSec end)/60
 from #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType group by b.ASMAreaNodeId,b.ASMAreaNodeType,b.ZoneNodeId,b.ZoneNodeType,b.ASMArea
 ORDER BY ASMArea

 UPDATE A SET A.[# Stores Delivered^2]=B.StoresServed FROM #FinalReport A INNER JOIN (SELECT ASMAreaNodeId,ASMAreaNodeType,COUNT(DISTINCT StoreIdServed) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE StoreIdServed>0 GROUP BY ASMAreaNodeId,ASMAreaNodeType) B ON A.NodeId=B.ASMAreaNodeId AND A.NodeType=B.ASMAreaNodeType
 
 
 UPDATE A SET A.[# Stores Pending Dlvry^2]=B.StoresServed  FROM #FinalReport A INNER JOIN (SELECT ASMAreaNodeId,ASMAreaNodeType,COUNT(DISTINCT StoreId) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE flgSupplyPending>0 GROUP BY ASMAreaNodeId,ASMAreaNodeType) B ON A.NodeId=B.ASMAreaNodeId AND A.NodeType=B.ASMAreaNodeType



 
 ----------------------------------SO
 insert into #FinalReport
select 7,b.SOAreaNodeId,b.SOAreaNodeType,b.ASMAreaNodeId,b.ASMAreaNodeType,b.SOArea,COUNT(Distinct case when [Tele Caller] is not null then  convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106) end),sum([# Calls Planned]),sum([# Phone Available]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive])
,sum([# Lines Ordered]),
sum([Value Ordered])
,convert(numeric(20,2),
case when sum([# Calls Productive])>0 then 
(sum([Value Ordered]))/sum([# Calls Productive]) else 0 end),Convert(varchar,convert(numeric(15,0),

case when sum([# Calls Made])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Made]) else 0 end))+' %'

,Convert(varchar,convert(numeric(15,0),
case when sum([# Calls Picked])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Picked]) else 0 end))+' %'

,
case when sum([# Calls Productive])>0 then 
convert(float,sum([# Lines Ordered]))/sum([# Calls Productive]) else 0 end,convert(numeric(20,2)

,
case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Ordered]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end)

,Sum([Net Lines Supplied]),Sum([Value Supplied]),Sum([Return Value]),Sum([Net Value Supplied])

,0,0 as [Productive Stores],
0 as [Throughput],

'' as [Productivity],0 as LPB,

(case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Supplied]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end) as [Throughput Per TES],

Convert(varchar,convert(numeric(15,0),
case when sum([Value Ordered])>0 then (((sum([Value Ordered])-sum([Value Supplied]))*100)/sum([Value Ordered])) else 0 end)) [Cutover%], 

Convert(varchar,convert(numeric(15,0),
case when sum([Value Supplied])>0 then (sum([Return Value])*100)/sum([Value Supplied]) else 0 end)) [SRN%]
,format(Min(StartTime),'HH:mm'),sum(ActualTimeInSec)/60,Avg(case when isnull(ProdTimeInSec,0)<>0 then ProdTimeInSec end)/60

 from #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType group by b.SOAreaNodeId,b.SOAreaNodeType,b.ASMAreaNodeId,b.ASMAreaNodeType,b.SOArea
 ORDER BY SOArea

 UPDATE A SET A.[# Stores Delivered^2]=B.StoresServed FROM #FinalReport A INNER JOIN (SELECT SOAreaNodeId,SOAreaNodeType,COUNT(DISTINCT StoreIdServed) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE StoreIdServed>0 GROUP BY SOAreaNodeId,SOAreaNodeType) B ON A.NodeId=B.SOAreaNodeId AND A.NodeType=B.SOAreaNodeType
 
 
 UPDATE A SET A.[# Stores Pending Dlvry^2]=B.StoresServed  FROM #FinalReport A INNER JOIN (SELECT SOAreaNodeId,SOAreaNodeType,COUNT(DISTINCT StoreId) StoresServed FROM #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType WHERE flgSupplyPending>0 GROUP BY SOAreaNodeId,SOAreaNodeType) B ON A.NodeId=B.SOAreaNodeId AND A.NodeType=B.SOAreaNodeType


 
 ----------------------------------Distributor
 insert into #FinalReport
select 8,b.DistNodeId,b.DistNodeType,b.SOAreaNodeId,b.SOAreaNodeType,b.DistributorName+' ['+b.DistrbutorCode+']',COUNT(Distinct case when [Tele Caller] is not null then  convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106) end),sum([# Calls Planned]),sum([# Phone Available]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive])
,sum([# Lines Ordered]),
sum([Value Ordered])
,convert(numeric(20,2),
case when sum([# Calls Productive])>0 then 
(sum([Value Ordered]))/sum([# Calls Productive]) else 0 end),Convert(varchar,convert(numeric(15,0),

case when sum([# Calls Made])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Made]) else 0 end))+' %'

,Convert(varchar,convert(numeric(15,0),
case when sum([# Calls Picked])>0 then 
convert(float,(sum([# Calls Productive])*100))/sum([# Calls Picked]) else 0 end))+' %'

,
case when sum([# Calls Productive])>0 then 
convert(float,sum([# Lines Ordered]))/sum([# Calls Productive]) else 0 end,convert(numeric(20,2)

,
case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Ordered]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end)

,Sum([Net Lines Supplied]),Sum([Value Supplied]),Sum([Return Value]),Sum([Net Value Supplied])

,0,0 as [Productive Stores],
0 as [Throughput],

'' as [Productivity],0 as LPB,

(case when COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106))>0 then 
(sum([Value Supplied]))/COUNT(Distinct convert(varchar,TeleUserId)+'-'+convert(varchar,Date,106)) else 0 end) as [Throughput Per TES],

Convert(varchar,convert(numeric(15,0),
case when sum([Value Ordered])>0 then (((sum([Value Ordered])-sum([Value Supplied]))*100)/sum([Value Ordered])) else 0 end)) [Cutover%], 

Convert(varchar,convert(numeric(15,0),
case when sum([Value Supplied])>0 then (sum([Return Value])*100)/sum([Value Supplied]) else 0 end)) [SRN%]
,format(Min(StartTime),'HH:mm'),sum(ActualTimeInSec)/60,Avg(case when isnull(ProdTimeInSec,0)<>0 then ProdTimeInSec end)/60

 from #TeleData a join #ADistributorList b on a.DistNodeId=b.DistNodeId
 and a.DistNodeType=b.DistNodeType group by b.DistNodeId,b.DistNodeType,b.SOAreaNodeId,b.SOAreaNodeType,b.DistributorName,b.DistrbutorCode
 ORDER BY b.DistributorName

 UPDATE A SET A.[# Stores Delivered^2]=B.StoresServed FROM #FinalReport A INNER JOIN (SELECT DistNodeId,DistNodeType,COUNT(DISTINCT StoreIdServed) StoresServed FROM #TeleData a  WHERE StoreIdServed>0 GROUP BY DistNodeId,DistNodeType) B ON A.NodeId=B.DistNodeId AND A.NodeType=B.DistNodeType
 
 
 UPDATE A SET A.[# Stores Pending Dlvry^2]=B.StoresServed  FROM #FinalReport A INNER JOIN (SELECT DistNodeId,DistNodeType,COUNT(DISTINCT StoreId) StoresServed FROM #TeleData a  WHERE flgSupplyPending>0 GROUP BY DistNodeId,DistNodeType) B ON A.NodeId=B.DistNodeId AND A.NodeType=B.DistNodeType

 UPDATE A SET [Throughput^2]=(case when [# Stores Delivered^2]>0 then 
([Net Value Supplied^2])/[# Stores Delivered^2] else 0 end),

[Productivity^2]=convert(varchar,convert(numeric(10,0),case when [# Phone Available^1]>0 then 
convert(float,([# Stores Delivered^2]*100))/[# Phone Available^1] else 0 end))+' %',
[LPB^2]=
case when [# Stores Delivered^2]>0 then 
convert(float,[Net Lines Supplied^2])/[# Stores Delivered^2] else 0 end

 FROM #FinalReport A

 print '12'
print CONVERT(varchar, dbo.fnGetCurrentDateTime(),108)
 SELECT Lvl ,NodeId ,NodeType ,PNodeId ,PNodeType , [Total\Cntry\Region\RSH\ASM\SO\DB] ,
[# Of TES^1] ,
[# Calls Planned^1] ,[# Phone Available^1] ,
[# Calls Made^1] ,
[# Calls Picked^1] , [# Calls Productive^1] ,[Start Time^1],[Actual Call Time in Min^1],[Average Time Per Productive Call in Min^1]
,[# Lines Ordered^1] 
 ,[Value Ordered^1] 
 ,[Throughput^1] 
	  ,[Productivity^1] 
	  , 
 [Call Conversion^1] 
,[LPO^1]  
,[Throughput Per TES^1] 

	  ,[Value Supplied^2] 
	  ,[# Stores Delivered^2] 
  FROM #FinalReport order by lvl,[Total\Cntry\Region\RSH\ASM\SO\DB]
  
  
  --SELECT * FROM #FinalReport WHERE Lvl=2
    --SELECT * FROM #FinalReport WHERE Lvl=7 order by lvl,[Total\Cntry\Region\RSH\ASM\SO\DB]
--select  TESSiteName as [TES Site],[Tele Caller],[# Calls Planned],[# Phone Available],[# Calls Made],[# Calls Picked],[# Calls Productive],[# Lines Ordered],[Value Ordered],[Lines Supplied],
--[# Stores Served],[Throughput],CONVERT(VARCHAR,Productivity)+'%' AS Productivity,Convert(varchar,[Call Conversion %])+'%' as [Call Conversion %],LPB from #FinalReport order by TESSiteName,flgOrder
  --select * from #TeleData
  END
