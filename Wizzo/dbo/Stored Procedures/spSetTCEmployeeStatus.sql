

CREATE proc [dbo].[spSetTCEmployeeStatus]
@EmpId int,
@flgActive bit,
@LoginId int
as
begin

Declare @Curr_Date datetime
set @Curr_Date=dbo.fnGetCurrentDateTime()

if @flgActive=0
begin

Update tblTCPDA_UserMapMaster set DateTo=DATEADD(dd,-1,@Curr_Date),LoginIDUpd=@LoginId,TimestampUpd=@Curr_Date where TCEmpID=@EmpId and @Curr_Date between DateFrom and DateTo
Update tblTeleCallerEmpMapping set ToDate=DATEADD(dd,-1,@Curr_Date),LoginIDUpd=@LoginId,TimestampUpd=@Curr_Date where EmpID=@EmpId and @Curr_Date between FromDate and ToDate
end
Update tblTCEmpMstr set flgActive=@flgActive,LoginIDUpd=@LoginId,TimestampUpd=@Curr_Date where EmpId=@EmpId

end
