
  --select * from tblpdamaster
--select * from tblSalesHierChannelMapping  
--Declare @Date datetime=Getdate(),@IMEI varchar(50)='867626026311211'

 --Declare @Date datetime=Getdate() 

 --SELECT * FROM TBLPDAMASTER
 --

 --SELECT * FROM 
 -- exec spSchemeDetailByIMEI  '866924027227762','2018-02-26' 
CREATE proc [dbo].[spSchemeDetailByIMEIN]   
@PDACode varchar(100),  
@Date datetime,
@CoverageAreaNodeID INT = 0,
@CoverageAreaNodeType SMALLINT  =0 
  
AS  
BEGIN  
Print 'Step1'
--insert into [dbo].[tmpSchemeIMEIInfo_tobeDelete] values(@IMEI,@Date)
    Declare @PersonNodeId int,@PersonNodeType int
SELECT @PersonNodeID=NodeID,@PersonNodeType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

CREATE TABLE #DSRRouteList (CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT,CoverageArea VARCHAR(500),PersonNodeID INT,PersonNodeType SMALLINT,PersonName VARCHAR(200), RouteID INT, RouteNodeType SMALLINT,Route VARCHAR(500),flgDefaultRoute TINYINT)

 IF Object_id('tempdb..#tmpRouteStoreId') is not null
BEGIN
DROP TABLE #tmpRouteStoreId
END
 SELECT DISTINCT R.RouteNodeId RouteID,R.RouteNodeType,R.StoreId,s.ChannelId,s.subchannelid,r.DistNodeId,
r.DistNodeType,s.StateId INTO #tmpRouteStoreId FROM tblRouteCalendar(nolock) R
 JOIN tblstoremaster s on r.storeid=s.storeid
WHERE R.VisitDate>=@Date AND R.SONodeId=@PersonNodeId AND R.SONodeType=@PersonNodeType
 --select * from #tmpRouteStoreId
 IF Object_id('tempdb..#tmpSchDet') is not null
BEGIN
DROP TABLE #tmpSchDet
END

--SELECT * FROM #tmpRouteStoreId


IF Object_id('tempdb..#tmpStoreId') is not null  
begin  
drop table #tmpStoreId  
end  
Create table #tmpStoreId(StoreId int,SchemeDetId int)
insert into #tmpStoreId
Select distinct a.StoreId,b.SchemeDetId  from  tblSchemeApplicabilityDetail z join tblSchemeDetail b on z.SchemeDetID=b.SchemeDetID
join tblSchemeMaster c on c.SchemeID=b.SchemeID
join #tmpRouteStoreId A on (A.StoreId=z.StoreId or Z.StoreId=0)
and (A.ChannelId=z.ChannelId or Z.ChannelId=0)
and (A.SubChannelId=z.SubChannelId or Z.SubChannelId=0)
and ((A.DistNodeId=z.DistributorNodeId and A.DistNodeType=z.DistributorNodeType) or Z.DistributorNodeId=0)
and (A.stateid=z.stateid or Z.stateid=0)

--SELECT * FROM #tmpStoreId



--union
--Select distinct B.StoreId,d.SchemeDetId  from #tmpRouteStoreId A join tblStoreMaster B ON A.StoreId=B.StoreId
--JOIN #tmpSchemeStoreChannel d ON  (B.OutChannelID=d.CHNodeID or D.CHNodeID=0)
--join tblOutletAddressDet OA on OA.Storeid=B.StoreId
--JOIN #tmpLocSchemeMapping e ON  (OA.CityId=e.CityNodeId )
--join #tmpSchDet f ON f.SchemeDetId=d.SchemeDetId
--and f.SchemeDetId=e.SchemeDetId
--where f.flgSearchType=2
--union

----Select distinct B.StoreId,d.SchemeDetId  from #tmpRouteStoreId A join tblStoreMaster B ON A.StoreId=B.StoreId
----JOIN #tmpSchemeStoreChannel d ON  (B.OutChannelID=d.CHNodeID or D.CHNodeID=0)
----join tblOutletAddressDet OA on OA.Storeid=B.StoreId
----left JOIN #tmpLocSchemeMapping g ON  (OA.CityId=g.CityNodeId )
----and d.SchemeDetId=g.SchemeDetId
----left  join #tmpRouteSchemeMapping1 E ON E.RouteId=A.RouteId
----and E.RouteNodeType=A.RouteNodeType and E.SchemeDetId=d.SchemeDetId
----left  join #tmpRouteSalesSchemeMapping S ON S.RouteId=A.RouteId
----and S.RouteNodeType=A.RouteNodeType and S.SchemeDetId=d.SchemeDetId
----join #tmpSchDet f ON f.SchemeDetId=d.SchemeDetId


