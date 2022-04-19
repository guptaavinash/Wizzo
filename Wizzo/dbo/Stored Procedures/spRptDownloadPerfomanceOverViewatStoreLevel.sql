








--select * from tblSecUser
--select * from tblSecUserLogin where UserID=2
--[spRptPerfomanceOverView] '01-May-2020','05-May-2020','','',8223
--[spRptDownloadPerfomanceOverViewatStoreLevel]'01-may-2021','01-may-2021',0,0,'',95,1,0,2
CREATE procedure [dbo].[spRptDownloadPerfomanceOverViewatStoreLevel]
@FromDate date,
@ToDate date,
@SalesNodeId  int=0,
@SalesNodeType  int=0,
@TeleReasonIds varchar(100),----'1|2|3|4|5'
@LoginId INT,
@flgActiveProductivityNorms tinyint=1,
@flgReportLevel smallint=0,---0--Default,140=Branch,145=SUBD
@flgDSETC TINYINT = 1, --1: TC, 2: DSE
@SectorIds varchar(100)=''
AS
BEGIN


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
	end




	CREATE TABLE #TeleCaller (UserId INT, TeleCallerId INT,DT DATE,Present INT)

	;With ashcte as(

	select @FromDate as Dt
	union all
	select dateadd(dd,1,Dt) from ashcte where dt<@ToDate)

	INSERT INTO #TeleCaller
	select TeleCallerId,TeleCallerId,Dt,0 as Present from [dbo].[tblTeleCallerMstr] a
	
	cross join ashcte d
	where a.flgActive=1

	--DELETE a from #TeleCaller a join tblTCAttendanceDetail b on a.TeleCallerId=b.TeleCallerId
	--join tblTCAttendanceMstr c on c.TCAttendId=b.TCAttendId and a.Dt=c.AttndDate
	--where b.Absent=1
	

		select * INTO #vwTeleCallerListForDay from vwTeleCallerListForDay where date between @FromDate and @ToDate
	--CREATE TABLE #TeleData(TeleCallingId int,flgorder INT,DistNodeId INT,DistNodeType INT,
	--	DSENodeId INT, DSENodeType INT,[DSEName] VARCHAR(1000),Beat VARCHAR(1000),[Date] DATE,[Tele Caller] VARCHAR(1000), TASSiteName VARCHAR(1000), StoreCode VARCHAR(1000),StoreName VARCHAR(1000),Channel VARCHAR(1000),ContactNo VARCHAR(1000),[Phone Available] VARCHAR(50), [Calls Made] VARCHAR(50), [Calls Picked] VARCHAR(50),  [Productive Call] VARCHAR(50),DownloadTime date,
		
	--	RoleID int, flgOnRoute TINYINT DEFAULT -1,StoreId int)

	CREATE TABLE #Order(TeleCallingId INT,OrderNo varchar(50),PrdNodeId INT,Product VARCHAR(200),OrderQty INT,FreeQty INT
	,OrderValue NUMERIC(18,2)
	,DiscValue NUMERIC(18,2)
	,NetLineOrderVal NUMERIC(18,2),flgSBD tinyint,flgInitiative tinyint,flgFB tinyint,PcsInBox int)
