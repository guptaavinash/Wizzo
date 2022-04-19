-- SpGetDSRRouteDetails 51,11
CREATE PROCEDURE [dbo].[SpGetDSRRouteDetails] --50,16
	@RouteNodeID INT,
	@RoutenodeType INT
AS
BEGIN
	DECLARE @StoreCount INT
	CREATE TABLE #RouteDetails (RouteID INT,FromDate Datetime,ToDate Datetime,StoreCount INT,PersonAssigned VARCHAR(200))
	INSERT INTO #RouteDetails(RouteID,FromDate,ToDate)
	SELECT DISTINCT RouteID,FromDate,ISNULL(ToDate,'01-Jan-2049') FROM tblRouteCoverage WHERE RouteID=@RouteNodeID AND NodeType=@RoutenodeType 
	AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND TODate

	
	SELECT DISTINCT RouteID,StoreID,FromDate,ToDate INTO #TblRoute
	FROM tblRouteCoverageStoreMapping WHERE RouteID=@RouteNodeID AND RouteNodeType=@RoutenodeType
	--GROUP BY RouteID,FromDate,ToDate

	SELECT TR.RouteID,COUNT(DISTINCT StoreID) StoreCount,RD.FromDate,RD.ToDate INTO #StoreCountTable FROM #TblRoute TR INNER JOIN #RouteDetails RD ON TR.RouteID=RD.RouteID
	WHERE (TR.FromDate BETWEEN RD.FromDate AND RD.ToDate OR TR.ToDate BETWEEN RD.FromDate AND RD.ToDate) OR
	(RD.FromDate BETWEEN TR.FromDate AND TR.ToDate OR RD.ToDate BETWEEN TR.FromDate AND TR.ToDate)
	GROUP BY TR.RouteID,RD.FromDate,RD.ToDate

	UPDATE RD SET StoreCount=R.StoreCount FROM #RouteDetails RD INNER JOIN #StoreCountTable R ON R.RouteID=RD.RouteID
	WHERE DATEDIFF(d,RD.FromDate,R.FromDate)=0 AND DATEDIFF(d,RD.ToDate,R.ToDate)=0

	--SELECT * FROM #RouteDetails
	--SELECT * FROM #TblRoute

	SELECT DISTINCT PersonNodeID,P.Descr PersonName,PM.FromDate,PM.ToDate INTO #PersonDetails FROM tblSalesPersonMapping PM INNER JOIN tblMstrPerson P ON P.NodeID=PM.PersonNodeID
	WHERE PM.NodeID=@RouteNodeID AND PM.NodeType=@RoutenodeType

	--SELECT * FROM #PersonDetails

	-- Make temp tabel with person to defined dates
	--Select distinct t.RouteID,t.StoreCount,t.FromDate,t.ToDate,t2.PersonNodeID,t2.PersonName from #RouteDetails t,#PersonDetails t2

	Select distinct t.RouteID,t.StoreCount,t.FromDate,t.ToDate,t2.PersonNodeID,t2.PersonName INTO #tmp from #RouteDetails t,#PersonDetails t2 
	WHERE t2.FromDate between t.FromDate and t.ToDate OR t2.ToDate between t.FromDate and t.ToDate
	OR t.FromDate BETWEEN t2.Fromdate AND t2.ToDate OR t.ToDate BETWEEN t2.Fromdate AND t2.ToDate

	--SELECT * FROM #tmp

	SELECT DISTINCT t2.RouteID,t2.FromDate,t2.ToDate ,t2.StoreCount,
	STUFF((SELECT ',' + CAST(t.PersonNodeID AS VARCHAR) + '^' + t.PersonName
			FROM #tmp t
			WHERE DATEDIFF(d,t2.FromDate,t.FromDate)=0
			AND DATEDIFF(d,t2.ToDAte,t.ToDate)=0
			FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)') 
		,1,1,'')  as PersonDetails  FROM #RouteDetails t2

	


END






