
create procEDURE [dbo].[SpGetPDAList] --37,160
	@TASSiteNodeId int,
	@TASSiteNodeType int
AS
BEGIN
	DECLARE @CurrDate datetime
	set @CurrDate=dbo.fnGetCurrentDateTime()
	
	SELECT P.PDAID,PDAModelName,PDA_IMEI,PDA_IMEI_Sec,ISNULL(E.EmpId,0) EmpId,ISNULL(E.EmpName,'Un-Assigned') EmpName,E.ContactNo,E.EmailId FROM tblPDAMaster P LEFT OUTER JOIN tblPDA_UserMapMaster PU ON PU.PDAID=P.PDAID AND CAST(@CurrDate AS DATE) BETWEEN PU.DateFrom AND PU.DateTo LEFT JOIN tblEmpMstr E ON E.EmpId=PU.EmpID  WHERE P.TASSiteNodeId=@TASSiteNodeId AND P.TASSiteNodeType=@TASSiteNodeType AND ISNULL(flgTesting,0)=0 
END
