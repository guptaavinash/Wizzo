

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--SpGetRoleBasedSalesHierachyDetails 0,0,0,0,0,5,2601
CREATE PROCEDURE [dbo].[SpGetRoleBasedSalesHierachyDetails] 
	@NodeID int = 0, 
	@NodeType int = 0,
	@flg INT=1, -- 0-All,1-Immediate
	@CurrentNodeID INT =0,
	@CurrentNodeType INT =0,
	@SalesHierTypeId INT=0,
	@loginId INT
AS
BEGIN
	DECLARE @LoginUserNodeID INT=0
	DECLARE @LoginUserNodeType TINYINT=0
	DECLARE @Counter INT=0
	DECLARE @AreaNodeId INT
	DECLARE @AreaNodeType INT
	DECLARE @SalesAreaNodeType INT=0

	SELECT @LoginUserNodeID=NodeID,@LoginUserNodeType=NodeType FROM tblSecUserLogin INNER JOIN tblSecUser ON tblSecUser.UserID=tblSecUserLogin.UserID WHERE LoginID=@LoginID	

	CREATE TABLE #tmpNodes(HierID INT,Descr VARCHAR(500),PHierID INT,NodeID INT,NodeType INT,LstLevel INT,PNodeID INT,PNodeType INT,PPHierID INT,PPNodeID INT,PPNodeType INT,Seq INT)
	
	--CREATE TABLE #tmpForDBRHierarchy(ID INT IDENTITY(1,1),NodeId INT, NodeType INT)
	CREATE TABLE #tmpForLoop(ID INT IDENTITY(1,1),NodeId INT, NodeType INT)
	
	PRINT '@NodeID=' + CAST(@NodeID AS VARCHAR)
	PRINT '@@NodeType=' + CAST(@NodeType AS VARCHAR)
	PRINT '@@CurrentNodeID=' + CAST(@CurrentNodeID AS VARCHAR)
	PRINT '@@CurrentNodeType=' + CAST(@CurrentNodeType AS VARCHAR)
	PRINT '@@SalesHierTypeId=' + CAST(@SalesHierTypeId AS VARCHAR)
	PRINT '@@@flg=' + CAST(@flg AS VARCHAR)	

	IF @LoginUserNodeType=0
	BEGIN
		PRINT 'AA'			
		INSERT INTO #tmpNodes(HierID ,Descr,PHierID,NodeID,NodeType,LstLevel,PNodeID,PNodeType,PPHierID,PPNodeID,PPNodeType,Seq)
		EXEC SpGetSalesHierachyNodes @NodeID,@NodeType,@flg,@CurrentNodeID,@CurrentNodeType,@SalesHierTypeId
	END
	ELSE
	BEGIN
		PRINT 'BB'
		SELECT @SalesAreaNodeType=ISNULL(MIN(SP.NodeType),0)
		FROM tblSalesPersonMapping SP
		WHERE SP.PersonNodeID=@LoginUserNodeID AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)
		PRINT 'SalesAreaNodeType-' + CAST(@SalesAreaNodeType AS VARCHAR)

		IF @SalesHierTypeId=2  -- Company Sales Herarchy
		BEGIN
			INSERT INTO #tmpForLoop(NodeId,NodeType)
			SELECT DISTINCT NodeId, NodeType
			FROM tblSalesPersonMapping
			WHERE PersonNodeID=@LoginUserNodeID AND PersonType=@LoginUserNodeType AND (GETDATE() BETWEEN FromDate AND ToDate) AND NodeType=@SalesAreaNodeType
		END
		ELSE IF @SalesHierTypeId=5 -- DBR Sales Herarchy
		BEGIN
		if @LoginUserNodeType=150
			begin
				insert into #tmpForLoop values(@LoginUserNodeId,@LoginUserNodeType)
			end
			else
			begin

			SELECT * INTO #SalesHier FROM VwSalesHierarchy

			SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegionID,RegionType AS RegionNodeType,CS.Region,ASMAreaID,ASMAreaType ASMAreaNodeType, ASMArea,SOID AS SOAreaID,SOAreaType SOAreaNodeType,SOArea,ComCoverageAreaID,ComCoverageAreaType,ComCoverageArea INTO #CompSales
			FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #SalesHier CS ON Map.SHNodeId=CS.ComCoverageAreaID AND Map.SHNodeType=CS.ComCoverageAreaType				WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
			UNION ALL
			SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegionID,RegionType AS RegionNodeType,CS.Region,ASMAreaID,ASMAreaType, ASMArea,SOID AS SOAreaID, SOAreaType, SOArea,0,0,'Direct'
			FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #SalesHier CS ON Map.SHNodeId=CS.SOID AND Map.SHNodeType=CS.SOAreaType		
			WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate)
			UNION ALL
			SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegionID,RegionType AS RegionNodeType,CS.Region,ASMAreaID,ASMAreaType, ASMArea,0,0,'Direct',0,0,'Direct'
			FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #SalesHier CS ON Map.SHNodeId=CS.ASMAreaId AND Map.SHNodeType=CS.ASMAreaType 
			WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate) 
			UNION ALL
			SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegionID,RegionType AS RegionNodeType,CS.Region,0,0,'Direct',0,0,'Direct',0,0,'Direct'
			FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #SalesHier CS ON Map.SHNodeId=CS.RegionID AND Map.SHNodeType=CS.RegionType 
			WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate) 

			SELECT DISTINCT A.RegionID,A.RegionNodeType,A.Region,A.ASMAreaID,A.ASMAreaNodeType,A.ASMArea,A.SOAreaID,A.SOAreaNodeType,A.SOArea,B.DBRNodeID, B.DistributorNodeType,B.DBRCoverageID,b.DBRCoverageNodeType,B.DBRRouteID,B.RouteNodeType INTO #FullHier
			FROM #CompSales A INNER JOIN VwAllDistributorHierarchy B ON A.DHNodeID=B.DBRCoverageID AND A.DHNodeType=B.DBRCoverageNodeType
			
			--SELECT * FROM #FullHier --where DBRNodeID in(57,58,59) order by  DBRNodeID
			
			SELECT DISTINCT RegionID,RegionType,ASMAreaID,ASMAreaType,SOID AS SOAreaId,SOAreaType,Map.DHNodeId AS DBRNodeId,Map.DHNodeType AS DistributorNodeType INTO #DBRListWithCompRoute
			FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #SalesHier Vw ON Map.SHNodeId=Vw.ComCoverageAreaID AND Map.SHNodeType=Vw.ComCoverageAreaType
			WHERE Map.DHnodeId<>0 AND Map.SHNodeId<>0 AND Map.DHNodeType=150 AND  (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate) 

			--SELECT * FROm #DBRListWithCompRoute

			INSERT INTO #tmpForDBRHierarchy(NodeId,NodeType)
			SELECT DISTINCT NodeId, NodeType
			FROM tblSalesPersonMapping
			WHERE PersonNodeID=@LoginUserNodeID AND PersonType=@LoginUserNodeType AND (GETDATE() BETWEEN FromDate AND ToDate) AND NodeType=@SalesAreaNodeType
			--SELECT * FROM #tmpForDBRHierarchy
			
			SET @counter  = 1
			WHILE(@counter <=(Select MAX(ID) FROM #tmpForDBRHierarchy))
			BEGIN
				SELECT @AreaNodeId = NodeId,@AreaNodeType=NodeType FROM #tmpForDBRHierarchy WHERE ID = @counter
				
				IF @AreaNodeType=100
				BEGIN
					INSERT INTO #tmpForLoop(NodeId,NodeType)
					SELECT DISTINCT DBRNodeID,DistributorNodeType
					FROM #FullHier WHERE RegionID= @AreaNodeId
					UNION
					SELECT DISTINCT DBRNodeID,DistributorNodeType
					FROM #DBRListWithCompRoute WHERE RegionID= @AreaNodeId
				END
				ELSE IF @AreaNodeType=110
				BEGIN
					INSERT INTO #tmpForLoop(NodeId,NodeType)
					SELECT DISTINCT DBRNodeID,DistributorNodeType
					FROM #FullHier WHERE ASMAreaID= @AreaNodeId
					UNION
					SELECT DISTINCT DBRNodeID,DistributorNodeType
					FROM #DBRListWithCompRoute WHERE ASMAreaID= @AreaNodeId
				END
				ELSE IF @AreaNodeType=120
				BEGIN
					INSERT INTO #tmpForLoop(NodeId,NodeType)
					SELECT DISTINCT DBRNodeID,DistributorNodeType
					FROM #FullHier WHERE SOAreaID= @AreaNodeId
					UNION
					SELECT DISTINCT DBRNodeID,DistributorNodeType
					FROM #DBRListWithCompRoute WHERE SOAreaID= @AreaNodeId
				END			
				SET @counter = @counter + 1			
			END	
		END
		end
		--SELECT * FROM #tmpForLoop
		SET @counter  = 1
		WHILE(@counter <=(Select MAX(ID) FROM #tmpForLoop))
		BEGIN
			SELECT @AreaNodeId = NodeId,@AreaNodeType=NodeType FROM #tmpForLoop WHERE ID = @counter
			
			INSERT INTO #tmpNodes(HierID ,Descr,PHierID,NodeID,NodeType,LstLevel,PNodeID,PNodeType,PPHierID,PPNodeID,PPNodeType,Seq)
			EXEC SpGetSalesHierachyNodes @AreaNodeId,@AreaNodeType,@flg,@CurrentNodeID,@CurrentNodeType,@SalesHierTypeId
			
			SET @counter = @counter + 1			
		END
	END
	--UPDATE #tmpNodes SET PHierID=0 WHERE PHierID IS NULL
	select HierID ,Descr,PHierID,NodeID,NodeType,LstLevel,PNodeID,PNodeType,PPHierID,PPNodeID,PPNodeType,Seq 
	FROM #tmpNodes
	ORDER BY NodeType,Descr

			
END


