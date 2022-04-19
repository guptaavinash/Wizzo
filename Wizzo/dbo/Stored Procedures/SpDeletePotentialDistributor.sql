
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpDeletePotentialDistributor] 
	@NodeID INT,
	@NodeType SMALLINT 
AS
BEGIN
	UPDATE tblPotentialDistributor SET flgInActive=1 WHERE NodeID=@NodeID AND NodeType=@NodeType
	DECLARE @flgStatus INT
		SET @flgStatus=1
		
	SELECT @flgStatus flgStatus
END
