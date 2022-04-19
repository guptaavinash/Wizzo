

-- =============================================
-- Author:		Avinash Gupta
-- Create date: 27-Apr-2015
-- Description:	Sp to get the Child Details list for route mapping
-- =============================================
-- SpGetChildDetails 1,9,1
CREATE PROCEDURE [dbo].[SpGetChildDetails] 
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

CREATE TABLE #tblChildList (HierID INT ,Descr VARCHAR(200),PHierID INT,NodeID INT,NodeType INT,LstLevel INT,PNodeID INT,PNodeType INT,PPHierID INT,PPNodeID INT,PPNodeType INT,Seq INT DEFAULT 1)

;WITH CTEAllChilds AS 
	( 
	--initialization 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM tblCompanySalesStructureHierarchy  
	WHERE (NodeID= @NodeID AND NodeType=@NodeType) 
	UNION ALL 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM tblCompanySalesStructureHierarchy  
	WHERE PNodeID= @NodeID AND PNodeType=@NodeType AND @NodeID=0 AND @NodeType=0
	UNION ALL 
	--recursive execution 
	SELECT C.NodeID, C.NodeType, C.HierID ,C.PNodeID,C.PNodeType,C.PHierID,O.LstLevel + 1
	FROM tblCompanySalesStructureHierarchy C INNER JOIN CTEAllChilds O
	ON C.PHierID = O.HierID 
	) 

SELECT * INTO #cteallchilds FROM CTEAllChilds

--select * from #cteallchilds

--SELECT DISTINCT NodeType FROM #cteallchilds WHERE PNodeType=@NodeType

IF @flg=1
BEGIN
	SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@NodeType

	EXEC spUTLGetSQLTblSource @ChildNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

	SET @strSQL='INSERT INTO #tblChildList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType) '
	SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,C.LstLevel,C.PNodeID,C.PNodeType FROM ' + @tblDesc + ' T INNER JOIN #cteallchilds C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE PNodeType=' + CAST(@NodeType AS VARCHAR)
	PRINT @strSQL
	EXEC (@strSQL)
END
ELSE
BEGIN
	DECLARE Cur_Sales CURSOR FOR
	SELECT DISTINCT HierID,NodeType FROM #cteallchilds WHERE PNodeType=@NodeType
	OPEN Cur_Sales
	FETCH NEXT FROM Cur_Sales INTO @PHierID,@ChildNodeType
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT '@ChildNodeType=' + CAST(@ChildNodeType AS VARCHAR)
		WHILE (ISNULL(@ChildNodeType,0)>0)
		BEGIN
			PRINT '@ChildNodeType=' + CAST(@ChildNodeType AS VARCHAR)
			EXEC spUTLGetSQLTblSource @ChildNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT

			SET @strSQL='INSERT INTO #tblChildList(NodeID,Descr,NodeType,HierID,PHierID,LstLevel,PNodeID,PNodeType) '
			SET @strSQL=@strSQL + 'SELECT T.NodeID,T.Descr,T.NodeType,C.HierID,C.PhierID,C.LstLevel,C.PNodeID,C.PNodeType FROM ' + @tblDesc + ' T INNER JOIN #cteallchilds C ON C.NodeID=T.NodeID AND C.NodeType=T.NodeType WHERE T.NodeType=' + CAST(@ChildNodeType AS VARCHAR)
			PRINT @strSQL
			EXEC (@strSQL)

			IF @ChildNodeType=170
			BEGIN
				IF EXISTS(SELECT 1 FROM #cteallchilds WHERE PNodeType=@ChildNodeType AND PHierID=@PHierID)
					SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@ChildNodeType AND PHierID=@PHierID
				ELSE 
					SELECT @ChildNodeType=0
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT 1 FROM #cteallchilds WHERE PNodeType=@ChildNodeType)
					SELECT @ChildNodeType=NodeType FROM #cteallchilds WHERE PNodeType=@ChildNodeType
				ELSE 
					SELECT @ChildNodeType=0
			END
			
		END
		FETCH NEXT FROM Cur_Sales INTO @PHierID,@ChildNodeType
		
	END
	CLOSE Cur_Sales
	DEALLOCATE Cur_Sales
END
--select * from #tblChildList
UPDATE #tblChildList SET PHierID=NULL WHERE PHierID =0

;WITH TempEmp (HierID,duplicateRecCount)
AS
(
SELECT HierID,ROW_NUMBER() OVER(PARTITION by HierID, Descr ORDER BY HierID) 
AS duplicateRecCount
FROM #tblChildList
)
--Now Delete Duplicate Records
DELETE FROM TempEmp
WHERE duplicateRecCount > 1  

DELETE FROM #tblChildList WHERE NodeType=130 AND NodeID NOT IN (SELECT DISTINCT PNodeID FROM #tblChildList WHERE NodeType=150)

UPDATE #tblChildList SET PPNodeID=ISNULL(CL.PNodeID,0),PPNodeType=ISNULL(CL.PNodeType,0) FROM #tblChildList C INNER JOIN #cteallchilds CL ON CL.NodeID=C.PNodeID AND CL.NodeType=C.PNodeType
UPDATE #tblChildList SET PPNodeID=ISNULL(PPNodeID,0),PPNodeType=ISNULL(PPNodeType,0) FROM #tblChildList

UPDATE #tblChildList SET Seq=0 WHERE NodeID=@CurrentNodeID AND NodeType=@CurrentNodeType

--SELECT * FROM #tblChildList ORDER BY NodeType,NodeID --Seq

select HierID ,Descr,PHierID,NodeID,NodeType,LstLevel,PNodeID,PNodeType,PPHierID,PPNodeID,PPNodeType,Seq 
FROM #tblChildList
WHERE NodeType not in(130,160)
UNION ALL
select A.HierID ,A.Descr + '(' + ISNULL(AA.PersonName,'NA') + ')',A.PHierID,A.NodeID,A.NodeType,A.LstLevel,A.PNodeID,A.PNodeType,A.PPHierID,A.PPNodeID,A.PPNodeType,A.Seq 
FROM #tblChildList A LEFT JOIN
(SELECT SP.NodeID,SP.NodeType,P.Descr AS PersonName  FROM tblSalesPersonMapping SP INNER JOIN tblMstrPerson P ON SP.PersonNodeID=p.NodeID AND SP.PersonType=P.NodeType WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(Sp.ToDate,GETDATE())) AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))) AA
ON A.NodeID=AA.NodeID AND A.NodeType=AA.NodeType
WHERE A.NodeType in(130,160)
ORDER BY NodeType,Descr


