


--SELECT * FROM dbo.[fnGetRouteList](3 ,160 ,GETDATE() )

CREATE FUNCTION [dbo].[fnGetAllDatesInMonth](@Date date)
RETURNS @Dates TABLE (MonthDate DATE)
BEGIN
	DECLARE @FirstDate DATE
	DECLARE @LastDate DATE

	SELECT @FirstDate=CAST(CAST(YEAR(@Date) AS VARCHAR) + '-' + CAST(MONTH(@Date) AS VARCHAR) + '-01' AS DATE)
	SELECT @LastDate=DATEADD(dd,-1,DATEADD(m,1,@FirstDate))

	WHILE (@FirstDate<=@LastDate) 
	BEGIN
		--If DATENAME(dw,@FirstDate)<>'Sunday'
		INSERT INTO @Dates(MonthDate) VALUES(@FirstDate)
		SET @FirstDate=DATEADD(d,1,@FirstDate)
	END

RETURN
end



