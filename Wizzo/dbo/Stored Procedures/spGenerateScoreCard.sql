
--select * from mrco_ExtractMaster
--spGenerateScoreCard '10-Mar-2021'
CREATE proc [dbo].[spGenerateScoreCard] 
@currdate date
as
begin
Declare @SalesFileSetId bigint,@RetFileSetId bigint,@PrdFileSetId bigint
,@SalHierFileSetId bigint,@TgtFileSetId bigint,@PrcFileSetId bigint,@PrdCnvFileSetId bigint,@11FileId bigint,@8FileId bigint
,@10FileId bigint,@13FileId bigint,@15FileId bigint,@25FileId bigint--,@PlndFileSetId bigint


--select @PlndFileSetId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=25


select @SalesFileSetId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=19

select @RetFileSetId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=22
select @PrdFileSetId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=18

select @SalHierFileSetId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=23

select @TgtFileSetId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=3

select @PrcFileSetId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=9

select @PrdCnvFileSetId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=12

select @11FileId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=11
select @8FileId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=8
select @10FileId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=10

select @13FileId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=13

select @15FileId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=15

select @25FileId=isnull(max(CycFileID),0) from tblExtractCycDet where date=@currdate and DataRowsCopied<>0 and FileID=25




--select count(distinct sale_inv_no) as [# of Invoices],count(distinct CASE WHEN StatusId=5 THEN sale_inv_no end)  from mrco_TEMP_BillwiseITEMWISE_Astic where StatusId  in(1,3,5)
--select count(distinct RtrCode) as [# of Retailers] from mrco_RetailerMaster_Astic
--select count(distinct CmpRtrCode) as [# of Retailers Billed],count(distinct CASE WHEN StatusId=5 THEN CmpRtrCode end) as [# of Retailers Billed] from mrco_TEMP_BillwiseITEMWISE_Astic where StatusId not in(4,2,6,7)

IF OBJECT_ID('tempdb..#TmpScoreCardSummary') is not null
begin
drop table #TmpScoreCardSummary
end

Create table #TmpScoreCardSummary(Id int identity(1,1),ParentId int,IsValue tinyint not null default(0),LblTxt varchar(200),[Total^Total] varchar(50),[Total^Delivered] varchar(50),[Against TES^Total] varchar(50),[Against TES^Delivered] varchar(50),SheetName varchar(100))



insert into #TmpScoreCardSummary(ParentId,IsValue,LblTxt ,[Total^Total] ,[Total^Delivered] )
select 1,1,'Total Sales',Convert(numeric(18,2),sum(net_value)) as [Total Sales Value],convert(numeric(18,2),SUM(CASE WHEN StatusId=5 THEN net_value end)) from mrco_TEMP_BillwiseITEMWISE_Astic
where CycFileID= @SalesFileSetId

IF OBJECT_ID('tempdb..#mrco_TEMP_BillwiseITEMWISE_Astic') is not null
begin
drop table #mrco_TEMP_BillwiseITEMWISE_Astic
end


select * into #mrco_TEMP_BillwiseITEMWISE_Astic from mrco_TEMP_BillwiseITEMWISE_Astic where teleorderno<>'' and CycFileID=@SalesFileSetId

IF OBJECT_ID('tempdb..#OrderNo') is not null
begin
drop table #OrderNo
end
select OrderCode into #OrderNo from vwOrderMaster(nolock) where OrderDate<@currdate
union 
select convert(varchar,OrderID) from vwOrderMaster(nolock) where OrderDate<@currdate

print 'ttt'

IF OBJECT_ID('tempdb..#AgstTes') is not null
begin
drop table #AgstTes
end
select Convert(numeric(18,2),sum(net_value)) as [Total Sales Value],convert(numeric(18,2),SUM(CASE WHEN StatusId=5 THEN net_value end)) as DlvrdSalesVal

into #AgstTes

from #mrco_TEMP_BillwiseITEMWISE_Astic a join #OrderNo b on a.teleorderno=b.OrderCode 



print 'fds'
IF OBJECT_ID('tempdb..#AgstTes1') is not null
begin
drop table #AgstTes1
end
select 
count(distinct sale_inv_no ) as [TotInvNo],count (distinct CASE WHEN StatusId=5 THEN sale_inv_no end) as DlvrdInvNo,
count(distinct CmpRtrCode ) as [TotNoOfStore],count (distinct CASE WHEN StatusId=5 THEN CmpRtrCode end) as DlvrdNoOfStore

into #AgstTes1

from #mrco_TEMP_BillwiseITEMWISE_Astic a join #OrderNo b on a.teleorderno=b.OrderCode --or a.teleorderno=convert(varchar,b.OrderID)
where  statusid in(1,3,5)



update z set [Against TES^Total]=a.[Total Sales Value],[Against TES^Delivered]=a.DlvrdSalesVal from #TmpScoreCardSummary z cross join
#AgstTes as a 
where z.Id=1



insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total] ,[Total^Delivered] )
select 1,'# of Invoices',count(distinct sale_inv_no) ,count (distinct CASE WHEN StatusId=5 THEN sale_inv_no end) from mrco_TEMP_BillwiseITEMWISE_Astic
where CycFileID= @SalesFileSetId and StatusId  in(1,3,5)

print 'zzzz'

update z set [Against TES^Total]=a.[TotInvNo],[Against TES^Delivered]=a.DlvrdInvNo from #TmpScoreCardSummary z cross join
#AgstTes1 as a 
where z.Id=2


insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total] ,[Total^Delivered] )
select 1,'# of Retailers Billed',count(distinct CmpRtrCode) ,count (distinct CASE WHEN StatusId=5 THEN CmpRtrCode end) from mrco_TEMP_BillwiseITEMWISE_Astic
where CycFileID= @SalesFileSetId and StatusId  in(1,3,5)

