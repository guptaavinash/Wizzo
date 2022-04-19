-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[spRptGetFullSalesHierarchyBasedonLogin_tocheck]15118,0,0,''
CREATE PROCEDURE [dbo].[spRptGetFullSalesHierarchyBasedonLogin_tocheck] 
@LoginId INT,
@NodeId int=0,
@NodeType int=0,
@strSalesHierarchy VARCHAR(5000)=''	--PNodeId^PNodeType^NodeId^NodeType^|
AS
BEGIN
	DECLARE @SalesAreaNodeType INT=0
	DECLARE @LoginUserID INT=0
	DECLARE @LoginPersonID INT=0
	CREATE TABLE #ApplicableSalesArea(AreaNodeId INT,AreaNodeType INT)

	IF @strSalesHierarchy<>''
	BEGIN
		DECLARE @TempStr VARCHAR(5000)=''
		DECLARE @PNodeId INT
		DECLARE @PNodeType INT
		DECLARE @PPNodeId INT
		DECLARE @PPNodeType INT

		WHILE (PATINDEX('%|%',@strSalesHierarchy)>0)  
		BEGIN  
			SELECT @TempStr = SUBSTRING(@strSalesHierarchy,0, PATINDEX('%|%',@strSalesHierarchy))  
			SELECT @strSalesHierarchy = SUBSTRING(@strSalesHierarchy,PATINDEX('%|%',@strSalesHierarchy)+1, LEN(@strSalesHierarchy))
		   		
			SELECT @PPNodeId= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))
			SELECT @TempStr = SUBSTRING(@TempStr, PATINDEX('%^%',@TempStr) + 1 , LEN(@TempStr))
			SELECT @PPNodeType= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))
			SELECT @TempStr = SUBSTRING(@TempStr, PATINDEX('%^%',@TempStr) + 1 , LEN(@TempStr))
			SELECT @PNodeId= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))
			SELECT @TempStr = SUBSTRING(@TempStr, PATINDEX('%^%',@TempStr) + 1 , LEN(@TempStr))
			SELECT @PNodeType= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))
			SELECT @TempStr = SUBSTRING(@TempStr, PATINDEX('%^%',@TempStr) + 1 , LEN(@TempStr))
			SELECT @NodeId= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))
			SELECT @TempStr = SUBSTRING(@TempStr, PATINDEX('%^%',@TempStr) + 1 , LEN(@TempStr))
			SELECT @NodeType= SUBSTRING(@TempStr,0, PATINDEX('%^%',@TempStr))

			INSERT INTO #ApplicableSalesArea(AreaNodeId,AreaNodeType)
			SELECT @NodeId,@NodeType
		END
		--SELECT * FROM #ApplicableSalesArea
	END
	ELSE IF @NodeType<>0
	BEGIN
		INSERT INTO #ApplicableSalesArea(AreaNodeId,AreaNodeType)
		VALUES(@NodeId,@NodeType)
		--SELECT * FROM #ApplicableSalesArea
	END
	ELSE IF @LoginID>0
	BEGIN
		SELECT @LoginUserID=UserID FROM tblSecUserLogin WHERE LoginID=@LoginID
		--SELECT @LoginUserID
	
		IF ISNULL(@LoginUserID,0)>0
		BEGIN
			SELECT @LoginPersonID=NodeId FROM tblsecuser WHERE UserId=@LoginUserID
						
			IF ISNULL(@LoginPersonID,0)>0
			BEGIN
				INSERT INTO #ApplicableSalesArea(AreaNodeId,AreaNodeType)
				SELECT DISTINCT NodeID,NodeType
				FROM tblSalesPersonMapping 
				WHERE PersonNodeID=@LoginPersonID AND (CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate)
			END			
		END
		--SELECT * FROM #ApplicableSalesArea
	END
	
	SELECT @SalesAreaNodeType=MIN(AreaNodeType) FROM #ApplicableSalesArea
	SELECT @SalesAreaNodeType=ISNULL(@SalesAreaNodeType,0)
	--SELECT * FROM #ApplicableSalesArea
	--SELECT @SalesAreaNodeType

	CREATE TABLE #FullSalesHierMaster(ZoneID INT,ZonenNodeType INT,Zone VARCHAR(200),RegionID INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200))

	SELECT DISTINCT V.*,R.NodeID Routeid,R.NodeType RouteType,R.Descr Route INTO #SalesHier FROM VwCompanyDSRFullDetail	V INNER JOIN tblCompanySalesStructureHierarchy H ON H.PNodeID=V.DSRAreaID AND H.PNodeType=V.DSRAreaNodeType INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=H.NodeID AND R.NodeType=H.NodeType


	--SELECT * FROM #SalesHier

	--IF @SalesAreaNodeType=0
	--BEGIN
	--	DELETE A FROM #SalesHier A
	--END
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
