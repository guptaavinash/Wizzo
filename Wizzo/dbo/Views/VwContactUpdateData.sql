CREATE VIEW dbo.VwContactUpdateData
AS
SELECT TOP (100) PERCENT dbo.tblMstrPerson.NodeID, dbo.tblStoreListForValidation.StoreID, dbo.tblMstrPerson.Descr AS TSI, dbo.tblStoreMaster.StoreCode, dbo.tblStoreMaster.StoreName, 
                  dbo.tblReasonCodeMstr.REASNCODE_LVL2NAME AS Reason, dbo.tblOutletContactDet.LandLineNo1 AS [Old Contact Number], dbo.tblStoreContactUpdate.ContactNo AS [New Contact Number], 
                  dbo.tblStoreContactUpdate.TimestampIns AS UpdateDate, dbo.tblStoreContactUpdate.TimestampIns AS [Datetime Update], dbo.tblOutletContactDet.ContactType, 
                  dbo.tblStoreListForValidation.TimestampIns AS DatetimeSentForValidation, dbo.tblStoreMaster.StateName, dbo.tblStoreMaster.City, dbo.tblStoreMaster.flgActive
FROM     dbo.tblMstrPerson INNER JOIN
                      (SELECT DISTINCT StoreId, SONodeId, SONodeType
                       FROM      dbo.tblRouteCalendar) AS R ON dbo.tblMstrPerson.NodeID = R.SONodeId AND dbo.tblMstrPerson.NodeType = R.SONodeType INNER JOIN
                  dbo.tblStoreListForValidation ON R.StoreId = dbo.tblStoreListForValidation.StoreID INNER JOIN
                  dbo.tblStoreMaster ON dbo.tblStoreListForValidation.StoreID = dbo.tblStoreMaster.StoreID INNER JOIN
                  dbo.tblReasonCodeMstr ON dbo.tblStoreListForValidation.ReasonID = dbo.tblReasonCodeMstr.ReasonCodeID INNER JOIN
                  dbo.tblOutletContactDet ON dbo.tblStoreListForValidation.StoreID = dbo.tblOutletContactDet.StoreID LEFT OUTER JOIN
                  dbo.tblStoreContactUpdate ON dbo.tblStoreListForValidation.StoreID = dbo.tblStoreContactUpdate.StoreID
WHERE  (dbo.tblReasonCodeMstr.REASNFOR = 1) AND (dbo.tblOutletContactDet.ContactType = 1)
ORDER BY dbo.tblMstrPerson.NodeID, dbo.tblStoreListForValidation.StoreID

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[39] 4[28] 2[23] 3) )"
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
         Left = -36
      End
      Begin Tables = 
         Begin Table = "tblMstrPerson"
            Begin Extent = 
               Top = 53
               Left = 128
               Bottom = 222
               Right = 373
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "R"
            Begin Extent = 
               Top = 7
               Left = 1773
               Bottom = 148
               Right = 1967
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblStoreListForValidation"
            Begin Extent = 
               Top = 49
               Left = 730
               Bottom = 212
               Right = 927
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblStoreMaster"
            Begin Extent = 
               Top = 143
               Left = 986
               Bottom = 306
               Right = 1272
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "tblReasonCodeMstr"
            Begin Extent = 
               Top = 34
               Left = 1053
               Bottom = 197
               Right = 1312
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblOutletContactDet"
            Begin Extent = 
               Top = 192
               Left = 408
               Bottom = 355
               Right = 668
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "tblStoreContactUpdate"
            Begin Extent = 
               Top = 70
               Left = 1358
               Bottom = 233
      ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwContactUpdateData';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'         Right = 1566
            End
            DisplayFlags = 280
            TopColumn = 5
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 11
         Width = 284
         Width = 1200
         Width = 2520
         Width = 1980
         Width = 1200
         Width = 1752
         Width = 2184
         Width = 2412
         Width = 1200
         Width = 2064
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7116
         Alias = 2700
         Table = 2160
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwContactUpdateData';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VwContactUpdateData';

