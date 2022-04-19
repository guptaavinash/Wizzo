
CREATE proc [dbo].[spGetTeleCallerMessage]
@CycFileId bigint
as
begin

select MessageID into #Message from mrco_TelecallerMessageMaster  where  flgSent in(0,1,3) 

Update a set CycFileId=@CycFileId,flgSent=1 from mrco_TelecallerMessageMaster  a join #Message b on a.MessageID=b.MessageID
 where a.CycFileId is null 

 Update a set CycFileId=@CycFileId from mrco_TelecallerMessage_DistList  a join #Message b on a.MessageID=b.MessageID
 where a.CycFileId is null 

 SELECT 1

end
