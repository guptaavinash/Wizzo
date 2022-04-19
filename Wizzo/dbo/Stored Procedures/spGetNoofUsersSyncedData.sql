-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

--[spGetNoofUsersSyncedData]202201
CREATE PROCEDURE [dbo].[spGetNoofUsersSyncedData]
@RptMonthYear INT
AS
BEGIN
	SELECT A.PersonNodeID,B.Descr as [Person Name],B.Code,case when B.NodeType =210 then 'ASM' else 'TSI' end as Role,ISNULL(B.PersonEmailID,'') [Person EmailID],B.PersonPhone [Person Phone],COUNT(DISTINCT CAST([Datetime] AS DATE)) [# of Days Worked]
	FROM tblPersonAttendance A INNER JOIN tblMstrPerson B ON A.PersonNodeID=B.NodeID and A.PersonNodeType = B.NodeType
	WHERE CONVERT(VARCHAR(6),A.[Datetime],112)=@RptMonthYear
	GROUP BY A.PersonNodeID,B.Descr ,B.Code,B.Designation,B.PersonEmailID,B.PersonPhone, B.NodeType
	order by B.Designation,B.Code

	

	


END
