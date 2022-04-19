-- =============================================
-- Author:		Avinash Gupta
-- Create date: 07-Feb-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpVanGetVanMappingdetails] --1,110
	@CoverageAreaNodeID INT=0,
	@CoverageAreaNodeType TINYINT=0	
AS
BEGIN
	CREATE TABLE #VanmappingDetails(VanID INT,Nodetype SMALLINT,VanRegNumber VARCHAR(30),SalesNodeID INT,SalesNodetype SMALLINT,ComCoverageArea VARCHAR(200),Descr VARCHAR(200),PersonNodeID INT,PersonNodeType SMALLINT,Person VARCHAR(200))

	DECLARE @DistributorNodeType INT
	SELECT @DistributorNodeType=NodeType FROM [dbo].[tblSecMenuContextMenu] WHERE flgdistributor=1

	----IF @CoverageAreaNodeID=0 AND @CoverageAreaNodeType=0
	----BEGIN
	----	INSERT INTO #VanmappingDetails(VanID,NodeType,VanRegNumber,Descr)
	----	SELECT DISTINCT NodeID,NodeType,VanRegNumber,Descr FROM [dbo].[tblVanMstr]
	----END
	----ELSE IF @DistributorNodeType<>@CoverageAreaNodeType
	----BEGIN
	----	INSERT INTO #VanmappingDetails(VanID,NodeType,VanRegNumber,Descr)
	----	SELECT DISTINCT NodeID,NodeType,VanRegNumber,Descr FROM [dbo].[tblVanMstr] V INNER JOIN [tblSalesHierVanMapping] SH ON SH.VanID=V.NodeID LEFT OUTER JOIN VwCompanyDSRFullDetail C ON C.DSRAreaID=SH.SalesNodeID AND C.DSRAreaNodeType=SH.SalesNodeType WHERE C.SOAreaID=@CoverageAreaNodeID AND C.SOAreaNodeType=@CoverageAreaNodeType
	----	UNION
	----	SELECT DISTINCT NodeID,NodeType,VanRegNumber,Descr FROM [dbo].[tblVanMstr] V INNER JOIN [tblSalesHierVanMapping] SH ON SH.VanID=V.NodeID LEFT OUTER JOIN [VwDistributorDSRFullDetail] C ON C.DBRCoverageID=SH.SalesNodeID AND C.DBRCoverageNodeType=SH.SalesNodeType WHERE C.SOAreaID=@CoverageAreaNodeID AND C.SOAreaNodeType=@CoverageAreaNodeType
	----END
	----ELSE IF @DistributorNodeType=@CoverageAreaNodeType
	----BEGIN
	----	INSERT INTO #VanmappingDetails(VanID,NodeType,VanRegNumber,Descr)
	----	SELECT DISTINCT NodeID,NodeType,VanRegNumber,Descr FROM [dbo].[tblVanMstr] V INNER JOIN [tblSalesHierVanMapping] SH ON SH.VanID=V.NodeID LEFT OUTER JOIN [VwDistributorDSRFullDetail] C ON C.DBRCoverageID=SH.SalesNodeID AND C.DBRCoverageNodeType=SH.SalesNodeType WHERE C.DBRNodeID=@CoverageAreaNodeID AND C.DistributorNodeType=@CoverageAreaNodeType
	----END
	------SELECT * FROM 	#VanmappingDetails

	----UPDATE VM SET SalesNodeID=SV.SalesNodeID,SalesNodetype=SV.SalesNodetype,ComCoverageArea=S.ComCoverageArea,PersonNodeID=SP.PersonNodeID,PersonNodeType=SP.PersonType,Person=P.Descr 
	----FROM #VanmappingDetails VM INNER JOIN [tblSalesHierVanMapping] SV ON SV.VanID=VM.VanID AND SV.VanNodeType=VM.NodeType 
	----INNER JOIN [VwSalesHierarchy] S ON S.ComCoverageAreaID=SV.SalesNodeID AND S.ComcoverageAreaType=SV.SalesNodeType AND GETDATE() BETWEEN SV.Fromdate AND SV.Todate
	----LEFT OUTER JOIN tblSalesPersonMapping SP
	----INNER JOIN tblMstrPerson P ON P.NodeID=SP.PersonNodeID AND P.NodeType=SP.PersonType
	---- ON SP.NodeID=S.ComCoverageAreaID AND SP.NodeType=S.ComCoverageAreaType

	---- UPDATE VM SET SalesNodeID=SV.SalesNodeID,SalesNodetype=SV.SalesNodetype,ComCoverageArea=S.DBRCoverage,PersonNodeID=SP.PersonNodeID,PersonNodeType=SP.PersonType,Person=P.Descr 
	----FROM #VanmappingDetails VM INNER JOIN [tblSalesHierVanMapping] SV ON SV.VanID=VM.VanID AND SV.VanNodeType=VM.NodeType 
	----INNER JOIN VwAllDistributorHierarchy S ON S.DBRCoverageID=SV.SalesNodeID AND S.DBRCoverageNodeType=SV.SalesNodeType AND GETDATE() BETWEEN SV.Fromdate AND SV.Todate
	----LEFT OUTER JOIN tblSalesPersonMapping SP
	----INNER JOIN tblMstrPerson P ON P.NodeID=SP.PersonNodeID AND P.NodeType=SP.PersonType
	---- ON SP.NodeID=S.DBRCoverageID AND SP.NodeType=S.DBRCoverageNodeType
	

	SELECT * FROM #VanmappingDetails

	--SELECT DISTINCT V.NodeID VanID,V.NodeType,V.VanRegNumber,SV.SalesNodeID,SV.SalesNodetype,S.ComCoverageArea FROM tblVanMstr V LEFT OUTER JOIN [dbo].[tblSalesHierVanMapping] SV ON SV.VanID=V.NodeID AND SV.VanNodeType=V.NodeType
	--INNER JOIN [VwSalesHierarchy] S ON S.ComCoverageAreaID=SV.SalesNodeID AND S.ComcoverageAreaType=SV.SalesNodeType
	 --AND GETDATE() BETWEEN SV.Fromdate AND SV.Todate
END


