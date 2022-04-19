

Create view [dbo].[vwTCOrderMaster]
as
select * from tblTCOrderMaster
union all
select * from tblTCOrderMaster_History
