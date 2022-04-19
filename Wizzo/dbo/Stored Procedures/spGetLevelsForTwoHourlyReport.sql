-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spGetLevelsForTwoHourlyReport]'30-Nov-2021'
CREATE Procedure [dbo].[spGetLevelsForTwoHourlyReport] 
@RptDate DATE,
@ChannelId INT=1
AS
BEGIN
	EXEC [spRptCalculateDataFor2HourlyReport] @RptDate
	--EXEC [spRptCalculateDataFor2HourlyReport] '06-Mar-2021'
	
	CREATE TABLE #FullSalesHier(ZoneId INT,ZoneNodeType INT,Zone VARCHAR(200),RegionNodeId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200))

	INSERT INTO #FullSalesHier(ZoneId,ZoneNodeType,Zone,RegionNodeId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea,RouteId, RouteNodeType,Route)
	EXEC [spRptGetFullSalesHierarchyBasedonLogin] 0,0,0,''

	--SELECT * FROM #FullSalesHier --where RegionID=7 
	--ORDER BY Zone
	
	SELECT 0 AS NodeId,0 AS NodeType,'[All India]' AS LevelName,'' AS PersonName, 'gaurav@astix.in' AS EmailId_To, 'alok@astix.in,varun@astix.in' AS EmailId_CC,'gaurav@astix.in' AS EmailId_BCC INTO #AllMails
	UNION ALL
	SELECT DISTINCT ZoneId,ZoneNodeType,'[Zone-' + Zone + ']' AS LevelName,C.Descr AS PersonName,CASE WHEN LEN(ISNULL(C.PersonEmailID,''))>1 AND LEN(ISNULL(D.EmailId,''))>1 THEN C.PersonEmailID + ',' + D.EmailId WHEN LEN(ISNULL(C.PersonEmailID,''))>1 AND LEN(ISNULL(D.EmailId,''))=0 THEN C.PersonEmailID WHEN LEN(ISNULL(C.PersonEmailID,''))=0 AND LEN(ISNULL(D.EmailId,''))>1 THEN D.EmailId END AS EmailId_To,'' AS EmailId_CC,'' AS EmailId_BCC
	FROM #FullSalesHier A INNER JOIN tblSalesPersonMapping B ON A.ZoneId=B.NodeID AND A.ZoneNodeType=B.NodeType
	INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID
	LEFT JOIN tblAdditionalEmailDetailForTwoHourlyReport D ON B.NodeID=D.NodeId AND B.NodeType=D.NodeType
	WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND LEN(ISNULL(C.PersonEmailID,''))>1
	UNION ALL
	SELECT DISTINCT RegionNodeId,RegionNodeType,'[Region-' + Region + ']' AS LevelName,C.Descr AS PersonName,CASE WHEN LEN(ISNULL(C.PersonEmailID,''))>1 AND LEN(ISNULL(D.EmailId,''))>1 THEN C.PersonEmailID + ',' + D.EmailId WHEN LEN(ISNULL(C.PersonEmailID,''))>1 AND LEN(ISNULL(D.EmailId,''))=0 THEN C.PersonEmailID WHEN LEN(ISNULL(C.PersonEmailID,''))=0 AND LEN(ISNULL(D.EmailId,''))>1 THEN D.EmailId END AS EmailId_To,'' AS EmailId_CC,'' AS EmailId_BCC
	FROM #FullSalesHier A INNER JOIN tblSalesPersonMapping B ON A.RegionNodeId=B.NodeID AND A.RegionNodeType=B.NodeType
	INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID
	LEFT JOIN tblAdditionalEmailDetailForTwoHourlyReport D ON B.NodeID=D.NodeId AND B.NodeType=D.NodeType
	WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND LEN(ISNULL(C.PersonEmailID,''))>1
	UNION ALL
	SELECT DISTINCT ASMAreaID,ASMAreaNodeType,'[ASM Area-' + ASMArea + ']' AS LevelName,C.Descr AS PersonName,CASE WHEN LEN(ISNULL(C.PersonEmailID,''))>1 AND LEN(ISNULL(D.EmailId,''))>1 THEN C.PersonEmailID + ',' + D.EmailId WHEN LEN(ISNULL(C.PersonEmailID,''))>1 AND LEN(ISNULL(D.EmailId,''))=0 THEN C.PersonEmailID WHEN LEN(ISNULL(C.PersonEmailID,''))=0 AND LEN(ISNULL(D.EmailId,''))>1 THEN D.EmailId END AS EmailId_To,'' AS EmailId_CC,'' AS EmailId_BCC
	FROM #FullSalesHier A INNER JOIN tblSalesPersonMapping B ON A.ASMAreaID=B.NodeID AND A.ASMAreaNodeType=B.NodeType
	INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID 
	LEFT JOIN tblAdditionalEmailDetailForTwoHourlyReport D ON B.NodeID=D.NodeId AND B.NodeType=D.NodeType
	WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND (LEN(ISNULL(C.PersonEmailID,''))>1 OR LEN(ISNULL(D.EmailId,''))>1)
	----UNION ALL
	----SELECT DISTINCT SOAreaID,SOAreaNodeType,'[SO Area-' + SOArea + ']' AS LevelName,C.Descr AS PersonName,CASE WHEN LEN(ISNULL(C.PersonEmailID,''))>1 AND LEN(ISNULL(D.EmailId,''))>1 THEN C.PersonEmailID + ',' + D.EmailId WHEN LEN(ISNULL(C.PersonEmailID,''))>1 AND LEN(ISNULL(D.EmailId,''))=0 THEN C.PersonEmailID WHEN LEN(ISNULL(C.PersonEmailID,''))=0 AND LEN(ISNULL(D.EmailId,''))>1 THEN D.EmailId END AS EmailId_To,'saurav@astixsolutions.com' AS EmailId_CC,'' AS EmailId_BCC
	----FROM #Tmp A INNER JOIN tblSalesPersonMapping B ON A.SOAreaID=B.NodeID AND A.SOAreaNodeType=B.NodeType
	----INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
	----LEFT JOIN tblAdditionalEmailDetailForTwoHourlyReport D ON B.NodeID=D.NodeId AND B.NodeType=D.NodeType
	----WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND LEN(ISNULL(C.PersonEmailID,''))>1
	----ORDER BY NodeType,NodeId
	

	SELECT * FROM #AllMails WHERE NodeId=0
	ORDER BY NodeType,NodeId

END



