








--[spRptPerfomanceOverView] '01-May-2020','05-May-2020','','',8223
--[spRptDownloadPerfomanceOverViewatStoreLeveln]'17-feb-2021','17-feb-2021',0,0,'',0,1,0,2
CREATE procedure [dbo].[spRptDownloadPerfomanceOverViewatStoreLeveln]
@FromDate date,
@ToDate date,
@SalesNodeId  int=0,
@SalesNodeType  int=0,
@TeleReasonIds varchar(100),----'1|2|3|4|5'
@LoginId INT,
@flgActiveProductivityNorms tinyint=1,
@flgReportLevel smallint=0,---0--Default,140=Branch,145=SUBD
@flgDSETC TINYINT = 1 --1: TC, 2: DSE
AS
BEGIN


	Declare @NodeId int,@NodeType int,@RoleId int
	select @NodeId=b.UserNodeId,@NodeType=b.UserNodeType,@RoleId=b.RoleId from tblSecUserLogin a join tblSecMapUserRoles b on a.userid=b.UserID where LoginId=@LoginId 


	select distinct items  as TeleReasonId into #TeleReason from dbo.Split(@TeleReasonIds,'|') where items<>''


Create table #ADistributorList(DistNodeId int,DistNodeType int,DistrbutorCode varchar(50),DistributorName varchar(150),Cntry varchar(100),Region varchar(100),RSH varchar(100),ASMArea varchar(100),SOArea varchar(100),SOAreaNodeId int,SOAreaNodeType int
,ASMAreaNodeId int,ASMAreaNodeType int
,RSHNodeId int,RSHNodeType int
,RegionNodeId int,RegionNodeType int
,CntNodeId int,CntNodeType int
)

	
		insert into #ADistributorList
		 exec spGetDistributorList @loginid,@SalesNodeId,@SalesNodeType


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

	CREATE TABLE #Order(TeleCallingId INT,OrderNo varchar(50),PrdNodeId INT,SBF VARCHAR(200),OrderQty INT
	,OrderValue NUMERIC(18,2)
	,DiscValue NUMERIC(18,2)
	,NetLineOrderVal NUMERIC(18,2),flgSBD tinyint,flgInitiative tinyint,flgFB tinyint)
