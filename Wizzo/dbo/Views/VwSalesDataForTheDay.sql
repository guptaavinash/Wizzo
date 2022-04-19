CREATE VIEW dbo.VwSalesDataForTheDay
AS
SELECT dbo.tblMstrPerson.Code, dbo.tblMstrPerson.Descr, dbo.tblStoreMaster.StoreCode, dbo.tblStoreMaster.StoreName, dbo.VwSFAProductHierarchy.Category, dbo.VwSFAProductHierarchy.SKU, dbo.VwSFAProductHierarchy.MRP, 
                  dbo.tblOrderMaster.OrderCode, dbo.tblOrderMaster.OrderDate, dbo.tblOrderMaster.NetOrderValue, dbo.VwSFAProductHierarchy.SKUCode, dbo.VwSFAProductHierarchy.UOMValue, dbo.tblOrderDetail.OrderQty, 
                  dbo.tblOrderDetail.ProductRate, dbo.tblOrderDetail.LineOrderVal, dbo.tblOrderDetail.TotLineDiscVal, dbo.tblOrderDetail.NetLineOrderVal, dbo.tblOrderDetail.FreeQty
FROM     dbo.VwSFAProductHierarchy INNER JOIN
                  dbo.tblMstrPerson INNER JOIN
                  dbo.tblSalesPersonMapping ON dbo.tblMstrPerson.NodeID = dbo.tblSalesPersonMapping.PersonNodeID INNER JOIN
                  dbo.VwCompanySalesHierarchy ON dbo.tblSalesPersonMapping.NodeID = dbo.VwCompanySalesHierarchy.DSRAreaID AND dbo.tblSalesPersonMapping.NodeType = dbo.VwCompanySalesHierarchy.DSRAreaNodeType INNER JOIN
                  dbo.tblOrderDetail INNER JOIN
                  dbo.tblOrderMaster ON dbo.tblOrderDetail.OrderID = dbo.tblOrderMaster.OrderID INNER JOIN
                  dbo.tblStoreMaster ON dbo.tblOrderMaster.StoreID = dbo.tblStoreMaster.StoreID ON dbo.tblSalesPersonMapping.PersonNodeID = dbo.tblOrderMaster.EntryPersonNodeId AND 
                  dbo.tblSalesPersonMapping.PersonType = dbo.tblOrderMaster.EntryPersonNodetype ON dbo.VwSFAProductHierarchy.SKUNodeID = dbo.tblOrderDetail.ProductID
WHERE  (dbo.tblOrderMaster.OrderDate = '30-Nov-2021')

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
         Begin Table = "VwSFAProductHierarchy"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 371
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblMstrPerson"
            Begin Extent = 
               Top = 7
               Left = 419
               Bottom = 170
               Right = 664
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblSalesPersonMapping"
            Begin Extent = 
               Top = 7
               Left = 712
               Bottom = 170
               Right = 940
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "VwCompanySalesHierarchy"
            Begin Extent = 
               Top = 7
               Left = 988
               Bottom = 170
               Right = 1214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblOrderDetail"
            Begin Extent = 
               Top = 7
               Left = 1262
               Bottom = 170
               Right = 1505
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblOrderMaster"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 338
               Right = 301
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblStoreMaster"
            Begin Extent = 
               Top = 175
               Left = 349
               Bottom = 338
       ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwSalesDataForTheDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'        Right = 635
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwSalesDataForTheDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwSalesDataForTheDay';

