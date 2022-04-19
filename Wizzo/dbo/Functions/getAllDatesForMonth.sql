






CREATE FUNCTION [dbo].[getAllDatesForMonth]
(
 @date1 datetime
)
RETURNS @dates TABLE 
(
 date datetime not null,
 strDate VARCHAR(10) not null 
)
AS
BEGIN
 -- Set first day in month
 DECLARE @month int;
 
 SET @month = datepart(MM, @date1);
 SET @date1 = convert(datetime, convert(varchar,datepart(yy,@date1)) + '.' + convert(varchar,@month) + '.01 00:00:00');
 WHILE datepart(MM,@date1) = @month
 BEGIN
  INSERT INTO @dates VALUES (@date1,RIGHT(CONVERT(VARCHAR,@date1,112),2)+'-'+LEFT(DATENAME(m,@date1),3)+'-'+RIGHT(YEAR(@date1),2));
  SET @date1 = dateadd(dd, 1, @date1);
 END 
 RETURN;
END  