--and f.SchemeDetId=g.SchemeDetId
--join #tmpRouteSchemeMapping E ON E.RouteId=A.RouteId
--and E.RouteNodeType=A.RouteNodeType

----where f.flgSearchType=2 AND (S.RouteId is not null or g.SchemeDetId is not null or E.SchemeDetId is not null)

----JOIN #tmpSchemeStoreClass C ON C.SchemeDetId=e.SchemeDetId
----AND (B.StorePotentialTypeId=C.SCNodeId or C.SCNodeId=0)

--JOIN #tmpSchemeStoreChannel d ON d.SchemeDetId=e.SchemeDetId
--AND (B.OutChannelID=d.CHNodeID or D.CHNodeID=0)

----JOIN #tmpSchemeStoreType F ON F.SchemeDetId=e.SchemeDetId
----AND (B.StoreTypeID=F.StoreTypeHierId or F.StoreTypeHierId=0)


----JOIN #tmpSchemeStoreAccount G ON G.SchemeDetId=e.SchemeDetId
----AND (B.AccountTypeId=G.ACTypeID or G.ACTypeID=-1)

--select * from tblstoremaster
if (object_id('tempdb..#tmpStoreScheme')is not null)  
begin  
drop table #tmpStoreScheme  
end  

  
select Distinct A.StoreID, B.SchemeID into #tmpStoreScheme from tblSchemeMaster B JOIN tblSchemeDetail C ON C.SchemeID=B.SchemeID
join   #tmpStoreId A ON C.SchemeDetID=A.SchemeDetID
where flgActive=1 and B.IsApplyOnSFA=1
  
  SELECT * FROM #tmpStoreScheme
  
if (object_id('tempdb..#tmpScheme')is not null)  
begin  
drop table #tmpScheme  
end  
  
--select distinct SchemeID into #tmpScheme from #tmpRouteSchemeMapping  
SELECT distinct SchemeID into #tmpScheme from #tmpStoreScheme
  
  
Select  B.SchemeID,SchemeName,SchemeApplicationID,SchemeApplRule AS SchemeAppliedRule,SchemeTypeId from #tmpScheme A join tblSchemeMaster B ON A.SchemeID=B.SchemeID  
JOIN tblSchemeDetail C ON C.SchemeID=B.SchemeID  

  
  
  
Select  B.SchemeID,C.SchemeSlabID,SlabDescrOrg AS SchemeSlabDesc,BenifitDescrOrg as BenifitDescr from #tmpScheme A join tblSchemeMaster B ON A.SchemeID=B.SchemeID  
JOIN tblSchemeSlabDetails C ON C.SchemeID=B.SchemeID  
JOIN tblSchemeSlabOutput D ON C.SchemeSlabID=D.SchemeSlabID  
  
  
  
  
if (object_id('tempdb..#SlabSplit')is not null)  begin  
drop table #SlabSplit  
end  
  
select A.SchemeID,A.SchemeSlabID,B.* into #SlabSplit from #tmpScheme C INNER JOIN  tblSchemeSlabDetails A  
  
ON C.SchemeID=A.SchemeID  
 cross apply  dbo.SlabSplit(A.SlabPrdStr) B  

 --SELECT 'Test'
 --SELECT * FROM #SlabSplit
  
  
   
if (object_id('tempdb..#tmpSchemeDet')is not null)  
begin  
drop table #tmpSchemeDet  
end  
  
select distinct SchemeSlabID into #tmpSchemeDet from #SlabSplit  
  
  
if (object_id('tempdb..#BenSplit')is not null)  
begin  
drop table #BenSplit  
end  
   
select D.SchemeID,A.SchemeSlabID,B.* into #BenSplit from #tmpSchemeDet C INNER JOIN  tblSchemeSlabOutput A  
  
ON C.SchemeSlabID=A.SchemeSlabID  
INNER JOIN  tblSchemeSlabDetails D ON D.SchemeSlabID=A.SchemeSlabID  
  
 cross apply  dbo.BenSplit1(A.strPrdFreePrd) B  
  
  
 if (object_id('tempdb..#prod')is not null)  
