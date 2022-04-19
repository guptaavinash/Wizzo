

Create proc [dbo].[spTransferTeleCallerMessageStatus]
@CycFileId bigint,
@flgStatus tinyint---1=Success,2=Error
as
begin

if @flgStatus=1
begin
Update mrco_TelecallerMessageMaster set flgSent=2 where CycFileId=@CycFileId and flgSent =1
end
else if @flgStatus=2
begin
Update mrco_TelecallerMessageMaster set flgSent=0 where CycFileId=@CycFileId and flgSent =1
end
end
