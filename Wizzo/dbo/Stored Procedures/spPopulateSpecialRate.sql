

--select * 
--[spPopulateSpecialRate] 0
CREATE proc [dbo].[spPopulateSpecialRate]
@CycFileId bigint
as
begin
Declare @currdate datetime=dbo.fnGetCurrentDateTime()
select [Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,0 as StoreId,0 as PrdNodeId,0 as PrdNodeType,0 as DbNodeId,0 as DbNodeType,0 as PcsInBox into #tmpRawDataSpecialRate from tmpRawDataSpecialRate where FileSetId=@CycFileId
--where [ACTIVE STATUS]='Active' and [APPROVED STATUS]='Approved' and convert(date,getdate()) between convert(date,[From Date],103) and convert(date,[To Date],103)

insert into tmpRawDataSpecialRate_Error([Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,ErrorId,TimeStampIns)
select [Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,1,@currdate from #tmpRawDataSpecialRate

where not ([ACTIVE STATUS]='Active' and [APPROVED STATUS]='Approved')

delete #tmpRawDataSpecialRate where not ([ACTIVE STATUS]='Active' and [APPROVED STATUS]='Approved')


insert into tmpRawDataSpecialRate_Error([Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,ErrorId,TimeStampIns)
select [Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,2,@currdate from #tmpRawDataSpecialRate

where not (convert(date,getdate()) between convert(date,[From Date],103) and convert(date,[To Date],103))

delete #tmpRawDataSpecialRate where not (convert(date,getdate()) between convert(date,[From Date],103) and convert(date,[To Date],103))


Update a set  DbNodeId=b.NodeId,DbNodeType=b.nodetype from #tmpRawDataSpecialRate a join tblDbrSalesStructureDBR b on a.[Distributor Code]=b.DistributorCode

insert into tmpRawDataSpecialRate_Error([Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,ErrorId,TimeStampIns)
select [Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,3,@currdate from #tmpRawDataSpecialRate a where dbnodeid=0


delete a from #tmpRawDataSpecialRate a where dbnodeid=0



Update a set  StoreId=b.StoreId from #tmpRawDataSpecialRate a join tblSToreMaster b on a.[Retailer Code]=b.StoreCode

insert into tmpRawDataSpecialRate_Error([Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,ErrorId,TimeStampIns)
select [Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,4,@currdate from #tmpRawDataSpecialRate a where StoreId=0


delete a from #tmpRawDataSpecialRate a  where StoreId=0



Update a set  PrdNodeId=b.nodeid,PrdNodeType=b.nodetype,PcsInBox=b.PcsInBox from #tmpRawDataSpecialRate a join tblPrdMstrHierLvl2 b on a.[PACK TYPE]=b.[Descr]

insert into tmpRawDataSpecialRate_Error([Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,ErrorId,TimeStampIns)
select [Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,5,@currdate from #tmpRawDataSpecialRate a where PrdNodeId=0


delete a from #tmpRawDataSpecialRate a  where PrdNodeId=0



insert into tmpRawDataSpecialRate_Error([Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,ErrorId,TimeStampIns)
select [Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,6,@currdate from #tmpRawDataSpecialRate a where isnumeric([SPECIAL SALES RATE])<>1


delete a from #tmpRawDataSpecialRate a  where isnumeric([SPECIAL SALES RATE])<>1


insert into tmpRawDataSpecialRate_Error([Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,ErrorId,TimeStampIns)
select [Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,7,@currdate from #tmpRawDataSpecialRate a where isnumeric([CAP QTY MONTHLY])<>1


delete a from #tmpRawDataSpecialRate a  where isnumeric([CAP QTY MONTHLY])<>1


;with ashcte as(select *,Row_number() over(partition by dbnodeid,storeid,prdnodeid order by dbnodeid,storeid,prdnodeid) as rown from #tmpRawDataSpecialRate)
insert into tmpRawDataSpecialRate_Error([Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,ErrorId,TimeStampIns)
select [Distributor Code],[Retailer Code],[RETAILER NAME],[SPECIAL RATE ID],[PACK TYPE],[FROM DATE],[TO DATE],[SPECIAL SALES RATE],[CAP QTY MONTHLY],[CLAIM AMOUNT PER UNIT],[ACTIVE STATUS],[APPROVED STATUS],FileSetId,8,@currdate from ashcte where  rown>1

;with ashcte as(select *,Row_number() over(partition by dbnodeid,storeid,prdnodeid order by dbnodeid,storeid,prdnodeid) as rown from #tmpRawDataSpecialRate)
delete from ashcte where  rown>1

truncate table tblPrdStoreProductPriceMstr
insert into tblPrdStoreProductPriceMstr(StoreId,PrdNodeId,PrdNodeType,RLP,RLP_Case,TimeStampins
--,ReqCapQtyInPcs,ActCapQtyInPcs,
,DbNodeId,DbNodeType
--,SpecialRateId,FileSetId

)
select StoreId,PrdNodeId,PrdNodeType,[SPECIAL SALES RATE],CONVERT(NUMERIC(18,10),[SPECIAL SALES RATE])*pcsinbox,@currdate
--,[CAP QTY MONTHLY],0

,DbNodeId,
DbNodeType
--,[SPECIAL RATE ID],@CycFileId 
from #tmpRawDataSpecialRate a 



end
