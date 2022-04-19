CREATE proc spDataDumpProductPrice
as
begin
SELECT        r.PrcRegion, p.PrdCode, p.Product, p.Category, p.Brand, 'PCS' as UOM,1 as [Conversion Factor], p.Volume*1000 as [Weight In Gm], s.MRP, s.StandardRate as RLP,s.DistributorStandardRate AS DLP
FROM            tblPriceRegionMstr AS r INNER JOIN
                         tblPrdSKUSalesMapping AS s ON r.PrcRgnNodeId = s.PrcLocationId INNER JOIN
                         vwProductHierarchy AS p ON s.SKUNodeId = p.PrdNodeId AND s.SKUNodeType = p.PrdNodeType
WHERE        (s.UOMID = 3) and GETDATE() between s.FromDate and s.ToDate
UNION ALL
SELECT        r.PrcRegion, p.PrdCode, p.Product, p.Category, p.Brand, 'Case' as UOM,p.PcsInBox, p.Volume*1000*p.PcsInBox as [Weight In Gm], s.MRP, s.StandardRate,s.DistributorStandardRate
FROM            tblPriceRegionMstr AS r INNER JOIN
                         tblPrdSKUSalesMapping AS s ON r.PrcRgnNodeId = s.PrcLocationId INNER JOIN
                         vwProductHierarchy AS p ON s.SKUNodeId = p.PrdNodeId AND s.SKUNodeType = p.PrdNodeType
WHERE        (s.UOMID = 1) and GETDATE() between s.FromDate and s.ToDate
ORDER BY 1,2
end