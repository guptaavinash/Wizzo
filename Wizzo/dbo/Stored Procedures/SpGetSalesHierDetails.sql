-- [SpGetSalesHierDetails] 9,130,3,120
CREATE Procedure [dbo].[SpGetSalesHierDetails]
	@NodeID INT,
	@NodeType INT,
	@PNodeID INT,
	@PNodeType INT
AS
BEGIN
	DECLARE @tblHier VARCHAR(50)
	DECLARE @tblDesc VARCHAR(50)
	DECLARE @FrameID INT
	DECLARE @HierTypeID INT	
	DECLARE @strSQL VARCHAR(4000)
	DECLARE @ChildtblDesc VARCHAR(50)
	

	EXEC spUTLGetSQLTblSource @NodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT
	SET @strSQL='SELECT Descr FROM ' +  @tblDesc + ' WHERE NodeId=' +  CAST(@NodeID AS varChar(6))
	print @strSQL
	EXEC (@strSQL)

	SET @strSQL='SELECT DISTINCT tblSalesHierChannelMapping.ChannelID,tblOutletChannelMaster.ChannelName ChannelName FROM tblSalesHierChannelMapping INNER JOIN ' + @tblDesc + ' ON ' + @tblDesc + '.NodeID=tblSalesHierChannelMapping.SalesStructureNodID
	AND tblSalesHierChannelMapping.SalesStructureNodType=' + @tblDesc + '.NodeType
	INNER JOIN tblOutletChannelMaster ON tblOutletChannelMaster.OutChannelID=tblSalesHierChannelMapping.ChannelID WHERE tblSalesHierChannelMapping.SalesStructureNodID=' + CAST(@NodeID AS VARCHAR) + ' AND GetDate() BETWEEN tblSalesHierChannelMapping.FromDate AND tblSalesHierChannelMapping.ToDate'
	print @strSQL
	EXEC (@strSQL)
	
	SELECT @ChildtblDesc=@tblDesc


	if @PNodeID=0 and @PNodeType=0
	begin
	
	EXEC spUTLGetSQLTblSource @PNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT
	SET @strSQL='SELECT Descr FROM ' +  @tblDesc + ' WHERE NodeId=' +  CAST(@NodeID AS varChar(6))
	print @strSQL
	EXEC (@strSQL)
	
	
	SET @strSQL='SELECT DISTINCT tblSalesHierChannelMapping.ChannelID AS PChannelID,tblOutletChannelMaster.ChannelName ParentChannelName FROM tblSalesHierChannelMapping INNER JOIN ' + @tblDesc + ' ON ' + @tblDesc + '.NodeID=tblSalesHierChannelMapping.SalesStructureNodID
	AND tblSalesHierChannelMapping.SalesStructureNodType=' + @tblDesc + '.NodeType
	INNER JOIN tblOutletChannelMaster ON tblOutletChannelMaster.OutChannelID=tblSalesHierChannelMapping.ChannelID WHERE GetDate() BETWEEN tblSalesHierChannelMapping.FromDate AND tblSalesHierChannelMapping.ToDate'
	print @strSQL
	EXEC (@strSQL)
	
	end
	else
	begin
	EXEC spUTLGetSQLTblSource @PNodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT
	SET @strSQL='SELECT Descr FROM ' +  @tblDesc + ' WHERE NodeId=' +  CAST(@PNodeID AS varChar(6))
	print @strSQL
	EXEC (@strSQL)
	
	
	SET @strSQL='SELECT DISTINCT tblSalesHierChannelMapping.ChannelID AS PChannelID,tblOutletChannelMaster.ChannelName ParentChannelName FROM tblSalesHierChannelMapping INNER JOIN ' + @tblDesc + ' ON ' + @tblDesc + '.NodeID=tblSalesHierChannelMapping.SalesStructureNodID
	AND tblSalesHierChannelMapping.SalesStructureNodType=' + @tblDesc + '.NodeType
	INNER JOIN tblOutletChannelMaster ON tblOutletChannelMaster.OutChannelID=tblSalesHierChannelMapping.ChannelID WHERE tblSalesHierChannelMapping.SalesStructureNodID=' + CAST(@PNodeID AS VARCHAR) 
	print @strSQL
	EXEC (@strSQL)
	
	end
	
	PRINT 'A'
	CREATE TABLE #tblPerson(PersonID INT,PersonName VARCHAR(200),PersonEmail VARCHAR(200),PersonPhone VARCHAR(10),FromDate Datetime,ToDate Datetime)
	

	INSERT INTO #tblPerson(PersonID ,PersonName ,PersonEmail ,PersonPhone ,FromDate ,ToDate)
	SELECT DISTINCT P.NodeID,P.Descr,P.PersonEmailID,P.PersonPhone,SP.FromDate,SP.ToDate from tblMstrPerson P 
	INNER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=P.NodeID AND SP.NodeID=@NodeID AND SP.NodeType=@NodeType AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate	AND SP.ToDate
	PRINT 'B'
	IF NOT EXISTS(SELECT 'x' FROM #tblPerson)
	BEGIN
		INSERT INTO #tblPerson(PersonID,PersonName,PersonEmail,PersonPhone,FromDate,ToDate)
		SELECT TOP 1P.NodeID,P.Descr,P.PersonEmailID,P.PersonPhone,SP.FromDate,SP.ToDate from tblMstrPerson P 
		INNER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=P.NodeID AND SP.NodeID=@NodeID AND SP.NodeType=@NodeType ORDER BY SP.FromDate DESC 
	END
		PRINT 'C'
	-- ###################################### Backup Person Details ####################################################################################
	CREATE TABLE #tblBackupPerson(PersonID INT,PersonName VARCHAR(200),PersonEmail VARCHAR(200),PersonPhone VARCHAR(10),FromDate Datetime,ToDate Datetime)
	INSERT INTO #tblBackupPerson(PersonID ,PersonName ,PersonEmail ,PersonPhone ,FromDate ,ToDate)
	SELECT DISTINCT P.NodeID,P.Descr,P.PersonEmailID,P.PersonPhone,SP.FromDate,SP.ToDate from tblMstrPerson P 
	INNER JOIN tblSalesBackupPersonMapping SP ON SP.PersonNodeID=P.NodeID AND SP.NodeID=@NodeID AND SP.NodeType=@NodeType AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate	AND SP.ToDate

	IF NOT EXISTS(SELECT 'x' FROM #tblPerson)
	BEGIN
		INSERT INTO #tblBackupPerson(PersonID,PersonName,PersonEmail,PersonPhone,FromDate,ToDate)
		SELECT TOP 1 P.NodeID,P.Descr,P.PersonEmailID,P.PersonPhone,SP.FromDate,SP.ToDate from tblMstrPerson P 
		INNER JOIN tblSalesBackupPersonMapping SP ON SP.PersonNodeID=P.NodeID AND SP.NodeID=@NodeID AND SP.NodeType=@NodeType ORDER BY SP.FromDate 
	END
		PRINT 'D'
	--#################################################################################################################################################################

	SELECT * FROM #tblPerson
	SELECT * FROM #tblBackupPerson
	
	----SELECT M.*,D.Descr FROM tblCompanySalesStructure_DistributorMapping M LEFT OUTER JOIN tblDBRSalesStructureDBR D ON M.DHNodeID=D.NodeID AND M.DHNodeType=D.NodeType
	----WHERE GETDATE() BETWEEN FromDate AND ToDate AND SHNodeID=@NodeID

	SELECT NodeType INTO #SalesNodeType FROM tblSecMenuContextMenu WHERE flgRoute=1 OR flgCoverageArea=1
	DECLARE @PersonNodeID INT
	DECLARE @PersonNodeType TINYINT
	IF @NodeType IN (SELECT NodeType FROM #SalesNodeType)
	BEGIN
		PRINT 'A'
		IF EXISTS(SELECT 1 FROM tblSalesPersonMapping WHERE NodeID=@NodeID AND NodeType=@NodeType AND flgOtherLevelPerson=1 AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate)
		BEGIN
			PRINT 'B'
			SELECT @PersonNodeID=PersonNodeID,@PersonNodeType=PersonType FROM tblSalesPersonMapping WHERE NodeID=@NodeID AND NodeType=@NodeType AND flgOtherLevelPerson=1 AND GETDATE() BETWEEN FromDate AND ToDate
			SELECT M.* FROM tblSalesPersonMapping M WHERE M.PersonNodeID=@PersonNodeID AND M.PersonType=@PersonNodeType AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate AND ISNULL(flgOtherLevelPerson,0)<>1
			AND @NodeType IN (SELECT NodeType FROM #SalesNodeType)
		END
		ELSE
		BEGIN 
			SELECT M.* FROM tblSalesPersonMapping M WHERE M.NodeID=@NodeID AND M.NodeType=@NodeType  AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate
		END
	END
	ELSE
		SELECT M.* FROM tblSalesPersonMapping M WHERE M.NodeID=@NodeID AND M.NodeType=@NodeType  AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate
		

	SELECT M.*,D.Descr FROM tblCompanySalesStructure_DistributorMapping M LEFT OUTER JOIN tblDBRSalesStructureCoverage D ON M.DHNodeID=D.NodeID AND M.DHNodeType=D.NodeType
	WHERE CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate AND DHNodeID=@NodeID AND SHNodeID<>0

	SELECT M.* FROM tblCompanySalesStructure_DistributorMapping M WHERE CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate AND SHNodeID=@NodeID AND SHNodeType=@NodeType


	-- Brand
	SET @strSQL='SELECT DISTINCT tblSalesHierPrdBrandMapping.NodeId AS BrandID,tblPrdMstrHierLvl1.Descr BrandName FROM tblSalesHierPrdBrandMapping INNER JOIN ' + @ChildtblDesc + ' ON ' + @ChildtblDesc + '.NodeID=tblSalesHierPrdBrandMapping.SalesStructureNodID
	AND tblSalesHierPrdBrandMapping.SalesStructureNodType=' + @ChildtblDesc + '.NodeType
	INNER JOIN tblPrdMstrHierLvl1 ON tblPrdMstrHierLvl1.NodeID=tblSalesHierPrdBrandMapping.NodeID AND tblPrdMstrHierLvl1.NodeType=tblSalesHierPrdBrandMapping.NodeType WHERE tblSalesHierPrdBrandMapping.SalesStructureNodID=' + CAST(@NodeID AS VARCHAR) + ' AND GetDate() BETWEEN tblSalesHierPrdBrandMapping.FromDate AND tblSalesHierPrdBrandMapping.ToDate'
	print @strSQL
	EXEC (@strSQL)

	SET @strSQL='SELECT DISTINCT tblSalesHierPrdBrandMapping.NodeId AS PBrandID,tblPrdMstrHierLvl1.Descr PBrandName FROM tblSalesHierPrdBrandMapping INNER JOIN ' + @tblDesc + ' ON ' + @tblDesc + '.NodeID=tblSalesHierPrdBrandMapping.SalesStructureNodID
	AND tblSalesHierPrdBrandMapping.SalesStructureNodType=' + @tblDesc + '.NodeType
	INNER JOIN tblPrdMstrHierLvl1 ON tblPrdMstrHierLvl1.NodeID=tblSalesHierPrdBrandMapping.NodeID AND tblPrdMstrHierLvl1.NodeType=tblSalesHierPrdBrandMapping.NodeType WHERE tblSalesHierPrdBrandMapping.SalesStructureNodID=' + CAST(@NodeID AS VARCHAR) + ' AND GetDate() BETWEEN tblSalesHierPrdBrandMapping.FromDate AND tblSalesHierPrdBrandMapping.ToDate'
	print @strSQL
	EXEC (@strSQL)
END





