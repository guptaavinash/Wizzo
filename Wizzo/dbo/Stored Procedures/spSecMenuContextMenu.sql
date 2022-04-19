




CREATE PROCEDURE [dbo].[spSecMenuContextMenu] --2

	@HierTypeID INT

 AS

SELECT   dbo.tblSecMenuContextMenu.NodeType, dbo.tblSecMenuContextMenu.NodeTypeUnder, dbo.tblSecMenuContextMenu.Descr, 
        dbo.tblPMstNodeTypes.FrameID,dbo.tblSecMenuContextMenu.flgBusinessType,dbo.tblSecMenuContextMenu.NodeIDBusinessType,tblSecMenuContextMenu.UpperlevelNameForEdit,
		flgMap,flgChannel,flgPerson,flgRoute,flgMapType,flgDistributor,flgCoverageArea,flgMapDistributor
FROM         dbo.tblSecMenuContextMenu INNER JOIN
        dbo.tblPMstNodeTypes ON dbo.tblSecMenuContextMenu.NodeType = dbo.tblPMstNodeTypes.NodeType
WHERE     (dbo.tblSecMenuContextMenu.HierTypeID = @HierTypeID)
ORDER BY dbo.tblSecMenuContextMenu.NodeType








