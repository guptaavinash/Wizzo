
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetOrderString] 
(
	@OrderQtyCS FLOAT,
	@OrderQtyPcs FLOAT
)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @OrderStr VARCHAR(100)
	SELECT @OrderStr=''

	SELECT @OrderStr=CAST(ROUND(@OrderQtyCS,2) AS VARCHAR) + ' Cs|' + CAST(ROUND(@OrderQtyPcs,0) AS VARCHAR) + ' Pc'
	--IF  @OrderQtyCS=0 AND @OrderQtyPcs<>0
	--	SELECT  @OrderStr = CAST(@OrderQtyPcs AS VARCHAR) + ' Pc'
	--ELSE IF @OrderQtyCS<>0 AND @OrderQtyPcs=0
	--	SELECT @OrderStr = CAST(@OrderQtyCS AS VARCHAR) + ' Cs'
	--ELSE
	--	SELECT @OrderStr = CAST(@OrderQtyCS AS VARCHAR) + ' Cs ' + CAST(@OrderQtyPcs AS VARCHAR) + ' Pc'


	RETURN @OrderStr

END
