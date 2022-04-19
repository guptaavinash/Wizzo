
--15129_1_0_1!73364$1#25170_1_0_1!83598$1


--select * from tblStoreMaster where StoreCode='BIS21036'

--update a set LOTID=B.LotId from tbltelecallerlistforday a join tblStoreMaster b on a.StoreId=b.StoreID

--select * from tbltelecallerlistforday where isused=1 and languageid=2
--exec spSchemeDetailByStoreN @storeid=919223,@Date='2020-04-17 00:00:00'
--[spSchemeDetailByStore]    808,'15-JUL-2021'
CREATE proc [dbo].[spSchemeDetailByStore]   
@Storeid int,  
@Date datetime  
AS  
begin  

--if exists(select top 1 * from tblPrdStoreProductPriceMstr where StoreId=@Storeid)
--begin
--set @Storeid=0
--end
Declare @ChannelId int,@SubChannelId int,@DistributorNodeId int,@DistributorNodeType int,@BranchSubdNodeId int,@BranchNodeType int,@StateId int
Declare @Curr_Date datetime
set @Curr_Date=dbo.fnGetCurrentDateTime()

select @ChannelId= ChannelId,@SubChannelId=s.subchannelid,@DistributorNodeId= DistNodeId,
@DistributorNodeType=DistNodeType,@StateId=RegionId from tblStoreMaster s   where StoreID=@Storeid





PRINT 'Step1 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)

print convert(varchar,dbo.fnGetCurrentDateTime(),109)
print 'step1'
--select SBFNodeId,SBFNodeType into #PrdBranchSBFPriceMstr from tblPrdBranchSBFPriceMstr(nolock) where BrnSubdNodeId=@BranchSubdNodeId and BrnSubdNodeType=@BranchNodeType -- and (flgNewStore=1 or flgSearchList=1)

select DISTINCT SkuNodeId as PrdNodeId, SKUNodeType AS  PrdNodeType into #PrdBranchSBFPriceMstr from tblprdskusalesmapping(nolock) a 

where GETDATE() between FromDate and ToDate AND PrcLocationId=@StateId
--and z.sbfnodeid is null

select distinct PrdNodeId,PrdNodeType into #BlockProd from tblSchemeBlockProduct  where distnodeid=@distributornodeid
and distnodetype=@distributornodetype

PRINT 'Step2 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)

print convert(varchar,dbo.fnGetCurrentDateTime(),109)

IF Object_id('tempdb..#tmpStoreId') is not null  
begin  
drop table #tmpStoreId  
end  


Create table #tmpStoreId(StoreId int,SchemeDetId int)
insert into #tmpStoreId
Select distinct @StoreId,a.SchemeDetId  from tblSchemeApplicabilityDetail a join tblSchemeDetail b on a.SchemeDetID=b.SchemeDetID
join tblSchemeMaster c on c.SchemeID=b.SchemeID
where @Date between b.SchemeFromDate and b.SchemeToDate and c.flgActive=1
and ((a.StoreId=@Storeid or a.StoreId=0) and (a.ChannelId=@ChannelId or a.ChannelId=0)

and (a.SubChannelId=@SubChannelId or a.SubChannelId=0)
and ((a.DistributorNodeId =@DistributorNodeId and a.DistributorNodeType=@DistributorNodeType) or a.DistributorNodeId=0)
) and ((a.stateid=@StateId) or a.StateId=0)

PRINT 'Step3 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)

