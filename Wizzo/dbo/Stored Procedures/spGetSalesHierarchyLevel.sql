



CREATE PROCEDURE [dbo].[spGetSalesHierarchyLevel]
	
AS
BEGIN
	SELECT NodeType, LTRIM(RTRIM(REPLACE(NodeTypeDesc,'Company',''))) AS Descr
	FROM tblPmstNodeTypes
	WHERE HierTypeId IN(2,5) AND NodeType<=150
	ORDER BY Nodetype
END



