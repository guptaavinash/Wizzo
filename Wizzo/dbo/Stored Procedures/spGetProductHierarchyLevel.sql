
CREATE PROCEDURE [dbo].[spGetProductHierarchyLevel]
	
AS
BEGIN
	SELECT NodeType, NodeTypeDesc AS Descr
	FROM tblPmstNodeTypes
	WHERE HierTypeId =1 AND NodeType<30
	ORDER BY Nodetype
END

