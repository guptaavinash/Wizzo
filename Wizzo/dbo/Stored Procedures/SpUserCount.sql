-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpUserCount] 
	
AS
BEGIN
	SELECT C.PersonNodeID,personnodetype,P.PersonPhone,P.Descr,DATENAME(MONTH,C.TImestampins) MON,DATENAME(YEAR,C.Timestampins) Yrs,COUNT(DISTINCT StoreID) TOtalValidated,A.NoOfDaysWorking FROM tblStoreContactUpdate C INNER JOIN tblMstrPerson P ON p.NodeID=C.PersonNodeID AND p.NodeType=C.PersonNodeType
	LEFT OUTER JOIN (SELECT MONTH(Datetime) MOn,YEAR(Datetime) Yr,PersonNodeID,COUNT(DISTINCT PersonAttendanceID) NoOfDaysWorking FROM tblPersonAttendance GROUP BY MONTH(Datetime),YEAR(Datetime), PersonNodeID) A ON A.PersonNodeID=P.NodeID AND A.MOn=MONTH(C.TimestampIns) AND A.Yr=YEAR(C.TimestampIns)
	GROUP BY C.PersonNodeID,personnodetype,P.PersonPhone,P.Descr,DATENAME(MONTH,C.TImestampins),DATENAME(YEAR,C.Timestampins),A.NoOfDaysWorking
	ORDER BY DATENAME(MONTH,C.TImestampins) DESC
END
