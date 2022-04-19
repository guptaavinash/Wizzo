CREATE VIEW dbo.VwCompanyDSRFullDetail
AS
SELECT DISTINCT 
                  RSMArea.NodeID AS RSMAreaID, RSMArea.NodeType AS RSMAreaType, RSMArea.Descr AS RSMArea, StateHeadArea.NodeID AS StateHeadAreaID, StateHeadArea.NodeType, StateHeadArea.Descr AS StateHeadArea, 
                  ASMArea.NodeID AS ASMAreaID, ASMArea.NodeType AS ASMAreaNodeType, ASMArea.Descr AS ASMArea, SOArea.NodeID AS SOAreaID, SOArea.Descr AS SOArea, ISNULL(DSRCoverageArea.NodeID, 0) AS DSRAreaID, 
                  ISNULL(DSRCoverageArea.Descr, 'NA') AS DSRArea, SOArea.NodeType AS SOAreaNodeType, StateHeadArea.NodeType AS StateHeadAreaNodeType, ISNULL(DSRCoverageArea.NodeType, 0) AS DSRAreaNodeType, 
                  RSM.Descr AS RSM, RSM.NodeID AS RSMID, RSM.NodeType AS RSMPersonType, StateHead.Descr AS StateHead, StateHead.NodeType AS StateHeadNodeType, StateHead.NodeID AS StateHeadID, 
                  ASMMapping.PersonNodeID AS ASMID, ASM.Code AS ASMEmpCode, ASM.Descr AS ASM, SO.NodeID AS SOID, SO.Descr AS SO, SO.NodeType AS SONodeType, CompanyDSR.NodeID AS CompanyDSRID, 
                  CompanyDSR.Descr AS CompanyDSR, CompanyDSR.NodeType AS CompanyDSRNodeType, DSRCoverageArea.IsActive AS IsDSRCoverage, SOArea.IsActive AS IsSOCoverage, CompanyDSR.Code AS [DSR EmpCode]
