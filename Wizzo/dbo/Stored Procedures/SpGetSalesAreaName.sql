-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROC [dbo].[SpGetSalesAreaName] 

(	

	@SalesAreaNodeID INT,

	@SalesAreaNodeType SMALLINT

)

AS

BEGIN

	DECLARE @Tablename VARCHAR(200)

	DECLARE @SQL VARCHAR(MAX)

	SELECT @Tablename=DetTable FROM tblpmstnodetypes WHERE NodeType=@SalesAreaNodeType



	SET @SQL='SELECT Descr AS SalesArea FROM ' + @Tablename + ' WHERE NodeID=' + CAST(@SalesAreaNodeID AS VARCHAR)

	EXEC (@SQL)



END


