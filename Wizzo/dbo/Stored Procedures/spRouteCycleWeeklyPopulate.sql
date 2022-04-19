CREATE proc [dbo].[spRouteCycleWeeklyPopulate]
as
begin
set datefirst 1
Declare @MinDate date='21-Dec-2020',@CycleId int=0,@i int=1,@TotCycleCnt int=39,@WkDate date,@wi int=1,
@WkNo tinyint=1

select @WkDate=dateadd(dd,6,isnull(dateadd(dd,1,max(EndDate)),@MinDate)) from tblRouteWeekMstr

while @i<=@TotCycleCnt
begin

if @WkNo=14
set @WkNo=1

insert into tblRouteCycleMstr(RouteCycDescr) values('Cycle_'+convert(varchar,Year(dateadd(dd,6,@WkDate)))+'_'+CONVERT(varchar,@WkNo))
set @CycleId =@@IDENTITY

select @WkDate=isnull(dateadd(dd,1,max(EndDate)),@MinDate) from tblRouteWeekMstr where RouteCycId< @CycleId

set @wi=1
	while @wi<=4
	begin
		
		insert into tblRouteWeekMstr values(@CycleId,@wi,@WkDate,DATEADD(dd,6,@wkdate),DATEPART(WK,DATEADD(dd,6,@wkdate)))

		set @WkDate=dateadd(dd,7,@WkDate)
	set @wi=@wi+1
	end
set @WkNo=@WkNo+1
	set @i=@i+1
end
set datefirst 7
end
