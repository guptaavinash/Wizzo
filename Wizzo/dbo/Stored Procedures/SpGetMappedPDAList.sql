
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procEDURE [dbo].[SpGetMappedPDAList] --1,160
	@TASSiteNodeId int,
	@TASSiteNodeType int
AS
BEGIN
		DECLARE @CurrDate datetime
		set @CurrDate=dbo.fnGetCurrentDateTime()
		
		SELECT PDA_IMEI,PDA_IMEI_Sec,ISNULL(E.EmpId,0) EmpId,ISNULL(E.EmpName,'Un-Assigned') EmpName FROM tblPDAMaster P LEFT OUTER JOIN tblPDA_UserMapMaster PU ON PU.PDAID=P.PDAID AND CAST(@CurrDate AS DATE) BETWEEN PU.DateFrom AND PU.DateTo LEFT JOIN tblEmpMstr E ON E.EmpId=PU.EmpID  WHERE P.TASSiteNodeId=@TASSiteNodeId AND P.TASSiteNodeType=@TASSiteNodeType AND ISNULL(flgTesting,0)=0 
	
	
	select distinct b.TeleCallerId, isnull(e.EmpId,0) as EmpId,b.TeleCallerCode as UserName,e.EmpName into #User from  tblTeleCallerMstr b 
 join [dbo].[tblTeleCallerEmpMapping] tc join tblEmpMstr e on e.EmpId=tc.EmpId

 on tc.NodeId=b.TeleCallerId
and tc.NodeType=b.NodeType and @CurrDate between tc.FromDate and tc.ToDate

select * from #User 

Select EmpId, EmpName, ContactNo, EmailId from tblEmpMstr WHERE TASSiteNodeId=@TASSiteNodeId AND TASSiteNodeType=@TASSiteNodeType AND flgActive=1 AND EmailId <> '' AND ContactNo <> '0'
END
