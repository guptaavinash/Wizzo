-- =============================================
-- Author:		Varun Jain
-- Create date: 14-Apr-2022
-- Description:	To Change DB of Stores for entrie route by passing Route ID and DB ID as parameter
-- =============================================
--exec [SpToMakeStoreOutCov] @StoreCode
--exec [SpToMakeStoreOutCov] 'FO_RAJG_70473267'
CREATE PROCEDURE [dbo].[SpToMakeStoreOutCov] 
	-- Add the parameters for the stored procedure here
	@StoreCode varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @StoreID int
	
	select @StoreID  = StoreID from tblStoreMaster where StoreCode = @StoreCode
	
	if @StoreID is not null
	begin
		
		update tblRouteCoverageStoreMapping set ToDate = cast(GETDATE() as date), LoginIDUpd = 1, TimestampUpd = GETDATE() 
		where storeid = @StoreID and GETDATE() between FromDate and ToDate
		Print 'Given store is now mark out of coverage -->' + @StoreCode
	end
	else
	begin
		Print 'Invalid Store Code --> ' + @StoreCode
	end
END
