-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [SpGetDistributorStockReport] 4492,''
CREATE PROCEDURE [dbo].[SpGetDistributorStockReport] 
	@LoginId INT,
	@strSalesHierarchy VARCHAR(5000)=''
AS
BEGIN
	--SELECT * FROM VwSFAProductHierarchy
	--SELECT * FROM tblPrdMstrPackingUnits_ConversionUnits
	CREATE TABLE #Final(RSMAreaId INT,RSMAreaNodeType INT,[RSM Area] VARCHAR(200),StateHeadAreaNodeID INT,StateHeadAreaNodeType INT,StateHeadArea VARCHAR(200),	ASMAreaId INT,ASMAreaNodeType INT,[ASM Area] VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,[SO Area] VARCHAR(200),CoverageAreaId INT,CoverageAreaNodeType INT,CoverageArea VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,Salesman VARCHAR(200))
	
	CREATE TABLE #tmpRsltWithFullHierarchy(ZoneId INT,ZoneNodeType INT,Zone VARCHAR(200),RegionNodeId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,Salesman VARCHAR(200))

	INSERT INTO #tmpRsltWithFullHierarchy(ZoneId,ZoneNodeType,Zone,RegionNodeId,RegionNodeType,Region,
	ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea, RouteId,RouteNodeType,Route)
	EXEC [spRptGetFullSalesHierarchyBasedonLogin] @LoginId,0,0,@strSalesHierarchy

	UPDATE A SET A.SalesmanNodeId=MP.NodeId,A.SalesmanNodeType=Mp.NodeType,A.Salesman=ISNULL(MP.Descr,'Vacant')
	FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping(nolock) SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)
	LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID

	INSERT INTO #Final(RSMAreaId,RSMAreaNodeType,[RSM Area],StateHeadAreaNodeID,StateHeadAreaNodeType,StateHeadArea,ASMAreaId,ASMAreaNodeType,[ASM Area],SOAreaId,SOAreaNodeType,[SO Area],CoverageAreaId,CoverageAreaNodeType,CoverageArea, SalesmanNodeId,SalesmanNodeType,Salesman)
	SELECT DISTINCT ZoneId,ZoneNodeType,Zone,RegionNodeId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea,SalesmanNodeId,SalesmanNodeType, Salesman 
	FROM #tmpRsltWithFullHierarchy   WHERE ISNULL(RouteId,0)>0

	

	--SELECT * FROM #Final

	SELECT F.[RSM Area],F.StateHeadArea,F.[ASM Area],F.[SO Area],P.Code,P.Descr Salesman,D.DistributorCode,D.Descr Distributor,FORMAT(StockDate,'dd-MMM-yyyy') StockDate,V.Category,CAST(V.UOMValue AS VARCHAR) + 'Gram' [Secondary Category],V.SKUCode [Product ErpID],V.SKUShortDescr,PS.StandardRate PTD,StockQty [Stock(Pcs)],CAST(ROUND(StockQty/RelConversionUnits,0) AS INT) [Stock(Case)],CAST(ROUND(StockQty * PS.StandardRate,0) AS INT) [Stock(Value in Lacs)]
	FROM [tblDistributorStockDet] DS INNER JOIN tblDBRSalesStructureDBR D ON D.NodeID=DS.CustomerNodeID AND D.NodeType=DS.CustomerNodeType INNER JOIN VwSFAProductHierarchy V ON V.SKUNodeID=DS.ProductNodeID AND V.SKUNodeType=DS.ProductNodeType 
	INNER JOIN tblMstrPerson P ON P.NodeID=DS.PersonNodeid AND P.NodeType=DS.PersonNodeType
	INNER JOIN #Final F ON F.SalesmanNodeId=P.NodeID
	INNER JOIN tblPrdMstrPackingUnits_ConversionUnits C ON C.SKUId=V.SKUNodeID AND C.BaseUOMID=3
	INNER JOIN [dbo].[tblPriceRegionMstr] PR ON PR.StateID=D.StateId 
	LEFT OUTER JOIN tblPrdSKUSalesMapping PS ON PS.SKUNodeId=V.SKUNodeID AND PS.SKUNodeType=V.SKUNodeType
	AND StockDate BETWEEN PS.FromDate AND PS.ToDate
	AND PS.PrcLocationId=PR.PrcRgnNodeId
	ORDER BY DistributorCode,StockDate,Category,SKUShortDescr
END
