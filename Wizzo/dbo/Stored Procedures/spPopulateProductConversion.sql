
CREATE proc [dbo].[spPopulateProductConversion]
@FileSetId bigint
as
begin

Declare  @CurrDate datetime=dbo.[fnGetCurrentDateTime]()
insert into mrco_NRC_SCHEME_PRODUCTMASTER_Urban_Error(DistCode,
BRANDCODE,
BRANDNAME,
SKUCODE,
PRODUCTCODE,
PRODUCTUNIT,
PRODUCTUOM,
PRODUCTWEIGHT,
CaseUomid,
CREATEDDATE,
CycFileID,ErrorId,TimeStampIns)
select DistCode,
BRANDCODE,
BRANDNAME,
SKUCODE,
PRODUCTCODE,
PRODUCTUNIT,
PRODUCTUOM,
PRODUCTWEIGHT,
CaseUomid,
CREATEDDATE,
CycFileID, 19, @CurrDate from mrco_NRC_SCHEME_PRODUCTMASTER_Urban a left join tblDBRSalesStructureDBR b on a.DISTCODE=b.DistributorCode
where b.NodeID is null and a.CycFileID=@FileSetId

delete a from mrco_NRC_SCHEME_PRODUCTMASTER_Urban a left join tblDBRSalesStructureDBR b on a.DISTCODE=b.DistributorCode
where b.NodeID is null and a.CycFileID=@FileSetId



insert into mrco_NRC_SCHEME_PRODUCTMASTER_Urban_Error(DistCode,
BRANDCODE,
BRANDNAME,
SKUCODE,
PRODUCTCODE,
PRODUCTUNIT,
PRODUCTUOM,
PRODUCTWEIGHT,
CaseUomid,
CREATEDDATE,
CycFileID,ErrorId,TimeStampIns)
select DistCode,
BRANDCODE,
BRANDNAME,
SKUCODE,
PRODUCTCODE,
PRODUCTUNIT,
PRODUCTUOM,
PRODUCTWEIGHT,
a.CaseUomid,
CREATEDDATE,
CycFileID, 19, @CurrDate from mrco_NRC_SCHEME_PRODUCTMASTER_Urban a left join tblPrdMstrHierLvl7 b on a.PRODUCTCODE=b.Code
where b.NodeID is null and a.CycFileID=@FileSetId


delete a from mrco_NRC_SCHEME_PRODUCTMASTER_Urban a left join tblPrdMstrHierLvl7 b on a.PRODUCTCODE=b.Code
where b.NodeID is null and a.CycFileID=@FileSetId


update d set PcsInBox=a.PRODUCTUOM,Volume=a.PRODUCTWEIGHT,VolUomId=u.BUOMID from  mrco_NRC_SCHEME_PRODUCTMASTER_Urban a join tblPrdMstrHierLvl7 b on a.PRODUCTCODE=b.Code
join tblDBRSalesStructureDBR c on c.DistributorCode=a.DISTCODE
join tblPrdDistributorProductPriceMstr d on d.DistNodeId=c.NodeID
and d.DistNodeType=c.NodeType
and d.PrdNodeId=b.NodeID
and d.PrdNodeType=b.NodeType
left join tblPrdMstrBUOMMaster u on u.BUOMName=a.PRODUCTUNIT
WHERE a.CycFileID=@FileSetId

update b set PcsInBox=a.PRODUCTUOM,Volume=a.PRODUCTWEIGHT,VolUomId=u.BUOMID,CaseUomId=a.CaseUomid from  mrco_NRC_SCHEME_PRODUCTMASTER_Urban a join tblPrdMstrHierLvl7 b on a.PRODUCTCODE=b.Code
left join tblPrdMstrBUOMMaster u on u.BUOMName=a.PRODUCTUNIT
WHERE a.CycFileID=@FileSetId
END
