-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetDBRList] 
@LoginId INT
AS
BEGIN
	SELECT NodeID DBRNodeId,NodeType DBRNodeType,ISNULL(DistributorCode,'NA') DBRCode,Descr DBR
	FROM tblDBRSalesStructureDBR
	WHERE IsActive=1
END
