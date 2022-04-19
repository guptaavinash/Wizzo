
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 05Jan2021
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpSaveOrderMailSendStatus] 
	@RequestID INT,
	@flgSendStatus TINYINT, -- 1=Picked,2=Send Success,3=Error
	@ErrorText VARCHAR(MAX)
AS
BEGIN
	UPDATE tblOrderSendOnMailRequest SET flgSendStatus=@flgSendStatus,TimestampUpd=GETDATE(),Failedtext=@ErrorText WHERE RequestID=@RequestID
END
