




--[spGetPurchaseReqList] 

CREATE proc	[dbo].[spGetPurchaseReqList]
@ReqFromDate date,
@ReqToDate date,
@DbrNodeId int,
@DbrNodeType Int,
@StatusId int
as
begin
select a.PurchReqId,a.PurchReqNo AS [PO No.],Replace(Convert(varchar,a.ReqDate,106),' ','-') as [PO Date],Replace(Convert(varchar,a.Expectedby,106),' ','-') as [Required by], 
b.POProcessStatus  as Status,a.StatusId as StatusId  from tblPurchaseReqMaster A 
join [dbo].[tblMstrPurchaseReqProcessStatus] b on A.StatusId=b.POProcessStatusId
where 
ReqDate between @ReqFromDate and @ReqToDate
AND 
SalesNodeId=@DbrNodeId
and SalesNodeType=@DbrNodeType

and (a.StatusId =@StatusId or @StatusId=-1)
select DistributorCode,Descr as Distributor from tblDBRSalesStructureDBR where NodeID=@DbrNodeId and NodeType=@DbrNodeType
end






