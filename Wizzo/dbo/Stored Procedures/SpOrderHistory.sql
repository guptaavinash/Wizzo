-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- SpOrderHistory '314D6CE8-0C6A-4635-9D75-04AC1A56F27A'
CREATE PROCEDURE [dbo].[SpOrderHistory] 
	@PDACode VARCHAR(100),
	@CoverageAreaNodeID INT=0,
	@CoverageAreaNodeType SMALLINT=0
AS
BEGIN
	DECLARE @PersonID INT     
	DECLARE @PersonType INT
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	CREATE TABLE #CoverageArea(NodeID INT,NodeType SMALLINT)

	IF @PersonType IN (220,230)
	BEGIN
		INSERT INTO  #CoverageArea
		SELECT DISTINCT P.NodeID,P.NodeType  
		FROM tblSalesPersonMapping P     
		INNER JOIN [dbo].[tblSecMenuContextMenu] S ON S.NodeType=P. NodeType     
		WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) AND S.flgCoverageArea=1
	END
	ELSE IF @PersonType=210
	BEGIN
		IF @CoverageAreaNodeID>0 AND @coverageAreaNodeType>0
		BEGIN
			INSERT INTO  #CoverageArea
			SELECT @CoverageAreaNodeID,@coverageAreaNodeType
		END
		ELSE
		BEGIN
			INSERT INTO  #CoverageArea
			SELECT DISTINCT V.DSRAreaID,V.DSRAreaNodeType  
			FROM tblSalesPersonMapping P INNER JOIN [dbo].[VwCompanySalesHierarchy] V ON V.ASMAreaID=P.NodeID AND V.ASMAreaNodeType=P.NodeType 
			WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		END
	END

	CREATE TABLE #Routes(NodeID INT,NodeType SMALLINT)
	INSERT INTO #Routes(Nodeid,Nodetype)
		SELECT DISTINCT  RouteNodeId,RouteNodetype FROM tblRoutePlanningVisitDetail(nolock) RP INNER JOIN #CoverageArea C ON C.NodeID=RP.CovAreaNodeID AND C.NodeType=RP.CovAreaNodeType WHERE VisitDate>=CAST(GETDATE() AS DATE)
	PRINT '@PersonID=' + CAST(@PersonID AS VARCHAR) 

	CREATE TABLE #DSRStoreList (RouteNodeID INT,RouteNodeType SMALLINT,Route VARCHAR(500),flgDefaultRoute TINYINT,StoreID INT)

	INSERT INTO #DSRStoreList(RouteNodeID,RouteNodeType,Route,StoreID)
	SELECT DISTINCT RL.NodeID,RL.NodeType,'',RS.StoreID FROM #Routes RL INNER JOIN tblRouteCoverageStoreMapping RS ON RS.RouteID=RL.NodeID AND RS.RouteNodeType=RL.NodeType AND CAST(GETDATE() AS DATE) BETWEEN RS.FromDate AND RS.ToDate 


	----SELECT DISTINCT @PersonID,@PersonType,RouteNodeId,RouteNodeType,RM.Descr,RC.StoreId FROM tblRouteCalendar RC INNER JOIN tblCompanySalesStructureRouteMstr RM ON RM.NodeID=RC.RouteNodeId AND RC.RouteNodeType=RM.NodeType WHERE RC.SONodeId=@PersonID AND RC.SONodeType=@PersonType

	SELECT A.StoreID,P.invid OrderID,P.flgOrderSource,FORMAT(A.InvDate,'dd-MMM-yyyy') InvDate,SUM(NetValue) OrderValue , ROUND(SUM(CAST(P.Qty AS FLOAT) /prd.PcsInBox),1) [Qty(cases)]
	FROM
		(SELECT S.StoreID,P.InvDate , ROW_NUMBER() OVER(PARTITION BY P.StoreID ORDER BY P.invdate DESC) AS Rnk FROM tblP3MSalesDetail(nolock) P INNER JOIN #DSRStoreList S ON S.StoreID=P.StoreId 
		) A INNER JOIN tblP3MSalesDetail(nolock) P ON P.StoreId=A.StoreID AND P.InvDate=A.InvDate
		INNER JOIN tblPrdMstrSKULvl prd ON prd.NodeID=P.PrdNodeId
		WHERE A.Rnk<=5
		GROUP BY A.SToreID,P.invid,P.flgOrderSource,A.InvDate
		ORDER BY A.SToreID,P.invid,P.flgOrderSource,A.InvDate DESC

	SELECT A.StoreID,P.invid OrderID,P.flgOrderSource,A.PrdNodeId,FORMAT(A.InvDate,'dd-MMM-yyyy') InvDate,NetValue OrderValue ,ROUND(CAST(P.Qty AS FLOAT)/prd.PcsInBox,1) [Qty(cases)]
	FROM
	(SELECT S.StoreID,P.PrdNodeId,P.InvDate , ROW_NUMBER() OVER(PARTITION BY P.StoreID,P.invdate ORDER BY P.invdate DESC) AS Rnk FROM tblP3MSalesDetail(nolock) P INNER JOIN #DSRStoreList S ON S.StoreID=P.StoreId 
	) A INNER JOIN tblP3MSalesDetail(nolock) P ON P.StoreId=A.StoreID AND P.PrdNodeId=A.PrdNodeId AND P.InvDate=A.InvDate
	INNER JOIN tblPrdMstrSKULvl prd ON prd.NodeID=P.PrdNodeId
	WHERE A.Rnk<=5
	--GROUP BY A.SToreID,P.invid,P.flgOrderSource,A.PrdNodeId,A.InvDate
	ORDER BY A.SToreID,P.invid,A.InvDate DESC,A.PrdNodeId,P.flgOrderSource


END