begin  
drop table #prod  
end  
select NodeId,NodeType into #prod from #SlabSplit where SlabSubBucketType<>'2' and NodeId<>''  
union  
select NodeId,NodeType from #BenSplit where BenSubBucketType<>4 and NodeId<>''  
  
  
 if (object_id('tempdb..#ActProd')is not null)  
begin  
drop table #ActProd;  
end;  
with cte as  
(  
select A.NodeId,A.NodeType,A.NodeId as PNodeId,A.NodeType as PNodeType,A.HierId  from tblPrdMstrHierarchy A join #prod B  
ON A.Nodeid=B.Nodeid and A.NodeType=B.NodeType  and convert(varchar,getdate(),112) between convert(varchar,a.VldFrom,112) and convert(varchar,a.VldTo,112)
union all  
select A.NodeId,A.NodeType,B.PNodeId as PNodeId,B.PNodeType as PNodeType,A.hierId from tblPrdMstrHierarchy A join cte B  
ON A.PNodeid=B.Nodeid and A.PNodeType=B.NodeType and A.PHierId=B.HierId   and convert(varchar,getdate(),112) between convert(varchar,a.VldFrom,112) and convert(varchar,a.VldTo,112)
)   
  
select a.*,b.ManufacturerID into  #ActProd from cte a join tblPrdMstrskulvl b on a.NodeId=b.NodeId where a.NodeType=20   and  b.isactive=1
  
  --SELECT * FROM #ActProd
  
--Create table #tmpSlabBucketMstr(SlabSubBucketType int identity(1,1),SlabSubBucketTypeDesc char(4))   
--insert into #tmpSlabBucketMstr(SlabSubBucketTypeDesc) values('PROD'),('PVOL'),('VALU'),('PDLN'),('PVAL')  
  
--Create table #tmpSubBucketValTypeMstr(SubBucketValType int identity(1,1),SubBucketValTypeDesc char(4))   
--insert into #tmpSubBucketValTypeMstr(SubBucketValTypeDesc) values('IVAL'),('GVAL'),('NVAL')  
if object_id('tempdb..#tmpSlabBucketDetails') is not null
begin
drop table #tmpSlabBucketDetails
end
  
Create table #tmpSlabBucketDetails(RowID int identity(1,1),SchemeID int,SchemeSlabID int,BucketID int,SubBucketID int,SlabSubBucketType tinyint,SlabSubBucketValue varchar(100),SubBucketValType tinyint,SlabSubBucketMin varchar(100),SlabSubBucketMax varchar(100))  
  
insert into #tmpSlabBucketDetails  
select Distinct A.SchemeID,A.SchemeSlabID,A.BucketID,A.SubBucketID,SlabSubBucketType,SlabSubBucketValue,case SlabSubBucketType when 2 then NodeId else 0 end AS ValType,convert(int,convert(numeric(18,2),SlabSubBucketValue)*.8),convert(int,convert(numeric(18,2),SlabSubBucketValue)*.99) from #SlabSplit A   
  
PRINT  'TS'  
select RowID, SchemeID, SchemeSlabID, BucketID,Row_number() over (partition by SchemeSlabID,BucketID order by BucketID,SubBucketID) as SubBucketID,SlabSubBucketType,SlabSubBucketValue, SubBucketValType,SlabSubBucketMin,SlabSubBucketMax into #tmpSlabBucketDetails1  
 from #tmpSlabBucketDetails  
  
 select * from #tmpSlabBucketDetails1  
    PRINT 'A11'
select Distinct B.RowID,D.NodeID AS ProductID,Case when E.SchemeTypeID=3 then 1 else 0 end flgCombine into #SlabProduct from #SlabSplit A   
join #tmpSlabBucketDetails B ON A.SchemeSlabID=B.SchemeSlabID  
AND A.BucketID=B.BucketID AND A.SubBucketID=B.SubBucketID  
cross apply dbo.split(A.ManufacturerId,',') F 
inner join #ActProd D on A.NodeId=D.PNodeId  
and A.NodeType=D.PNodeType  and (f.items=D.Manufacturerid or f.items=0)
inner join tblSchemeMaster E on  E.SchemeId=B.SchemeId
WHERE A.SlabSubBucketType<>'2'  
order by 2,1  
  
  PRINT 'A1'
  
  
  
  
