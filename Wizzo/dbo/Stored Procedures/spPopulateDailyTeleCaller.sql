

CREATE proc [dbo].[spPopulateDailyTeleCaller]
@TCDailyId int,
@TCNodeId int,
@TCNodeType int,
@CallDate date,
@StatusId int,--1=Start Call ,2=Hold Call,3=Resume Call,4=End Call for the Day
@LoginId int,
@Breakreason int=0
as
begin
--select @TCDailyId=TCDailyId from tblTeleCallerDailyMstr where TCNodeId=@TCNodeId and TCNodeType=@TCNodeType
--and TCDate=@CallDate

DECLARE @currdate datetime=dbo.fnGetCurrentDateTime()

if isnull(@TCDailyId,0)=0
begin
insert into tblTeleCallerDailyMstr(TCNodeId,TCNodeType,CallDate,StatusId,StartCall,LoginIdIns,TimeStampIns)
select TelecallerId,NodeType,@CallDate,1,@currdate,@LoginId,@currdate from tblTeleCallerMstr A where TeleCallerId=@TCNodeId and NodeType=@TCNodeType
		SET @TCDailyId=@@IDENTITY

End
else
begin

update tblTeleCallerDailyMstr set StatusId=@StatusId,EndCall=case when @StatusId=4 then @currdate else null  end,LoginIdUpd=@LoginId,TimeStampUpd=GETDATE(),BreakReasonId=@Breakreason where TCDailyId=@TCDailyId
end
insert into tblTeleCallerDailyActivityDet(TCDailyId,StatusId,TimeStampIns,BreakReasonId) values(@TCDailyId,@StatusId,@currdate,@Breakreason)

select @TCDailyId as TCDailyId
end
