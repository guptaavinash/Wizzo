
Create proc [dbo].[spRptFilterMastersData]
as
begin

select * from tblMstrSector
select * from tblTeleReasonMstr where flgRptFilter=1


end
