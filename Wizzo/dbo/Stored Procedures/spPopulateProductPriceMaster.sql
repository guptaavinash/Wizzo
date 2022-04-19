CREATE proc [dbo].[spPopulateProductPriceMaster]
as
begin
SELECT        distinct Category, SKUCode, SKU, MRP, SKUShortDescr,  Max(RLPWithTax) as RLPWithTax, UOMValue, UOMType, RelConversionUnit, BoxUOMType, 0 AS CatId, 0 AS CaseUOMId,CustPrdWeightInGm
INTO              [#ProductListAPI]
FROM            tmpRawProductPriceMstr AS a
group by Category, SKUCode, SKU, MRP, SKUShortDescr,  UOMValue, UOMType, RelConversionUnit, BoxUOMType,CustPrdWeightInGm

insert into tblPrdMstrHierLvl1(Code,Descr,NodeType,FileSetIdIns,TimestampIns)
select distinct Category,Category,10,0,GETDATE() from #ProductListAPI a left join tblPrdMstrHierLvl1  b on a.Category=b.Descr
where b.NodeID is null

Update a set CatId=b.catid from #ProductListAPI a join tblPrdAttr_Category b on CONVERT(VARCHAR,CONVERT(FLOAT,UOMValue))+' '+UOMType=b.CatName
insert into tblPrdAttr_Category(CatName)
select distinct CONVERT(VARCHAR,CONVERT(FLOAT,UOMValue))+' '+UOMType from #ProductListAPI where isnull(catid,0)=0 

Update a set CatId=b.catid from #ProductListAPI a join tblprdattr_category b on CONVERT(VARCHAR,CONVERT(FLOAT,UOMValue))+' '+UOMType=b.CatName where a.CatId=0


Update a set CaseUOMId=b.BUOMID from #ProductListAPI a join tblPrdMstrBUOMMaster b on a.BoxUOMType=b.BUOMName
insert into tblPrdMstrBUOMMaster(BUOMName,LoginIDCreate,TimeStampCreate,LoginIDMod,TimeStampMod,flgConversionUnit)
select distinct BoxUOMType,0,GETDATE(),0,GETDATE(),1 from #ProductListAPI where isnull(CaseUOMId,0)=0 

Update a set CaseUOMId=b.BUOMID from #ProductListAPI a join tblPrdMstrBUOMMaster b on a.BoxUOMType=b.BUOMName where isnull(CaseUOMId,0)=0 

Update b set Descr=a.SKU,ShortDescr=a.SKUShortDescr,StandardRate=a.RLPWithTax,StandardRateBeforeTax=a.RLPWithTax,PrdTypeId=a.catid,UOMID=a.CaseUOMId,TimestampUpd=GETDATE(),
MRP=case when a.MRP is not null then a.MRP else b.MRP end,PcsInBox=RelConversionUnit,Grammage=a.CustPrdWeightInGm/1000

from #ProductListAPI a join tblPrdMstrSKULvl  b on a.SKUCode=b.SKUCode

insert into tblPrdMstrSKULvl(SKUCode,Descr,ShortDescr,NodeType,TimestampIns,IsActive,PcsInBox,StandardRate,StandardRateBeforeTax,PrdTypeId,UomId,SectorId,Grammage,Tax,BrandID,ManufacturerID,RetMarginPer,flgSeq,DistMarginPer,PriceTypeId,flgPriceAva,MRP,UOMType,UOMValue,flgSaleType)
select distinct a.SKUCode,a.SKU,a.SKUShortDescr,20,GETDATE(),1,RelConversionUnit,(a.RLPWithTax),(a.RLPWithTax),a.CatId,a.CaseUOMId,1,a.CustPrdWeightInGm/1000,0,10,10,0,0,0,0,0,(ISNULL(A.MRP,0)),a.UOMType,a.UOMValue,2 from #ProductListAPI a left join tblPrdMstrSKULvl  b on a.SKUCode=b.SKUCode
where b.NodeID is null-- AND Deactivated='False'



insert into tblPrdMstrHierarchy
select DISTINCT a.NodeID,a.NodeType,0,0,1,0,CONVERT(date,getdate()),'2050-12-31',0 from tblPrdMstrHierLvl1 a left join tblPrdMstrHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType
where b.NodeID is null


UPDATE b set VldTo=convert(date,DATEADD(dd,-1,getdate()))
from tblPrdMstrSKULvl a 

join #ProductListAPI p on p.SKUCode=a.SKUCode
join tblPrdMstrHierLvl1 c on c.descr=p.Category
join tblPrdMstrHierarchy h on h.NodeID=c.NodeID
and h.NodeType=c.NodeType
join tblPrdMstrHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo
where  b.PNodeID<>h.NodeID

insert into tblPrdMstrHierarchy
select DISTINCT a.NodeID,a.NodeType,h.NodeID,h.NodeType,1,h.HierID,CONVERT(date,getdate()),'2050-12-31',0 from tblPrdMstrSKULvl a 

join #ProductListAPI p on p.SKUCode=a.SKUCode
join tblPrdMstrHierLvl1 c on c.descr=p.Category
join tblPrdMstrHierarchy h on h.NodeID=c.NodeID
and h.NodeType=c.NodeType
left join tblPrdMstrHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo
where b.NodeID is null


if OBJECT_ID('tempdb..#ProductPrice') is not null
begin
drop table #ProductPrice
end
select *,0 as PrdNodeId,0 as PrdNodeType,0as RegionId into #ProductPrice from tmpRawProductPriceMstr

Update a set PrdNodeId=p.NodeID,PrdNodeType=p.NodeType from #ProductPrice a join tblPrdMstrSKULvl p on a.SKUCode=p.SKUCode

--Delete #ProductPrice where PrdNodeId=0

Update a set RegionId=p.PrcRgnNodeId from #ProductPrice a join tblPriceRegionMstr p on a.PrcRegion=p.PrcRegion

insert into tblPriceRegionMstr(PrcRegion)
select distinct A.PrcRegion from #ProductPrice A left join tblPriceRegionMstr b on A.PrcRegion=b.prcregion
where b.prcrgnNodeId is null



Update a set RegionId=p.PrcRgnNodeId from #ProductPrice a join tblPriceRegionMstr p on a.PrcRegion=p.PrcRegion
where RegionId=0

Delete tblPrdSKUSalesMapping where FromDate=CONVERT(date,getdate())
Update a set ToDate=DATEADD(dd,-1,getdate()) from tblPrdSKUSalesMapping a where GETDATE() between FromDate and ToDate
and skunodeid in(select distinct PrdNodeId from #ProductPrice)

insert into tblPrdSKUSalesMapping(SKUNodeId,SKUNodeType,SalesNodeType,PrcLocationId1,TaxLocationId1,PrcLocationId,TaxLocationId,BusinessSegmentId,MRP,RetMarginPer,StandardRate,Tax,DistributorMarginPer,DistributorStandardRate,FromDate,ToDate,UOMID)

select PrdNodeId,PrdNodeType,150,1,1,RegionId,1,1,MRP,0,RLPWithTax,0,0,DLPWithTax,CONVERT(date,getdate()),'2050-12-31',3 from #ProductPrice

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

