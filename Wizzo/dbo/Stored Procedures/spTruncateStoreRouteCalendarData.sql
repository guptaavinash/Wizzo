
Create proc [dbo].[spTruncateStoreRouteCalendarData]
as
begin
truncate table tblstoremaster
truncate table tbldbrsalesstructureroute
truncate table tblmstrperson
truncate table tblroutecalendar

end
