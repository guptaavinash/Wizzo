
CREATE PROCEDURE [dbo].[spPopulateOLAPCompanySalesHierarchy]
	
AS
BEGIN
	TRUNCATE TABLE tblOLAPCompanySalesStructure
	--SELECT * FROM tblOLAPCompanySalesStructure
	 PRINT 'Company Route'
	INSERT INTO tblOLAPCompanySalesStructure(ZoneID,ZoneNodeType,Zone,RegionId,RegionNodeType,Region,ASMAreaID,ASMAreaNodeType,ASMArea,SOAreaID,SOAreaNodeType,SOArea,CoverageAreaID, CoverageAreaNodeType,CoverageArea,RouteNodeId,RouteNodeType,Route,StoreID,StoreCode,StoreName)	
	SELECT  VW.ZoneID, VW.ZoneNodeType, VW.Zone,VW.RegionID, VW.RegionNodeType, VW.Region, VW.ASMAreaID, VW.ASMAreaNodeType, VW.ASMArea, VW.SOAreaID, VW.SOAreaNodeType,VW.SOArea, VW.DSRAreaID, VW.DSRAreaNodeType, VW.DSRArea, R.NodeID, R.NodeType, R.Descr, ISNULL(SM.StoreID,0) StoreID,ISNULL(SM.StoreCode,'NA') StoreCode, ISNULL(SM.StoreName,'NA') StoreName
	FROM            tblStoreMaster AS SM INNER JOIN
                         tblRouteCoverageStoreMapping AS RC ON SM.StoreID = RC.StoreID INNER JOIN
						 tblCompanySalesStructureHierarchy H ON RC.RouteID=H.NodeID AND RC.RouteNodeType=H.NodeType INNER JOIN
						 tblcompanySalesStructureRouteMstr R ON H.NodeId=R.NodeId AND H.NodeType=R.NodeType INNER JOIN
                         VwCompanySalesHierarchy AS VW ON H.PNodeID = VW.DSRAreaID AND H.PNodeType = VW.DSRAreaNodeType
	
	
	UPDATE tblOLAPCompanySalesStructure SET StarOutlet='No'
	UPDATE A SET A.StarOutlet='Yes' FROM tblOLAPCompanySalesStructure A INNER JOIN StartOutletDump BB ON A.StoreID=BB.StoreID


	/*

	--ZH Update
     UPDATE A SET A.Zone=A.Zone + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPCompanySalesStructure A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND B.NodeType=95) AA
    ON A.ZoneID=AA.NodeId AND A.ZoneNodeType=AA.NodeType
	WHERE A.ZoneID<>0

	--RSM Update
     UPDATE A SET A.Region=A.Region + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPCompanySalesStructure A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND B.NodeType=100) AA
    ON A.RegionId=AA.NodeId AND A.RegionNodeType=AA.NodeType
	WHERE A.RegionID<>0

    --ASM Name Update
    UPDATE A SET A.ASMArea=A.ASMArea + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPCompanySalesStructure A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=110) AA
    ON A.ASMAreaID=AA.NodeId AND A.ASMAreaNodeType=AA.NodeType
	WHERE A.ASMAreaID<>0

    --SO Name Update
    UPDATE A SET A.SOArea=A.SOArea + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPCompanySalesStructure A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=120) AA
    ON A.SOAreaID=AA.NodeId AND A.SOAreaNodeType=AA.NodeType
	WHERE A.SOAreaID<>0

    --CSR Name Update
    UPDATE A SET A.CoverageArea=A.CoverageArea + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPCompanySalesStructure A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType IN(130,160)) AA
    ON A.CoverageAreaID=AA.NodeId AND A.CoverageAreaNodeType=AA.NodeType
	WHERE A.CoverageAreaNodeType<>150

	  --CSR Name Update
    UPDATE A SET A.Route=A.Route + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPCompanySalesStructure A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType IN(140,170)) AA
    ON A.RouteNodeId=AA.NodeId AND A.RouteNodeType=AA.NodeType
	WHERE A.RouteNodeType<>150
	*/
END

