

--select * from tblTeleCallerListForDay where date='13-Feb-2021'
CREATE proc [dbo].[spPopulateMessageDetail]  
@TeleCallingId int
as
begin
Declare @MessageId int=0
insert into mrco_TelecallerMessageMaster(MessageTitle,Description,StartDate,EndDate,CreatedBy,CreatedDate)
select 'Comments For DSE '+StoreName,DSEComments,dbo.fnGetCurrentDateTime(),dbo.fnGetCurrentDateTime(),1,dbo.fnGetCurrentDateTime() from tblTeleCallerListForDay where TeleCallingId=@TeleCallingId and flgCallStatus=2 and isnull(DSEComments,'')<>''
union all
select 'No Order Reason '+StoreName,b.REASNCODE_LVL2NAME +case when  isnull(DSEComments,'')<>'' then ','+isnull(DSEComments,'') else '' end ,dbo.fnGetCurrentDateTime(),dbo.fnGetCurrentDateTime(),1,dbo.fnGetCurrentDateTime() from tblTeleCallerListForDay a join tblReasonCodeMstr b on a.ReasonId=b.ReasonCodeID where TeleCallingId=@TeleCallingId and flgCallStatus=1 and ReasonCodeID<>8
set @MessageId=@@IDENTITY
if @MessageId>0
begin
insert into  mrco_TelecallerMessage_DistList (MessageID,DistributorId,RetailerCode,CreatedBy,CreatedDate,TeleCallingId)
select @MessageId,b.DistributorCode,StoreCode,1,dbo.fnGetCurrentDateTime(),@TeleCallingId from tblTeleCallerListForDay a join tblDBRSalesStructureDBR b on a.DistNodeId=b.NodeID where TeleCallingId=@TeleCallingId

end


end
