
---[spGetSchemeMasterPopupDetail] 11775
CREATE proc [dbo].[spGetSchemeMasterPopupDetail] 
@SchemeId int
as
begin

Declare @SchLvl tinyint
select @SchLvl=SchLvl from tblSchemeMaster where SchemeID=@SchemeId
if object_id('tempdb..#SlabType') is not null
begin
	drop table #SlabType
end
SELECT a.SchemeSlabID ,b.*,a.SlabCost into #SlabType FROM tblSchemeSlabDetails A  
  

 cross apply  dbo.SlabSplit(A.SlabPrdStr) B   where schemeid=@SchemeId

 declare @flgOnInvoice tinyint=1

if object_id('tempdb..#BenSplit') is not null
begin
	drop table #BenSplit
end
select a.SchemeSlabID,b.*,a.Slab_Max_Limit into #BenSplit from tblSchemeSlabOutput A  
  
INNER JOIN  tblSchemeSlabDetails D ON D.SchemeSlabID=A.SchemeSlabID  
  
 cross apply  dbo.BenSplit1(A.strPrdFreePrd) B  
 where schemeid=@SchemeId

if object_id('tempdb..#SlabDetail') is not null
begin
	drop table #SlabDetail
end
 select  distinct identity(int,1,1) as rowid, a.SchemeSlabID,SlabSubBucketType,a.BucketID,+'Group Level '+convert(varchar,a.SubBucketID) as GroupBucket,a.SubBucketID,case when a.SlabSubBucketType=3 then convert(varchar,QtyType) else 'NA' end as Variance,b.schemeslabtype,SlabSubBucketValue,
 
 Substring(BenSubBucketDiscValue,0,CharIndex('$',BenSubBucketDiscValue))+' '+
 case c.BenSubBucketType when 10 then 'Rs Discount Per '+convert(varchar,Per)+' '+u.BUOMName  
 when 7 then 'Rs Discount'
 when 6 then '% Discount' end
  as BenValue,case when Slab_Max_Limit=99999999.00 then 'No Limit' else convert(varchar,Slab_Max_Limit) end Max_Limit,SlabCost
 into #SlabDetail from #SlabType a join tblSchemeSlabTypeMaster b on a.SlabSubBucketType=b.SchemeSlabTypeID 
 join #BenSplit c on c.SchemeSlabID=a.SchemeSlabID
left join tblPrdMstrBUOMMaster u on  u.BUOMID=c.UOM  and  c.BenSubBucketType=10
order by SlabCost


select PrdNodeId,PrdNodeType,Product,Category,Brand into #vwProductHierarchy from vwProductHierarchy

select PrdNodeId,PrdNodeType into #tblSchemeProductDetail from tblSchemeProductDetail where SchemeId=@SchemeId

 select * from #SlabDetail
 select distinct a.rowid,
 case @SchLvl when 0 then 'Product' 
 when 2 then 'Division'
 when 3 then 'Category'
 when 4 then 'Brand'
 when 5 then 'Sub Brand'
 when 6 then 'Product'
  end as SchType
 ,case @SchLvl when 0 then Product 
 when 2 then Division
 when 3 then Category
 when 4 then Brand
 when 5 then SBF 
 when 6 then 'Product'
 end as  Descr from #SlabDetail a 
 CROSS join  #tblSchemeProductDetail p
 join #vwProductHierarchy v on v.PrdNodeId=p.PrdNodeId and v.PrdNodeType=p.PrdNodeType 
 --where @flgOnInvoice=0
 --union 
 --select distinct a.rowid,'All','On Invoice' from #SlabDetail a  where @flgOnInvoice=1

end
