

--select * from tblTeleCallerListForDay where Date='13-oct-2021' and tcnodeid=1 and isused=1
--exec [spGetOrderProductListn] 83846,42578
CREATE proc [dbo].[spGetOrderProductListn] 
@StoreId int,
@TeleCallingId int
as
begin

Declare @DistNodeId int,@DistNodeType int,@SectorId int, @Remarks VARCHAR(500), @flgOrderSource INT,@ChannelId int=0,@SubChannelId int=0,@DistributorNodeId int=0,@DistributorNodeType int=0,@RptDate date,
@ActBranchNodeId int,@ActBranchNodeType int,@LoTId int=0,@LanguageId tinyint=1,@TCNodeId int=0,@StateId INT=0,
@SONodeId int,@SONodeType int,@PrcRegionId int=0
set @flgOrderSource=1
select @SONodeId=SONodeId,@SONodeType=SONodeType, @DistNodeId=DistNodeId,@DistNodeType=DistNodeType,@SectorId=SectorId,@RptDate=Date,@Remarks=Remarks,@LoTId=isnull(LoTId,0),@ChannelId=ChannelId,@PrcRegionId=PrcRegionId,
@SubChannelId=SubChannelId,@LanguageId=LanguageId,@TCNodeId=TCNodeId from tblTeleCallerListForDay(nolock) where TeleCallingId=@TeleCallingId
select *,PrdNodeId AS SBFNodeId,PrdNodeType AS SBFNodeType  into #StoreLastOrderDetail from tblP3MSalesDetail(nolock) where storeid=@StoreId

SELECT @StateId=StateId FROM tblDBRSalesStructureDBR where NodeID=@DistNodeId and NodeType=@DistNodeType
set @StateId=0
select * INTO #SBFPrice from [dbo].tblprdskusalesmapping(nolock) where PrcLocationId=@PrcRegionId and GETDATE() between FromDate and ToDate

select Top 1 * into #SalesHier from vwSalesHierarchy where SONodeid=@SONodeId and SONodeType=@SONodeType

Select Skunodeid,TargetValue,MonthlyTarget into #TargetData 
from tblRetailerSKUKWiseTarget where storeid=@StoreId  and monthval=month(@RptDate) and yearval=year(@RptDate)

Declare @PendingVisits tinyint=0
--select @PendingVisits=case when isnull(PendingVisits,1)=0 then 1 else isnull(PendingVisits,1) end from tblStoreMaster(nolock) where storeid=@StoreId
uPDATE A SET StandardRate=B.RLP FROM  #SBFPrice a join tblprdstoreproductpricemstr b on a.SKUNodeId=b.PrdNodeId where b.StoreId=@StoreId


--SELECT distinct  a.FBID,a.FBName,a.SlabTypeId,
--a.Target,b.IsAchieved,b.Achievement,a.SBFCount,sl.SchemeSlabType,convert(numeric(18,2),0) as InOrder, case when a.SBFCount>150 then 0 else 1 end IsProductShow into #FBData FROM tblINITFocusBrandMaster a join tblINITFocusBrandStoreMapping b on 
--a.fbid=b.fbid
--join tblSchemeSlabTypeMaster sl on sl.SchemeSlabTypeID=a.SlabTypeId
--where b.storeid=@StoreId and @RptDate between a.FromDate and a.ToDate and b.sectorid=@SectorId and flgActive=1


--select @ChannelId= ChannelId,@SubChannelId=s.subchannelid from tblStoreMaster s   where StoreID=@Storeid

--Change By AK - 27Mar to allow products of selected categories only




--SELECT        S.SBFNodeID, S.SBFNodeType,S.SBDGroupID into #TotSBDGroupId
--FROM            tblINITSBDBranchMapping AS B INNER JOIN
--                         tblINITSBDChannelMapping AS C ON B.SBDGroupID = C.SBDGroupID INNER JOIN
--                         tblINITSBDSBFList AS S ON C.SBDGroupID = S.SBDGroupID
--WHERE        (B.BranchNodeID = @ActBranchNodeId) AND (B.BranchNodeType = @ActBranchNodeType) AND (C.ChannelID = @ChannelId)

Declare @date date=Getdate()
DECLARE @CurrDate datetime
set @CurrDate=Getdate()

Select distinct a.SchemeDetId,b.SchemeID  into #SchemeDetsId from tblSchemeApplicabilityDetail a join tblSchemeDetail b on a.SchemeDetID=b.SchemeDetID
join tblSchemeMaster c on c.SchemeID=b.SchemeID
where @Date between b.SchemeFromDate and b.SchemeToDate and c.flgActive=1
and ((a.StoreId=@Storeid or a.StoreId=0) and (a.ChannelId=@ChannelId or a.ChannelId=0)
and (a.LoTId=@LoTId or a.LoTId=0)
and (a.SubChannelId=@SubChannelId or a.SubChannelId=0)
and ((a.DistributorNodeId =@DistNodeId and a.DistributorNodeType=@DistNodeType) or a.DistributorNodeId=0)
--and ((a.DistributorNodeId =@DistNodeId and a.DistributorNodeType=@DistNodeType) )
) and ((a.StateId=@StateId) or a.StateId=0)

--select @StateId,@DistributorNodeId,@DistributorNodeType,@ChannelId,@SubChannelId,@LoTId,@StoreId
--select * from #SchemeDetsId
--if (object_id('tempdb..#SlabSplit')is not null)  begin  
--drop table #SlabSplit  
--end  
  
--select DISTINCT B.NodeID,B.NodeType into #SlabSplit from #SchemeDetsId C INNER JOIN  tblSchemeSlabDetails A  
  
--ON C.SchemeID=A.SchemeID  
-- cross apply  dbo.SlabSplit(A.SlabPrdStr) B  

--select * from #StoreLastOrderDetail

Declare @flgInactiveUpload int=0

select PrdNodeId,PrdNodeType,0 as StockAvailable,0 as flgNewProduct into #activeProduct from vwProductHierarchy

group by PrdNodeId,PrdNodeType

select distinct a.PrdNodeId as NodeId,a.PrdNodeType as NodeType,a.MRP into  #InitProd 
from tblSchemeProductDetail a join #SchemeDetsId b on a.SchemeId=b.SchemeID 
join #activeProduct p on p.PrdNodeId=a.PrdNodeId
and p.PrdNodeType=a.PrdNodeType

