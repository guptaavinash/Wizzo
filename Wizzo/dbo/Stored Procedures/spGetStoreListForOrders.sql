
--select * from tblSecUserLogin
--[spGetStoreListForOrders]  246
CREATE procEDURE [dbo].[spGetStoreListForOrders]  
	-- Add the parameters for the stored procedure here
	@LoginId int
AS
BEGIN
	
	SET NOCOUNT ON;

    
	
	-- Insert statements for procedure here


	select a.NodeID,a.NodeType,a.Descr+' ['+a.DistributorCode+']' as Distributor
	into #DBRList from tblDBRSalesStructureDBR a 
	
	Declare @UserId int,@NodeId int,@NodeType int
	select @UserId=a.UserId,@NodeType=NodeType,@NodeId=NodeID from tblSecUserlogin a join tblSecUser b on a.UserID=b.UserID where loginid= @LoginId
--	select @UserId
	DECLARE @RouteDate Date,@CurrDate datetime
	set @CurrDate=dbo.fnGetCurrentDateTime()

	SET @RouteDate=CAST(@CurrDate AS DATE)
	--if @MenuId=2
	--begin
--		select a.TeleCallingId
--		,
--		a.StoreId,
--	a. DistNodeId ,
--	a.DistNodeType,
--	b.Distributor as [Store Details^Distributor],
--		p.Descr+' ['+p.Code+']' as  [Store Details^DSE],
--		StoreCode as [Store Details^Store Code],
--		StoreName as [Store Details^Store Name],
--		a.Channel as [Store Details^Channel],
--		Replace(Replace(a.ContactNo,'N/A','NA'),',','/') as [Store Details^Contact No],
--		a.ContactPerson as [Store Details^Contact Person],
--r1.TeleReason as [Tele Call^Reason],
--	case flgCallStatus when 0 then 'To be Called' when 1 then 'Called' when 2 then 'Productive Call'
	
--	when 3 then 'Call Schedule'
--		 when 4 then 'Order Downloaded'
--	end as [Calling Status^Status],
--	--isnull(r.REASNCODE_LVL2NAME,'') as [Calling Status^Reason],
--		  ScheduleCall as [Calling Status^Schedule],
--		  isnull(CallAttempt,0) as [Calling Status^Call Attempt],
--	format(isnull(CallMade,a.LastCallDate),'dd-MMM-yy hh:mm tt')  as [Last Call Date^] ,'Hindi' as [Language^],
--	1 as flgRecording,

--	case  when ReasonId=8 then 1 
--		when ReasonId=2 then 2
--		else 0 end as flgColorStatus

--		 from tblTeleCallerListForDay a(nolock) join #DBRList b on b.nodeid=a.DistNodeId
--		 and b.nodetype=a.DistNodeType
--		 join tblMstrPerson p(nolock) on p.nodeid=a.DSENodeId
--		 and p.nodetype=a.DSENodeType
--		 left join tblReasonCodeMstr r on  r.ReasonCodeId=a.reasonid
--		 left join tblTeleReasonMstr r1 on  r1.TeleReasonId=a.TeleReasonId
--		 where TCNodeId=@UserId and Date=@RouteDate and flgCallStatus in(0,3) and isnull(CallAttempt,0)<4
--		 and isnull(IsFinalDownloadSubmit,0)=0 and isnull(IsDownloaded,0)=0
--		 order by case when ScheduleCall is null then 7  else 
		 
--		 DATEDIFF(MINUTE,CONVERT(TIME,@CurrDate),convert(time,ScheduleCall))+(case when a.reasonid=8 then  -1 else 0 end) end, Priority
--	end
--else
--begin
		select a.TeleCallingId,a.StoreId,a. DistNodeId ,
	a.DistNodeType,
	
		case when flgCallStatus<3 and isnull(IsDownloaded,0)=0 and isnull(IsFinalDownloadSubmit,0)=0 then flgCallStatus 
		when isnull(IsDownloaded,0)=1 then 3
		when isnull(IsFinalDownloadSubmit,0)=1 then 4 else 0 end as flgColorStatus
		,b.Distributor as [Store Details^Distributor],a.SOName as  [Store Details^DSE],StoreCode as [Store Details^Store Code],StoreName as [Store Details^Store Name],a.Channel as [Store Details^Channel],Replace(a.ContactNo,',','/')  as [Store Details^Contact No],a.ContactPerson as [Store Details^Contact Person],
