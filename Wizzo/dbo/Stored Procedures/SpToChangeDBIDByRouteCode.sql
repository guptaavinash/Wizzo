-- =============================================
-- Author:		Varun Jain
-- Create date: 16-Jan-2021
-- Description:	To Change DB of Stores for entrie route by passing Route ID and DB ID as parameter
-- =============================================
--exec [[SpToChangeDBIDByRouteCode]] @RouteCode, @DBCode
--exec [SpToChangeDBIDByRouteCode] 631,140,286
CREATE PROCEDURE [dbo].[SpToChangeDBIDByRouteCode] 
	-- Add the parameters for the stored procedure here
	@RouteCode varchar(50),
	@DBCode varchar (50)
	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @RouteID Int
	declare @RouteNodeType int
	declare @DBID int
	declare @CheckR int
	declare @DBType int

	select  @RouteID = NodeID from tblCompanySalesStructureRouteMstr where Code = @RouteCode
	select  @DBID = NodeID, @DBType = NodeType from tblDBRSalesStructureDBR where DistributorCode = @DBCode

	select top 1 @CheckR = RouteID from tblRouteCoverageStoreMapping where RouteID = @RouteID and RouteNodeType = 140

	
	if @CheckR is not null
	BEGIN
		create table #tempStoresForDBChange (StoreID int NULL)
	
		insert into #tempStoresForDBChange
		select StoreID from tblRouteCoverageStoreMapping where RouteID = @RouteID and RouteNodeType = 140 and GETDATE() between FromDate and ToDate

		if @DBID is not null
		begin
			update tblStoreMaster set DBID = @DBID, DBNodeType = @DBType, DistNodeId = @DBID, DistNodeType = @DBType where StoreID in (select StoreID from #tempStoresForDBChange)
			drop table #tempStoresForDBChange
			Print 'DB ID changes DONE'
		end    
	END
	ELSE
	BEGIN
		Print 'No such route/DB id found in the tables'	
	END
END
