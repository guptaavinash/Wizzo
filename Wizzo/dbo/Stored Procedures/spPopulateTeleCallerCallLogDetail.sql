
CREATE proc [dbo].[spPopulateTeleCallerCallLogDetail]
@TeleCallingId int,
	@flgOrderSource tinyint=1,
	@StartTime datetime,
	--@EndTime datetime,
	@flgCallStatus tinyint=1,
	@ReasonId int,
	@ScheduleCall varchar(50)='',
	@LoginId int,
	@PhoneNo varchar(100),
	@DSEComments varchar(500),
	@TotalOrderValue numeric(18,2)=0,
	@NoOfSKU int=0,
	@flgCallType tinyint,
	@DialingFrequency tinyint
as
begin
declare @EndTime datetime=dbo.fnGetCurrentDateTime()
insert into tblTeleCallerCallLogDetail(TeleCallingId,	flgOrderSource	,StartTime	,EndTime	,flgCallStatus	,ReasonId	,ScheduleCall	,LoginIdIns	,TimeStampIns	,PhoneNo,	DSEComments	,TotalOrderValue	,NoOfSKU	,flgCallType	,DialingFrequency)
values(@TeleCallingId,	@flgOrderSource	,@StartTime	,@EndTime	,@flgCallStatus	,@ReasonId	,@ScheduleCall	,@LoginId	,dbo.fnGetCurrentDateTime(),@PhoneNo,	@DSEComments	,@TotalOrderValue	,@NoOfSKU	,@flgCallType	,@DialingFrequency)

end