declare @orderid int=0
select @orderid=orderid from tblTCOrderMaster(nolock) where TeleCallingId=@TeleCallingId AND flgOrderSource=1

CREATE TABLE #Cat (CatNodeID INT, CatNodeType INT)
INSERT INTO #Cat (CatNodeID, CatNodeType)
SELECT NodeID, NodeType FROM tblPrdMstrHierLvl1

--SELECT CatNodeID, CatNodeType FROM tblSiteCategoryMapping
--WHERE SiteNOdeID=@SiteNodeID AND SiteNodeType=@SiteNodeType
--END OF SECTION 

--select distinct SBDGroupId into #SBDGroupId from tblINITSBDStoreWiseGaps where StoreID=@StoreId

--Delete a from #SBDGroupId a join tblINITSBDGroupMaster b on a.SBDGroupID=b.SBDGroupID
--join #StoreLastOrderDetail c on c.PrdNodeId=b.SBFNodeID and c.PrdNodeType=b.SBFNodeType

--Delete a from #InactiveProduct a join tblTCOrderDetail b on a.PrdNodeId=b.PrdNodeId
--and a.PrdNodeType=b.PrdNodeType
--where b.OrderID=@orderid and OrderQty>0
--select @flgInactiveUpload=count(*) from #InactiveProduct

