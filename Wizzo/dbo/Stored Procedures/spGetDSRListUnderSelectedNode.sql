-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spGetDSRListUnderSelectedNode] 22,150
--EXEC [spGetDSRListUnderSelectedNode] 0,0
CREATE PROCEDURE [dbo].[spGetDSRListUnderSelectedNode]
@NodeID INT=0,
@NodeType INT=0,
@DSRNodeType INT=160
AS
BEGIN
	
	CREATE TABLE #DSRList(CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT,CoverageArea VARCHAR(500),PersonNodeID INT,PersonNodeType SMALLINT,PersonName VARCHAR(200))

	IF @NodeType>0
	BEGIN
	INSERT INTO #DSRList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName)
	--RSM 
	SELECT DISTINCT DSRAreaID,DSRAreaNodeType,ISNULL(CompanyDSR,'VACANT') + ' (' + DSRArea + ')',CompanyDSRID,CompanyDSRNodeType,CompanyDSR FROM VwCompanyDSRFullDetail  
	WHERE DSRAreaID>0 AND RSMAreaID=@NodeID AND RSMAReaType=@Nodetype  -- INsert all the company DSR List
	UNION	
	--ASM
	SELECT DISTINCT DSRAreaID,DSRAreaNodeType,ISNULL(CompanyDSR,'VACANT') + ' (' + DSRArea + ')',CompanyDSRID,CompanyDSRNodeType,CompanyDSR FROM VwCompanyDSRFullDetail  
	WHERE DSRAreaID>0 AND ASMAreaID=@NodeID AND ASMAreaNodeType=@Nodetype  -- INsert all the company DSR List
	UNION
	--SO
	SELECT DISTINCT DSRAreaID,DSRAreaNodeType,ISNULL(CompanyDSR,'VACANT') + ' (' + DSRArea + ')',CompanyDSRID,CompanyDSRNodeType,CompanyDSR FROM VwCompanyDSRFullDetail  
	WHERE DSRAreaID>0 AND SOAreaID=@NodeID AND SOAreaNodeType=@Nodetype  -- INsert all the company DSR List
	----UNION
	------Distributor		
	----SELECT DISTINCT DBRCoverageID,DBRCoverageNodeType,ISNULL(DistributorDSR,'VACANT') + ' (' + DBRCoverage + ')' ,DistributorDSRID,DistributorDSRNodeType,DistributorDSR 
	----FROM VwDistributorDSRFullDetail 
	----WHERE  DBRNodeID=@NodeID AND DistributorNodeType=@Nodetype 
	----UNION
	------RSM		
	----SELECT DISTINCT DBRCoverageID,DBRCoverageNodeType,ISNULL(DistributorDSR,'VACANT') + ' (' + DBRCoverage + ')' ,DistributorDSRID,DistributorDSRNodeType,DistributorDSR 
	----FROM VwDistributorDSRFullDetail 
	----WHERE  ZoneID=@NodeID AND ZoneType=@Nodetype 
	----UNION
	------ASM		
	----SELECT DISTINCT DBRCoverageID,DBRCoverageNodeType,ISNULL(DistributorDSR,'VACANT') + ' (' + DBRCoverage + ')' ,DistributorDSRID,DistributorDSRNodeType,DistributorDSR 
	----FROM VwDistributorDSRFullDetail 
	----WHERE  ASMAreaID=@NodeID AND ASMAreaNodeType=@Nodetype 
	----UNION
	------SO		
	----SELECT DISTINCT DBRCoverageID,DBRCoverageNodeType,ISNULL(DistributorDSR,'VACANT') + ' (' + DBRCoverage + ')' ,DistributorDSRID,DistributorDSRNodeType,DistributorDSR 
	----FROM VwDistributorDSRFullDetail 
	----WHERE  SOAreaID=@NodeID AND SOAreaNodeType=@Nodetype 
	END
	ELSE
	BEGIN
		INSERT INTO #DSRList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName)
		SELECT DISTINCT DSRAreaID,DSRAreaNodeType,ISNULL(CompanyDSR,'VACANT') + ' (' + DSRArea + ')',CompanyDSRID,CompanyDSRNodeType,CompanyDSR FROM VwCompanyDSRFullDetail  
		WHERE DSRAreaID>0  -- INsert all the company DSR List
	END
	
	SELECT * FROM #DSRList		
			
		
END





