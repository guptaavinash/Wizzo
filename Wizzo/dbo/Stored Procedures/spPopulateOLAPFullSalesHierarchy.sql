
CREATE PROCEDURE [dbo].[spPopulateOLAPFullSalesHierarchy]
	
AS
BEGIN  
       
	TRUNCATE TABLE tblOLAPFullSalesHierarchy
	
    PRINT 'Company Route'

	INSERT INTO tblOLAPFullSalesHierarchy(ZoneID,ZoneNodeType,ZoneHierID,Zone,RegionID,RegionNodeType,RegionHierID,Region,ASMAreaID,ASMAreaNodeType,ASMAreaHierID,ASMArea,SOAreaID, SOAreaNodeType,SOAreaHierID,SOArea,DBRNodeID,DBRNodeType,DBRHierID,DBRCode,DBR,CoverageAreaID,CoverageAreaNodeType,CoverageAreaHierID,CoverageArea,RouteNodeId,RouteNodeType,RouteHierId,Route,StoreID,StoreCode,StoreHierId,StoreName)
	SELECT  VW.ZoneID, VW.ZoneNodeType,VW.ZoneHierId, VW.Zone,VW.RegionID, VW.RegionNodeType,VW.RegionHierId, VW.Region, VW.ASMAreaID, VW.ASMAreaNodeType,Vw.ASMAreaHierID, VW.ASMArea,VW.SOAreaID,VW.SOAreaNodeType,VW.SOAreaHierID, VW.SOArea,0,0,0,'','',VW.DSRAreaID, VW.DSRAreaNodeType,0, VW.DSRArea, R.NodeID, R.NodeType, H.HierID, R.Descr, ISNULL(SM.StoreID,0) StoreID,ISNULL(CAST(SM.StoreCode AS VARCHAR),'NA') StoreCode, CAST(R.NodeID AS VARCHAR) + '^' + CAST(R.NodeType AS VARCHAR) + '^' + CAST(ISNULL(SM.StoreID,0) AS VARCHAR) StoreHierId, ISNULL(SM.StoreName,'NA') StoreName
	FROM            tblStoreMaster AS SM INNER JOIN
                         tblRouteCoverageStoreMapping AS RC ON SM.StoreID = RC.StoreID INNER JOIN
						 tblCompanySalesStructureHierarchy H ON RC.RouteID=H.NodeID AND RC.RouteNodeType=H.NodeType INNER JOIN
						 tblcompanySalesStructureRouteMstr R ON H.NodeId=R.NodeId AND H.NodeType=R.NodeType INNER JOIN
                         VwCompanySalesHierarchy AS VW ON H.PNodeID = VW.DSRAreaID AND H.PNodeType = VW.DSRAreaNodeType
	
	UPDATE A SET A.DBRNodeID=DBR.NodeID,A.DBRNodeType=DBR.NodeType,A.DBRCode=DBR.DistributorCode,A.DBR=DBR.Descr,A.DBRHierID=CAST(ISNULL(A.SOAreaHierID, 0) AS VARCHAR) + '^' + CAST(DBR.NodeID AS VARCHAR) + '^' + CAST(DBR.NodeType AS VARCHAR)
	FROm tblOLAPFullSalesHierarchy A INNER JOIN tblStoreMaster SM ON A.StoreId=SM.StoreId INNER JOIN tblDBRSalesStructureDBR DBR ON SM.DBID=DBR.NodeID AND SM.DBNodeType=DBR.NodeType
	WHERE A.DBRNodeID=0

	--for teh stores where no db is found in system
	UPDATE A SET A.DBRHierID=CAST(ISNULL(A.SOAreaHierID, 0) AS VARCHAR) + '^0^0'
	FROm tblOLAPFullSalesHierarchy A INNER JOIN tblStoreMaster SM ON A.StoreId=SM.StoreId
	WHERE A.DBRNodeID=0 AND ISNULL(Sm.DBID,0)=0

	UPDATE A SET A.CoverageAreaHierID=CAST(ISNULL(A.DBRNodeID, 0) AS VARCHAR) + '^' + CAST(A.DBRNodeType AS VARCHAR) + '^' + CAST(A.CoverageAreaID AS VARCHAR) + '^' + CAST(A.CoverageAreaNodeType AS VARCHAR)
	FROm tblOLAPFullSalesHierarchy A
	WHERE A.CoverageAreaHierID='0'

	UPDATE A SET A.RouteHierId=CAST(ISNULL(A.DBRNodeID, 0) AS VARCHAR) + '^' + CAST(A.DBRNodeType AS VARCHAR) + '^' + CAST(A.CoverageAreaID AS VARCHAR) + '^' + CAST(A.CoverageAreaNodeType AS VARCHAR) + '^' + CAST(A.RouteHierId AS varchar)
	FROm tblOLAPFullSalesHierarchy A
	WHERE A.RouteNodeType=140

	UPDATE tblOLAPFullSalesHierarchy SET StarOutlet='No'
	UPDATE A SET A.StarOutlet='Yes' FROM tblOLAPFullSalesHierarchy A INNER JOIN StartOutletDump BB ON A.StoreID=BB.StoreID

	SELECT A.*
	FROM tblOLAPFullSalesHierarchy A LEFT OUTER JOIN tblRoutePlanningVisitDetail B ON A.RouteNodeId=B.RouteNodeId AND A.RouteNodeType=B.RouteNodetype
	WHERE B.RouteNodeId IS NULL AND B.RouteNodetype IS NULL
	
	--SELECT * FROM tblOLAPFullSalesHierarchy where RegionID IS NULL
	/*
	--ZSM Name Update
     UPDATE A SET A.Zone=A.Zone + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPFullSalesHierarchy A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=100) AA
    ON A.ZoneID=AA.NodeId AND A.ZoneNodeType=AA.NodeType
	WHERE A.ZoneID<>0

	--RSM Update
     UPDATE A SET A.Region=A.Region + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPCompanySalesStructure A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND B.NodeType=100) AA
    ON A.RegionId=AA.NodeId AND A.RegionNodeType=AA.NodeType
	WHERE A.RegionID<>0

    --ASM Name Update
    UPDATE A SET A.ASMArea=A.ASMArea + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPFullSalesHierarchy A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=110) AA
    ON A.ASMAreaID=AA.NodeId AND A.ASMAreaNodeType=AA.NodeType
	WHERE A.ASMAreaID<>0

    --SO Name Update
    UPDATE A SET A.SOArea=A.SOArea + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPFullSalesHierarchy A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=120) AA
    ON A.SOAreaID=AA.NodeId AND A.SOAreaNodeType=AA.NodeType
	WHERE A.SOAreaID<>0

    --CSR Name Update
    UPDATE A SET A.CoverageArea=A.CoverageArea + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPFullSalesHierarchy A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType IN(130,160)) AA
    ON A.CoverageAreaID=AA.NodeId AND A.CoverageAreaNodeType=AA.NodeType
	WHERE A.CoverageAreaNodeType<>150

	  --CSR Name Update
    UPDATE A SET A.Route=A.Route + '(' + ISNULL(AA.Descr,'Vacant') + ')'  FROM tblOLAPFullSalesHierarchy A LEFT JOIN
    (SELECT B.NodeId,B.NodeType,C.Descr FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType
    WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType IN(140,170)) AA
    ON A.RouteNodeId=AA.NodeId AND A.RouteNodeType=AA.NodeType
	WHERE A.RouteNodeType<>150
	*/
END












