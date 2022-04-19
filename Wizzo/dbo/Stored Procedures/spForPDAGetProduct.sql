
CREATE PROC [dbo].[spForPDAGetProduct]
@PDACode VARCHAR(50)

AS

SELECT        SKUNodeID AS ProductId, SKUShortDescr AS ProductName
FROM            VwSFAProductHierarchy