select * from #slabproduct  
order by 1,2  
  
  
--select A.SchemeID,A.SchemeSlabID,SlabType,Value,SlabID,SlabAndID,B.NodeID AS ProductID,'NA' AS ValType from #SlabSplit A left join #ActProd B on A.NodeId=B.PNodeId  
--and A.NodeType=B.PNodeType  
--WHERE SlabSubBucketType<>'Val'  
--union   
--select A.SchemeID,A.SchemeSlabID,SlabType,Value,SlabID,SlabAndID,0 AS ProductID,NodeID AS ValType from #SlabSplit A   
--WHERE SlabSubBucketType='Val'  
--order by 1,2,3  
  
Create table #tmpBenBucketDetails(RowID int identity(1,1),SchemeID int,SchemeSlabID int,BucketID tinyint,SubBucketID tinyint,BenSubBucketType tinyint,BenSubBucketValue varchar(1000),CouponCode varchar(100),Per varchar(20),UOM int,Prorata int,IsDiscountOnTotalAmount int)  
  
insert into #tmpBenBucketDetails(SchemeID,SchemeSlabID,BucketID,SubBucketID,BenSubBucketType,CouponCode,Per,UOM,Prorata,IsDiscountOnTotalAmount)  
select dISTINCT A.SchemeID,A.SchemeSlabID,BucketID,SubBucketID,BenSubBucketType,ISNULL([SchemeCouponCode],''),A.Per,a.uom,case when BenSubBucketType not in(2,6,8) then A.Prorata else 0 end,case when BenSubBucketType in(2,6,8) then A.Prorata else 0 end from #BenSplit A LEFT JOIN   
tblSchemeCouponMaster B ON A.CounponID=b.CouponID  
  
    PRINT 'A2'
  
Create table #tmpBenefitsValueDetail(RowID int, BenValue varchar(10),Remarks varchar(100),Type tinyint)  
  
  
insert into #tmpBenefitsValueDetail(RowID,BenValue,Remarks,Type)  
Select dISTINCT B.RowID,Substring(items,0,CharIndex('$',items)) ,Substring(items,CharIndex('$',items)+1,LEN(items)-CharIndex('$',items)),1  
from #BenSplit A   
join #tmpBenBucketDetails B ON A.SchemeSlabID=B.SchemeSlabID  
AND A.BucketID=B.BucketID AND A.SubBucketID=B.SubBucketID  
Cross apply dbo.Split(a.BenSubBucketValue,'^')  
where items<>''  
  
  
  
insert into #tmpBenefitsValueDetail(RowID,BenValue,Remarks,Type)  
Select dISTINCT B.RowID,Substring(items,0,CharIndex('$',items)) ,Substring(items,CharIndex('$',items)+1,LEN(items)-CharIndex('$',items)),case B.BenSubBucketType when  6   
then 2 when  7 then 3 else  B.BenSubBucketType end  
from #BenSplit A   
join #tmpBenBucketDetails B ON A.SchemeSlabID=B.SchemeSlabID  
AND A.BucketID=B.BucketID AND A.SubBucketID=B.SubBucketID  
Cross apply dbo.Split(a.BenSubBucketDiscValue,'^')  
where items<>''

  PRINT 'A3'
  
  ---(18-Nov-2015) As discussed with A
select A.RowID, SchemeID, SchemeSlabID, BucketID,Row_number() over (partition by SchemeSlabID,BucketID order by BucketID,SubBucketID) as SubBucketID,BenSubBucketType, ISNULL(CouponCode,'')  CouponCode,  
case when isnull(BenValue,'')='' then '0' ELSE BenValue end as BenSubBucketValue ,CASE WHEN BenSubBucketType IN(8,9) THEN 1 ELSE 0 END BenDiscApplied ,case when  BenSubBucketType>9 then dbo.fnGetGramsConversion(A.UOM,A.Per) else 0 end as Per,case when A.UOM IN(11,12,14,13) then 14 else 0 end as UOM,A.ProRata,
A.IsDiscountOnTotalAmount
 from #tmpBenBucketDetails A Left join #tmpBenefitsValueDetail B  
 ON A.RowID=B.RowID  
 AND Remarks='default'  
  
 Delete #tmpBenefitsValueDetail where Remarks='default'  
  
  
