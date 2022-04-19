-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[spRptGetFullSalesHierarchyBasedonPDA] '5C895DAF-DCBD-4408-B701-93872C228260',0,0
CREATE PROCEDURE [dbo].[spRptGetFullSalesHierarchyBasedonPDA] 
@PDACode VARCHAR(50),
@NodeId int=0,
@NodeType int=0
AS
BEGIN
	DECLARE @SalesAreaNodeType INT=0
	DECLARE @PersonID INT     
	DECLARE @PersonType INT
	
	CREATE TABLE #ApplicableSalesArea(AreaNodeId INT,AreaNodeType INT)

	IF @NodeType<>0
	BEGIN
		INSERT INTO #ApplicableSalesArea(AreaNodeId,AreaNodeType)
		VALUES(@NodeId,@NodeType)
		--SELECT * FROM #ApplicableSalesArea
	END
	ELSE IF @PDACode<>''
	BEGIN
		 SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
		 PRINT 'PersonID=' + CAST(@PersonID AS VARCHAR)          
		 PRINT 'PersonType=' + CAST(@PersonType AS VARCHAR)
		  
		 INSERT INTO #ApplicableSalesArea
		 SELECT SM.NodeID,SM.NodeType FROM tblSalesPersonMapping SM INNER JOIN tblPMstNodeTypes M ON M.PersonType=SM.PersonType AND M.NodeType=SM.NodeType AND CAST(GETDATE() AS DATE) BETWEEN SM.FromDate AND SM.ToDate WHERE SM.PersonNodeID=@PersonID AND SM.PersonType=@PersonType
		--SELECT * FROM #ApplicableSalesArea
	END
	
	SELECT @SalesAreaNodeType=MIN(AreaNodeType) FROM #ApplicableSalesArea
	SELECT @SalesAreaNodeType=ISNULL(@SalesAreaNodeType,0)
	--SELECT * FROM #ApplicableSalesArea
	--SELECT @SalesAreaNodeType

	CREATE TABLE #FullSalesHierMaster(ZoneID INT,ZonenNodeType INT,Zone VARCHAR(200),RegionID INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200))

	SELECT DISTINCT V.*,R.NodeID Routeid,R.NodeType RouteType,R.Descr Route INTO #SalesHier FROM VwCompanyDSRFullDetail	V INNER JOIN tblCompanySalesStructureHierarchy H ON H.PNodeID=V.DSRAreaID AND H.PNodeType=V.DSRAreaNodeType INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=H.NodeID AND R.NodeType=H.NodeType
	--SELECT * FROM #SalesHier

	IF @SalesAreaNodeType=0
	BEGIN
		DELETE A FROM #SalesHier A
	END
	IF @SalesAreaNodeType=95
	BEGIN
		DELETE A FROM #SalesHier A LEFT OUTER JOIN #ApplicableSalesArea B ON A.RSMAreaID=B.AreaNodeId AND A.RSMAreaType=B.AreaNodeType 
		WHERE B.AreaNodeId IS NULL AND B.AreaNodeType IS NULL
	END
	ELSE IF @SalesAreaNodeType=100
	BEGIN
		DELETE A FROM #SalesHier A LEFT OUTER JOIN #ApplicableSalesArea B ON A.StateHeadAreaID=B.AreaNodeId AND A.StateHeadAreaNodeType=B.AreaNodeType 
		WHERE B.AreaNodeId IS NULL AND B.AreaNodeType IS NULL
	END
	ELSE IF @SalesAreaNodeType=110
	BEGIN
		DELETE A FROM #SalesHier A LEFT OUTER JOIN #ApplicableSalesArea B ON A.ASMAreaID=B.AreaNodeId AND A.ASMAreaNodeType=B.AreaNodeType 
		WHERE B.AreaNodeId IS NULL AND B.AreaNodeType IS NULL
	END
	ELSE IF @SalesAreaNodeType=120
	BEGIN
		DELETE A FROM #SalesHier A LEFT OUTER JOIN #ApplicableSalesArea B ON A.SOAreaID=B.AreaNodeId AND A.SOAreaNodeType=B.AreaNodeType 
		WHERE B.AreaNodeId IS NULL AND B.AreaNodeType IS NULL
	END
	ELSE IF @SalesAreaNodeType=130
	BEGIN
		DELETE A FROM #SalesHier A LEFT OUTER JOIN #ApplicableSalesArea B ON A.DSRAreaID=B.AreaNodeId AND A.DSRAreaNodeType=B.AreaNodeType 
		WHERE B.AreaNodeId IS NULL AND B.AreaNodeType IS NULL
	END
	--ELSE IF @SalesAreaNodeType=140
	--BEGIN
	--	DELETE A FROM #SalesHier A LEFT OUTER JOIN #ApplicableSalesArea B ON A.RouteID=B.AreaNodeId AND A.RouteType=B.AreaNodeType 
	--	WHERE B.AreaNodeId IS NULL AND B.AreaNodeType IS NULL
	--END
	--SELECT * FROM #SalesHier
	
	INSERT INTO #FullSalesHierMaster(ZoneID,ZonenNodeType,Zone,RegionID,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea,RouteId, RouteNodeType,Route)
	SELECT DISTINCT RSMAreaID,RSMAreaType,RSMArea,StateHeadAreaID,StateHeadAreaNodeType,StateHead,ASMAreaID,ASMAreaNodeType,ASMArea,SOAreaID,SOAreaNodeType,SOArea,DSRAreaID,DSRAreaNodeType,DSRArea,RouteID,RouteType,Route
	FROM #SalesHier

	
	SELECT * FROM #FullSalesHierMaster
END
