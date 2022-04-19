-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION fnGetCurrentDateTime()

RETURNS DATETIME
AS
BEGIN
	
	-- Return the result of the function
	RETURN GETDATE()

END
