


--[spForPDAGetPendingInvoices]'358312063112236'  
CREATE PROCEDURE [dbo].[spForPDAGetPendingInvoices]  
@PDACode VARCHAR(50),
@CoverageAreaNodeID INT = 0,
@CoverageAreaNodeType SMALLINT  =0    
  
AS    
	--DECLARE @PDAID INT  
	DECLARE @SalesNodeID INT 
	DECLARE @SalesNodetype SMALLINT

	DECLARE @PersonID INT,@PersonType SMALLINT
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	--SELECT @PDAID=PDAID FROM tblPDAMaster WHERE PDA_IMEI=@PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI  

	SELECT NodeType INTO #RouteNodeTypes FROM [dbo].[tblSecMenuContextMenu] WHERE flgRoute=1
	--SELECT NodeType INTO #CoverageAreaNodeTypes FROM [dbo].[tblSecMenuContextMenu] WHERE flgCoverageArea=1
	
	/* commented by gaurav on 5-Jan-18 as not being used
	SELECT S.NodeID,S.NodeType INTO #CoverageArea  FROM tblSalesPersonMapping S INNER JOIN #CoverageAreaNodeTypes C ON C.NodeType=S.NodeType 
	INNER JOIN tblPDA_UserMapMaster PU ON PU.PersonID=S.PersonNodeID AND PU.PersonType=S.PersonType
	WHERE PU.PDAID=@PDAID
	AND (GETDATE() BETWEEN PU.DateFrom AND PU.DateTo) AND (GETDATE() BETWEEN S.FromDate AND S.ToDate)
	--SELECT * FROM #CoverageArea

	CREATE TABLE #Distributor( NodeID INT,NodeType SMALLINT,DBRNAme VARCHAR(200))
	IF (SELECT HierTypeID FROM [tblSecMenuContextMenu] WHERE NodeType IN (SELECT NodeType FROM #CoverageArea))=2
	BEGIN
		INSERT INTO #Distributor(NodeID,NodeType,DBRNAme)
		SELECT DISTINCT DHNodeID,DHNodeType,DBR.Descr FROM [dbo].[tblCompanySalesStructure_DistributorMapping] D INNER JOIN #CoverageArea C ON C.NodeID=D.SHNodeID AND C.NodeType=D.SHNodeType 
		INNER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=DHNodeID AND DBR.NodeType=DHNodeType
		WHERE GETDATE() BETWEEN D.FromDate AND D.ToDate
	END
	ELSE
	BEGIN
		INSERT INTO #Distributor(NodeID,NodeType,DBRNAme)
		SELECT  DISTINCT DBRNodeID,DistributorNodeType,Distributor FROM VwAllDistributorHierarchy V INNER JOIN #CoverageArea C ON C.NodeID=V.DBRCoverageID AND C.NodeType=V.DBRCoverageNodeType 
	END
	*/
	PRINT 'A1'
	SELECT DISTINCT @SalesNodeID=P.NodeID,@SalesNodetype=P.NodeType --INTO #Routes 
	FROM tblSalesPersonMapping P  
	INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
	--INNER JOIN tblPDAMaster PDA ON PDA.PDAID=M.PDAID
	WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
	ORDER BY P.NodeType DESC

	CREATE TABLE #Routes(RouteID INT,NodeType SMALLINT,RouteName VARCHAR(200))
	----INSERT INTO #Routes(RouteID,NodeType)
	----SELECT SP.NodeID RouteID,SP.NodeType 
	----FROM  tblSalesPersonMapping SP   
	----INNER JOIN #RouteNodeTypes R ON SP.NodeType=R.NodeType
	----WHERE SP.PersonNodeID=@PersonID AND SP.PersonType=@PersonType AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate) 
	----UNION
	----SELECT DISTINCT DBRRouteID,RouteNodeType
	----FROM  VwDistributorDSRFullDetail V WHERE SOAreaID=@SalesNodeID AND SOAreaNodeType=@SalesNodetype AND V.DBRCoverageID>0
	----UNION
	----SELECT DISTINCT DSRRouteNodeID,DSRRouteNodeType
	----FROM VwCompanyDSRFullDetail V WHERE SOAreaID=@SalesNodeID AND SOAreaNodeType=@SalesNodetype AND V.DSRAreaID>0

	INSERT INTO #Routes
	SELECT distinct CH.NodeID,CH.NodeType,RM.Descr
	FROM tblSalesPersonMapping P
	INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
	INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
	INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
	INNER JOIN tblCompanySalesStructureRoute RM ON RM.NodeID=CH.NodeID AND CH.NodeType=RM.NodeType
	WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))

	SELECT DISTINCT RouteNodeId,RouteNodeType,RM.Descr FROM tblRouteCalendar RC INNER JOIN tblCompanySalesStructureRoute RM ON RM.NodeID=RC.RouteNodeId AND RC.RouteNodeType=RM.NodeType WHERE RC.SONodeId=@PersonID AND RC.SONodeType=@PersonType 
	 
	PRINT 'A'
	
	UPDATE R SET RouteName=RM.Descr FROM #Routes R INNER JOIN tblCompanySalesStructureRouteMstr RM ON RM.NodeID=R.RouteID AND RM.NodeType=R.NodeType
	--UPDATE R SET RouteName=RM.Descr FROM #Routes R INNER JOIN tblDBRSalesStructureRouteMstr RM ON RM.NodeID=R.RouteID AND RM.NodeType=R.NodeType
   
  
	SELECT DISTINCT SM.StoreID, SM.StoreName AS StoreName, #Routes.RouteID, #Routes.NodeType RouteNodeType,#Routes.RouteName AS RouteName,DBR.NodeID AS DistID, REPLACE(DBR.Descr,'&','and') AS DistName, [dbo].[fncSetDateFormat](OM.OrderDate) AS InvoiceForDate, 0 AS flgSubmit, OM.OrderID  
	FROM tblStoreMaster SM INNER JOIN  tblOrderMaster OM ON SM.StoreID = OM.StoreID  
	--INNER JOIN  tblVisitMaster VM ON VM.VisitID = OM.VisitID  
	INNER JOIN  #Routes ON #Routes.RouteID=OM.RouteNodeId AND #Routes.NodeType=OM.RouteNodeType --CROSS JOIN  #Distributor D    
    INNER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=SM.DBID AND DBR.NodeType=SM.DBNodeType
	WHERE (OM.TotOrderVal > 0) AND DATEDIFF(dd,OM.OrderDate,GETDATE())<=14 aND OM.OrderStatusID=1  
	----UNION
	----SELECT DISTINCT SM.StoreID, SM.StoreName AS StoreName, #Routes.RouteID, #Routes.NodeType RouteNodeType,#Routes.RouteName AS RouteName,DBR.NodeID AS DistID, REPLACE(DBR.Descr,'&','and') AS DistName, [dbo].[fncSetDateFormat](OM.OrderDate) AS InvoiceForDate, 0 AS flgSubmit, OM.OrderID  
	----FROM tblStoreMaster SM INNER JOIN  tblOrderMaster OM ON SM.StoreID = OM.StoreID  
	------INNER JOIN  tblVisitMaster VM ON VM.VisitID = OM.VisitID  
	----INNER JOIN  #Routes ON #Routes.RouteID=OM.RouteNodeId AND #Routes.NodeType=OM.RouteNodeType --CROSS JOIN  #Distributor D    
 ----   INNER JOIN tblWarehouseMstr DBR ON DBR.NodeID=SM.DBID AND DBR.NodeType=SM.DBNodeType
	----WHERE (OM.TotOrderVal > 0) AND DATEDIFF(dd,OM.OrderDate,GETDATE())<=14 aND OM.OrderStatusID=1 
	ORDER BY StoreName, DistName  
  
  
  



