

-- =============================================  
-- Author:  Avinash Gupta  
-- Create date: 11-Oct-2015  
-- Description:   
-- =============================================  
-- [SpPDA_Get_ProductCategory] '354010084603910'
CREATE PROCEDURE [dbo].[SpPDA_Get_ProductCategory]   
@PDACode VARCHAR(50)
AS  
BEGIN  
	--DECLARE @DeviceID INT
	DECLARE @PersonID INT     
	DECLARE @PersonType INT    
	DECLARE @ChannelId INT=0

	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMEINO OR PDA_IMEI_Sec=@IMEINO
	--PRINT '@DeviceID=' + CAST(ISNULL(@DeviceID,0) AS VARCHAR)

	--SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@DeviceID  AND (GETDATE() BETWEEN DateFrom AND DateTo)
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	PRINT 'PersonID=' + CAST(@PersonID AS VARCHAR)          
	PRINT 'PersonType=' + CAST(@PersonType AS VARCHAR)
	
	SELECT P.NodeID,P.NodeType INTO #CoverageArea 
	FROM tblSalesPersonMapping P  
	INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
	
	WHERE ISNULL(C.flgCoverageArea,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))

	SELECT @ChannelId=A.ChannelID
	from tblSalesHierChannelMapping A INNER JOIN #CoverageArea B ON A.SalesStructureNodID=B.NodeId AND A.SalesStructureNodType=B.NodeType
	WHERE (GETDATE() BETWEEN A.FromDate AND ISNULL(A.ToDate,GETDATE()))
	PRINT 'ChannelId=' + CAST(ISNULL(@ChannelId,0) AS VARCHAR)

	IF ISNULL(@ChannelId,0)=0
		SET @ChannelId=1

	----SELECT DISTINCT ProductTypeNodeID NODEID,ProductType CATEGORY,CatOrdr AS CatOrdr 
	----FROM [VwSFAProductHierarchy]  A INNER JOIN tblPrdSKUSalesMapping B ON A.SKUNodeID=B.SKUNodeID AND A.SKUNodeType=B.SKUNodeType
	----WHERE B.BusinessSegmentId=@ChannelId AND (CONVERT(DATE,GETDATE()) BETWEEN FromDate AND ToDate) 
	----UNION  
	----SELECT 0, 'All' ,0 AS Ordr
	----ORDER BY CatOrdr 

	SELECT DISTINCT CategoryNodeId NODEID,Category CATEGORY FROM [VwSFAProductHierarchy]  
	UNION  
	Select 0, 'All'  
END  


