-- =============================================
-- Author:		Avinash Gupta
-- Create date: 24-Dec-2021
-- Description:	
-- =============================================
--DROP PROC SpSaveFeedbackFinal
CREATE PROCEDURE [dbo].[SpSaveFeedbackFinal] 
	@RsltFeedbackQuestAnsMstr udtResponse_ASM READONLY,
	@flgApplicablemodule TINYINT --0=Store Visit Feedback,1=DSM Visit Feedback,2=OverAll Feedback.
AS
BEGIN
	DECLARE @NodeID INT,@NodeType SMALLINT,@OptionID INT,@AnswerValID VARCHAR(100)
	DECLARE @GrpQuestID INT,@QuestID INT,@AnsControlTypeID INT,@AnswerValue VARCHAR(500)
	DECLARE @JointVisitID INT,@JointVisitCode VARCHAR(100),@StorevisitCode VARCHAR(100),@StoreCheckVisitID INT

	DECLARE @flgRajPrdBuying TINYINT,@flgRetailerSatisfactionRajPrd TINYINT,@flgRetailerSatisfiedwithDB TINYINT,@flgRajProminentBrand TINYINT,@IsPotentialForNewPrd TINYINT

	DECLARE @isDSMReviwedStoreinfo TINYINT,@HasDSMDoneStoreCheck TINYINT,@isRajStockAvailable TINYINT,@isTookPhotoBeforeMerchandising TINYINT,@isRearrangedStock TINYINT,@isTookPhotoAfterMerchandising TINYINT,@isDSMExplainSchemeApplicable TINYINT,@isSalesPitchDone TINYINT,@isDSMPromotedFocusedSKU TINYINT

	DECLARE @isDSMAddressByName TINYINT,@isDSMStartDayOnTime TINYINT,@IsDSMAwaremarketGeography TINYINT,@isDSMAwarePrdDetails TINYINT

	IF @flgApplicablemodule=0  -- Store Visit Feedback
	BEGIN
		PRINT '@flgApplicablemodule=' + CAST(@flgApplicablemodule AS VARCHAR)
		SELECT * FROM @RsltFeedbackQuestAnsMstr

		SELECT @flgRajPrdBuying=0,@flgRetailerSatisfactionRajPrd=0,@flgRetailerSatisfiedwithDB=0,@flgRajProminentBrand=0,@IsPotentialForNewPrd=0
		DECLARE Cur_Responses_Final CURSOR FOR
		SELECT DISTINCT StoreCheckVisitID,flgApplicablemodule FROM @RsltFeedbackQuestAnsMstr WHERE flgApplicablemodule=@flgApplicablemodule

		OPEN Cur_Responses_Final
		FETCH NEXT FROM Cur_Responses_Final INTO @StoreCheckVisitID,@flgApplicablemodule
		WHILE @@FETCH_STATUS = 0  
		BEGIN 

			--- Dynamic Questions Data pull
			DECLARE CurQuest CURSOR  
			  FOR SELECT [GrpQuestID],QstID,[AnsControlTypeID],[AnsValID],[AnsTextVal] FROM @RsltFeedbackQuestAnsMstr WHERE StoreCheckVisitID= @StoreCheckVisitID AND  flgApplicablemodule=@flgApplicablemodule
			 OPEN CurQuest  
			 FETCH NEXT FROM CurQuest  
			 INTO @GrpQuestID,@QuestID,@AnsControlTypeID,@AnswerValID,@AnswerValue  
			 WHILE @@FETCH_STATUS=0  
			 BEGIN  
					PRINT '@GrpQuestID=' + CAST(@GrpQuestID AS VARCHAR)
					SET @OptionID=0
					SET @NodeID=0
					SET @NodeType=0
					IF EXISTS (SELECT 1 FROM tblDynamic_PDAQuestMstr WHERE AnsSourceTypeID IN (1,2) AND QuestID=@QuestID)
					BEGIN
						SELECT @OptionID=SUBSTRING(@AnswerValID,0,PATINDEX('%-%',@AnswerValID))
						SELECT @NodeID=SUBSTRING(@AnswerValID,PATINDEX('%-%',@AnswerValID)+1,PATINDEX('%-%',SUBSTRING(@AnswerValID,PATINDEX('%-%',@AnswerValID)+1,LEN(@AnswerValID)))-1)
						SELECT @NodeType=SUBSTRING(@AnswerValID,LEN(@AnswerValID) - CHARINDEX('-',REVERSE(@AnswerValID)) +2,LEN(@AnswerValID)) 
					END
		 			PRINT '@GrpQuestID=' + CAST(@GrpQuestID AS VARCHAR) + '@OptionID=' + CAST(@OptionID AS VARCHAR) + '@NodeID=' + CAST(@NodeID AS VARCHAR) + '@NodeType=' + CAST(@NodeType AS VARCHAR) + '@AnswerValue=' + @AnswerValue

					IF @GrpQuestID=28 SELECT @flgRajPrdBuying=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=29 SELECT @flgRetailerSatisfactionRajPrd=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=30 SELECT @flgRetailerSatisfiedwithDB=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=31 SELECT @flgRajProminentBrand=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=32 SELECT @IsPotentialForNewPrd=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					

				FETCH NEXT FROM CurQuest INTO @GrpQuestID,@QuestID,@AnsControlTypeID,@AnswerValID,@AnswerValue  
			 END  
			 CLOSE CurQuest  
			 DEALLOCATE CurQuest  

			 IF EXISTS (SELECT 1 FROM tblFeedbackDSMStoreVisit_ASM WHERE StoreCheckVisitID=@StoreCheckVisitID)
			 BEGIN
				UPDATE A SET flgRetailerSatisfactionRajPrd=@flgRetailerSatisfactionRajPrd,[flgRetailerSatisfiedwithDB]=@flgRetailerSatisfiedwithDB,[flgRajProminentBrand]=@flgRajProminentBrand,[IsPotentialForNewPrd]=@IsPotentialForNewPrd,@flgRajPrdBuying=@flgRajPrdBuying FROM [dbo].[tblFeedbackDSMStoreVisit_ASM] A WHERE StoreCheckVisitID=@StoreCheckVisitID
			 END
			 ELSE
			 BEGIN
				INSERT INTO [tblFeedbackDSMStoreVisit_ASM]([StoreCheckVisitID],[flgRetailerSatisfactionRajPrd],[flgRetailerSatisfiedwithDB],[flgRajProminentBrand],[IsPotentialForNewPrd],flgRetPrdBuying)
				SELECT @StoreCheckVisitID,@flgRetailerSatisfactionRajPrd,@flgRetailerSatisfiedwithDB,@flgRajProminentBrand,@IsPotentialForNewPrd,@flgRajPrdBuying
			 END


			FETCH NEXT FROM Cur_Responses_Final INTO @StoreCheckVisitID,@flgApplicablemodule
		END
		CLOSE Cur_Responses_Final
		DEALLOCATE Cur_Responses_Final
	END
	ELSE IF @flgApplicablemodule=1
	BEGIN
		PRINT '@flgApplicablemodule=' + CAST(@flgApplicablemodule AS VARCHAR)
		SELECT * FROM @RsltFeedbackQuestAnsMstr
		
		SELECT @isDSMReviwedStoreinfo=0,@HasDSMDoneStoreCheck=0,@isRajStockAvailable=0,@isTookPhotoBeforeMerchandising=0,@isRearrangedStock=0,@isTookPhotoAfterMerchandising=0,@isDSMExplainSchemeApplicable=0,@isSalesPitchDone=0,@isDSMPromotedFocusedSKU=0

		DECLARE Cur_Responses_1 CURSOR FOR
		SELECT DISTINCT StoreCheckVisitID,flgApplicablemodule FROM @RsltFeedbackQuestAnsMstr WHERE flgApplicablemodule=@flgApplicablemodule

		OPEN Cur_Responses_1
		FETCH NEXT FROM Cur_Responses_1 INTO @StoreCheckVisitID,@flgApplicablemodule
		WHILE @@FETCH_STATUS = 0  
		BEGIN 

			--- Dynamic Questions Data pull
			DECLARE CurQuest CURSOR  
			  FOR SELECT [GrpQuestID],QstID,[AnsControlTypeID],[AnsValID],[AnsTextVal] FROM @RsltFeedbackQuestAnsMstr WHERE StoreCheckVisitID= @StoreCheckVisitID AND  flgApplicablemodule=@flgApplicablemodule
			 OPEN CurQuest  
			 FETCH NEXT FROM CurQuest  
			 INTO @GrpQuestID,@QuestID,@AnsControlTypeID,@AnswerValID,@AnswerValue  
			 WHILE @@FETCH_STATUS=0  
			 BEGIN  
					PRINT '@GrpQuestID=' + CAST(@GrpQuestID AS VARCHAR)
					SET @OptionID=0
					SET @NodeID=0
					SET @NodeType=0
					IF EXISTS (SELECT 1 FROM tblDynamic_PDAQuestMstr WHERE AnsSourceTypeID IN (1,2) AND QuestID=@QuestID)
					BEGIN
						SELECT @OptionID=SUBSTRING(@AnswerValID,0,PATINDEX('%-%',@AnswerValID))
						SELECT @NodeID=SUBSTRING(@AnswerValID,PATINDEX('%-%',@AnswerValID)+1,PATINDEX('%-%',SUBSTRING(@AnswerValID,PATINDEX('%-%',@AnswerValID)+1,LEN(@AnswerValID)))-1)
						SELECT @NodeType=SUBSTRING(@AnswerValID,LEN(@AnswerValID) - CHARINDEX('-',REVERSE(@AnswerValID)) +2,LEN(@AnswerValID)) 
					END
		 			PRINT '@GrpQuestID=' + CAST(@GrpQuestID AS VARCHAR) + '@OptionID=' + CAST(@OptionID AS VARCHAR) + '@NodeID=' + CAST(@NodeID AS VARCHAR) + '@NodeType=' + CAST(@NodeType AS VARCHAR) + '@AnswerValue=' + @AnswerValue

					SELECT @isDSMReviwedStoreinfo=0,@HasDSMDoneStoreCheck=0,@isRajStockAvailable=0,@isTookPhotoBeforeMerchandising=0,@isRearrangedStock=0,@isTookPhotoAfterMerchandising=0,@isDSMExplainSchemeApplicable=0,@isSalesPitchDone=0,@isDSMPromotedFocusedSKU=0

					IF @GrpQuestID=19 SELECT @isDSMReviwedStoreinfo=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=20 SELECT @HasDSMDoneStoreCheck=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=21 SELECT @isRajStockAvailable=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=22 SELECT @isTookPhotoBeforeMerchandising=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=23 SELECT @isRearrangedStock=@NodeID FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=24 SELECT @isTookPhotoAfterMerchandising=@NodeID FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=25 SELECT @isSalesPitchDone=@NodeID FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=26 SELECT @isDSMExplainSchemeApplicable=@NodeID FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=27 SELECT @isDSMPromotedFocusedSKU=@NodeID FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					

				FETCH NEXT FROM CurQuest INTO @GrpQuestID,@QuestID,@AnsControlTypeID,@AnswerValID,@AnswerValue  
			 END  
			 CLOSE CurQuest  
			 DEALLOCATE CurQuest  

			 IF EXISTS (SELECT 1 FROM tblFeedbackDSMStoreVisit_ASM WHERE StoreCheckVisitID=@StoreCheckVisitID)
			 BEGIN
				UPDATE A SET [IsStoreInformationReviewed]=@isDSMReviwedStoreinfo,[IsStorecheckCompleted]=@HasDSMDoneStoreCheck,[flgbeforeMerchandisingPhototaken]=@isTookPhotoBeforeMerchandising,[flgAfterMerchandisingPhototaken]=@isTookPhotoAfterMerchandising,[IsStockCleaned/Re-arranged]=@isRearrangedStock,isSalesPitchDone=@isSalesPitchDone,[IsRajStockAvailable]=@isRajStockAvailable,[flgSchemeExplained]=@isDSMExplainSchemeApplicable,[flgSKUPromoted]=@isDSMPromotedFocusedSKU FROM tblFeedbackDSMVisit_ASM A WHERE StoreCheckVisitID=@StoreCheckVisitID
			 END
			 ELSE
			 BEGIN
				INSERT INTO tblFeedbackDSMVisit_ASM([StoreCheckVisitID],[IsStoreInformationReviewed],[IsStorecheckCompleted],[flgbeforeMerchandisingPhototaken],[flgAfterMerchandisingPhototaken],[IsStockCleaned/Re-arranged],IsSalesPitchDone,[IsRajStockAvailable],[flgSchemeExplained],[flgSKUPromoted])
				SELECT @StoreCheckVisitID,@isDSMReviwedStoreinfo,@HasDSMDoneStoreCheck,@isTookPhotoBeforeMerchandising,@isTookPhotoAfterMerchandising,@isRearrangedStock,@isSalesPitchDone,@isRajStockAvailable,@isDSMExplainSchemeApplicable,@isDSMPromotedFocusedSKU

			 END
			FETCH NEXT FROM Cur_Responses_1 INTO @StoreCheckVisitID,@flgApplicablemodule
		END
		CLOSE Cur_Responses_1
		DEALLOCATE Cur_Responses_1
	END
	ELSE IF @flgApplicablemodule=2
	BEGIN
		PRINT '@flgApplicablemodule=' + CAST(@flgApplicablemodule AS VARCHAR)
		SELECT * FROM @RsltFeedbackQuestAnsMstr

		SELECT @isDSMAddressByName =0,@isDSMStartDayOnTime =0,@IsDSMAwaremarketGeography =0,@isDSMAwarePrdDetails =0

		DECLARE Cur_Responses_Final CURSOR FOR
		SELECT DISTINCT JointVisitID,flgApplicablemodule FROM @RsltFeedbackQuestAnsMstr WHERE flgApplicablemodule=@flgApplicablemodule

		OPEN Cur_Responses_Final
		FETCH NEXT FROM Cur_Responses_Final INTO @JointVisitID,@flgApplicablemodule
		WHILE @@FETCH_STATUS = 0  
		BEGIN 

			--- Dynamic Questions Data pull
			DECLARE CurQuest CURSOR  
			  FOR SELECT [GrpQuestID],QstID,[AnsControlTypeID],[AnsValID],[AnsTextVal] FROM @RsltFeedbackQuestAnsMstr WHERE JointVisitID= @JointVisitID AND  flgApplicablemodule=@flgApplicablemodule
			 OPEN CurQuest  
			 FETCH NEXT FROM CurQuest  
			 INTO @GrpQuestID,@QuestID,@AnsControlTypeID,@AnswerValID,@AnswerValue  
			 WHILE @@FETCH_STATUS=0  
			 BEGIN  
					PRINT '@GrpQuestID=' + CAST(@GrpQuestID AS VARCHAR)
					SET @OptionID=0
					SET @NodeID=0
					SET @NodeType=0
					IF EXISTS (SELECT 1 FROM tblDynamic_PDAQuestMstr WHERE AnsSourceTypeID IN (1,2) AND QuestID=@QuestID)
					BEGIN
						SELECT @OptionID=SUBSTRING(@AnswerValID,0,PATINDEX('%-%',@AnswerValID))
						SELECT @NodeID=SUBSTRING(@AnswerValID,PATINDEX('%-%',@AnswerValID)+1,PATINDEX('%-%',SUBSTRING(@AnswerValID,PATINDEX('%-%',@AnswerValID)+1,LEN(@AnswerValID)))-1)
						SELECT @NodeType=SUBSTRING(@AnswerValID,LEN(@AnswerValID) - CHARINDEX('-',REVERSE(@AnswerValID)) +2,LEN(@AnswerValID)) 
					END
		 			PRINT '@GrpQuestID=' + CAST(@GrpQuestID AS VARCHAR) + '@OptionID=' + CAST(@OptionID AS VARCHAR) + '@NodeID=' + CAST(@NodeID AS VARCHAR) + '@NodeType=' + CAST(@NodeType AS VARCHAR) + '@AnswerValue=' + @AnswerValue

					SELECT @isDSMAddressByName =0,@isDSMStartDayOnTime =0,@IsDSMAwaremarketGeography =0,@isDSMAwarePrdDetails =0

					IF @GrpQuestID=33 SELECT @isDSMAddressByName=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=34 SELECT @isDSMStartDayOnTime=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=35 SELECT @IsDSMAwaremarketGeography=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					ELSE IF @GrpQuestID=36 SELECT @isDSMAwarePrdDetails=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
					

				FETCH NEXT FROM CurQuest INTO @GrpQuestID,@QuestID,@AnsControlTypeID,@AnswerValID,@AnswerValue  
			 END  
			 CLOSE CurQuest  
			 DEALLOCATE CurQuest  

			 IF EXISTS (SELECT 1 FROM [dbo].[tblFeedbackOverAllDSM_ASM] WHERE JointVisitId=@JointVisitID)
			 BEGIN
				UPDATE A SET [flgDSMKnewRetailername]=@isDSMAddressByName,[flgDSMStartedDayOnTime]=@isDSMStartDayOnTime,[flgDSMAwareMarketGeography]=@IsDSMAwaremarketGeography,[flgDSMAwareProductDet]=@isDSMAwarePrdDetails FROM [dbo].[tblFeedbackOverAllDSM_ASM] A WHERE JointVisitId=@JointVisitID
			 END
			 ELSE
			 BEGIN
				INSERT INTO [tblFeedbackOverAllDSM_ASM](JointVisitId,[flgDSMKnewRetailername],[flgDSMStartedDayOnTime],[flgDSMAwareMarketGeography],[flgDSMAwareProductDet])
				SELECT @JointVisitId,@isDSMAddressByName,@isDSMStartDayOnTime,@IsDSMAwaremarketGeography,@isDSMAwarePrdDetails
			 END


			FETCH NEXT FROM Cur_Responses_Final INTO @StoreCheckVisitID,@flgApplicablemodule
		END
		CLOSE Cur_Responses_Final
		DEALLOCATE Cur_Responses_Final
	END
END
