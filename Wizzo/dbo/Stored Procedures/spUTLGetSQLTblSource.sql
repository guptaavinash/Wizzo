

CREATE   PROCEDURE [dbo].[spUTLGetSQLTblSource] 

	@NodeType INT,
	@tblHierarchy varChar(70) OUTPUT,
	@tblDesc varChar(70) OUTPUT,
	@FrmID TINYINT OUTPUT,
	@HierTypeID TINYINT OUTPUT
AS



SELECT    @FrmID=FrameID, @tblHierarchy=Hierarchytable, @tblDesc=DetTable, @HierTypeID=HierTypeID FROM tblPMstNodeTypes WHERE     (NodeType =@NodeType)





