
CREATE VIEW [dbo].[VwAllDistributorHierarchy]
AS
SELECT dbo.tblDBRSalesStructureDBR.NodeID AS DBRNodeID, dbo.tblDBRSalesStructureDBR.DistributorCode, dbo.tblDBRSalesStructureDBR.Descr AS Distributor, dbo.tblDBRSalesStructureCoverage.NodeID AS DBRCoverageID, 
                  dbo.tblDBRSalesStructureCoverage.Descr AS DBRCoverage, dbo.tblDBRSalesStructureRouteMstr.NodeID AS DBRRouteID, dbo.tblDBRSalesStructureRouteMstr.Descr AS DBRRoute, DBRHierarchy.HierID AS DBRHierID, 
                  DBRSalesHierarchy.HierID AS DBRCoverageHierID, DBRRouteHierarchy.HierID AS DBRRouteHierID, DBRHierarchy.NodeType AS DistributorNodeType, DBRSalesHierarchy.NodeType AS DBRCoverageNodeType, 
                  DBRRouteHierarchy.NodeType AS RouteNodeType, dbo.tblDBRSalesStructureDBR.StateId
FROM     dbo.tblDBRSalesStructureRouteMstr INNER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS DBRRouteHierarchy ON dbo.tblDBRSalesStructureRouteMstr.NodeID = DBRRouteHierarchy.NodeID AND 
                  dbo.tblDBRSalesStructureRouteMstr.NodeType = DBRRouteHierarchy.NodeType RIGHT OUTER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS DBRSalesHierarchy INNER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS DBRHierarchy ON DBRSalesHierarchy.PHierId = DBRHierarchy.HierID INNER JOIN
                  dbo.tblDBRSalesStructureCoverage ON DBRSalesHierarchy.NodeID = dbo.tblDBRSalesStructureCoverage.NodeID AND DBRSalesHierarchy.NodeType = dbo.tblDBRSalesStructureCoverage.NodeType RIGHT OUTER JOIN
                  dbo.tblDBRSalesStructureDBR ON DBRHierarchy.NodeID = dbo.tblDBRSalesStructureDBR.NodeID AND DBRHierarchy.NodeType = dbo.tblDBRSalesStructureDBR.NodeType ON 
                  DBRRouteHierarchy.PHierId = DBRSalesHierarchy.HierID
GROUP BY dbo.tblDBRSalesStructureDBR.NodeID, dbo.tblDBRSalesStructureDBR.DistributorCode, dbo.tblDBRSalesStructureDBR.Descr, dbo.tblDBRSalesStructureCoverage.NodeID, dbo.tblDBRSalesStructureCoverage.Descr, 
                  dbo.tblDBRSalesStructureRouteMstr.NodeID, dbo.tblDBRSalesStructureRouteMstr.Descr, DBRHierarchy.HierID, DBRSalesHierarchy.HierID, DBRRouteHierarchy.HierID, DBRHierarchy.NodeType, DBRSalesHierarchy.NodeType, 
                  DBRRouteHierarchy.NodeType, dbo.tblDBRSalesStructureDBR.StateId
