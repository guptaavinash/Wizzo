CREATE proc [dbo].[spPopulateProductPrice]
as
begin

UPDATE A SET CnvrsFactor=b.CnvrsFactor FROM [tmpProductPrice] A JOIN [tmpProductPrice] b on a.SKUCode=b.SKUCode
AND A.temp_Region=b.temp_Region
where A.UOM='PCS' and b.UOM='Case'


select SKUCode from [tmpProductPrice] a where UOM='PCS' group by SKUCode having COUNT(distinct CnvrsFactor)>1
if @@ROWCOUNT>0
return
select SKUCode from [tmpProductPrice] a where UOM='PCS' group by SKUCode having COUNT(distinct Wgt)>1
if @@ROWCOUNT>0
return



if OBJECT_ID('tempdb..#ProductPrice') is not null
begin
drop table #ProductPrice
end
select *,0 as PrdNodeId,0 as PrdNodeType,0as RegionId into #ProductPrice from [tmpProductPrice]
Where UOM='PCS'

Update a set PrdNodeId=p.NodeID,PrdNodeType=p.NodeType from #ProductPrice a join tblPrdMstrSKULvl p on a.SKUCode=p.SKUCode

--Delete #ProductPrice where PrdNodeId=0

Update a set RegionId=p.PrcRgnNodeId from #ProductPrice a join tblPriceRegionMstr p on a.temp_Region=p.PrcRegion

insert into tblPriceRegionMstr(PrcRegion)
select distinct A.temp_Region from #ProductPrice A left join tblPriceRegionMstr b on A.temp_Region=b.prcregion
where b.prcrgnNodeId is null



Update a set RegionId=p.PrcRgnNodeId from #ProductPrice a join tblPriceRegionMstr p on a.temp_Region=p.PrcRegion
where RegionId=0

Update a set PcsInBox=b.CnvrsFactor,Grammage=convert(float,b.Wgt)/1000 from tblPrdMstrSKULvl a join #ProductPrice b on a.NodeID=b.PrdNodeId

Delete tblPrdSKUSalesMapping where FromDate=CONVERT(date,getdate()) 
and skunodeid in(select distinct PrdNodeId from #ProductPrice)

Update a set ToDate=DATEADD(dd,-1,getdate()) from tblPrdSKUSalesMapping a where GETDATE() between FromDate and ToDate
and skunodeid in(select distinct PrdNodeId from #ProductPrice)



insert into tblPrdSKUSalesMapping(SKUNodeId,SKUNodeType,SalesNodeType,PrcLocationId1,TaxLocationId1,PrcLocationId,TaxLocationId,BusinessSegmentId,MRP,RetMarginPer,StandardRate,Tax,DistributorMarginPer,DistributorStandardRate,FromDate,ToDate,UOMID)

select PrdNodeId,PrdNodeType,150,1,1,RegionId,1,1,MRP,0,PTR,0,0,PTD,CONVERT(date,getdate()),'2050-12-31',3 from #ProductPrice where isnumeric(PTR)=1 

DELETE tblPrdSKUSalesMapping WHERE GETDATE() between FromDate and ToDate AND StandardRate=0

insert into tblPrdSKUSalesMapping(SKUNodeId, SKUNodeType, SalesNodeType, PrcLocationId1, TaxLocationId1, PrcLocationId, TaxLocationId, UOMID, BusinessSegmentId, MRP, RetMarginPer, Tax, StandardRate, 
                          FromDate, ToDate, DistributorMarginPer,DistributorStandardRate)
SELECT        a.SKUNodeId, a.SKUNodeType, a.SalesNodeType, a.PrcLocationId1, a.TaxLocationId1, a.PrcLocationId, a.TaxLocationId, 1, a.BusinessSegmentId, a.MRP*p.PcsInBox, a.RetMarginPer, a.Tax, a.StandardRate*p.PcsInBox, a.FromDate, a.ToDate, a.DistributorMarginPer,a.DistributorStandardRate*p.PcsInBox
FROM            tblPrdSKUSalesMapping AS a INNER JOIN
                         tblPrdMstrSKULvl AS p ON a.SKUNodeId = p.NodeID
WHERE        (GETDATE() BETWEEN a.FromDate AND a.ToDate) and a.UOMID=3
and a.SKUNodeId in(select distinct PrdNodeId from #ProductPrice)

truncate table tblPrdMstrTransactionUOMConfig
insert into tblPrdMstrTransactionUOMConfig
select NodeID,1,1,1,0,0,0,1 from tblPrdMstrSKULvl
union all
select NodeID,3,0,2,1,1,1,0 from tblPrdMstrSKULvl
truncate table tblPrdMstrPackingUnits_ConversionUnits

insert into tblPrdMstrPackingUnits_ConversionUnits

select NodeID,1,3,1,PcsInBox,0,GETDATE(),0,GETDATE(),1,1,1,1,20,1 from tblPrdMstrSKULvl

truncate table tblPrdMstrRptngUnits_ConversionUnits
insert into tblPrdMstrRptngUnits_ConversionUnits

select NodeID,1,3,4,Grammage*1000,0,GETDATE(),0,GETDATE(),NodeType from tblPrdMstrSKULvl

end