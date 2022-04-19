CREATE proc [dbo].[spPopulateProductMasterRawData]
as
begin
RETURN
--select ProductERPId,MAX(Id) as PrdLastId into #LastData from tmpRawDataProductListAPI
--group by ProductERPId
select a.*,0 as CatId,0 as CaseUOMId into #ProductListAPI from tmprawdataproductmaster a 
--join #LastData b on a.Id=b.PrdLastId

insert into tblPrdMstrHierLvl1(Code,Descr,NodeType,FileSetIdIns,TimestampIns)
select distinct [temp_Primary Category],[temp_Primary Category],10,0,GETDATE() from #ProductListAPI a left join tblPrdMstrHierLvl1  b on a.[temp_Primary Category]=b.Descr
where b.NodeID is null

Update a set CatId=b.catid from #ProductListAPI a join tblprdattr_category b on a.[temp_Secondary Category]=b.CatName
insert into tblPrdAttr_Category(CatName)
select distinct [temp_Secondary Category] from #ProductListAPI where isnull(catid,0)=0 

Update a set CatId=b.catid from #ProductListAPI a join tblprdattr_category b on a.[temp_Secondary Category]=b.CatName where a.CatId=0


Update a set CaseUOMId=b.BUOMID from #ProductListAPI a join tblPrdMstrBUOMMaster b on a.[temp_Standard Unit]=b.BUOMName
insert into tblPrdMstrBUOMMaster(BUOMName,LoginIDCreate,TimeStampCreate,LoginIDMod,TimeStampMod,flgConversionUnit)
select distinct [temp_Standard Unit],0,GETDATE(),0,GETDATE(),1 from #ProductListAPI where isnull(CaseUOMId,0)=0 

Update a set CaseUOMId=b.BUOMID from #ProductListAPI a join tblPrdMstrBUOMMaster b on a.[temp_Standard Unit]=b.BUOMName where isnull(CaseUOMId,0)=0 

Update b set Descr=a.Product,ShortDescr=a.Product
--,IsActive=case when Deactivated='False' then 1 else 0 end
,StandardRate=a.PTR,StandardRateBeforeTax=a.PTR,PrdTypeId=a.catid,UOMID=a.CaseUOMId,TimestampUpd=GETDATE(),
MRP=case when a.MRP is not null then a.MRP else b.MRP end,PcsInBox=convert(numeric(18,0),[Standard Unit Conversion Factor]),Grammage=convert(float,a.[Product Weight in gm])/1000,UOMValue=a.[Product Weight in gm]

from #ProductListAPI a join tblPrdMstrSKULvl  b on a.[Product Erp Id]=b.SKUCode

insert into tblPrdMstrSKULvl(SKUCode,Descr,ShortDescr,NodeType,TimestampIns,IsActive,PcsInBox,StandardRate,StandardRateBeforeTax,PrdTypeId,UomId,SectorId,Grammage,Tax,BrandID,ManufacturerID,RetMarginPer,flgSeq,DistMarginPer,PriceTypeId,flgPriceAva,MRP,UOMType,UOMValue,flgSaleType)
select distinct [Product Erp Id],a.Product,a.Product,20,GETDATE(),
--case when Deactivated='False' then 1 else 0 end,
1,
convert(numeric(18,0),[Standard Unit Conversion Factor]),a.PTR,a.PTR,a.CatId,a.CaseUOMId,1,convert(float,a.[Product Weight in gm])/1000,0,10,10,0,0,0,0,0,ISNULL(A.MRP,0),'gm',[Product Weight in gm],2 from #ProductListAPI a left join tblPrdMstrSKULvl  b on a.[Product Erp Id]=b.SKUCode
where b.NodeID is null-- AND Deactivated='False'



insert into tblPrdMstrHierarchy
select a.NodeID,a.NodeType,0,0,1,0,CONVERT(date,getdate()),'2050-12-31',0 from tblPrdMstrHierLvl1 a left join tblPrdMstrHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType
where b.NodeID is null


UPDATE b set VldTo=convert(date,DATEADD(dd,-1,getdate()))
from tblPrdMstrSKULvl a 

join #ProductListAPI p on p.[Product Erp Id]=a.SKUCode
join tblPrdMstrHierLvl1 c on c.Code=p.[temp_Primary Category]
join tblPrdMstrHierarchy h on h.NodeID=c.NodeID
and h.NodeType=c.NodeType
join tblPrdMstrHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo
where  b.PNodeID<>h.NodeID

insert into tblPrdMstrHierarchy
select distinct a.NodeID,a.NodeType,h.NodeID,h.NodeType,1,h.HierID,CONVERT(date,getdate()),'2050-12-31',0 from tblPrdMstrSKULvl a 

join #ProductListAPI p on p.[Product Erp Id]=a.SKUCode
join tblPrdMstrHierLvl1 c on c.Code=p.[temp_Primary Category]
join tblPrdMstrHierarchy h on h.NodeID=c.NodeID
and h.NodeType=c.NodeType
left join tblPrdMstrHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo
where b.NodeID is null

--Update tblPrdSKUSalesMapping set ToDate=DATEADD(dd,-1,Getdate())
--WHERE        (UOMID = 1) AND (CONVERT(date, GETDATE()) BETWEEN FromDate AND ToDate)

--insert into tblPrdSKUSalesMapping(SKUNodeId, SKUNodeType, SalesNodeType, PrcLocationId1, TaxLocationId1, PrcLocationId, TaxLocationId, UOMID, BusinessSegmentId, MRP, RetMarginPer, Tax, StandardRate, 
--                         FromDate, ToDate, DistributorMarginPer, DistributorStandardRate)
--SELECT        SKUNodeId, SKUNodeType, SalesNodeType, PrcLocationId1, TaxLocationId1, PrcLocationId, TaxLocationId, 1, BusinessSegmentId, a.MRP*p.PcsInBox, a.RetMarginPer, a.Tax, a.StandardRate*p.PcsInBox, 
--                         GETDATE(), '2050-12-31', a.DistributorMarginPer, a.DistributorStandardRate*p.PcsInBox
--FROM            tblPrdSKUSalesMapping a join tblPrdMstrSKULvl p on a.SKUNodeId=p.NodeID
--WHERE        (a.UOMID = 3) AND (CONVERT(date, GETDATE()) BETWEEN FromDate AND ToDate)


--truncate table tblPrdStateProductPriceMstr
--insert into tblPrdStateProductPriceMstr
--  select 0,NodeID,NodeType,MRP,StandardRate,PcsInBox,1,1,0,0 from tblPrdMstrSKULvl


  --select * from tblPrdActivePrdList

  --insert into 

end
