CREATE proc [dbo].[spRefreshDailySuggestedOrderData]
as
begin
Declare @FromDate date=dateadd(dd,-90,dbo.fnGetCurrentDateTime())

Declare @P4MDate date=dateadd(dd,-1,@FromDate)
Declare @P6MDate date=dateadd(dd,-90,@FromDate)

--select NodeID,NodeType into #DBRList from tblDBRSalesStructureDBR  where IsActive=1

if object_id('tempdb..#InvCodeList') is not null
begin
	drop table #InvCodeList
end
;with ashcte as(
select FAOrdId,StoreId,FAOrderNo,FAOrderDate,ROW_NUMBER() over(partition by StoreId order by StoreId,FAOrdId desc) as rown from tblFAORDERmASTER a  where  FAOrderDate>=@FromDate
and FAOrderDate<CONVERT(date,GETDATE())
)

select * into #InvCodeList from ashcte 
--where rown<=6
--select * from #InvCodeList
--select @FromDate
truncate table [tblP3MSalesDetail]
insert into [tblP3MSalesDetail]
select 0,0,0,0,a.StoreId,b.PrdId,20,b.FAOrdId,a.FAOrderNo,a.FAOrderDate,b.Qty,b.NetOrderValue,0,0,b.NetOrderValue,0,1 from #InvCodeList a join tblFAOrderDetail b on a.FAOrdId=b.FAOrdId
union all
select t.DistNodeId,t.DistNodeType,t.TCNodeId,t.TCNodeType,a.StoreId,b.PrdNodeId,b.PrdNodeType,a.orderid,a.OrderCode,a.OrderDate,b.OrderQty,b.LineOrderValWDisc,0,b.TotTaxValue,b.NetLineOrderVal,0,2 from tblTCOrderMaster a join tblTCOrderDetail b on a.OrderId=b.OrderId
join vwtelecallerlistforday t on t.telecallingid=a.TeleCallingId
where  t.date>=@FromDate and t.Date<CONVERT(date,GETDATE()) --t.flgCallConversionStatus=1  and
union all
select a.SalesNodeId,a.SalesNodeType,a.SalesPersonID,a.SalesPersonType,a.StoreId,b.ProductID,20,a.orderid,a.OrderCode,a.OrderDate,b.OrderQty,b.LineOrderValWDisc,0,b.TotTaxValue,b.NetLineOrderVal,0,3 from tblOrderMaster a join tblOrderDetail b on a.OrderId=b.OrderId
where  a.orderdate>=@FromDate and a.OrderStatusID<>3 and a.orderdate<CONVERT(date,GETDATE())

---Avinash Sir Sp
exec SpPopulateStoreListForValidation

truncate table [tblP4MP6MStoreSuggestedData]
insert into [tblP4MP6MStoreSuggestedData]
select MAX(SalesNodeId),MAX(SalesNodeType),StoreId,PrdId,PrdNodeType,AVG(Qty),AVG(NetOrderValue),0
from(
select 0 AS SalesNodeId,0 as SalesNodetype,a.StoreId,b.PrdId,20 as PrdNodeType,b.Qty,b.NetOrderValue from tblFAOrderMaster a join tblFAOrderDetail b on a.FAOrdId=b.FAOrdId
where a.FAOrderDate between @P6MDate and @P4MDate
union all
select t.DistNodeId,t.DistNodeType,a.StoreId,b.PrdNodeId,b.PrdNodeType,b.OrderQty,b.NetLineOrderVal from tblTCOrderMaster a join tblTCOrderDetail b on a.OrderId=b.OrderId
join vwtelecallerlistforday t on t.telecallingid=a.TeleCallingId
where  t.date between @P6MDate and @P4MDate
union all
select a.SalesNodeId,a.SalesNodeType,a.StoreId,b.ProductID,20,b.OrderQty,b.NetLineOrderVal from tblOrderMaster a join tblOrderDetail b on a.OrderId=b.OrderId
where  a.orderdate between @P6MDate and @P4MDate and a.OrderStatusID<>3 
) as a
group by StoreId,PrdId,PrdNodeType

end