SELECT        COUNT(tblOrderMaster.OrderID) AS Cnt, V.DBRRoute, V.DBRCoverageID,v.DBRCoverageNodeType
INTO              [#tmpOrderProcessedCoverageArea]
FROM            tblOrderMaster INNER JOIN
                         tblRouteCoverageStoreMapping AS RC ON RC.StoreID = tblOrderMaster.StoreID AND tblOrderMaster.OrderDate BETWEEN RC.FromDate AND RC.ToDate RIGHT OUTER JOIN
                         VwAllDistributorHierarchy AS V ON  RC.RouteID = V.DBRRouteID
						  and RC.RouteNodeType= V.RouteNodeType
and        (tblOrderMaster.OrdPrcsId = 2)
WHERE V.DBRNodeID = @NodeID 
GROUP BY V.DBRCoverage, V.DBRRoute, V.DBRCoverageID,v.DBRCoverageNodeType
union all
SELECT        COUNT(tblOrderMaster.OrderID) AS Cnt, V.Route AS DBRRoute, V.CovNodeID AS DBRCoverageID,v.CovNodeType as DBRCoverageNodeType
FROM            tblOrderMaster INNER JOIN
                         tblRouteCoverageStoreMapping AS RC ON RC.StoreID = tblOrderMaster.StoreID AND tblOrderMaster.OrderDate BETWEEN RC.FromDate AND RC.ToDate RIGHT OUTER JOIN
                         VwAllDistributorCompanyHierarchy AS V ON  RC.RouteID = V.RouteNodeId
						 and RC.RouteNodeType= V.RouteNodeType
and        (tblOrderMaster.OrdPrcsId = 2)
WHERE V.DBRNodeID = @NodeID 
GROUP BY V.Cov, V.Route, V.CovNodeID,v.CovNodeType
order by 1 desc


select distinct DBRCoverageId as NodeId,DBRCoverageNodeType as NodeType,DBRCoverage+ ISNULL('('+STUFF((SELECT ',' + CAST(p1.DBRRoute AS VARCHAR)+'('+CAST(p1.Cnt AS VARCHAR)+')' 
         FROM #tmpOrderProcessedCoverageArea p1
         WHERE A.DBRCoverageID = p1.DBRCoverageID
		 and A.DBRCoverageNodeType = p1.DBRCoverageNodeType
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)')
        ,1,1,'') +')','') as Descr  from [VwAllDistributorHierarchy] A
		where DBRNodeID = @NodeID

		union all
select distinct CovNodeID as NodeId,CovNodeType as NodeType,Cov+ ISNULL('('+STUFF((SELECT ',' + CAST(p1.DBRRoute AS VARCHAR)+'('+CAST(p1.Cnt AS VARCHAR)+')' 
         FROM #tmpOrderProcessedCoverageArea p1
         WHERE A.CovNodeID = p1.DBRCoverageID
		 and A.CovNodeType = p1.DBRCoverageNodeType
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)')
        ,1,1,'') +')','') as Descr  from VwAllDistributorCompanyHierarchy A
		where DBRNodeID = @NodeID
END



