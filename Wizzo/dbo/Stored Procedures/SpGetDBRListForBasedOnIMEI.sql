

-- =============================================
-- Author:		Avinash Gupta
-- Create date: 18-JUl-2017
-- Description:	
-- ============================================

-- [SpGetDBRListForBasedOnIMEI] '359670066016988'
CREATE PROCEDURE [dbo].[SpGetDBRListForBasedOnIMEI]
@IMENumber VARCHAR(20)

AS

BEGIN

	DECLARE @DeviceID INT      

	CREATE TABLE #DBRList(ident int identity(1,1),DBRNodeId INT,DBRNodeType INT, Distributor VARCHAR(200),flgReMap TINYINT,flgStockManage tinyint)

	SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMENumber OR PDA_IMEI_Sec=@IMENumber
	PRINT '@DeviceID=' + CAST(ISNULL(@DeviceID,0) AS VARCHAR)

	SELECT P.NodeID,P.NodeType INTO #CoverageArea 
	FROM tblSalesPersonMapping P INNER JOIN tblPDA_UserMapMaster M ON M.PersonID=P.PersonNodeID AND M.PersonType=P.PersonType     
	INNER JOIN tblPDAMaster PDA ON PDA.PDAID=M.PDAID      
	WHERE M.PDAID = @DeviceID AND  (GETDATE() BETWEEN M.DateFrom AND ISNULL(M.DateTo,GETDATE())) AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))   

	--SELECT * FROM #CoverageArea
	--SELECT DISTINCT F.DBRNodeID,F.DBRNodeType 
	--FROM #CoverageArea C CROSS Apply dbo.[fnGetDistributorList](C.NodeID,C.NodeType,GETDATE()) F   --INNER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=F.DBRNodeId AND DBR.NodeType=F.DBRNodetype
	
	INSERT INTO #DBRList(DBRNodeId,DBRNodeType,Distributor,flgReMap,flgStockManage)
	SELECT DISTINCT F.DBRNodeID,F.DBRNodeType,DBR.Descr,ISNULL(DBR.flgReMap,1),isnull(DBR.flgWillManageInventory,0)+1 FROM #CoverageArea C CROSS Apply dbo.[fnGetDistributorList](C.NodeID,C.NodeType,GETDATE()) F   INNER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=F.DBRNodeId AND DBR.NodeType=F.DBRNodetype
	
	----SELECT DISTINCT DBR.NodeId,DBR.NodeType,DBR.Descr,ISNULL(DBR.flgReMap,1),isnull(DBR.flgWillManageInventory,0)+1
	----FROM VwSalesHierarchy V INNER JOIN #CoverageArea C ON C.NodeID=V.SOID AND C.NodeType=V.SOAreaType 
	----INNER JOIN tblCompanySalesStructure_DistributorMapping M ON C.NodeID=M.SHNodeID AND C.NodeType=M.SHNodeType
	----INNER JOIN tblDBRSalesStructureDBR DBR ON M.DHNodeId=DBR.NodeId AND M.DHNodeType=DBR.Nodetype
	----WHERE V.ComCoverageAreaID IS NOT NULL AND DBR.IsActive=1 AND (GETDATE() BETWEEN M.FromDate AND ISNULL(M.ToDate,GETDATE()))
	----UNION
	----SELECT DISTINCT DBR.NodeId,DBR.NodeType,DBR.Descr,ISNULL(DBR.flgReMap,1),isnull(DBR.flgWillManageInventory,0)+1
	----FROM tblCompanySalesStructure_DistributorMapping M INNER JOIN #CoverageArea C      
	----ON C.NodeID=M.SHNodeID AND C.NodeType=M.SHNodeType INNER JOIN VwAllDistributorHierarchy V ON V.DBRCoverageID=M.DHNodeID AND V.DBRCoverageNodeType=M.DHNodeType
	----INNER JOIN tblDBRSalesStructureDBR DBR ON V.DBRNodeID=DBR.NodeId AND V.DistributorNodeType=DBR.Nodetype
	----WHERE DBR.IsActive=1 AND (GETDATE() BETWEEN M.FromDate AND ISNULL(M.ToDate,GETDATE()))
	----UNION
	----SELECT DISTINCT DBR.NodeId,DBR.NodeType,DBR.Descr,ISNULL(DBR.flgReMap,1),isnull(DBR.flgWillManageInventory,0)+1
	----FROM #CoverageArea C INNER JOIN VwAllDistributorHierarchy V ON V.DBRCoverageID=C.NodeID AND V.DBRCoverageNodeType=C.NodeType
	----INNER JOIN tblDBRSalesStructureDBR DBR ON V.DBRNodeID=DBR.NodeId AND V.DistributorNodeType=DBR.Nodetype


	SELECT * FROM #DBRList A 
	EXEC [spStoreCloseReasonMaster]

	Create table #StockDetail(Date date,PrdId int,PrdBatchId int,StockStatusId int,ProductRate numeric(18,2),SalesNodeId int,SalesNodeType int,Fyid int,BookedStock int,Physicalstock int,LocationId int,UomId int,MRP numeric(18,2))

	Declare @i int,@cnt int,@DbrNodeId int,@DbrNodeType int,@flgStockManage tinyint
	set @i=1
	select @cnt=count(*) from #DBRList

	while @i<=@cnt
	begin
		select @DbrNodeId=DbrNodeId,@DbrNodeType=DbrNodeType,@flgStockManage=flgStockManage from #DBRList where ident=@i

		if @flgStockManage=2
		begin
			insert into #StockDetail
			exec [spGetCurrentStockByDbr] @DbrNodeId,@DbrNodeType
		end
		set @i=@i+1
	end
	select SalesNodeId as DBRNodeId,SalesNodeType as DbrNodeType,PrdId,sum(Physicalstock) as Physicalstock from  #StockDetail where StockStatusId=1
	group by SalesNodeId ,SalesNodeType ,PrdId
END