--if exists(select count(*) from #InactiveProduct)
--begin
--set @flgInactiveUpload=1
--end
SELECT DISTINCT 0 as SBDGroupID into #SBD2  where 1<>1 --FROM tblINITSBDStoreWiseGaps a(nolock)  where storeid=@StoreId

SELECT  0 as SBDGroupID,0 as SBFNodeID,0 as SBFNodeType,0 as flgBaseCode into #SBD1 where 1<>1 --FROM #SBD2 a join tblINITSBDSBFList b on a.SBDGroupID=b.SBDGroupID


select 0 as SBDGroupID,0 as SBFNodeID,0 as SBFNodeType,0 as SBDGroupName,0 as flgBaseCode,Count(*) over(partition by a.SBDGroupID) as  SBDPrdCnt into #SBDGroupList from #SBD1 a where 1<>1
--join tblINITSBDGroupMaster c on c.SBDGroupID=a.SBDGroupID

--if @flgInactiveUpload>0
--begin
--delete z from #SBD1 z where SBDGroupID not in
--(
--select distinct a.SBDGroupID from #SBD1 a left join #InactiveProduct b on a.SBFNodeID=b.PrdNodeId
--and a.SBFNodeType=b.PrdNodeType
--where b.PrdNodeId is null
--)

--end
--Update a set SBFNodeId=pnodeid,SBFNodetype=pnodetype from #StoreLastOrderDetail a join tblPrdMstrHierarchy b on a.prdnodeid=b.nodeid
--and a.prdnodetype=b.nodetype
--where Getdate() between VldFrom and VldTo


SELECT DISTINCT a.BrndNodeID as CatNodeID, A.Brand Category,'' as Brand,'' as SBF, a.PrdNodeId, a.PrdNodeType, Product as Product,coalesce(b.MRP,0) as MRP,coalesce(b.standardrate,0) as RLP,isnull(a.PCSINBOX,0) as PCSINBOX,a.Volume,a.VolUom,dbo.[fnGetKGLConversion](a.VolUomId,a.Volume) as Grammage,1 as flgNewStore,
1 as flgSearchList,Category+'-'+Product+cONVERT(VARCHAR,isnull(isnull(b.MRP,0),0)) as Search,0 as flgInitiative,0 as flgInactive,0 as flgFB,0 as FBID,0 as flgNPD,0 as NPDID,0 as flgNewPrd,0 as stockavailable,0.00 as TargetValue,a.[flgSaleType],a.SectorId,0 as flgSP,flgSeq into #Prd
FROM            vwProductHierarchy a  join #SBFPrice b on a.PrdNodeId=b.SKUNodeId
and a.PrdNodeType=b.SKUNodeType
--join #activeProduct z on z.PrdNodeId=a.PrdNodeId and z.PrdNodeType=a.PrdNodeType
--where exists (select * from #activeProduct z where z.PrdNodeId=a.PrdNodeId and z.PrdNodeType=a.PrdNodeType)


--where exists(select * from tblsectorproductmapping where sectorid=@SectorId
--and Prdnodeid=a.PrdNodeId
--and Prdnodetype=a.PrdNodeType)

--if @flgInactiveUpload>0
--begin

--Delete a from #Prd a 
--where exists(select * from #InactiveProduct z where z.PrdNodeId=a.PrdNodeId and z.PrdNodeType=a.PrdNodeType
--)

--AND NOT EXISTS(select * from #SBD1 sb where sb.SBFNodeID=a.PrdNodeId
--and a.PrdNodeType=sb.SBFNodeType and sb.flgBaseCode=1)

--Update a set flgInactive=1 from #Prd a 
--where exists(select * from #InactiveProduct z where z.PrdNodeId=a.PrdNodeId and z.PrdNodeType=a.PrdNodeType 
--)

----Update 
--end

Declare @SalesHierNodeId int,@SalesHierNodeType int
select @SalesHierNodeId=ASMAreaNodeId,@SalesHierNodeType=ASMAreaNodeType from #SalesHier 

--select PrdNodeId,PrdNodeType,FBNPDMapId from tblMstrFocusBrandNPD where flgFB=1 and SalesNodeId=@SalesHierNodeId and SalesNodeType=@SalesHierNodeType

--Update a set flgFB=1,FBID=FBNPDMapId from #Prd a join tblMstrFocusBrandNPD  b on a.BrandNodeId=b.PrdNodeId
--and a.BrandNodeType=b.PrdNodeType where b.flgFB=1 and SalesNodeId=@SalesHierNodeId and SalesNodeType=@SalesHierNodeType

--Update a set flgNPD=1,NPDID=FBNPDMapId from #Prd a join tblStoreWiseNPDGaps  b on a.BrandNodeId=b.PrdNodeId
--and a.BrandNodeType=b.PrdNodeType where  StoreId=@StoreId and flgFB<>1

Update a set flgInitiative=1 from #Prd a join #InitProd b on a.PrdNodeId=b.NodeId
and PrdNodeType=b.NodeType


Update a set flgInitiative=0,flgSP=1 from #Prd a join tblPrdStoreProductPriceMstr b on a.PrdNodeId=b.PrdNodeId
and a.PrdNodeType=b.PrdNodeType
where StoreId=@StoreId

--Update a set flgNewPrd=1 from #Prd a join tblPrdMstrHierLvl7 b on a.PrdNodeId=b.NodeID
--where b.TimestampIns between dateadd(dd,-29, @date) and @date
--uPDATE  C SET flgFB=1 ,FBID=a.FBID

--select * from #Prd a join tblPrdMstrHierLvl7 b on a.PrdNodeId=b.NodeID
--where PrdNodeId=5587

--select * from #Prd where PrdNodeId=5587
--from #FBData a join tblINITFocusBrandProductDetail b on a.FBId=b.FBId
--join #Prd c on c.SBFNodeId=b.SBFNodeId and c.SBFNodeType=b.SBFNodeType


--Delete a from #Prd a where exists(select * from tblPrdInactiveSBFList z where z.SBFNodeId=a.SBFNodeId and z.SBFNodeType=a.SBFNodeType and SiteNodeId=@SiteNodeId and SiteNodeType=@SiteNodeType and Getdate() between fromdate and todate)

SELECT      P.CatNodeID, P.Category,Brand,  p.PrdNodeId, p.PrdNodeType, p.Product as  PrdName, s.InvDate,format(s.InvDate,'dd MMM') as DisplayDate, isnull(sum(s.Qty),0) as Qty,p.MRP,p.RLP,p.PcsInBox,isnull(Sum(Sum(NetValue)) over(partition by p.category),0) as CategoryNetValue
,flgSeq as brandNetValue
,isnull(Sum(flgSeq) over(partition by p.PrdNodeId),0) as PrdNetValue,count(S.InvNo) #OfInv,flgInitiative,flgInactive ,flgFB,FBID,Volume,VolUom,Grammage,p.stockavailable,p.TargetValue,p.flgNewPrd,flgNPD,NPDID,p.[flgSaleType],p.SectorId,p.flgSP,flgSeq  into #PrdList
FROM            #StoreLastOrderDetail AS s right JOIN
                         #Prd AS p ON s.SBFNodeId = p.PrdNodeId AND s.SBFNodeType = p.PrdNodeType
--						 join #InvDt D on D.InvDate=s.InvDate
group by  P.CatNodeID,P.Category,Brand,p.PrdNodeId,flgInactive,p.PrdNodeType,p.Product,s.InvDate,p.MRP,p.RLP,p.PcsInBox,flgInitiative,flgFB,FBID,Volume,VolUom,Grammage ,p.stockavailable,p.TargetValue,p.flgNewPrd,flgNPD,NPDID,p.[flgSaleType] ,NetValue,p.SectorId,p.flgSP,flgSeq

--SELECT * FROM #PrdList

update a set brandNetValue=(select count(distinct invdate) from #PrdList z where z.PrdNodeId=a.PrdNodeId) from #PrdList a
--SELECT * FROM #PrdList
--insert into #PrdList
--select P.CatNodeID,P.Category,Brand,  p.PrdNodeId, p.PrdNodeType, p.PRODUCT as  PrdName, '2010-01-01','' as DisplayDate, 0 as Qty,p.MRP,p.RLP,p.PcsInBox,0 as CategoryNetValue
--,0 as brandNetValue
--,0 as SBFNetValue,0 #OfInv,flgInitiative,flgInactive,flgFB,FBID,Volume,VolUom,Grammage,stockavailable
--,p.TargetValue,0,flgNPD,NPDID
--from #Prd P  where flgFB=1 and not exists(select * from #PrdList b where b.PrdNodeId=p.PrdNodeId )

--insert into #PrdList
--select P.CatNodeID,P.Category,Brand,  p.PrdNodeId, p.PrdNodeType, p.PRODUCT as  PrdName, '2010-01-01','' as DisplayDate, 0 as Qty,p.MRP,p.RLP,p.PcsInBox,0 as CategoryNetValue
--,0 as brandNetValue
--,0 as SBFNetValue,0 #OfInv,flgInitiative,flgInactive,flgFB,FBID,Volume,VolUom,Grammage,stockavailable
--,p.TargetValue,0,flgNPD,NPDID
--from #Prd P  where flgNPD=1 and not exists(select * from #PrdList b where b.PrdNodeId=p.PrdNodeId )


--insert into #PrdList
--select P.CatNodeID,P.Category,Brand,  p.PrdNodeId, p.PrdNodeType, p.PRODUCT as  PrdName, '2010-01-01','' as DisplayDate, 0 as Qty,p.MRP,p.RLP,p.PcsInBox,0 as CategoryNetValue
--,0 as brandNetValue
--,0 as SBFNetValue,0 #OfInv,flgInitiative,flgInactive,flgFB,FBID,Volume,VolUom,Grammage,stockavailable
--,p.SKU,p.SKUCode,p.SKUNodeId,p.TargetValue,1,flgNPD,NPDID
--from #Prd P  where flgNewPrd=1 and not exists(select * from #PrdList b where b.PrdNodeId=p.PrdNodeId )

--select * from #PrdList where PrdNodeId=5587

select distinct top 5  InvDate  into #InvDt from #PrdList where DisplayDate<>''
 order by 1 desc
  
 --order by 1 desc
--SELECT * FROM #InvDt 
--SELECT * FROM #PrdList WHERE PrdNodeId=19
--WHERE        (s.StoreId = @StoreId)

--Update a set MRP=B.MRP,RLP=b.RLP,PcsInBox=b.UPC from #PrdList a join tblPrdBranchSubBFPriceDetail b on a.PrdNodeId=b.SBFNodeId
--and a.PrdNodeType=b.SBFNodeType
--where BranchNodeId=@DistNodeId and BranchNodeType=@DistNodeType

;with ashLastBillQty as(
SELECT PrdNodeId,PrdNodeType,Qty,ROW_NUMBER() over(partition by prdnodeid,prdnodetype order by prdnodeid,prdnodetype,invdate desc,invno desc ) as rown FROM #StoreLastOrderDetail)

select * into #LastBillQty from ashLastBillQty  where rown=1

if not exists(select * from #PrdList)
begin
insert into #PrdList
select P.CatNodeID,P.Category,Brand,  p.PrdNodeId, p.PrdNodeType, p.PRODUCT as  PrdName, '2010-01-01','' as DisplayDate, 0 as Qty,p.MRP,p.RLP,p.PcsInBox,0 as CategoryNetValue
,flgSeq as brandNetValue
,0 as SBFNetValue,0 #OfInv,flgInitiative,flgInactive,flgFB,FBID,Volume,VolUom,Grammage,stockavailable
,p.TargetValue,p.flgNewPrd,p.flgNPD,NPDID,[flgSaleType],SectorId,p.flgSP,flgSeq
from #Prd P where flgNewStore=1

end

print 'tttas323'

if @orderid>0
begin
--select * from #PrdList
insert into #PrdList
select P.CatNodeID,p.Category,Brand,p.PrdNodeId,p.PrdNodeType,p.Product,'2010-01-01','',0,p.MRP,p.RLP,p.PcsInBox,0,0,0,0,p.flgInitiative,flgInactive,p.flgFB,p.FBID,p.Volume,p.VolUom,p.Grammage,p.stockavailable
,p.TargetValue,p.flgNewPrd,p.flgNPD,p.NPDID,[flgSaleType],SectorId,p.flgSP,p.flgSeq
from #Prd p join tblTCOrderDetail(nolock)
b on p.PrdNodeId=b.PrdNodeId
and p.PrdNodeType=b.PrdNodeType
WHERE not EXISTS(SELECT * from #PrdList where #PrdList.PrdNodeId=p.PrdNodeId
and #PrdList.PrdNodeType=p.PrdNodeType) and b.OrderID=@orderid

Update a set a.CategoryNetValue=b.CategoryNetValue from #PrdList a join #PrdList b on a.CatNodeID=b.CatNodeID
where a.CategoryNetValue=0 and b.CategoryNetValue<>0

--Update a set a.brandNetValue=b.brandNetValue from #PrdList a join #PrdList b on a.Brand=b.Brand
--where a.brandNetValue=0 and b.brandNetValue<>0
end
print 'dsd'
--SELECT * FROM #LastBillQty WHERE PrdNodeId=547
--select * from #PrdList where PrdNodeId=6
select a.PrdNodeId,a.PrdNodeType,Category,Brand,PrdName as [Product Name],convert(numeric(18,2),a.TargetValue) as [Tgt Val] ,stockavailable as Stock,convert(numeric(18,0),MRP)  AS MRP,PcsInBox as UPC,Case when a.[flgSaleType]=1 then convert(int,
(CONVERT(FLOAT,
AVG(a.Qty)))) ELSE convert(int,
(CONVERT(FLOAT,
AVG(a.Qty))))/PCSINBOX END  as [Suggested Qty],0 as [Order Qty],Case when a.[flgSaleType]=1 then 'PCS' ELSE 'CS' END UOM,

 convert(numeric(18,6),RLP)
 AS Rate
 ,convert(int,0) as [Tot Free Qty]
 ,convert(int,0) as [Free Qty]
,convert(numeric(18,2),0.00) as [InvLevelDisc]
,convert(numeric(18,2),0.00) as [Disc Val Per UOM]
,convert(numeric(18,2),0.00) as [Net Rate]
,convert(numeric(18,2),0.00) as [Disc Value]
,convert(numeric(18,2),0.00) as [Line Value]
,CategoryNetValue,brandNetValue,PrdNetValue,case when flgNPD=1 then 1 else 2 end as OrderType,convert(varchar(100),'') as SBDGroup,A.CatNodeID,NPDID AS SBDGroupId,0 as flgBaseProduct,0 as SBDPrdCnt,a.flgInitiative,flgInactive,a.flgFB,a.FBID,flgNPD as flgSBD,
VolUom,Volume,Grammage,a.flgNewPrd,a.[flgSaleType],a.SectorId,a.flgSP,flgSeq
into #TmpCrossTab from #PrdList a left join #LastBillQty
b on a.PrdNodeId=b.PrdNodeId
and a.PrdNodeType=b.PrdNodeType INNER JOIN #Cat ON a.CatNodeID=#Cat.CatNodeID
group by 
Category,Brand,a.PrdNodeId,a.PrdNodeType,flgInactive,PrdName,MRP,RLP,PcsInBox,CategoryNetValue,a.brandNetValue,PrdNetValue,b.Qty,A.CatNodeID,a.flgInitiative
,flgFB,FBID,VolUom,Volume,Grammage,stockavailable,convert(numeric(18,2),a.TargetValue) --having  SUM(Qty)>0
,a.flgNewPrd,flgNPD,NPDID,a.[flgSaleType],a.SectorId,a.flgSP,flgSeq


--Update a set SBDGroup=b.SBDGroupName,OrderType=1,SBDGroupId=b.SBDGroupID,SBDPrdCnt=
--case when  a.[Product Name]<>b.SBDGroupName then 0 else 
--b.SBDPrdCnt end,flgSBD=1 from #TmpCrossTab a join #SBDGroupList b on a.PrdNodeId=b.SBFNodeID
--and a.PrdNodeType=b.SBFNodeType

print 'dsd32332'
--insert into #TmpCrossTab
--select a.SBFNodeID,a.SBFNodeType,p.Category,p.Brand,p.SBF,p.MRP,p.PCSINBOX,0,0,'PCS',RLP,0,0,0,0,0,0,3,A.SBDGroupName,p.CatNodeID,a.SBDGroupID,0 ,
--case when p.SBF<>A.SBDGroupName then 0 else 

--a.SBDPrdCnt end,p.flgInitiative,p.flgInactive,p.flgFB,p.FBID,1 from #SBDGroupList a join #Prd p on a.SBFNodeID=p.PrdNodeId
--and a.SBFNodeType=p.PrdNodeType
--LEFT JOIN #TmpCrossTab t on t.PrdNodeId=a.SBFNodeID
--and t.PrdNodeType=a.SBFNodeType
--where t.PrdNodeId is null


--insert into #TmpCrossTab
--select p.SBFNodeId,p.SBFNodeType,p.Category,p.Brand,p.SBF,p.MRP,p.PCSINBOX,0,0,'PCS',RLP,0,0,0,0,0,0,4,'',p.CatNodeID,0,0 ,
--0,p.flgInitiative,p.flgInactive,p.flgFB,p.FBID,0 from #Prd p 
--LEFT JOIN #TmpCrossTab t on t.PrdNodeId=p.SBFNodeID
--and t.PrdNodeType=p.SBFNodeType
--where t.PrdNodeId is null and p.flgFB=1

update a set a.OrderType=b.OrderType from #TmpCrossTab  a join #TmpCrossTab b on a.SBDGroupId=b.SBDGroupId
where a.OrderType=3 and b.OrderType=1
Update a set a.CategoryNetValue=b.CategoryNetValue from #TmpCrossTab a join #TmpCrossTab b on a.CatNodeID=b.CatNodeID
where isnull(a.CategoryNetValue,0)=0 and b.CategoryNetValue<>0

--Update a set a.brandNetValue=b.brandNetValue from #TmpCrossTab a join #TmpCrossTab b on a.Brand=b.Brand
--where isnull(a.brandNetValue,0)=0 and b.brandNetValue<>0

Update #TmpCrossTab set flgBaseProduct=1 where   [Product Name]=SBDGroup

Delete #TmpCrossTab where flgBaseProduct=0 and flgInactive=1 and SBDGroupId<>0


print 'ttt'
if @orderid >0
begin
update #TmpCrossTab set [Order Qty]=0,[Line Value]=0,[Disc Value]=0,InvLevelDisc=0,[Tot Free Qty]=0,[Disc Val Per UOM]=0
Update a set [Order Qty]=
Case when a.[flgSaleType]=1 then b.OrderQty ELSE b.OrderQty/a.UPC END

,[Net Rate]=b.NetLineOrderVal/b.OrderQty,[Line Value]=b.NetLineOrderVal,[Disc Value]=b.TotLineDiscVal,[Disc Val Per UOM]=case when a.[flgSaleType]=1 then b.TotLineDiscVal/b.OrderQty ELSE ((b.TotLineDiscVal/b.OrderQty)*a.UPC) END,InvLevelDisc=b.InvLevelDisc,[Tot Free Qty]=b.FreeQty from #TmpCrossTab a join tblTCOrderDetail b on a.PrdNodeId=b.PrdNodeId
and a.PrdNodeType=b.PrdNodeType
where b.OrderID=@orderid
print 'dasdf'
--Update a set InOrder=(select isnull(sum(orderqty),0) from tblTCOrderDetail z join #Prd b on z.PrdNodeId=b.SBFNodeId  where OrderID=@orderid and a.FBId=b.FBID and z.flgFB=1 ) from  #FBData a WHERE a.SlabTypeId=1

--Update a set InOrder=(select isnull(sum(orderqty*ProductRate),0) from tblTCOrderDetail z join #Prd b on z.PrdNodeId=b.SBFNodeId  where OrderID=@orderid and a.FBId=b.FBID and z.flgFB=1 ) from  #FBData a WHERE a.SlabTypeId=4

end
alter table #TmpCrossTab add IsFBProductShow tinyint not null default(1)

--update a set IsFBProductShow=isnull((select isnull(Max(IsProductShow),0) from #FBData z where z.FBId=a.FBID),0) from #TmpCrossTab a 
--Update a set SBDPrdCnt=(select count(*) from #TmpCrossTab z

--where a.SBDGroupID=z.SBDGroupID) from #TmpCrossTab a where SBDGroupId<>0 and [OrderType] in(3,1) --where flgBaseProduct=1

--update a set SBDGroupId=b.SBDGroupID,flgSBD=1 from #TmpCrossTab a join #TotSBDGroupId b on a.PrdNodeId=b.SBFNodeID
--and a.PrdNodeType=b.SBFNodeType
--where a.SBDGroupId=0

--Delete #TmpCrossTab where [Suggested Qty]<0 and [Order Qty]<=0 and SBDGroupId=0
--SELECT DISTINCT DisplayDate, InvDate FROM #PrdList --WHERE InvDate IN(SELECT InvDate FROM #InvDT)

DECLARE @strSQL varChar(2000)
	DECLARE @DisplayDate varChar(10)
	DECLARE @OrderDate DATE
	print 'sss'
	DECLARE @curDate CURSOR
	SET @curDate=CURSOR FOR SELECT DISTINCT DisplayDate, InvDate FROM #PrdList WHERE InvDate IN(SELECT InvDate FROM #InvDT) ORDER BY InvDate DESC
	OPEN @curDate
	FETCH NEXT FROM @curDate INTO @DisplayDate, @OrderDate
	WHILE @@FETCH_STATUS=0
		BEGIN
			SET @strSQL='ALTER TABLE #TmpCrossTab Add [' + @DisplayDate + '] varchar(30)'
			EXEC (@strSQL)
			SET @strSQl=''
			SET @strSQl='UPDATE #TmpCrossTab SET #TmpCrossTab.[' + @DisplayDate + '] = CASE WHEN #PrdList.[flgSaleType]=2 then #PrdList.Qty/#PrdList.PCSInBox
			else #PrdList.Qty end FROM  #TmpCrossTab INNER JOIN #PrdList ON #TmpCrossTab.PrdNodeId= #PrdList.PrdNodeId WHERE #PrdList.DisplayDate=''' + @DisplayDate + ''''
			PRINT @strSQL
			EXEC (@strSQL)
			FETCH NEXT FROM @curDate INTO @DisplayDate,@OrderDate
		END

	CLOSE @CurDate
	DEALLOCATE @CurDate

	Declare @i int,@cnt int=5,@ik int
	--IN(SELECT InvDate FROM #InvDT)
	select @i=count(distinct InvDate) from #InvDT
	set @ik=@i
	while @i<@cnt
	begin

				SET @strSQL='ALTER TABLE #TmpCrossTab Add [NA'+convert(varchar,@i-@ik+1)+'] varchar(30)'
				EXEC (@strSQL)
	set @i=@i+1
	end
select * from #TmpCrossTab
ORDER BY CategoryNetValue DESC,Category,brandNetValue desc,OrderType,SBDGroup,flgBaseProduct DESC,PrdNetValue DESC
 --ORDER BY Category,[Order Qty] desc

 select b.flgOrderSource,b.InvId,b.InvNo,format(b.InvDate,'dd-MMM') as [Inv Date],sum(NetValue) as NetValue,b.InvDate into #Top5Inv  from #InvDt a join #StoreLastOrderDetail b on a.InvDate=b.invdate

 group by b.flgOrderSource,b.InvId,b.InvNo,b.InvDate
 order by b.invdate desc
 select flgOrderSource,InvId,a.InvNo,a.[Inv Date],NetValue,case Row_number() over(order by a.invdate desc) when 1 then 1 else 0 end  as flgTeleOrderInv,0.00 as  OutstandingAmt from #Top5Inv a 

 --select 0 as InvId,'' as InvNo,'' as [Inv Date],0 as NetValue,'' as Status where 1<>1

 --select  Top 5 a.OrderID ,a.OrderCode ,format(a.orderdate,'dd-MMM') as [Inv Date],a.NetOrderValue as NetValue,b.InvStatus as Status,orderdate as InvDate into #Top5Inv from tblTCOrderMaster a join tblMstrInvStatus b on a.StatusId=b.InvStatusId where storeid=@StoreId order by 1 desc

 --select OrderID,OrderCode,[Inv Date],NetValue,Status from #Top5Inv

 --select * from tblTCOrderMaster

	SELECT        ReasonCodeID, REASNCODE_LVL1NAME, REASNCODE_LVL2NAME, case when reasoncodeid=8 then 1 else 0 end as flgSchedule,flgRunningIssue
FROM            tblReasonCodeMstr where REASNCODE_LVL1NAME='Not Connected'


	SELECT        ReasonCodeID, REASNCODE_LVL1NAME, REASNCODE_LVL2NAME, case when reasoncodeid=8 then 1 else 0 end as flgSchedule,flgRunningIssue
FROM            tblReasonCodeMstr where REASNCODE_LVL1NAME='Connected but No Order' order by Sequence
print 'dfafasdfasdfd'
 Declare @VisitDate varchar(50)='',@VisitStatus varchar(100)='',@LastInvDate varchar(50)='',@TeleCallDate varchar(50)='',@CallStatus varchar(100)='',@BranchCCRDataId int,@MaxTeleCallingId int,
 @LastOrderedDate date,
 @LastVisitDate date,
 @LastTASCallDate date,
@LastOrderedValue varchar(30),
@LastVisitStatus varchar(100),
@LastTASCallStatus varchar(100),
@LastOrderedPerson varchar(100),
 @LastVisitPerson varchar(100),
 @LastTASCallPerson varchar(100)

 
--select @LastOrderedDate=max(invdate),@LastOrderedValue=sum(NetValue),@LastOrderedPerson=p.descr from tblP3MSalesDetail a join tblMstrPerson p on p.nodeid=a.dsenodeid where invid=@invid
--group by p.descr

set @LastInvDate=format(@LastOrderedDate,'')
 --select top 1 @LastInvDate=[Inv Date] from #Top5Inv order by InvDate DESC
 print 'asdffd1111'
 select @LastVisitDate=LastVisit,@VisitStatus=LastVisitStatus,@LastVisitPerson=VisitedBy,
 @LastOrderedDate=LastOrderDate,@LastOrderedValue=LastOrderValue,@LastOrderedPerson=OrderBy,
 @LastTASCallDate=LastCall,@LastTASCallStatus=LastCallStatus,@LastTASCallPerson=LastCalledBY
 
 from tblTeleCallerListForDay where TeleCallingId=@TeleCallingId
 --select @BranchCCRDataId=isnull(max(BranchCCRDataId),0)  from tblBranchCCRData where storeid=@StoreId 
 set @LastVisitStatus=@VisitStatus
 set @VisitDate=isnull(format((@LastVisitDate),'dd-MMM')+' by '+@LastVisitPerson,'')

 --select @VisitDate=isnull(format((VisitDate),'dd-MMM')+' by '+p.Descr,''),@VisitStatus=case when OrderValue>0 then 'Productive' else [Reason Code] end,
 --@LastVisitStatus=case when OrderValue>0 then 'Productive' else [Reason Code] end,
 --@LastVisitDate=VisitDate,@LastVisitPerson=p.Descr from tblBranchCCRData a join tblMstrPerson p on a.DSENodeId=p.NodeID where BranchCCRDataId=@BranchCCRDataId

 --set @BranchCCRDataId=0
 --select @BranchCCRDataId=isnull(max(BranchCCRDataId),0) from tblBranchCCRData where StoreId=@StoreId and OrderValue>0


 --select @LastOrderedDate=VisitDate,@LastOrderedValue=OrderValue,@LastOrderedPerson=p.Descr from tblBranchCCRData a join tblMstrPerson p on a.DSENodeId=p.NodeID where BranchCCRDataId=@BranchCCRDataId
 

 --if @LastOrderedDate is null
 --begin
	-- set @LastOrderedDate=dateadd(dd,-2000,Getdate())

 --end
 --print @LastOrderedDate
 --print 'dsasdf'
 --Declare @LOrderId int=0
 --select @LOrderId=isnull(Max(OrderId),0) from tblTCOrderMaster where storeid=@storeid and orderdate>@LastOrderedDate and flgOrderSource=1
 --if @LOrderId=0
 --begin
 -- select @LOrderId=isnull(Max(OrderId),0) from tblTCOrderMaster_history where storeid=@storeid and orderdate>@LastOrderedDate and flgOrderSource=1
	--if @LOrderId<>0
	--begin
	--  select @LastOrderedDate=OrderDate,@LastOrderedValue=NetOrderValue,@LastOrderedPerson=u.UserFullName from tblTCOrderMaster_History a join vwTeleCallerListForDay b on a.TeleCallingId=b.TeleCallingId
 -- join tblSecUser u on u.UserID=b.TeleUserId
 -- where a.OrderID=@LOrderId
	--end

 --end
 --else 
 --begin
 -- select @LastOrderedDate=OrderDate,@LastOrderedValue=NetOrderValue,@LastOrderedPerson=u.UserFullName from tblTCOrderMaster a join vwTeleCallerListForDay b on a.TeleCallingId=b.TeleCallingId
 -- join tblSecUser u on u.UserID=b.TeleUserId
 -- where a.OrderID=@LOrderId
 --end

--  select @MaxTeleCallingId=Max(TeleCallingId) from vwTeleCallerListForDay(nolock) where StoreId=@StoreId and Date<convert(date,Getdate())
--and flgCallStatus<>0


-- select @LastTASCallDate=Date,@CallStatus=case when flgCallStatus=2 then 'Productive' else 'UnProductive' end,
--@LastTASCallStatus=case when flgCallStatus=2 then 'Productive' else r.REASNCODE_LVL2NAME end,@LastTASCallPerson=u.UserFullName
-- --,
-- --case when @LastVisitDate
-- from vwTeleCallerListForDay(nolock) a left join tblReasonCodeMstr r on r.ReasonCodeID=a.ReasonId join tblSecUser u on u.UserID=a.TeleUserId where TeleCallingId=@MaxTeleCallingId
print 'tadffasds'
 set @TeleCallDate=format(@LastTASCallDate,'dd-MMM')

-- if @LastTASCallDate>@LastVisitDate
--begin
--set  @LastVisitDate=@LastTASCallDate
--set @LastVisitStatus=@LastTASCallStatus
--set @LastVisitPerson=@LastTASCallPerson
--end
 --select @LastInvDate as LastInvDate,isnull(@TeleCallDate,'') as TeleCallDate,isnull(@VisitDate,'') as VisitDate

 Select 'Last Visit Date'as PreviousText,isnull(@VisitDate,'') as PreviousValue 
 union all
 Select 'Visit Status'as PreviousText,isnull(@VisitStatus,'') as PreviousValue 
 union all
 Select 'Last TeleCall Date'as PreviousText,isnull(@TeleCallDate,'') as PreviousValue 
 union all
 Select 'Call Status'as PreviousText,isnull(@CallStatus,'') as PreviousValue 
 union all
 Select 'Last Invoice Date'as PreviousText,@LastInvDate as PreviousValue 


 Select 'Outstanding As On '+format(OutstandingDate,'dd-MMM-yy') as OutStandingText,OutstandingAmt as OutStandingValue from tblTeleCallerListForDay(nolock) WHERE TeleCallingId=@TeleCallingId and OutstandingAmt is not null




Declare @NoOfLSSSchme INT  
  Select @NoOfLSSSchme=count(distinct b.SchemeID)  from tblSchemeApplicabilityDetail a join tblSchemeDetail b on a.SchemeDetID=b.SchemeDetID
join tblSchemeMaster c on c.SchemeID=b.SchemeID
where @Date between b.SchemeFromDate and b.SchemeToDate and c.flgActive=1
and ((a.StoreId=@Storeid or a.StoreId=0) and (a.ChannelId=@ChannelId or a.ChannelId=0)

and (a.SubChannelId=@SubChannelId or a.SubChannelId=0)
and ((a.DistributorNodeId =@DistNodeId and a.DistributorNodeType=@DistNodeType) or a.DistributorNodeId=0)
) and c.SchemeCode like 'LSS%' and c.schemetypeid=2




Update   [tblTeleCallerListForDay] set FiveStarNoOfLSSTgt=@NoOfLSSSchme where FiveStarNoOfLSSTgt>@NoOfLSSSchme and @NoOfLSSSchme<2
and TeleCallingId=@TeleCallingId

Declare @NoOfGPTgt tinyint

select @NoOfGPTgt=count(distinct SBDGroupId) from #TmpCrossTab where OrderType in(1,3) and flgBaseProduct=1 and SBDGroupId>0

Update   [tblTeleCallerListForDay] set FiveStarNoOfGPTgt=@NoOfGPTgt 
where FiveStarNoOfGPTgt>@NoOfGPTgt 
and TeleCallingId=@TeleCallingId


select A.StoreCode,
A.StoreName,
A.ContactPerson,
a.ContactNo,
A.Channel,a.SOName as PersonName,b.Descr+' ['+b.DistributorCode+']' as Distributor,
case when a.RuleId in(1,2) then 
r.RuleDisplayName +' '+t.TeleReason+'<b>'+format(a.LastVisit,'dd-MMM')

when a.RuleId=3
then
r.RuleDisplayName 

when a.RuleId=4
then
r.RuleDisplayName  end
as [Call Type],
case when a.RuleId in(2) then 
r.RuleDisplayName +' '+t.TeleReason+'<b>'+isnull(format(a.LastVisit,'dd-MMM'),'')

when a.RuleId=3
then
r.RuleDisplayName 

when a.RuleId=1
then
r.RuleDisplayName  end
as [Reason],sc.SectorCode,a.SectorId,format(isnull(scheduleDate,Date),'dd-MMM-yyyy') as ScheduleDate,isnull(@Remarks,'') AS Remarks ,'' as BirthDate,'' as AnniversaryDate

--,
--sm.[Customer Type]
,a.subchannel as [Customer Type]
,a.subchannel,isnull(a.AlternateContactNo,'') as  AlternateContactNo,a.FiveStarNoOfGPTgt,a.FiveStarNoOfLSSTgt,a.FiveStarIndTgtDlvryVal,a.FiveStarProductivityTgt,
a.FiveStarTotIndTgtDlvryVal, @NoOfLSSSchme AS NoOfLSSSchme, 44 AS TotMnthGPTgt,FiveStarNoOfLSSAct,a.RouteName
,
(select Language from tblLanguageMaster where LngID=@LanguageId) as Languge,sh.ASMName +' ('+ sh.ASMArea+')' as ASM,
a.City,format(dateadd(dd,isnull(NoOfDlvryDays,2),a.Date ),'dd-MMM-yyyy') as DlvryDate,DSEComments,
DSEIssueIds,(select count(*) from #TmpCrossTab where sectorid=a.sectorid and flgSP=1) AS flgSP,IsDiscountApplicable,pr.PrcRegion,
a.DialerTypeId
from [dbo].[tblTeleCallerListForDay] a(nolock) join  tblDBRSalesStructureDBR b on a.DistNodeId=b.nodeid
and a.DistNodeType=b.nodetype
join tblMstrTeleCallRule r on r.RuleId=a.RuleId
join tblTeleReasonMstr t on t.TeleReasonId=a.TeleReasonId
left join tblMstrFrequency f on f.FrqTypeId=a.FrequencyId
left join #SalesHier sh on sh.SONodeId=a.SONodeId
and sh.sonodetype=a.sonodetype
 left join tblMstrSector sc on sc.SectorId=a.SectorId
 LEFT Join tblpriceregionmstr pr on pr.PrcRgnNodeId=a.PrcRegionId
 --join tblStoreMaster sm on sm.StoreID=a.StoreId
 WHERE TeleCallingId=@TeleCallingId
 print 'dfafasdfasdfd122'
-- select * into #NewPrd from vwProductHierarchyUptoSBF  where flgSearchList=1

--SELECT DISTINCT Category, a.SBFNodeId, a.SBFNodeType, SBF,isnull(b.MRP,a.MRP) as MRP,isnull(b.RLP,a.RLP) as RLP,isnull(b.PCSINBOX,a.PCSINBOX) as PCSINBOX,flgNewStore,flgSearchList 
--FROM            #NewPrd a left join #SBFPrice b on a.SBFNodeId=b.SBFNodeId
--and a.SBFNodeId=b.SBFNodeType where a.flgSearchList=1 and
--not exists(select * from #TmpCrossTab where PrdNodeId=a.SBFNodeId and PrdNodeType=a.SBFNodeType)
--ORDER BY CategoryNetValue DESC,SBFNetValue DESC
--select * from #Top5Inv

alter table #Prd add flgSBD tinyint not null default(0),SBDGroupId int not null default(0)

--update a set flgSBD=1,SBDGroupId=B.SBDGroupID from #Prd a join #TotSBDGroupId b on a.SBFNodeId=b.SBFNodeID
--and a.SBFNodeType=b.SBFNodeType

SELECT DISTINCT Category,Brand,SBF, a.PrdNodeId, a.PrdNodeType, Product,a.MRP,Convert(numeric(18,2),a.RLP) as RLP,a.PCSINBOX,Grammage,VolUom,Volume,flgNewStore,flgSearchList,Search,a.CatNodeID ,a.flgInitiative,a.flgFB,
a.FBID,0 as flgSBD,0 as SBDGroupId,stockavailable,convert(numeric(18,2),a.TargetValue) as TargetValue
FROM           #Prd a 
INNER JOIN #Cat ON a.CatNodeID=#Cat.CatNodeID  where ---flgSearchList=1 and
not exists(select * from #TmpCrossTab where PrdNodeId=a.PrdNodeId and PrdNodeType=a.PrdNodeType)

Declare @InvId int=0,@InvD date,@flgSource tinyint
--select @InvId= isnull(Max(invid),0) from tblP3MSalesDetail where StoreId=@StoreId

select @InvD= Max(InvDate) from tblP3MSalesDetail where StoreId=@StoreId

select @flgSource=flgOrderSource,@InvId=InvId from tblP3MSalesDetail where StoreId=@StoreId and InvDate=@Invd order by [flgOrderSource],InvId desc


select @LastOrderedPerson=coalesce(p.descr,t.TeleCallerCode,''), @LastOrderedDate=Max(InvDate),@LastOrderedValue=convert(numeric(18,2),SUM(NetValue)) from tblP3MSalesDetail a 
left join tblTeleCallerMstr t on t.TeleCallerId=a.DSENodeId
and t.NodeType=a.DSENodeType
left join tblMstrPerson p on p.NodeID=a.DSENodeId
and p.NodeType=a.DSENodeType
where flgOrderSource=@flgSource and InvId=@InvId
group by coalesce(p.descr,t.TeleCallerCode,'')

--select @LastOrderedPerson=p.Descr from tblP3MSalesDetail z join tblMstrPerson p on z.DSENodeId=p.NodeID
--where z.InvId=@InvId
select strSchemeBenefit,TotLineOrderVal,TotLineLevelDisc,TotOrderVal,TotDiscVal,TotOrderValWDisc,TotTaxVal,NetOrderValue ,TotMRPValue from tblTCOrderMaster where TeleCallingId=@TeleCallingId and flgOrderSource=1

select 'Date' as [Particular], format(@LastOrderedDate,'dd-MMM') AS [Last Invoiced],format(@LastTASCallDate,'dd-MMM') as [Last TAS Call]
UNION ALL
select 'Value Status' as [VISIT /CALL DETAILS], @LastOrderedValue,@LastTASCallStatus
UNION ALL
select 'Seller / Caller' as [VISIT /CALL DETAILS], @LastOrderedPerson,@LastTASCallPerson

--Select sum([Suggested Qty]*Rate) AS TotalOrderValue,sum(case when [Suggested Qty]>0 then 1 else 0 end) as #LineOrder from #TmpCrossTab 

SELECT 0 AS flgGPTarget,0 as Target

--SELECT 0 AS flgFBDisplay,0 as Target,0 as Ach 

select '' as [FOCUS BRAND],'' AS [SUB Brand Form],'' as GAP where 1<>1
--select * from #FBData
--select b.FBId,b.SBFNodeId,b.SBFNodeType,c.Descr from #FBData a join tblINITFocusBrandProductDetail b on a.FBId=b.FBId
--join tblPrdMstrHierLvl4 c on c.NodeID=b.SBFNodeId and c.NodeType=b.SBFNodeType



--select 0 as TargetValue,0 as  ActSalesValue  

select case when @PendingVisits>0 then isnull(sum(TargetValue),0)/@PendingVisits else isnull(sum(TargetValue),0) end as TargetValue,0 as  Achieved  from #TargetData


select isnull(sum(MonthlyTarget),0)as MonthlyTargetValue,isnull(sum(MonthlyTarget),0)-isnull(sum(TargetValue),0) as  Achieved,isnull(sum(TargetValue),0)as BalanceTargetValue  from #TargetData


--select TargetValue,ActSalesValue from tblLeapRetailerTargetData where StoreId=@StoreId and  MonthVal=month(@date) and YearVal=year(@date)

select fbid,Brand,count(*) as [# Of SKU] from #Prd WHERE flgFB=1 group by fbid,Brand



select a.*,case when b.TelecallerId is not null then 1 else 0 end as IsTeleCallerMap from tblLanguageMaster a left join tblTeleCallerLanguageMapping b on a.LngID=b.LanguageId
and b.TelecallerId=@TCNodeId

select NPDID,Brand,count(*) as [# Of SKU] from #Prd WHERE flgNPD=1 group by NPDID,Brand

insert into tblTeleCallerCallDetail(TeleCallingId ,flgOrderSource ,CallType,CallDateTime) values (@TeleCallingId,@flgOrderSource,1,@CurrDate)

Update tblTeleCallerListForDay set CallStartDate=Getdate() where TeleCallingId=@TeleCallingId 


end
