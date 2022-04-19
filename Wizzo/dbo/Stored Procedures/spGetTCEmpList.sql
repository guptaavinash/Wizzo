

CREATE proc [dbo].[spGetTCEmpList]
@TASSiteNodeId int,
@TASSiteNodeType int,
@flgActive bit
as
begin

DECLARE @CurrDate datetime
set @CurrDate=dbo.fnGetCurrentDateTime()

SELECT        tblTCEmpMstr.EmpId, EmpName, ContactNo, EmailId, Address, EmgencyContactNo, DOB,t.TeleCallerCode as MappedTeleCallerRoute,
case when tblTCPDA_UserMapMaster.TCPDAID is not null 
then 'Yes' else 'No' end as PDAMapped,P.PDAModelName,p.PDA_IMEI as [Primary IMEI],p.PDA_IMEI_Sec as [Secondary IMEI]

FROM            tblTCEmpMstr left join tblTCPDA_UserMapMaster join tblTCPDAMaster p on p.TCPDAID=tblTCPDA_UserMapMaster.TCPDAID on tblTCEmpMstr.EmpId=tblTCPDA_UserMapMaster.TCEmpID and @CurrDate between  tblTCPDA_UserMapMaster.DateFrom and tblTCPDA_UserMapMaster.DateTo
left join tblTeleCallerEmpMapping em join tblTeleCallerMstr t on t.TeleCallerId=em.NodeId
and t.NodeType=t.NodeType on em.EmpId=tblTCEmpMstr.EmpId and @CurrDate between em.FromDate and em.ToDate
WHERE        (tblTCEmpMstr.TASSiteNodeId = @TASSiteNodeId) AND (tblTCEmpMstr.TASSiteNodeType = @TASSiteNodeType)
and tblTCempmstr.flgActive=@flgActive
end
