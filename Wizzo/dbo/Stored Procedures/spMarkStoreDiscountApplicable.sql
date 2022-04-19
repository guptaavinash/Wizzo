CREATE proc [dbo].[spMarkStoreDiscountApplicable]
@StoreIds NodeIds readonly,---NodeId=Storeid,NodeType=IsDiscountApplicable
@LoginId int
as
begin
Declare @currdate datetime=Getdate()
Update a set IsDiscountApplicable=b.NodeType,LoginIdUpd=@LoginId,TimeSTampUpd=@currdate from tblTeleCallerListForDay a join @StoreIds b on a.StoreId=b.NodeId
where Date=convert(date,@currdate)

Update a set IsDiscountApplicable=b.NodeType,LoginIdUpd=@LoginId,TimeSTampUpd=@currdate from tblStoreMaster a join @StoreIds b on a.StoreId=b.NodeId


end