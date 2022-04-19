

create proc [dbo].[spGetEmpList]
@TASSiteNodeId int=1,
@TASSiteNodeType int=160,
@flgActive bit
as
begin

DECLARE @CurrDate datetime
set @CurrDate=dbo.fnGetCurrentDateTime()

SELECT        tblEmpMstr.EmpId, EmpName, ContactNo, EmailId, Address, EmgencyContactNo, DOB,t.TeleCallerCode as MappedTeleCallerRoute,
case when tblPDA_UserMapMaster.PDAID is not null 
then 'Yes' else 'No' end as PDAMapped,P.PDAModelName,p.PDA_IMEI as [Primary IMEI],p.PDA_IMEI_Sec as [Secondary IMEI]

FROM            tblEmpMstr left join tblPDA_UserMapMaster join tblPDAMaster p on p.PDAID=tblPDA_UserMapMaster.PDAID on tblEmpMstr.EmpId=tblPDA_UserMapMaster.EmpID and @CurrDate between  tblPDA_UserMapMaster.DateFrom and tblPDA_UserMapMaster.DateTo
left join tblTeleCallerEmpMapping em join tblTeleCallerMstr t on t.TeleCallerId=em.NodeId
and t.NodeType=t.NodeType on em.EmpId=tblEmpMstr.EmpId and @CurrDate between em.FromDate and em.ToDate
WHERE        (tblEmpMstr.TASSiteNodeId = @TASSiteNodeId) AND (tblEmpMstr.TASSiteNodeType = @TASSiteNodeType)
and tblempmstr.flgActive=@flgActive
end
