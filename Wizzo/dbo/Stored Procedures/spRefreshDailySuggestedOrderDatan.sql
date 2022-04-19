CREATE proc [dbo].[spRefreshDailySuggestedOrderDatan]
as
begin
Declare @FromDate date=dateadd(dd,-90,dbo.fnGetCurrentDateTime())


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
truncate table [tblP3MSalesDetailn]
insert into [tblP3MSalesDetailn]
select 0,0,0,0,a.StoreId,b.PrdId,20,b.FAOrdId,a.FAOrderNo,a.FAOrderDate,b.Qty,b.NetOrderValue,0,0,b.NetOrderValue,0,1 from #InvCodeList a join tblFAOrderDetail b on a.FAOrdId=b.FAOrdId
union all
select t.DistNodeId,t.DistNodeType,t.TCNodeId,t.TCNodeType,a.StoreId,b.PrdNodeId,b.PrdNodeType,a.orderid,a.OrderCode,a.OrderDate,b.OrderQty,b.LineOrderValWDisc,0,b.TotTaxValue,b.NetLineOrderVal,0,2 from tblTCOrderMaster a join tblTCOrderDetail b on a.OrderId=b.OrderId
join vwtelecallerlistforday t on t.telecallingid=a.TeleCallingId
where  t.date>=@FromDate and t.Date<CONVERT(date,GETDATE()) --t.flgCallConversionStatus=1  and
union all
select a.SalesNodeId,a.SalesNodeType,a.SalesPersonID,a.SalesPersonType,a.StoreId,b.ProductID,20,a.orderid,a.OrderCode,a.OrderDate,b.OrderQty,b.LineOrderValWDisc,0,b.TotTaxValue,b.NetLineOrderVal,0,3 from tblOrderMaster a join tblOrderDetail b on a.OrderId=b.OrderId
where  a.orderdate>=@FromDate and a.OrderStatusID<>3 and a.orderdate<CONVERT(date,GETDATE())

-----Avinash Sir Sp
--exec SpPopulateStoreListForValidation
end
