CREATE VIEW [dbo].[VwAllSalesHierarchy]
AS
SELECT NodeID, Descr, NodeType
FROM   tblCompanySalesStructureMgnrLvl0
UNION ALL
SELECT NodeID, Descr, NodeType
FROM   tblCompanySalesStructureMgnrLvl1
UNION ALL
SELECT NodeID, Descr, NodeType
FROM   tblCompanySalesStructureSprvsnLvl1
UNION ALL
SELECT NodeID, Descr, NodeType
FROM   tblCompanySalesStructureCoverage
