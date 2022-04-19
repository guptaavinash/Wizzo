-- =============================================
-- Author:		Varun Jain
-- Create date: 22-Feb-2022
-- Description:	To Change DB of Stores for entrie route by passing Route ID and DB ID as parameter
-- =============================================
--exec [[SpToCreateNewDBnMapCovArea]] @DBCode, @DBName, @Region, @EmpCode
--exec [SpToCreateNewDBnMapCovArea] 'DBCOde','DBName','Region','EMPCode'
CREATE PROCEDURE [dbo].[SpToCreateNewDBnMapCovArea] 
	-- Add the parameters for the stored procedure here
	@DBCode varchar(50),
	@DBName varchar (100),
	@Region varchar(50),
	@EmpCode varchar(50)
	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @DBID int
	declare @StateID int
	declare @SHNodeID int
	declare @SHNodeType int
	declare @DHNodeID int
	declare @DHNodeType int
	declare @Today as date
	declare @prcregid as int

	set @Today = cast(GETDATE() as date)

	select  @DBID = NodeID from tblDBRSalesStructureDBR where DistributorCode = @DBCode
	
	select  @StateID = StateID, @prcregid = PrcRgnNodeId from tblPriceRegionMstr where PrcRegion  = @Region
	
	select @SHNodeID = B.NodeID,@SHNodeType = B.NodeType from tblMstrPerson A inner join tblSalesPersonMapping B on A.NodeID = B.PersonNodeID and A.NodeType = B.PersonType
    where GETDATE () between B.FromDate and B.ToDate and A.flgSFAUser = 1 and A.flgActive = 1 and B.NodeType = 130 and A.Code = @EmpCode


			
	IF @StateID is not null AND @SHNodeID is not null AND @DBID is null and @prcregid is NOT null
	BEGIN
		
		insert into tblDBRSalesStructureDBR (Descr,DistributorCode,NodeType,IsActive,Flag,FileSetIDIns,TimestampIns,
		flgLive,StateId,Region,DlvryWeeklyOffDay,OfficeWeeklyOffDay,IsSuperStockiest,PrcRegionId) values(@DBName,@DBCode,150,1,0,0,GETDATE(),0,@StateID,@Region,7,7,0,@prcregid)
		--select @StateID
		--select @SHNodeID
		--select @DBID

		select  @DHNodeID = NodeID, @DHNodeType = NodeType from tblDBRSalesStructureDBR where DistributorCode = @DBCode 

		If @DHNodeID is not null AND @DHNodeType is not null
		begin
			insert into tblCompanySalesStructure_DistributorMapping values(@DHNodeID, @DHNodeType,@SHNodeID,@SHNodeType,GETDATE(),0,CONVERT(date, @Today, 105),'31-Dec-2050',0)
			EXEC SP_StateEntryForDB @DHnodeid, @StateID

			Select @DBCode + '-' + @DBName + 'Added in the system and also mapped with coevrage area of Emp code' + @EmpCode + 'Area ID is ' + cast (@shnodeid as varchar)

		end
		else
		begin
			print 'DB insertion failed'
		end

	END
	Else 
	BEGIN
		Print 'This distributor is already in the table OR Region not found OR Emp Code coverage area not found, please check parameter again'
	END
END
