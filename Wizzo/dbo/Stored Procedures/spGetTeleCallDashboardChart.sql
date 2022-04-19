

-- [spGetTeleCallDashboardChart] 1,800,3,4
CREATE proc [dbo].[spGetTeleCallDashboardChart]
@TCNodeId int,
@TCNodeType int,
@Type tinyint, ---1=Day,2=Week,3=MTD
@MeasureId tinyint---1=Productive Call,2=Productive Perc,3=Call Picked,4=Sales
as
begin

	Declare @FromDate date,@ToDate date=Getdate()

	IF @Type=1
	begin
		set @FromDate=dateadd(dd,-3,@ToDate)
	end
	else IF @Type=2
	begin
		set datefirst 1
		set @ToDate=dateadd(dd, 7-DATEPART(dw,@ToDate),@ToDate)
		set @FromDate=dateadd(dd, DATEPART(dw,@ToDate)+(-34),@ToDate)
		set datefirst 7
	end
	else IF @Type=3
	begin
		set @FromDate=DATEADD(month,-3,convert(date,convert(varchar(6),@ToDate,112)+'01',112))
	end

	Create table #FinalChartTable(TCNodeId int,TCNodeType int,MeasureVal float,RangeType varchar(50),RangeVal int)

	if @MeasureId=1
	begin
		insert into #FinalChartTable(TCNodeId,TCNodeType,MeasureVal,RangeVal,RangeType)
		select a.TCNodeId,a.TCNodeType,sum(case when flgCallStatus=2 then 1 else 0 end),case when @Type=1 then convert(varchar,a.Date,112)
		when @Type=2 then convert(varchar,dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),112)
		when @Type=3 then convert(varchar(6),a.Date,112)

		end,case when @Type=1 then format(a.Date,'dd-MMM')
		when @Type=2 then format(dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),'WE:dd-MMM')
		when @Type=3 then format(a.Date,'MMM-yy')
		end  from tblTeleCallerListForDay a 
		where convert(date,a.Date) between @FromDate and @ToDate
		group by a.TCNodeId,a.TCNodeType,case when @Type=1 then convert(varchar,a.Date,112)
		when @Type=2 then convert(varchar,dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),112)
		when @Type=3 then convert(varchar(6),a.Date,112)

		end
		,
		case when @Type=1 then format(a.Date,'dd-MMM')
		when @Type=2 then format(dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),'WE:dd-MMM')
		when @Type=3 then format(a.Date,'MMM-yy') end
	end
	else if @MeasureId=2
	begin
		insert into #FinalChartTable(TCNodeId,TCNodeType,MeasureVal,RangeVal,RangeType)
		select a.TCNodeId,a.TCNodeType,
		case when sum(case when flgCallStatus=2   then 1 when flgCallStatus=1 and ISNULL(REASNFOR,0)=2 then 1 else 0 end)>0 then 
		convert(int,convert(float,sum(case when flgCallStatus=2 then 1 else 0 end)*100)/sum(case when flgCallStatus=2   then 1 when flgCallStatus=1 and ISNULL(REASNFOR,0)=2 then 1 else 0 end)) else 0 end,case when @Type=1 then convert(varchar,a.Date,112)
		when @Type=2 then convert(varchar,dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),112)
		when @Type=3 then convert(varchar(6),a.Date,112)

		end,case when @Type=1 then format(a.Date,'dd-MMM')
		when @Type=2 then format(dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),'WE:dd-MMM')
		when @Type=3 then format(a.Date,'MMM-yy')
		end  from tblTeleCallerListForDay a left  join tblReasonCodeMstr r on a.ReasonId=r.ReasonCodeID
		where convert(date,a.Date) between @FromDate and @ToDate
		group by a.TCNodeId,a.TCNodeType,case when @Type=1 then convert(varchar,a.Date,112)
		when @Type=2 then convert(varchar,dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),112)
		when @Type=3 then convert(varchar(6),a.Date,112)

		end
		,
		case when @Type=1 then format(a.Date,'dd-MMM')
		when @Type=2 then format(dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),'WE:dd-MMM')
		when @Type=3 then format(a.Date,'MMM-yy') end
	end
	else if @MeasureId=3
	begin
		insert into #FinalChartTable(TCNodeId,TCNodeType,MeasureVal,RangeVal,RangeType)
		select a.TCNodeId,a.TCNodeType,sum(case when flgCallStatus=3 and ReasonId=8 then 1 when flgCallStatus=2   then 1 when flgCallStatus=1 and isnull(b.[REASNFOR],0)=2 then 1 else 0 end),case when @Type=1 then convert(varchar,a.Date,112)
		when @Type=2 then convert(varchar,dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),112)
		when @Type=3 then convert(varchar(6),a.Date,112)

		end,case when @Type=1 then format(a.Date,'dd-MMM')
		when @Type=2 then format(dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),'WE:dd-MMM')
		when @Type=3 then format(a.Date,'MMM-yy')
		end  from tblTeleCallerListForDay a left join [tblReasonCodeMstr] b on a.reasonid=b.ReasonCodeID
		where convert(date,a.Date) between @FromDate and @ToDate
		group by a.TCNodeId,a.TCNodeType,case when @Type=1 then convert(varchar,a.Date,112)
		when @Type=2 then convert(varchar,dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),112)
		when @Type=3 then convert(varchar(6),a.Date,112)

		end
		,
		case when @Type=1 then format(a.Date,'dd-MMM')
		when @Type=2 then format(dateadd(dd, 7-DATEPART(dw,a.Date),a.Date),'WE:dd-MMM')
		when @Type=3 then format(a.Date,'MMM-yy') end
	end
