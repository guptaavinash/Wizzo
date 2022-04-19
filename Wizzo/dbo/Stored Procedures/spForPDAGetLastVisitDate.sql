
-- [spForPDAGetLastVisitDate] '05-Jan-2018' ,'354010084603910',17,170,1  
CREATE PROCEDURE [dbo].[spForPDAGetLastVisitDate] 
@Date varchar(50),
@PDACode VARCHAR(50),
@RouteID INT,
@RouteNodeType INT,
@flgAllRoutesData  TINYINT,  -- 1:to show all routes, 0: to show only given route 
@CoverageAreaNodeID INT = 0,
@CoverageAreaNodeType SMALLINT  =0
AS
BEGIN
	DECLARE @PersonID INT     
	DECLARE @PersonType INT  
	DECLARE @VisitDate Date
	--DECLARE @DeviceID INT
	
	SET @VisitDate=CONVERT(Date,@Date,105)

	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI   
	--SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@DeviceID  AND (GETDATE() BETWEEN DateFrom AND DateTo)
	 SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	-- Get the Default Route Assigned
	DECLARE @SalesAreaNodeID INT,@SalesAreaNodeType INT

	CREATE TABLE #CoverageArea (CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT) 

	INSERT INTO #CoverageArea(CoverageAreaNodeID,CoverageAreaNodeType)
	SELECT DISTINCT NodeID,NodeType FROM tblSalespersonmapping WHERE PersonNOdeID=@PersonID AND PersonType=@PersonType AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate 

	CREATE TABLE #Stores(RouteID INT,RouteNodeType INT,StoreID INT) 

	INSERT INTO #Stores
	SELECT DISTINCT RouteID,RouteNodeType,RM.Descr,RC.StoreId FROM tblRouteCoverageStoreMapping(nolock) RC INNER JOIN tblCompanySalesStructureRouteMstr(nolock) RM ON RM.NodeID=RC.RouteID AND RC.RouteNodeType=RM.NodeType
	INNER JOIN tblCompanySalesStructureHierarchy H  ON H.NodeID=RC.RouteID AND H.NodeType=RC.RouteNodeType
	INNER JOIN #CoverageArea C ON C.CoverageAreaNodeID=H.PNodeID AND C.CoverageAreaNodeType=H.PNodeType
	WHERE  CAST(GETDATE() AS DATE) BETWEEN RC.FromDate AND RC.ToDate

	--SELECT DISTINCT RouteNodeId,RouteNodeType,RC.StoreId FROM tblRouteCalendar RC WHERE RC.SONodeId=@PersonID AND RC.SONodeType=@PersonType AND VisitDate>=CAST(GETDATE() AS DATE)  

	--SELECT * FROM #Routes
	SELECT S.RouteID,S.RouteNodeType,S.StoreID,MAX(InvDate) MaxInvDate INTO [#LastVisit] FROM tblP3MSalesDetail P INNER JOIN #Stores S ON S.StoreID=P.StoreId GROUP BY S.RouteID,S.RouteNodeType,S.StoreID

	Select RouteId,RouteNodeType, StoreID, REPLACE(CONVERT(VARCHAR,MaxInvDate,106),' ','-') AS VIsitDate, 1 AS flgOrder
	FROM [#LastVisit] 

END







