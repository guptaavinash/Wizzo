

--select * from tblSecUserLogin order by 1 desc
CREATE proc [dbo].[spGetTCUserListForMapping] 
@LoginId int=0
as
begin
Declare @NodeId int=0,@NodeType int=0,@Date date=dbo.fnGetCurrentDateTime()
select @NodeId=b.UserNodeId,@NodeType=b.UserNodeType from tblSecUserLogin a join tblSecMapUserRoles b on a.userid=b.userid
where loginid=@loginid


select distinct b.TeleCallerId,b.NodeType,isnull(e.EmpId,0) as EmpId,b.TeleCallerCode as UserName,isnull(e.EmpName,'Un-Assigned') as EmpName,case when tblTCPDA_UserMapMaster.TCPDAID is not null 
then 'Yes' else 'No' end as PDAMapped,P.PDAModelName,p.PDA_IMEI as [Primary IMEI],p.PDA_IMEI_Sec as [Secondary IMEI] into #User from  tblTeleCallerMstr b 
left join [dbo].[tblTeleCallerEmpMapping] tc join tblTCEmpMstr e on e.EmpId=tc.EmpId
left join tblTCPDA_UserMapMaster join tblTCPDAMaster p on p.TCPDAID=tblTCPDA_UserMapMaster.TCPDAID on e.EmpId=tblTCPDA_UserMapMaster.TCEmpID and @Date between  tblTCPDA_UserMapMaster.DateFrom and tblTCPDA_UserMapMaster.DateTo
 on tc.NodeId=b.TeleCallerId
and tc.NodeType=b.NodeType and @Date between tc.FromDate and tc.ToDate

where  b.TSVNodeId=@NodeId
and b.TSVNodeType=@NodeType
and b.flgActive=1


select * from #User
end
