--spMakeTreeWSChildNodes 0,0,1,'9/21/2015 2:10:49 PM',2,5,5,614

-- spMakeTreeWSChildNodes 61,3,1,'5/17/2015 1:56:03 PM',2,5,1,4913
CREATE PROCEDURE [dbo].[spMakeTreeWSChildNodes] 


--spMakeTreeWSChildNodes 0, 0, 1, '30-Apr-07', 1, 1, 0, 111
-- spMakeTreeChildNodes 0,'11',1,'05-Nov-2004',2,1170,'-11-12-13-14-'
@PHierID INT , --This is the HierId of the node for whom children are to be found.
@PNodeType INT,
@DefRepType TINYINT,  --This is the reporting type for which tree is to be made.
@RepDate DATETIME, --This is the date for which tree to be made
@PSecFlag TINYINT, -- Parameter to pass the security flag for the node to be drilled down
@LstLevelReqd INT,
@HierTypeID INT,
@LoginID INT,
@ManufacturerID INT=0

AS

DECLARE @ChildNodesCursor Cursor
DECLARE @HierID INT
DECLARE @NodeID INT
DECLARE @NodeType SMALLINT
DECLARE @FrmID TINYINT
DECLARE @SSClass VarChar(100)
DECLARE @ImageName varChar(100)
DECLARE @NodeDesc varChar(100)
DECLARE @ISActive TINYINT
DECLARE @LstLevel TINYINT
DECLARE @SecFlag TINYINT
DECLARE @SQLStr varChar(2000)
DECLARE @tblHier varChar(70) --This is the Hierarchy table from which the records will be fetched
DECLARE @tblDesc varChar(50) --This is not required in this SP but used a SP to get SQLTblSource requires it
DECLARE @DateINT INT
DECLARE @EmpPKey varChar(100)
DECLARE @EmpName varChar(300)

DECLARE @SHNodeID INT
DECLARE @SHNodeType SMALLINT
DECLARE @LoginUserNodeID INT
DECLARE @LoginUserNodeType TINYINT

SET NOCOUNT ON

CREATE TABLE #tmpChildNodes (
	[HierID] [int] NOT NULL , --This is the Hierarchy ID from the relevant Hierarchy table
	[PHierID] [INT] NOT NULL,
	[NodeID] [int] NOT NULL , --This is the Node ID of the Child Field
	[NodeType] [SMALLINT], --This is the Node Type of the Child Field
	[NodeDesc] [varchar] (100) , --Description of the Chld Field
 	[PNodeID] [int] NOT NULL , --This is the Node ID of the Child Field
	[PNodeType] [SMALLINT], --This is the Node Type of the Child Field
	[SSClass] [Varchar] (150),
	[ImageName] [Varchar] (50),
	[lstLevel] [TINYINT],
	[SecFlag] [TINYINT],
	[EmpPKey] varChar(50) DEFAULT '0',
	[ISActive] [TINYINT]
)


IF @LstLevelReqd=0
	BEGIN
		SELECT @LstLevelReqd=Max(NodeType) FROM tblPMstNodeTypes WHERE HierTypeID=@HierTypeID
		IF @LstLevelReqd=@PNodeType
			BEGIN
				SELECT @LstLevelReqd=Max(NodeType) FROM tblPMstNodeTypes WHERE HierTypeID=@HierTypeID AND NodeType<>@PNodeType
			END
	END
PRINT '@LstLevelReqd=' + CAST(@LstLevelReqd AS VARCHAR)
IF @PNodeType=0
	BEGIN
		SELECT @PNodeType=Min(NodeType) FROM tblPMstNodeTypes WHERE HierTypeID=@HierTypeID
	END
	PRINT '@PNodeType=' + CAST(@PNodeType AS VARCHAR)
