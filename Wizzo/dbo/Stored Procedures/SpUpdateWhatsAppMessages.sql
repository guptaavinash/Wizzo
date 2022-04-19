
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 15-Jun-2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpUpdateWhatsAppMessages] 
	@ID INT,
	@MessageID VARCHAR(100)
AS
BEGIN
	UPDATE O SET flgmessageSent=1,SentTimestamp=GETDATE(),RefMessageID=@MessageID FROM tblWhatsAppAPI_OutgoingMessages O WHERE ID=@ID
	
END
