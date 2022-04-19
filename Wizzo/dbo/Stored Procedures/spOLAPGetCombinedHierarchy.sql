


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [spOLAPGetCombinedHierarchy] 3442
CREATE PROCEDURE [dbo].[spOLAPGetCombinedHierarchy]
@LoginId INT=0,
@LastlvlNodeTypeToShow INT=0	--this is the nodetype to show sales hierarchy upto, i.e. if 0 then show full sales hierarchy, if 120 then show upto So Area

AS
BEGIN
	DECLARE @LoginPersonId INT=0
	DECLARE @LoginPersonType INT=0
	DECLARE @SalesAreaNodeType INT=0

	SELECT @LoginPersonId=A.NodeId,@LoginPersonType=A.NodeType
	FROM tblsecUser A INNER JOIN  tblSecUserLogin B ON A.UserId=B.UserId
	WHERE B.LoginId=@LoginId
	PRINT 'LoginPersonId-' + CAST(@LoginPersonId AS VARCHAR)
	PRINT 'LoginPersonType-' + CAST(@LoginPersonType AS VARCHAR)

	IF @LoginPersonId>0
	BEGIN
		SELECT @SalesAreaNodeType=ISNULL(MIN(SP.NodeType),0)
		FROM tblSalesPersonMapping SP
		WHERE SP.PersonNodeID=@LoginPersonId AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)
	END
	PRINT 'SalesAreaNodeType-' + CAST(@SalesAreaNodeType AS VARCHAR)
	--SELECT @SalesAreaNodeType
	CREATE TABLE #SalesAreas(SalesAreaNodeId INT,SalesAreaNodeType INT)

	INSERT INTO #SalesAreas(SalesAreaNodeId,SalesAreaNodeType)
	SELECT SP.NodeID,SP.NodeType
	FROM tblSalesPersonMapping SP
	WHERE SP.PersonNodeID=@LoginPersonId AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate) AND SP.NodeType=@SalesAreaNodeType

	--SELECT * FROM #SalesAreas

	CREATE TABLE #tmpRslt(HierId VARCHAR(50),PHierId VARCHAR(50),[Sales Area] VARCHAR(200),Lvl TINYINT,NodeType INT)
	
	SELECT * INTO #tmpRsltWithFullHierarchy FROM [tblOLAPFullSalesHierarchy]
	--SELECT * FROM #tmpRsltWithFullHierarchy
	IF @SalesAreaNodeType=95 --Zone
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE ZoneId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas)
	END
	ELSE IF @SalesAreaNodeType=100 --Region
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE RegionID NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas)
	END
	ELSE IF @SalesAreaNodeType=110 -- ASM
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE ASMAreaId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas)
	END
	ELSE IF @SalesAreaNodeType=120 --SO
	BEGIN
		DELETE FROM #tmpRsltWithFullHierarchy WHERE SOAreaId NOT IN(SELECT SalesAreaNodeId FROM #SalesAreas)
	END
	--SELECT * FROM #tmpRsltWithFullHierarchy ORDER BY ASMAreaId


	--ZONE
	IF @SalesAreaNodeType=0 OR @SalesAreaNodeType=95
	BEGIN
		INSERT INTO #tmpRslt(HierId,PHierId,[Sales Area],Lvl,NodeType)
		SELECT DISTINCT ZoneHierID,0,Zone,0,ZoneNodeType
		FROM #tmpRsltWithFullHierarchy
	END

	--Region
	IF @SalesAreaNodeType=0 OR @SalesAreaNodeType=95 OR @SalesAreaNodeType=100
	BEGIN
		INSERT INTO #tmpRslt(HierId,PHierId,[Sales Area],Lvl,NodeType)
		SELECT DISTINCT RegionHierID,ZoneHierID,Region,1,RegionNodeType
		FROM #tmpRsltWithFullHierarchy
	END


	--ASMA Area
	IF @SalesAreaNodeType=0 OR @SalesAreaNodeType=95 OR @SalesAreaNodeType=100 OR @SalesAreaNodeType=110
	BEGIN
		INSERT INTO #tmpRslt(HierId,PHierId,[Sales Area],Lvl,NodeType)
		SELECT DISTINCT ASMAreaHierID,RegionHierID,ASMArea,2,ASMAreaNodeType
		FROM #tmpRsltWithFullHierarchy
	END

	-- So Area
	INSERT INTO #tmpRslt(HierId,PHierId,[Sales Area],Lvl,NodeType)
	SELECT DISTINCT SOAreaHierID,ASMAreaHierID,SOArea,3,SOAreaNodeType	FROM #tmpRsltWithFullHierarchy


	 --DISTRIBUTOR
	INSERT INTO #tmpRslt(HierId,PHierId,[Sales Area],Lvl,NodeType)
	SELECT DISTINCT DBRHierID,SOAreaHierID,DBR,4,DBRNodeType FROM #tmpRsltWithFullHierarchy


	--Coverage Area
	INSERT INTO #tmpRslt(HierId,PHierId,[Sales Area],Lvl,NodeType)
	--SELECT DISTINCT CoverageAreaHierID,SOAreaHierID,CoverageArea,3,CoverageAreaNodeType FROM #tmpRsltWithFullHierarchy WHERE CoverageAreaID IS NOT NULL
	SELECT DISTINCT CoverageAreaHierID,DBRHierID,CoverageArea,5,CoverageAreaNodeType FROM #tmpRsltWithFullHierarchy WHERE CoverageAreaID IS NOT NULL

	----Route
	--INSERT INTO #tmpRslt(HierId,PHierId,[Sales Area],Lvl,NodeType)
	--SELECT DISTINCT RouteHierId,CoverageAreaHierID,Route,4,RouteNodeType FROM #tmpRsltWithFullHierarchy
	--WHERE RouteNodeId IS NOT NULL
	
	IF @LastlvlNodeTypeToShow>0
	BEGIN
		DELETE FROM #tmpRslt WHERE NodeType>@LastlvlNodeTypeToShow
	END
	--SELECT * FROM #tmpRslt ORDER BY NodeType
	IF NOT EXISTS(SELECT 1 FROM #tmpRslt WHERE PHierId='0')
	BEGIN
		DECLARE @FirstLvl TINYINT

		SELECT @FirstLvl=MIN(Lvl) FROM #tmpRslt
		--SELECT @FirstLvl

		UPDATE #tmpRslt SET PhierId='0' WHERE Lvl=@FirstLvl
	END

	SELECT HierId,PHierId,[Sales Area],Lvl
	FROM #tmpRslt where HierId<>PHierId
	ORDER BY Lvl

	SELECT MAX(Lvl) MaxLvl FROm #tmpRslt
END






