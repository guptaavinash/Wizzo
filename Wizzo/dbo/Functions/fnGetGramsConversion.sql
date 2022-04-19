






CREATE function [dbo].[fnGetGramsConversion](@UOMID int,@Value NUMERIC(18,6))
returns int
as
begin
Declare @Val int
if @UOMID in (3,5)
set @Val= @Value*1000
else
set @Val= convert(numeric(18,0),@Value)

return @Val
end
