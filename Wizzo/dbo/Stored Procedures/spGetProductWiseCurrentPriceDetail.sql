
--select * from tblPrdSKUSalesMapping where GETDATE() between FromDate and ToDate
--[spGetProductWiseCurrentPriceDetail] 330,150,'18-nov-21'
CREATE proc [dbo].[spGetProductWiseCurrentPriceDetail]
@SalesNodeId int,
@SalesNodeType int,
@Date date
as
begin
      Declare @PriceLocationId int=1


	  select @PriceLocationId=ISNULL(PrcRegionId,1) from tbldbrsalesstructuredbr(nolock) a  where NodeID=@SalesNodeId and NodeType=@SalesNodeType AND PrcRegionId IS NOT NULL
	    print convert(varchar,getdate(),109)
	  select * into #ProductPriceTax from [dbo].[tblPrdSKUSalesMapping](nolock)
	  where 1<>1 and SalesNodeType=@SalesNodeType

--insert into #ProductPriceTax
--select *  from [dbo].[tblPrdSKUSalesMapping] where --ASMNodeId=@ASMNodeId and ASMNodeType=@ASMNodeType
----and 
-- SalesNodeType=@SalesNodeType and PrcLocationId=@PriceLocationId and
--(@Date BETWEEN Fromdate AND ToDate) 



print @PriceLocationId
print @Date
insert into #ProductPriceTax
select *  from [dbo].[tblPrdSKUSalesMapping](nolock) where --ASMNodeId=@ASMNodeId and ASMNodeType=@ASMNodeType
--and 
 SalesNodeType=@SalesNodeType and PrcLocationId=@PriceLocationId and
(@Date BETWEEN Fromdate AND ToDate) and UOMID=3


print convert(varchar,getdate(),109)
alter table #ProductPriceTax add 
SSMarginPer numeric(18,2),StandardRateForSS   numeric(18,4),StandardRateBeforeTaxForSS   numeric(18,4)

update A set SSMarginPer=B.SSMarginPer from #ProductPriceTax A join tblPrdMstrSKULvl B on A.SKUNodeId=B.NodeID
print convert(varchar,getdate(),109)
UPDATE #ProductPriceTax set StandardRateForSS=DistributorStandardRate/(1+SSMarginPer/100)
UPDATE #ProductPriceTax set StandardRateBeforeTaxForSS=StandardRateForSS/(1+Tax/100)

print convert(varchar,getdate(),109)
select distinct SKUNodeId,MRP,Tax,RetMarginPer,StandardRate,StandardRateBeforeTax,DistributorMarginPer as DistMarginPer,DistributorStandardRate as StandardRateForDist,DistributorStandardRateBeforeTax as StandardRateBeforeTaxForDist,SSMarginPer,StandardRateForSS,StandardRateBeforeTaxForSS,BusinessSegmentId,PrcLocationId,TaxLocationId from #ProductPriceTax
end



