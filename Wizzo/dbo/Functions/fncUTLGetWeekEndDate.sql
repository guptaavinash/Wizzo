



CREATE FUNCTION [dbo].[fncUTLGetWeekEndDate]
(@Date DATETIME)

RETURNS DATETIME
AS
BEGIN
	DECLARE @DayFirst TINYINT
	DECLARE @FirstDayOfWeek TINYINT
	SELECT @DayFirst=@@DATEFIRST

	IF @DayFirst=1
	BEGIN
		SELECT @Date=@Date-DATEPART(DW,@Date)+1 

	END
	ELSE IF @DayFirst=2
	BEGIN
		SELECT @Date= CASE WHEN DATEPART(DW,@Date)=7 THEN @Date
				   ELSE @Date-DATEPART(DW,@Date) END

	END
	ELSE IF @DayFirst=3
	BEGIN
		SELECT @Date= CASE WHEN DATEPART(DW,@Date)=6 THEN @Date
			      	   WHEN DATEPART(DW,@Date)=7 THEN @Date-1
				   ELSE @Date-DATEPART(DW,@Date)-1 END

	END
	ELSE IF @DayFirst=4
	BEGIN
		SELECT @Date= CASE WHEN DATEPART(DW,@Date)=5 THEN @Date
			      	   WHEN DATEPART(DW,@Date)=6 THEN @Date-1
				   WHEN DATEPART(DW,@Date)=7 THEN @Date-2
				   ELSE @Date-DATEPART(DW,@Date)-2 END
	END
	ELSE IF @DayFirst=5
	BEGIN
		SELECT @Date= CASE WHEN DATEPART(DW,@Date)=4 THEN @Date
	      	   WHEN DATEPART(DW,@Date)=5 THEN @Date-1
		   WHEN DATEPART(DW,@Date)=6 THEN @Date-2
		   WHEN DATEPART(DW,@Date)=7 THEN @Date-3
		   ELSE @Date-DATEPART(DW,@Date)-3 END
	END
	ELSE IF @DayFirst=6
	BEGIN
		SELECT @Date= CASE WHEN DATEPART(DW,@Date)=3 THEN @Date
	      	   WHEN DATEPART(DW,@Date)=4 THEN @Date-1
		   WHEN DATEPART(DW,@Date)=5 THEN @Date-2
		   WHEN DATEPART(DW,@Date)=6 THEN @Date-3
		   WHEN DATEPART(DW,@Date)=7 THEN @Date-4
		   ELSE @Date-DATEPART(DW,@Date)-4 END

	END
	ELSE IF @DayFirst=7
	BEGIN
		SELECT @Date= CASE WHEN DATEPART(DW,@Date)=1 THEN @Date-6
				   ELSE @Date+2-DATEPART(DW,@Date) END

	END
	

SET @Date=DATEADD(d, 6, @Date)

RETURN @Date
END









