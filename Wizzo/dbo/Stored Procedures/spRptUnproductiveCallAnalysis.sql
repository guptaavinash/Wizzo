

--select * from tblReasonCodeMstr 
--delete tblReasonCodeMstr  where ReasonCodeID=31
--select * from vwSalesHierarchy where SiteName='rajasthan'

--select * from tblReasonCodeMstr where 

--select * from tblTeleCallerListForDay where isnull(ContactNo,'') in('','0') and CallMade is not null and flgCallStatus<>1
--[spRptUnproductiveCallAnalysis] '8-apr-2022','8-apr-2022','','',95
CREATE procedure [dbo].[spRptUnproductiveCallAnalysis]
@FromDate date,
@ToDate date,
@SiteNodeIds varchar(100),-----'1|2|3|4|5'
@TeleReasonIds varchar(100),----'1|2|3|4|5'
@LoginId INT,
@SectorIds varchar(100)=''
AS
BEGIN


Declare @NodeId int,@NodeType int,@RoleId int
select @NodeId=b.UserNodeId,@NodeType=b.UserNodeType,@RoleId=b.RoleId from tblSecUserLogin a join tblSecMapUserRoles b on a.userid=b.UserID where LoginId=@LoginId 


select distinct items  as SiteNodeId into #Sites from dbo.Split(@SiteNodeIds,'|') where items<>''

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
end

	if (select count(*) from #Sector)=0
	begin
		insert into #Sector
		select SectorId from tblMstrSector
	end

;With ashcte as(

select @FromDate as Dt
union all
select dateadd(dd,1,Dt) from ashcte where dt<@ToDate)

select u.UserId,TeleCallerId,Dt,0 as Present into #TeleCaller from [dbo].[tblTeleCallerMstr] a
join tblSecMapUserRoles u on u.UserNodeId=a.TeleCallerId
and u.UserNodeType=a.NodeType
 
cross join ashcte d
where a.flgActive=1

DELETE a from #TeleCaller a join tblTCAttendanceDetail b on a.TeleCallerId=b.TeleCallerId
join tblTCAttendanceMstr c on c.TCAttendId=b.TCAttendId and a.Dt=c.AttndDate
where b.Absent=1

--Create table #OrderData(TeleCallingId int,PrdNodeId int,NetLineOrderVal numeric(18,2))


select * into #vwTeleCallerListForDay from vwTeleCallerListForDay where date between @FromDate and @ToDate
and IsUsed<7
print 'ffdadfdsfads'
select SOAREANodeId,SOAREANodeType,
0 as flgorder,DistNodeId,DistNodeType, [Tele Caller],SUM([# Calls Planned]) AS [# Calls Planned],SUM([Phone NA]) AS [Phone NA],SUM([# Calls Made]) AS [# Calls Made],ReasonId,SUM([# Failed Calls]) AS [# Failed Calls],sum([# Unproductive Calls]) as [# Unproductive Calls], SUM([# Calls Productive]) AS [# Calls Productive],TCNodeId,Date,

sum([# Calls Not Made]) as [# Calls Not Made],sum([# Calls Picked]) as [# Calls Picked]
into #TeleData 
FROM 
(
select  A.DistNodeId,A.DistNodeType,a.SOAREANodeId,a.SOAREANodeType, b.TeleCallerCode as  [Tele Caller],1 as [# Calls Planned],
 case when IsValidContactNo =0 then 1 else 0 end as [Phone NA],
case when flgCallStatus=3 and ReasonId=8 then 1 when flgCallStatus=2 then 1 when flgCallStatus=1 and isnull(rc.reasnfor,0)=2 then 1 else 0 end as [# Calls Picked],
case when callmade is not null then 1 else 0 end as [# Calls Made],case when a.TCNodeId=0 then 99999 else  ReasonId end as ReasonId,
case when flgCallStatus=0  then 1 when flgCallStatus in(1,3) and isnull(rc.reasnfor,0)=1 then 1 else 0 end as [# Failed Calls],
(case when flgCallStatus=3 and  ReasonId=8 then 1 when flgCallStatus=1 and isnull(rc.reasnfor,0)=2 then 1 else 0 end) as [# Unproductive Calls],
case when flgCallStatus=2 then 1 else 0 end as [# Calls Productive],a.TCNodeId,a.Date,

case when len(isnull(ContactNo,''))>=7 and flgCallStatus=0  then 1 else 0 end as [# Calls Not Made]

 from #vwTeleCallerListForDay a left join tblTeleCallerMstr b on a.TCNodeId=b.TeleCallerId
 join #ASoList c on c.SOAREANodeId=a.SOAREANodeId
 and c.SOAREANodeType=a.SOAREANodeType
 join #TeleReason t on t.TeleReasonId=a.TeleReasonId
 join #Sector sc on sc.SectorId=a.SectorId
  left join tblReasonCodeMstr rc on rc.reasoncodeid=a.reasonid
 --where a.date between @FromDate and @ToDate
) AS AA
GROUP BY DistNodeId,DistNodeType, [Tele Caller],TCNodeId,Date,ReasonId,AA.SOareaNodeId,aa.SOareaNodeType
print 'ffasfd223345'
select 'Productive Calls' as DisplayTxt,isnull(Sum([# Calls Productive]),0) as DisplayValue from #TeleData
union all
select 'Connected but No Order',isnull(Sum([# Unproductive Calls]),0) from #TeleData
union all
select 'Not Connected',isnull(Sum([# Failed Calls]),0) from #TeleData


select ReasnCode_Lvl2Name as DisplayTxt,isnull(Sum([# Failed Calls]),0) as DisplayValue  from tblReasonCodeMstr a join #TeleData b on a.reasoncodeid=b.reasonid
where [# Failed Calls]>=1
group by ReasnCode_Lvl2Name
union all
select 'Phone NA',isnull(Sum([Phone NA]),0) from #TeleData 
union all
select 'Calls Not Made' as DisplayTxt,isnull(Sum([# Calls Not Made]),0) as DisplayValue  from #TeleData b 
--where [# Failed Calls]=1 and isnull(ReasonId,0)=0 and [Phone NA]<>1


select ReasnCode_Lvl2Name as DisplayTxt,isnull(Sum([# Unproductive Calls]),0) as DisplayValue  from tblReasonCodeMstr a join #TeleData b on a.reasoncodeid=b.reasonid
where [# Unproductive Calls]>=1
group by ReasnCode_Lvl2Name
print 'ffasfd223'

select 'Total Call' as Label,isnull(Sum([# Calls Planned]),0) as Value from #TeleData
union all
select 'Not Connected',isnull(Sum([# Failed Calls]),0) from #TeleData
union all
select 'Connected but No Order',isnull(Sum([# Unproductive Calls]),0) from #TeleData

Create table #FinalReport(Lvl tinyint,NodeId int,NodeType int,PNodeId int,PNodeType int,[Total\Cntry\Region\RSH\ASM\SO\DB|3^]  varchar(500),
[# Calls Planned|0^] int,
[# Calls Made|0^] int,
[# Calls Picked|0^] int,
 [# Calls Productive|0^] int, [Not Connected|1^# Phone NA] int,
[Not Connected|1^# Calls Not Made] int
)

--SELECT * FROM #TeleData

insert into #FinalReport
select 1,0,0,-1,-1,'Total',sum([# Calls Planned]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive]),sum([Phone NA]),
sum([# Calls Not Made])
 from #TeleData 
 print 'ffasfd'
insert into #FinalReport
select 2,b.ZoneNodeId,b.ZoneNodeType,0,0,b.Zone,sum([# Calls Planned]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive]),sum([Phone NA]),
sum([# Calls Not Made])

 from #TeleData a join #ASoList b on a.SOAREANodeId=b.SOAREANodeId
 and a.SOAREANodeType=b.SOAREANodeType group by b.ZoneNodeId,b.ZoneNodeType,b.Zone


-- insert into #FinalReport
--select 3,b.RegionNodeId,b.RegionNodeType,b.CntNodeId,b.CntNodeType,b.Region,sum([# Calls Planned]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive]),sum([Phone NA]),
--sum([# Calls Not Made])

-- from #TeleData a join #ASoList b on a.DistNodeId=b.DistNodeId
-- and a.DistNodeType=b.DistNodeType  group by b.RegionNodeId,b.RegionNodeType,b.CntNodeId,b.CntNodeType,b.Region


  insert into #FinalReport
select 3,b.RegionNodeId,b.RegionNodeType,b.ZoneNodeId,b.ZoneNodeType,b.Region,sum([# Calls Planned]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive]),sum([Phone NA]),
sum([# Calls Not Made])

 from #TeleData a join #ASoList b on a.SOAreaNodeId=b.SOAreaNodeId
 and a.SOAreaNodeType=b.SOAreaNodeType  group by b.ZoneNodeId,b.ZoneNodeType,b.RegionNodeId,b.RegionNodeType,b.Region

 
  insert into #FinalReport
select 4,b.ASMAreaNodeId,b.ASMAreaNodeType,b.RegionNodeId,b.RegionNodeType,b.ASMArea,sum([# Calls Planned]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive]),sum([Phone NA]),
sum([# Calls Not Made])

 from #TeleData a join #ASoList b on a.SOAreaNodeId=b.SOAreaNodeId
 and a.SOAreaNodeType=b.SOAreaNodeType  group by b.ASMAreaNodeId,b.ASMAreaNodeType,b.RegionNodeId,b.RegionNodeType,b.ASMArea

   insert into #FinalReport
select 5,b.SoAreaNodeId,b.SoAreaNodeType,b.ASMAreaNodeId,b.ASMAreaNodeType,b.SOArea,sum([# Calls Planned]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive]),sum([Phone NA]),
sum([# Calls Not Made])

 from #TeleData a join #ASoList b on a.SOAreaNodeId=b.SOAreaNodeId
 and a.SOAreaNodeType=b.SOAreaNodeType  group by b.ASMAreaNodeId,b.ASMAreaNodeType,b.SoAreaNodeId,b.SoAreaNodeType,b.SOArea

 insert into #FinalReport
select 6,a.DistNodeId,a.DistNodeType,b.SOAreaNodeId,b.SOAreaNodeType,d.Descr+' ['+d.DistributorCode+']',sum([# Calls Planned]),sum([# Calls Made]),sum([# Calls Picked]),sum([# Calls Productive]),sum([Phone NA]),
sum([# Calls Not Made])

 from #TeleData a join #ASoList b on a.SOAreaNodeId=b.SOAreaNodeId
 and a.SOAreaNodeType=b.SOAreaNodeType
 join tblDBRSalesStructureDBR d on d.NodeID=a.DistNodeId
 and d.NodeType=a.DistNodeType
 group by a.DistNodeId,a.DistNodeType,b.SOAreaNodeId,b.SOAreaNodeType,d.Descr+' ['+d.DistributorCode+']'


Declare @i int=1,@cnt int,@ri int=1,@strcol nvarchar(500)='',@strSql nvarchar(2000)=''

select identity(int,1,1) as ident,ReasnCode_Lvl1Name,Reasnfor,ReasnCode_Lvl2Name,reasoncodeid into #reason from tblreasoncodemstr order by reasnfor,reasoncodeid



select @cnt=count(*) from #reason

while @i<=@cnt
begin
	set @strcol=''

	select @strcol='['+ReasnCode_Lvl1Name+'|'+convert(varchar,Reasnfor)+'^'+ReasnCode_Lvl2Name+']',@ri=reasoncodeid from #reason where ident=@i
	set @strSql='alter table #FinalReport add '+@strcol+' int not null default(0)'
	exec sp_executesql @strSql

	
	
	set @strSql='Update a set '+@strcol+'=(select isnull(sum([# Calls Planned]),0) from #TeleData z join #ASoList b on z.SOareaNodeId=b.SOareaNodeId
 and z.SOareaNodeType=b.SOareaNodeType  where ReasonId ='+convert(varchar,@ri)+'  and ZoneNodeId=a.nodeid and  ZoneNodeType=a.nodetype)  from  #FinalReport a where nodetype=95 ' 

		exec sp_executesql @strSql

		set @strSql='Update a set '+@strcol+'=(select isnull(sum([# Calls Planned]),0) from #TeleData z join #ASoList b on z.SOareaNodeId=b.SOareaNodeId
 and z.SOareaNodeType=b.SOareaNodeType  where ReasonId ='+convert(varchar,@ri)+'  and RegionNodeId=a.nodeid and  RegionNodeType=a.nodetype)  from  #FinalReport a where nodetype=100 ' 

		exec sp_executesql @strSql


		set @strSql='Update a set '+@strcol+'=(select isnull(sum([# Calls Planned]),0) from #TeleData z join #ASoList b on z.SOareaNodeId=b.SOareaNodeId
 and z.SOareaNodeType=b.SOareaNodeType  where ReasonId ='+convert(varchar,@ri)+'  and ASMAreaNodeId=a.nodeid and  ASMAreaNodeType=a.nodetype)  from  #FinalReport a where nodetype=110 ' 

		exec sp_executesql @strSql


		set @strSql='Update a set '+@strcol+'=(select isnull(sum([# Calls Planned]),0) from #TeleData z join #ASoList b on z.SOareaNodeId=b.SOareaNodeId
 and z.SOareaNodeType=b.SOareaNodeType  where ReasonId ='+convert(varchar,@ri)+'  and b.SOAreaNodeId=a.nodeid and  b.SOAreaNodeType=a.nodetype)  from  #FinalReport a where nodetype=120 ' 

		exec sp_executesql @strSql

		
		set @strSql='Update a set '+@strcol+'=(select isnull(sum([# Calls Planned]),0) from #TeleData   where ReasonId ='+convert(varchar,@ri)+'  and DistNodeId=a.nodeid and  DistNodeType=a.nodetype)  from  #FinalReport a where nodetype=150 ' 

		exec sp_executesql @strSql

	set @strSql='Update a set '+@strcol+'=(select isnull(sum([# Calls Planned]),0) from #TeleData where ReasonId ='+convert(varchar,@ri)+'  )  from  #FinalReport a  where nodetype=0  '
		exec sp_executesql @strSql
set @i=@i+1
end


	SELECT * FROM #FinalReport --WHERE Lvl <=6
    --SELECT * FROM #FinalReport WHERE Lvl=7

--SELECT * FROM #TeleData where ReasonId=13
  END
