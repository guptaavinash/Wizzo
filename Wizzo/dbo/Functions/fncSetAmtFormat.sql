




CREATE  FUNCTION [dbo].[fncSetAmtFormat]
	(@Amt Amount)
	RETURNS Numeric(18,2)
AS  
BEGIN	
	
	return convert(numeric(18,2),@Amt)
END