select Distinct B.RowID,D.NodeID AS ProductID from #BenSplit A   
join #tmpBenBucketDetails B ON A.SchemeSlabID=B.SchemeSlabID  
AND A.BucketID=B.BucketID AND A.SubBucketID=B.SubBucketID  
cross apply dbo.split(A.ManufacturerId,',') F 
inner join #ActProd D on A.NodeId=D.PNodeId  
and A.NodeType=D.PNodeType  and (f.items=D.Manufacturerid or f.items=0)
--inner join #ActProd D on A.NodeId=D.PNodeId 
 
--and A.NodeType=D.PNodeType  
  
SELECT * FROM #tmpBenefitsValueDetail  
  
    PRINT 'A4'
  
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
  
  SET @String=''
  
 if (object_id('tempdb..#tmpProductRowID')is not null)  
begin  
drop table #tmpProductRowID  
end  
  
select  Productid,STUFF((SELECT ',' + CAST(p1.RowID AS VARCHAR)  
         FROM #SlabProduct p1  
         WHERE A.Productid = p1.Productid  
            FOR XML PATH(''), TYPE  
            ).value('.', 'NVARCHAR(MAX)')   
        ,1,1,'')  as RowIDs,RowID  into #tmpProductRowID  from #SlabProduct A  
  
    PRINT 'A5'
  
 if (object_id('tempdb..#tmpRowIDs')is not null)  
begin  
drop table #tmpRowIDs  
end  
  
select  distinct RowIDs,RowID  into #tmpRowIDs  from #tmpProductRowID A  
  
 if (object_id('tempdb..#product')is not null)  