r1.TeleReason as [Tele Call^Reason],
		case  when flgCallStatus=0 then 'To be Called' when flgCallStatus=1 then 'Called' when flgCallStatus=2 then 'Productive Call'
	
		 when flgCallStatus=3 then 'Call Schedule'
		 when isnull(IsDownloaded,0)=1 then 'Order Downloaded'
		 when isnull(IsFinalDownloadSubmit,0)=1 then 'Final Dowloaded'
		  end as [Calling Status^Status],isnull(r.REASNCODE_LVL2NAME,'') as [Calling Status^Reason],ScheduleCall as [Calling Status^Schedule],isnull(CallAttempt,0) as [Calling Status^Call Attempt],
		  isnull(z.NoOfSku,0) as [Calling Status^No Of Ordered SKU],
		  isnull(z.NetOrderValue,0) as [Calling Status^Order Value],
	format(isnull(CallMade,a.LastCallDate),'dd-MMM-yy hh:mm tt')  as [Last Call Date^] ,'Hindi' as [Language^]
	,
	1 as flgRecording
		 from tblTeleCallerListForDay a(nolock) join #DBRList b on b.nodeid=a.DistNodeId
		 and b.nodetype=a.DistNodeType
		 
		 left join tblReasonCodeMstr r on  r.ReasonCodeId=a.reasonid
		 left join tblTeleReasonMstr r1 on  r1.TeleReasonId=a.TeleReasonId
		 left join [dbo].[tblMstrSector] s1 on s1.SectorId=a.SectorId
		 left join (select y.TeleCallingId,Sum(case when x.OrderQty>0 then 1 else 0 end) as NoOfSku,Sum(x.LineOrderVal) as NetOrderValue from tblTCOrderDetail x join tblTCOrderMaster y on x.orderid=y.OrderID
		 --where isnull(y.flgSent,0)<>1
		 group by y.TeleCallingId) z on z.TeleCallingId=a.TeleCallingId 

		 where TCNodeId=@NodeId and Date=@RouteDate 
		 --and  (flgCallStatus in(1,2)
		 ----or (flgCallStatus=3 and CallAttempt>3)
		 --) 
		 and a.IsUsed in(2,3,5)
--		  --and isnull(IsFinalDownloadSubmit,0)=0 and isnull(IsDownloaded,0)=0

		  

----end
--select 'Total # Of Call Made' as StatusText,convert(varchar,Count(*)) as  StatusVal from tblTeleCallerListForDay(nolock) where TeleUserId=@UserId and Date=@RouteDate 
--		 and  (isnull(flgCallStatus,0)>0)
--		 union all
--		 		  select 'Total Productive Calls' as StatusText,convert(varchar,sum(case when Round(o.TotOrderVal,0)>=b.ThresholdAmount then 1 else 0 end)) as  StatusVal from tblTeleCallerListForDay(nolock) a join tblChannelWiseProductivityThreshold b on 
--				  a.ChannelId=b.ChannelId and @RouteDate between Fromdate and ToDate
--				  join tblOrderMaster o(nolock) on o.TeleCallingId=a.TeleCallingId
--				  and o.flgOrderSource=1
--				  where a.TeleUserId=@UserId and a.Date=@RouteDate 
--		 and  (isnull(flgCallStatus,0)=2)
--		 union all
--		 		  select 'Total Downloaded Orders' as StatusText,convert(varchar,Count(*)) as  StatusVal from tblTeleCallerListForDay(nolock) where TeleUserId=@UserId and Date=@RouteDate 
--		 and  (isnull(flgCallStatus,0)=2 and (isnull(IsDownloaded,0)=1 
--		 or isnull(IsFinalDownloadSubmit,0)=1))
--		 		 union all
--		 		  select 'Net Order Value' as StatusText,convert(varchar,isnull(sum(b.TotOrderVal),0.00)) as  StatusVal from tblTeleCallerListForDay a(nolock)
--				  join  tblOrderMaster b (nolock) on a.TeleCallingId=b.TeleCallingId
--				  and b.flgOrderSource=1
--				   where TeleUserId=@UserId and Date=@RouteDate 
--				  --exec spDeleteTopChannelsForAstixUser


--Declare @MTDTotStarEarned int,@MTDRank int,@MTDTotTC int,@TotTC int,@RankToday int,@AvgStarPerCall numeric(10,1),
--@TotStarEarnedToday int,@CallConvPerc numeric(10,0),@CallMade int,@CallConvStarEarned int,
--@ProductivityPerc numeric(10,0),@ProdStarEarned int,@TotGPTgt int,@TotGPAch int,@GPStarEarned int,@GPPerc numeric(10,0)
--,@TotFBTgt int,@TotFBAch int,@FBStarEarned int,@FBPerc numeric(10,0)
--,@TotSTTgt numeric(18,0),@TotSTAch numeric(18,0),@STStarEarned int,@TotSTBalance numeric(18,0),@STPerc numeric(10,0),
--@NoOfCallsFiveStar int,@TotSTCompletedTgt numeric(18,0)


