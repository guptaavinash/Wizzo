-- =============================================
-- Author:		Avinash Gupta
-- Create date: 27-Apr-2015
-- Description:	
-- =============================================
-- SpGetRouteDetailsOnDates 96,10,'12-Jun-15','30-Jun-15', 56,9
-- SpGetRouteDetailsOnDates 86,7,'1-Jan-16','1-April-49',2,6
CREATE PROCEDURE [dbo].[SpGetRouteDetailsOnDates] 
	@RouteNodeID INT, --0=New Routes ,1 =Existing Routes
	@RouteNodeType INT, 
	@FromDate DATE,
	@ToDate DATE,
	@ParentNodeID INT,
	@ParentNodeType INT
AS
BEGIN
	DECLARE @CovFrqID INT
	DECLARE @WeekId INT
	DECLARE @WeekValue INT

	IF @RouteNodeID=0
	BEGIN
		SELECT DISTINCT PersonNodeID,P.Descr PersonName,P.PersonEmailID PersonEmail,P.PersonPhone,PM.FromDate,PM.ToDate FROM tblSalesPersonMapping PM 
		INNER JOIN tblMstrPerson P ON P.NodeID=PM.PersonNodeID
		WHERE PM.NodeID=@ParentNodeID AND PM.NodeType=@ParentNodeType AND (PM.FromDate BETWEEN @FromDate AND @ToDate OR PM.ToDate BETWEEN @FromDate AND @ToDate)
	END
	ELSE
	BEGIN
		SELECT DISTINCT RouteID,CovFrqID,[Weekday],FromDate,ISNULL(ToDate,'01-Jan-2049') ToDate,WeekID,CASE CovFrqID WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 3 THEN 2 WHEN 10 THEN 2 ELSE 3 END AS CovTypeId INTO #RouteDetails FROM tblRouteCoverage
		WHERE RouteID=@RouteNodeID AND NodeType=@RoutenodeType AND ISNULL(ToDate,'01-Jan-2049')>=CONVERT(VARCHAR(11),GETDATE(),112)
		AND (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate)
		--DATEDIFF(d,FromDate,@FromDate)=0 AND DATEDIFF(d,ToDate,@ToDate)=0

		SELECT @CovFrqID=CovFrqID,@WeekId=WeekID FROM #RouteDetails
		--SELECT @CovFrqID
		--SELECT @WeekId

		SELECT DISTINCT TOP 4 WeekId,WeekFrom,WeekTo,Value INTO #Weeks
		FROM tblRoutePlanDetails
		WHERE weekfrom>= CAST(DATEADD(dd, -(DATEPART(dw, GETDATE())-1), GETDATE()) AS DATE) AND CovFrqID=@CovFrqID
		ORDER BY WeekFrom
		--SELECT * FROm #Weeks

		IF NOT EXISTS(SELECT 1 FROM #Weeks WHERE WeekId=@WeekId)
		BEGIN
			SELECT @WeekValue=Value FROM tblRoutePlanDetails WHERE CovFrqID=@CovFrqID AND WeekId=@WeekId
			--SELECT @WeekValue

			UPDATE #RouteDetails SET #RouteDetails.WeekId=AA.WeekId FROM #RouteDetails,(SELECT MIN(WeekId) WeekId FROM #Weeks WHERE Value=@WeekValue) AA
		END
		SELECT * FROM #RouteDetails

		SELECT DISTINCT PersonNodeID,P.Descr PersonName,PM.FromDate,PM.ToDate FROM tblSalesPersonMapping PM INNER JOIN tblMstrPerson P ON P.NodeID=PM.PersonNodeID
		WHERE PM.NodeID=@RouteNodeID AND PM.NodeType=@RoutenodeType AND 
		((@FromDate BETWEEN PM.FromDate AND PM.ToDate OR @ToDate BETWEEN PM.FromDate AND PM.ToDate) OR (PM.FromDate BETWEEN @FromDate AND @ToDate OR PM.ToDate BETWEEN @FromDate AND @ToDate))
		--(PM.FromDate BETWEEN @FromDate AND @ToDate OR PM.ToDate BETWEEN @FromDate AND @ToDate)
	END
	


	----SELECT DISTINCT RouteID,StoreID,FromDate,ToDate 
	----FROM tblRouteCoverageStoreMapping WHERE RouteID=@RouteNodeID AND NodeType=@RoutenodeType
	----AND FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate
END





