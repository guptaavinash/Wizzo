-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec [SpPDAGetTargetForSalesman] @PDACode=N'5C895DAF-DCBD-4408-B701-93872C228260',@Date=N'30-Dec-2021'
CREATE PROCEDURE [dbo].[SpPDAGetTargetForSalesman_OLD] 
	@PDACode VARCHAR(100),
	@Date Date
AS
BEGIN
	DECLARE @PersonNodeID Integer=0 
	DECLARE @PersonNodeType Integer=0
	SELECT @PersonNodeID=NodeID,@PersonNodeType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	PRINT '@PersonNodeID=' + CAST( @PersonNodeID AS VARCHAR)
	PRINT '@PersonNodeID=' + CAST( @PersonNodeType AS VARCHAR)
	DECLARE @SalesCovAreaNodeID INT
	DECLARE @SalesCovAreaNodeType INT

	SELECT @SalesCovAreaNodeID=NodeID,@SalesCovAreaNodeType=NodeType FROM tblSalesPersonMapping WHERE PersonNodeID=@PersonNodeID AND PersonType=@PersonNodeType AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate AND NodeType=110

	PRINT '@@SalesCovAreaNodeID=' + CAST( @SalesCovAreaNodeID AS VARCHAR)
	PRINT '@@SalesCovAreaNodeType=' + CAST( @SalesCovAreaNodeType AS VARCHAR)

	--SELECT *  FROM VwSalesHierarchyFull WHERE ASMAreaNodeId=@SalesCovAreaNodeID AND ASMAreaNodeType=@SalesCovAreaNodeType
	SELECT DISTINCT DSRAreaID ComCoverageAreaID,DSRArea ComCoverageArea,DSRAreaNodeType ComCoverageAreaType INTO #VwSalesHierarchyFull FROM VwCompanyDSRFullDetail WHERE ASMAreaID=@SalesCovAreaNodeID AND ASMAreaNodeType=@SalesCovAreaNodeType
	--SELECT * INTO #VwSalesHierarchyFull FROM VwSalesHierarchyFull WHERE ASMAreaNodeId=@SalesCovAreaNodeID AND ASMAreaNodeType=@SalesCovAreaNodeType

	CREATE TABLE #SalesTarget(CovAreaNodeID INT,CovAreaNodeType SMALLINT,CovArea VARCHAR(50),TodaysRouteNodeID INT,TodaysRouteNodeType SMALLINT,TodaysRoute VARCHAR(100),
	PersonNodeID INT,PersonNodeType SMALLINT,Personname VARCHAR(200),[Month Target] NUMERIC(10,2) DEFAULT 0,Achievement NUMERIC(10,2) DEFAULT 0,[RR Required]NUMERIC(10,2) DEFAULT 0,[Todays Store] INT DEFAULT 0,[Productive Stores(Visit)] INT DEFAULT 0,LastRouteVisitDate Date,Dstrbn_Tgt NUMERIC(10,2) DEFAULT 0,Sales_Tgt NUMERIC(10,2) DEFAULT 0)
	IF ISNULL(@PersonNodeID,0)>0
	BEGIN
		PRINT 'OK'
		--SELECT * FROM #VwSalesHierarchyFull
		INSERT INTO #SalesTarget(CovAreaNodeID,CovAreaNodeType,CovArea,PersonNodeID,PersonNodeType,Personname)
		SELECT DISTINCT V.ComCoverageAreaID,V.ComCoverageAreaType,ComCoverageArea,SM.PersonNodeID,SM.PersonType,P.Descr FROM #VwSalesHierarchyFull V INNER JOIN tblSalesPersonMapping SM ON SM.NodeID=V.ComCoverageAreaID AND SM.NodeType=V.ComCoverageAreaType AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate INNER JOIN tblMstrPerson P ON P.NodeID=SM.PersonNodeID AND P.NodeType=SM.PersonType

		UPDATE S SET TodaysRouteNodeID=RP.RouteNodeId,TodaysRouteNodeType=RP.RouteNodetype,TodaysRoute=R.Descr FROM  tblRoutePlanningVisitDetail RP INNER JOIN #SalesTarget S ON S.CovAreaNodeID=RP.CovAreaNodeID AND S.CovAreaNodeType=RP.CovAreaNodeType INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=RP.RouteNodeId AND R.NodeType=RP.RouteNodetype WHERE VisitDate=@Date
	END
	--SELECT * FROM #SalesTarget
	-- Target Update
	UPDATE S SET S.[Month Target]=CT.SecondaryTarget FROM #SalesTarget S INNER JOIN tblCompanyTarget CT ON CT.CovNodeID=S.CovAreaNodeID AND CT.CovNodeType=S.CovAreaNodeType AND YEAR(GETDATE()) * 100 + MONTH(GETDATE())=CT.RptMonthYear
	-- Achievement Update
	UPDATE S SET S.Achievement=X.TotalSales FROM #SalesTarget S,(SELECT AreaNodeId,AreaNodeType,ROUND(SUM(MTDSales)/1000,2) TotalSales FROM tblRptBeatProfileData R WHERE YEAR(GETDATE()) * 100 + MONTH(GETDATE())=R.RptMonthYear GROUP BY AreaNodeId,AreaNodeType) X WHERE X.AreaNodeId=S.CovAreaNodeID AND X.AreaNodeType=S.CovAreaNodeType 
	-- RR Required
	SELECT V.CovAreaNodeID,V.CovAreaNodeType,COUNT(DISTINCT V.ROuteNOdeID) PLannedDays INTO #PlannedDays FROM tblRoutePlanningVisitDetail(nolock) V INNER JOIN #SalesTarget ST ON ST.CovAreaNodeID=V.CovAreaNodeID AND ST.CovAreaNodeType=V.CovAreaNodeType WHERE MONTH(VisitDate)=MONTH(GETDATE()) AND YEAR(VisiTDate)=YEAR(GETDATE()) 
	GROUP BY V.CovAreaNodeID,V.CovAreaNodeType

	UPDATE S SET [RR Required]=CASE WHEN PLannedDays>0 THEN CAST(S.[Month Target]-S.Achievement AS FLOAT)/PLannedDays ELSE CAST(S.[Month Target]-S.Achievement AS FLOAT) END FROM #SalesTarget S INNER JOIN #PlannedDays P ON S.CovAreaNodeID=P.CovAreaNodeID AND S.CovAreaNodeType=P.CovAreaNodeType

	-- Todays Store
	UPDATE S SET S.[Todays Store]=X.TotalStores FROM #SalesTarget S,(SELECT AreaNodeId,AreaNodeType,COUNT(IsPlanned) TotalStores FROM tblRptBeatProfileData R WHERE YEAR(GETDATE()) * 100 + MONTH(GETDATE())=R.RptMonthYear GROUP BY AreaNodeId,AreaNodeType) X WHERE X.AreaNodeId=S.CovAreaNodeID AND X.AreaNodeType=S.CovAreaNodeType 
	-- Productive Store
	UPDATE S SET S.[Productive Stores(Visit)]=X.TotalStores FROM #SalesTarget S,(
	SELECT R.AreaNodeId,R.AreaNodeType,SUM(IsProductive) TotalStores FROM tblRptBeatProfileData R INNER JOIN (SELECT AreaNodeId,AreaNodeType,MIN(LastVisited) LastCallDate FROM tblRptBeatProfileData R GROUP BY AreaNodeId,AreaNodeType) Y ON Y.AreaNodeId=R.AreaNodeId AND Y.AreaNodeType=R.AreaNodeType
	WHERE IsPlanned=1 GROUP BY R.AreaNodeId,R.AreaNodeType
	) X 
	WHERE X.AreaNodeId=S.CovAreaNodeID AND X.AreaNodeType=S.CovAreaNodeType 
	-- Route Last Visited
	UPDATE S SET S.LastRouteVisitDate=X.LastCallDate FROM #SalesTarget S,(
	SELECT AreaNodeId,AreaNodeType,MIN(LastVisited) LastCallDate FROM tblRptBeatProfileData R GROUP BY AreaNodeId,AreaNodeType) X
	WHERE X.AreaNodeId=S.CovAreaNodeID AND X.AreaNodeType=S.CovAreaNodeType 


	UPDATE S SET S.Dstrbn_Tgt=T.Dstrbn_Tgt,S.Sales_Tgt=T.Dstrbn_Tgt FROM  #SalesTarget S INNER JOIN tblGateMeetingTarget T ON T.CovAreaNodeID=S.CovAreaNodeID AND T.CovAreaNodeType=S.CovAreaNodeType WHERE EntryPersonNodeID=@PersonNodeID AND EntryPersonNodeType=@PersonNodeType AND T.DataDate=@Date 

	SELECT CovAreaNodeID,CovAreaNodeType,CovArea,TodaysRouteNodeID,TodaysRouteNodeType,PersonNodeID,PersonNodeType,Personname + ' (' + ISNULL(TodaysRoute,'No Route') + ')' Personname,[Month Target],Achievement,[RR Required],[Todays Store],[Productive Stores(Visit)],FORMAT(LastRouteVisitDate,'dd-MMM-yyyy') LastRouteVisitDate,Dstrbn_Tgt,Sales_Tgt FROM #SalesTarget
END
