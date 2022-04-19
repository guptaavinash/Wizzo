

-- =============================================
-- Author:      Avinash Gupta
-- Create Date: 26Jan2021
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[SpCycFileEntry_UpdateLog]
(
    @CycFileID BIGINT,
	@RowsRead BIGINT,
	@RowsCopied BIGINT,
	@ErrorMessage VARCHAR(MAX)
)
AS
BEGIN
	UPDATE tblExtractCycDet SET DataRowsRead=@RowsRead,DataRowsCopied=@RowsCopied,ErrorMessage=@ErrorMessage WHERE CycFileID=@CycFileID
	
END