begin  
drop table #Product  
end  
select Distinct RowIDs,IDENTITY(int,1,1) as ident into #Product from #tmpProductRowID  
  
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
  
  SET @schemeString=''  
    
  Select  @schemeString=CONVERT(VARCHAR,B.SchemeID)+'_'+CONVERT(VARCHAR,SchemeApplicationID)+'_'+CONVERT(VARCHAR,SchemeApplRule)+'_'+CONVERT(VARCHAR,SchemeTypeId) from tblSchemeMaster B  
  JOIN tblSchemeDetail C ON C.SchemeID=B.SchemeID  
  WHERE B.SchemeID=@SchemeId  
  SELECT '4332432',@schemeString
  if @s=1  
    set @String=@schemeString  
    else  
    set @String=@String+'#'+@schemeString  
  
   if (object_id('tempdb..#SchemeSlab')is not null)  
  begin  
  drop table #SchemeSlab  
  end  
  
  --select distinct SchemeSlabID,IDENTITY(int,1,1) as ident into #SchemeSlab from #tmpSlabBucketDetails1 A join #tmpRowIDs B on B.RowID=A.RowID where RowIDs=@RowIDs  
  --and SchemeID=@SchemeId  
  --order by SchemeSlabID desc
  
  select distinct A.SchemeSlabID,IDENTITY(int,1,1) as ident,SlabCost into #SchemeSlab from #tmpSlabBucketDetails1 A join #tmpRowIDs B on B.RowID=A.RowID 
  inner join tblSchemeSlabDetails D on D.SchemeSlabID=A.SchemeSlabID
  where RowIDs=@RowIDs  
  and a.SchemeID=@SchemeId  
  order by SlabCost desc

    set @sl=1   
    select @slcnt=count(*) from  #SchemeSlab  
    while @sl<=@slcnt  
    begin  
  
    
  
    select @SlbID=SchemeSlabID from #SchemeSlab where ident=@sl  
  
    print '@SlbID'  
    print @SlbID  
  
    if @sl=1  
    set @String=@String+'!'+convert(varchar,@SlbID)+'$'  
    else  
    set @String=@String+'@'+convert(varchar,@SlbID)+'$'  
  
      
      if (object_id('tempdb..#Bucket')is not null)  
     begin  
     drop table #Bucket  
     end  
  
    select  BucketID, count(*) as BucketCnt,IDENTITY(int,1,1) as ident into #Bucket from #tmpSlabBucketDetails1 A 
	--join #tmpRowIDs B on B.RowID=A.RowID 
	where 
	--RowIDs=@RowIDs  
    --and 
	SchemeID=@SchemeId and SchemeSlabID=@SlbID  
    group by BucketID  
	order by BucketID desc
    SELECT 'FFFF3SDFADSF',@String
 SELECT 'Z',* FROM #Bucket 
    set @b=1  
    select @bcnt=count(*) from #Bucket  
    set @BuckString=''  
    while @b<=@bcnt  
    begin  
      
      
  
     set @BuckString=''  
      select @BuckString=CONVERT(VARCHAR,BucketID)+'^'+CONVERT(VARCHAR,BucketCnt),@BucketId=BucketID from #Bucket where ident=@b  
	
	
  
      print '@BucketId'  
	  print @RowIDs
    print @BucketId
      set @SubBuckString=''  
	  --+'^'+Convert(varchar,C.flgCombine)
    select  @SubBuckString=@SubBuckString+Convert(varchar,A.SubBucketID)+'^'+Convert(varchar,A.RowId)+'^'+Convert(varchar,A.SlabSubBucketType)+'^'+Convert(varchar,A.SlabSubBucketValue)+'^'+Convert(varchar,A.SubBucketValType)+'*' from #tmpSlabBucketDetails1 A 
	--join #tmpRowIDs B on B.RowID=A.RowID
	--join (select distinct rowid,flgCombine from  #slabproduct ) AS C ON C.Rowid=A.Rowid  
	
	where 
	--RowIDs=@RowIDs  
    --and 
	SchemeID=@SchemeId and SchemeSlabID=@SlbID  
    and BucketID=@BucketId  
	SELECT @SubBuckString,@BuckString
       set @String=@String+@BuckString+'|'+left(@SubBuckString,len(@SubBuckString)-1) +(case when @b=@bcnt then '' else  '~' end)
       print @String  
     set @b=@b+1  
    end  
      SELECT 'FFFF',@String
     print 'bucket end'  
       
       
     
    set @sl=@sl+1  
    end  
  
     
  set @s=@s+1  
  end  
  PRINT '@RowIDs'
  PRINT @RowIDs
  PRINT @String
  insert into #productMap   
  select distinct productid,@String from #tmpProductRowID where RowIDs=@RowIDs  
  set @String=''  
  
set @i=@i+1  
end  
  SELECT '1',* FROM #tmpProductRowID
select * from #productMap where PrdString<>'' order by 1  
  



   
  
set @i=1  
select @cnt=count(*) from  #Product  
while @i<=@cnt  
begin  
  
select @RowIDs=RowIDs from #Product where ident=@i  
  
  
   if (object_id('tempdb..#Scheme1')is not null)  
  begin  
  drop table #Scheme1  
  end  

  Create table #Scheme1(ident int IDENTITY(1,1) ,SchemeID int,SchemeSlabCost numeric(18,2))
  
  insert into #Scheme1(SchemeID,SchemeSlabCost)
  select A.SchemeId,max(a.SlabCost) from tblSchemeSlabDetails A inner join
 ( select distinct SchemeID from #tmpSlabBucketDetails1 A join #tmpRowIDs B on B.RowID=A.RowID where RowIDs=@RowIDs  ) as B ON a.SchemeID=b.SchemeID
 Inner join tblSchemeMaster as C on C.SchemeId=b.schemeid where c.SchemeType2ID=2
 group by a.SchemeID
order by  2 desc
  print 'ProductID'  
  print @ProductID  
  set @s=1   
  select @scnt=count(*) from  #Scheme1  
  while @s<=@scnt  
  begin  
  
    
  select @SchemeId=SchemeID from #Scheme1 where ident=@s  
  print '@SchemeId'  
  print @SchemeId  
  
  SET @schemeString=''  
    
  Select  @schemeString=CONVERT(VARCHAR,B.SchemeID)+'_'+CONVERT(VARCHAR,SchemeApplicationID)+'_'+CONVERT(VARCHAR,SchemeApplRule)+'_'+CONVERT(VARCHAR,SchemeTypeId) from tblSchemeMaster B  
  JOIN tblSchemeDetail C ON C.SchemeID=B.SchemeID  
  WHERE B.SchemeID=@SchemeId  
  
  if @s=1  
    set @String=@schemeString  
    else  
    set @String=@String+'#'+@schemeString  
  
   if (object_id('tempdb..#SchemeSlab1')is not null)  
  begin  
  drop table #SchemeSlab1  
  end  
  
  select distinct A.SchemeSlabID,IDENTITY(int,1,1) as ident,SlabBenCost into #SchemeSlab1 from #tmpSlabBucketDetails1 A join #tmpRowIDs B on B.RowID=A.RowID 
  inner join tblSchemeSlabDetails D on D.SchemeSlabID=A.SchemeSlabID
  where RowIDs=@RowIDs  
  and a.SchemeID=@SchemeId  
  order by SlabBenCost desc
  
    set @sl=1   
    select @slcnt=count(*) from  #SchemeSlab1  
    while @sl<=@slcnt  
    begin  
  
    
  
    select @SlbID=SchemeSlabID from #SchemeSlab1 where ident=@sl  
  
    print '@SlbID'  
    print @SlbID  
  
    if @sl=1  
    set @String=@String+'!'+convert(varchar,@SlbID)+'$'  
    else  
    set @String=@String+'@'+convert(varchar,@SlbID)+'$'  
  
      
     
      if (object_id('tempdb..#Bucket1')is not null)  
     begin  
     drop table #Bucket1  
     end  
  
    select distinct BucketID, count(*) as BucketCnt,IDENTITY(int,1,1) as ident into #Bucket1 from #tmpSlabBucketDetails1 A 
	
	--join #tmpRowIDs B on B.RowID=A.RowID 
	where 
	--RowIDs=@RowIDs  
    --and 
	SchemeID=@SchemeId and SchemeSlabID=@SlbID  
    group by BucketID  
	order by BucketID desc
  
  
    set @b=1  
    select @bcnt=count(*) from #Bucket1  
    set @BuckString=''  
    while @b<=@bcnt  
    begin  
      
      
  
     set @BuckString=''  
      select @BuckString=CONVERT(VARCHAR,BucketID)+'^'+CONVERT(VARCHAR,BucketCnt),@BucketId=BucketID from #Bucket1 where ident=@b  
	  
  
      print '@BucketId'  
	  print @RowIDs
    print @BucketId
      set @SubBuckString=''  
	  --+'^'+Convert(varchar,C.flgCombine)
    select  @SubBuckString=@SubBuckString+Convert(varchar,A.SubBucketID)+'^'+Convert(varchar,A.RowId)+'^'+Convert(varchar,A.SlabSubBucketType)+'^'+Convert(varchar,A.SlabSubBucketValue)+'^'+Convert(varchar,A.SubBucketValType)+'*' from 
	
	#tmpSlabBucketDetails1 AS A 
	--join (select distinct rowid,flgCombine from  #slabproduct ) AS C ON C.Rowid=A.Rowid 
	 where 
	--RowIDs=@RowIDs  
    --and 
	SchemeID=@SchemeId and SchemeSlabID=@SlbID  
    and BucketID=@BucketId  
       set @String=@String+@BuckString+'|'+left(@SubBuckString,len(@SubBuckString)-1) +(case when @b=@bcnt then '' else  '~' end)
       print @String  
     set @b=@b+1  
    end  
      
     print 'bucket end'  
       
    set @sl=@sl+1  
    end  
  
     
  set @s=@s+1  
  end  
  
  insert into #productMap1   
  select distinct productid,@String from #tmpProductRowID where RowIDs=@RowIDs  and @String<>''
  set @String=''  
  
set @i=@i+1  
end  
  
select * from #productMap1 order by 1  



select Distinct B.RowID,D.NodeID AS ProductID,B.SchemeID, B.SchemeSlabID ,B.SlabSubBucketType,B.SlabSubBucketMin,B.SlabSubBucketMax from #SlabSplit A   
join #tmpSlabBucketDetails B ON A.SchemeSlabID=B.SchemeSlabID  
AND A.BucketID=B.BucketID AND A.SubBucketID=B.SubBucketID  
cross apply dbo.split(A.ManufacturerId,',') F 
inner join #ActProd D on A.NodeId=D.PNodeId  
and A.NodeType=D.PNodeType  and (f.items=D.Manufacturerid or f.items=0)
inner join tblSchemeMaster E on  E.SchemeId=B.SchemeId
WHERE A.SlabSubBucketType<>'2'  and E.SchemeTypeID=3 
order by 2,1  
  

  
  set @String=''

   if (object_id('tempdb..#Scheme2')is not null)  
  begin  
  drop table #Scheme2  
  end  

  Create table #Scheme2(ident int IDENTITY(1,1) ,SchemeID int,SchemeSlabCost numeric(18,2))
  
  insert into #Scheme2(SchemeID,SchemeSlabCost)
  select A.SchemeId,max(a.SlabCost) from tblSchemeSlabDetails A inner join
 ( select distinct SchemeID from #tmpSlabBucketDetails1 A left join #SlabProduct B on B.RowID=A.RowID where b.rowid is null ) as B ON a.SchemeID=b.SchemeID
 Inner join tblSchemeMaster as C on C.SchemeId=b.schemeid where c.SchemeType2ID=1
 group by a.SchemeID
order by  2 desc
  set @s=1   
  select @scnt=count(*) from  #Scheme2  
  while @s<=@scnt  
  begin  
  
    
  select @SchemeId=SchemeID from #Scheme2 where ident=@s  
  print '@SchemeId'  
  print @SchemeId  
  
  SET @schemeString=''  
    
  Select  @schemeString=CONVERT(VARCHAR,B.SchemeID) from tblSchemeMaster B  
  JOIN tblSchemeDetail C ON C.SchemeID=B.SchemeID  
  WHERE B.SchemeID=@SchemeId  
  
  if @s=1  
    set @String=@schemeString  
    else  
    set @String=@String+'#'+@schemeString  
  
   if (object_id('tempdb..#SchemeSlab2')is not null)  
  begin  
  drop table #SchemeSlab2 
  end  
  
  select distinct A.SchemeSlabID,IDENTITY(int,1,1) as ident,SlabBenCost into #SchemeSlab2 from #tmpSlabBucketDetails1 A 
  left join #SlabProduct B on B.RowID=A.RowID 
  inner join tblSchemeSlabDetails D on D.SchemeSlabID=A.SchemeSlabID
  where b.rowid is null
  and a.SchemeID=@SchemeId  
  order by SlabBenCost desc
  
    set @sl=1   
    select @slcnt=count(*) from  #SchemeSlab2  
    while @sl<=@slcnt  
    begin  
  
    
  
    select @SlbID=SchemeSlabID from #SchemeSlab2 where ident=@sl  
  
    print '@SlbID'  
    print @SlbID  
  
    if @sl=1  
    set @String=@String+'~'+convert(varchar,@SlbID)--+'$'  
    else  
    set @String=@String+'!'+convert(varchar,@SlbID)---+'$'  
  
      
	     if (object_id('tempdb..#Bucket2')is not null)  
     begin  
     drop table #Bucket2  
     end  
  
    select distinct A.BucketID, count(*) as BucketCnt,IDENTITY(int,1,1) as ident into #Bucket2 from #tmpSlabBucketDetails1 A left join #SlabProduct B on B.RowID=A.RowID 
	
	 where b.rowid is null
    and A.SchemeID=@SchemeId and A.SchemeSlabID=@SlbID  
    group by A.BucketID  
	order by A.BucketID desc
  
  
    set @b=1  
    select @bcnt=count(*) from #Bucket2  
    set @BuckString=''  
    while @b<=@bcnt  
    begin  
      
    
  
     set @BuckString=''  
      select @BuckString=CONVERT(VARCHAR,BucketID),@BucketId=BucketID from #Bucket2 where ident=@b  
	    --if @b=1  
    set @String=@String+'$'+convert(varchar,@BucketId)  
    --else  
    --set @String=@String+'^'+convert(varchar,@BucketId)
  
      print '@BucketId'  
	  print @RowIDs
    print @BucketId
      set @SubBuckString=''  
	  --+'^'+Convert(varchar,C.flgCombine)
    select  @SubBuckString=@SubBuckString+'*'+Convert(varchar,A.SubBucketID) from #tmpSlabBucketDetails1 A 
	--join (select distinct rowid,flgCombine from  #slabproduct ) AS C ON C.Rowid=A.Rowid  where RowIDs=@RowIDs  
    where SchemeID=@SchemeId and SchemeSlabID=@SlbID  
    and BucketID=@BucketId  

	print '@SubBuckString'
	print @SubBuckString
       set @String=@String+@SubBuckString 
       print @String  
     set @b=@b+1  
    end  
      
     
    set @sl=@sl+1  
    end  
  
     
  set @s=@s+1  
  end  
  
  select @String AS InvString
  --set @String=''  
  

end  
--select * from tblRouteCoverageStoreMapping w