FROM     dbo.tblCompanySalesStructureMgnrLvl0 AS RSMArea INNER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS RSMHierarchy ON RSMArea.NodeID = RSMHierarchy.NodeID AND RSMArea.NodeType = RSMHierarchy.NodeType INNER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS StateHeadHierarchy ON RSMHierarchy.HierID = StateHeadHierarchy.PHierId INNER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS ASMHierarchy ON ASMHierarchy.PHierId = StateHeadHierarchy.HierID INNER JOIN
                  dbo.tblCompanySalesStructureMgnrLvl1 AS StateHeadArea ON StateHeadHierarchy.NodeID = StateHeadArea.NodeID AND StateHeadHierarchy.NodeType = StateHeadArea.NodeType INNER JOIN
                  dbo.tblCompanySalesStructureMgnrLvl2 AS ASMArea ON ASMArea.NodeID = ASMHierarchy.NodeID AND ASMArea.NodeType = ASMHierarchy.NodeType INNER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS SOHierarchy ON SOHierarchy.PHierId = ASMHierarchy.HierID INNER JOIN
                  dbo.tblCompanySalesStructureSprvsnLvl1 AS SOArea ON SOArea.NodeID = SOHierarchy.NodeID AND SOArea.NodeType = SOHierarchy.NodeType INNER JOIN
                  dbo.tblCompanySalesStructureHierarchy AS DSRHierarchy ON SOHierarchy.HierID = DSRHierarchy.PHierId INNER JOIN
                  dbo.tblCompanySalesStructureCoverage AS DSRCoverageArea ON DSRHierarchy.NodeID = DSRCoverageArea.NodeID AND DSRHierarchy.NodeType = DSRCoverageArea.NodeType LEFT OUTER JOIN
                  dbo.tblSalesPersonMapping AS RSMMapping ON RSMArea.NodeType = RSMMapping.NodeType AND RSMArea.NodeID = RSMMapping.NodeID AND GETDATE() BETWEEN RSMMapping.FromDate AND 
                  RSMMapping.ToDate LEFT OUTER JOIN
                  dbo.tblMstrPerson AS RSM ON RSM.NodeID = RSMMapping.PersonNodeID AND RSM.NodeType = RSMMapping.PersonType LEFT OUTER JOIN
                  dbo.tblSalesPersonMapping AS StateHeadMapping ON StateHeadArea.NodeID = StateHeadMapping.NodeID AND StateHeadArea.NodeType = StateHeadMapping.NodeType AND GETDATE() BETWEEN StateHeadMapping.FromDate AND 
                  StateHeadMapping.ToDate LEFT OUTER JOIN
                  dbo.tblMstrPerson AS StateHead ON StateHeadMapping.PersonNodeID = StateHead.NodeID AND StateHeadMapping.PersonType = StateHead.NodeType LEFT OUTER JOIN
                  dbo.tblSalesPersonMapping AS ASMMapping ON ASMHierarchy.NodeID = ASMMapping.NodeID AND ASMHierarchy.NodeType = ASMMapping.NodeType AND GETDATE() BETWEEN ASMMapping.FromDate AND 
                  ASMMapping.ToDate LEFT OUTER JOIN
                  dbo.tblMstrPerson AS ASM ON ASM.NodeID = ASMMapping.PersonNodeID AND ASM.NodeType = ASMMapping.PersonType LEFT OUTER JOIN
                  dbo.tblSalesPersonMapping AS SOMapping ON SOMapping.NodeID = SOArea.NodeID AND SOMapping.NodeType = SOArea.NodeType AND GETDATE() BETWEEN SOMapping.FromDate AND SOMapping.ToDate LEFT OUTER JOIN
                  dbo.tblMstrPerson AS SO ON SO.NodeID = SOMapping.PersonNodeID AND SO.NodeType = SOMapping.PersonType LEFT OUTER JOIN
                  dbo.tblSalesPersonMapping AS DSRMapping ON DSRCoverageArea.NodeID = DSRMapping.NodeID AND DSRCoverageArea.NodeType = DSRMapping.NodeType AND GETDATE() BETWEEN DSRMapping.FromDate AND 
                  DSRMapping.ToDate LEFT OUTER JOIN
                  dbo.tblMstrPerson AS CompanyDSR ON CompanyDSR.NodeID = DSRMapping.PersonNodeID AND CompanyDSR.NodeType = DSRMapping.PersonType

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[33] 2[7] 3) )"
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
         Top = -1080
         Left = 0
      End
      Begin Tables = 
         Begin Table = "RSMArea"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RSMHierarchy"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 338
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "StateHeadHierarchy"
            Begin Extent = 
               Top = 343
               Left = 48
               Bottom = 506
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ASMHierarchy"
            Begin Extent = 
               Top = 511
               Left = 48
               Bottom = 674
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "StateHeadArea"
            Begin Extent = 
               Top = 679
               Left = 48
               Bottom = 842
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ASMArea"
            Begin Extent = 
               Top = 847
               Left = 48
               Bottom = 1010
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SOHierarchy"
            Begin Extent = 
               Top = 1015
               Left = 48
               Bottom = 1178
               Right = 242
            E', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwCompanyDSRFullDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'nd
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SOArea"
            Begin Extent = 
               Top = 1183
               Left = 48
               Bottom = 1346
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "DSRHierarchy"
            Begin Extent = 
               Top = 1351
               Left = 48
               Bottom = 1514
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DSRCoverageArea"
            Begin Extent = 
               Top = 1519
               Left = 48
               Bottom = 1682
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RSMMapping"
            Begin Extent = 
               Top = 1687
               Left = 48
               Bottom = 1850
               Right = 276
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RSM"
            Begin Extent = 
               Top = 1855
               Left = 48
               Bottom = 2018
               Right = 293
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "StateHeadMapping"
            Begin Extent = 
               Top = 2023
               Left = 48
               Bottom = 2186
               Right = 276
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "StateHead"
            Begin Extent = 
               Top = 2191
               Left = 48
               Bottom = 2354
               Right = 293
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ASMMapping"
            Begin Extent = 
               Top = 2359
               Left = 48
               Bottom = 2522
               Right = 276
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ASM"
            Begin Extent = 
               Top = 2527
               Left = 48
               Bottom = 2690
               Right = 293
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SOMapping"
            Begin Extent = 
               Top = 2695
               Left = 48
               Bottom = 2858
               Right = 276
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SO"
            Begin Extent = 
               Top = 2863
               Left = 48
               Bottom = 3026
               Right = 293
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DSRMapping"
            Begin Extent = 
               Top = 3031
               Left = 48
               Bottom = 3194
               Right = 276
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CompanyDSR"
            Begin Extent = 
               Top = 3199
               Left = 48
               Bottom = 3362
               Right = 293
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
         A', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwCompanyDSRFullDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane3', @value = N'lias = 2796
         Table = 3648
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwCompanyDSRFullDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 3, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwCompanyDSRFullDetail';

