


Create proc [dbo].[spMarkPresentAgainstSO]
@AttendDetId int,
@LoginId int
as
begin
Declare @CurrDate datetime=dbo.fnGetCurrentDateTime()

Update tblAttendanceDet set Absent=0,LoginIdUpd=@LoginId,TimeStampUpd=@CurrDate where AttendDetId=@AttendDetId
Delete a from tblTeleCallerListForDay a 
where a.Date=convert(date,@currdate) and IsUsed=0
and a.AttendDetId=@AttendDetId

end
