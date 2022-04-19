-- =============================================
-- Author:		Avinash Gupta
-- Create date: 18-JUl-2017
-- Description:	
-- ============================================
-- [SpGetDSRRoutesDetUnderSO] '9C34A784-42D1-42EC-B129-973F8C56906C','05-Apr-2021'

CREATE PROCEDURE [dbo].[SpGetDSRRoutesDetUnderSO] --'359670066016988'
	 @IMENumber VARCHAR(50),
	 @Date Date 
AS
BEGIN
	----DECLARE @DeviceID INT      
	----SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMENumber OR PDA_IMEI_Sec=@IMENumber      
 ----   PRINT @DeviceID
	DECLARE @DayofWeek INT 

	DECLARE @PersonID INT
	DECLARE @PersonNodetype SMALLINT

	SET DATEFirst 1  
	SELECT @DayofWeek = datepart(dw,@Date)   
	PRINT '@DayofWeek=' + CAST(ISNULL(@DayofWeek,0) AS VARCHAR)
	SET DATEFirst 7  

	SELECT @PersonID=NodeID,@PersonNodetype=NodeType FROM dbo.fnGetPersonIDfromPDACode(@IMENumber) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	PRINT '@PersonID=' + CAST(@PersonID AS VARCHAR)
	PRINT '@PersonNodetype=' + CAST(@PersonNodetype AS VARCHAR)

	SELECT RouteID,RouteNodeType,DistNodeId,DistNodeType INTO #RouteDBMap FROM tblRouteCoverageStoreMapping RM INNER JOIN tblStoreMaster SM ON SM.StoreID=RM.StoreID
	WHERE CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate 

	
	CREATE TABLE #DSRList(CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT,CoverageArea VARCHAR(500),PersonNodeID INT,PersonNodeType SMALLINT,PersonName VARCHAR(200),WorkingType TINYINT)

	CREATE TABLE #DSRRouteList (CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT,CoverageArea VARCHAR(500),PersonNodeID INT,
	PersonNodeType SMALLINT,PersonName VARCHAR(200),RouteNodeID INT,RouteNodeType SMALLINT,Route VARCHAR(500),flgDefaultRoute TINYINT DEFAULT 0,DBNodeID INT)

	----CREATE TABLE #RouteList (CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT,CoverageArea VARCHAR(500),PersonNodeID INT,
	----PersonNodeType SMALLINT,PersonName VARCHAR(200),RouteNodeID INT,RouteNodeType SMALLINT,Route VARCHAR(500),
	----Active TINYINT Default 0)
	
	INSERT INTO #DSRList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName,WorkingType)
	SELECT DISTINCT V.DSRAreaID,V.DSRAreaNodeType,V.DSRArea,ISNULL(SM.PersonNodeID,0),ISNULL(SM.PersonType,0),ISNULL(SPM.Descr,'Vacant'),2 
	FROM tblSalesPersonMapping P INNER JOIN [dbo].[VwCompanySalesHierarchy] V ON V.ASMAreaID=P.NodeID AND V.ASMAreaNodeType=P.NodeType 
	INNER JOIN tblMstrPerson PM ON PM.NodeID=P.PersonNodeID AND PM.NodeType=P.PersonType
	LEFT OUTER JOIN tblSalesPersonMapping SM ON SM.NodeID=V.DSRAreaID AND SM.NodeType=V.DSRAreaNodeType
	LEFT OUTER JOIN tblMstrPerson SPM ON SPM.NodeID=SM.PersonNodeID AND SPM.NodeType=SM.PersonType
	WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonNodetype AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) AND (GETDATE() BETWEEN SM.FromDate AND ISNULL(SM.ToDate,GETDATE())) --AND SPM.flgSFAUser=1

	
	
	

	INSERT INTO #DSRRouteList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,RouteNodeID,RouteNodeType,Route)
	SELECT DISTINCT  C.CoverageAreaNodeID,C.CoverageAreaNodeType,C.CoverageArea,RP.DSENodeId,RP.DSENodeType,RouteNodeId,RouteNodetype,ISNULL(RM.Code,'') + '-' +RM.Descr FROM tblRoutePlanningVisitDetail RP INNER JOIN #DSRList C ON C.CoverageAreaNodeID=RP.CovAreaNodeID AND C.CoverageAreaNodeType=RP.CovAreaNodeType INNER JOIN tblCompanySalesStructureRouteMstr RM ON RM.NodeID=RP.RouteNodeId AND RM.NodeType=RP.RouteNodetype


	UPDATE R SET DBNodeID=M.DistNodeId FROM #DSRRouteList R INNER JOIN #RouteDBMap M ON M.RouteID=R.RouteNodeID AND M.RouteNodeType=R.RouteNodeType

	

	UPDATE A SET flgDefaultRoute=1 FROM #DSRRouteList A INNER JOIN tblRoutePlanningVisitDetail R ON R.RouteNodeID=A.RouteNodeID AND R.RouteNodetype=A.RouteNodeType AND CAST(VisitDate AS DATE)=CAST(@Date AS DATE)

	
	 SELECT * FROM #DSRList
	 SELECT DISTINCT CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName,RouteNodeID,RouteNodeType,Route,flgDefaultRoute AS Active,DBNodeID FROM #DSRRouteList



END
