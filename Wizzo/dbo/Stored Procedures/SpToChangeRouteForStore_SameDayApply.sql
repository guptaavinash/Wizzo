-- =============================================
-- Author:		Varun Jain
-- Create date: 16-Jan-2021
-- Description:	To Change DB of Stores for entrie route by passing Route ID and DB ID as parameter
-- =============================================
--exec [SpToChangeRouteForStore] @OldRouteID, @@OldRouteNodeType,@NewRouteID,@NewRouteNodeType,@StoreID
--exec [SpToChangeRouteForStore] 425,140,423,140,18807
create PROCEDURE [dbo].[SpToChangeRouteForStore_SameDayApply] 
	-- Add the parameters for the stored procedure here
	@OldRouteCode varchar(50), 
	@NewRouteCode varchar(50),
	@StoreCode varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @OldRouteID int
	declare @NewRouteID int
	declare @CheckR int
	declare @StoreID int

	select @OldRouteID = NodeID from tblCompanySalesStructureRouteMstr where Code = @OldRouteCode
	select @NewRouteID  = NodeID from tblCompanySalesStructureRouteMstr where Code = @NewRouteCode
	select @StoreID  = StoreID from tblStoreMaster where StoreCode = @StoreCode


	if @StoreID is not null AND @OldRouteID is not null AND @NewRouteID is not null
	begin
		select top 1 @CheckR = RouteID from tblRouteCoverageStoreMapping where RouteID = @OldRouteID and RouteNodeType = 140 
		and StoreID = @StoreID and GETDATE() between FromDate and ToDate

	
		if @CheckR is not null
		BEGIN
		
		--select cast(GETDATE()-1 as date)
		
		
				update tblRouteCoverageStoreMapping set ToDate = cast(GETDATE()-1 as date), LoginIDUpd = 1, TimestampUpd = GETDATE() 
				where RouteID = @OldRouteID and RouteNodeType = 140 and storeid = @StoreID and GETDATE() between FromDate and ToDate

				insert into tblRouteCoverageStoreMapping values(@NewRouteID,@StoreID,cast(GETDATE() as date),'31-Dec-2049',1,GETDATE(),NULL,NULL,140,NULL)
		
			Print 'Given store is now mapped to new route'
		END
		ELSE
		BEGIN
			Print 'No such route and store mapping found in the tblRouteCoverageStoreMapping'	
		END
	end
	else
	begin
		Print 'Invalid Details'
	end
END
