
CREATE proc [dbo].[spForPDAUOMMaster]  
as  
  
select BUOMID AS UOMID,BUOMName AS UOM from  [dbo].[tblPrdMstrBUOMMaster] where BUOMID=2
  
	select * from [dbo].[tblManufacturerMstrMain]
	order by 2
