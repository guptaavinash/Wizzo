
-- [spForPDAGetLastVisitDetails] '20-Aug-2018' ,'354010084603910',17,170,1   
CREATE PROCEDURE [dbo].[spForPDAGetLastVisitDetails]   
@Date varchar(50),  
@PDACode VARCHAR(50),  
@RouteID INT,
@RouteNodeType INT  ,
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
		
	CREATE TABLE #Stores(RouteID INT,RouteNodeType INT,StoreID INT)

	CREATE TABLE #CoverageArea (CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT) 

	INSERT INTO #CoverageArea(CoverageAreaNodeID,CoverageAreaNodeType)
	SELECT DISTINCT NodeID,NodeType FROM tblSalespersonmapping WHERE PersonNOdeID=@PersonID AND PersonType=@PersonType AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate 

	INSERT INTO #Stores
	SELECT DISTINCT RouteID,RouteNodeType,RC.StoreId FROM tblRouteCoverageStoreMapping(nolock) RC INNER JOIN tblCompanySalesStructureRouteMstr(nolock) RM ON RM.NodeID=RC.RouteID AND RC.RouteNodeType=RM.NodeType
	INNER JOIN tblCompanySalesStructureHierarchy H  ON H.NodeID=RC.RouteID AND H.NodeType=RC.RouteNodeType
	INNER JOIN #CoverageArea C ON C.CoverageAreaNodeID=H.PNodeID AND C.CoverageAreaNodeType=H.PNodeType
	WHERE  CAST(GETDATE() AS DATE) BETWEEN RC.FromDate AND RC.ToDate

	----SELECT DISTINCT RouteNodeId,RouteNodeType,RC.StoreId FROM tblRouteCalendar RC WHERE RC.SONodeId=@PersonID AND RC.SONodeType=@PersonType AND VisitDate>=CAST(GETDATE() AS DATE)  

	--SELECT * FROM #Routes
	SELECT S.RouteID,S.RouteNodeType,S.StoreID,MAX(InvDate) MaxInvDate INTO [#LastVisit] FROM tblP3MSalesDetail P INNER JOIN #Stores S ON S.StoreID=P.StoreId GROUP BY S.RouteID,S.RouteNodeType,S.StoreID
  
 
	SELECT OM.StoreID, OM.InvDate OrderDate, OM.PrdNodeId ProductID, OM.Qty OrderQty, PS.Descr PrdName,OM.InvId OrderID,OM.NetValue NetLineOrderVal, 0 AS VisitID ,A.RouteID AS RouteId,A.RouteNodeType,OM.InvNo InvoiceNumber INTO [#Order]  
	FROM [#LastVisit] AS A INNER JOIN  tblP3MSalesDetail OM ON A.MaxInvDate = OM.InvDate AND A.StoreID=OM.StoreId INNER JOIN  
	tblPrdMstrSKULvl PS ON OM.PrdNodeId = PS.NodeID 
	--LEFT OUTER JOIN tblPrdSizeMstr S ON S.NodeID=PS.SizeID
    --VwProductHierarchy ON tblOrderDetail.ProductID = VwProductHierarchy.SKUNodeID 
  
	CREATE TABLE [#Stock](PrdName VARCHAR(500),StockDate Date,Qty Float,ProductID INT,StoreID INT)
	---- INSERT INTO [#Stock]
	----SELECT        VwProductHierarchy.SKUShortDescr PrdName, tblVisitStock.StockDate, tblVisitStock.Qty, tblVisitStock.ProductID, StoreID  
	----INTO              [#Stock]  
	----FROM            [#LastVisit] AS A INNER JOIN  
	----                         tblVisitStock ON A.VisitID = tblVisitStock.VisitID INNER JOIN  
	----                         VwProductHierarchy ON tblVisitStock.ProductID = VwProductHierarchy.SKUNodeID  
  
	----SELECT tblInvMaster.OrderId,tblInvMaster.InvCode ,tblInvMaster.InvID, tblInvMaster.flgInvStatus, tblInvDetail.ProductID, tblInvDetail.InvQty  ProductQty INTO [#Execcution]  
	----FROM tblInvDetail INNER JOIN  tblInvMaster ON tblInvDetail.InvID = tblInvMaster.InvID  INNER JOIN [#Order] O ON O.OrderID=tblInvMaster.OrderId
 
  
    
	----SELECT [#Order].RouteId,[#Order].RouteNodeType,[#Order].StoreID, [#Order].OrderDate, [#Order].ProductID, [#Order].OrderQty, [#Order].PrdName, [#Order].NetLineOrderVal, [#Execcution].ProductQty  
	----INTO #Order_Execution  
	----FROM [#Order] LEFT OUTER JOIN  [#Execcution] ON [#Order].OrderID = [#Execcution].OrderId AND [#Order].ProductID = [#Execcution].ProductID  
    
  
	SELECT DISTINCT ISNULL(A.StoreID,#Stock.StoreID) AS StoreID, REPLACE(CONVERT(VARCHAR,ISNULL(OrderDate,StockDate),106),' ','-') AS Date,   
ISNULL(OrderQty,0) AS [Order], ISNULL(#Stock.Qty,0) AS Stock, ISNULL(A.PrdName, #Stock.PrdName) AS SKUName, ISNULL(A.OrderQty,0) AS ExecutionQty,A.RouteId,A.RouteNodeType ,A.ProductID
	FROM [#Order] AS A FULL OUTER JOIN [#Stock] ON A.StoreID = [#Stock].StoreID AND A.ProductID = [#Stock].ProductID  
  
END  
  
  







