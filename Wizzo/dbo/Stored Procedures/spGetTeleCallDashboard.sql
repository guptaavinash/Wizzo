

--[spGetTeleCallDashboard] 1,800
CREATE proc [dbo].[spGetTeleCallDashboard] 
@TCNodeId int,
@TCNodeType int
AS
BEGIN


Declare @FromDate date,@ToDate date=dbo.fnGetCurrentDateTime()

Declare @WFromDate date

Declare @MFromDate date

		set @FromDate=@ToDate
		set datefirst 1
		set @WFromDate=dateadd(dd,-1* DATEPART(dw,@ToDate)+1,@ToDate)
		set datefirst 7
		set @MFromDate=convert(date,convert(varchar(6),@ToDate,112)+'01',112)
	Declare @TotCall int,@ProductiveCall int,@CallsConnected int,@RangeSelling int=0
select @TotCall=Count(*) ,@ProductiveCall=sum(case when flgCallStatus=2 then 1 else 0 end),
@CallsConnected=sum(case when flgCallStatus=3 and ReasonId=8 then 1 when flgCallStatus=2   then 1 when flgCallStatus=1 and isnull(b.[REASNFOR],0)=2 then 1 else 0 end)


from tbltelecallerlistforday a left join [tblReasonCodeMstr] b on a.reasonid=b.ReasonCodeID
where 
a.tcNodeID=@TCNodeId and TCNodeType=@TCNodeType
and a.Date between @FromDate and @ToDate


--select @RangeSelling=count(distinct c.ProductID) from tblTelecallMaster a(nolock)  join tblOrderDetail c(nolock) on c.OrderID=a.OrderID
--join tblSecUserLogin b1 on a.LoginID=b1.LoginID
--join tblSecUser u on u.UserID=b1.UserID
--where 
--u.NodeID=@TCNodeId and u.NodeType=@TCNodeType
--and convert(date,a.CallDate) between @FromDate and @ToDate


select @TotCall as TotCall,@ProductiveCall as ProductiveCall,case when @CallsConnected>0 then convert(numeric(18,0),convert(float,@ProductiveCall*100)/@CallsConnected)  else 0 end as ProductivityPerc,@CallsConnected as CallsConnected

select @TotCall=Count(*) ,@ProductiveCall=sum(case when flgCallStatus=2 then 1 else 0 end),
@CallsConnected=sum(case when flgCallStatus=3 and ReasonId=8 then 1 when flgCallStatus=2   then 1 when flgCallStatus=1 and isnull(b.[REASNFOR],0)=2 then 1 else 0 end)
from tbltelecallerlistforday a left join [tblReasonCodeMstr] b on a.reasonid=b.ReasonCodeID
where 
a.tcNodeID=@TCNodeId and TCNodeType=@TCNodeType
and a.Date between @WFromDate and @ToDate



--select @RangeSelling=count(distinct c.ProductID) from tblTelecallMaster a(nolock)  join tblOrderDetail c(nolock) on c.OrderID=a.OrderID
--join tblSecUserLogin b1 on a.LoginID=b1.LoginID
--join tblSecUser u on u.UserID=b1.UserID
--where 
--u.NodeID=@TCNodeId and u.NodeType=@TCNodeType
--and convert(date,a.CallDate) between @WFromDate and @ToDate

select @TotCall as TotCall,@ProductiveCall as ProductiveCall,case when @CallsConnected>0 then convert(numeric(18,0),convert(float,@ProductiveCall*100)/@CallsConnected)  else 0 end as ProductivityPerc,@CallsConnected as CallsConnected --,@RangeSelling as RangeSelling

select @TotCall=Count(*) ,@ProductiveCall=sum(case when flgCallStatus=2 then 1 else 0 end),
@CallsConnected=sum(case when flgCallStatus=3 and ReasonId=8 then 1 when flgCallStatus=2   then 1 when flgCallStatus=1 and isnull(b.[REASNFOR],0)=2 then 1 else 0 end)
from tbltelecallerlistforday a left join [tblReasonCodeMstr] b on a.reasonid=b.ReasonCodeID
where 
a.tcNodeID=@TCNodeId and TCNodeType=@TCNodeType
and a.Date between @MFromDate and @ToDate



--select @RangeSelling=count(distinct c.ProductID) from tblTelecallMaster a(nolock)  join tblOrderDetail c(nolock) on c.OrderID=a.OrderID
--join tblSecUserLogin b1 on a.LoginID=b1.LoginID
--join tblSecUser u on u.UserID=b1.UserID
--where 
--u.NodeID=@TCNodeId and u.NodeType=@TCNodeType
--and convert(date,a.CallDate) between @MFromDate and @ToDate

select @TotCall as TotCall,@ProductiveCall as ProductiveCall,case when @CallsConnected>0 then convert(numeric(18,0),convert(float,@ProductiveCall*100)/@CallsConnected)  else 0 end as ProductivityPerc,@CallsConnected as CallsConnected


--select SKUNodeId,BusinessUnit,Grammage_Act into #Prd from VwProductHierarchy
--select BusinessUnit,sum(c.OrderQty*Grammage_Act)+sum(c.FreeQty*Grammage_Act) as ActKg from tblTelecallMaster a(nolock)  join tblOrderDetail c(nolock) on c.OrderID=a.OrderID
--join #Prd p on p.SKUNodeId=c.ProductID
--join tblSecUserLogin b1 on a.LoginID=b1.LoginID
--join tblSecUser u on u.UserID=b1.UserID
--where 
--u.NodeID=@TCNodeId and u.NodeType=@TCNodeType
--and convert(date,a.CallDate) between @FromDate and @ToDate
--group by BusinessUnit

--select BusinessUnit,sum(c.OrderQty*Grammage_Act)+sum(c.FreeQty*Grammage_Act) as ActKg from tblTelecallMaster a(nolock)  join tblOrderDetail c(nolock) on c.OrderID=a.OrderID
--join #Prd p on p.SKUNodeId=c.ProductID
--join tblSecUserLogin b1 on a.LoginID=b1.LoginID
--join tblSecUser u on u.UserID=b1.UserID
--where 
--u.NodeID=@TCNodeId and u.NodeType=@TCNodeType
--and convert(date,a.CallDate) between @WFromDate and @ToDate
--group by BusinessUnit



--select BusinessUnit,sum(c.OrderQty*Grammage_Act)+sum(c.FreeQty*Grammage_Act) as ActKg from tblTelecallMaster a(nolock)  join tblOrderDetail c(nolock) on c.OrderID=a.OrderID
--join #Prd p on p.SKUNodeId=c.ProductID
--join tblSecUserLogin b1 on a.LoginID=b1.LoginID
--join tblSecUser u on u.UserID=b1.UserID
--where 
--u.NodeID=@TCNodeId and u.NodeType=@TCNodeType
--and convert(date,a.CallDate) between @MFromDate and @ToDate
--group by BusinessUnit

select isnull(b.TelCallBreakReason,'') as BreakReason,case when datepart(hour,getdate()) between 10 and 11  then '12 pm -2 pm'
else  '' end nextTimeslot

from tblTeleCallerDailyMstr a left  join tblMstTeleCallBreakReason b on a.BreakReasonId=TelCallBreakReasonId where TCNodeId=@TCNodeId and TCNodeType=@TCNodeType and CallDate=@ToDate
END
