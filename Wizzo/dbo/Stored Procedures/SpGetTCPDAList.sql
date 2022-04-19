
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procEDURE [dbo].[SpGetTCPDAList] --37,160
	@TASSiteNodeId int,
	@TASSiteNodeType int
AS
BEGIN
	DECLARE @CurrDate datetime
	set @CurrDate=dbo.fnGetCurrentDateTime()
	
	SELECT P.TCPDAID AS PDAID,PDAModelName,PDA_IMEI,PDA_IMEI_Sec,ISNULL(E.EmpId,0) EmpId,ISNULL(E.EmpName,'Un-Assigned') EmpName,E.ContactNo,E.EmailId FROM tblTCPDAMaster P LEFT OUTER JOIN tblTCPDA_UserMapMaster PU ON PU.TCPDAID=P.TCPDAID AND CAST(@CurrDate AS DATE) BETWEEN PU.DateFrom AND PU.DateTo LEFT JOIN tblTCEmpMstr E ON E.EmpId=PU.TCEmpID  WHERE P.TASSiteNodeId=@TASSiteNodeId AND P.TASSiteNodeType=@TASSiteNodeType AND ISNULL(flgTesting,0)=0 
END