--select @TotSTCompletedTgt=isnull(sum(FiveStarIndTgtDlvryVal),0) from tblTeleCallerListForDay where TeleUserId=@UserId
--and flgCallStatus<>0 and Date=@RouteDate
----Set @MTDTotStarEarned=350
----Set @MTDRank=2
----SET @MTDTotTC=14
----SET @TotTC=14
----Set @RankToday=3
----Set @AvgStarPerCall=2.9
----SET @TotStarEarnedToday=45
----SET @CallConvPerc=70
----SET @CallMade=25
----SET @CallConvStarEarned=18
----SET @ProductivityPerc=56
----SET @ProdStarEarned=14
----SET @TotGPTgt=100
----SET @TotGPAch=80
----SET @GPStarEarned=6
----SET @GPPerc=25
----SET @TotFBTgt=25
----SET @TotFBAch=15 
----SET @FBStarEarned=8
----SET @FBPerc=60
----SET @TotSTTgt=50000
----SET @TotSTAch=32000
----SET @STStarEarned=12
----SET @TotSTBalance=35000
----SET @STPerc=65
--Declare @TCDailyId  int
--select @TCDailyId=TCDailyId from tblTeleCallerDailyMstr where TeleCallerId=@NodeId and TeleCallerNodeType=@NodeType and CallDate=@RouteDate

--select @MTDTotStarEarned=sum(convert(int,MeasureVal)) from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId in(1,7)
--select @MTDRank=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=2
--select @MTDTotTC=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=3
--select @TotTC=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=4
--select @RankToday=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=5
--select @AvgStarPerCall=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=6
--select @TotStarEarnedToday=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=7
--select @CallConvPerc=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=8
--select @CallMade=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=9
--select @CallConvStarEarned=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=10
--select @ProductivityPerc=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=11
--select @ProdStarEarned=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=12
--select @TotGPTgt=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=13
--select @TotGPAch=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=14
--print 'tttdfds'
--select @GPStarEarned=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=15
--select @GPPerc=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=16
--select @TotFBTgt=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=17
--select @TotFBAch=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=18
--select @FBStarEarned=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=19
--print 'tttdfds111222'
--print @TCDailyId
--select @FBPerc=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=20
--print 'tttdfds11122233333'
--print @TCDailyId
--select @TotSTTgt=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=21
--print 'tttdfds1112223'
--select @TotSTAch=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=22
--select @STStarEarned=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=23
--print 'tttdfds111'
--select @TotSTBalance=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=24
--select @STPerc=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=25
--select @NoOfCallsFiveStar=MeasureVal from  tblTeleCallerDailyMeasureDetail where TCDailyId=@TCDailyId  and MeasureId=26

--select @MTDTotStarEarned as MTDTotStarEarned,@MTDRank as MTDRank,@MTDTotTC as MTDTotTC,@TotTC as TotTC,@RankToday as RankToday ,@AvgStarPerCall as AvgStarPerCall 
--,
--@TotStarEarnedToday as TotStarEarnedToday,

--CASE WHEN @AvgStarPerCall<=2.5 then '#c00000'
--WHEN @AvgStarPerCall>2.5 and @AvgStarPerCall<=3.5 then '#ffc000'
--else  '#00b050' end as [SETColor],


--CASE WHEN @MTDRank<=2.5 then '#c00000'
--WHEN @MTDRank>2.5 and @MTDRank<=3.5 then '#ffc000'
--else  '#00b050' end as [MTDRankColor]


--,


--CASE WHEN @RankToday<=2.5 then '#c00000'
--WHEN @RankToday>2.5 and @RankToday<=3.5 then '#ffc000'
--else  '#00b050' end as [RankTodayColor]




--,@CallConvPerc as CallConvPerc,@CallMade as CallMade,@CallConvStarEarned as CallConvStarEarned
--,CASE WHEN @CallConvPerc>=65 then '#00b050'
--WHEN @CallConvPerc>=40 and @CallConvPerc<65 then '#ffc000'
--else  '#c00000'  end as [CallConvColor]

--,
--@ProductivityPerc as ProductivityPerc,@ProdStarEarned as ProdStarEarned

--,CASE WHEN @ProductivityPerc>=60 then '#00b050'
--WHEN @ProductivityPerc>=40 and @ProductivityPerc<60 then '#ffc000'
--else  '#c00000' end as [ProductivityColor]
--,@TotGPTgt as TotGPTgt,@TotGPAch as TotGPAch,@GPStarEarned as GPStarEarned,@GPPerc as GPPerc
--,CASE WHEN @GPPerc>=60 then '#00b050'
--WHEN @GPPerc>=40 and @GPPerc<60 then '#ffc000'
--else  '#c00000' end as [GPColor]

--,@TotFBTgt as TotFBTgt,@TotFBAch as TotFBAch,@FBStarEarned as FBStarEarned,@FBPerc as FBPerc 
--,CASE WHEN @FBPerc>=60 then '#00b050'
--WHEN @FBPerc>=40 and @FBPerc<60 then '#ffc000'
--else  '#c00000' end as [FBColor]
--,@TotSTTgt as TotSTTgt,@TotSTAch as TotSTAch,@STStarEarned as STStarEarned,@TotSTBalance as TotSTBalance,@STPerc as STPerc
--,CASE WHEN @STPerc>=90 then '#00b050'
--WHEN @STPerc>=60 and @STPerc<90 then '#ffc000'
--else  '#c00000' end as [STColor],@NoOfCallsFiveStar as NoOfCallsFiveStar,@TotSTCompletedTgt as TotSTCompletedTgt

END
