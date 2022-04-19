
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 15-Jun-2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpSaveMessageRegisteredRecord]
	@Source NUMERIC(18,0),
	@Destination NUMERIC(18,0),
	@MessageDatetime Datetime,
	@Type TINYINT --1=OptIn,2=OptOut
AS
BEGIN
	DECLARE @CustomerNodeID INT,@CustomerNodeType SMALLINT
	--SELECT TOP 2 * FROM tblStoreMaster
	DECLARE @RegID INT
	--SELECT @RegID=LEFT(CAST(RAND()*1000000000+999999 AS INT),6)
	SELECT @CustomerNodeID=NodeID,@CustomerNodeType=NodeType FROM tblMstrPerson WHERE PersonPhone=@Source-- OR alternatewhatsappNo=@Source

	IF @Type=1
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM tblWhatsAppAPI_RegisteredCustomer WHERE CustomerMobNo=@Source)
		BEGIN
			INSERT INTO tblWhatsAppAPI_RegisteredCustomer(CustomerMobNo,CustomerNodeID,CustomerNodeType,flgRegistered,RegisteredDatetime)
			SELECT @Source,@CustomerNodeID,@CustomerNodeType,1,@MessageDatetime
			SELECT @RegID=SCOPE_IDENTITY()
			UPDATE R SET RegistrationID='REG' + CAST((10000 + ID) AS VARCHAR) FROM tblWhatsAppAPI_RegisteredCustomer R WHERE CustomerMobNo=@Source AND ID=@RegID
			Update tblMstrPerson set flgWhatsAppReg=1 where NodeID=@CustomerNodeID 
		END
	END
	ELSE IF @Type=2
	begin
		UPDATE R SET flgRegistered=0,UnregisteredDatetime=@MessageDatetime FROM tblWhatsAppAPI_RegisteredCustomer R WHERE CustomerMobNo=@Source
		Update tblMstrPerson set flgWhatsAppReg=0 where NodeID=@CustomerNodeID 
		end
END
