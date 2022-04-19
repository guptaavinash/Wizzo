
CREATE proc [dbo].[spGetPurchReqMaster]
as
begin
select BUOMID as UOMID,BUOMName as UOM from  tblPrdMstrBUOMMaster where BUOMID=1
select * from [dbo].[tblManufacturerMstrMain]

select -1 as POProcessStatusId,'All' as POProcessStatus
union all
SELECT        POProcessStatusId, POProcessStatus
FROM            tblMstrPurchaseReqProcessStatus
end

