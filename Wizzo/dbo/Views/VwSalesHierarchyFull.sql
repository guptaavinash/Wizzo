CREATE VIEW dbo.VwSalesHierarchyFull
AS
SELECT DISTINCT 
                  H1.PHierId AS ZnHierId, Zn.NodeID AS ZnNodeId, Zn.NodeType AS ZnNodeType, Zn.Code AS ZoneCode, Zn.Descr AS Zone, H1.HierID AS RegHierId, Reg.NodeID AS RegNodeId, Reg.NodeType AS RegNodeType, Reg.Code AS RegCode, 
                  Reg.Descr AS Region, H2.HierID AS ASMAreaHierId, Aa.NodeID AS ASMAreaNodeId, Aa.NodeType AS ASMAreaNodeType, Aa.Descr AS ASMArea, Aa.Code AS ASMAreaCode, H3.HierID AS SOAreaHierId, SO.NodeID AS SOAreaNodeId, 
                  SO.NodeType AS SOAreaNodeType, SO.UnqCode AS SOareaCode, SO.Descr AS SOArea, ZSM.Code AS ZSMCode, ZSM.Descr AS ZSMName, RSM.Code AS RSMCode, RSM.Descr AS RSMName, ASMN.Code AS ASMCode, 
                  ASMN.Descr AS ASMName, TSO.Code AS SOCode, TSO.Descr AS SOName, TSO.NodeID AS SONodeid, TSO.NodeType AS SONodeType, Cov.NodeID AS ComCoverageAreaID, Cov.NodeType AS ComCoverageAreaType, 
                  Cov.Descr AS ComCoverageArea, DSM.NodeID AS DSMID, DSM.Code AS DSMCode, DSM.Descr AS DSM
FROM     dbo.tblMstrPerson AS DSM INNER JOIN
                  dbo.tblSalesPersonMapping AS CovMap ON DSM.NodeID = CovMap.PersonNodeID RIGHT OUTER JOIN
                  dbo.tblCompanySalesStructureCoverage AS Cov INNER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS H4 ON Cov.NodeID = H4.NodeID AND Cov.NodeType = H4.NodeType INNER JOIN
                  dbo.tblCompanySalesStructureMgnrLvl0 AS Zn INNER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS H1 ON Zn.NodeID = H1.PNodeID AND Zn.NodeType = H1.PNodeType INNER JOIN
                  dbo.tblCompanySalesStructureMgnrLvl1 AS Reg ON H1.NodeID = Reg.NodeID AND H1.NodeType = Reg.NodeType INNER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS H2 ON H1.HierID = H2.PHierId INNER JOIN
                  dbo.tblCompanySalesStructureMgnrLvl2 AS Aa ON H2.NodeID = Aa.NodeID AND H2.NodeType = Aa.NodeType INNER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS H3 ON H2.HierID = H3.PHierId INNER JOIN
                  dbo.tblCompanySalesStructureSprvsnLvl1 AS SO ON H3.NodeID = SO.NodeID AND H3.NodeType = SO.NodeType INNER JOIN
                  dbo.tblSalesPersonMapping AS ZnMap ON ZnMap.NodeID = Zn.NodeID AND ZnMap.NodeType = Zn.NodeType AND CONVERT(date, GETDATE()) BETWEEN ZnMap.FromDate AND ZnMap.ToDate INNER JOIN
                  dbo.tblMstrPerson AS ZSM ON ZSM.NodeID = ZnMap.PersonNodeID INNER JOIN
                  dbo.tblSalesPersonMapping AS RSMMap ON RSMMap.NodeID = Reg.NodeID AND RSMMap.NodeType = Reg.NodeType AND CONVERT(date, GETDATE()) BETWEEN RSMMap.FromDate AND RSMMap.ToDate INNER JOIN
                  dbo.tblMstrPerson AS RSM ON RSM.NodeID = RSMMap.PersonNodeID INNER JOIN
                  dbo.tblSalesPersonMapping AS ASMMap ON ASMMap.NodeID = Aa.NodeID AND ASMMap.NodeType = Aa.NodeType AND CONVERT(date, GETDATE()) BETWEEN ASMMap.FromDate AND ASMMap.ToDate INNER JOIN
                  dbo.tblMstrPerson AS ASMN ON ASMN.NodeID = ASMMap.PersonNodeID INNER JOIN
                  dbo.tblSalesPersonMapping AS SoMap ON SoMap.NodeID = SO.NodeID AND SoMap.NodeType = SO.NodeType AND CONVERT(date, GETDATE()) BETWEEN SoMap.FromDate AND SoMap.ToDate INNER JOIN
                  dbo.tblMstrPerson AS TSO ON TSO.NodeID = SoMap.PersonNodeID ON H4.PHierId = H3.HierID ON CovMap.NodeID = Cov.NodeID AND CovMap.NodeType = Cov.NodeType

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
         Configuration = "(H (1[50] 4[25] 3) )"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[42] 2[34] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1[83] 3) )"
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
         Configuration = "(H (1[75] 4) )"
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
      ActivePaneConfig = 2
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -120
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DSM"
            Begin Extent = 
               Top = 591
               Left = 1483
               Bottom = 754
               Right = 1703
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CovMap"
            Begin Extent = 
               Top = 415
               Left = 1476
               Bottom = 578
               Right = 1704
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Cov"
            Begin Extent = 
               Top = 205
               Left = 1466
               Bottom = 368
               Right = 1663
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "H4"
            Begin Extent = 
               Top = 410
               Left = 1228
               Bottom = 573
               Right = 1422
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "Zn"
            Begin Extent = 
               Top = 7
               Left = 592
               Bottom = 170
               Right = 789
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "H1"
            Begin Extent = 
               Top = 7
               Left = 837
               Bottom = 170
               Right = 1031
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Reg"
            Begin Extent = 
               Top = 7
               Left = 1079
               Bottom = 170
               Right = 1276
            End
            DisplayFlags = 280
            To', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwSalesHierarchyFull';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'pColumn = 0
         End
         Begin Table = "H2"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 338
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Aa"
            Begin Extent = 
               Top = 175
               Left = 290
               Bottom = 338
               Right = 487
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "H3"
            Begin Extent = 
               Top = 175
               Left = 535
               Bottom = 338
               Right = 729
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SO"
            Begin Extent = 
               Top = 175
               Left = 777
               Bottom = 338
               Right = 974
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ZnMap"
            Begin Extent = 
               Top = 195
               Left = 1067
               Bottom = 358
               Right = 1295
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ZSM"
            Begin Extent = 
               Top = 343
               Left = 48
               Bottom = 506
               Right = 268
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RSMMap"
            Begin Extent = 
               Top = 343
               Left = 316
               Bottom = 506
               Right = 544
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RSM"
            Begin Extent = 
               Top = 343
               Left = 592
               Bottom = 506
               Right = 812
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ASMMap"
            Begin Extent = 
               Top = 343
               Left = 860
               Bottom = 506
               Right = 1088
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ASMN"
            Begin Extent = 
               Top = 511
               Left = 48
               Bottom = 674
               Right = 268
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SoMap"
            Begin Extent = 
               Top = 511
               Left = 316
               Bottom = 674
               Right = 544
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TSO"
            Begin Extent = 
               Top = 511
               Left = 592
               Bottom = 674
               Right = 812
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
      Begin ColumnWidths = 37
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwSalesHierarchyFull';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane3', @value = N'         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
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
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwSalesHierarchyFull';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 3, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwSalesHierarchyFull';

