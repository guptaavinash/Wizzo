


CREATE  FUNCTION [dbo].[fncSetDateFormat]
	(@InDate date)
	RETURNS varchar(20)
AS  
BEGIN	
	
	return REPLACE(CONVERT(varchar, @InDate, 106), ' ', '-')
END



