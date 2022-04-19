
CREATE function [dbo].[fnGetKGLConversion](@UOMID int,@Value numeric(18,4))
returns numeric(18,6)
as
begin
Declare @Val  numeric(18,6)
if @UOMID in (3,5)
set @Val= @Value
else
set @Val= convert(numeric(18,6),@Value/1000)

return @Val
end