--	else if @MeasureId=3
--	begin
--		insert into #FinalChartTable(TCNodeId,TCNodeType,MeasureVal,RangeVal,RangeType)
--		select u.NodeID,u.NodeType,convert(int,count(distinct o.ProductID)),case when @Type=1 then convert(varchar,a.CallDate,112)
--		when @Type=2 then convert(varchar,dateadd(dd, 7-DATEPART(dw,a.CallDate),a.CallDate),112)
--		when @Type=3 then convert(varchar(6),a.CallDate,112)

--		end,case when @Type=1 then format(a.CallDate,'dd-MMM')
--		when @Type=2 then format(dateadd(dd, 7-DATEPART(dw,a.CallDate),a.CallDate),'WE:dd-MMM')
--		when @Type=3 then format(a.CallDate,'MMM-yy')
--		end  from tblTelecallMaster a join tblSecUserLogin b on a.LoginID=b.LoginID
--		join tblSecUser u on u.UserID=b.UserID
--		join tblOrderDetail o  on o.OrderID=a.OrderID
--		where convert(date,a.CallDate) between @FromDate and @ToDate
--		group by u.NodeID,u.NodeType,case when @Type=1 then convert(varchar,a.CallDate,112)
--		when @Type=2 then convert(varchar,dateadd(dd, 7-DATEPART(dw,a.CallDate),a.CallDate),112)
--		when @Type=3 then convert(varchar(6),a.CallDate,112)

--		end
--		,
--		case when @Type=1 then format(a.CallDate,'dd-MMM')
--		when @Type=2 then format(dateadd(dd, 7-DATEPART(dw,a.CallDate),a.CallDate),'WE:dd-MMM')
--		when @Type=3 then format(a.CallDate,'MMM-yy') end

--end
--else if @MeasureId=4
--begin
--select SKUNodeId,BusinessUnit,Grammage into #Prd from VwProductHierarchy
--select case when @Type=1 then convert(varchar,a.CallDate,112)
--		when @Type=2 then convert(varchar,dateadd(dd, 7-DATEPART(dw,a.CallDate),a.CallDate),112)
--		when @Type=3 then convert(varchar(6),a.CallDate,112)

--		end AS RangeVal
		
--		,case when @Type=1 then format(a.CallDate,'dd-MMM')
--		when @Type=2 then format(dateadd(dd, 7-DATEPART(dw,a.CallDate),a.CallDate),'WE:dd-MMM')
--		when @Type=3 then format(a.CallDate,'MMM-yy') end AS RangeType,p.BusinessUnit as Type
--		,
--		sum(o.OrderQty*Grammage)+sum(o.FreeQty*Grammage) as MeasureVal

--		into #SalesVal
--		  from tblTelecallMaster a join tblSecUserLogin b on a.LoginID=b.LoginID
--		join tblSecUser u on u.UserID=b.UserID
--		join tblOrderDetail o  on o.OrderID=a.OrderID
--		JOIN #Prd p on p.SKUNodeId=o.ProductID
--		where convert(date,a.CallDate) between @FromDate and @ToDate
--		group by p.BusinessUnit,case when @Type=1 then convert(varchar,a.CallDate,112)
--		when @Type=2 then convert(varchar,dateadd(dd, 7-DATEPART(dw,a.CallDate),a.CallDate),112)
--		when @Type=3 then convert(varchar(6),a.CallDate,112)

--		end
--		,
--		case when @Type=1 then format(a.CallDate,'dd-MMM')
--		when @Type=2 then format(dateadd(dd, 7-DATEPART(dw,a.CallDate),a.CallDate),'WE:dd-MMM')
--		when @Type=3 then format(a.CallDate,'MMM-yy') end

--		select * from #SalesVal order by 1
--	select Max(MeasureVal) as MaxVal, Min(MeasureVal) as MinVal from #SalesVal
--return

--	end

	select RangeVal,RangeType,SUM(CASE WHEN TCNodeId=@TCNodeId and TCNodeType=@TCNodeType then  MeasureVal else 0 end) as Score,Max(MeasureVal) as [High Performing Agent] into #FinalTable from #FinalChartTable
	group by RangeVal,RangeType
	order by 1 asc


	select RangeVal,RangeType,'Score' as Type,Score as MeasureVal from #FinalTable
	union all
		select RangeVal,RangeType,'High Performing Agent' as Type,[High Performing Agent] as MeasureVal from #FinalTable
		order by 1 asc
	select Max([High Performing Agent]) as MaxVal, Min(Score) as MinVal from #FinalTable

end
