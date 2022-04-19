

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fncGetLocalDatetime] 
(
	@InputDatetime Datetime
)
RETURNS  Datetime
AS
BEGIN
	DECLARE @OutputDatetime DATETIME
	SELECT @OutputDatetime=DATEADD(HOUR,-5,DATEADD(MINUTE,-30,@InputDatetime)) --- Ghana Time
	--SELECT @OutputDatetime=@InputDatetime --- India Time
	RETURN @OutputDatetime

END
