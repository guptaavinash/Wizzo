

-- =============================================
-- Author:      Avinash Gupta
-- Create Date: 26Jan2021
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[SpCycFileEntry]
(
    @CycleUnqID INT,
	@FileID INT,
	@DataDate Date,
	@TimePopulated time(7),
	@flgProcessType TINYINT, -- 1=Start,2=End
	@RowID INT=0
		
)
AS
BEGIN
	
	DECLARE @CycFileID INT
	SELECT @CycFileID=CycFileID FROM tblExtractCycDet WHERE CycleUnqID=@CycleUnqID AND FileID=@FileID AND TimePopulated=@TimePopulated

	DECLARE @ToDaysDate Datetime
	SELECT @ToDaysDate=DATEADD(minute,330,GETDATE()) --- For indian time

	IF ISNULL(@CycFileID,0)=0
	BEGIN
		INSERT INTO tblExtractCycDet(CycleUnqID,FileID,Date,TimePopulated,TimeDataLoadStart,TimestampIns,RowID)
		SELECT @CycleUnqID,@FileID,@DataDate,@TimePopulated,@ToDaysDate,@ToDaysDate,@RowID

		SELECT @CycFileID=@@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE E SET TimeDataLoadEnd=@ToDaysDate  FROM tblExtractCycDet E WHERE CycleUnqID=@CycleUnqID AND FileID=@FileID
	END

	SELECT @CycFileID CycFileID
END
