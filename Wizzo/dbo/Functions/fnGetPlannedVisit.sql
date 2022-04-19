

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetPlannedVisit]
(
	@RouteId INT,
	@RouteNodeType INT,
	@RptDate Date
)
RETURNS INT
AS
BEGIN
	
	--DECLARE @WeekNo INT
	DECLARE @CovFrqId INT
	DECLARE @WeekId INT
	DECLARE @FrqVal INT=0
	DECLARE @flgPlanned INT=0
	--SELECT @WeekNo=DATEPART(WEEK, @RptDate)  -  DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,@RptDate), 0))+ 1

	SELECT @flgPlanned=1 FROM tblRoutePlanningVisitDetail WHERE RouteNodeId=@RouteId AND RouteNodeType=@RouteNodeType AND @RptDate=VisitDate

	--IF EXISTS(SELECT RouteCoverageId from tblRouteCoverage 	WHERE RouteId=@RouteId AND NodeType=@RouteNodeType AND (@RptDate BETWEEN FromDate AND ToDate) AND DATEPART(dw,@RptDate)=Weekday)
	--BEGIN
	--	SELECT @CovFrqId=CovFrqId,@WeekId=WeekId FROM tblRouteCoverage WHERE RouteId=@RouteId AND NodeType=@RouteNodeType AND (@RptDate BETWEEN FromDate AND ToDate) AND DATEPART(dw,@RptDate)=Weekday
	--	SELECT @FrqVal=value FROM tblRoutePlanDetails WHERE WeekId=@WeekId AND CovFrqID=@CovFrqId

	--	If EXISTS(SELECT WeekId FROM tblRoutePlanDetails WHERE CovFrqID=@CovFrqId AND Value=@FrqVal AND (@RptDate BETWEEN WeekFrom AND WeekTo))
	--	BEGIN
	--		SELECT @flgPlanned=1
	--	END
	--	ELSE
	--	BEGIN
	--		SELECT @flgPlanned=0
	--	END	
	--END
	--ELSE
	--	BEGIN
	--		SELECT @flgPlanned=0
	--	END	

		return @flgPlanned
END