Create table #OrderGPValue(StoreId int,flgOrderSource tinyint,GPValue int)



	CREATE TABLE #Inv(TeleCallingId INT,PrdNodeId INT,PrdCode VARCHAR(200),PrdName VARCHAR(200),InvDate DATE,Qty INT,SalesValue numeric(18,2),DiscAmt numeric(18,2),NetValue NUMERIC(18,2))

	select * into #PrdHierarchy from vwProductHierarchy
	
	CREATE TABLE #TeleData(TeleCallingId int,flgorder INT,DistNodeId INT,DistNodeType INT,
		[DSEName] VARCHAR(1000),Beat VARCHAR(1000),[Date] DATE,[Tele Caller] VARCHAR(1000), StoreCode VARCHAR(1000),StoreName VARCHAR(1000),Channel VARCHAR(1000),SubChannel VARCHAR(1000),ContactNo VARCHAR(1000),[Phone Available] VARCHAR(50), [Calls Made] VARCHAR(50), [Calls Picked] VARCHAR(50),  [Productive Call] VARCHAR(50),
		
		StoreId int)


			INSERT INTO #TeleData
			select  a.TeleCallingId,1,a.DistNodeId,a.DistNodeType,a.DSEName,a.RouteName,a.Date, b.TeleCallerCode as  [Tele Caller],a.StoreCode,a.StoreName,a.Channel,a.SubChannel,a.ContactNo 
			,case when LEN(isnull(ContactNo,''))>=7 then 'Yes' else 'No' end as [Phone Available],
			case when callmade is not null then 'Yes' else 'No' end as [Calls Made],
			case when flgCallStatus=3 and reasonid=8 then 'Yes' when flgCallStatus=2 then 'Yes'
			when flgCallStatus=1 and isnull(rc.reasnfor,0)=2 then 'Yes' else 'No' end as [Calls Picked]
			,case when flgCallStatus=2 then
			
			'Yes'  else 'No' end as [Productive Call],
			a.StoreId
			 from #vwTeleCallerListForDay a join tblTeleCallerMstr b on a.TCNodeId=b.TeleCallerId
			 
			 join #TeleReason t on t.TeleReasonId=a.TeleReasonId
			  left join tblReasonCodeMstr rc on rc.reasoncodeid=a.reasonid
			 where a.date between @FromDate and @ToDate 

			INSERT INTO #Order(TeleCallingId,OrderNo,PrdNodeId,SBF,OrderQty,OrderValue,DiscValue,NetLineOrderVal,flgInitiative)
			select c.TeleCallingId,b.OrderCode,a.PrdNodeId,p.SBF,a.OrderQty,a.LineOrderVal,a.TotLineDiscVal,a.NetLineOrderVal,A.flgInitiative --INTO #Order  
			from tblOrderDetail a join tblordermaster b on a.orderid=b.orderid
			join #TeleData c on c.TeleCallingId=b.TeleCallingId 
			join #PrdHierarchy p on p.PrdNodeId=a.PrdNodeId
			and p.PrdNodeType=a.PrdNodeType
			where  a.OrderQty>0 AND B.flgOrderSource=1
			UNION
			select c.TeleCallingId,b.OrderCode,a.PrdNodeId,p.SBF,a.OrderQty,a.LineOrderVal,a.TotLineDiscVal,a.NetLineOrderVal,A.flgInitiative --INTO #Order  
			from tblOrderDetail_History a join tblordermaster_History b on a.orderid=b.orderid
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


	
	select isnull(a.TeleCallingId,b.TeleCallingId) as  TeleCallingId,isnull(a.OrderNo,'') as OrderNo,isnull(a.PrdNodeId,b.prdnodeid) as prdnodeid,a.OrderQty,a.OrderValue,a.DiscValue,a.NetLineOrderVal,b.InvDate,b.Qty as NetQty,b.SalesValue,b.DiscAmt as InvDiscAmt,b.NetValue,a.flgInitiative  into #OrderInv from #Order a full join  #Inv b on a.TeleCallingId=b.TeleCallingId and a.PrdNodeId=b.PrdNodeId


				SELECT a.[Tele Caller],c.Cntry as Country,c.Region,c.RSH,c.ASMArea,c.SOArea,c.DistributorName+' ['+c.DistrbutorCode+']' as [Distributor],a.DSEName,a.StoreCode,a.StoreName,a.Channel ,a.ContactNo
				,a.[Phone Available],
				a.[Calls Made],
				a.[Calls Picked]
				,a.[Productive Call],a.Date,Max(b.OrderNo) as [Order No]
				,SUM(case when isnull(b.OrderQty,0)>0 then 1 else 0 end ) as [# Lines Ordered],

				SUM(b.OrderValue) as [Value Ordered],

				SUM(b.DiscValue) as [Disc Value],

				SUM(b.NetLineOrderVal) as [Net Ordered Value]
				,SUM(case when isnull(b.NetQty,0)>0 then 1 else 0 end ) as [Net Lines Supplied]
				,SUM(b.SalesValue) as [Value Supplied]
				,SUM(b.InvDiscAmt) as [Disc Supplied]
				,SUM(b.NetValue) as [Net Value Supplied]
				 fROM #TeleData a left join #OrderInv b on a.TeleCallingId=b.TeleCallingId
				  join #ADistributorList c on c.DistNodeId=a.DistNodeId
			 and c.DistNodeType=a.DistNodeType
				group by a.[Tele Caller],c.Cntry ,c.Region,c.RSH,c.ASMArea,c.SOArea,c.DistributorName+' ['+c.DistrbutorCode+']',a.StoreCode,a.StoreName ,a.ContactNo,a.[Phone Available],a.[Calls Made],a.[Calls Picked],a.[Productive Call],a.Date,a.DSEName,a.Channel,b.OrderNo
				order by 2,3,4,5,6,7

				SELECT a.[Tele Caller],c.Cntry as Country,c.Region,c.RSH,c.ASMArea,c.SOArea,c.DistributorName+' ['+c.DistrbutorCode+']' as [Distributor],a.DSEName,a.StoreCode,a.StoreName ,a.Channel,a.ContactNo
				,a.[Phone Available],
				a.[Calls Made],
				a.[Calls Picked]
				,a.[Productive Call],a.Date,b.OrderNo,p.Code as PrdCode,p.Descr as ProductName, b.OrderQty
				,b.OrderValue as [Order Value]
				,b.DiscValue as [Disc Value]
				,b.NetLineOrderVal as [Net Order Value]
				--,case when b.flgInitiative =1 then 'Yes' else 'No' end as IsInitiative
				,b.NetQty,(b.SalesValue) as [Value Supplied]
				,(b.InvDiscAmt) as [Disc Supplied]
				,(b.NetValue) as [Net Value Supplied]
				 fROM #TeleData a left join #OrderInv b on a.TeleCallingId=b.TeleCallingId
				  join #ADistributorList c on c.DistNodeId=a.DistNodeId
				  join tblPrdMstrHierLvl7 p on p.NodeID=b.prdnodeid
			 and c.DistNodeType=a.DistNodeType
				order by 2,3,4,6
		
		--select * from #OrderInv where TeleCallingId=8930
  END
