

--select * from mrco_TEMP_ClosingStockDetail_Astic order by CycFileID desc
--[spPopulateActiveProductList]  1048
  CREATE proc [dbo].[spPopulateActiveProductList]  
  @FileSetId bigint
  as
  begin

  update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@FileSetId and DataRowsCopied>0
  
  if @@ROWCOUNT<1
  return;
Declare  @CurrDate datetime=dbo.[fnGetCurrentDateTime]()
insert into mrco_TEMP_ClosingStockDetail_Astic_Error(DistCode,Item_Code,Closing_Saleable_Qty,Closing_Offer_Qty,ServerDate,CREATEDDATE,
UploadFlag, FileSetId, ErrorId, TimeStampIns)
SELECT        DistCode,Item_Code,Closing_Saleable_Qty,Closing_Offer_Qty,ServerDate,CREATEDDATE,
UploadFlag, @FileSetId, 19, @CurrDate
FROM            mrco_TEMP_ClosingStockDetail_Astic a left join tblDBRSalesStructureDBR b on a.DISTCODE=b.DistributorCode
where b.NodeID is null and a.CycFileID=@FileSetId

Delete a from mrco_TEMP_ClosingStockDetail_Astic a left join tblDBRSalesStructureDBR b on a.DISTCODE=b.DistributorCode
where b.NodeID is null and a.CycFileID=@FileSetId


insert into mrco_TEMP_ClosingStockDetail_Astic_Error(DistCode,Item_Code,Closing_Saleable_Qty,Closing_Offer_Qty,ServerDate,CREATEDDATE,
UploadFlag, FileSetId, ErrorId, TimeStampIns)
SELECT       DistCode,Item_Code,Closing_Saleable_Qty,Closing_Offer_Qty,ServerDate,CREATEDDATE,
UploadFlag, @FileSetId, 22, @CurrDate
FROM            mrco_TEMP_ClosingStockDetail_Astic a left join tblPrdMstrHierLvl7 b on a.Item_Code=b.Code
where b.NodeID is null and a.CycFileID=@FileSetId

Delete a from mrco_TEMP_ClosingStockDetail_Astic a left join tblPrdMstrHierLvl7 b on a.Item_Code=b.Code
where b.NodeID is null and a.CycFileID=@FileSetId

--if object_id('tblPrdActivePrdListn') is not null
--begin
--drop table tblPrdActivePrdListn
--end

--	select * into tblPrdActivePrdListn from tblPrdActivePrdList where 1<>1
if object_id('tempdb..#DBRList') is not null
begin
drop table #DBRList
end
SELECT distinct B.nodeid into #DBRList from 
[mrco_TEMP_ClosingStockDetail_Astic] A JOIN tblDBRSalesStructureDBR B ON A.DistCode=B.DistributorCode 
where a.CycFileID=@FileSetId

Delete a from tblPrdActivePrdList a join #DBRList b on a.DistNodeId=b.NodeID

  insert into tblPrdActivePrdList
  SELECT distinct p.nodeid,p.NodeType,b.NodeID,b.NodeType,a.Closing_Saleable_Qty  FROM [mrco_TEMP_ClosingStockDetail_Astic] A JOIN tblDBRSalesStructureDBR B ON A.DistCode=B.DistributorCode 
  JOIN tblPrdMstrHierLvl7 p on p.Code=a.Item_Code
  WHERE Closing_Saleable_Qty>0 and a.CycFileID=@FileSetId

  --exec sp_rename 'tblPrdActivePrdList','tblPrdActivePrdListn1'
  --exec sp_rename 'tblPrdActivePrdListn','tblPrdActivePrdList'
  --exec sp_rename 'tblPrdActivePrdListn1','tblPrdActivePrdListn'
  

update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID=@FileSetId
 
  end

  --select * into tblPrdActivePrdList  from tblPrdActivePrdListn where 1<>1
