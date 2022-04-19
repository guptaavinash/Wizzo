-- =============================================
-- Author:		Avinash Gupta
-- Create date: 04-Mar-2019
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpReturnDynQuestionResponseFormat] 
	@tblRawDataQuestAnsMstr udt_RawDataOutletQuestAnsMstr READONLY	
AS
BEGIN
	DECLARE @RsltOutletQuestAnsMstr [dbo].[udtResponse_ASM]
	DECLARE @Counter INT
	DECLARE @i AS INT
	DECLARE @j AS INT
	DECLARE @iCount AS INT
	DECLARE @jCount AS INT
	DECLARE @MaxCount INT
	DECLARE @QuestID INT
	DECLARE @AnswerType INT
	DECLARE @AnswerValue VARCHAR(100)
	DECLARE @QuestionGroupID INT
	DECLARE @SectionID INT
	DECLARE @StoreVisitCode VARCHAR(200)
	DECLARE @JointVisitCode VARCHAR(200)
	DECLARE @StoreCheckVisitID INT
	DECLARE @JointVisitID INT
	DECLARE @flgApplicablemodule TINYINT
	DECLARE @strPymtStageId VARCHAR(500)
	DECLARE @Values VARCHAR(200)
	DECLARE @Values_2 VARCHAR(200)
	DECLARE @PhotoName VARCHAR(500)
	DECLARE @ImageCntrlType VARCHAR(50)
	DECLARE @StoreIDDB INT

	CREATE TABLE #Values(ID INT IDENTITY(1,1),AnswerVal VARCHAR(200))
	CREATE TABLE #Values_2(ID INT IDENTITY(1,1),AnswerVal_2 VARCHAR(200))

	CREATE TABLE #tmpOutletQuestAnsMstr(ID INT IDENTITY(1,1),StoreVisitCode VARCHAR(100),JointVisitCode VARCHAR(100),StoreCheckVisitID INT,JointVisitID INT,flgApplicablemodule TINYINT,QuestID INT,AnswerType INT,AnswerValue VARCHAR(500),QuestionGroupID INT,SectionID INT)
	PRINT 'Prepare Question answer table'
	INSERT INTO #tmpOutletQuestAnsMstr(StoreVisitCode,JointVisitCode,StoreCheckVisitID,JointVisitID,flgApplicablemodule,QuestID,AnswerType,AnswerValue,QuestionGroupID,SectionID)
	SELECT StoreVisitCode,JointVisitCode,StoreCheckVisitID,JointVisitID,flgApplicablemodule,QuestID,AnswerType,AnswerValue,QuestionGroupID,SectionID
	FROM @tblRawDataQuestAnsMstr
	
	SET @Counter=1
	SELECT @MaxCount=MAX(Id) FROM #tmpOutletQuestAnsMstr
	WHILE @Counter<=@MaxCount
	BEGIN
		SELECT @QuestID=QuestID,@AnswerType=AnswerType,@AnswerValue=AnswerValue,@QuestionGroupID=QuestionGroupID,@SectionID=SectionID,@StoreVisitCode=StoreVisitCode,@JointVisitCode=JointVisitCode,@StoreCheckVisitID=StoreCheckVisitID,@JointVisitID=JointVisitID,@flgApplicablemodule=flgApplicablemodule FROM #tmpOutletQuestAnsMstr WHERE Id=@Counter
		
		IF @AnswerType IN(1,4,6,7,8,13)
		BEGIN
			INSERT INTO @RsltOutletQuestAnsMstr([StoreVisitCode],[JointVisitCode],[StoreCheckVisitID],[JointVisitID],[flgApplicablemodule],GrpQuestId,QstId,AnsControlTypeId,AnsValId,AnsTextVal)
			SELECT @StoreVisitCode,@JointVisitCode,@StoreCheckVisitID,@JointVisitID,@flgApplicablemodule,@QuestionGroupID,@QuestID,@AnswerType,@AnswerValue,NULL
		END
		ELSE IF @AnswerType IN(2,3,11,12,18)
		BEGIN
			INSERT INTO @RsltOutletQuestAnsMstr([StoreVisitCode],[JointVisitCode],[StoreCheckVisitID],[JointVisitID],[flgApplicablemodule],GrpQuestId,QstId,AnsControlTypeId,AnsValId,AnsTextVal)
			SELECT @StoreVisitCode,@JointVisitCode,@StoreCheckVisitID,@JointVisitID,@flgApplicablemodule,@QuestionGroupID,@QuestID,@AnswerType,NULL,@AnswerValue
		END
		ELSE IF @AnswerType IN(5,15,16,17)
		BEGIN
			--SELECT items from dbo.Split('dhvd-nbjbb','^')
			TRUNCATE TABLE #Values
			INSERT INTO #Values(AnswerVal)
			SELECT items from dbo.Split(@AnswerValue,'^')

			SET @i=1
			SET @iCount=0
			SELECT @iCount=MAX(Id) FROM #Values
			WHILE @i<=@iCount
			BEGIN
				SELECT @Values=AnswerVal  FROM #Values WHERE Id=@i
				
				TRUNCATE TABLE #Values_2
				INSERT INTO #Values_2(AnswerVal_2)
				SELECT items from dbo.Split(@Values,'~')

				IF EXISTS(SELECT 1 FROM #Values_2 WHERE Id>1)
				BEGIN
					INSERT INTO @RsltOutletQuestAnsMstr([StoreVisitCode],[JointVisitCode],[StoreCheckVisitID],[JointVisitID],[flgApplicablemodule],GrpQuestId,QstId,AnsControlTypeId,AnsValId,AnsTextVal)
					SELECT @StoreVisitCode,@JointVisitCode,@StoreCheckVisitID,@JointVisitID,@flgApplicablemodule,@QuestionGroupID,@QuestID,@AnswerType,A.AnswerVal_2,B.AnswerVal_2
					FROM (SELECT AnswerVal_2 FROM #Values_2 WHERE Id=1) A,(SELECT AnswerVal_2 FROM #Values_2 WHERE Id=2) B
				END
				ELSE
				BEGIN
					INSERT INTO @RsltOutletQuestAnsMstr([StoreVisitCode],[JointVisitCode],[StoreCheckVisitID],[JointVisitID],[flgApplicablemodule],GrpQuestId,QstId,AnsControlTypeId,AnsValId,AnsTextVal)
					SELECT @StoreVisitCode,@JointVisitCode,@StoreCheckVisitID,@JointVisitID,@flgApplicablemodule,@QuestionGroupID,@QuestID,@AnswerType,A.AnswerVal_2,''
					FROM (SELECT AnswerVal_2 FROM #Values_2 WHERE Id=1) A
				END

				SET @i+=1
			END
		END
		ELSE IF @AnswerType IN(14)
		BEGIN
			--SELECT items from dbo.Split('dhvd-nbjbb','^')
			TRUNCATE TABLE #Values
			INSERT INTO #Values(AnswerVal)
			SELECT items from dbo.Split(@AnswerValue,'^')

			SET @i=1
			SET @iCount=0
			SELECT @iCount=MAX(Id) FROM #Values
			WHILE @i<=@iCount
			BEGIN
				SELECT @Values=AnswerVal  FROM #Values WHERE Id=@i
				
				TRUNCATE TABLE #Values_2
				INSERT INTO #Values_2(AnswerVal_2)
				SELECT items from dbo.Split(@Values,'~')

				INSERT INTO @RsltOutletQuestAnsMstr([StoreVisitCode],[JointVisitCode],[StoreCheckVisitID],[JointVisitID],[flgApplicablemodule],GrpQuestId,QstId,AnsControlTypeId,AnsValId,AnsTextVal)
				SELECT @StoreVisitCode,@JointVisitCode,@StoreCheckVisitID,@JointVisitID,@flgApplicablemodule,@QuestionGroupID,@QuestID,@AnswerType,A.AnswerVal_2,B.AnswerVal_2
				FROM (SELECT AnswerVal_2 FROM #Values_2 WHERE Id=1) A,(SELECT AnswerVal_2 FROM #Values_2 WHERE Id=2) B
				
				SET @i+=1
			END
		END

		SET @Counter+=1
	END
	
	SELECT * FROM @RsltOutletQuestAnsMstr
END
