





CREATE proc [dbo].[spApproveRejectPurchaseReq]
@PurchReqId OrderReasonMap readonly,
@LoginId int,
@StatusId int---4=Rejected By ASM,3=Rejected By So,1=ASM Approved,2=Download the PO
as
begin
Update A set StatusId=@StatusId,LoginIDUpd=@LoginId,TimestampUpd=Getdate() from [dbo].[tblPurchaseReqMaster] A join @PurchReqId B on A.PurchReqId=B.OrderId

insert into [dbo].[tblPurchaseReqLogDetail]
select distinct b.OrderId,1,@StatusId,@LoginId,Getdate() from [dbo].tblPurchaseReqMaster A join @PurchReqId B on A.PurchReqId=B.OrderId
end






