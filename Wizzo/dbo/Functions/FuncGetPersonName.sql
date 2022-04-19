


-- =============================================
-- Author:		Avinash Gupta
-- Create date: 07-Apr-2015
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[FuncGetPersonName] 
(
	-- Add the parameters for the function here
	@NodeID int,
	@NodeType INT
)
RETURNS VARCHAR(200)
AS
BEGIN

	DECLARE @PersonDetail VARCHAR(200)

	IF @NodeType=100
		SELECT @PersonDetail=L.Descr FROM tblCompanySalesStructureHierarchy H INNER JOIN tblCompanySalesStructureMgnrLvl0 L ON L.NodeID=H.NodeID AND L.NodeType=H.NodeType WHERE H.NodeID=@NodeID
	IF @NodeType=110
		SELECT @PersonDetail=L.Descr FROM tblCompanySalesStructureHierarchy H INNER JOIN tblCompanySalesStructureMgnrLvl1 L ON L.NodeID=H.NodeID AND L.NodeType=H.NodeType WHERE H.NodeID=@NodeID
	IF @NodeType=120
		SELECT @PersonDetail=L.Descr FROM tblCompanySalesStructureHierarchy H INNER JOIN tblCompanySalesStructureSprvsnLvl1 L ON L.NodeID=H.NodeID AND L.NodeType=H.NodeType WHERE H.NodeID=@NodeID
	IF @NodeType=130
		SELECT @PersonDetail=L.Descr FROM tblCompanySalesStructureHierarchy H INNER JOIN tblCompanySalesStructureCoverage L ON L.NodeID=H.NodeID AND L.NodeType=H.NodeType WHERE H.NodeID=@NodeID
	IF @NodeType=140
		SELECT @PersonDetail=L.Descr FROM tblCompanySalesStructureHierarchy H INNER JOIN tblCompanySalesStructureRouteMstr L ON L.NodeID=H.NodeID AND L.NodeType=H.NodeType WHERE H.NodeID=@NodeID
	RETURN @PersonDetail

END







