CREATE proc [dbo].[spPopulateProductMaster]
as
begin
return;
select ProductERPId,MAX(Id) as PrdLastId into #LastData from tmpRawDataProductListAPI
group by ProductERPId
select a.*,0 as CatId,0 as CaseUOMId into #ProductListAPI from tmpRawDataProductListAPI a join #LastData b on a.Id=b.PrdLastId

insert into tblPrdMstrHierLvl1(Code,Descr,NodeType,FileSetIdIns,TimestampIns)
select distinct Brand,Brand,10,0,GETDATE() from #ProductListAPI a left join tblPrdMstrHierLvl1  b on a.Brand=b.Code
where b.NodeID is null

Update a set CatId=b.catid from #ProductListAPI a join tblprdattr_category b on a.Category=b.CatName
insert into tblPrdAttr_Category(CatName)
select distinct Category from #ProductListAPI where isnull(catid,0)=0 

Update a set CatId=b.catid from #ProductListAPI a join tblprdattr_category b on a.Category=b.CatName where a.CatId=0


Update a set CaseUOMId=b.BUOMID from #ProductListAPI a join tblPrdMstrBUOMMaster b on a.StandardUnit=b.BUOMName
insert into tblPrdMstrBUOMMaster(BUOMName,LoginIDCreate,TimeStampCreate,LoginIDMod,TimeStampMod,flgConversionUnit)
select distinct StandardUnit,0,GETDATE(),0,GETDATE(),1 from #ProductListAPI where isnull(CaseUOMId,0)=0 

Update a set CaseUOMId=b.BUOMID from #ProductListAPI a join tblPrdMstrBUOMMaster b on a.StandardUnit=b.BUOMName where isnull(CaseUOMId,0)=0 

Update b set Descr=a.Name,ShortDescr=a.Name,IsActive=case when Deactivated='False' then 1 else 0 end,StandardRate=a.Price,StandardRateBeforeTax=a.Price,PrdTypeId=a.catid,UOMID=a.CaseUOMId,TimestampUpd=GETDATE(),
MRP=case when a.MRP is not null then a.MRP else b.MRP end,PcsInBox=convert(numeric(18,0),StandardUnitConversionFactor)

from #ProductListAPI a join tblPrdMstrSKULvl  b on a.ProductERPId=b.SKUCode

insert into tblPrdMstrSKULvl(SKUCode,Descr,ShortDescr,NodeType,TimestampIns,IsActive,PcsInBox,StandardRate,StandardRateBeforeTax,PrdTypeId,UomId,SectorId,Grammage,Tax,BrandID,ManufacturerID,RetMarginPer,flgSeq,DistMarginPer,PriceTypeId,flgPriceAva,MRP,UOMType,UOMValue,flgSaleType)
select distinct ProductERPId,a.Name,a.Name,20,GETDATE(),case when Deactivated='False' then 1 else 0 end,convert(numeric(18,0),StandardUnitConversionFactor),a.Price,a.Price,a.CatId,a.CaseUOMId,1,0,0,10,10,0,0,0,0,0,ISNULL(A.MRP,0),'gm',0,2 from #ProductListAPI a left join tblPrdMstrSKULvl  b on a.ProductERPId=b.SKUCode
where b.NodeID is null-- AND Deactivated='False'



insert into tblPrdMstrHierarchy
select a.NodeID,a.NodeType,0,0,1,0,CONVERT(date,getdate()),'2050-12-31',0 from tblPrdMstrHierLvl1 a left join tblPrdMstrHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType
where b.NodeID is null


UPDATE b set VldTo=convert(date,DATEADD(dd,-1,getdate()))
from tblPrdMstrSKULvl a 

join #ProductListAPI p on p.ProductERPId=a.SKUCode
join tblPrdMstrHierLvl1 c on c.Code=p.Brand
join tblPrdMstrHierarchy h on h.NodeID=c.NodeID
and h.NodeType=c.NodeType
join tblPrdMstrHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo
where  b.PNodeID<>h.NodeID

insert into tblPrdMstrHierarchy
select a.NodeID,a.NodeType,h.NodeID,h.NodeType,1,h.HierID,CONVERT(date,getdate()),'2050-12-31',0 from tblPrdMstrSKULvl a 

join #ProductListAPI p on p.ProductERPId=a.SKUCode
join tblPrdMstrHierLvl1 c on c.Code=p.Brand
join tblPrdMstrHierarchy h on h.NodeID=c.NodeID
and h.NodeType=c.NodeType
left join tblPrdMstrHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo
where b.NodeID is null

Update tblPrdSKUSalesMapping set ToDate=DATEADD(dd,-1,Getdate())
WHERE        (UOMID = 1) AND (CONVERT(date, GETDATE()) BETWEEN FromDate AND ToDate)

insert into tblPrdSKUSalesMapping(SKUNodeId, SKUNodeType, SalesNodeType, PrcLocationId1, TaxLocationId1, PrcLocationId, TaxLocationId, UOMID, BusinessSegmentId, MRP, RetMarginPer, Tax, StandardRate, 
                         FromDate, ToDate, DistributorMarginPer, DistributorStandardRate)
SELECT        SKUNodeId, SKUNodeType, SalesNodeType, PrcLocationId1, TaxLocationId1, PrcLocationId, TaxLocationId, 1, BusinessSegmentId, a.MRP*p.PcsInBox, a.RetMarginPer, a.Tax, a.StandardRate*p.PcsInBox, 
                         GETDATE(), '2050-12-31', a.DistributorMarginPer, a.DistributorStandardRate*p.PcsInBox
FROM            tblPrdSKUSalesMapping a join tblPrdMstrSKULvl p on a.SKUNodeId=p.NodeID
WHERE        (a.UOMID = 3) AND (CONVERT(date, GETDATE()) BETWEEN FromDate AND ToDate)


--truncate table tblPrdStateProductPriceMstr
--insert into tblPrdStateProductPriceMstr
--  select 0,NodeID,NodeType,MRP,StandardRate,PcsInBox,1,1,0,0 from tblPrdMstrSKULvl


  --select * from tblPrdActivePrdList

  --insert into 

end
