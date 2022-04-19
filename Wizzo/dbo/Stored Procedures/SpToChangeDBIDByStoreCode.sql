-- =============================================
-- Author:		Varun Jain
-- Create date: 16-Jan-2021
-- Description:	To Change DB of Stores for entrie route by passing Route ID and DB ID as parameter
-- =============================================
--exec [SpToChangeDBIDByRouteID] @RouteID, @RouteNodeType, @DBID
--exec SpToChangeDBIDByRouteID 631,140,286
CREATE PROCEDURE [dbo].[SpToChangeDBIDByStoreCode] 
	-- Add the parameters for the stored procedure here
	@StoreCode varchar(50),
	@DBCode varchar (50)
	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @DBID int
	declare @DBType int
	declare @CheckR int

	select  @DBID = NodeID, @DBType = NodeType from tblDBRSalesStructureDBR where DistributorCode = @DBCode

	select @CheckR = StoreID from tblStoreMaster where StoreCode = @StoreCode

	
	if @CheckR is not null
	BEGIN
		if @DBID is not null
		begin
			update tblStoreMaster set DBID = @DBID, DBNodeType = @DBType, DistNodeId = @DBID, DistNodeType = @DBType where StoreID = @CheckR
			Print 'DB ID changes DONE'
		end    
	END
	ELSE
	BEGIN
		Print 'No such store found in the tables'	
	END
END
