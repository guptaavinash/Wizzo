-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--DROP PROC SpPDASaveRegistration
CREATE PROCEDURE [dbo].[SpPDASaveGCMRegistration] 
	@PDACode VARCHAR(50),
	@strDate VARCHAR(20), 
	@AppVersionID INT,
	@RegistrationID varchar(300) ='' 
AS
BEGIN
	IF @RegistrationID  <>''
    BEGIN
		EXEC spInsertFromPDANotification  @PDACode, @strDate,@AppVersionID,@RegistrationID
	END
END
