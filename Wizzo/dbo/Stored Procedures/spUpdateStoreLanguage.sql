
Create proc [dbo].[spUpdateStoreLanguage]
@StoreId int,
@TeleCallingId int,
@LanguageId tinyint,
@LoginId int
as
begin
Declare @Currdate datetime=dbo.fnGetCurrentDateTime()
Update tblTeleCallerListForDay set LanguageId=@LanguageId,LoginIdUpd=@LoginId,TimeSTampUpd=@Currdate
where TeleCallingId=@TeleCallingId


Update tblStoreMaster set LanguageId=@LanguageId,LoginIdUpd=@LoginId,TimeSTampUpd=@Currdate
where StoreID=@StoreId


end
