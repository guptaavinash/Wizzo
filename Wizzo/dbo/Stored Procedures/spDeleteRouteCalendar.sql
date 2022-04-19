Create proc spDeleteRouteCalendar
@VisitDate date
as
begin
delete b from tblroutecalendar b 
where b.visitdate=@VisitDate

end