-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetStartWeekOptionBasedOnCovFrequency] 
	
AS
BEGIN
	SET DATEFIRST 1
		
	--select DATEADD(dd, -(DATEPART(dw, GETDATE())-1), GETDATE()) AS StartWeek
	--select DATEADD(dd, 7-(DATEPART(dw, GETDATE())), GETDATE()) As EndWeek
	SELECT tblRoutePlanDetails.WeekId,FORMAT(tblRoutePlanDetails.WeekFrom,'dd-MMM-yy')+ ' to ' + FORMAT(tblRoutePlanDetails.WeekTo,'dd-MMM-yy') AS [Week],tblRoutePlanDetails.CovFrqId FROM tblRoutePlanDetails INNER JOIN
	(SELECT DISTINCT TOP 4 WeekId,WeekFrom,WeekTo--,CovFrqId
	FROM tblRoutePlanDetails
	WHERE weekfrom>= CAST(DATEADD(dd, -(DATEPART(dw, GETDATE())-1), GETDATE()) AS DATE)
	ORDER BY WeekFrom) AA ON tblRoutePlanDetails.WeekId=AA.WeekId
	ORDER BY tblRoutePlanDetails.WeekFrom,tblRoutePlanDetails.CovFrqId

	SET DATEFIRST 7
END