EXEC spUTLGetSQLTblSource @PNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrmID OUTPUT, @HierTypeID OUTPUT
SELECT @LoginUserNodeID=NodeID,@LoginUserNodeType=NodeType FROM tblSecUserLogin INNER JOIN tblSecUser ON tblSecUser.UserID=tblSecUserLogin.UserID WHERE LoginID=@LoginID

IF @HierTypeID=5
BEGIN
	IF @PNodeType=150 AND @LoginUserNodeType<>0
	BEGIN
		SET @SQLStr='INSERT INTO #tmpChildNodes (HierId, PHierID, NodeID, NodeType, PNodeID, PNodeType) 
		SELECT HierID, PHierID, NodeID, NodeType, PNodeId, PNodeType  FROM ' + @tblHier  + ' 
		WHERE HierTypeID=' + CAST(@HierTypeID AS VarChar(5)) + ' AND  (PHierID = ' + CAST(@PHierID AS VarChar(5)) + ')'  + ' 
		AND   DATEDIFF(DAY,VldFrom,''' +   Cast(@RepDate as Varchar(12))  +  ''')>=0 '  + ' 
		AND DATEDIFF(DAY,VldTo, ''' +  Cast(@RepDate as Varchar(12)) + ''')<=0' -- To date is < Start Date and To Date > End
		IF @PNodeType<>@LstLevelReqd OR  @PNodeType=0 OR @PHierID=0 OR (@PNodeType=@LstLevelReqd AND @PNodeType=100) 
		BEGIN
			print'AA'
			EXEC (@SQLStr)
		END
		
		CREATE TABLE #tmpForDBRHierarchy(ID INT IDENTITY(1,1),NodeId INT, NodeType INT)
		CREATE TABLE #tmp(ID INT IDENTITY(1,1),NodeId INT, NodeType INT)
		DECLARE @Counter INT=0
		DECLARE @AreaNodeId INT
		DECLARE @AreaNodeType INT
		Declare @Curr_Date datetime
		set @Curr_Date=dbo.fnGetCurrentDateTime()
				
		SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegionID,RegionNodeType,Region,ASMAreaID,ASMAreaNodeType,ASMArea,SOAreaID,SOAreaNodeType,SOArea,DSRAreaID,DSRAreaNodeType,DSRArea INTO #CompSales
		FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN VwCompanySalesHierarchy CS ON Map.SHNodeId=CS.DSRAreaID AND Map.SHNodeType=CS.DSRAreaNodeType	WHERE Map.SHNodeId<>0 AND (@Curr_Date BETWEEN Map.Fromdate AND Map.ToDate)
		UNION ALL
		SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegionID,RegionNodeType,Region,ASMAreaID,ASMAreaNodeType,ASMArea,SOAreaID,SOAreaNodeType,SOArea,0,0,'Direct'
		FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN VwCompanySalesHierarchy CS ON Map.SHNodeId=CS.SOAreaId AND Map.SHNodeType=CS.SOAreaNodeType		WHERE Map.SHNodeId<>0 AND (@Curr_Date BETWEEN Map.Fromdate AND Map.ToDate)
		UNION ALL
		SELECT DISTINCT Map.DHNodeId,Map.DHNodeType,CS.RegionID,RegionNodeType,Region,ASMAreaID,ASMAreaNodeType,ASMArea,0,0,'Direct',0,0,'Direct'
		FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN VwCompanySalesHierarchy CS ON Map.SHNodeId=CS.ASMAreaId AND Map.SHNodeType=CS.ASMAreaNodeType WHERE Map.SHNodeId<>0 AND (@Curr_Date BETWEEN Map.Fromdate AND Map.ToDate) 

		SELECT DISTINCT A.RegionID,A.RegionNodeType,A.Region,A.ASMAreaID,A.ASMAreaNodeType,A.ASMArea,A.SOAreaID,A.SOAreaNodeType,A.SOArea,B.DBRNodeID,B.DistributorNodeType,B.DBRCoverageID,b.DBRCoverageNodeType,B.DBRRouteID,B.RouteNodeType INTO #FullHier
		FROM #CompSales A INNER JOIN VwAllDistributorHierarchy B ON A.DHNodeID=B.DBRCoverageID AND A.DHNodeType=B.DBRCoverageNodeType
		--SELECT * FROM #FullHier order by RegionID,ASMAreaID,SOAreaID
		
		INSERT INTO #tmpForDBRHierarchy(NodeId,NodeType)
		SELECT DISTINCT NodeId, NodeType
		FROM tblSalesPersonMapping
		WHERE PersonNodeID=@LoginUserNodeID AND PersonType=@LoginUserNodeType AND (@Curr_Date BETWEEN FromDate AND ToDate)
		--SELECT * FROM #tmpForDBRHierarchy
		
		SET @counter  = 1
		WHILE(@counter <=(Select MAX(ID) FROM #tmpForDBRHierarchy))
		BEGIN
			SELECT @AreaNodeId = NodeId,@AreaNodeType=NodeType FROM #tmpForDBRHierarchy WHERE ID = @counter
			
			IF @AreaNodeType=100
			BEGIN
				INSERT INTO #tmp(NodeId,NodeType)
				SELECT DISTINCT DBRNodeID,DistributorNodeType
				FROM #FullHier WHERE RegionID= @AreaNodeId
			END
			ELSE IF @AreaNodeType=110
			BEGIN
				INSERT INTO #tmp(NodeId,NodeType)
				SELECT DISTINCT DBRNodeID,DistributorNodeType
				FROM #FullHier WHERE ASMAreaID= @AreaNodeId
			END
			ELSE IF @AreaNodeType=120
			BEGIN
				INSERT INTO #tmp(NodeId,NodeType)
				SELECT DISTINCT DBRNodeID,DistributorNodeType
				FROM #FullHier WHERE SOAreaID= @AreaNodeId
			END			
			SET @counter = @counter + 1			
		END	
		--SELECT * FROM #tmp
		--SELECT * FROM #tmpChildNodes
		DELETE FROM #tmpChildNodes WHERE NodeType=9 AND NodeID NOT IN (SELECT NodeID FROM #tmp WHERE NodeType=150)
		
		/*
		SELECT @SHNodeID=NodeID, @SHNodeType=NodeType FROM dbo.tblSalesPersonMapping WHERE @Curr_Date BETWEEN FromDate AND TODATE AND PersonNodeID=@LoginUserNodeID AND PersonType=@LoginUserNodeType
		PRINT '@LoginUserNodeID=' + CAST(@LoginUserNodeID AS VARCHAR)
		PRINT '@LoginUserNodeType=' + CAST(@LoginUserNodeType AS VARCHAR)
		PRINT '@SHNodeID=' + CAST(@SHNodeID AS VARCHAR)
		PRINT '@SHNodeType=' + CAST(@SHNodeType AS VARCHAR)
		--SELECT * FROM #tmpChildNodes
		DELETE FROM #tmpChildNodes WHERE NodeType=9 AND NodeID NOT IN (SELECT M.DBRNodeID FROM tblCompanySalesStructure_DistributorMapping DM INNER JOIN dbo.VwAllDistributorHierarchy M ON M.DBRCoverageID=DM.DHNodeID AND M.DBRCoverageNodeType=DM.DHNodeType 
		WHERE @Curr_Date BETWEEN FromDate AND ToDate AND flgSup=1 AND DM.SHNodeID=@SHNodeID AND DM.SHNodeType=@SHNodeType)
		*/
	END
	ELSE
	BEGIN	
		SET @SQLStr='INSERT INTO #tmpChildNodes (HierId, PHierID, NodeID, NodeType, PNodeID, PNodeType) 
		SELECT HierID, PHierID, NodeID, NodeType, PNodeId, PNodeType  FROM ' + @tblHier  + '  
		WHERE HierTypeID=' + CAST(@HierTypeID AS VarChar(5)) + ' AND  (PHierID = ' + CAST(@PHierID AS VarChar(5)) + ')'  + ' 
		AND   DATEDIFF(DAY,VldFrom,''' +   Cast(@RepDate as Varchar(12))  +  ''')>=0 '  + ' 
		AND DATEDIFF(DAY,VldTo, ''' +  Cast(@RepDate as Varchar(12)) + ''')<=0' 
		--Added By AK on 15May to improve speed of distributor appearing on screen by filtering only for DBR with coverage area
		
		IF @PNodeType<>@LstLevelReqd OR  @PNodeType=0 OR @PHierID=0 OR (@PNodeType=@LstLevelReqd AND @PNodeType=100) 
		BEGIN
			print'BB'
			EXEC (@SQLStr)
		END
	END
	
	
END
ELSE
BEGIN
	SET @SQLStr='INSERT INTO #tmpChildNodes (HierId, PHierID, NodeID, NodeType, PNodeID, PNodeType) 
	SELECT HierID, PHierID, NodeID, NodeType, PNodeId, PNodeType  FROM ' + @tblHier  + ' 
	WHERE HierTypeID=' + CAST(@HierTypeID AS VarChar(5)) + ' AND  (PHierID = ' + CAST(@PHierID AS VarChar(5)) + ')'  + ' 
	AND   DATEDIFF(DAY,VldFrom,''' +   Cast(@RepDate as Varchar(12))  +  ''')>=0 '  + ' 
	AND DATEDIFF(DAY,VldTo, ''' +  Cast(@RepDate as Varchar(12)) + ''')<=0' -- To date is < Start Date and To Date > End
	IF @PNodeType<>@LstLevelReqd OR  @PNodeType=0 OR @PHierID=0 OR (@PNodeType=@LstLevelReqd AND @PNodeType=95) 
	BEGIN
		print'CC'
		EXEC (@SQLStr)
	END
END



Print @SQLStr		
 -- ')  AND  CAST((CAST(VldFrom AS INT)-1) - CAST(' + CAST(@DateINT AS VarChar(6)) + ' AS INT) AS INT) <= 0  AND   CAST((CAST(VldTo AS INT)+1 - CAST(' + CAST(@DateINT AS VarChar(6)) + ' AS INT)) AS INT) >= 0' --+ (CAST(@Curr_Date as Varchar(15)) 




--DELETE FROM #tmpChildNodes WHERE NodeType=6
--select * from #tmpChildNodes
Print 'a'
SET @ChildNodesCursor = CURSOR FOR
	select HierId, NodeID, NodeType from #tmpChildNodes

OPEN @ChildNodesCursor

	FETCH NEXT FROM @ChildNodesCursor INTO @HierID, @NodeID, @NodeType
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Print 'A'
		EXEC spGetNodeDesc @NodeID, @NodeType,@NodeDesc OUTPUT,@ISActive OUTPUT
		Print 'B'
		EXEC spMakeTreeGetFormat @NodeType, @SSClass OUTPUT, @ImageName OUTPUT
		Print 'C'
		EXEC spMakeTreeLastLevelStatus @HierID, @NodeType, 2, @LstLevelReqd, @LstLevel OUTPUT
		Print 'D'
		EXEC spMakeTreeGetUserSec @LoginID, @NodeID, @NodeType, @PSecFlag, @SecFlag OUTPUT
		Print 'E'
		IF ISNULL(@ManufacturerID,0)<>0
		BEGIN
			IF @NodeType=10
			BEGIN
				DELETE FROM #tmpChildNodes WHERE NodeType=@NodeType AND NodeID NOT IN (SELECT CategoryNodeID FROM VwProductHierarchy WHERE ManufacturerID=@ManufacturerID)
			END
			ELSE IF @NodeType=20
			BEGIN
				DELETE FROM #tmpChildNodes WHERE NodeType=@NodeType AND NodeID NOT IN (SELECT ProductTypeNodeID FROM VwProductHierarchy WHERE ManufacturerID=@ManufacturerID)
			END
			ELSE IF @NodeType=30
			BEGIN
				DELETE FROM #tmpChildNodes WHERE NodeType=@NodeType AND NodeID NOT IN (SELECT SKUNodeID FROM VwProductHierarchy WHERE ManufacturerID=@ManufacturerID)
			END
		END
--		IF @NodeType=5 --For Job Description, we will also show current incumbent to position
--			BEGIN
--				SET @EmpName=NULL
--				SET @EmpPKey=NULL
--				SELECT     @EmpName=tblOrgEmployee.Descr FROM         tblOrgHierarchy INNER JOIN tblOrgEmployee ON tblOrgHierarchy.NodeId = tblOrgEmployee.NodeID AND tblOrgHierarchy.NodeType = tblOrgEmployee.NodeType WHERE tblOrgHierarchy.PHierID=@HierID
--				SET @EmpName=ISNULL(@EmpName, 'Vacant')
--				SELECT @EmpPKey=Cast(isnull(HierID,0) as varchar) + '|' + cast(isnull(PHierID,0) as varchar) + '|' + cast(isnull(NodeID,0) as varchar) + '|' + cast(isnull(NodeType,0) as varchar) + '|' + cast(isnull(PNodeID,0) as varchar) + '|' + cast(isnull(PNodeType,0) as varchar) + '|20|2|0' FROM tblOrgHierarchy WHERE PHierID=@HierID AND NodeType=6
--				--SET @NodeDesc=@NodeDesc + ' _ ' + @EmpName
--			SET @NodeDesc=@NodeDesc
--			END
		PRINT @NodeDesc + '----' + CAST(@SecFlag AS VARcHAR(4))
	--	SET @EmpPKey=ISNULL(@EmpPKey, '0')
	 	UPDATE #tmpChildNodes SET NodeDesc=@NodeDesc, SSClass=@SSClass, ImageName=@ImageName, SecFlag=@SecFlag, LstLevel=@LstLevel, EmpPkey=@EmpPkey, ISActive = @ISActive WHERE HierId=@HierId AND NodeId=@NodeID and NodeType=@NodeType
		
		--SET @EmpPKey='0'
	FETCH NEXT FROM @ChildNodesCursor INTO @HierId, @NodeID, @NodeType
	END
--IF @NodeType=5
	--BEGIN
--		SELECT cast(isnull(HierID,0) as varchar) + '|' + cast(isnull(PHierID,0) as varchar) + '|' + cast(isnull(NodeID,0) as varchar) + '|' + cast(isnull(NodeType,0) as varchar) + '|' + cast(isnull(PNodeID,0) as varchar) + '|' + cast(isnull(PNodeType,0) as varchar) + '|' + cast(isnull(LstLevel,0) as varchar) + '|' + cast(isnull(SecFlag,0) as varchar) + '|0'  + '$' + EmpPKey  AS PKey, NodeDesc, SSClass, ImageName  FROM #tmpChildNodes ORDER BY NodeDesc
	--END
--ELSE
	--BEGIN
		SELECT cast(isnull(HierID,0) as varchar) + '|' + cast(isnull(PHierID,0) as varchar) + '|' + cast(isnull(NodeID,0) as varchar) + '|' + cast(isnull(NodeType,0) as varchar) + '|' + cast(isnull(PNodeID,0) as varchar) + '|' + cast(isnull(PNodeType,0) as varchar) + '|' + cast(isnull(LstLevel,0) as varchar) + '|' + cast(isnull(SecFlag,0) as varchar) + '|0'AS PKey, NodeDesc, SSClass, ImageName ,ISActive FROM #tmpChildNodes 
		WHERE ISActive = 1
		
		 ORDER BY NodeDesc
	--END
