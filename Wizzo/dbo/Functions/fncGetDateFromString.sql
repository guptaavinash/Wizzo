


CREATE  FUNCTION [dbo].[fncGetDateFromString]
	(@InDate varchar(10))
	RETURNS datetime
AS  
BEGIN	
	Declare @Day AS varchar(20)
	Declare @Month AS varchar(20)
	Declare @YEAR AS varchar(20)
	Declare @pos AS varchar(20)
	
	WHILE CHARINDEX('-', @InDate) > 0
	BEGIN
	Set @pos  = CHARINDEX('-', @InDate)  
	Set @Day = SUBSTRING(@InDate, 1, @pos-1)
	--print  @Day

	Set @InDate = SUBSTRING(@InDate, @pos+1, LEN(@InDate)-@pos)

	Set @pos  = CHARINDEX('-', @InDate)  
	Set @Month = SUBSTRING(@InDate, 1, @pos-1)
	--print  @Month

	SET @InDate = SUBSTRING(@InDate, @pos+1, LEN(@InDate)-@pos)
	Set @YEAR = @InDate

	END
	IF @Month = '01'
		Set @Month = 'Jan'
	IF @Month = '02'
		Set @Month = 'Feb'
	IF @Month = '03'
		Set @Month = 'Mar'
	IF @Month = '04'
		Set @Month = 'Apr'
	IF @Month = '05'
		Set @Month = 'May'
	IF @Month = '06'
		Set @Month = 'Jun'
	IF @Month = '07'
		Set @Month = 'Jul'
	IF @Month = '08'
		Set @Month = 'Aug'
	IF @Month = '09'
		Set @Month = 'Sep'
	IF @Month = '10'
		Set @Month = 'Oct'
	IF @Month = '11'
		Set @Month = 'Nov'
	IF @Month = '12'
		Set @Month = 'Dec'
		
	return convert(datetime,(@Day+'-'+@Month+'-'+@YEAR))
END
