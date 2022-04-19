
CREATE VIEW [dbo].[vwLocationHierarchy]
AS
SELECT        dbo.tblLocLvl1.NodeID AS CountryNodeId, dbo.tblLocLvl1.NodeType AS CountryNodeType, LocHier_1.HierID AS CountryHierId, dbo.tblLocLvl1.Descr AS Country, dbo.tblLocLvl2.NodeID AS StateNodeId, 
                         dbo.tblLocLvl2.NodeType AS StateNodeType, LocHier_2.HierID AS StateHierId, dbo.tblLocLvl2.Descr AS State, dbo.tblLocLvl3.NodeID AS DistrictNodeId, dbo.tblLocLvl3.NodeType AS DistrictNodeType, 
                         LocHier_3.HierID AS DistrictHierId, dbo.tblLocLvl3.Descr AS District, dbo.tblLocLvl4.NodeID AS CityNodeId, dbo.tblLocLvl4.NodeType AS CityNodeType, LocHier_4.HierID AS CityHierId, dbo.tblLocLvl4.Descr AS City, 
                         dbo.tblCompanySalesStructureMgnrLvl0.NodeID AS RegionNodeID, dbo.tblCompanySalesStructureMgnrLvl0.NodeType AS RegionNodeType, dbo.tblCompanySalesStructureMgnrLvl0.Descr AS Region
FROM            dbo.tblCompanySalesStructureMgnrLvl0 RIGHT OUTER JOIN
                         dbo.tblLocLvl1 INNER JOIN
                         dbo.tblMstrLocationHierarchy AS LocHier_1 ON dbo.tblLocLvl1.NodeID = LocHier_1.NodeID AND dbo.tblLocLvl1.NodeType = LocHier_1.NodeType INNER JOIN
                         dbo.tblMstrLocationHierarchy AS LocHier_2 ON LocHier_1.HierID = LocHier_2.PHierId INNER JOIN
                         dbo.tblLocLvl2 ON LocHier_2.NodeID = dbo.tblLocLvl2.NodeID AND LocHier_2.NodeType = dbo.tblLocLvl2.NodeType ON dbo.tblCompanySalesStructureMgnrLvl0.NodeID = dbo.tblLocLvl2.SalesNodeID AND 
                         dbo.tblCompanySalesStructureMgnrLvl0.NodeType = dbo.tblLocLvl2.SalesNodetype LEFT OUTER JOIN
                         dbo.tblLocLvl4 INNER JOIN
                         dbo.tblMstrLocationHierarchy AS LocHier_4 ON dbo.tblLocLvl4.NodeID = LocHier_4.NodeID AND dbo.tblLocLvl4.NodeType = LocHier_4.NodeType RIGHT OUTER JOIN
                         dbo.tblLocLvl3 INNER JOIN
                         dbo.tblMstrLocationHierarchy AS LocHier_3 ON dbo.tblLocLvl3.NodeID = LocHier_3.NodeID AND dbo.tblLocLvl3.NodeType = LocHier_3.NodeType ON LocHier_4.PHierId = LocHier_3.HierID ON 
                         LocHier_2.HierID = LocHier_3.PHierId
