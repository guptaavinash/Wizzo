CREATE proc [dbo].[spTestLinkedServerSave]
as
set XACT_ABORT on
--SELECT TOP 1 * FROM [67SERVERSMSDB].SmsDB.dbo.tblOutGoingMsgDetails
INSERT INTO [67SERVERSMSDB].SmsDB.dbo.tblOutGoingMsgDetails(SMSTo,Msg,DateTimeStamp,FlgStatus,IsRecdPicked,AppType,ServiceProvider,SenderId,EntityId,TemplateId)
SELECT '8826887816','test' AS MSg,GETDATE(),0,0,120,'RajTraders','RAJSOP','1201161492702308055','1207164302496529719'

set XACT_ABORT off