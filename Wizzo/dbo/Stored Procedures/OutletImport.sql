-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OutletImport] 
	
AS
BEGIN
	--DELETE FROM OutletMasterLoad
	UPDATE OutletMasterLoad SET StoreiD=NULL,RouteNodeID=NULL,CovNodeID=NULL,DHNodeID=NULL,DHNodeType=NULL

	INSERT INTO tblDBRSalesStructureDBR(Descr,DistributorCode,NodeType,IsActive,FileSetIDIns,TimestampIns,flgLive,DlvryWeeklyOffDay,OfficeWeeklyOffDay,IsSuperStockiest)
	SELECT DISTINCT Distributor,T.DistributorCode,150,1,0,GETDATE(),1,7,7,0 FROM OutletMasterLoad T LEFT OUTER JOIN tblDBRSalesStructureDBR D ON D.DistributorCode=T.DistributorCode WHERE D.NodeID IS NULL AND T.Distributor IS NOT NULL

	UPDATE T SET DHNOdeID=B.NodeID,DHNodeType=B.NodeType FROM OutletMasterLoad T INNER JOIN tblDBRSalesStructureDBR B ON B.DistributorCode=T.DistributorCode

	UPDATE O SET CovNodeID=SM.NodeID FROM OutletMasterLoad O INNER JOIN tblMstrPerson P ON P.Descr=O.[User ] INNER JOIN tblSalesPersonMapping SM ON SM.PersonNodeID=P.NodeID AND CAST(GETDATE() AS DATE) BETWEEN SM.FromDate AND SM.ToDate WHERE P.flgSFAUser=1

	UPDATE O SET CovNodeID=SM.NodeID FROM OutletMasterLoad O INNER JOIN tblMstrPerson P ON P.Code=O.UserErpID INNER JOIN tblSalesPersonMapping SM ON SM.PersonNodeID=P.NodeID AND CAST(GETDATE() AS DATE) BETWEEN SM.FromDate AND SM.ToDate WHERE P.flgSFAUser=1
	
	INSERT INTO tblCompanySalesStructure_DistributorMapping(DHNodeID,DHNodeType,SHNodeID,SHNodeType,TimestampIns,LoginIDIns,FromDate,ToDate,flgSup)
	SELECT DISTINCT T.DHNodeID,T.DHNodeType,CovNodeID,130,GETDATE(),0,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0 FROM OutletMasterLoad T LEFT OUTER JOIN tblCompanySalesStructure_DistributorMapping D ON D.DHNodeID=T.DHNodeID AND D.DHNodeType=T.DHNodeType AND D.SHNOdeID=T.CovNodeID AND D.SHNodeType=130 AND CAST(GETDATE() AS DATE) BETWEEN D.FromDate AND D.ToDate AND T.DHNodeID IS NOT NULL AND D.DHNodeID IS NULL WHERE T.DHNodeID IS NOT NULL

	UPDATE T SET StateID=L.NodeID FROM OutletMasterLoad T INNER JOIN tblLocLvl2 L ON L.Descr=T.state

	insert into tblSalesHier_GeoHierMapping(GeoNodeId,GeoNodeType,SalesAreaNodeId,SalesAreaNodeType,FromDate,ToDate)
	select distinct StateId,310,DHNodeID,150,getdate(),'31-Dec-2049'
	from OutletMasterLoad A left outer join tblSalesHier_GeoHierMapping b on a.DHNodeID=b.SalesAreaNodeId and b.SalesAreaNodeType=150 and a.StateId=b.GeoNodeId and b.GeoNodeType=310 
	where b.GeoNodeId is null and b.GeoNodeType is null and b.SalesAreaNodeId is null and b.SalesAreaNodeType is null and a.DHNodeID is not null




	UPDATE R SET RouteNodeID=NULL FROM OutletMasterLoad R

	SELECT [Outlet erp id],COUNT(DISTINCT [Route Erpid]) FROM OutletMasterLoad GROUP BY [Outlet erp id] hAVING COUNT(DISTINCT [Route Erpid])>1
	--DELETE D FROM OutletMasterLoad D WHERE [Outlet Erp Id] IN (SELECT [Outlet erp id] FROM OutletMasterLoad GROUP BY [Outlet erp id] hAVING COUNT(DISTINCT [Route Erpid])>1)

	SELECT * FROM OutletMasterLoad WHERE RouteNodeID IS NULL

	

	UPDATE O SET StoreID=P.StoreID FROM OutletMasterLoad O INNER JOIN tblStoreMaster P ON P.StoreCode=O.[Outlet Erp Id]

	SELECT * FROM OutletMasterLoad WHERE StoreID IS NULL
	SELECT * FROM OutletMasterLoad WHERE CovNodeID IS NULL

	
	SELECT Code,COUNT(DISTINCT NodeID) FROM tblCompanySalesStructureRouteMstr WHERE Code IN (SELECT [Route ErpId] FROM OutletMasterLoad WHERE CovNodeID IS NOT NULL)  GROUP BY Code HAVING COUNT(DISTINCT NodeID)>1

	UPDATE O SET RouteNodeID=P.NodeID FROM OutletMasterLoad O INNER JOIN tblCompanySalesStructureRouteMstr P ON P.Code=O.[Route ErpId]

	--SELECT DISTINCT RH.* INTO #Hierbackup  FROM tblCompanySalesStructureHierarchy RH INNER JOIN tblCompanySalesStructureHierarchy PH ON PH.NodeID=RH.PNodeID AND PH.NodeType=RH.PNodeType LEFT OUTER JOIN OutletMasterLoad O ON O.RouteNodeID=RH.NodeID AND RH.PNodeID=O.CovNodeID  WHERE O.StoreID IS NULL AND RH.NodeType=140 AND PH.NodeID IN (SELECT DISTINCT CovNodeID FROM OutletMasterLoad) AND PH.NodeType=130

	--SELECT * FROM #Hierbackup
	SELECT * FROM OutletMasterLoad WHERE RouteNodeID IS NULL
	--SELECT * FROM tblCompanySalesStructureHierarchy WHERE NodeID=44366 AND NodeType=140

	DELETE RS FROM tblRouteCoverageStoreMapping RS INNER JOIN OutletMasterLoad O ON O.StoreID=RS.StoreID WHERE CovNodeID IS NOT NULL


	--INSERT INTO tblCompanySalesStructureHierarchy_Backup(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	--SELECT DISTINCT RH.NodeID,rh.NodeType,RH.PNodeID,RH.PNodeType,RH.HierTypeID,RH.PHierId,RH.VldFrom,DATEADD(d,-1,GETDATE()),0  FROM #Hierbackup RH

	--DELETE H FROM tblCompanySalesStructureHierarchy H INNER JOIN #Hierbackup B ON B.HierID=H.HierID

	--INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	--SELECT DISTINCT RouteNodeID,140,CovNodeID,130,1,PH.HierID,GETDATE(),'31-Dec-2049',0 FROM OutletMasterLoad O INNER JOIN tblCompanySalesStructureHierarchy PH ON PH.NodeID=O.CovNodeID AND PH.NodeType=130  LEFT OUTER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=O.RouteNodeID AND H.NodeType=140 AND H.PNodeID=PH.NodeID AND H.PNodeType=PH.NodeType WHERE H.HierID IS NULL

	UPDATE RS SET ToDate=DATEADD(d,-1,GETDATE()) FROM tblRouteCoverageStoreMapping RS INNER JOIN OutletMasterLoad O ON O.StoreID=RS.StoreID AND O.RouteNodeID<>RS.RouteID AND RS.RouteNodeType=140 AND CAST(GETDATE() AS DATE) BETWEEN RS.FromDate AND RS.ToDate AND O.CovNodeID IS NOT NULL

	--SELECT * FROM OutletMasterLoad WHERE StoreID=47
	--SELECT * FROM tblRouteCoverageStoreMapping WHERE StoreID=47

	UPDATE S SET [Lat Code]=O.LatCode,[Long Code]=O.longCode FROM tblStoreMaster S INNER JOIN OutletMasterLoad O ON O.StoreID=S.StoreID WHERE CovNodeID IS NOT NULL --AND CAST(S.[Lat Code] AS FLOAT)=0

	INSERT INTO tblRouteCoverageStoreMapping(RouteID,RouteNodeType,StoreID,FromDate,ToDate,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,DisplaySeq)
	SELECT DISTINCT O.RouteNodeID,140,O.StoreID,GETDATE(),'31-Dec-2049',0,GETDATE(),NULL,NULL,0 FROM OutletMasterLoad O LEFT OUTER JOIN tblRouteCoverageStoreMapping RS ON RS.StoreID=O.StoreID AND RS.RouteID=O.RouteNodeID AND RS.RouteNodeType=140 WHERE RS.StoreID IS NULL AND O.RouteNodeID IS NOT NULL AND O.CovNodeID IS NOT NULL AND O.StoreID IS NOT NULL


END