Create table #OrderGPValue(StoreId int,flgOrderSource tinyint,GPValue int)



	CREATE TABLE #Inv(TeleCallingId INT,PrdNodeId INT,PrdCode VARCHAR(200),PrdName VARCHAR(200),InvDate DATE,Qty INT,SalesValue numeric(18,2),DiscAmt numeric(18,2),NetValue NUMERIC(18,2))

	select * into #PrdHierarchy from vwProductHierarchy
	
	CREATE TABLE #TeleData(TeleCallingId int,flgorder INT,DistNodeId INT,DistNodeType INT,
		[SOName] VARCHAR(1000),Beat VARCHAR(1000),[Date] DATE,[Tele Caller] VARCHAR(1000), StoreCode VARCHAR(1000),StoreName VARCHAR(1000),Channel VARCHAR(1000),SubChannel VARCHAR(1000),ContactNo VARCHAR(1000),ContactPerson VARCHAR(1000),[Phone Available] VARCHAR(50), [Calls Made] VARCHAR(50), [Calls Picked] VARCHAR(50),  [Productive Call] VARCHAR(50),
		
		StoreId int,ReasonLvl1 varchar(200),ReasonLvl2 varchar(200),ReasonLvl3 varchar(200),CallAttempt varchar(4),CallStartTime varchar(20),CallEndTime varchar(20),CallDuration int,CallSlot varchar(30),Sector varchar(100),SOAreaNodeId int,SOAreaNodeType int,DSEComments varchar(500),DSEIssueIds varchar(100))


			INSERT INTO #TeleData
			select  a.TeleCallingId,1,a.DistNodeId,a.DistNodeType,a.SOName,a.RouteName,a.Date, b.TeleCallerCode as  [Tele Caller],a.StoreCode,a.StoreName,a.Channel,a.SubChannel,a.ContactNo ,a.ContactPerson
			,case when IsValidContactNo=1 then 'Yes' else 'No' end as [Phone Available],
			case when callmade is not null then 'Yes' else 'No' end as [Calls Made],
			case when flgCallStatus=3 and reasonid=8 then 'Yes' when flgCallStatus=2 then 'Yes'
			when flgCallStatus=1 and isnull(rc.reasnfor,0)=2 then 'Yes' else 'No' end as [Calls Picked]
			,case when flgCallStatus=2 then
			
			'Yes'  else 'No' end as [Productive Call],
			a.StoreId,rc.Lvl1Display,RC.Lvl2Display,rc.REASNCODE_LVL2NAME,a.CallAttempt,
			format(a.CallStartDate,'hh:mm:ss tt'),
			format(a.CallMade,'hh:mm:ss tt'),
			DATEDIFF(second,a.CallStartDate,a.CallMade),
			case when datepart(hour,a.CallStartDate) between 9 and 10 then '9 AM-11 AM'
			when datepart(hour,a.CallStartDate) between 11 and 12 then '11 AM-1 PM'
			when datepart(hour,a.CallStartDate) between 13 and 14 then '1 PM-3 PM'
			when datepart(hour,a.CallStartDate) between 15 and 16 then '3 PM-5 PM'
			when datepart(hour,a.CallStartDate) between 17 and 18 then '5 PM-7 PM'
			ELSE ''
			END,SC.SectorCode,a.SOareaNodeId,a.SOareaNodeType,a.DSEComments,a.DSEIssueIds
			 from #vwTeleCallerListForDay a left join tblTeleCallerMstr b on a.TCNodeId=b.TeleCallerId
			 
			 join #TeleReason t on t.TeleReasonId=a.TeleReasonId
			  left join tblReasonCodeMstr rc on rc.reasoncodeid=a.reasonid
			  join tblMstrSector sc on sc.SectorId=a.SectorId
			 where a.date between @FromDate and @ToDate 

			INSERT INTO #Order(TeleCallingId,OrderNo,PrdNodeId,Product,OrderQty,OrderValue,DiscValue,NetLineOrderVal,flgInitiative,PcsInBox,FreeQty)
			select c.TeleCallingId,b.OrderCode,a.PrdNodeId,p.PrdCode,a.OrderQty,a.LineOrderVal,a.TotLineDiscVal,a.NetLineOrderVal,A.flgInitiative,p.PcsInBox,a.FreeQty --INTO #Order  
			from tblTCOrderDetail a join tblTCordermaster b on a.orderid=b.orderid
			join #TeleData c on c.TeleCallingId=b.TeleCallingId 
			join #PrdHierarchy p on p.PrdNodeId=a.PrdNodeId
			and p.PrdNodeType=a.PrdNodeType
			where  a.OrderQty>0 AND B.flgOrderSource=1
			UNION
			select c.TeleCallingId,b.OrderCode,a.PrdNodeId,p.PrdCode,a.OrderQty,a.LineOrderVal,a.TotLineDiscVal,a.NetLineOrderVal,A.flgInitiative,p.PcsInBox,a.FreeQty --INTO #Order  
			from tblTCOrderDetail_History a join tblTCordermaster_History b on a.orderid=b.orderid
			join #TeleData c on c.TeleCallingId=b.TeleCallingId 
			join #PrdHierarchy p on p.PrdNodeId=a.PrdNodeId
			and p.PrdNodeType=a.PrdNodeType
			where  a.OrderQty>0 AND B.flgOrderSource=1
	
			INSERT INTO #Inv(TeleCallingId,PrdNodeId,PrdCode,InvDate,Qty,SalesValue,DiscAmt,NetValue)
			select c.TeleCallingId,a.PrdNodeId,p.PrdCode,Max(InvDate) as InvDate, sum(a.Qty) as Qty
			,sum(a.RETAILING) as RETAILING
			,sum(a.DiscAmt) as DiscAmt
			,sum(a.NetValue) as NetValue --INTO #Inv  
			from tblTeleCallingInvDetail a(nolock) 
			join #TeleData c on c.TeleCallingId=a.TeleCallingId AND a.flgOrderSource=1
			join #PrdHierarchy p on p.PrdNodeId=a.PrdNodeId
			and p.PrdNodeType=a.PrdNodeType
			group by c.TeleCallingId,a.PrdNodeId,p.PrdCode


	
	select isnull(a.TeleCallingId,b.TeleCallingId) as  TeleCallingId,isnull(a.OrderNo,'') as OrderNo,isnull(a.PrdNodeId,b.prdnodeid) as prdnodeid,a.OrderQty,a.FreeQty,a.OrderValue,a.DiscValue,a.NetLineOrderVal,b.InvDate,b.Qty as NetQty,b.SalesValue,b.DiscAmt as InvDiscAmt,b.NetValue,a.flgInitiative ,a.PcsInBox into #OrderInv from #Order a full join  #Inv b on a.TeleCallingId=b.TeleCallingId and a.PrdNodeId=b.PrdNodeId


				SELECT a.[Tele Caller],c.Region,c.Zone,c.ASMArea,C.SOArea,d.Descr+' ['+d.DistributorCode+']' as [Distributor],a.SOName,a.Beat,a.StoreCode,a.StoreName,a.Channel ,a.ContactNo,a.ContactPerson,a.Sector
				,a.[Phone Available],
				a.[Calls Made],
				a.[Calls Picked]
				,a.[Productive Call],a.Date,A.CallStartTime AS [Call Start Time]
				,A.CallEndTime AS [Call End Time],A.CallDuration AS [Call Duration in Seconds]
				,A.CallSlot AS [Call Slot]
				
				,a.ReasonLvl1,a.ReasonLvl2,a.ReasonLvl3,a.DSEComments,STUFF((select distinct ','+ p2.REASNCODE_LVL2NAME from dbo.Split(a.DSEIssueIds,',') p1 join tblReasonCodeMstr p2 on p1.Items=p2.ReasonCodeID
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)')
        ,1,1,'')  as DSEIssues,a.CallAttempt,Max(b.OrderNo) as [Order No]
		,SUM(convert(int,isnull(b.OrderQty+b.FreeQty,0)/b.PcsInBox)) as [Total Cases]
				,SUM(case when isnull(b.OrderQty,0)>0 then 1 else 0 end ) as [# Lines Ordered],

				SUM(b.OrderValue) as [Value Ordered],

				SUM(b.DiscValue) as [Disc Value],

				SUM(b.NetLineOrderVal) as [Net Ordered Value]
				,STUFF((select distinct ','+ p1.InvNo+'-('+p2.InvStatus+')' from tblTeleCallingInvDetail p1 join tblMstrInvStatus p2 on p1.StatusId=p2.InvStatusId 
         WHERE A.TeleCallingId = p1.TeleCallingId
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)')
        ,1,1,'')  as InvDetail
				,SUM(case when isnull(b.NetQty,0)>0 then 1 else 0 end ) as [Net Lines Supplied]
				,SUM(b.SalesValue) as [Value Supplied]
				,SUM(b.InvDiscAmt) as [Disc Supplied]
				,SUM(b.NetValue) as [Net Value Supplied]
				 fROM #TeleData a left join #OrderInv b on a.TeleCallingId=b.TeleCallingId
				  join #ASoList c on c.SOAREANodeId=a.SOAREANodeId
			 and c.SOAREANodeType=a.SOAREANodeType
			 join tblDBRSalesStructureDBR d on d.NodeID=a.DistNodeId
			 and d.NodeType=a.DistNodeType
				group by a.[Tele Caller],c.Region,c.Zone,c.ASMArea,d.Descr+' ['+d.DistributorCode+']',a.StoreCode,a.StoreName ,a.ContactNo,a.[Phone Available],a.[Calls Made],a.[Calls Picked],a.[Productive Call],a.Date,a.SOName,a.Channel,a.ReasonLvl1,a.ReasonLvl2,a.ReasonLvl3,a.CallAttempt,a.TeleCallingId,a.CallStartTime,a.CallEndTime,
				a.CallSlot,A.CallDuration,C.SOArea,a.Sector,a.DSEComments,a.DSEIssueIds,a.Beat,a.ContactPerson
				order by 2,3,4,5,6,7

				SELECT a.[Tele Caller],c.Region,c.Zone,c.ASMArea,c.SOArea,d.Descr+' ['+d.DistributorCode+']' as [Distributor],a.SOName,a.Beat,a.StoreCode,a.StoreName ,a.Channel,a.ContactNo,a.ContactPerson
				,a.[Phone Available],
				a.[Calls Made],
				a.[Calls Picked]
				,a.[Productive Call],a.Date,a.ReasonLvl1,a.ReasonLvl2,a.ReasonLvl3,a.DSEComments,STUFF((select distinct ','+ p2.REASNCODE_LVL2NAME from dbo.Split(a.DSEIssueIds,',') p1 join tblReasonCodeMstr p2 on p1.Items=p2.ReasonCodeID
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)')
        ,1,1,'')  as DSEIssues,A.Sector,a.CallAttempt,b.OrderNo,p.SKUCode as PrdCode,p.Descr as ProductName,p.PcsInBox as UPC, b.OrderQty AS QtyInPcs,convert(float,b.OrderQty)/p.PcsInBox as CaseQty
				,b.OrderValue as [Order Value]
				,b.DiscValue as [Disc Value]
				,b.NetLineOrderVal as [Net Order Value],STUFF((select distinct ','+ p1.InvNo+'-('+p2.InvStatus+')' from tblTeleCallingInvDetail p1 join tblMstrInvStatus p2 on p1.StatusId=p2.InvStatusId 
         WHERE A.TeleCallingId = p1.TeleCallingId
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)')
        ,1,1,'')  as InvDetail
				--,case when b.flgInitiative =1 then 'Yes' else 'No' end as IsInitiative
				,b.NetQty,(b.SalesValue) as [Value Supplied]
				,(b.InvDiscAmt) as [Disc Supplied]
				,(b.NetValue) as [Net Value Supplied]
				 fROM #TeleData a left join #OrderInv b on a.TeleCallingId=b.TeleCallingId
				  join #ASoList c on c.SOAREANodeId=a.SOAREANodeId
			 and c.SOAREANodeType=a.SOAREANodeType
			 join tblDBRSalesStructureDBR d on d.NodeID=a.DistNodeId
			 and d.NodeType=a.DistNodeType
				 left join tblPrdMstrSKULvl p on p.NodeID=b.prdnodeid
			
				order by 2,3,4,6
		
		--select * from #OrderInv where TeleCallingId=8930
  END

  --select * from tblTeleCallerListForDay where Date='06-sep-2021'