-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpGetDistributorDetails] 
	@PDACode VARCHAR(100)=''
AS
BEGIN
	SELECT NodeID,NodeType,Descr Distributor,DistributorCode FROM tblDBRSalesStructureDBR
END
