CREATE VIEW dbo.VwCompanySalesHierarchy
AS
SELECT        dbo.tblCompanySalesStructureMgnrLvl0.NodeID AS ZoneID, dbo.tblCompanySalesStructureMgnrLvl0.Descr AS Zone, dbo.tblCompanySalesStructureMgnrLvl1.NodeID AS RegionID, 
                         dbo.tblCompanySalesStructureMgnrLvl1.Descr AS Region, dbo.tblCompanySalesStructureMgnrLvl2.NodeID AS ASMAreaID, dbo.tblCompanySalesStructureMgnrLvl2.Descr AS ASMArea, 
                         dbo.tblCompanySalesStructureSprvsnLvl1.NodeID AS SOAreaID, dbo.tblCompanySalesStructureSprvsnLvl1.Descr AS SOArea, ISNULL(dbo.tblCompanySalesStructureCoverage.NodeID, 0) AS DSRAreaID, 
                         ISNULL(dbo.tblCompanySalesStructureCoverage.Descr, 'NA') AS DSRArea, dbo.tblCompanySalesStructureSprvsnLvl1.NodeType AS SOAreaNodeType, dbo.tblCompanySalesStructureMgnrLvl1.NodeType AS RegionNodeType, 
                         dbo.tblCompanySalesStructureMgnrLvl2.NodeType AS ASMAreaNodeType, ISNULL(dbo.tblCompanySalesStructureCoverage.NodeType, 0) AS DSRAreaNodeType, 
                         dbo.tblCompanySalesStructureMgnrLvl0.NodeType AS ZoneNodeType, DSRHierarchy.HierID AS DSRAreaHierId, SOHierarchy.HierID AS SOAreaHierId, ASMHierarchy.HierID AS ASMAreaHierId, 
                         RegionHierarchy.HierID AS RegionHierId, ZoneHier.HierID AS ZoneHierId
FROM            dbo.tblCompanySalesStructureHierarchy AS ZoneHier INNER JOIN
                         dbo.tblCompanySalesStructureHierarchy AS ASMHierarchy INNER JOIN
                         dbo.tblCompanySalesStructureHierarchy AS RegionHierarchy INNER JOIN
                         dbo.tblCompanySalesStructureMgnrLvl0 ON RegionHierarchy.PNodeID = dbo.tblCompanySalesStructureMgnrLvl0.NodeID AND RegionHierarchy.PNodeType = dbo.tblCompanySalesStructureMgnrLvl0.NodeType INNER JOIN
                         dbo.tblCompanySalesStructureMgnrLvl1 ON RegionHierarchy.NodeID = dbo.tblCompanySalesStructureMgnrLvl1.NodeID AND RegionHierarchy.NodeType = dbo.tblCompanySalesStructureMgnrLvl1.NodeType ON 
                         ASMHierarchy.PHierId = RegionHierarchy.HierID INNER JOIN
                         dbo.tblCompanySalesStructureHierarchy AS SOHierarchy ON ASMHierarchy.HierID = SOHierarchy.PHierId INNER JOIN
                         dbo.tblCompanySalesStructureMgnrLvl2 ON ASMHierarchy.NodeID = dbo.tblCompanySalesStructureMgnrLvl2.NodeID AND ASMHierarchy.NodeType = dbo.tblCompanySalesStructureMgnrLvl2.NodeType INNER JOIN
                         dbo.tblCompanySalesStructureSprvsnLvl1 ON SOHierarchy.NodeID = dbo.tblCompanySalesStructureSprvsnLvl1.NodeID AND SOHierarchy.NodeType = dbo.tblCompanySalesStructureSprvsnLvl1.NodeType ON 
                         ZoneHier.NodeID = dbo.tblCompanySalesStructureMgnrLvl0.NodeID AND ZoneHier.NodeType = dbo.tblCompanySalesStructureMgnrLvl0.NodeType LEFT OUTER JOIN
                         dbo.tblCompanySalesStructureHierarchy AS DSRHierarchy INNER JOIN
                         dbo.tblCompanySalesStructureCoverage ON DSRHierarchy.NodeID = dbo.tblCompanySalesStructureCoverage.NodeID AND DSRHierarchy.NodeType = dbo.tblCompanySalesStructureCoverage.NodeType ON 
                         SOHierarchy.HierID = DSRHierarchy.PHierId

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[46] 2[30] 3) )"
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
         Configuration = "(H (1[63] 2) )"
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
      ActivePaneConfig = 2
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DSRHierarchy"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblCompanySalesStructureCoverage"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ASMHierarchy"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RegionHierarchy"
            Begin Extent = 
               Top = 72
               Left = 548
               Bottom = 202
               Right = 718
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblCompanySalesStructureMgnrLvl0"
            Begin Extent = 
               Top = 274
               Left = 689
               Bottom = 404
               Right = 859
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblCompanySalesStructureMgnrLvl1"
            Begin Extent = 
               Top = 255
               Left = 305
               Bottom = 385
               Right = 475
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SOHierarchy"
            Begin Extent = 
               Top = 402
               Left = 38
        ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwCompanySalesHierarchy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'       Bottom = 532
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblCompanySalesStructureMgnrLvl2"
            Begin Extent = 
               Top = 402
               Left = 246
               Bottom = 532
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblCompanySalesStructureSprvsnLvl1"
            Begin Extent = 
               Top = 581
               Left = 269
               Bottom = 711
               Right = 439
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ZoneHier"
            Begin Extent = 
               Top = 156
               Left = 963
               Bottom = 286
               Right = 1133
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
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwCompanySalesHierarchy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwCompanySalesHierarchy';

