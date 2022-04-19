-- =============================================
-- Author:		Gaurav Gupta
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
--DROP PROC spPrepareDetailsAndSaveNewStore
CREATE PROCEDURE [dbo].[spPrepareDetailsAndSaveNewStore]
@StrStoreId VARCHAR(100),
@PDA_IMEI VARCHAR(100),
@XMLFullName VARCHAR(100),
@XMLReceiveDate DATETIME,
@tblStoreList udt_RawDataStoreList READONLY,
@tblRawDataOutletQuestAnsMstr udt_RawDataOutletQuestAnsMstr READONLY,
@tblRawDataSalesQuotePaymentDetails udt_RawDataNewStoreSalesQuotePaymentDetails READONLY,
@tblRawDataImages udt_RawDataTableImage READONLY,
@tblRawDataLatLongDetails udt_RawDataLatLongDetails READONLY,
@tblRawDataNewStoreLocationDetails udt_RawDataNewStoreLocationDetails READONLY,
@tblRawDataCustomerVisit udt_RawDataCustomerVisit READONLY,
@OrgStoreId INT OUTPUT,
@FileSetID INT
AS
BEGIN
	--SELECT * FROM @tblVisitStoreList order by StoreId
	--SELECT * FROM @tblRawDataOutletQuestAnsMstr order by Outletid,QuestionGroupid,CAST(Answertype AS INT)
	--SELECT * FROM @tblRawDataSalesQuotePaymentDetails order by StoreId
	--SELECT * FROM @tblRawDataImages order by StoreId
	SELECT * FROM @tblRawDataLatLongDetails order by StoreId

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
	DECLARE @strPymtStageId VARCHAR(500)
	DECLARE @Values VARCHAR(200)
	DECLARE @Values_2 VARCHAR(200)
	DECLARE @PhotoName VARCHAR(500)
	DECLARE @ImageCntrlType VARCHAR(50)
	DECLARE @StoreIDDB INT
	--DECLARE @tblRawDataOutletQuestAnsMstr_N udt_RawDataOutletQuestAnsMstr
	--DECLARE @tblRawDataSalesQuotePaymentDetails_N udt_RawDataNewStoreSalesQuotePaymentDetails
	--DECLARE @tblRawDataImages_N udt_RawDataTableImage
	--DECLARE @tblRawDataLatLongDetails_N udt_RawDataLatLongDetails

	
	--DECLARE @RsltOutletQuestAnsMstr TABLE(GrpQuestId INT,QstId INT,AnsControlTypeId INT,AnsValId VARCHAR(500),AnsTextVal VARCHAR(500),OptionValue VARCHAR(50))
	DECLARE @RsltOutletQuestAnsMstr udtResponse

	--DECLARE @RsltSalesQuotePaymentDetails TABLE(PymtStageId INT,Percentage NUMERIC(5,2),CreditDays SMALLINT,CreditLimit DECIMAL(18,4),CreditPeriodTypeId TINYINT,GracePeriodInDays SMALLINT,PymtMode VARCHAR(40))
	DECLARE @RsltSalesQuotePaymentDetails PaymentStage
	DECLARE @RsltStoreImages udt_Image
	DECLARE @RsltGPSInfo udt_GPSInfo


	CREATE TABLE #tmpOutletQuestAnsMstr(ID INT IDENTITY(1,1),QuestID INT,AnswerType INT,AnswerValue VARCHAR(500),QuestionGroupID INT,SectionID INT)
	CREATE TABLE #tmpOutletSalesQuotePaymentDetails(ID INT IDENTITY(1,1),PymtStageId VARCHAR(500))
	CREATE TABLE #tmpOutletImages(ID INT IDENTITY(1,1),PhotoName VARCHAR(500),ImageCntrlType VARCHAR(50))

	CREATE TABLE #Values(ID INT IDENTITY(1,1),AnswerVal VARCHAR(200))
	CREATE TABLE #Values_2(ID INT IDENTITY(1,1),AnswerVal_2 VARCHAR(200))

	PRINT 'Prepare Question answer table'
	INSERT INTO #tmpOutletQuestAnsMstr(QuestID,AnswerType,AnswerValue,QuestionGroupID,SectionID)
	SELECT QuestID,AnswerType,AnswerValue,QuestionGroupID,SectionID
	FROM @tblRawDataOutletQuestAnsMstr
	WHERE OutletId=@StrStoreId
	
	SET @Counter=1
	SELECT @MaxCount=MAX(Id) FROM #tmpOutletQuestAnsMstr
	WHILE @Counter<=@MaxCount
	BEGIN
		SELECT @QuestID=QuestID,@AnswerType=AnswerType,@AnswerValue=AnswerValue,@QuestionGroupID=QuestionGroupID,@SectionID=SectionID FROM #tmpOutletQuestAnsMstr WHERE Id=@Counter
		
		IF @AnswerType IN(1,4,6,7,8,13)
		BEGIN
			INSERT INTO @RsltOutletQuestAnsMstr(GrpQuestId,QstId,AnsControlTypeId,AnsValId,AnsTextVal)
			SELECT @QuestionGroupID,@QuestID,@AnswerType,@AnswerValue,NULL
		END
		ELSE IF @AnswerType IN(2,3,11,12,18)
		BEGIN
			INSERT INTO @RsltOutletQuestAnsMstr(GrpQuestId,QstId,AnsControlTypeId,AnsValId,AnsTextVal)
			SELECT @QuestionGroupID,@QuestID,@AnswerType,NULL,@AnswerValue
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
					INSERT INTO @RsltOutletQuestAnsMstr(GrpQuestId,QstId,AnsControlTypeId,AnsValId,AnsTextVal)
					SELECT @QuestionGroupID,@QuestID,@AnswerType,A.AnswerVal_2,B.AnswerVal_2
					FROM (SELECT AnswerVal_2 FROM #Values_2 WHERE Id=1) A,(SELECT AnswerVal_2 FROM #Values_2 WHERE Id=2) B
				END
				ELSE
				BEGIN
					INSERT INTO @RsltOutletQuestAnsMstr(GrpQuestId,QstId,AnsControlTypeId,AnsValId,AnsTextVal)
					SELECT @QuestionGroupID,@QuestID,@AnswerType,A.AnswerVal_2,''
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

				INSERT INTO @RsltOutletQuestAnsMstr(GrpQuestId,QstId,AnsControlTypeId,AnsValId,AnsTextVal)
				SELECT @QuestionGroupID,@QuestID,@AnswerType,A.AnswerVal_2,B.AnswerVal_2
				FROM (SELECT AnswerVal_2 FROM #Values_2 WHERE Id=1) A,(SELECT AnswerVal_2 FROM #Values_2 WHERE Id=2) B
				
				SET @i+=1
			END
		END

		SET @Counter+=1
	END
	--SELECT * FROM @RsltOutletQuestAnsMstr order by AnsControlTypeId

	PRINT 'Prepare Payment Stage table'
	INSERT INTO #tmpOutletSalesQuotePaymentDetails(PymtStageId)
	SELECT PymtStageId
	FROM @tblRawDataSalesQuotePaymentDetails
	WHERE StoreId=@StrStoreId

	SET @Counter=1
	SET @MaxCount=0
	SELECT @MaxCount=MAX(Id) FROM #tmpOutletSalesQuotePaymentDetails
	WHILE @Counter<=@MaxCount
	BEGIN
		SELECT @strPymtStageId=PymtStageId FROM #tmpOutletSalesQuotePaymentDetails WHERE Id=@Counter

		TRUNCATE TABLE #Values
		INSERT INTO #Values(AnswerVal)
		SELECT items from dbo.Split(@strPymtStageId,'$')

		SET @i=1
		SET @iCount=0
		SELECT @iCount=MAX(Id) FROM #Values
		WHILE @i<=@iCount
		BEGIN
			SELECT @Values=AnswerVal  FROM #Values WHERE Id=@i

			TRUNCATE TABLE #Values_2
			INSERT INTO #Values_2(AnswerVal_2)
			SELECT items from dbo.Split(@Values,'~')

			INSERT INTO @RsltSalesQuotePaymentDetails(PymtStageId,Percentage,CreditDays,CreditLimit,CreditPeriodTypeId,GracePeriodInDays,PymtMode)
			SELECT A.AnswerVal_2,B.AnswerVal_2,C.AnswerVal_2,D.AnswerVal_2,1,0,E.AnswerVal_2
			FROM (SELECT AnswerVal_2 FROM #Values_2 WHERE Id=1) A,(SELECT AnswerVal_2 FROM #Values_2 WHERE Id=2) B,(SELECT AnswerVal_2 FROM #Values_2 WHERE Id=3) C,(SELECT AnswerVal_2 FROM #Values_2 WHERE Id=4) D,(SELECT AnswerVal_2 FROM #Values_2 WHERE Id=5) E

			SET @i+=1
		END

		SET @Counter+=1
	END
	--SELECT * FROM @RsltSalesQuotePaymentDetails

	PRINT 'Prepare Image table'
	INSERT INTO #tmpOutletImages(PhotoName,ImageCntrlType)
	SELECT PhotoName,QstIdAnsCntrlTyp
	FROM @tblRawDataImages
	WHERE StoreId=@StrStoreId
	--SELECT * FROM #tmpOutletImages
	SET @Counter=1
	SET @MaxCount=0
	SELECT @MaxCount=MAX(Id) FROM #tmpOutletImages
	WHILE @Counter<=@MaxCount
	BEGIN
		SELECT @PhotoName=PhotoName,@ImageCntrlType=ImageCntrlType FROM #tmpOutletImages WHERE Id=@Counter

		TRUNCATE TABLE #Values
		INSERT INTO #Values(AnswerVal)
		SELECT items from dbo.Split(@ImageCntrlType,'^')
		--SELECT * FROM #Values

		INSERT INTO @RsltStoreImages(ImageName,ImgType)
		SELECT @PhotoName,CASE (SELECT AnswerVal FROM #Values WHERE Id=3) WHEN 13 THEN 1 WHEN 16 THEN 2 WHEN 17 THEN 3 ELSE 10 END
		
		SET @Counter+=1
	END
	--SELECT * FROM @RsltStoreImages

	PRINT 'GPS Info'
	INSERT INTO @RsltGPSInfo(StoreId,[Address],Distance,AllProviderData,GPSLatitude,GPSLongitude,GPSAccuracy,GPSAddress,NetworkLatitude, NetworkLongitude,NetworkAccuracy,NetworkAddress,FusedLatitude,FusedLongitude,FusedAccuracy,FusedAddress)
	SELECT StoreId,[fnAddress],null,[AllProvidersLocation],CASE LEN([GpsLat]) WHEN 0 THEN NULL ELSE [GpsLat] END [GpsLat],CASE LEN([GpsLong]) WHEN 0 THEN NULL ELSE [GpsLong] END [GpsLong],[GpsAccuracy],[GpsAddress],CASE LEN([NetwLat]) WHEN 0 THEN NULL ELSE [NetwLat] END [NetwLat],CASE LEN([NetwLong]) WHEN 0 THEN NULL ELSE [NetwLong] END [NetwLong],[NetwAccuracy], [NetwAddress],CASE LEN([FusedLat]) WHEN 0 THEN NULL ELSE [FusedLat] END [FusedLat],CASE LEN([FusedLong]) WHEN 0 THEN NULL ELSE [FusedLong] END [FusedLong],[FusedAccuracy],[FusedAddress]
	FROM @tblRawDataLatLongDetails
	WHERE StoreId=@StrStoreId
	--SELECT * FROM @RsltGPSInfo

	DECLARE @VisitStartTS DATETIME
	DECLARE @VisitEndTS DATETIME
	DECLARE @AppVersion INT=1
	DECLARE @ActualLatitude decimal(30, 27)
	DECLARE @ActualLongitude decimal(30, 27)
	DECLARE @LocProvider varchar(20)
	DECLARE @Accuracy varchar (100)  
	DECLARE @BatteryStatus varchar(10)
	--DECLARE @Imei varchar (100)
	--DECLARE @XMLFullDate varchar (100)
	DECLARE @XMLReceiveDate_N DATETIME
	DECLARE @OutStat int=4
	--DECLARE @tblQuestAns udtResponse Readonly
	--DECLARE @PaymentStage [PaymentStage] readonly
	DECLARE @StoreMapAddress VARCHAR(2000)  =''
	DECLARE @City VARCHAR(200)
	DECLARE @PinCode BIGINT
	DECLARE @State VARCHAR(200)
	--DECLARE @StoreImages udt_Image ReadOnly,  -- 1=Shop Sign board,2=Shop Front,3=manager businesscard,4=Chef businesscard,5=Owner businesscard
	--DECLARE @tblGPSInfo udt_GPSInfo ReadOnly,
	DECLARE @flgLocationServicesOnOff TINYINT
	DECLARE @flgGPSOnOff TINYINT
	DECLARE @flgNetworkOnOff TINYINT
	DECLARE @flgFusedOnOff TINYINT
	DECLARE @flgInternetOnOff TINYINT
	DECLARE @flgRestart TINYINT
	DECLARE @Address VARCHAR(500)
	DECLARE @MapCity VARCHAR(200)
	DECLARE @MapState VARCHAR(200)
	DECLARE @MapPinCode BIGINT
	DECLARE @CityID INT
	DECLARE @StateID INT
	CREATE TABLE #tmpStoreIdDB(StoreIdDB INT)
	CREATE TABLE #tmpOrgStoreId(OrgStoreId INT)
	--SELECT CONVERT(DATETIME,[VisitStartTS],105) FROM @tblVisitStoreList
	--SELECT CONVERT(DATETIME,[VisitEndTS],105) FROM @tblVisitStoreList
	PRINT 'AA'
	PRINT '@StrStoreId=' + @StrStoreId
	SELECT 'AA gaya'
	SELECT * FROM @tblStoreList
	SELECT * FROM @tblRawDataLatLongDetails
	SELECT @ActualLatitude=[FusedLat],@ActualLongitude=[FusedLong] FROM @tblRawDataLatLongDetails WHERE StoreId=@StrStoreId 

	SELECT CONVERT(DATETIME,CreatedDate,105),CONVERT(DATETIME,CreatedDate,105),[StoreCity],[StorePinCode],[StoreState],[flgRestart],[StoreAddress],[StoreCityID],[StoreStateID]
	FROM @tblStoreList
	WHERE StoreId=@StrStoreId


	SELECT @VisitStartTS=CONVERT(DATETIME,CreatedDate,105),@VisitEndTS=CONVERT(DATETIME,CreatedDate,105),@City=[StoreCity],@PinCode=[StorePinCode],@State=[StoreState],@flgRestart=[flgRestart],@Address=[StoreAddress],@CityID=[StoreCityID],@StateID=[StoreStateID]
	FROM @tblStoreList
	WHERE StoreId=@StrStoreId


	SELECT @Accuracy=[Accuracy],@BatteryStatus=[BateryLeftStatus],@LocProvider=[LocProvider],@flgLocationServicesOnOff=[flgLocationServicesOnOff],@flgGPSOnOff=[flgGPSOnOff],@flgNetworkOnOff=[flgNetworkOnOff],@flgFusedOnOff=[flgFusedOnOff],@flgInternetOnOff=[flgInternetOnOffWhileLocationTracking] FROM @tblRawDataNewStoreLocationDetails WHERE StoreID=@StrStoreId

	SELECT @MapCity=[MapCity],@MapState=[MapState],@MapPinCode=[MapPinCode],@StoreMapAddress=ISNULL([MapAddress],'NA') FROM @tblRawDataCustomerVisit WHERE StoreID=@StrStoreId

	--SELECT @VisitStartTS
	--SELECT @VisitEndTS

	--SELECT @XMLReceiveDate
	SELECT @XMLReceiveDate_N=@XMLReceiveDate

	--SELECT @XMLReceiveDate_N
	--SELECT * FROM @RsltOutletQuestAnsMstr
	--SELECT * FROM @RsltSalesQuotePaymentDetails
	--SELECT * FROM @RsltStoreImages
	SELECT * FROM @tblStoreList
	SELECT * FROM @RsltGPSInfo

	PRINT 'calling of SP [spPDA_Save_StoreMappingDetails_SFA]'
	--SELECT @Accuracy
	PRINT '@ActualLatitude=' + CAST(@ActualLatitude AS VARCHAR)
	EXEC [spPDA_Save_StoreMappingDetails_SFA] @StrStoreId,@VisitStartTS,@VisitEndTS,@AppVersion,@ActualLatitude,@ActualLongitude,@LocProvider,@Accuracy,@BatteryStatus,@PDA_IMEI,@XMLFullName,  
@XMLReceiveDate_N,@OutStat,@RsltOutletQuestAnsMstr,@RsltSalesQuotePaymentDetails,@StoreMapAddress,@City,@PinCode,@State,@RsltStoreImages,@RsltGPSInfo,@flgLocationServicesOnOff,@flgGPSOnOff,@flgNetworkOnOff,@flgFusedOnOff,@flgInternetOnOff,@flgRestart,@Address,@MapCity,@MapState,@MapPinCode,@CityID,@StateID,@FileSetID

	SELECT @StoreIDDB=StoreIdDB FROM #tmpStoreIdDB

	PRINT 'calling of SP [spSaveValidatedStore]'
	PRINT '@StoreIDDB=' + CAST(@StoreIDDB AS VARCHAR)
	EXEC [spSaveValidatedStore] @StoreIDDB,0

	SELECT @OrgStoreId=OrgStoreId FROM #tmpOrgStoreId
END
