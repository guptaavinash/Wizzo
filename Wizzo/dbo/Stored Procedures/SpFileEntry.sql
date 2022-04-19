

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpFileEntry]
	@Filename VARCHAR(200)

AS
BEGIN
	INSERT INTO tblFileentry(Filename)
	SELECT @Filename
END
