

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- SpGetEmpDet 1
CREATE procEDURE [dbo].[SpGetTCEmpDet] 
	@EmpID INT
	
AS
BEGIN

	DECLARE @CurrDate datetime
	set @CurrDate=dbo.fnGetCurrentDateTime()

	SELECT        tblTCEmpMstr.EmpId, EmpName, ContactNo, EmailId, Address, EmgencyContactNo, format(DOB,'dd-MMM-yyyy') as DOB,t.TeleCallerCode as MappedTeleCallerRoute,
case when tblTCPDA_UserMapMaster.TCPDAID is not null 
then 'Yes' else 'No' end as PDAMapped,p.PDA_IMEI as [Primary IMEI],p.PDA_IMEI_Sec as [Secondary IMEI],P.PDAModelName,tblTCEmpMstr.flgActive

FROM            tblTCEmpMstr left join tblTCPDA_UserMapMaster join tblTCPDAMaster p on p.TCPDAID=tblTCPDA_UserMapMaster.TCPDAID on tblTCEmpMstr.EmpId=tblTCPDA_UserMapMaster.TCEmpID and @CurrDate between DateFrom and DateTo
left join tblTeleCallerEmpMapping em join tblTeleCallerMstr t on t.TeleCallerId=em.NodeId
and t.NodeType=t.NodeType on em.EmpId=tblTCEmpMstr.EmpId and @CurrDate between DateFrom and DateTo
WHERE        tblTCEmpMstr.EmpId=@EmpID

END