print 'zzzz'

update z set [Against TES^Total]=a.[TotNoOfStore],[Against TES^Delivered]=a.DlvrdNoOfStore from #TmpScoreCardSummary z cross join
#AgstTes1 as a 
where z.Id=3


if object_id('tempdb..#StoreId') is not null
begin
drop table #StoreId
end

select Storeid,DistNodeId into #StoreId  from tblTeleCallerListForDay where Date=@currdate

insert into #TmpScoreCardSummary(ParentId,IsValue,LblTxt ,[Total^Total],[Against TES^Total]  )
select 2,1,'Total Target Value for the Day',convert(numeric(18,2),sum(TargetValue)) ,convert(numeric(18,2),sum(case when b.storeid is not null then TargetValue else 0 end)) from tblRetailerSKUKWiseTarget a left join #StoreId b on a.StoreId=b.StoreId 
where MonthVal=month(@currdate) and YearVal=year(@currdate)
 

insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],[Against TES^Total]  )
select 2,'# of Retailers With Targets',count(distinct a.StoreId) ,count(distinct b.storeid ) from tblRetailerSKUKWiseTarget a left join #StoreId b on a.StoreId=b.StoreId 
where MonthVal=month(@currdate) and YearVal=year(@currdate)


insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],[Against TES^Total]  )
select 3,'# of DBRs with Closing Stock',count(distinct a.DistNodeId) ,count(distinct b.DistNodeId ) from tblPrdActivePrdList a left join #StoreId b on a.DistNodeId=b.DistNodeId 


insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],[Against TES^Total]  )
select 3,'# of DBRS with No Closing Stock',count(distinct b.DistNodeId) ,count(distinct b.DistNodeId ) from tblPrdActivePrdList a right join #StoreId b on a.DistNodeId=b.DistNodeId 
where a.DistNodeId is null


insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],[Against TES^Total]  )
select 3,'# of On Route Retailers With No Products in Stock',count(distinct b.StoreId) ,count(distinct b.StoreId ) from tblPrdActivePrdList a right join #StoreId b on a.DistNodeId=b.DistNodeId 
where a.DistNodeId is null

if object_id('tempdb..#Dist') is not null
begin
	drop table #Dist
end
select distinct DistNodeId,PrdNodeId into #Dist from tblP3MSalesDetail 


if object_id('tempdb..#DistTes') is not null
begin
	drop table #DistTes
end
select distinct DistNodeId,PrdNodeId into #DistTes from tblP3MSalesDetail where exists (select * from tblTeleCallerListForDay
where tblTeleCallerListForDay.StoreId= tblP3MSalesDetail.StoreId
and tblTeleCallerListForDay.Date=@currdate)

insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total] ,[Against TES^Total] )
select 3,'Key Replenishment Opportunities',count(*) ,(select count(*) from #DistTes) from  #Dist b 
Declare @TesCnt int

select @TesCnt =count(*) from
tblPrdActivePrdList a right join #DistTes b on a.DistNodeId=b.DistNodeId and a.PrdNodeId=b.PrdNodeId
where a.DistNodeId is null


insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total] ,[Against TES^Total] )
select 3,'Key Replenishment Opportunity Loss',count(*),@TesCnt  from tblPrdActivePrdList a right join #Dist b on a.DistNodeId=b.DistNodeId and a.PrdNodeId=b.PrdNodeId
where a.DistNodeId is null



insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total]  )
select 4,'# of Retailers',count(distinct RtrCode)  from mrco_RetailerMaster_Astic
where CycFileID= @RetFileSetId 



insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total]  )
select 4,'# of Retailers on Route',count(distinct StoreId)  from tblRouteCalendar
where FileSetId= @RetFileSetId 


insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],[Against TES^Total]  )
select 4,'# of Retailers TC - Planned Calls',count(distinct ChildRtrCode),(SELECT COUNT(*) FROM tblTeleCallerListForDay 
WHERE RuleId=3 AND Date=@currdate AND IsUsed<5)  from mrco_Console2Minet_TCOutletSchedule_Astic
where CycFileID= @25FileId and convert(date,Calldate)=@currdate


insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Against TES^Total]  )
select 4,'# of Retailers TC - Other Calls',count(*)  from tblTeleCallerListForDay
WHERE RuleId<3 AND Date=@currdate


insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],SheetName  )
select 5,'# Of Product Rejected',count(distinct ProductCode),'Rjctd Product'  from mrco_ProductDetails_PT_Astic_Error a 
where FileSetId=@PrdFileSetId
print 'tt'

insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total] ,SheetName )
select 5,'# Of Distributor Rejected',count(distinct DISTRIBUTOR_CODE),'Rjctd Distributor'  from mrco_MI_Sales_User_Relationship_Error a 
where FileSetId=@SalHierFileSetId

insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],SheetName  )
select 5,'# Of Retailers and Route Data Rejected',count(distinct RtrCode),'Rjctd Retailer'  from mrco_RetailerMaster_Astic_Error a 
where FileSetId=@RetFileSetId

insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total] ,SheetName )
select 5,'# Of Target Data Rejected',count(1),'Rjctd Tgt'  from mrco_Tbl_RetailerwiseTargetClient_Newlogic_Error a 
where FileSetId=@TgtFileSetId


insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],SheetName  )
select 5,'# Of Product Price Data Rejected',count(1) ,'Rjctd Prd Price' from mrco_NRC_SCHEME_BATCHMASTER_Urban_Error a 
where FileSetId=@PrcFileSetId

insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total] ,SheetName )
select 5,'# Of Product Conversion Data Rejected',count(1),'Rjctd Prd Cnvrs'  from mrco_NRC_SCHEME_PRODUCTMASTER_Urban_Error a 
where CycFileID=@PrdCnvFileSetId

insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total] ,SheetName )
select 5,'# Of Schemes Rejected',count(distinct CMPSCHCODE),'Rjctd Schms Hdr'  from mrco_NRC_SCHEME_HEADER_Urban_Error a 
where FileSetId=@11FileId

insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],SheetName  )
select 5,'# Of Schemes Attribute Rejected',count(distinct CMPSCHCODE),'Rjctd Schms Attr'  from mrco_NRC_SCHEME_Attribute_Urban_Error a 
where FileSetId=@8FileId

--insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],SheetName  )
--select 5,'# Of Schemes Attribute Rejected',count(distinct CMPSCHCODE),'Rjctd Schms Attr'  from mrco_NRC_SCHEME_Attribute_Urban_Error a 
--where FileSetId=@8FileId

--insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],SheetName  )
--select 5,'# Of Schemes Attribute Rejected',count(distinct CMPSCHCODE),'Rjctd Schms Attr'  from mrco_NRC_SCHEME_Attribute_Urban_Error a 
--where FileSetId=@8FileId

--insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total]  )
--select 4,'# Of Schemes Exclusion Data Rejected',count(distinct CMPSCHCODE)  from mrco_NRC_SCHEME_EXCLUSION_Error a 
--where FileSetId=@10FileId



insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],SheetName  )
select 5,'# Of Schemes Slab Data Rejected',count(distinct CMPSCHCODE),'Rjctd Schms Slab'  from mrco_NRC_SCHEME_SLABS_Urban_Error a 
where FileSetId=@15FileId

insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],SheetName  )
select 5,'# Of Invoice Data Rejected',count(distinct sale_inv_no),'Rjctd Inv Data'  from mrco_TEMP_BillwiseITEMWISE_Astic_Error a 
where FileSetId=@SalesFileSetId

set @TesCnt=0
select @TesCnt=count(distinct a.StoreId) from tblSalesMaster a join tblSalesStatusLog b on a.InvId=b.InvId
INNER JOIN tblTeleCallerListForDay tc on tc.StoreId=a.StoreId
where b.StatusId=5 and convert(date,b.TimeStampIns) between DATEADD(dd,-1,@currdate) and @currdate
and tc.Date=@currdate


insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total],[Against TES^Total]  )
select 5,'# of Retailers with delivery in P2D',count(distinct a.StoreId),@TesCnt from tblSalesMaster a join tblSalesStatusLog b on a.InvId=b.InvId
where b.StatusId=5 and convert(date,b.TimeStampIns) between DATEADD(dd,-1,@currdate) and @currdate


select @TesCnt=count(distinct sale_inv_no) from mrco_TEMP_BillwiseITEMWISE_Astic a  INNER JOIN tblTeleCallerListForDay tc on tc.StoreId=a.StoreId
where CycFileID=@SalesFileSetId and a.StatusId in(1,3)
and tc.Date=@currdate

insert into #TmpScoreCardSummary(ParentId,LblTxt ,[Total^Total] ,[Against TES^Total] )
select 5,'# of Retailers with Pending delivery',count(distinct sale_inv_no),@TesCnt  from mrco_TEMP_BillwiseITEMWISE_Astic a 
where CycFileID=@SalesFileSetId and a.StatusId in(1,3)


Select 1 as ParentId,'Total Sales Received' as Txt
union all
Select 2 as ParentId,'Targets Received For Day' as Txt
union all
Select 3 as ParentId,'Closing Stock' as Txt
union all
Select 4 as ParentId,'Calling For the Day' as Txt
union all
Select 5 as ParentId,'Exception Data' as Txt
select * from #TmpScoreCardSummary

select Id,SheetName from #TmpScoreCardSummary where SheetName is not null order by 1

select [CountryId],[CountryCode],[CountryName],[Country-DivisionCode],[DivisionId]
,[DivisionCode],[DivisionName],[Division-CategoryCode],[CategoryId],[CategoryCode],[CategoryName],[Category-BrandCode],[BrandId]
,[BrandCode],[BrandName],[Brand-SubBrandCode],[SubBrandId],[SubBrandCode],[SubBrandName],[SubBrand-SKU_Code],[SKU_Id],[SKU_Code]
,[SKU_Name],[SKU_-ProductCode],[ProductId],[ProductCode],[ProductName],b.ErrorDescr  from mrco_ProductDetails_PT_Astic_Error a join tblMstrError b on a.ErrorId=b.ErrorId
where FileSetId=@PrdFileSetId


select [ID],[Region],[CEO_CODE],[GSM_CODE],[RSM_CODE],[RSH_CODE],[ASM_CODE],[TSO_TSE_CODE],[DISTRIBUTOR_CODE]
,[MIDAS_Non_MIDAS],[Distributor_Flag],[CEO_Name],[GSM_Name],[RSM_Name],[RSH_Name],[ASM_Name],[ASM_AREA],[TSO_TSE_Name],[TSO_TSE_HQ]
,[DISTRIBUTOR_NAME],[DISTRIBUTOR_STATE_Code],[DISTRIBUTOR_STATE_Name],[DISTRIBUTOR_CITY],[ISR_Code],[ISR_Name]
,[HQ_code],b.ErrorDescr from [mrco_MI_Sales_User_Relationship_Error] a join tblMstrError b on a.ErrorId=b.ErrorId
where FileSetId=@SalHierFileSetId

SELECT [ASMArea],[DistCode],[DistributorName],[RtrCode],[Registered],[ParentCompRtrCode],[RtrName],[ParentRtrName],[RelationStatus]
,[RtrAddress1],[RtrAddress2],[RtrAddress3],[RtrPhoneNo],[RtrType],[SMCode],[SMName],[Positioncode],[RMCode],[RMName],[LineofTradeCode]
,[ChannelCode],[ChannelName],[SubChannelCode],[SubChannelName],[programName],[RetailerStatus],[RetailerFrequency],[RetailerSequence]
,[RelatedParty],[StateName],[RtrPinCode],[CityCode],[RouteGTMType],[CallDays],[Mobileno1],[Mobileno2],[Lattitude],[Longitude]
,[Createddate],[CSRtrCode],b.ErrorDescr
from [mrco_RetailerMaster_Astic_Error]  a join tblMstrError b on a.ErrorId=b.ErrorId
where FileSetId=@RetFileSetId



