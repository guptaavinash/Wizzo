





/*Select * from tblPMstNodeTypes*/
 CREATE VIEW [dbo].[vwProductHierarchy]
AS
SELECT        H1.PHierId AS BrndHierId, Brnd.NodeID AS BrndNodeID, Brnd.NodeType AS BrndNodeType, Brnd.Descr AS Brand, Brnd.Code AS BrandCode, H1.PHierId AS PrdHierId, Prd.NodeID AS PrdNodeId, 
                         Prd.NodeType AS PrdNodeType, Prd.SKUCode AS PrdCode, Prd.ShortDescr AS Product, Prd.Descr AS ProductFullDescr, Prd.PcsInBox, Grammage as Volume, '' AS VolUom, 0 as VolUomId, 
                         Prd.flgSaleType,Prd.SectorId,pb.CatName as Category,Prd.flgSeq
FROM            dbo.tblPrdMstrHierLvl1 AS Brnd INNER JOIN
                         dbo.tblPrdMstrHierarchy AS H1 ON Brnd.NodeID = H1.PNodeID AND Brnd.NodeType = H1.PNodeType INNER JOIN
                         dbo.tblPrdMstrSKULvl AS Prd ON H1.NodeID = Prd.NodeID AND H1.NodeType = Prd.NodeType 
						 --LEFT OUTER JOIN
       --                  dbo.tblPrdMstrBUOMMaster AS u ON u.BUOMID = Prd.VolUomId 
						 
						 INNER JOIN
                         dbo.tblPrdAttr_category AS pb ON pb.catid = Prd.PrdTypeId
WHERE        (Prd.IsActive = 1) and  GETDATE() between h1.VldFrom and H1.VldTo
