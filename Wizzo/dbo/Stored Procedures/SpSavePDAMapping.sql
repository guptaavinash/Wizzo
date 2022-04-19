
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [SpSavePDAMapping] 0,'1234567890','','',1,37,360,1
CREATE procEDURE [dbo].[SpSavePDAMapping] 
	@EmpID INT=0,
	@PDAIMEINo1 VARCHAR(15),
	@PDAIMEINo2 VARCHAR(15),
	@PDAModelName VARCHAR(200),
	@TASSiteNodeId INT=1,
	@TASSiteNodeType INT=160,
	@LoginID INT
AS
BEGIN
	DECLARE @PDAID INT
	SELECT @PDAID=PDAID FROM tblPDAMaster WHERE PDA_IMEI=@PDAIMEINo1 OR PDA_IMEI_Sec=@PDAIMEINo2 OR PDA_IMEI=@PDAIMEINo2 OR PDA_IMEI_Sec=@PDAIMEINo1

	PRINT '@PDAID=' + CAST(@PDAID AS VARCHAR)

	IF ISNULL(@PDAID,0)=0
	BEGIN
		INSERT INTO tblPDAMaster(PDAModelName,PDA_IMEI,PDA_IMEI_Sec,TASSiteNodeId,TASSiteNodeType)
		SELECT @PDAModelName,@PDAIMEINo1,@PDAIMEINo2,@TASSiteNodeId,@TASSiteNodeType

		SELECT @PDAID=SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		UPDATE P SET PDA_IMEI=@PDAIMEINo1,PDA_IMEI_Sec=@PDAIMEINo2 FROM tblPDAMaster P WHERE PDAID=@PDAID
	END

	IF @PDAID>0 AND @EmpID>0
	BEGIN
		--IF @flgPDAMove=1
		--BEGIN
		Declare @Curr_Date datetime
		set @Curr_Date=dbo.fnGetCurrentDateTime()

			---UnAssigned PDA from everywhere
			DELETE PU FROM tblPDA_UserMapMaster PU WHERE PDAID=@PDAID AND DateFrom=CAST(@Curr_Date AS DATE)

			UPDATE PU SET DateTo=CASE WHEN DateFrom=CAST(@Curr_Date AS DATE) THEN @Curr_Date ELSE DATEADD(d,-1,@Curr_Date) END FROM tblPDA_UserMapMaster PU WHERE PDAID=@PDAID AND CAST(@Curr_Date AS DATE) BETWEEN PU.DateFrom AND PU.DateTo

			---UnAssigned Emp from everywhere
			DELETE PU FROM tblPDA_UserMapMaster PU WHERE EmpID=@EmpID AND DateFrom=CAST(@Curr_Date AS DATE)

			UPDATE PU SET DateTo=CASE WHEN DateFrom=CAST(@Curr_Date AS DATE) THEN @Curr_Date ELSE DATEADD(d,-1,@Curr_Date) END FROM tblPDA_UserMapMaster PU WHERE EmpID=@EmpID AND CAST(@Curr_Date AS DATE) BETWEEN PU.DateFrom AND PU.DateTo

			IF NOT EXISTS (SELECT 1 FROM tblPDA_UserMapMaster WHERE PDAID=@PDAID AND EmpID=@EmpID AND CAST(@Curr_Date AS DATE) BETWEEN DateFrom AND DateTo)
			BEGIN
				INSERT INTO tblPDA_UserMapMaster(PDAID,EmpID,EmpType,DateFrom,DateTo,LoginIDIns,TImestampIns)
				SELECT @PDAID,@EmpID,2,@Curr_Date,'31-Dec-2049',@LoginID,@Curr_Date
			END
	
		--END
		--ELSE
		--BEGIN
		--	IF NOT EXISTS (SELECT 1 FROM tblPDA_UserMapMaster WHERE PDAID=@PDAID AND EmpID=@EmpID AND CAST(dbo.fnGetCurrentDateTime() AS DATE) BETWEEN DateFrom AND DateTo)
		--	BEGIN
		--		INSERT INTO tblPDA_UserMapMaster(PDAID,EmpID,EmpType,DateFrom,DateTo,LoginIDIns,TImestampIns)
		--		SELECT @PDAID,@EmpID,2,dbo.fnGetCurrentDateTime(),'31-Dec-2049',@LoginID,dbo.fnGetCurrentDateTime()
		--	END
		--END
	END
	ELSE IF @PDAID>0 AND @EmpID=0
	BEGIN
		PRINT 'Called'
		Declare @Curr_Date1 datetime
		set @Curr_Date1=dbo.fnGetCurrentDateTime()

		DELETE PU FROM tblPDA_UserMapMaster PU WHERE PDAID=@PDAID AND DateFrom=CAST(@Curr_Date1 AS DATE)

		UPDATE PU SET DateTo=CASE WHEN DateFrom=CAST(@Curr_Date1 AS DATE) THEN @Curr_Date1 ELSE DATEADD(d,-1,@Curr_Date1) END FROM tblPDA_UserMapMaster PU WHERE PDAID=@PDAID AND CAST(@Curr_Date1 AS DATE) BETWEEN PU.DateFrom AND PU.DateTo 
	END
END
