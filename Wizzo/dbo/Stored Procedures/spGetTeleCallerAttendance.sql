


--exec spGetPersonAttendance 33,193,140,'31-Jul-2019'
CREATE proc [dbo].[spGetTeleCallerAttendance]
@LoginId int,
@TSVNodeId int=0,
@TSVNodeType int=0,
@AttDate datetime
as
begin
--set @AttDate='05-Jul-2019'
--select @BranchNodeid=b.UserNodeId,@BranchNodeType=b.UserNodeType from tblSecUserLogin a join tblSecMapUserRoles b on a.userid=b.UserID where LoginId=@LoginId

--select @BranchNodeid,@BranchNodeType,@AttDate
set @TSVNodeId=0
set @TSVNodeType=0
Declare @WeekDay tinyint,@CovTypeId tinyint,@WeekId int
set datefirst 1
select @WeekDay=DATEPART(dw,@AttDate)
set datefirst 7

select @WeekId=(datediff(week, dateadd(week, datediff(week, 0, dateadd(month, datediff(month, 0, @AttDate), 0)), 0), @AttDate - 1) + 1)

DECLARE @CurrDate datetime
set @CurrDate=dbo.fnGetCurrentDateTime()

Select a.TeleCallerId,A.NodeType,isnull(A.TeleCallerCode,'') as [Tele Caller],isnull(e.EmpName,'Not Available') as Name,isnull(e.ContactNo,'Not Available') as ContactNo, convert(int,0) as flgAbsent into #Attend from tblTeleCallerMstr A left join [dbo].[tblTeleCallerEmpMapping] b 
join tblTCEmpMstr e on e.EmpId=b.EmpId
on a.TeleCallerId=b.NodeId and a.NodeType=b.NodeType
and @CurrDate between b.FromDate and b.ToDate where TSVNodeId=@TSVNodeId and TSVNodeType=@TSVNodeType and a.flgActive=1

--order by DSEName
Declare @AttendId int=0
select @AttendId=TCAttendId from tblTCAttendanceMstr where TSVNodeId=@TSVNodeId and TSVNodeType=@TSVNodeType
and Attnddate=@AttDate

Update  a set flgAbsent=b.Absent from #Attend a join tblTCAttendanceDetail b on a.TeleCallerId=b.TeleCallerId WHERE  TCAttendId=@AttendId 

select * from #Attend order by [Tele Caller]


select @AttendId isSubmitted


end
