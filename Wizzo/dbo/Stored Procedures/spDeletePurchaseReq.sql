





CREATE proc [dbo].[spDeletePurchaseReq]
@PurchReqId OrderReasonMap readonly,
@LoginId int,
@SalesNodeId int,
@SalesNodeType int,
@Fyid int
as
begin
Update A set StatusId=4,LoginIDUpd=@LoginId,TimestampUpd=Getdate() from [dbo].[tblPurchaseReqDetail] A join @PurchReqId B on A.PurchReqId=B.OrderId

insert into [dbo].[tblPurchaseReqLogDetail]
select distinct b.OrderId,a.POCategoryId,4,@LoginId,Getdate() from [dbo].[tblPurchaseReqDetail] A join @PurchReqId B on A.PurchReqId=B.OrderId
end






