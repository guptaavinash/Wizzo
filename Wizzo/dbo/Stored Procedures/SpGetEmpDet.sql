

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- SpGetEmpDet 1
create procEDURE [dbo].[SpGetEmpDet] 
	@EmpID INT
	
AS
BEGIN

	DECLARE @CurrDate datetime
	set @CurrDate=dbo.fnGetCurrentDateTime()

	SELECT        tblEmpMstr.EmpId, EmpName, ContactNo, EmailId, Address, EmgencyContactNo, format(DOB,'dd-MMM-yyyy') as DOB,t.TeleCallerCode as MappedTeleCallerRoute,
case when tblPDA_UserMapMaster.PDAID is not null 
then 'Yes' else 'No' end as PDAMapped,p.PDA_IMEI as [Primary IMEI],p.PDA_IMEI_Sec as [Secondary IMEI],P.PDAModelName,tblEmpMstr.flgActive

FROM            tblEmpMstr left join tblPDA_UserMapMaster join tblPDAMaster p on p.PDAID=tblPDA_UserMapMaster.PDAID on tblEmpMstr.EmpId=tblPDA_UserMapMaster.EmpID and @CurrDate between DateFrom and DateTo
left join tblTeleCallerEmpMapping em join tblTeleCallerMstr t on t.TeleCallerId=em.NodeId
and t.NodeType=t.NodeType on em.EmpId=tblEmpMstr.EmpId and @CurrDate between DateFrom and DateTo
WHERE        tblEmpMstr.EmpId=@EmpID

END
