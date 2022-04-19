
--[spForPDAGetExecutionSummary]'15-Sep-2017','869770027958550',78,170,1
CREATE PROCEDURE [dbo].[spForPDAGetExecutionSummary]     
@Date varchar(50),  
@PDACode VARCHAR(50),
@RouteID INT,
@RouteNodeType INT,
@flgAllRoutesData  TINYINT , -- 1:to show all routes, 0: to show only given route  
@CoverageAreaNodeID INT = 0,
@CoverageAreaNodeType SMALLINT  =0

AS    

BEGIN    
    DECLARE @VisitDate Date
	DECLARE @DeviceID INT, @AppVersionID INT, @RouteVisitID INT,@LastVisitDtOfMerchandiser INT  

	SET @VisitDate=CONVERT(Date,@Date,105)

	--SELECT @LastVisitDtOfMerchandiser = MAX(CONVERT(VARCHAR,convert(datetime,VisitDate,105),112)) FROM tblVisitMaster WHERE RouteID = @RouteID  

	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI  
	DECLARE @PersonID INT,@PersonType SMALLINT
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

	CREATE TABLE #tblOutletList (StoreID int)  
	CREATE TABLE #tblOutletOrder (StoreID int, OrderDate DATE)  
	CREATE TABLE #Routes(RouteID INT,RouteNodeType INT) 

	INSERT INTO #Routes(RouteID,RouteNodeType)
	SELECT DISTINCT  RouteNodeId,RouteNodetype FROM tblRoutePlanningVisitDetail RP INNER JOIN #CoverageArea C ON C.NodeID=RP.CovAreaNodeID AND C.NodeType=RP.CovAreaNodeType 
	
	----IF @CoverageAreaNodeID>0 AND @coverageAreaNodeType>0   --- Need the Route list for the DSR.
	----BEGIN
	----	INSERT INTO #Routes(RouteID,RouteNodeType)
	----	SELECT DISTINCT DBRRouteID,RouteNodeType
	----	FROM  VwDistributorDSRFullDetail V WHERE DBRCoverageID=@CoverageAreaNodeID AND DBRCoverageNodeType=@coverageAreaNodeType AND V.DBRCoverageID>0
	----	UNION
	----	SELECT DISTINCT DSRRouteNodeID,DSRRouteNodeType
	----	FROM VwCompanyDSRFullDetail V WHERE DSRAreaID=@CoverageAreaNodeID AND DSRAreaNodeType=@coverageAreaNodeType AND V.DSRAreaID>0
	----END
	----ELSE
	----BEGIN
	----	IF @flgAllRoutesData=1
	----	BEGIN
	----		INSERT INTO #Routes(RouteId,RouteNodeType)
	----		SELECT distinct CH.NodeID,CH.NodeType 
	----		FROM tblSalesPersonMapping P
	----		INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
	----		INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
	----		INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
	----		WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
	----	END
	----	ELSE
	----	BEGIN
	----		INSERT INTO #Routes(RouteId,RouteNodeType)
	----		SELECT @RouteID,@RouteNodeType
	----	END
	----END

	


	--SELECT DISTINCT RouteNodeId,RouteNodeType FROM tblRouteCalendar RC INNER JOIN tblCompanySalesStructureRoute RM ON RM.NodeID=RC.RouteNodeId AND RC.RouteNodeType=RM.NodeType WHERE RC.SONodeId=@PersonID AND RC.SONodeType=@PersonType 

    --SELECT * FROM #Routes

	SELECT @LastVisitDtOfMerchandiser = MAX(CONVERT(VARCHAR,convert(datetime,VisitDate,105),112)) 
	FROM tblVisitMaster V INNER JOIN #Routes R ON V.RouteID=R.RouteId AND V.RouteType=R.RouteNodeType --WHERE RouteID = @RouteID  
	--SELECT @LastVisitDtOfMerchandiser

	INSERT INTO #tblOutletList (StoreID)  
	SELECT DISTINCT StoreID  
	FROM    tblRouteCoverageStoreMapping  RC INNER JOIN #Routes R ON RC.RouteID=R.RouteId AND RC.RouteNodeType=R.RouteNodeType
	WHERE  (@VisitDate BETWEEN Fromdate and Todate) -- AND (RouteID = @RouteID) AND (RouteNodeType = @RouteNodeType)	 
	UNION   
	SELECT DISTINCT RC.StoreID  
	FROM tblRouteCoverageStoreMapping RC INNER JOIN #Routes R ON RC.RouteID=R.RouteId AND RC.RouteNodeType=R.RouteNodeType 
	INNER JOIN  tblVisitMaster ON CONVERT(VARCHAR, CONVERT(datetime, tblVisitMaster.VisitDate, 105), 112) = @LastVisitDtOfMerchandiser  
	WHERE  (@VisitDate BETWEEN Fromdate and Todate)  AND (ISNULL(tblVisitMaster.flgOutletNextDay, 0) = 1)  -- AND (tblRouteCoverageStoreMapping.RouteID = @RouteID) AND (tblRouteCoverageStoreMapping.RouteNodeType = @RouteNodeType)
	--SELECT * FROM #tblOutletList
	

	INSERT INTO #tblOutletOrder  
	SELECT        tblOrderMaster.StoreID, MAX(OrderDate) AS OrderDate  
	FROM            tblOrderMaster JOIN #tblOutletList ON #tblOutletList.StoreID = tblOrderMaster.StoreID 
	WHERE DATEDIFF(DD,OrderDate,@VisitDate)<=90 
	GROUP BY tblOrderMaster.StoreID    

	INSERT INTO #tblOutletOrder  
	SELECT        tblOrderMaster.StoreID, MAX(tblOrderMaster.OrderDate) AS OrderDate  
	FROM            tblOrderMaster JOIN #tblOutletOrder ON tblOrderMaster.StoreID = #tblOutletOrder.StoreID AND  tblOrderMaster.OrderDate < #tblOutletOrder.OrderDate  
	WHERE DATEDIFF(DD,tblOrderMaster.OrderDate,@VisitDate)<=90 
	GROUP BY tblOrderMaster.StoreID    

	INSERT INTO #tblOutletOrder  
	SELECT  tblOrderMaster.StoreID, MAX(tblOrderMaster.OrderDate) AS OrderDate  
	FROM tblOrderMaster JOIN (SELECT StoreId,MIN(OrderDate) OrderDate FROM #tblOutletOrder GROUP BY StoreId) AA ON tblOrderMaster.StoreID = AA.StoreiD AND  tblOrderMaster.OrderDate < AA.OrderDate  
	WHERE DATEDIFF(DD,tblOrderMaster.OrderDate,@VisitDate)<=90 
	GROUP BY tblOrderMaster.StoreID  
	
	INSERT INTO #tblOutletOrder  
	SELECT  tblOrderMaster.StoreID, MAX(tblOrderMaster.OrderDate) AS OrderDate  
	FROM tblOrderMaster JOIN (SELECT StoreId,MIN(OrderDate) OrderDate FROM #tblOutletOrder GROUP BY StoreId) AA ON tblOrderMaster.StoreID = AA.StoreiD AND  tblOrderMaster.OrderDate < AA.OrderDate  
	WHERE DATEDIFF(DD,tblOrderMaster.OrderDate,@VisitDate)<=90 
	GROUP BY tblOrderMaster.StoreID  

	PRINT 1   

	SELECT DISTINCT tblOrderMaster.StoreID, 'O:' + FORMAT(tblOrderMaster.OrderDate,'dd-MM') + '|I:' + ISNULL(FORMAT(tblInvMaster.InvDate,'dd-MM'),'NA') AS OrderDate, tblOrderDetail.ProductID, tblOrderDetail.OrderQty,ISNULL(tblInvMaster.flgInvStatus,0) AS flgInvStatus, ISNULL(tblInvDetail.InvQty,0) AS ProductQty, VwSFAProductHierarchy.SKUShortDescr PrdName,tblOrderMaster.OrderDate AS OrderDate1,tblOrderMaster.RouteNodeId RouteId,tblOrderMaster.RouteNodeType--,'O:' + FORMAT(tblOrderMaster.OrderDate,'dd-MM') + '|I:' + ISNULL(FORMAT(tblInvMaster.InvDate,'dd-MM'),'NA') AS OrderDate1
	FROM    tblInvDetail RIGHT OUTER JOIN
            tblInvMaster ON tblInvDetail.InvID = tblInvMaster.InvID RIGHT OUTER JOIN
            tblOrderDetail INNER JOIN tblOrderMaster ON tblOrderDetail.OrderID = tblOrderMaster.OrderID ON tblInvDetail.ProductID = tblOrderDetail.ProductID AND 
            tblInvMaster.OrderID = tblOrderMaster.OrderID INNER JOIN
            [#tblOutletOrder] ON [#tblOutletOrder].StoreID = tblOrderMaster.StoreID AND [#tblOutletOrder].OrderDate = tblOrderMaster.OrderDate INNER JOIN
            VwSFAProductHierarchy ON tblOrderDetail.ProductID = VwSFAProductHierarchy.SKUNodeID
	ORDER BY tblOrderMaster.StoreID ,tblOrderMaster.OrderDate DESC

end  





