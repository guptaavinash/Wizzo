
CREATE proc [dbo].[spTruncateSalesData]
as
begin
truncate table tblSalesStatusLog
truncate table tblsalesdetail
delete from tblsalesmaster


 DBCC CHECKIDENT ('tblsalesmaster', RESEED, 0); 

end