SELECT [DistributorCode],[DistributorName],[TargetMonth],[TargetYear],[DSRID],[DSRName],[BeatID],[BeatName]
,[RetailerCode],[RetailerName],[CMPRetailerCode],[ChannelCode],[ChannelName],[BrandName],[TargetVolume],[TargetBPM],[ParentSKUcode]
,[CompParentretailerCode],[CSParentretailercode],[RouteGTMType],[IndexBPM],b.ErrorDescr
from [mrco_Tbl_RetailerwiseTargetClient_Newlogic_Error]  a join tblMstrError b on a.ErrorId=b.ErrorId
where FileSetId=@TgtFileSetId


select [DISTCODE],[SKUCODE],[PRODUCTCODE],[MRP],[SELLINGRATEAFTERVAT],[PrimaryDisc],[CREATEDDATE],b.ErrorDescr from [mrco_NRC_SCHEME_BATCHMASTER_Urban_Error] a join tblMstrError b on a.ErrorId=b.ErrorId
where FileSetId=@PrcFileSetId

select [DistCode],[BRANDCODE],[BRANDNAME],[SKUCODE],[PRODUCTCODE],[PRODUCTUNIT],[PRODUCTUOM],[PRODUCTWEIGHT],[CaseUomid],[CREATEDDATE]
,b.ErrorDescr from mrco_NRC_SCHEME_PRODUCTMASTER_Urban_Error a join tblMstrError b on a.ErrorId=b.ErrorId
where a.CycFileID=@PrcFileSetId

select [DISTCODE],[RTRCODE],[CMPSCHCODE],[SCHLEVEL],[SCHTYPE],[ISRANGE],[PurOfEvery],[ProRata],[BUDGETAMT],[MRPLevel]
,[ClaimGroupCode],[CREATEDDATE],[SchemeRemarks]
,b.ErrorDescr from [mrco_NRC_SCHEME_HEADER_Urban_Error] a join tblMstrError b on a.ErrorId=b.ErrorId
where a.FileSetId=@11FileId


select [DISTCODE],[CMPSCHCODE],[AttrType],[AttrName],[CREATEDDATE]
,b.ErrorDescr from [mrco_NRC_SCHEME_Attribute_Urban_Error] a join tblMstrError b on a.ErrorId=b.ErrorId
where a.FileSetId=@8FileId

select [DISTCODE],[CMPSCHCODE],[SLABID],[FROMQTY],[TOQTY],[FOREVERYQTY],[FROMUOMID],[TOUOMID],[FOREVERYUOMID]
,[DISCPERC],[FLATAMT],[SchType],[CREATEDDATE] ,b.ErrorDescr from [mrco_NRC_SCHEME_SLABS_Urban_Error] a join tblMstrError b on a.ErrorId=b.ErrorId
where a.FileSetId=@15FileId

select t_date, dist_code, dsr_id, dsr_name, beat_id, beat_name, channel, channel_sub, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, parent_retailer_code, retailer_id, retailer_code, 
                         retailer_name, item_comp_code, item_code, batch_no, sale_inv_no, sale_inv_date, sal_inv_doc, qty, rate, sales_volume, sales_value, primary_scheme, secondary_scheme, spl_disc, dist_disc, disp_disc, addi_lnd, sal_ret, 
                         tax1, tax2, total_tax, total_dedn, net_value, upload_flag, teleorderno, upload_time, mrp, retailermargin, lastmoddate, bill_status, company_code, salesqty, offerqty, t_sales_volume, freevolume, primaryamt, 
                         primaryschemevolume, secondaryschemevolume, p3discount, cashdiscount, salesextax, last_src_update_date, CmpRtrCode, ParentCmpRtrCode, RouteGTMType, NormalSecSchemeAmt, AddSecSchemeAmt,b.ErrorDescr
					from	 mrco_TEMP_BillwiseITEMWISE_Astic_Error a join tblMstrError b on a.ErrorId=b.ErrorId
where a.FileSetId=@SalesFileSetId

end
