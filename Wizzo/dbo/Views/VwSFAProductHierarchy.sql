CREATE VIEW dbo.VwSFAProductHierarchy
AS
SELECT DISTINCT 
                  Lvl1.HierID AS CategoryHierID, dbo.tblPrdMstrHierLvl1.NodeID AS CategoryNodeID, dbo.tblPrdMstrHierLvl1.NodeType AS CategoryNodeType, dbo.tblPrdMstrHierLvl1.Descr AS Category, SKULvl.HierID AS SKUHierID, 
                  SKULvl.NodeID AS SKUNodeID, SKULvl.NodeType AS SKUNodeType, dbo.tblPrdMstrSKULvl.Descr AS SKU, dbo.tblPrdMstrSKULvl.MRP, dbo.tblPrdMstrSKULvl.CostToRetailer, dbo.tblPrdMstrSKULvl.ShortDescr AS SKUShortDescr, 
                  dbo.tblPrdMstrSKULvl.UOMID, dbo.tblPrdMstrSKULvl.Grammage, dbo.tblPrdMstrBUOMMaster.BUOMName AS UOM, dbo.tblPrdMstrSKULvl.RetMarginPer, dbo.tblPrdMstrSKULvl.Tax, dbo.tblPrdMstrSKULvl.StandardRate, 
                  dbo.tblPrdMstrSKULvl.StandardRateBeforeTax, dbo.tblPrdMstrSKULvl.StandardTax, dbo.tblPrdMstrSKULvl.SKUCode, dbo.tblPrdMstrHierLvl1.flgSeq AS CatOrdr, dbo.tblPrdMstrSKULvl.ProductSeq AS SKUOrdr, 
                  dbo.tblPrdMstrSKULvl.DistMarginPer, dbo.tblPrdMstrSKULvl.StandardRateForDist, dbo.tblPrdMstrSKULvl.PcsInBox, dbo.tblPrdMstrSKULvl.IsActive, 0 AS flgPriority, dbo.tblPrdMstrSKULvl.WarehouseId, dbo.tblPrdMstrSKULvl.HSNCode, 
                  0 AS StandardRateWholeSale, 0 AS StandardRateBeforeTaxWholeSale, 0 AS StandardTaxWholeSale, dbo.tblPrdMstrSKULvl.PhotoName, dbo.tblPrdMstrSKULvl.UOMValue, dbo.tblPrdMstrSKULvl.UOMType
FROM     dbo.tblPrdMstrHierarchy AS SKULvl INNER JOIN
                  dbo.tblPrdMstrSKULvl ON SKULvl.NodeID = dbo.tblPrdMstrSKULvl.NodeID AND SKULvl.NodeType = dbo.tblPrdMstrSKULvl.NodeType INNER JOIN
                  dbo.tblPrdMstrHierarchy AS Lvl1 ON Lvl1.NodeID = SKULvl.PNodeID AND Lvl1.NodeType = SKULvl.PNodeType AND CAST(GETDATE() AS DATE) BETWEEN SKULvl.VldFrom AND SKULvl.VldTo INNER JOIN
                  dbo.tblPrdMstrHierLvl1 ON Lvl1.NodeID = dbo.tblPrdMstrHierLvl1.NodeID AND Lvl1.NodeType = dbo.tblPrdMstrHierLvl1.NodeType LEFT OUTER JOIN
                  dbo.tblPrdMstrBUOMMaster ON dbo.tblPrdMstrBUOMMaster.BUOMID = dbo.tblPrdMstrSKULvl.UOMID
WHERE  (dbo.tblPrdMstrHierLvl1.NodeID <> 2)

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[27] 4[16] 2[39] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SKULvl"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblPrdMstrSKULvl"
            Begin Extent = 
               Top = 40
               Left = 476
               Bottom = 203
               Right = 728
            End
            DisplayFlags = 280
            TopColumn = 51
         End
         Begin Table = "Lvl1"
            Begin Extent = 
               Top = 343
               Left = 48
               Bottom = 506
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblPrdMstrHierLvl1"
            Begin Extent = 
               Top = 511
               Left = 48
               Bottom = 674
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblPrdMstrBUOMMaster"
            Begin Extent = 
               Top = 679
               Left = 48
               Bottom = 842
               Right = 262
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
        ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwSFAProductHierarchy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwSFAProductHierarchy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwSFAProductHierarchy';

