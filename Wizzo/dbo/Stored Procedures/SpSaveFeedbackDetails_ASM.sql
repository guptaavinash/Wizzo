-- =============================================
-- Author:		Avinash Gupta
-- Create date: 01-Mar-2019
-- Description:	
-- =============================================
CREATE Procedure [dbo].[SpSaveFeedbackDetails_ASM] 
	@IMEINo VARCHAR(100),
	@tblRawDataQuestAnsMstr udt_RawDataOutletQuestAnsMstr READONLY
	
AS
BEGIN
	--DECLARE @PDAID INT=0
	--SELECT @PDAID=PDAID FROM tblPDAMaster WHERE PDA_IMEI=@IMEINo OR PDA_IMEI_Sec=@IMEINo

	DECLARE @tblRawDataQuestAnsMstr_SingleStore udt_RawDataOutletQuestAnsMstr

	DECLARE @JointVisitID INT,@JointVisitCode VARCHAR(100),@StorevisitCode VARCHAR(100),@StoreVisitID INT,@flgApplicablemodule TINYINT
	----SELECT * FROM @tblRawDataQuestAnsMstr
	----SELECT * FROM tblPDAStoreFeedbackResponseMstr_ASM
	----SELECT * FROM tblPDAOverAllFeedbackResponseMstr_ASM


	-- Reading the store and DSM visit feedback
	DECLARE @RsltOutletQuestAnsMstr udtResponse_ASM
	DECLARE Cur_Responses CURSOR FOR
		SELECT DISTINCT StoreVisitCode,[StoreCheckVisitID],flgApplicablemodule FROM @tblRawDataQuestAnsMstr WHERE flgApplicablemodule IN (0,1)

	OPEN Cur_Responses
	FETCH NEXT FROM Cur_Responses INTO @StorevisitCode,@StoreVisitID,@flgApplicablemodule
	WHILE @@FETCH_STATUS = 0  
	BEGIN 
		PRINT '@StorevisitCode=' + @StorevisitCode
		PRINT '@StoreVisitID=' + CAST(@StoreVisitID AS VARCHAR)
		PRINT '@flgApplicablemodule=' + CAST(@flgApplicablemodule AS VARCHAR)

		DELETE FROM @tblRawDataQuestAnsMstr_SingleStore
		INSERT INTO @tblRawDataQuestAnsMstr_SingleStore
		SELECT * FROM @tblRawDataQuestAnsMstr WHERE StoreVisitCode=@StorevisitCode AND flgApplicablemodule=@flgApplicablemodule

		DELETE FROM @RsltOutletQuestAnsMstr
		INSERT INTO @RsltOutletQuestAnsMstr
		EXEC SpReturnDynQuestionResponseFormat	@tblRawDataQuestAnsMstr_SingleStore
		 
		DELETE FROM tblPDAStoreFeedbackResponseMstr_ASM WHERE StoreVisitCode=@StorevisitCode AND flgApplicablemodule=@flgApplicablemodule
		INSERT INTO tblPDAStoreFeedbackResponseMstr_ASM(StoreCheckVisitID,StoreVisitCode,flgApplicablemodule,GrpQuestID,QstId,AnsControlTypeID,AnsValId,AnsTextVal,TimeStampIn,OptionValue)
		SELECT @StoreVisitID,@StorevisitCode,flgApplicablemodule,GrpQuestID,QstId,AnsControlTypeID,AnsValId,AnsTextVal,GETDATE(),OptionValue FROM @RsltOutletQuestAnsMstr R WHERE StoreVisitCode=@StorevisitCode AND flgApplicablemodule=@flgApplicablemodule

		-- Calling to save the feedback data into final tables
		EXEC SpSaveFeedbackFinal @RsltOutletQuestAnsMstr,@flgApplicablemodule

		FETCH NEXT FROM Cur_Responses INTO @StorevisitCode,@StoreVisitID,@flgApplicablemodule
	END
	CLOSE Cur_Responses
	DEALLOCATE Cur_Responses

	-- Reading the OverAll DSM feedback
	DECLARE Cur_Responses CURSOR FOR
		SELECT DISTINCT JointVisitCode,JointVisitID,flgApplicablemodule FROM @tblRawDataQuestAnsMstr WHERE flgApplicablemodule=2

	OPEN Cur_Responses
	FETCH NEXT FROM Cur_Responses INTO @JointVisitCode,@JointVisitID,@flgApplicablemodule
	WHILE @@FETCH_STATUS = 0  
	BEGIN 
		PRINT '@JointVisitCode=' + @JointVisitCode
		PRINT '@JointVisitID=' + CAST(@JointVisitID AS VARCHAR)
		PRINT '@flgApplicablemodule=' + CAST(@flgApplicablemodule AS VARCHAR)

		DELETE FROM @tblRawDataQuestAnsMstr_SingleStore
		INSERT INTO @tblRawDataQuestAnsMstr_SingleStore
		SELECT * FROM @tblRawDataQuestAnsMstr WHERE JointVisitCode=@JointVisitCode AND flgApplicablemodule=@flgApplicablemodule

		DELETE FROM @RsltOutletQuestAnsMstr
		INSERT INTO @RsltOutletQuestAnsMstr
		EXEC SpReturnDynQuestionResponseFormat	@tblRawDataQuestAnsMstr_SingleStore
		 
		DELETE FROM tblPDAOverAllFeedbackResponseMstr_ASM WHERE JointVisitCode=@JointVisitCode AND flgApplicablemodule=@flgApplicablemodule
		INSERT INTO tblPDAOverAllFeedbackResponseMstr_ASM(JointVisitID,JointVisitCode,flgApplicablemodule,GrpQuestID,QstId,AnsControlTypeID,AnsValId,AnsTextVal,TimeStampIn,OptionValue)
		SELECT @JointVisitID,@JointVisitCode,@flgApplicablemodule,GrpQuestID,QstId,AnsControlTypeID,AnsValId,AnsTextVal,GETDATE(),OptionValue FROM @RsltOutletQuestAnsMstr R WHERE JointVisitCode=@JointVisitCode AND flgApplicablemodule=@flgApplicablemodule

		-- Calling to save the feedback data into final tables
		EXEC SpSaveFeedbackFinal @RsltOutletQuestAnsMstr,@flgApplicablemodule

		FETCH NEXT FROM Cur_Responses INTO @JointVisitCode,@JointVisitID,@flgApplicablemodule
	END
	CLOSE Cur_Responses
	DEALLOCATE Cur_Responses

END