if (object_id('tempdb..#tmpStoreScheme0')is not null)  
begin  
drop table #tmpStoreScheme0  
end  

  
select Distinct A.StoreID, B.SchemeID into #tmpStoreScheme0 from tblSchemeMaster B JOIN tblSchemeDetail C ON C.SchemeID=B.SchemeID
join   #tmpStoreId A ON C.SchemeDetID=A.SchemeDetID
where flgActive=1 --and exists(select * from #PrdBranchSBFPriceMstr where PrdNodeId=b.PrdNodeId and PrdNodeType=b.PrdNodeType)

select  distinct a.* into #tmpStoreScheme from #tmpStoreScheme0 a join tblSchemeProductDetail b on a.SchemeID=b.SchemeId
where  exists(select * from #PrdBranchSBFPriceMstr where PrdNodeId=b.PrdNodeId and PrdNodeType=b.PrdNodeType)

PRINT 'Step4 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  
  SELECT * FROM #tmpStoreScheme
  
if (object_id('tempdb..#tmpScheme')is not null)  
begin  
drop table #tmpScheme  
end  
  
--select distinct SchemeID into #tmpScheme from #tmpRouteSchemeMapping  
SELECT distinct SchemeID into #tmpScheme from #tmpStoreScheme

PRINT 'Step5 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)

Select  B.SchemeID,SchemeDescription+case when B.MRPLevel=1 THEN  ' (MRP Level)' else '' end as SchemeName,SchemeApplicationID,SchemeApplRule AS SchemeAppliedRule,SchemeTypeId,IsPayoutFixed,B.Retailer_Apply_Count,schemecode,SchemeName As SchemeDescr,ApplicableBrands,B.MRPLevel from #tmpScheme A join tblSchemeMaster B ON A.SchemeID=B.SchemeID  
JOIN tblSchemeDetail C ON C.SchemeID=B.SchemeID  

PRINT 'Step6 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)
  
  
Select  B.SchemeID,C.SchemeSlabID,SlabDescrOrg AS SchemeSlabDesc,BenifitDescrOrg as BenifitDescr from #tmpScheme A join tblSchemeMaster B ON A.SchemeID=B.SchemeID  
JOIN tblSchemeSlabDetails C ON C.SchemeID=B.SchemeID  
JOIN tblSchemeSlabOutput D ON C.SchemeSlabID=D.SchemeSlabID  
  
PRINT 'Step7 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109) 
  


if (object_id('tempdb..#SlabMstr')is not null)  begin  
drop table #SlabMstr 
end  
  
select a.* into #SlabMstr from #tmpScheme C INNER JOIN  tblSchemeSlabDetails A  
  
ON C.SchemeID=A.SchemeID  

if (object_id('tempdb..#SlabSplit')is not null)  begin  
drop table #SlabSplit  
end  
  
select A.SchemeID,A.SchemeSlabID,B.*,A.SlabCost into #SlabSplit from #SlabMstr A  
  
 cross apply  dbo.SlabSplit(A.SlabPrdStr) B  

PRINT 'Step8 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  
   
   
if (object_id('tempdb..#tmpSchemeDet')is not null)  
begin  
drop table #tmpSchemeDet  
end  
  
select distinct SchemeSlabID into #tmpSchemeDet from #SlabSplit  
 
 PRINT 'Step9 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)
 
if (object_id('tempdb..#BenMstr')is not null)  
begin  
drop table #BenMstr  
end  

select DISTINCT D.SchemeID,A.SchemeSlabID,a.Slab_Max_Limit,A.strPrdFreePrd into #BenMstr from #tmpSchemeDet C INNER JOIN  tblSchemeSlabOutput A  
  
ON C.SchemeSlabID=A.SchemeSlabID  
INNER JOIN  #SlabMstr D ON D.SchemeSlabID=A.SchemeSlabID  

  
if (object_id('tempdb..#BenSplit')is not null)  
begin  
drop table #BenSplit  
end  
   
select A.SchemeID,A.SchemeSlabID,a.Slab_Max_Limit,B.* into #BenSplit from #BenMstr A
  
 cross apply  dbo.BenSplit1(A.strPrdFreePrd) B  
  
PRINT 'Step10 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  
 if (object_id('tempdb..#prod')is not null)  
begin  
drop table #prod  
end  
select NodeId,NodeType into #prod from #SlabSplit where SlabSubBucketType<>'2' and NodeId<>''  
union  
select NodeId,NodeType from #BenSplit where BenSubBucketType<>4 and NodeId<>''  
  
PRINT 'Step11 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)

-- if (object_id('tempdb..#ActProd')is not null)  
--begin  
--drop table #ActProd;  
--end;  
--with cte as  
--(  
--select A.NodeId,A.NodeType,A.NodeId as PNodeId,A.NodeType as PNodeType,A.HierId  from tblPrdMstrHierarchy A join #prod B  
--ON A.Nodeid=B.Nodeid and A.NodeType=B.NodeType  and convert(varchar,@Curr_Date,112) between convert(varchar,a.VldFrom,112) and convert(varchar,a.VldTo,112) 
--where a.NodeType<=40
--union all  
--select A.NodeId,A.NodeType,B.PNodeId as PNodeId,B.PNodeType as PNodeType,A.hierId from tblPrdMstrHierarchy A join cte B  
--ON A.PNodeid=B.Nodeid and A.PNodeType=B.NodeType and A.PHierId=B.HierId   and convert(varchar,@Curr_Date,112) between convert(varchar,a.VldFrom,112) and convert(varchar,a.VldTo,112) 
--where a.NodeType<=40 
--)    

--select a.*,10 as ManufacturerID into  #ActProd from cte a join tblPrdMstrHierLvl4 b on a.NodeId=b.NodeId where a.NodeType=40   and  b.isactive=1

--select a.*,10 as ManufacturerID into  #ActProd from tblSchemeProductDetail a join #prod b on a.pNodeId=b.NodeId where a.pNodeType=b.NodeType

PRINT 'Step12 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  


--Delete a from #ActProd a left join #PrdBranchSBFPriceMstr b on a.NodeID=b.SBFNodeId
--and a.NodeType=b.SBFNodeType
--where b.SBFNodeId is null

PRINT 'Step13 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  
  

--Create table #tmpSlabBucketMstr(SlabSubBucketType int identity(1,1),SlabSubBucketTypeDesc char(4))   
--insert into #tmpSlabBucketMstr(SlabSubBucketTypeDesc) values('PROD'),('PVOL'),('VALU'),('PDLN'),('PVAL')  
  
--Create table #tmpSubBucketValTypeMstr(SubBucketValType int identity(1,1),SubBucketValTypeDesc char(4))   
--insert into #tmpSubBucketValTypeMstr(SubBucketValTypeDesc) values('IVAL'),('GVAL'),('NVAL')  
if object_id('tempdb..#tmpSlabBucketDetails') is not null
begin
drop table #tmpSlabBucketDetails
end
  
Create table #tmpSlabBucketDetails(RowID int identity(1,1),SchemeID int,SchemeSlabID int,BucketID int,SubBucketID int,SlabSubBucketType tinyint,SlabSubBucketValue varchar(100),SubBucketValType tinyint,UOMName varchar(100),UOMCnv numeric(18,0),Seq numeric(18,2))  
  
insert into #tmpSlabBucketDetails  
select Distinct A.SchemeID,A.SchemeSlabID,A.BucketID,A.SubBucketID,SlabSubBucketType,
 SlabSubBucketValue,case SlabSubBucketType when 2 then NodeId else 0 end AS ValType,U.BUOMName AS UOM,
 
 case SlabSubBucketType when 5 then 
 dbo.fnGetGramsConversion(a.QtyType,1) else 0 end,SlabCost  from #SlabSplit A  left join tblPrdMstrBUOMMaster u on a.QtyType=u.BUOMID and SlabSubBucketType='5' 
PRINT 'Step14 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  
PRINT  'TS'  
select RowID, SchemeID, SchemeSlabID, BucketID,Row_number() over (partition by SchemeSlabID,BucketID order by BucketID,SubBucketID) as SubBucketID,SlabSubBucketType,SlabSubBucketValue, SubBucketValType ,UOMName,UOMCnv,Seq
into #tmpSlabBucketDetails1  
 from #tmpSlabBucketDetails  
PRINT 'Step15 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  
 select * from #tmpSlabBucketDetails1  
 
PRINT 'Step16 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109) 

select Distinct B.RowID,D.PrdNodeId AS ProductID,Case when S.SchemeTypeID=3 then 1 else 0 end flgCombine,case A.SlabSubBucketType when 3 then QtyType else 0 end as QtyPerLine,a.SchemeID,D.MRP into #SlabProduct from #SlabSplit A   
join #tmpSlabBucketDetails B ON A.SchemeSlabID=B.SchemeSlabID  
AND A.BucketID=B.BucketID AND A.SubBucketID=B.SubBucketID  
cross apply dbo.split(A.ManufacturerId,',') F 
inner join tblSchemeProductDetail D on A.SchemeID=D.SchemeId 
inner join tblSchemeMaster S on S.SchemeId=B.SchemeId
WHERE A.SlabSubBucketType<>'2'  and exists(select * from #PrdBranchSBFPriceMstr z where d.PrdNodeId=z.PrdNodeId
and d.PrdNodeType=z.PrdNodeType)
and not exists(select * from #BlockProd y  where d.PrdNodeId=y.PrdNodeId
and d.PrdNodeType=y.PrdNodeType and s.SchLvl<>0
)
order by 2,1  
  
 PRINT 'Step17 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  
  
  
  
  
select * from #slabproduct  
order by 1,2  
 
 PRINT 'Step18 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  
  
--select A.SchemeID,A.SchemeSlabID,SlabType,Value,SlabID,SlabAndID,B.NodeID AS ProductID,'NA' AS ValType from #SlabSplit A left join #ActProd B on A.NodeId=B.PNodeId  
--and A.NodeType=B.PNodeType  
--WHERE SlabSubBucketType<>'Val'  
--union   
--select A.SchemeID,A.SchemeSlabID,SlabType,Value,SlabID,SlabAndID,0 AS ProductID,NodeID AS ValType from #SlabSplit A   
--WHERE SlabSubBucketType='Val'  
--order by 1,2,3  
  
Create table #tmpBenBucketDetails(RowID int identity(1,1),SchemeID int,SchemeSlabID int,BucketID tinyint,SubBucketID tinyint,BenSubBucketType tinyint,BenSubBucketValue varchar(1000),CouponCode varchar(100),Per varchar(20),UOM int,Prorata int,IsDiscountOnTotalAmount int,Slab_Max_Limit numeric(18,2))  
  
insert into #tmpBenBucketDetails(SchemeID,SchemeSlabID,BucketID,SubBucketID,BenSubBucketType,CouponCode,Per,UOM,Prorata,IsDiscountOnTotalAmount,Slab_Max_Limit)  
select dISTINCT A.SchemeID,A.SchemeSlabID,BucketID,SubBucketID,BenSubBucketType,ISNULL([SchemeCouponCode],''),A.Per,a.uom,case when BenSubBucketType not in(2,6,8) then A.Prorata else 0 end,case when BenSubBucketType in(2,6,8) then A.Prorata else 0 end,A.Slab_Max_Limit from #BenSplit A LEFT JOIN   
tblSchemeCouponMaster B ON A.CounponID=b.CouponID  

PRINT 'Step19 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)    
  

  
  
Create table #tmpBenefitsValueDetail(RowID int, BenValue varchar(10),Remarks varchar(100),Type tinyint)  
  
  
insert into #tmpBenefitsValueDetail(RowID,BenValue,Remarks,Type)  
Select dISTINCT B.RowID,Substring(items,0,CharIndex('$',items)) ,Substring(items,CharIndex('$',items)+1,LEN(items)-CharIndex('$',items)),1  
from #BenSplit A   
join #tmpBenBucketDetails B ON A.SchemeSlabID=B.SchemeSlabID  
AND A.BucketID=B.BucketID AND A.SubBucketID=B.SubBucketID  
Cross apply dbo.Split(a.BenSubBucketValue,'^')  
where items<>''  
  
 PRINT 'Step20 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109) 
  
insert into #tmpBenefitsValueDetail(RowID,BenValue,Remarks,Type)  
Select dISTINCT B.RowID,Substring(items,0,CharIndex('$',items)) ,Substring(items,CharIndex('$',items)+1,LEN(items)-CharIndex('$',items)),case B.BenSubBucketType when  6   
then 2 when  7 then 3 else  B.BenSubBucketType end  
from #BenSplit A   
join #tmpBenBucketDetails B ON A.SchemeSlabID=B.SchemeSlabID  
AND A.BucketID=B.BucketID AND A.SubBucketID=B.SubBucketID  
Cross apply dbo.Split(a.BenSubBucketDiscValue,'^')  
where items<>''  
  
PRINT 'Step21 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)

select A.RowID, SchemeID, SchemeSlabID, BucketID,Row_number() over (partition by SchemeSlabID,BucketID order by BucketID,SubBucketID) as SubBucketID,BenSubBucketType, ISNULL(CouponCode,'')  CouponCode,  
case when isnull(BenValue,'')='' then '0' ELSE BenValue end as BenSubBucketValue ,CASE WHEN BenSubBucketType IN(8,9) THEN 1 ELSE 0 END BenDiscApplied ,case when  BenSubBucketType>9 then dbo.fnGetGramsConversion(A.UOM,A.Per) else 0 end as Per,case when A.UOM IN(2,3,4,5) then 2 else 0 end as UOM,
A.Prorata,A.IsDiscountOnTotalAmount,a.Slab_Max_Limit,
case BenSubBucketType when 10 then '&#8377;. '+case when isnull(BenValue,'')='' then '0' ELSE BenValue end +' Per '+ isnull(a.Per,'')+' '+ isnull(u.BUOMName,'')
when 6 then case when isnull(BenValue,'')='' then '0' ELSE BenValue end +' % Discount'
when 7 then '&#8377; '+case when isnull(BenValue,'')='' then '0' ELSE BenValue end +' Amount'
when 5 then case when isnull(BenValue,'')='' then '0' ELSE BenValue end +' Pcs'
when 1 then case when isnull(BenValue,'')='' then '0' ELSE 

BenValue end +' Pcs of '+ STUFF((SELECT distinct ',' + p1.SKUCode 
                     
         FROM tblPrdMstrSKULvl p1 join #BenSplit f on p1.nodeid=f.NodeId
         WHERE f.SchemeSlabID=A.SchemeSlabID  
AND f.BucketID=A.BucketID AND f.SubBucketID=A.SubBucketID  
and f.NodeType=20
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)')
        ,1,1,'') 
else '' end as BenefitDisplay
 from #tmpBenBucketDetails A Left join #tmpBenefitsValueDetail B  
 ON A.RowID=B.RowID  
 left join tblPrdMstrBUOMMaster u on u.BUOMID=a.UOM
 AND Remarks='default'  
PRINT 'Step22 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)
  
  --select * from tblSchemeBenefitsTypeMaster
 --Delete #tmpBenefitsValueDetail where Remarks='default'  
  
  
select Distinct B.RowID,NodeId AS ProductID,'' AS FreeProductName,'' AS SKUCode,8 AS UOMID,0 as StandardRate,0 AS StandardRateBeforeTax ,0 AS Tax,0 AS MRP,0 as Grammage,0 as CurrentInvStock,0 as BookedInvStock from #BenSplit A   
join #tmpBenBucketDetails B ON A.SchemeSlabID=B.SchemeSlabID  
AND A.BucketID=B.BucketID AND A.SubBucketID=B.SubBucketID  
where NodeId<>''
  --where 1<>1
----SELECT * FROM #tmpBenefitsValueDetail  
--PRINT 'Step23 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  
  
--  select A.RowID,STUFF((SELECT '@' + CAST(p1.BenValue AS VARCHAR)+ '^'+CAST(p1.Remarks AS VARCHAR)  + '^'+CAST(p1.Type AS VARCHAR)
--         FROM #tmpBenefitsValueDetail p1  
--         WHERE A.RowID = p1.RowID  
--            FOR XML PATH(''), TYPE  
--            ).value('.', 'NVARCHAR(MAX)')   
--        ,1,1,'') FROM #tmpBenBucketDetails A 
--  group by A.RowID
 
 
--Select a.PrdNodeId as ProductID, [SchemeString] as PrdString from tblSchemeApplicabilityDetailProductDetail a join #PrdBranchSBFPriceMstr b on a.PrdNodeId=b.PrdNodeId
--and a.PrdNodeType=b.PrdNodeType where 
--((a.DistributorNodeId =@DistributorNodeId and a.DistributorNodeType=@DistributorNodeType) or a.DistributorNodeId=0)
--and ((a.BranchSubDNodeId =@BranchSubdNodeId and a.BranchSubDNodeType=@BranchNodeType) or a.BranchSubDNodeId=0)
--and (a.ChannelId=@ChannelId or a.ChannelId=0)
--and (a.SubChannelId=@SubChannelId or a.SubChannelId=0)
--and
-- ((a.StoreId=@Storeid or a.StoreId=0) )


 
--Create table #productMap1(ProductID int,PrdString varchar(max))  

--  select 0 AS offDay  where 1<>1

--  select distinct SchemeSlabID,BucketId
-- from #tmpSlabBucketDetails1  



--select * from #productMap1 order by 1  




--SELECT * FROM #tmpBenefitsValueDetail  
PRINT 'Step23 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  
  
  select A.RowID,STUFF((SELECT '@' + CAST(p1.BenValue AS VARCHAR)+ '^'+CAST(p1.Remarks AS VARCHAR)  + '^'+CAST(p1.Type AS VARCHAR)
         FROM #tmpBenefitsValueDetail p1  
         WHERE A.RowID = p1.RowID  
            FOR XML PATH(''), TYPE  
            ).value('.', 'NVARCHAR(MAX)')   
        ,1,1,'') FROM #tmpBenBucketDetails A 
  group by A.RowID
 
PRINT 'Step24 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)

 if (object_id('tempdb..#productMap')is not null)  
begin  
drop table #productMap  
end  

 if (object_id('tempdb..#productMap1')is not null)  
begin  
drop table #productMap1 
end  
  
Declare @schemeString varchar(50),@BuckString varchar(50),@SubBuckString varchar(500),@String varchar(1000),@SchemeId int,@SlbID int,@ProductID INT,@BucketID int,@RowIDs varchar(100)  
Create table #productMap(ProductID int,PrdString varchar(max))  
Create table #productMap1(ProductID int,PrdString varchar(max))  
Declare @i int, @cnt int,@s int,@scnt int,@sl int,@slcnt int,@B int,@Bcnt int  
  
  --insert into #productMap(ProductId,PrdString)
  --select distinct ProductId,null from #slabproduct

  --Update A SET PrdString=STUFF((SELECT '#' + CAST(p.PrdStr AS VARCHAR(500))
  --       FROM #tmpScheme s join [dbo].[tblSchemeProductDesc] p
		-- on s.SchemeId= p.SchemeId
  --       WHERE p.PrdId = A.ProductId
  --          FOR XML PATH(''), TYPE
  --          ).value('.', 'NVARCHAR(MAX)')
  --      ,1,1,'') from #productMap A

    create nonclustered index idxSlabProduct on #SlabProduct(Productid) include(RowId)
 if (object_id('tempdb..#tmpProductRowID')is not null)  
begin  
drop table #tmpProductRowID  
end  
  
select  Productid,STUFF((SELECT ',' + CAST(p1.RowID AS VARCHAR)  
         FROM #SlabProduct p1  
         WHERE A.Productid = p1.Productid  
		 order by p1.RowID
            FOR XML PATH(''), TYPE  
            ).value('.', 'NVARCHAR(100)')   
        ,1,1,'')  as RowIDs,RowID  into #tmpProductRowID  from #SlabProduct A  where ProductID not in(select PrdNodeId from  tblPrdStoreProductPriceMstr where StoreId=@Storeid)

		
  create nonclustered index idx2SlabProduct on #tmpProductRowID(RowIDs) include(RowID)

PRINT 'Step25 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109)  

  
 if (object_id('tempdb..#tmpRowIDs')is not null)  
begin  
drop table #tmpRowIDs  
end  
  
select  distinct RowIDs,RowID  into #tmpRowIDs  from #tmpProductRowID A  

PRINT 'Step26 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109) 
  
 if (object_id('tempdb..#product')is not null)  
begin  
drop table #Product  
end  
select Distinct RowIDs,IDENTITY(int,1,1) as ident into #Product from #tmpProductRowID  

PRINT 'Step27 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109) 

set @i=1  
select @cnt=count(*) from  #Product  
while @i<=@cnt  
begin  
  
select @RowIDs=RowIDs from #Product where ident=@i  
  
  
   if (object_id('tempdb..#Scheme')is not null)  
  begin  
  drop table #Scheme  
  end  

  Create table #Scheme(ident int IDENTITY(1,1) ,SchemeID int,SchemeSlabCost numeric(18,2))
  
  insert into #Scheme(SchemeID,SchemeSlabCost)
  select A.SchemeId,max(a.SlabCost) from tblSchemeSlabDetails A inner join
 ( select distinct SchemeID from #tmpSlabBucketDetails1 A join #tmpRowIDs B on B.RowID=A.RowID where RowIDs=@RowIDs  ) as B ON a.SchemeID=b.SchemeID
 Inner join tblSchemeMaster as C on C.SchemeId=b.schemeid where c.SchemeType2ID=1
 group by a.SchemeID
order by  2 desc
  print 'ProductID'  
  print @ProductID  
  set @s=1   
  select @scnt=count(*) from  #Scheme  
  while @s<=@scnt  
  begin  
  
    
  select @SchemeId=SchemeID from #Scheme where ident=@s  
  print '@SchemeId'  
  print @SchemeId  
  
print convert(varchar,dbo.fnGetCurrentDateTime(),109)
print 'step12.1' 
  SET @schemeString=''  
    
  Select  @schemeString=CONVERT(VARCHAR,B.SchemeID)+'_'+CONVERT(VARCHAR,SchemeApplicationID)+'_'+CONVERT(VARCHAR,SchemeApplRule)+'_'+CONVERT(VARCHAR,SchemeTypeId) 
  from tblSchemeMaster B  
  JOIN tblSchemeDetail C ON C.SchemeID=B.SchemeID  
  WHERE B.SchemeID=@SchemeId  
  
  if @s=1  
    set @String=@schemeString  
    else  
    set @String=@String+'#'+@schemeString  
  
   if (object_id('tempdb..#SchemeSlab')is not null)  
  begin  
  drop table #SchemeSlab  
  end  



  select distinct A.SchemeSlabID,IDENTITY(int,1,1) as ident,SlabCost into #SchemeSlab 
  from #tmpSlabBucketDetails1 A join #tmpRowIDs B on B.RowID=A.RowID 
  inner join tblSchemeSlabDetails D on D.SchemeSlabID=A.SchemeSlabID
  where RowIDs=@RowIDs  
  and a.SchemeID=@SchemeId  
  order by SlabCost desc

  --if @SchemeId=12001
  --begin
  --select * from #SchemeSlab
  --select * from #tmpRowIDs where  RowIDs=@RowIDs  
  --end
    set @sl=1   
    select @slcnt=count(*) from  #SchemeSlab  
    while @sl<=@slcnt  
    begin  
  
    
  
    select @SlbID=SchemeSlabID from #SchemeSlab where ident=@sl  
  
    print '@SlbID'  
    print @SlbID  
  
    if @sl=1  
    set @String=@String+'!'+convert(varchar,@SlbID)  
    else  
    set @String=@String+'@'+convert(varchar,@SlbID)
  
      
      if (object_id('tempdb..#Bucket')is not null)  
     begin  
     drop table #Bucket  
     end  
  
    select distinct BucketID, count(*) as BucketCnt,IDENTITY(int,1,1) as ident into #Bucket from #tmpSlabBucketDetails1 A join #tmpRowIDs B on B.RowID=A.RowID where RowIDs=@RowIDs  
    and SchemeID=@SchemeId and SchemeSlabID=@SlbID  
    group by BucketID  
	order by BucketID desc
  
  
    set @b=1  
    select @bcnt=count(*) from #Bucket  
    set @BuckString=''  
    while @b<=@bcnt  
    begin  
      
    
  
     set @BuckString=''  
      select @BuckString=CONVERT(VARCHAR,BucketID)+'^'+CONVERT(VARCHAR,BucketCnt),@BucketId=BucketID from #Bucket where ident=@b  
	    if @b=1  
    set @String=@String+'$'+convert(varchar,@BucketId)  
    else  
    set @String=@String+'^'+convert(varchar,@BucketId)
  
 --     print '@BucketId'  
	--  print @RowIDs
 --   print @BucketId
 --     set @SubBuckString=''  
	--  --+'^'+Convert(varchar,C.flgCombine)
 --   select  @SubBuckString=@SubBuckString+Convert(varchar,A.SubBucketID)+'^'+Convert(varchar,A.RowId)+'^'+Convert(varchar,A.SlabSubBucketType)+'^'+Convert(varchar,A.SlabSubBucketValue)+'^'+Convert(varchar,A.SubBucketValType)+'*' from #tmpSlabBucketDetails1 A join #tmpRowIDs B on B.RowID=A.RowID
	--join (select distinct rowid,flgCombine from  #slabproduct ) AS C ON C.Rowid=A.Rowid  where RowIDs=@RowIDs  
 --   and SchemeID=@SchemeId and SchemeSlabID=@SlbID  
 --   and BucketID=@BucketId  
 --      set @String=@String+@BuckString+'|'+left(@SubBuckString,len(@SubBuckString)-1)  
 --      print @String  
     set @b=@b+1  
    end  
      
 --    print 'bucket end'  
       
       
     
    set @sl=@sl+1  
    end  
  
     
  set @s=@s+1  
  end  
  
  insert into #productMap   
  select distinct productid,@String from #tmpProductRowID where RowIDs=@RowIDs  
  set @String=''  
  
set @i=@i+1  
end  
 
 PRINT 'Step28 : ' + convert(varchar,dbo.fnGetCurrentDateTime(),109) 
 
select * from #productMap  where prdstring<>'' order by 1  
  
  select 0 AS offDay  where 1<>1

  select distinct SchemeSlabID,BucketId
 from #tmpSlabBucketDetails1  





  select '' AS InvString
  --set @String=''  
  
    end
