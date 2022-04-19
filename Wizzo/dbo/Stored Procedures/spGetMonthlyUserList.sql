
Create proc spGetMonthlyUserList
@FromDate date,
@ToDate date
as
begin
--Declare @FromDate date='01-Oct-2021',@ToDate date='31-Oct-2021'
if OBJECT_ID('tempdb..#UserList') is not null
begin
drop table #UserList
end
select a.UserID,NodeID,NodeType,UserName,r.RoleName,convert(varchar(500),'') as ActualName,COUNT(distinct convert(date,b.LoginTime)) as NoOfDays into #UserList from tblSecUser a join tblsecuserlogin b on a.userid=b.userid
join tblSecRoles r on r.RoleId=a.RoleID
where convert(date,b.LoginTime) between @FromDate and @Todate
group by a.UserID,NodeID,NodeType,UserName,r.RoleName


update a set ActualName=e.EmpName from #UserList a join tblTeleCallerEmpMapping b on a.NodeID=b.NodeId
and a.NodeType=b.NodeType
join tblTCEmpMstr e on e.EmpId=b.EmpId
select * from #UserList
end