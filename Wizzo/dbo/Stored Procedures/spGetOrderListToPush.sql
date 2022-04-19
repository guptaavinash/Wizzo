

CREATE proc [dbo].[spGetOrderListToPush]
@CycFileId bigint
as
Declare @currdate datetime=dbo.fnGetCurrentDateTime()
update tblTCOrderMaster set flgSent=3 where OrderDate=convert(date,@currdate)
and isnull(flgSent,0)=0 and datepart(hour,@currdate)<17 and dateadd(hour,2,TimestampIns)<=@currdate

update tblTCOrderMaster set flgSent=3 where OrderDate=convert(date,@currdate)
and isnull(flgSent,0)=0 and datepart(hour,@currdate)>=17 

insert into [mrco_MI_TELE_ORDER]([DIST_CODE]
      ,[RETAILER_CODE]
      ,[RETAILER_NAME]
      ,[BEAT_DESC]
      ,[SKU_CODE]
      ,[SKU_DESC]
      ,[ORDER_QTY]
      ,[TELE_ORDER_NO]
      ,[TELE_CALLER_ID]
      ,[TELE_CALLER_NAME]
      ,[DOWNLOAD_FLAG]
      ,[ORDER_DATE]
      ,[RouteGTMType],CycleId)
select d.DistributorCode as DistCode,s.CSRtrCode as RETAILER_CODE,s.StoreName as RETAILER_NAME,t.RouteName as BEAT_DESC,p.Code as SKU_CODE,p.Descr as SKU_DESC,b.OrderQty as ORDER_QTY,a.OrderCode  as TELE_ORDER_NO,u.TeleCallerCodeForExtract as  TELE_CALLER_ID,u.TeleCallerName as TELE_CALLER_NAME,'N'  as DOWNLOAD_FLAG,A.OrderDate as ORDER_DATE,t.RouteGTMType,@CycFileId from tblTCOrderMaster a join tblTCOrderDetail b on a.OrderID=b.OrderID
join  tblPrdMstrHierLvl7 p on p.NodeID=b.PrdNodeId
and p.NodeType=b.PrdNodeType
join tblDBRSalesStructureDBR d on d.NodeID=a.DistNodeId
and d.NodeType=a.DistNodeType
join tblStoreMaster s on s.StoreID=a.StoreID
join tblTeleCallerListForDay t on t.TeleCallingId=a.TeleCallingId
join tblTeleCallerMstr u on u.TeleCallerId=t.TCNodeId
where OrderDate=convert(date,@currdate)
and isnull(flgSent,0) in(3,1)


update tblTCOrderMaster set flgSent=1,CycleId=@CycFileId where OrderDate=convert(date,@currdate)
and isnull(flgSent,0) in(3,1)

SELECT 1
