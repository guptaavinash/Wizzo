




--exec spGetPurchaseReqProductMasters @searchText=N'',@SalesNodeId=62,@SalesNodeType=150,@Fyid=18
--exec [spGetPurchaseReqProductMasters] '',1,150,17
CREATE proc [dbo].[spGetPurchaseReqProductMastersN]
@searchText varchar(50),
@SalesNodeId int,
@SalesNodeType int
as
Declare @IsSuperStockiest bit
Declare @PlantDepotId int=0
DECLARE @StateID INT

Declare @dATE date=getdate()

Create table #ProductPrice(SKUNodeId int,MRP numeric(18,2),Tax numeric(18,2),RetMarginPer numeric(18,10),
StandardRate numeric(18,10),StandardRateBeforeTax numeric(18,10),DistMarginPer numeric(18,10),StandardRateForDist   numeric(18,10),StandardRateBeforeTaxForDist   numeric(18,10)
,SSMarginPer numeric(18,10)
,
StandardRateForSS   numeric(18,10),StandardRateBeforeTaxForSS   numeric(18,10),BusinessSegmentId int,PrcLocationId INT,TaxLocationId INT)

insert into #ProductPrice
exec [spGetProductWiseCurrentPriceDetail] @SalesNodeId,@SalesNodeType,@dATE


;with ashdup as (
select *,row_number() over(partition by SKUNodeId order by SKUNodeId,MRP desc)as rown from #ProductPrice )
delete ashdup where rown>1




select 0 as ProductId,0 as BookedStock into #tmpBooked
Declare @Sqlstr nvarchar(4000)='',@SqlSearch nvarchar(4000)=''

select * into #ProdList from VwSFAProductHierarchy 
select @SqlSearch=@SqlSearch+'and ''|''+Category+''|''+ SKU+''|''+ SKUCode like ''%'+items+'%'''  from dbo.split(@searchText,',')
	where items<>''

set @Sqlstr='select A.SKUNodeID,Skunodetype,sku,skushortdescr,category,P.MRP as MRP,'+case when @IsSuperStockiest=1 then 'P.StandardRateForSS*A.PcsInBox' else 'P.StandardRateForDist*A.PcsInBox' end+' AS StandardRate,'+case when @IsSuperStockiest=1 then  'P.StandardRateBeforeTaxForSS*A.PcsInBox' else 'P.StandardRateBeforeTaxForDist*A.PcsInBox' end +
' as StandardRateBeforeTax,StandardTax*A.PcsInBox as StandardTax,P.Tax,a.UOMID,Grammage,SKUCode,'+case when @IsSuperStockiest=1 then  'P.SSMarginPer' else 'P.DistMarginPer' end +' AS DistMarginPer,UOM,UOMValue,UOMType
, P.RetMarginPer,''|''+Category+''|''+ SKU+''|''+ SKUCode as SearchField,CategoryNodeID

From #ProdList AS A 
	join #ProductPrice P on P.SKUNodeId=A.SKUNodeId
	where P.MRP is not null '+@SqlSearch+' order by category,grammage'
	

 print @Sqlstr 
 exec sp_executesql @Sqlstr

 select distinct category,CategoryNodeID,UOMValue,UOMType
 From #ProdList order by 1




