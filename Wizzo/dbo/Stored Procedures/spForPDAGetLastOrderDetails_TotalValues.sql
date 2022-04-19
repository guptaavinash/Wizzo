
--[spForPDAGetLastOrderDetails_TotalValues]'29-Nov-2017' ,'1234512345123452',540,170,1
CREATE PROCEDURE [dbo].[spForPDAGetLastOrderDetails_TotalValues]   
@Date varchar(50),  
@PDACode VARCHAR(50),
@RouteID INT,
@RouteNodeType INT,
@flgAllRoutesData  TINYINT,  -- 1:to show all routes, 0: to show only given route
@CoverageAreaNodeID INT = 0,
@CoverageAreaNodeType SMALLINT  =0 
AS  

BEGIN   

	PRINT 1  
	DECLARE @VisitDate Date
	--DECLARE @DeviceID INT

	SET @VisitDate=CONVERT(Date,@Date,105)
	
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI  
	DECLARE @PersonID INT,@PersonType SMALLINT

	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	CREATE TABLE #Routes(RouteID INT,RouteNodeType INT) 

	IF @CoverageAreaNodeID>0 AND @coverageAreaNodeType>0   --- Need the Route list for the DSR.
	BEGIN
		INSERT INTO #Routes(RouteID,RouteNodeType)
		----SELECT DISTINCT DBRRouteID,RouteNodeType
		----FROM  VwDistributorDSRFullDetail V WHERE DBRCoverageID=@CoverageAreaNodeID AND DBRCoverageNodeType=@coverageAreaNodeType AND V.DBRCoverageID>0
		----UNION
		SELECT DISTINCT DSRRouteNodeID,DSRRouteNodeType
		FROM VwCompanyDSRFullDetail V WHERE DSRAreaID=@CoverageAreaNodeID AND DSRAreaNodeType=@coverageAreaNodeType AND V.DSRAreaID>0
	END
	ELSE
	BEGIN
		IF @flgAllRoutesData=1
		BEGIN
			INSERT INTO #Routes(RouteId,RouteNodeType)
			SELECT DISTINCT P.NodeID,P.NodeType 
			FROM tblSalesPersonMapping P  
			INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
			WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		END
		ELSE
		BEGIN
			INSERT INTO #Routes(RouteId,RouteNodeType)
			SELECT @RouteID,@RouteNodeType
		END
	END  
    --SELECT * FROM #Routes

	

	SELECT  V.StoreID, MAX(V.VisitID) AS VisitID  INTO [#LastVisit]
	FROM tblVisitMaster V INNER JOIN  tblOrderMaster ON V.VisitID = tblOrderMaster.VisitID 
	INNER JOIN #Routes R ON V.RouteID=R.RouteId AND V.RouteType=R.RouteNodeType  
	WHERE  CAST(VisitDate AS DATE)<=@VisitDate -- AND (tblVisitMaster.RouteID = @RouteID) AND (tblVisitMaster.RouteType = @RouteNodeType)
	GROUP BY V.StoreID    

	SELECT  OM.StoreID, SUM(tblOrderDetail.NetLineOrderVal) AS NetLineOrderVal, tblOrderDetail.OrderID,OM.RouteNodeId RouteId,OM.RouteNodeType  INTO [#Order]  
	FROM [#LastVisit] AS A INNER JOIN  tblOrderMaster OM ON A.VisitID = OM.VisitID INNER JOIN  
    tblOrderDetail ON OM.OrderID = tblOrderDetail.OrderID  
	GROUP BY OM.StoreID, tblOrderDetail.OrderID ,OM.RouteNodeId,OM.RouteNodeType
	 

	SELECT  tblInvMaster.OrderID, SUM(tblInvDetail.InvQty*tblInvDetail.ProductRate) AS ExecutionValue  INTO [#Execcution]  
	FROM tblInvDetail RIGHT OUTER JOIN  tblInvMaster ON tblInvDetail.InvID = tblInvMaster.InvID  
	WHERE (tblInvMaster.OrderID IN (SELECT DISTINCT OrderID FROM [#Order]))  
	GROUP BY tblInvMaster.OrderID  


	SELECT  [#Order].StoreID, ROUND(CAST(ISNULL(NetLineOrderVal,0) AS DECIMAL(18,2)),2) AS OrderValue, ROUND(CAST(ISNULL(ExecutionValue,0) AS DECIMAL(18,2)),2)  AS ExecutionValue,[#Order].RouteId,[#Order].RouteNodeType 
	FROM    [#Order] LEFT OUTER JOIN  [#Execcution] ON [#Order].OrderID = [#Execcution].OrderID   
	ORDER By Storeid

  

  

--SELECT        vwPrdGetProductHierarchy.PrdName, tblVisitStock.StockDate, tblVisitStock.Qty, tblVisitStock.ProductID, StoreID  

--INTO              [#Stock]  

--FROM            [#LastVisit] AS A INNER JOIN  

--                         tblVisitStock ON A.VisitID = tblVisitStock.VisitID INNER JOIN  

--                         vwPrdGetProductHierarchy ON tblVisitStock.ProductID = vwPrdGetProductHierarchy.PrdNodeID  

  

  

--SELECT ISNULL(#Order.StoreID,#Stock.StoreID) AS StoreID, REPLACE(CONVERT(VARCHAR,ISNULL(OrderDate,StockDate),106),' ','-') AS Date, ISNULL(#Order.ProductID,#Stock.ProductID) AS SKUID,  

--ISNULL(OrderQty,0) AS [Order], ISNULL(#Order.Qty,0) AS Free, ISNULL(#Stock.Qty,0) AS Stock, ISNULL(#Order.PrdName, #Stock.PrdName) AS SKUName  

--FROM #Order FULL OUTER JOIN [#Stock] ON #Order.StoreID = [#Stock].StoreID AND #Order.ProductID = [#Stock].ProductID  

  

END  

  

  





