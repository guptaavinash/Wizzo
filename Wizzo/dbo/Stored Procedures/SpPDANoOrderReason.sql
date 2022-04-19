-- =============================================
-- Author:		Avinash Gupta
-- Create date: 04Jan2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpPDANoOrderReason] 
	@PDACode VARCHAR(20)=''
AS
BEGIN
	SELECT * FROM tblReasonNoOrder WHERE flgActive=1
END
