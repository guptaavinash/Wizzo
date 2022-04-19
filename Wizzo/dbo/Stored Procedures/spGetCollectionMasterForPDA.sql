CREATE proc [dbo].[spGetCollectionMasterForPDA]
AS
begin
select BankID,BankName from tblMstrBank

select * from tblMstrinstrumentmode
end
