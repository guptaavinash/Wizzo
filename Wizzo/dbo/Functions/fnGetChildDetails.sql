




create FUNCTION [dbo].[fnGetChildDetails](@NodeId int,@NodeType int,@Date date)
RETURNS @SalesList TABLE (Descr VARCHAR(200),NodeID INT,NodeType SMALLINT,HierID INT,PNodeID INT,PNodeType SMALLINT,PHierID INT,LstLevel TINYINT)
BEGIN
Declare @CmpSales dbo.SalesList

;WITH CTEAllChilds(Descr,NodeID,NodeType,HierID,PNodeID,PNodeType,PHierID,LstLevel)
 AS 
	( 
	--initialization 
	SELECT CAST(V.Descr AS varchar(200)) Descr,S.NodeID, S.NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM tblCompanySalesStructureHierarchy S INNER JOIN  [dbo].[VwAllSalesHierarchy] V
	ON V.NodeID=S.NodeID AND V.NodeType=S.NodeType
	WHERE (S.NodeID= @NodeID AND S.NodeType=@NodeType) 
	UNION ALL 
	SELECT CAST(V.Descr AS VARCHAR(200)) Descr,S.NodeID, S.NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM tblCompanySalesStructureHierarchy S INNER JOIN  [dbo].[VwAllSalesHierarchy] V
	ON V.NodeID=S.NodeID AND V.NodeType=S.NodeType
	WHERE PNodeID= @NodeID AND PNodeType=@NodeType AND @NodeID=0 AND @NodeType=0
	UNION ALL 
	--recursive execution 
	SELECT CAST(O.Descr + '-' + V.Descr AS VARCHAR(200)),C.NodeID, C.NodeType, C.HierID ,C.PNodeID,C.PNodeType,C.PHierID,O.LstLevel + 1
	FROM tblCompanySalesStructureHierarchy C INNER JOIN  [dbo].[VwAllSalesHierarchy] V
	ON V.NodeID=C.NodeID AND V.NodeType=C.NodeType
	INNER JOIN CTEAllChilds O
	ON C.PHierID = O.HierID 
	)

insert into @SalesList
select *  from CTEAllChilds


RETURN
end


