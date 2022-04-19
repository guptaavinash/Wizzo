

-- =============================================
-- Author:		Avinash Gupta
-- Create date: 27-Apr-2015
-- Description:	Sp to get the Child Details list for route mapping
-- =============================================
-- SpGetChildDetailswithfullname 1,5,0,0,0
CREATE PROCEDURE [dbo].[SpGetChildDetailswithfullname] 
	@NodeID int = 0, 
	@NodeType int = 0,
	@flg INT=1, -- 0-All,1-Immediate
	@CurrentNodeID INT =0,
	@CurrentNodeType INT =0
AS
BEGIN

DECLARE @tblHier VARCHAR(50)
DECLARE @tblDesc VARCHAR(50)
DECLARE @FrameID INT
DECLARE @HierTypeID INT
DECLARE @strSQL VARCHAR(4000)

DECLARE @ChildNodeType INT
DECLARE @PHierID INT	

--CREATE TABLE #tblChildList (HierID INT ,Descr VARCHAR(200),PHierID INT,NodeID INT,NodeType INT,LstLevel INT,PNodeID INT,PNodeType INT,PPHierID INT,PPNodeID INT,PPNodeType INT,Seq INT DEFAULT 1)

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

SELECT * INTO #cteallchilds FROM CTEAllChilds

--SELECT DISTINCT NodeType FROM #cteallchilds WHERE PNodeType=@NodeType

SELECT * FROM #cteallchilds ORDER BY LstLevel


END








