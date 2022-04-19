
-- =============================================
-- Author:		Avinash
-- Create date: 
-- Description:	
-- =============================================
-- SpGetDistributorForSalesArea 1,120
--select * from tblpmstnodetypes
--select * from dbo.[fnGetDistributorList](2,140,'19-jul-2018')

CREATE PROCEDURE [dbo].[SpGetDistributorForSalesArea] 
	@NodeID INT,
	@NodeType SMALLINT
AS
BEGIN
	

	--CREATE TABLE #tblChildList (HierID INT ,Descr VARCHAR(200),PHierID INT,NodeID INT,NodeType INT,LstLevel INT,PNodeID INT,PNodeType INT,PPHierID INT,PPNodeID INT,PPNodeType INT,Seq INT DEFAULT 1)

	--;WITH CTEAllChilds AS 
	--	( 
	--	--initialization 
	--	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	--	FROM tblCompanySalesStructureHierarchy  
	--	WHERE (NodeID= @NodeID AND NodeType=@NodeType) 
	--	UNION ALL 
	--	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	--	FROM tblCompanySalesStructureHierarchy  
	--	WHERE PNodeID= @NodeID AND PNodeType=@NodeType AND @NodeID=0 AND @NodeType=0
	--	UNION ALL 
	--	--recursive execution 
	--	SELECT C.NodeID, C.NodeType, C.HierID ,C.PNodeID,C.PNodeType,C.PHierID,O.LstLevel + 1
	--	FROM tblCompanySalesStructureHierarchy C INNER JOIN CTEAllChilds O
	--	ON C.PHierID = O.HierID 
	--	) 

	--SELECT * INTO #cteallchilds FROM CTEAllChilds

	----SELECT * FROM #cteallchilds

	Declare @Date date =getdate()
	SELECT DISTINCT a.dbrnodeid as DHNodeID,a.dbrnodetype as DHNodeType,DBR.Descr AS Distributor FROM [fnGetDistributorList](@NodeID,	@NodeType,@Date) a INNER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=a.dbrNodeID AND DBR.NodeType=a.dbrNodeType
END

