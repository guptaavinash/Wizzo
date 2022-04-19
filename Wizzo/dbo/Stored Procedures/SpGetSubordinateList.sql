-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [SpGetSubordinateList] '9C34A784-42D1-42EC-B129-973F8C56906C'
CREATE PROCEDURE [dbo].[SpGetSubordinateList] 
	@IMEINumber VARCHAR(50)
AS
BEGIN
	--DECLARE @DeviceID INT      
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMEINumber OR PDA_IMEI_Sec=@IMEINumber      
    --PRINT @DeviceID
	DECLARE @PersonID INT
	DECLARE @PersonNodetype SMALLINT

	SELECT @PersonID=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@IMEINumber) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	SELECT @PersonNodetype=PersonType FROM tblSalesPersonMapping WHERE PersonNodeID=@PersonID
	
	DECLARE @NodeID INT,@NodeType SMALLINT
	SELECT @NodeID=NodeID,@NodeType=NodeType FROM tblSalesPersonMapping SM WHERE PersonNodeID=@PersonID AND PersonType=@PersonNodetype AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate AND PersonType=210

	PRINT @PersonID
	PRINT @PersonNodetype

	PRINT @NodeID
	PRINT @NodeType

	CREATE TABLE #CovAreaList(CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT,CoverageArea VARCHAR(500),PersonNodeID INT,PersonNodeType SMALLINT,PersonName VARCHAR(200),PDAId INT,Person_IMEI1 VARCHAR(20),Person_IMEI2 VARCHAR(20),ParentPersonID INT,ParentPersonType SMALLINT,flgMarketVisitStarted TINYINT DEFAULT 0)

	
	IF @PersonNodetype=210
	BEGIN
		INSERT INTO #CovAreaList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName,ParentPersonID,ParentPersonType)
		SELECT DISTINCT V.DSRAreaID,V.DSRAreaNodeType,V.DSRArea,CP.PersonNodeID,CP.PersonType ,PM.Descr,P.PersonNodeID,P.PersonType
		FROM tblSalesPersonMapping P INNER JOIN [dbo].[VwCompanySalesHierarchy] V ON V.ASMAreaID=P.NodeID AND V.ASMAreaNodeType=P.NodeType 
		LEFT OUTER JOIN  tblSalesPersonMapping CP ON CP.NodeID=V.DSRAreaID AND CP.NodeType=V.DSRAreaNodeType 
		LEFT OUTER JOIN tblMstrPerson PM ON PM.NodeID=CP.PersonNodeID
		WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonNodetype AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) AND  (GETDATE() BETWEEN CP.FromDate AND ISNULL(CP.ToDate,GETDATE()))
	
	END
	--SELECT * FROM tblCompetitionSurveyPlanStoreList
	--UPDATE C SET flgMarketVisitStarted=1 FROM #CovAreaList C INNER JOIN tblCompetitionSurveyPlanStoreList PL ON PL.CoverageAreaNodeID=C.CoverageAreaNodeID AND PL.CoverageAreaNodetype=C.CoverageAreaNodeType WHERE PL.SurveyDate=CAST(GETDATE() AS DATE)

	------DSR
	----INSERT INTO #CovAreaList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName,PDAId,Person_IMEI1,Person_IMEI2)
	----SELECT DBRCov.NodeId AS CovAreaNodeId,DBRCov.NodeType AS CovAreaNodeType,DBRCov.Descr AS CovArea,ISNULL(DSR.NodeID,0) AS PersonNodeID,ISNULL(DSR.NodeType,0) AS PersonNodeType,ISNULL(DSR.Descr,'') AS PersonName,ISNULL(DSR.PersonPhone,'') AS PersonPhone,0,'',''
	----FROM tblSalesPersonMapping SP INNER JOIN tblCompanySalesStructure_DistributorMapping Map ON SP.NodeId=Map.SHNodeId AND SP.NodeType=Map.SHNodeType
	----INNER JOIN tblDBRSalesStructureCoverage DBRCov ON Map.DHNodeId=DBRCov.NodeId AND Map.DHNodeType=DBRCov.NodeType
	----LEFT JOIN tblSalesPersonMapping DSRMap ON DBRCov.NodeID=DSRMap.NodeId AND DBRCov.NodeType=DSRMap.NodeType AND (CAST(GETDATE() AS DATE) BETWEEN CAST(DSRMap.FromDate AS DATE) AND CAST(DSRMap.ToDate AS DATE))
	----LEFT JOIN tblMstrPerson DSR ON DSRMap.PersonNodeID=DSR.NodeID AND (CAST(GETDATE() AS DATE) BETWEEN CAST(DSR.FromDate AS DATE) AND CAST(DSR.ToDate AS DATE))
	----WHERE SP.PersonNodeID=@PersonID AND SP.PersonType=@PersonNodetype AND (CAST(GETDATE() AS DATE) BETWEEN CAST(SP.FromDate AS DATE) AND CAST(SP.ToDate AS DATE))
	---- AND (CAST(GETDATE() AS DATE) BETWEEN CAST(Map.FromDate AS DATE) AND CAST(Map.ToDate AS DATE))

	---- --Company Salesman
	---- INSERT INTO #CovAreaList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName,PDAId,Person_IMEI1,Person_IMEI2)
	----SELECT CompCov.NodeId AS CovAreaNodeId,CompCov.NodeType AS CovAreaNodeType,CompCov.Descr AS CovArea,ISNULL(CSR.NodeID,0) AS PersonNodeID,ISNULL(CSR.NodeType,0) AS PersonNodeType,ISNULL(CSR.Descr,'') AS PersonName,ISNULL(CSR.PersonPhone,'') AS PersonPhone,0,'',''
	---- FROM tblSalesPersonMapping SP INNER JOIN tblCompanySalesStructureHierarchy PHier ON SP.NodeType=PHier.NodeType AND SP.NodeId=PHier.NodeId
	---- INNER JOIN  tblCompanySalesStructureHierarchy Hier ON PHier.HierId=Hier.PHierId
	---- INNER JOIN tblCompanySalesStructureCoverage CompCov ON Hier.NodeId=CompCov.NodeId AND Hier.NodeType=CompCov.NodeType
	---- LEFT JOIN tblSalesPersonMapping CSRMap ON CompCov.NodeID=CSRMap.NodeId AND CompCov.NodeType=CSRMap.NodeType AND (CAST(GETDATE() AS DATE) BETWEEN CAST(CSRMap.FromDate AS DATE) AND CAST(CSRMap.ToDate AS DATE))
	----LEFT JOIN tblMstrPerson CSR ON CSRMap.PersonNodeID=CSR.NodeID AND (CAST(GETDATE() AS DATE) BETWEEN CAST(CSR.FromDate AS DATE) AND CAST(CSR.ToDate AS DATE))
	----WHERE SP.PersonNodeID=@PersonID AND SP.PersonType=@PersonNodetype AND (CAST(GETDATE() AS DATE) BETWEEN CAST(SP.FromDate AS DATE) AND CAST(SP.ToDate AS DATE))

	--UPDATE A  SET A.Person_IMEI1=Pda.PDA_IMEI,A.Person_IMEI2=PDA.PDA_IMEI_Sec,A.PDAId=PDA.PDAID
	--FROM #CovAreaList A INNER JOIN tblPDA_UserMapMaster PDA_Map ON A.PersonNodeID=PDA_Map.PersonID 
	--INNER JOIN tblPDAMaster PDA ON PDA_Map.PDAID=PDA.PDAID
	--WHERE (CAST(GETDATE() AS DATE) BETWEEN CAST(PDA_Map.DateFrom AS DATE) AND CAST(PDA_Map.DateTo AS DATE))

	SELECT DISTINCT ISNULL(PersonNodeID,0) PersonNodeID,ISNULL(PersonNodeType,0) PersonNodeType,ISNULL(PersonName,'Vacant') PersonName,CoverageArea,CASE WHEN PersonNodeType=220 THEN 1 ELSE 2 END flgPersonType,ISNULL(ParentPersonID,0) ParentPersonID,ISNULL(ParentPersonType,0) ParentPersonType,flgMarketVisitStarted ,CoverageAreaNodeID,CoverageAreaNodeType
	 FROM #CovAreaList

END
