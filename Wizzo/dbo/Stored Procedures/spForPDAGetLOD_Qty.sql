
--exec [spForPDAGetLOD_Qty] '05-Jan-2018' ,'354010084603910',17,170,1  
CREATE PROCEDURE [dbo].[spForPDAGetLOD_Qty] 
@Date varchar(50),
@PDACode VARCHAR(50),
@RouteID INT,
@RouteNodeType INT,
@flgAllRoutesData  TINYINT,  -- 1:to show all routes, 0: to show only given route 
@CoverageAreaNodeID INT = 0,
@CoverageAreaNodeType SMALLINT  =0
AS
BEGIN
	DECLARE @VisitDate Date
	--DECLARE @DeviceID INT

	SET @VisitDate=CONVERT(Date,@Date,105)

	PRINT 1
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI   
	DECLARE @PersonNodeID INT,@PersonType SMALLINT
	SELECT @PersonNodeID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	
	CREATE TABLE #Routes(RouteID INT,RouteNodeType INT) 
	
	IF @CoverageAreaNodeID>0 AND @coverageAreaNodeType>0   --- Need the Route list for the DSR.
	BEGIN
		INSERT INTO #Routes(RouteID,RouteNodeType)
		--SELECT DISTINCT DBRRouteID,RouteNodeType
		--FROM  VwDistributorDSRFullDetail V WHERE DBRCoverageID=@CoverageAreaNodeID AND DBRCoverageNodeType=@coverageAreaNodeType AND V.DBRCoverageID>0
		--UNION
		SELECT DISTINCT DSRRouteNodeID,DSRRouteNodeType
		FROM VwCompanyDSRFullDetail V WHERE DSRAreaID=@CoverageAreaNodeID AND DSRAreaNodeType=@coverageAreaNodeType AND V.DSRAreaID>0
	END
	ELSE
	BEGIN
		IF @flgAllRoutesData=1
		BEGIN
			INSERT INTO #Routes(RouteId,RouteNodeType)
			SELECT DISTINCT P.NodeID,P.NodeType --INTO #Routes 
			FROM tblSalesPersonMapping P 
			INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
			WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonNodeID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		END
		ELSE
		BEGIN
			INSERT INTO #Routes(NodeId,NodeType)
			SELECT @RouteID,@RouteNodeType
		END
	END


	SELECT V.StoreID,V.VisitID,V.RouteId,V.RouteType RouteNodeType INTO [#LastVisit]
	FROM tblVisitMaster V INNER JOIN tblOrderMaster ON V.VisitID = tblOrderMaster.VisitID
	INNER JOIN #Routes R ON V.RouteId=R.RouteID AND V.RouteType=R.RouteNodeType
	WHERE CAST(VisitDate AS DATE)<=@VisitDate    
	

	SELECT  tblOrderMaster_1.StoreID, tblOrderDetail.ProductID AS SKUID, REPLACE(CONVERT(VARCHAR, tblOrderMaster_1.OrderDate, 106), ' ', '-') AS Date,tblOrderDetail.OrderQty AS Qty,	tblPrdMstrSKULvl.ShortDescr AS SKUName--, tblStoreMaster.StoreName,tblOrderMaster_1.RouteNodeId AS RouteId,tblOrderMaster_1.RouteNodeType
	FROM tblOrderDetail INNER JOIN tblOrderMaster AS tblOrderMaster_1 ON tblOrderDetail.OrderID = tblOrderMaster_1.OrderID INNER JOIN
    (SELECT tblOrderMaster.StoreID, MAX(tblOrderMaster.OrderDate) AS OrderDate, tblOrderDetail_1.ProductID FROM [#LastVisit] AS A INNER JOIN
            tblOrderMaster ON A.VisitID = tblOrderMaster.VisitID INNER JOIN tblOrderDetail AS tblOrderDetail_1 ON tblOrderMaster.OrderID = tblOrderDetail_1.OrderID
            GROUP BY tblOrderMaster.StoreID, tblOrderDetail_1.ProductID) AS derivedtbl_1 ON tblOrderMaster_1.StoreID = derivedtbl_1.StoreID AND 
    tblOrderDetail.ProductID = derivedtbl_1.ProductID AND tblOrderMaster_1.OrderDate = derivedtbl_1.OrderDate INNER JOIN
    tblPrdMstrSKULvl ON tblOrderDetail.ProductID = tblPrdMstrSKULvl.NodeID INNER JOIN
	--VwProductHierarchy ON tblOrderDetail.ProductID = VwProductHierarchy.SKUNodeID INNER JOIN
    tblStoreMaster ON tblOrderMaster_1.StoreID = tblStoreMaster.StoreID

END








