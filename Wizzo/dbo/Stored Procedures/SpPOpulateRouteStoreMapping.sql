-- =============================================
-- Author:		Avinash Gupta
-- Create date: 12-Oct-2021
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpPOpulateRouteStoreMapping] 
	
AS
BEGIN
	--SELECT TOP 10 * FROM tblRouteCalendar
	--SELECT * FROM tblRouteCoverageStoreMapping

	CREATE TABLE #WeekDay(RouteDay VARCHAR(50))
	INSERT INTO #WeekDay
	SELECT 'Monday'
	UNION
	SELECT 'Tuesday'
	UNION
	SELECT 'Wednesday'
	UNION
	SELECT 'Thursday'
	UNION
	SELECT 'Friday'
	UNION
	SELECT 'Saturday'

	SELECT DISTINCT RoutenodeID,RouteNodeType,VisitDate,DATENAME(WEEKDAY,VisitDate) RouteDAY INTO #RouteCoverage FROM tblRouteCalendar WHERE RouteNodeId>0 AND MONTH(VisitDate)=MONTH(GETDATE()) AND YEAR(VisitDate)=YEAR(GETDATE()) ORDER BY RouteNodeId,VisitDate

	CREATE TABLE #tblRouteCoverage(RouteNodeID INT,RouteNodeType SMALLINT,Mon INT,Tue INT,Wed INT,Thu INT,Fri INT,Sat INT,WeekID INT)
	INSERT INTO #tblRouteCoverage(RouteNodeID,RouteNodeType)
	SELECT DISTINCT RoutenodeID,RouteNodeType FROM #RouteCoverage

	--UPDATE R SET WeekID=WeekID FROM #tblRouteCoverage R WHERE 

END
