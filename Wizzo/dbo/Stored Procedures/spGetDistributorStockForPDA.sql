
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--declare @p4 dbo.udt_DBRWiseOrderList
--insert into @p4 values('0-32-150',N'OrdID-133587-eb7e4f2c54be-31-08-2017232943')
--insert into @p4 values('0-32-150',N'ljlkshkajdhkjhdkj')
--exec [spGetDistributorStockForPDA]'359473079352536',@p4
CREATE PROCEDURE [dbo].[spGetDistributorStockForPDA]
 @CustomerNodeID INT,              
 @CustomerNodeType SMALLINT,
@PDACode VARCHAR(50),
 @tblDBRWiseOrderList udt_DBRWiseOrderList READONLY,
 @CoverageAreaNodeID INT = 0,
@coverageAreaNodeType SMALLINT  =0
AS
BEGIN
	DECLARE @StockDate DATE=GETDATE()
	DECLARE @HierTypeID INT
	--DECLARE @DeviceID INT
	DECLARE @PersonID INT     
	DECLARE @PersonType INT    
	DECLARE @ChannelId INT=0

	CREATE TABLE #DBRList(CustomerNodeID INT,CustomerNodeType INT, ident int identity(1,1),StateID INT)

	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMEINO OR PDA_IMEI_Sec=@IMEINO
	-- PRINT '@DeviceID=' + CAST(ISNULL(@DeviceID,0) AS VARCHAR)

	-- SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@DeviceID  AND (GETDATE() BETWEEN DateFrom AND DateTo)
	 SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	 PRINT 'PersonID=' + CAST(@PersonID AS VARCHAR)          
	 PRINT 'PersonType=' + CAST(@PersonType AS VARCHAR)

	 -- to get coverage area list for the person
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
			PRINT 'AA GAYA'
			INSERT INTO  #CoverageArea
			SELECT DISTINCT V.DSRAreaID,V.DSRAreaNodeType  
			FROM tblSalesPersonMapping P INNER JOIN [dbo].[VwCompanySalesHierarchy] V ON V.ASMAreaID=P.NodeID AND V.ASMAreaNodeType=P.NodeType 
			WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		END
	END

	--SELECT * FROM #CoverageArea

	SELECT @HierTypeID=HierTypeID FROM [dbo].[tblSecMenuContextMenu] WHERE NodeType IN (SELECT TOP 1 NodeType FROM #CoverageArea)
	PRINT '@HierTypeID=' + CAST(ISNULL(@HierTypeID,0) AS VARCHAR)

	-- to get attached DBR list
	----IF @HierTypeID=5
	----BEGIN
	----	INSERT INTO #DBRList(CustomerNodeID,CustomerNodeType,StateID)
	----	SELECT DISTINCT A.DBRNodeID,A.DistributorNodeType,StateID
	----	FROM VwAllDistributorHierarchy A INNER JOIN #CoverageArea C on C.NodeId=A.DBRCoverageID AND C.NodeType=A.DBRCoverageNodeType	
	----END
	----ELSE
	BEGIN
		INSERT INTO #DBRList(CustomerNodeID,CustomerNodeType,StateID)
		SELECT Map.DHNodeId,DHNodeType,D.StateID  --INTO #DBRList
		FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN [dbo].[tblDBRSalesStructureDBR] D ON D.NodeID=Map.DHNodeID AND D.NodeType=Map.DHNodeType INNER JOIN #CoverageArea C ON Map.SHNodeId=C.NodeId AND Map.SHNodeType=C.NodeType
		WHERE DHNodeType=150 AND (GETDATE() BETWEEN Map.FromDate AND Map.ToDate)
	END
	--SELECT * FROM #DBRList

	 SELECT @ChannelId=A.ChannelID
	 from tblSalesHierChannelMapping A INNER JOIN #CoverageArea B ON A.SalesStructureNodID=B.NodeId AND A.SalesStructureNodType=B.NodeType
	 WHERE (GETDATE() BETWEEN A.FromDate AND ISNULL(A.ToDate,GETDATE()))
	 

	 IF ISNULL(@ChannelId,0)=0
		SET @ChannelId=1

PRINT 'ChannelId=' + CAST(@ChannelId AS VARCHAR) 
		
Create table #StockDetail(Date date,PrdId int,PrdBatchId int,StockStatusId int,ProductRate numeric(18,2),SalesNodeId int,SalesNodeType int,Fyid int,BookedStock int,Physicalstock int,LocationId int,UomId int,MRP numeric(18,2))

Declare @i int,@cnt int,@DbrNodeId int,@DbrNodeType int,@flgStockManage tinyint
set @i=1
select @cnt=count(*) from #DBRList

while @i<=@cnt
begin
SET @DbrNodeId=0
	select @DbrNodeId=CustomerNodeID,@DbrNodeType=CustomerNodeType from #DBRList where ident=@i
	SET @flgStockManage=0
	----select @flgStockManage=flgWillManageInventory from tbldbrsalesstructuredbr WHERE nodeid=@DbrNodeId and nodetype=@DbrNodeType
	if @flgStockManage=1
	begin
		insert into #StockDetail
		exec [spGetCurrentStockByDbr] @DbrNodeId,@DbrNodeType
	end
set @i=@i+1
end
	select SalesNodeId as DBRNodeId,SalesNodeType as DbrNodeType,PrdId,sum(Physicalstock) as Physicalstock into #DMSStk from  #StockDetail where StockStatusId=1
	group by SalesNodeId ,SalesNodeType ,PrdId

	--SELECT * FROM #DMSStk
	 CREATE TABLE #tblStockData(CustomerNodeID INT,CustomerNodeType INT,ProductNodeID INT,ProductNodeType SMALLINT,SKUName VARCHAR(500),StockDate DATE,StockQty INT,UOMID INT) 

	 -- to get Products assigned to channel
	 INSERT INTO #tblStockData(CustomerNodeID,CustomerNodeType,ProductNodeID,ProductNodeType,SKUName,StockDate,StockQty,UOMID)
	 SELECT DISTINCT D.CustomerNodeID,D.CustomerNodeType,V.SKUNodeID,V.SKUNodeType,V.SKUShortDescr,@StockDate,S.StockQty,S.uomid
	 FROM [VwSFAProductHierarchy] V INNER JOIN tblPrdSKUSalesMapping B ON V.SKUNodeID=B.SKUNodeID AND V.SKUNodeType=B.SKUNodeType
	 CROSS JOIN #DBRList D
	 LEFT JOIN tblDistributorStockDet S ON B.SKUNodeID=S.ProductNodeId AND B.SKUNodeType=S.ProductNodeType AND S.CustomerNodeID=@CustomerNodeId AND S.CustomerNodeType=@CustomerNodeType AND S.StockDate=@StockDate
	 WHERE B.BusinessSegmentId=@ChannelId AND (CONVERT(DATE,GETDATE()) BETWEEN FromDate AND ToDate) --AND D.StateID=B.PrcLocationID
	 --ORDER BY SKUOrdr    


	 UPDATE A SET A.StockQty = AA.Physicalstock  FROM #tblStockData A INNER JOIN
	 #DMSStk AA ON A.CustomerNodeID=AA.DBRNodeId AND A.CustomerNodeType=AA.DbrNodeType AND A.ProductNodeID=AA.PrdId


	 UPDATE A SET A.StockQty = AA.StockQty  FROM #tblStockData A INNER JOIN
	 (SELECT S.CustomerNodeID,S.CustomerNodeType,S.ProductNodeID,S.ProductNodeType,S.StockQty
	 FROM #DBRList A INNER JOIN tblDistributorStockDet S ON A.CustomerNodeID=S.CustomerNodeID AND A.CustomerNodeType=S.CustomerNodeType
	 WHERE S.StockDate=@StockDate) AA ON A.CustomerNodeID=AA.CustomerNodeID AND A.CustomerNodeType=AA.CustomerNodeType AND A.ProductNodeID=AA.ProductNodeID AND A.ProductNodeType=AA.ProductNodeType

	 SELECT SM.DbId AS CustomerNodeID,SM.DBNodeType AS CustomerNodeType,OD.ProductID ProductNodeID,SUM(OrderQty) OrderQty INTO #Orders
	 FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.orderId
	 INNER JOIN tblStoreMaster SM ON OM.StoreId=SM.StoreId
	 INNER JOIN #DBRList D ON SM.DBID=D.CustomerNodeID AND SM.DBNodeType=D.CustomerNodeType
	 WHERE ISNULL(OrderStatusID,0)<>3 AND OM.OrderDate=@StockDate
	 GROUP BY SM.DbId,SM.DBNodeType,OD.ProductID

	 UPDATE A SET A.StockQty=ISNULL(A.StockQty,0)-ISNULL(B.OrderQty,0)
	 FROM #tblStockData A INNER JOIN #Orders B ON A.ProductNodeID=B.ProductNodeID AND A.CustomerNodeID=B.CustomerNodeID AND A.CustomerNodeType=B.CustomerNodeType

	 SELECT '0-' + CAST(CustomerNodeID AS VARCHAR) + '-' + CAST(CustomerNodeType AS VARCHAR) AS Customer,ProductNodeID,ProductNodeType,SKUName,StockDate,StockQty,UOMID 
	 FROM #tblStockData

	 SELECT * INTO #tblDBRWiseOrderList FROM @tblDBRWiseOrderList
	 --SELECT * FROM #tblDBRWiseOrderList

	 SELECT DISTINCT'0-' + CAST(SM.DBId AS VARCHAR) + '-' + CAST(SM.DBNodeType AS VARCHAR) AS Customer,OM.OrderPDAID AS PDAOrderId INTO #ExistingOrders
	 FROM tblOrderMaster OM INNER JOIN tblStoreMaster SM ON OM.StoreId=SM.StoreId
	 INNER JOIN #tblDBRWiseOrderList A ON '0-' + CAST(SM.DBId AS VARCHAR) + '-' + CAST(SM.DBNodeType AS VARCHAR)=A.Customer
	 --SELECT * FROM #ExistingOrders

	 SELECT A.Customer,A.PDAOrderId
	 FROM #tblDBRWiseOrderList A LEFT OUTER JOIN #ExistingOrders B ON A.Customer=B.Customer AND A.PDAOrderId=B.PDAOrderId
	 WHERE B.Customer IS NULL AND B.PDAOrderId IS NULL

	 --SELECT DISTINCT D.CustomerNodeID,D.CustomerNodeType,D.PDAOrderId
	 --FROM tblOrderMaster OM INNER JOIN tblStoreMaster SM ON OM.StoreId=SM.StoreId
	 --RIGHT OUTER JOIN #tblDBRWiseOrderList D ON SM.DBID=D.CustomerNodeID AND SM.DBNodeType=D.CustomerNodeType AND OM.PDAOrderId=D.PDAOrderId
	 --WHERE SM.DBID IS NULL AND SM.DBNodeType IS NULL AND OM.PDAOrderId IS NULL
END


