
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpDeleteDistributor] 
	@NodeID INT,
	@NodeType SMALLINT 
AS
BEGIN
	UPDATE tblDBRSalesStructureDBR SET IsActive=0 WHERE NodeID=@NodeID AND NodeType=@NodeType
	DECLARE @flgStatus INT
		SET @flgStatus=1
		
	SELECT @flgStatus flgStatus
END
