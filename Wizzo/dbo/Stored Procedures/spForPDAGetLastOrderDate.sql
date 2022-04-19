
-- [spForPDAGetLastOrderDate] '05-Jan-2018' ,'354010084603910',17,170,1 
CREATE PROCEDURE [dbo].[spForPDAGetLastOrderDate]    
@Date Date,    
@PDACode VARCHAR(50),    
@RouteID INT,
@RouteNodeType INT,
@flgAllRoutesData  TINYINT,  -- 1:to show all routes, 0: to show only given route  
@CoverageAreaNodeID INT = 0,
@CoverageAreaNodeType SMALLINT  =0    
AS 
	DECLARE @VisitDate Date
	--DECLARE @DeviceID INT
	
	--SET @VisitDate=CONVERT(Date,@Date,105)   
	SET @VisitDate=@Date  
	
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI  
	DECLARE @PersonID INT,@PersonType SMALLINT
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	Create TABLE #TmpForExecution(StoreID INT, OrderDate DATE, OrderID INT, flgExecutionSummary TINYINT,RouteId INT,RouteNodeType INT) 
	CREATE TABLE #Routes(RouteID INT,RouteNodeType INT) 

	IF @CoverageAreaNodeID>0 AND @coverageAreaNodeType>0   --- Need the Route list for the DSR.
	BEGIN
		INSERT INTO #Routes
		SELECT distinct CH.NodeID,CH.NodeType 
		FROM tblSalesPersonMapping P
		INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
		INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
		INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
		WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))

		--SELECT DISTINCT RouteNodeId,RouteNodeType FROM tblRouteCalendar RC INNER JOIN tblCompanySalesStructureRoute RM ON RM.NodeID=RC.RouteNodeId AND RC.RouteNodeType=RM.NodeType WHERE RC.SONodeId=@PersonID AND RC.SONodeType=@PersonType 
	END  


    --SELECT * FROM #Routes
	INSERT INTO #TmpForExecution(StoreID, OrderDate)    
	SELECT  A.StoreID, MAX(A.OrderDate) AS OrderDate
	FROM    tblOrderMaster AS A --INNER JOIN  tblVisitMaster V ON A.VisitID = V.VisitID
	INNER JOIN #Routes R ON A.RouteNodeID=R.RouteId AND A.RouteNodeType=R.RouteNodeType  
	WHERE CAST(A.OrderDate AS DATE)<=@VisitDate AND [NetOrderValue]>0
	GROUP BY A.StoreID  
    
    
	UPDATE #TmpForExecution SET OrderID = tblOrderMaster.OrderID,RouteId=tblOrderMaster.RouteNodeId,RouteNodeType=tblOrderMaster.RouteNodeType     
	FROM #TmpForExecution JOIN tblOrderMaster ON #TmpForExecution.StoreID = tblOrderMaster.StoreID AND #TmpForExecution.OrderDate = tblOrderMaster.OrderDate    
    
	----UPDATE #TmpForExecution SET flgExecutionSummary = tblInvMaster.flgInvStatus    
	----FROM #TmpForExecution JOIN tblInvMaster ON tblInvMaster.OrderID = #TmpForExecution.OrderID    
    
	SELECT RouteId,RouteNodeType,StoreID, REPLACE(CONVERT(VARCHAR,OrderDate,106),' ','-') AS OrderDate,ISNULL(flgExecutionSummary,0) AS flgExecutionSummary  
	FROM #TmpForExecution    




