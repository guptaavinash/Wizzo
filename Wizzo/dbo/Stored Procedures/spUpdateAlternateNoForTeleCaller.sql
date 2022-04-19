



CREATE proc [dbo].[spUpdateAlternateNoForTeleCaller]
@TeleCallingId int,
@AlternateContactNo varchar(50),
@LoginId int
as
begin
Update tblTeleCallerListForDay set AlternateContactNo=@AlternateContactNo,LoginIdUpd=@LoginId,TimeSTampUpd=[dbo].[fnGetCurrentDateTime]() where TeleCallingId=@TeleCallingId

end
