

-- =============================================
-- Author:      Avinash Gupta
-- Create Date: 26Jan2021
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[SpCycFileEntry_Push]
(
    @CycleUnqID BIGINT,
	@FileID INT,
	@DataDate Date,
	@flgProcessType TINYINT, -- 1=Start,2=End
	@CycFileID BIGINT=0,
	@RowsRead INT NULL,
	@RowsCopied INT NULL
		
)
AS
BEGIN
	
	DECLARE @ToDaysDate Datetime
	SELECT @ToDaysDate=DATEADD(minute,330,GETDATE()) --- For indian time

	IF @flgProcessType=1
	BEGIN
		INSERT INTO tblExtractCycDet(CycleUnqID,FileID,Date,TimePopulated,TimeDataLoadStart,TimestampIns)
		SELECT @CycleUnqID,@FileID,@DataDate,CAST(@ToDaysDate AS TIME(7)),@ToDaysDate,@ToDaysDate
		SELECT @CycFileID=@@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE tblExtractCycDet SET TimeDataLoadEnd=@ToDaysDate,DataRowsRead=@RowsRead,DataRowsCopied=@RowsCopied WHERE CycFileID=@CycFileID AND @RowsRead=@RowsCopied
	END
	
	SELECT @CycFileID CycFileID,CAST(@ToDaysDate AS TIME(7))  TimePopulated
END
