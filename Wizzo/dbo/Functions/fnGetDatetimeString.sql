
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 26-Apr-2018
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetDatetimeString] 
(
	@Date datetime
)
RETURNS bigint
AS
BEGIN
	
	RETURN format(convert(datetime,@Date),'yyyyMMddHHmmss')

END
