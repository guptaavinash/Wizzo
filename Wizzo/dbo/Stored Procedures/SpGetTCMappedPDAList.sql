
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procEDURE [dbo].[SpGetTCMappedPDAList] --37,160
	@TASSiteNodeId int,
	@TASSiteNodeType int
AS
BEGIN
		DECLARE @CurrDate datetime
		set @CurrDate=dbo.fnGetCurrentDateTime()
		
		SELECT PDA_IMEI,PDA_IMEI_Sec,ISNULL(E.EmpId,0) EmpId,ISNULL(E.EmpName,'Un-Assigned') EmpName FROM tblTCPDAMaster P LEFT OUTER JOIN tblTCPDA_UserMapMaster PU ON PU.TCPDAID=P.TCPDAID AND CAST(@CurrDate AS DATE) BETWEEN PU.DateFrom AND PU.DateTo LEFT JOIN tblTCEmpMstr E ON E.EmpId=PU.TCEmpID  WHERE P.TASSiteNodeId=@TASSiteNodeId AND P.TASSiteNodeType=@TASSiteNodeType AND ISNULL(flgTesting,0)=0 
	
	
	select distinct b.TeleCallerId, isnull(e.EmpId,0) as EmpId,b.TeleCallerCode as UserName,e.EmpName into #User from  tblTeleCallerMstr b 
 join [dbo].[tblTeleCallerEmpMapping] tc join tblTCEmpMstr e on e.EmpId=tc.EmpId

 on tc.NodeId=b.TeleCallerId
and tc.NodeType=b.NodeType and @CurrDate between tc.FromDate and tc.ToDate
join tblTeleSuperVisorSalesHierMap ts on ts.TSVNodeId=b.TSVNodeId
AND ts.TSVNodeType=b.TSVNodeType
where  ts.SalesNodeId=@TASSiteNodeId
and ts.SalesNodeType=@TASSiteNodeType
and b.flgActive=1
select * from #User 

Select EmpId, EmpName, ContactNo, EmailId from tblTCEmpMstr WHERE TASSiteNodeId=@TASSiteNodeId AND TASSiteNodeType=@TASSiteNodeType AND flgActive=1 AND EmailId <> '' AND ContactNo <> '0'
END
