-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpGetSalesAreaDetails] 
	@LoginID INT
AS
BEGIN
	DECLARE @PersonNodeID INT
	DECLARE @PersonNodeType SMALLINT

	SELECT @PersonNodeID=M.UserNodeId,@PersonNodeType=M.UserNodeType  FROM tblSecUserLogin L INNER JOIN tblSecUser S ON S.UserID=L.UserID INNER JOIN [dbo].[tblSecMapUserRoles] M ON M.UserID=S.UserID WHERE L.LoginID=@LoginID


	CREATE TABLE #DSRList (DSRAreaID INT,DSRAreaNodeType SMALLINT,DSRArea VARCHAR(200),CompanyDSRID INT,CompanyDSRNodeType SMALLINT,CompanyDSR VARCHAR(200))
	IF @PersonNodeType=0 -- Admin
		INSERT INTO #DSRList(DSRAreaID,DSRAreaNodeType,DSRArea,CompanyDSRID,CompanyDSRNodeType,CompanyDSR)
		SELECT DISTINCT DSRAreaID,DSRAreaNodeType,DSRArea,CompanyDSRID,CompanyDSRNodeType,CompanyDSR FROM [dbo].[VwCompanyDSRFullDetail]
		UNION
		SELECT DISTINCT DBRCoverageID,DBRCoverageNodeType,DBRCoverage,DistributorDSRID,DistributorDSRNodeType,DistributorDSR FROM [dbo].[VwDistributorDSRFullDetail]
	ELSE IF @PersonNodeType=220  --SO
		INSERT INTO #DSRList(DSRAreaID,DSRAreaNodeType,DSRArea,CompanyDSRID,CompanyDSRNodeType,CompanyDSR)
		SELECT DSRAreaID,DSRAreaNodeType,DSRArea,CompanyDSRID,CompanyDSRNodeType,CompanyDSR FROM [dbo].[VwCompanyDSRFullDetail] WHERE SOID=@PersonNodeID AND SONodeType=@PersonNodeType
		UNION
		SELECT DISTINCT DBRCoverageID,DBRCoverageNodeType,DBRCoverage,DistributorDSRID,DistributorDSRNodeType,DistributorDSR FROM [dbo].[VwDistributorDSRFullDetail] WHERE SOID=@PersonNodeID AND SONodeType=@PersonNodeType
	ELSE IF @PersonNodeType=150  --Distributor
		INSERT INTO #DSRList(DSRAreaID,DSRAreaNodeType,DSRArea,CompanyDSRID,CompanyDSRNodeType,CompanyDSR)
		SELECT DISTINCT DBRCoverageID,DBRCoverageNodeType,DBRCoverage,DistributorDSRID,DistributorDSRNodeType,DistributorDSR FROM [dbo].[VwDistributorDSRFullDetail] WHERE DBRNodeID=@PersonNodeID AND DistributorNodeType=@PersonNodeType
		

	SELECT   DISTINCT     tblMstrPerson.NodeID, tblMstrPerson.NodeType, tblMstrPerson.Descr as PersonName
	FROM            tblMstrPerson INNER JOIN
	tblSalesPersonMapping SM ON tblMstrPerson.NodeID = SM.PersonNodeID INNER JOIN
	tblCompanySalesStructureCoverage ON SM.NodeID = tblCompanySalesStructureCoverage.NodeID AND SM.NodeType = tblCompanySalesStructureCoverage.NodeType
	INNER JOIN #DSRList D ON D.DSRAreaID=SM.NodeID AND D.DSRAreaNodeType=SM.NodeType
	WHERE        (CONVERT(DATE, GETDATE()) BETWEEN SM.FromDate AND SM.ToDate)
	UNION
	SELECT   DISTINCT     tblMstrPerson.NodeID, tblMstrPerson.NodeType, tblMstrPerson.Descr as PersonName
	FROM            tblMstrPerson INNER JOIN
	tblSalesPersonMapping SM ON tblMstrPerson.NodeID = SM.PersonNodeID INNER JOIN
	tblDBRSalesStructureCoverage ON SM.NodeID = tblDBRSalesStructureCoverage.NodeID AND SM.NodeType = tblDBRSalesStructureCoverage.NodeType
	INNER JOIN #DSRList D ON D.DSRAreaID=SM.NodeID AND D.DSRAreaNodeType=SM.NodeType
	WHERE        (CONVERT(DATE, GETDATE()) BETWEEN SM.FromDate AND SM.ToDate)

	SELECT   DISTINCT    tblCompanySalesStructureCoverage.Descr AS CoverageArea,
	tblCompanySalesStructureCoverage.NodeID SalesNodeID,tblCompanySalesStructureCoverage.NodeType SalesNodeType
	FROM            tblMstrPerson INNER JOIN
	tblSalesPersonMapping ON tblMstrPerson.NodeID = tblSalesPersonMapping.PersonNodeID INNER JOIN
	tblCompanySalesStructureCoverage ON tblSalesPersonMapping.NodeID = tblCompanySalesStructureCoverage.NodeID AND tblSalesPersonMapping.NodeType = tblCompanySalesStructureCoverage.NodeType
	INNER JOIN #DSRList D ON D.DSRAreaID=tblSalesPersonMapping.NodeID AND D.DSRAreaNodeType=tblSalesPersonMapping.NodeType
	UNION
	SELECT   DISTINCT    tblDBRSalesStructureCoverage.Descr AS CoverageArea,
	tblDBRSalesStructureCoverage.NodeID SalesNodeID,tblDBRSalesStructureCoverage.NodeType SalesNodeType
	FROM            tblMstrPerson INNER JOIN
	tblSalesPersonMapping ON tblMstrPerson.NodeID = tblSalesPersonMapping.PersonNodeID INNER JOIN
	tblDBRSalesStructureCoverage ON tblSalesPersonMapping.NodeID = tblDBRSalesStructureCoverage.NodeID AND tblSalesPersonMapping.NodeType = tblDBRSalesStructureCoverage.NodeType
	INNER JOIN #DSRList D ON D.DSRAreaID=tblSalesPersonMapping.NodeID AND D.DSRAreaNodeType=tblSalesPersonMapping.NodeType

--WHERE        (CONVERT(DATE, GETDATE()) BETWEEN tblSalesPersonMapping.FromDate AND tblSalesPersonMapping.ToDate)


END
