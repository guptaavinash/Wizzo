-- =============================================
-- Author:		Avinash Gupta
-- Create date: 12-Jun-2019
-- Description:	Saving All the App Data
-- =============================================
-- DROP PROC SpSaveAllData
CREATE PROCEDURE [dbo].[SpSaveAllData] 
	@FileSetId INT,
	@ImeiNo VARCHAR(50),
	@FileName VARCHAR(100),
	@receivedDate DATETIME,
	@tblRawDataPersonRegDetails udt_RawDataPersonRegDetails READONLY,
	@tblRawDataAttandanceDetails udt_RawDataAttandanceDetails READONLY,
	@tblRawDataStoreLocationDetails udt_RawDataLatLongDetails READONLY,
	@tblRawDataStoreList udt_RawDataStoreList READONLY,
	@tblRawDataQuestAnsMstr udt_RawDataOutletQuestAnsMstr READONLY,
	@tblRawDataNewStoreLocationDetails udt_RawDataNewStoreLocationDetails READONLY,
	@tblRawDataCustomerVisit udt_RawDataCustomerVisit READONLY,
	@tblRawDataInvoiceHeader udt_RawDataInvoiceHeader READONLY,
	@tblRawDataInvoiceDetail udt_RawDataInvoiceDetail READONLY,
	@tblRawDataDeliveryDetails udt_RawDataDeliveryDetails READONLY,
	@tblRawDataCollectionData udt_RawDataCollectionData READONLY,
	@tblRawDataStoreReturnDetail udt_RawDataStoreReturnDetail READONLY,
	@tblRawDataStoreCloseLocationDetail udt_RawDataStoreCloseLocationDetail READONLY,
	@tblRawDataStoreClosePhotoDetail udt_RawDataStoreClosePhotoDetail READONLY,
	@tblRawDataStoreReasonSaving udt_RawDataStoreReasonSaving READONLY,
	@tblRawDataDayEndDet udt_RawDataDayEndDet READONLY,
	@tblRawDataNoVisitStoreDetails udt_RawDataNoVisitStoreDetails READONLY,
	@tblRawDataStoreMultipleVisitDetail udt_RawDataStoreMultipleVisitDetail READONLY,
	@tblRawStoreCheckData udt_RawStoreCheckData READONLY,
	@tblRawDataSelectedManagerDetails udt_RawDataSelectedManagerDetails READONLY,
	@tblRawDataProductReturnImage udt_RawDataProductReturnImage READONLY,
	@tblRawDataTableImage udt_RawDataTableImage READONLY,
	@tblRawDataStoreCheckImage udt_RawDataStoreCheckImage READONLY,
	@tblRawDataInvoiceExecution udt_RawDataInvoiceExecution READONLY,
	@tblRawDataInvoiceImages udt_RawDataInvoiceImages READONLY,
	@tblRawDistProductStock udt_RawDistProductStock READONLY,
	@tblRawDataCartonMaster udt_RawDataCartonMaster READONLY,
	@tblRawDataCartonDetail udt_RawDataCartonDetail READONLY,
	@tblRawDataJointVisitMaster udt_RawDataJointVisitMaster READONLY,
	@tblRawDataJointVisitDetail udt_RawDataJointVisitDetail READONLY,
	@tblRawGateMeetingTarget udt_RawGateMeetingTarget READONLY,
	@tblRawGateMeetingTargetDet udt_RawGateMeetingTargetDet READONLY,
	@tblPotentialDBRetailerData_XMLSaving udt_PotentialDBRetailerData_XMLSaving READONLY 
AS
BEGIN
	DECLARE @tblRawDataPersonRegDetails_N udt_RawDataPersonRegDetails
	DECLARE @tblRawDataAttandanceDetails_N udt_RawDataAttandanceDetails
	DECLARE @tblRawDataStoreLocationDetails_N udt_RawDataLatLongDetails
	DECLARE @tblRawDataStoreList_N udt_RawDataStoreList 
	DECLARE @tblRawDataQuestAnsMstr_N udt_RawDataOutletQuestAnsMstr 
	DECLARE @tblRawDataCustomerVisit_N udt_RawDataCustomerVisit 
	DECLARE @tblRawDataInvoiceHeader_N udt_RawDataInvoiceHeader 
	DECLARE @tblRawDataInvoiceDetail_N udt_RawDataInvoiceDetail 
	DECLARE @tblRawDataDeliveryDetails_N udt_RawDataDeliveryDetails
	DECLARE @tblRawDataCollectionData_N udt_RawDataCollectionData
	DECLARE @tblRawDataNewStoreLocationDetails_N udt_RawDataNewStoreLocationDetails
	 
	DECLARE @tblRawDataDayEndDet_N udt_RawDataDayEndDet 
	DECLARE @tblRawDataNoVisitStoreDetails_N udt_RawDataNoVisitStoreDetails 
	DECLARE @tblRawDataStoreMultipleVisitDetail_N udt_RawDataStoreMultipleVisitDetail 
	DECLARE @tblRawStoreCheckData_N udt_RawStoreCheckData 
	DECLARE @tblRawStoreCheckData_Working udt_RawStoreCheckData 
	DECLARE @tblRawDataSelectedManagerDetails_N udt_RawDataSelectedManagerDetails 
	DECLARE @tblRawDataProductReturnImage_N udt_RawDataProductReturnImage 
	DECLARE @tblRawDataTableImage_N udt_RawDataTableImage 
	DECLARE @tblRawDataStoreCheckImage_N udt_RawDataStoreCheckImage 

	DECLARE @tblRawDistProductStock_N udt_RawDistProductStock 
	DECLARE @tblRawDataCartonMaster_N udt_RawDataCartonMaster
	DECLARE @tblRawDataCartonDetail_N udt_RawDataCartonDetail

	DECLARE @tblRawDataJointVisitMaster_N udt_RawDataJointVisitMaster
	DECLARE @tblRawDataJointVisitDetail_N udt_RawDataJointVisitDetail
	DECLARE @tblPotentialDBRetailerData_XMLSaving_N udt_PotentialDBRetailerData_XMLSaving

	INSERT INTO @tblRawDataPersonRegDetails_N SELECT * FROM @tblRawDataPersonRegDetails
	INSERT INTO @tblRawDataAttandanceDetails_N SELECT * FROM @tblRawDataAttandanceDetails
	INSERT INTO @tblRawDataStoreLocationDetails_N SELECT * FROM @tblRawDataStoreLocationDetails
	INSERT INTO @tblRawDataStoreList_N SELECT * FROM @tblRawDataStoreList
	INSERT INTO @tblRawDataQuestAnsMstr_N SELECT * FROM @tblRawDataQuestAnsMstr
	INSERT INTO @tblRawDataCustomerVisit_N SELECT * FROM @tblRawDataCustomerVisit
	INSERT INTO @tblRawDataInvoiceHeader_N SELECT * FROM @tblRawDataInvoiceHeader
	INSERT INTO @tblRawDataInvoiceDetail_N SELECT * FROM @tblRawDataInvoiceDetail
	INSERT INTO @tblRawDataCollectionData_N SELECT * FROM @tblRawDataCollectionData
	INSERT INTO @tblRawDataDayEndDet_N SELECT * FROM @tblRawDataDayEndDet
	INSERT INTO @tblRawDataNoVisitStoreDetails_N SELECT * FROM @tblRawDataNoVisitStoreDetails
	INSERT INTO @tblRawDataStoreMultipleVisitDetail_N SELECT * FROM @tblRawDataStoreMultipleVisitDetail
	INSERT INTO @tblRawStoreCheckData_N SELECT * FROM @tblRawStoreCheckData
	INSERT INTO @tblRawDataSelectedManagerDetails_N SELECT * FROM @tblRawDataSelectedManagerDetails
	INSERT INTO @tblRawDataProductReturnImage_N SELECT * FROM @tblRawDataProductReturnImage
	INSERT INTO @tblRawDataTableImage_N SELECT * FROM @tblRawDataTableImage
	INSERT INTO @tblRawDataStoreCheckImage_N SELECT * FROM @tblRawDataStoreCheckImage
	INSERT INTO @tblRawDataNewStoreLocationDetails_N SELECT * FROM @tblRawDataNewStoreLocationDetails

	INSERT INTO @tblRawDistProductStock_N SELECT * FROM @tblRawDistProductStock
	INSERT INTO @tblRawDataCartonMaster_N SELECT * FROM @tblRawDataCartonMaster
	INSERT INTO @tblRawDataCartonDetail_N SELECT * FROM @tblRawDataCartonDetail

	INSERT INTO @tblRawDataJointVisitMaster_N SELECT * FROM @tblRawDataJointVisitMaster
	INSERT INTO @tblRawDataJointVisitDetail_N SELECT * FROM @tblRawDataJointVisitDetail

	INSERT INTO @tblPotentialDBRetailerData_XMLSaving_N SELECT * FROM @tblPotentialDBRetailerData_XMLSaving
	


	UPDATE N SET Pincode=NULL FROM @tblRawDataAttandanceDetails_N N WHERE Pincode='null' OR Pincode='NA'
	UPDATE N SET MapPinCode=NULL FROM @tblRawDataAttandanceDetails_N N WHERE MapPinCode='null' OR MapPincode='NA'


	UPDATE N SET [BateryLeftStatus]=REPLACE([BateryLeftStatus],'%','') FROM @tblRawDataCustomerVisit_N N 

	UPDATE N SET Accuracy=CAST(ROUND(Accuracy,0) AS INT) FROM @tblRawDataNewStoreLocationDetails_N N
	UPDATE N SET Accuracy=CAST(ROUND(Accuracy,0) AS INT) FROM @tblRawDataCustomerVisit_N N
	UPDATE N SET Accuracy=CAST(ROUND(Accuracy,0) AS INT) FROM @tblRawDataStoreList_N N
	UPDATE N SET [fnAccuracy]=CAST(ROUND([fnAccuracy],0) AS INT),[GpsAccuracy]=CAST(ROUND([GpsAccuracy],0) AS INT),[NetwAccuracy]=CAST(ROUND([NetwAccuracy],0) AS INT),[FusedAccuracy]=CAST(ROUND([FusedAccuracy],0) AS INT) FROM @tblRawDataStoreLocationDetails_N N

	UPDATE N SET MapPinCode=NULL FROM @tblRawDataCustomerVisit_N N WHERE MapPinCode='NA' OR MapPinCode='null'
 

	UPDATE N SET MarriedDate=null FROM @tblRawDataPersonRegDetails_N N WHERE MarriedDate='null'

	UPDATE N SET StoreVisitCode=NULL FROM @tblRawDataInvoiceHeader_N N WHERE StoreVisitCode='NA' OR StoreVisitCode='null'

	UPDATE N SET StorePinCode=NULL FROM @tblRawDataStoreList_N N WHERE StorePinCode='NA'
	UPDATE N SET MapStorePinCode=NULL FROM @tblRawDataStoreList_N N WHERE MapStorePinCode='NA'
	UPDATE N SET [StoreStateID]=NULL FROM @tblRawDataStoreList_N N WHERE [StoreStateID]='null'
	UPDATE N SET [StoreCityID]=NULL FROM @tblRawDataStoreList_N N WHERE [StoreCityID]='null'
	UPDATE N SET [StoreContactNo]=NULL FROM @tblRawDataStoreList_N N WHERE [StoreContactNo]='null'

	--SELECT * FROM @tblRawDataDayEndDet_N

	UPDATE R SET EndTime=null FROM @tblRawDataDayEndDet_N R WHERE EndTime='null'
	UPDATE R SET EndTime=null FROM @tblRawDataDayEndDet_N R WHERE EndTime='null'
	UPDATE N SET StartTime=NULL FROM @tblRawDataDayEndDet_N N WHERE StartTime='null'
	UPDATE N SET EndTime=NULL FROM @tblRawDataDayEndDet_N N WHERE EndTime='null'
	UPDATE N SET ForDate=NULL FROM @tblRawDataDayEndDet_N N WHERE ForDate='null'

	UPDATE N SET StoreVisitCode=NULL FROM @tblRawStoreCheckData_N N WHERE StoreVisitCode='null'
	UPDATE N SET StoreVisitCode=NULL FROM @tblRawDataStoreCheckImage_N N WHERE StoreVisitCode='null'

	UPDATE N SET Productprice=0 FROM @tblRawDataInvoiceDetail_N N WHERE ProductPrice='null'
	DECLARE @PersonNodeID Integer=0 
	DECLARE @PersonNodeType Integer=0 
	--- Finding the Person sending the data
	DECLARE @FilePersonNodeID INT
	DECLARE @FilePersonNodeType INT

	SELECT @FilePersonNodeID=NodeID,@FilePersonNodeType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@ImeiNo) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID


	--- Saving Person Registration Detail  ##############################################################################################################################
	DECLARE @Name VARCHAR(200),@ContactNo VARCHAR(15),@DOB VARCHAR(25),@Gender VARCHAR(10),@IsMarried TINYINT,@MarriageDate VARCHAR(25),@Qualification VARCHAR(100),@EmailId VARCHAR(200),@BloodGroup VARCHAR(5),@SelfieName VARCHAR(200),@PhotoName VARCHAR(200),@SignImgName VARCHAR(200),
	@RegPersonNodeId INT,@RegPersonNodeType INT,@RegistrationDateTime VARCHAR(25),@BankAccountnumber VARCHAR(20),@BankID INT,@IFSCCode VARCHAR(20),@flgUPIID TINYINT,@UPIID INT,@AadhaarNumber NUMERIC(12,0)

	--- Person Registration
	IF EXISTS (SELECT 1 FROM @tblRawDataPersonRegDetails_N)
	BEGIN
		SELECT * FROM @tblRawDataPersonRegDetails_N
		PRINT 'Registration Called'
		SELECT @Name=[Name],@ContactNo=[ContactNo],@DOB=DOB,@Gender=Sex,@IsMarried=MaritalStatus,@MarriageDate=MarriedDate,@Qualification=Qualification,@EmailId=EmailID,@BloodGroup=BloodGroup,@SelfieName=SelfieName,@PhotoName=PhotoName,@SignImgName=SignName,@RegPersonNodeId=PersonNodeId,@RegPersonNodeType=PersonNodeType,@RegistrationDateTime=[ClickedDateTime],@BankAccountnumber=BankAccountnumber,@BankID=BankID,@IFSCCode=IFSCCode,@flgUPIID=flgUPIID,@UPIID=UPIID,@AadhaarNumber=AadhaarNumber FROM @tblRawDataPersonRegDetails_N WHERE IMEI=@ImeiNo
		EXEC spSavePersonRegistrationDetails @ImeiNo,@Name,@ContactNo,@DOB,@Gender,@IsMarried,@MarriageDate,@Qualification,@EmailId,@BloodGroup,@SelfieName,@SelfieName,@SignImgName,@RegPersonNodeId,@RegPersonNodeType,@RegistrationDateTime,@FileSetId
	END
	--#####################################################################################################################################################################

	--- No Visit Saving Data
	DECLARE @NoVisitReasonID INT,@NoVisitReasonDescr VARCHAR(100),@CurrentDate DATE
	IF EXISTS (SELECT 1 FROM @tblRawDataNoVisitStoreDetails)
	BEGIN
		SELECT @CurrentDate=[CurDate],@NoVisitReasonID=ReasonID,@NoVisitReasonDescr=ReasonDescr FROM @tblRawDataNoVisitStoreDetails WHERE IMEI=@IMEiNo
		EXEC spSaveReasonForNoVisit @IMEiNo,@CurrentDate,@NoVisitReasonID,@NoVisitReasonDescr
	END

	--- Person Attendance
	DECLARE @tblAttReason udt_AttReason,@Address VARCHAR(500),@LatCode DECIMAL(18,6),@LongCode DECIMAL(18,6),@AllProvidersLocation VARCHAR(MAX),@Datetime Datetime,@Comments VARCHAR(200),@DBNodeID INT,@DBNodetype TINYINT,@strReasonId VARCHAR(200),@strReason VARCHAR(500),@Accuracy NUMERIC(10,2),@VisitID INT,@flgLocationServicesOnOff TINYINT,@flgGPSOnOff TINYINT,@flgNetworkOnOff TINYINT,@flgFusedOnOff TINYINT,@flgInternetOnOffWhileLocationTracking TINYINT,@BatteryStatus INT,
	@PinCode VARCHAR(20),@City VARCHAR(100),@State VARCHAR(200),@MapAddress VARCHAR(500),@MapCity VARCHAR(200),@MapPinCode VARCHAR(50),@MapState VARCHAR(200),@IsNetworkTimeRecorded TINYINT,@OSVersion VARCHAR(100),@DeviceID VARCHAR(100),@BrandName VARCHAR(100),@Model VARCHAR(100),@DeviceDatetime Datetime,@LeaveStartDate Date,@LeaveEndDate Date,@SelfieNameDaily VARCHAR(200)
	
	IF EXISTS(SELECT 1 FROM @tblRawDataAttandanceDetails_N WHERE isnull(PersonNodeID,0)<>0)
	BEGIN
		CREATE TABLE #ReasonId(ID INT IDENTITY(1,1),ReasonId INT)
		CREATE TABLE #Reason(ID INT IDENTITY(1,1),ReasonDescr VARCHAR(200))


		SELECT @Datetime=AttandanceTime,@PersonNodeID=PersonNodeID,@Address=fnAddress,@PinCode=PinCode,@City=City,@State=State,@MapAddress=MapAddress,@MapCity=MapCity,@MapPinCode=MapPinCode,@MapState=MapState,@LatCode=REPLACE(fnLati,'NA',0),@LongCode=REPLACE(fnLongi,'NA',0),@Accuracy=REPLACE(fnAccuracy,'NA',0), @AllProvidersLocation=AllProvidersLocation,@Comments=Comment,@strReasonId=ReasonID,@strReason=ReasonDesc,@VisitID=0,@DBNodeID=0,@DBNodetype=0,@flgLocationServicesOnOff=flgLocationServicesOnOff,@flgGPSOnOff=flgGPSOnOff,@flgNetworkOnOff=flgNetworkOnOff,@flgFusedOnOff=flgFusedOnOff,@flgInternetOnOffWhileLocationTracking=flgInternetOnOffWhileLocationTracking,@BatteryStatus=[BatteryStatus],@IsNetworkTimeRecorded=[IsNetworkTimeRecorded],@OSVersion=[OSVersion],@DeviceID=[device],@BrandName=[BrandName],@Model=[Model],@DeviceDatetime=DeviceDatetime,@LeaveStartDate=LeaveStartDate,@LeaveEndDate=LeaveEndDate,@SelfieNameDaily=SelfieName
		FROM @tblRawDataAttandanceDetails_N

		INSERT INTO #ReasonId(ReasonId)
		SELECT items FROM dbo.Split(@strReasonId,'$')

		INSERT INTO #Reason(ReasonDescr)
		SELECT items FROM dbo.Split(@strReason,'$')

		INSERT INTO @tblAttReason(ReasonId,ResonDescr)
		SELECT A.ReasonId,B.ReasonDescr
		FROM #ReasonId A LEFT JOIN #Reason B ON A.Id=B.Id
		--SELECT * FROM @tblRawDataAttandanceDetails
		--SELECT * FROM #ReasonId
		PRINT 'Attendance'
		PRINT '@FileSetId=' + CAST(@FileSetId AS VARCHAR)
		--SELECT * FROM @tblRawDataAttandanceDetails_N
		--SELECT 1
		EXEC [SpSavePersonAttendance] @FileSetID,@PersonNodeID,@tblAttReason,@Address,@LatCode,@LongCode,@Accuracy,@AllProvidersLocation,@Datetime,@VisitID,@ImeiNo,@Comments,@DBNodeID,@DBNodetype,@flgLocationServicesOnOff,	@flgGPSOnOff,@flgNetworkOnOff,@flgFusedOnOff,@flgInternetOnOffWhileLocationTracking,@tblRawDataStoreLocationDetails_N,@BatteryStatus,@PinCode,@City,@State,@MapAddress,@MapCity,@MapPinCode,@MapState,@IsNetworkTimeRecorded,@OSVersion,@DeviceID,@BrandName,@Model,@DeviceDatetime,@LeaveStartDate,@LeaveEndDate,@SelfieNameDaily
		PRINT 'Attendance Saved'
	
	END

	--- Joint manager details #############################################################################################################################################
	DECLARE @ManagerNodeId INT,@ManagerNodeType INT,@ManagerName VARCHAR(200),@OtherManagerName VARCHAR(200),@VisitDate DATE

	IF EXISTS(SELECT 1 FROM @tblRawDataSelectedManagerDetails WHERE isnull(ManagerId,0)<>0)
	BEGIN
		SELECT 'manager Deatils Called'
		SELECT * FROM @tblRawDataSelectedManagerDetails

		SELECT @VisitDate=CurDate,@ImeiNo=IMEI,@ManagerNodeId=ManagerID,@ManagerNodeType=[ManagerType],@ManagerName=[ManagerName],@OtherManagerName=[OtherName],@PersonNodeID=[PersonID],@PersonNodetype=PersonType FROM @tblRawDataSelectedManagerDetails_N

		EXEC [spSaveManagerDetails] @ImeiNo,@VisitDate,@PersonNodeID,@PersonNodetype,@ManagerNodeId,@ManagerNodeType,@ManagerName,@OtherManagerName
	END

	--######################################################################################################################################################################


	--- Saving New Store ####################################################################################################################################################
	DECLARE @tblRawDataSalesQuotePaymentDetails_N udt_RawDataNewStoreSalesQuotePaymentDetails

	DECLARE @Counter INT
	DECLARE @MaxCount INT
	DECLARE @StoreId INT
	DECLARE @StrStoreId VARCHAR(100)
	DECLARE @OrgStoreId INT
	IF EXISTS(SELECT 1 FROM @tblRawDataStoreList_N WHERE ISNewStore=1)
	BEGIN
		SELECT 'New Store Saving Called'
		SELECT DISTINCT StoreId FROM @tblRawDataStoreList_N WHERE ISNewStore=1

		CREATE TABLE #NewStoreList(ID INT IDENTITY(1,1),StrStoreId VARCHAR(100), StoreId INT)
		INSERT INTO #NewStoreList(StrStoreId)
		SELECT DISTINCT StoreId FROM @tblRawDataStoreList_N WHERE ISNewStore=1

		SET @Counter=1
		SELECT @MaxCount=MAX(Id) FROM #NewStoreList

		WHILE @Counter<=@MaxCount
		BEGIN
			SELECT @OrgStoreId=NULL

			SELECT @StrStoreId=StrStoreId  FROM #NewStoreList WHERE Id=@Counter
			SELECT @StrStoreId
			--SELECT * FROM @tblRawDataQuestAnsMstr_N WHERE OutletId=@StrStoreId

			IF EXISTS(SELECT 1 FROM @tblRawDataQuestAnsMstr_N WHERE OutletId=@StrStoreId)
			BEGIN
				SELECT * FROM @tblRawDataTableImage_N
				EXEC [spPrepareDetailsAndSaveNewStore] @StrStoreId,@ImeiNo,@FileName,@receivedDate,@tblRawDataStoreList_N,@tblRawDataQuestAnsMstr_N,@tblRawDataSalesQuotePaymentDetails_N, @tblRawDataTableImage_N,@tblRawDataStoreLocationDetails_N,@tblRawDataNewStoreLocationDetails_N,@tblRawDataCustomerVisit_N,@OrgStoreId OUTPUT,@FileSetId

				SELECT @OrgStoreId AS OrgStoreId

				UPDATE @tblRawDataStoreList_N  SET StoreId=@OrgStoreId WHERE StoreId=@StrStoreId
				UPDATE @tblRawDataCustomerVisit_N  SET StoreId=@OrgStoreId WHERE StoreId=@StrStoreId
				UPDATE @tblRawDataStoreMultipleVisitDetail_N  SET StoreId=@OrgStoreId WHERE StoreId=@StrStoreId
				UPDATE @tblRawDataStoreLocationDetails_N   SET StoreId=@OrgStoreId WHERE StoreId=@StrStoreId
				UPDATE @tblRawDataInvoiceHeader_N  SET StoreId=@OrgStoreId WHERE StoreId=@StrStoreId
				UPDATE @tblRawDataInvoiceDetail_N  SET StoreId=@OrgStoreId WHERE StoreId=@StrStoreId
				UPDATE @tblRawStoreCheckData_N  SET StoreId=@OrgStoreId WHERE StoreId=@StrStoreId
				UPDATE @tblRawDataStoreCheckImage_N  SET StoreId=@OrgStoreId WHERE StoreId=@StrStoreId
				UPDATE @tblRawDataCartonMaster_N SET StoreID=@OrgStoreId WHERE StoreID=@StrStoreId

			END

			SET @Counter+=1
		END
	END


	--- Saving Store Visit Data
	DECLARE @StoreLatitude DECIMAL(27,24)
	DECLARE @StoreLongitude DECIMAL(27,24)
	DECLARE @ActualLatitude DECIMAL(27,24)
	DECLARE @ActualLongitude DECIMAL(27,24)
	DECLARE @VisitStartTS DATETIME
	DECLARE @VisitEndTS DATETIME
	DECLARE @VisitForDate  DATE
	--DECLARE @PDA_IMEI  VARCHAR(100)
	DECLARE @LocationProvider VARCHAR(100)
	DECLARE @BatteryLeftStatus INT
	DECLARE @OutletNextDay TINYINT
	DECLARE @OutletClose TINYINT
	DECLARE @flgNewStore TINYINT
	DECLARE @RouteID INT
	DECLARE @RouteNodeType SMALLINT
	DECLARE @flgCollectionStatus TINYINT
	DECLARE @flgSubmitSalesQuoteOnly TINYINT --0=No Sales Quote,1=Sales Quote Only
	DECLARE @flgVisitSubmitType TINYINT --0Submit from Order Screen , 1=Submit from external of Order Screen.
	DECLARE @flgInternetOnOff TINYINT
	DECLARE @flgRestart TINYINT
	DECLARE @StoreVisitCode VARCHAR(100)
	DECLARE @tblStoreMultipleVisit udt_StoreVisits
	DECLARE @OrderPDAID VARCHAR(100)
	DECLARE @OrderReturnDetail [dbo].[OrderReturnDetail]
	DECLARE @OrderReturnPhotoDetail OrderReturnPhotoDetail
	DECLARE @flgOrderCancel TINYINT
	DECLARE @VisitComments VARCHAR(500)
	DECLARE @flgIsPicAllowed TINYINT
	DECLARE @NOPIcReason VARCHAR(500)
	DECLARE @IsGeoValidated TINYINT
	DECLARE @NoOrderReasonID INT
	DECLARE @NoOrderReasonDescr VARCHAR(200)
	DECLARE @flgVisitType TINYINT =0
	DECLARE @TeleCallingID BIGINT =0

	DECLARE @ReasonId INT,@ReasonDescr VARCHAR(500),@ClosedStoreActualLatitude decimal(30, 27),@ClosedStoreActualLongitude decimal(30, 27),@LocProvider varchar(20),@ClosedStoreAccuracy varchar (100),@ClosedStoreCity VARCHAR(200),@ClosedStorePincode VARCHAR(20),@ClosedStoreState VARCHAR(200)


	DECLARE @RcptID INT=0,@RcvdAmount Amount=0,@BalanceAmt Amount=0,@LoginID INT=0
		DECLARE @PaymentDetails PaymentDetails 

	DECLARE @tblImages udt_ClosedStoreImages
	
	SELECT 'Store Visit Called'
	SELECT * FROM @tblRawDataCustomerVisit_N

	CREATE TABLE #StoreList(ID INT IDENTITY(1,1), StoreId INT)
	DECLARE @tblGPSInfo udt_GPSInfo

	INSERT INTO #StoreList(StoreId)
	SELECT DISTINCT StoreId
	FROM @tblRawDataCustomerVisit_N WHERE ISNULL(flgJointVisit,0)=0 --AND ISNULL(flgOnBehalfOf,0)=0

	SET @Counter=1
	SELECT @MaxCount=MAX(Id) FROM #StoreList

	WHILE @Counter<=@MaxCount
	BEGIN
		SELECT @flgLocationServicesOnOff=0,@flgGPSOnOff=0,@flgNetworkOnOff=0,@flgFusedOnOff=0,@flgInternetOnOffWhileLocationTracking=0
		SELECT @StoreId=0 ,@ActualLatitude=NULL,@ActualLongitude=NULL,@VisitStartTS=NULL,@VisitEndTS=NULL,@VisitForDate=NULL,@LocationProvider=NULL,@Accuracy=NULL,@BatteryLeftStatus=NULL,@OutletNextDay=0,@OutletClose=NULL,@flgNewStore=0,@flgLocationServicesOnOff=NULL,@flgGPSOnOff=NULL,@flgNetworkOnOff=NULL,@flgFusedOnOff=NULL,@flgInternetOnOff=NULL,@StoreVisitCode=NULL,@flgCollectionStatus=NULL,@flgOrderCancel=NULL,@VisitComments=NULL,@flgIsPicAllowed=NULL,@NOPIcReason=NULL,@IsGeoValidated=NULL,@NoOrderReasonID=NULL,@NoOrderReasonDescr=NULL,@flgVisitType=NULL,@TeleCallingID=0

		SELECT @StoreId=StoreId FROM #StoreList WHERE Id=@Counter
		PRINT '@StoreId=' + CAST(@StoreId AS VARCHAR)

		--- Code commented as data is not coming correct from PDA .
		DELETE FROM @tblGPSInfo
		INSERT INTO @tblGPSInfo([StoreID],[Address],[AllProviderData],[GPSLatitude],[GPSLongitude],[GPSAccuracy],[GPSAddress],[NetworkLatitude],[NetworkLongitude],
	[NetworkAccuracy],[NetworkAddress],[FusedLatitude],[FusedLongitude],[FusedAccuracy],[FusedAddress]) 
		SELECT [StoreID],[fnAddress],[AllProvidersLocation],[GpsLat],[GpsLong],[GpsAccuracy],[GpsAddress],[NetwLat],[NetwLong],[NetwAccuracy],[NetwAddress],[FusedLat],
	[FusedLong],[FusedAccuracy],[FusedAddress]
		FROM @tblRawDataStoreLocationDetails_N WHERE StoreId=@StoreId

		SELECT 'VisitData'
		SELECT * FROM @tblRawDataCustomerVisit_N

		SELECT @StoreLatitude=0,@StoreLongitude=0,@ActualLatitude=[VisitLatitude],@ActualLongitude=[VisitLongitude], @VisitStartTS=CONVERT(DATETIME,[VisitTimeInSideStore],105), @VisitEndTS=CONVERT(DATETIME,[VisitEndTS],105),@VisitForDate=CONVERT(DATE,[VisitDate],105),@LocationProvider=LocProvider, @Accuracy=Accuracy, @BatteryLeftStatus=BateryLeftStatus, @OutletNextDay=0,@OutletClose=StoreClose,@flgNewStore=0,@RouteID=0,@RouteNodeType=0, @flgSubmitSalesQuoteOnly=0,@flgVisitSubmitType=0,@flgLocationServicesOnOff=flgLocationServicesOnOff,@flgGPSOnOff=flgGPSOnOff,@flgNetworkOnOff=flgNetworkOnOff,@flgFusedOnOff=flgFusedOnOff,@flgInternetOnOff=flgInternetOnOffWhileLocationTracking,@flgRestart=0,@StoreVisitCode=StoreVisitCode,@flgCollectionStatus=flgVisitCollectionMarkedStatus,@flgOrderCancel=flgOrderCancel,@VisitComments=VisitComments,@flgIsPicAllowed=flgIsPicsAllowed,@NOPIcReason=NoPicsReason,@IsGeoValidated=IsGeoValidated,@NoOrderReasonID=NoOrderReasonID,@NoOrderReasonDescr=NoOrderReasonDescr,@flgVisitType=flgVisitType,@TeleCallingID=TeleCallingID

	FROM @tblRawDataCustomerVisit_N WHERE StoreID=@StoreId

	DELETE FROM @tblStoreMultipleVisit
		INSERT INTO @tblStoreMultipleVisit
		SELECT [StoreVisitCode],[TempStoreVisitCode],[VisitTimeStartAtStore],[VisitTimeEndStore],[VisitLatCode],[VisitLongCode],[flgTelephonic] FROM @tblRawDataStoreMultipleVisitDetail_N WHERE [StoreVisitCode]=@StoreVisitCode

		SELECT @VisitId=NULL
		PRINT 'Calling of Visit Saving'
		PRINT '@StoreID' + CAST(@StoreID AS VARCHAR)
		EXEC [spForPDA_Save_StoreVisit] @StoreID,@ActualLatitude,@ActualLongitude,@VisitStartTS,@VisitEndTS,@VisitForDate,@IMEINo,@LocationProvider, @Accuracy,@BatteryLeftStatus,@OutletNextDay,@OutletClose,@flgSubmitSalesQuoteOnly,@flgVisitSubmitType,@flgCollectionStatus,@StoreVisitCode,@tblStoreMultipleVisit,@tblGPSInfo,@flgLocationServicesOnOff,@flgGPSOnOff,@flgNetworkOnOff,@flgFusedOnOff,@flgInternetOnOffWhileLocationTracking,0,@VisitId OUTPUT,@VisitComments,@flgIsPicAllowed,@NOPIcReason,@FileSetId,@IsGeoValidated,@flgVisitType,@NoOrderReasonID,@NoOrderReasonDescr,@TeleCallingID

		SELECT @RcptID=0,@RcvdAmount=0,@BalanceAmt=0,@LoginID=0
		DELETE FROM @PaymentDetails
		IF ISNULL(@VisitId,0)>0
		BEGIN
			SELECT 'StoreVisitCode'
			SELECT @StoreVisitCode
			UPDATE @tblRawDataCustomerVisit_N SET VisitID=@VisitId WHERE StoreVisitCode=@StoreVisitCode 
			UPDATE @tblRawStoreCheckData_N SET VisitID=@VisitId WHERE StoreVisitCode=@StoreVisitCode 
			UPDATE @tblRawDataStoreCheckImage_N SET VisitID=@VisitID WHERE StoreVisitCode=@StoreVisitCode 
			IF EXISTS(SELECT 1 FROM @tblRawStoreCheckData_N WHERE StoreVisitCode IS NULL)
			BEGIN
				UPDATE @tblRawStoreCheckData_N SET VisitID=@VisitId,StoreVisitCode=@StoreVisitCode WHERE StoreVisitCode IS NULL
				UPDATE @tblRawDataStoreCheckImage_N SET VisitID=@VisitID,StoreVisitCode=@StoreVisitCode WHERE StoreVisitCode IS NULL
			END

			--- Saving Store Check Data ################################################################################################################################
			IF EXISTS (SELECT 1 FROM @tblRawStoreCheckData_N WHERE StoreVisitCode=@StoreVisitCode)
			BEGIN
				SELECT 'Called Store Check'
				DELETE FROM @tblRawStoreCheckData_Working
				INSERT INTO @tblRawStoreCheckData_Working
				SELECT * FROM @tblRawStoreCheckData_N WHERE StoreVisitCode=@StoreVisitCode

				SELECT * FROM @tblRawStoreCheckData_Working
				EXEC [SpSaveStoreCheckData] @ImeiNo,@tblRawStoreCheckData_Working
			END
			IF EXISTS (SELECT 1 FROM @tblRawDataStoreCheckImage_N WHERE StoreVisitCode=@StoreVisitCode)
			BEGIN
				DELETE A FROM tblVisitStockImage A INNER JOIN @tblRawDataStoreCheckImage_N S ON S.VisitID=A.VisitID
				--SELECT VisitID,[ProductID],[StockQty] FROM @tblStoreCheckData
				INSERT INTO tblVisitStockImage(VisitID,StoreID,IMagename,ImageClickTime,ImageType,StoreVisitCode)
				SELECT @VisitId,StoreID,Photoname,ImageClickTime,ImageType,StoreVisitCode FROM @tblRawDataStoreCheckImage_N WHERE StoreVisitCode=@StoreVisitCode
			END
			 
			--###########################################################################################################################################################

			--- Store Close Details Saving
			SELECT @ReasonId=NULL,@ReasonDescr=NULL,@ClosedStoreActualLatitude=NULL,@ClosedStoreActualLongitude=NULL,@LocProvider=NULL,@ClosedStoreAccuracy=NULL,@ClosedStoreCity=NULL,@ClosedStorePincode=NULL,@ClosedStoreState=NULL
			DELETE FROM @tblImages
			DELETE FROM @tblGPSInfo
					
			
			IF EXISTS (SELECT 1 FROM @tblRawDataStoreReasonSaving)
			BEGIN
				SELECT @ReasonId=ReasonID,@ReasonDescr=ReasonDescr,@ClosedStoreActualLatitude=[Lattitude],@ClosedStoreActualLongitude=[Longitude],@LocProvider=[fnAccurateProvider],@ClosedStoreAccuracy=[Accuracy],@ClosedStoreCity=[City],@ClosedStorePincode=[Pincode],@State=[State] FROM @tblRawDataStoreReasonSaving R INNER JOIN @tblRawDataStoreCloseLocationDetail L ON L.[StoreVisitCode]=R.[StoreVisitCode] WHERE R.StoreVisitCode=@StoreVisitCode

				INSERT INTO @tblImages([ImageName],[ClickedDateTime])
				SELECT DISTINCT P.Photoname,P.[ClickedDateTime] FROM @tblRawDataStoreClosePhotoDetail P WHERE P.[StoreVisitCode]=@StoreVisitCode

				INSERT INTO @tblGPSInfo([StoreID],[Address],[Distance],[AllProviderData],[GPSLatitude],[GPSLongitude],[GPSAccuracy],[GPSAddress],[NetworkLatitude],[NetworkLongitude],[NetworkAccuracy],[NetworkAddress],[FusedLatitude],[FusedLongitude],[FusedAccuracy],[FusedAddress])
				SELECT @StoreId,[Address],[Accuracy],[fnAccurateProvider],[GpsLat],[GpsLong],[GpsAccuracy],[GpsAddress],[NetwLat],[NetwLong],[NetwAccuracy],[NetwAddress],[FusedLat],[FusedLong],[FusedAccuracy],[FusedAddress] FROM @tblRawDataStoreCloseLocationDetail WHERE StoreID=@StoreId

				
				EXEC spPDA_Save_StoreClosedDetails  @StoreID,@StoreVisitCode,@VisitId,@ReasonId,@ReasonDescr,@ActualLatitude,@ActualLongitude,@LocProvider,@Accuracy,@City,@Pincode,@State,@ImeiNo,@tblImages,@tblGPSInfo
			END
			
			IF EXISTS (SELECT 1 FROM @tblRawDataStoreReturnDetail WHERE [StoreVisitCode]=@StoreVisitCode)
			BEGIN
				SELECT @RouteID=[RouteID],@RouteNodeType=[RouteNodeType],@OrderPDAID=[OrderIDPDA] FROM @tblRawDataStoreReturnDetail

				INSERT INTO @OrderReturnDetail([PrdID],[Qty],[Reason],[StockStatusId])
				SELECT DISTINCT [ReturnProductID],[ProdReturnQty],[ProdReturnReason],[ProdReturnReasonIndex] FROM @tblRawDataStoreReturnDetail WHERE [StoreVisitCode]=@StoreVisitCode

				INSERT INTO @OrderReturnPhotoDetail([PrdID],[PhotoName],[flgDelete],[PhotoClickedOn])
				SELECT DISTINCT [ProductID],[PhotoName],[PhotoValidation],[ImageClicktime] FROM @tblRawDataProductReturnImage_N P INNER JOIN @tblRawDataStoreReturnDetail R ON R.OrderIDPDA=P.OrderIDPDA WHERE R.[StoreVisitCode]=@StoreVisitCode

				EXEC [spPopulateOrderReturn] @IMEiNo,@StoreID,@StoreVisitCode,@VisitID,@RouteID,@RouteNodeType,@OrderReturnDetail,@OrderReturnPhotoDetail,@OrderPDAID
			END
			-- Saving Order Details
			DECLARE @ExistingVisitID INT
			IF EXISTS (SELECT 1 FROM @tblRawDataInvoiceHeader_N)
			BEGIN
				EXEC SpPrepareandSavePurchaseDetails @FileSetId,@StoreId,@VisitId,@VisitForDate,@StoreVisitCode,@tblRawDataInvoiceHeader_N,@tblRawDataInvoiceDetail_N,@tblRawDataDeliveryDetails_N,@ImeiNo
			END
			ELSE
			BEGIN
				 SELECT @ExistingVisitID =V.VisitID FROM tblVisitMaster(nolock) VM INNER JOIN @tblRawDataCustomerVisit_N V ON V.StoreID=VM.StoreID AND V.VisitDate=VM.VisitDate WHERE EntryPersonNodeID=@PersonNodeID AND EntryPersonNodeType=@PersonNodeType

				IF ISNULL(@ExistingVisitID,0)>0 
					UPDATE O SET OrderStatusID=3 FROM tblOrderMaster O WHERE VisitID=@ExistingVisitID
			END

			

			IF EXISTS(SELECT TOP 1 * FROM @tblRawDataCartonMaster_N)
			BEGIN
				DELETE C FROM tblCartonMaster C INNER JOIN tblCartonDetail CD ON CD.CartonID=C.CartonID
				INSERT INTO tblCartonMaster(StoreID,OrderID,CartonCode,CategoryID,UOMType,NoOfCarton,TotalExpectedQty,TotalActualQty,CartonDiscount,filesetID)
				SELECT DISTINCT C.StoreID,OM.OrderID,C.CartonID,C.CategoryID,C.UOMType,C.NoOfCarton,C.TotalExpectedQty,C.TotalActualQty,C.CartonDiscount,@FileSetId FROM @tblRawDataCartonMaster_N C LEFT OUTER JOIN tblOrderMaster(nolock) OM ON OM.OrderPDAID=C.Invoicenumber

				INSERT INTO tblCartonDetail(CartonID,ProductID,OrderQty,CartonProductDiscount)
				SELECT DISTINCT CM.CartonID,CD.ProductID,CD.OrderQty,CD.CartonProductDiscount FROM tblCartonMaster(nolock) CM INNER JOIN @tblRawDataCartonDetail_N CD ON CD.CartonID=CM.CartonCode
								
			END
		

			--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

			--- Saving Payment Details
			INSERT INTO @PaymentDetails([AdvChqId],[InstrumentMode],[TrnRefNo],[TrnDate],[RcptAmt],[BankId],[BankAdd],[Remarks],[AttachFilePath])
			SELECT DISTINCT 0,[PaymentModeID],[RefNoChequeNoTrnNo],CASE [PaymentModeID] WHEN 1 THEN @VisitForDate WHEN 2 THEN [Date] WHEN 3 THEN GETDATE() END,[Amount],[Bank],'','','' FROM @tblRawDataCollectionData_N WHERE StoreVisitCode=@StoreVisitCode

			SELECT * FROM @PaymentDetails
			IF EXISTS (SELECT 1 FROM @PaymentDetails)
				EXEC [dbo].[spPopulateReceiptMasterForPDA] @RcptID,@StoreVisitCode,@VisitID,@RcvdAmount,@BalanceAmt,@StoreId,@LoginID,@PaymentDetails

			--- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
		END

		SET @Counter+=1
	END

	--- Loop for Telephonic Order
	CREATE TABLE #TelePhonicStoreList(ID INT IDENTITY(1,1),StoreID INT)
	
	INSERT INTO #TelePhonicStoreList
	SELECT DISTINCT StoreId FROM @tblRawDataInvoiceHeader_N WHERE ISNULL(StoreVisitCode,'')=''
	SET @Counter=1
	SELECT @MaxCount=0
	SELECT @StoreVisitCode=''
	SELECT @MaxCount=MAX(ID) FROM #TelePhonicStoreList

	WHILE @Counter<=@MaxCount
	BEGIN
		SELECT @StoreID=StoreID FROM #TelePhonicStoreList WHERE ID=@Counter
		SELECT @VisitForDate=InvoiceDate FROM @tblRawDataInvoiceHeader_N WHERE StoreID=@StoreID
		SELECT @StoreVisitCode=StoreVisitCode FROM @tblRawDataInvoiceHeader_N WHERE StoreID=@StoreID
		

		IF ISNULL(@StoreVisitCode,'')=''
		BEGIN
			--- making an Entry in Visit Table 
			SELECT @flgLocationServicesOnOff=0,@flgGPSOnOff=0,@flgNetworkOnOff=0,@flgFusedOnOff=0,@flgInternetOnOffWhileLocationTracking=0
		SELECT @StoreId=0 ,@ActualLatitude=NULL,@ActualLongitude=NULL,@VisitStartTS=NULL,@VisitEndTS=NULL,@VisitForDate=NULL,@LocationProvider=NULL,@Accuracy=NULL,@BatteryLeftStatus=NULL,@OutletNextDay=0,@OutletClose=NULL,@flgNewStore=0,@flgLocationServicesOnOff=NULL,@flgGPSOnOff=NULL,@flgNetworkOnOff=NULL,@flgFusedOnOff=NULL,@flgInternetOnOff=NULL,@StoreVisitCode=NULL,@flgCollectionStatus=NULL,@flgOrderCancel=NULL,@VisitComments=NULL,@flgIsPicAllowed=NULL,@NOPIcReason=NULL,@IsGeoValidated=NULL,@NoOrderReasonID=NULL,@NoOrderReasonDescr=NULL,@flgVisitType=NULL,@TeleCallingID=0

		SELECT @StoreId=StoreId FROM #StoreList WHERE Id=@Counter
		PRINT '@StoreId=' + CAST(@StoreId AS VARCHAR)

		DELETE FROM @tblGPSInfo
		INSERT INTO @tblGPSInfo([StoreID],[Address],[AllProviderData],[GPSLatitude],[GPSLongitude],[GPSAccuracy],[GPSAddress],[NetworkLatitude],[NetworkLongitude],
	[NetworkAccuracy],[NetworkAddress],[FusedLatitude],[FusedLongitude],[FusedAccuracy],[FusedAddress]) 
		SELECT [StoreID],[fnAddress],[AllProvidersLocation],[GpsLat],[GpsLong],[GpsAccuracy],[GpsAddress],[NetwLat],[NetwLong],[NetwAccuracy],[NetwAddress],[FusedLat],
	[FusedLong],[FusedAccuracy],[FusedAddress]
		FROM @tblRawDataStoreLocationDetails_N WHERE StoreId=@StoreId

		SELECT * FROM @tblRawDataCustomerVisit_N

		SELECT @StoreLatitude=0,@StoreLongitude=0,@ActualLatitude=[VisitLatitude],@ActualLongitude=[VisitLongitude], @VisitStartTS=CONVERT(DATETIME,[VisitTimeInSideStore],105), @VisitEndTS=CONVERT(DATETIME,[VisitEndTS],105),@VisitForDate=CONVERT(DATE,[VisitDate],105),@LocationProvider=LocProvider, @Accuracy=Accuracy, @BatteryLeftStatus=BateryLeftStatus, @OutletNextDay=0,@OutletClose=StoreClose,@flgNewStore=0,@RouteID=0,@RouteNodeType=0, @flgSubmitSalesQuoteOnly=0,@flgVisitSubmitType=0,@flgLocationServicesOnOff=flgLocationServicesOnOff,@flgGPSOnOff=flgGPSOnOff,@flgNetworkOnOff=flgNetworkOnOff,@flgFusedOnOff=flgFusedOnOff,@flgInternetOnOff=flgInternetOnOffWhileLocationTracking,@flgRestart=0,@StoreVisitCode=StoreVisitCode,@flgCollectionStatus=flgVisitCollectionMarkedStatus,@flgOrderCancel=flgOrderCancel,@VisitComments=VisitComments,@flgIsPicAllowed=flgIsPicsAllowed,@NOPIcReason=NoPicsReason,@IsGeoValidated=IsGeoValidated,@NoOrderReasonID=NoOrderReasonID,@NoOrderReasonDescr=NoOrderReasonDescr,@flgVisitType=flgVisitType,@TeleCallingID=TeleCallingID

	FROM @tblRawDataCustomerVisit_N WHERE StoreID=@StoreId

	DELETE FROM @tblStoreMultipleVisit
		INSERT INTO @tblStoreMultipleVisit
		SELECT [StoreVisitCode],[TempStoreVisitCode],[VisitTimeStartAtStore],[VisitTimeEndStore],[VisitLatCode],[VisitLongCode],[flgTelephonic] FROM @tblRawDataStoreMultipleVisitDetail_N WHERE [StoreVisitCode]=@StoreVisitCode

		SELECT @VisitId=NULL
		PRINT 'Calling of Visit Saving'
		PRINT '@StoreID' + CAST(@StoreID AS VARCHAR)
		EXEC [spForPDA_Save_StoreVisit] @StoreID,@ActualLatitude,@ActualLongitude,@VisitStartTS,@VisitEndTS,@VisitForDate,@IMEINo,@LocationProvider, @Accuracy,@BatteryLeftStatus,@OutletNextDay,@OutletClose,@flgSubmitSalesQuoteOnly,@flgVisitSubmitType,@flgCollectionStatus,@StoreVisitCode,@tblStoreMultipleVisit,@tblGPSInfo,@flgLocationServicesOnOff,@flgGPSOnOff,@flgNetworkOnOff,@flgFusedOnOff,@flgInternetOnOffWhileLocationTracking,0,@VisitId OUTPUT,@VisitComments,@flgIsPicAllowed,@NOPIcReason,@FileSetId,@IsGeoValidated,1,@NoOrderReasonID,@NoOrderReasonDescr,@TeleCallingID

			PRINT 'Store Telephonic Order Saving Called'
				EXEC SpPrepareandSavePurchaseDetails @FileSetId,@StoreID,0,@VisitForDate,'',@tblRawDataInvoiceHeader_N,@tblRawDataInvoiceDetail_N,@tblRawDataDeliveryDetails_N,@ImeiNo
			PRINT 'Store Telephonic Order Saving Finished'
		END
		SELECT @Counter=@Counter + 1
	END

	

	--- Invoice execution 
	IF EXISTS (SELECT 1 FROM @tblRawDataInvoiceExecution)
	BEGIN
		DECLARE @TransDate Date,@OrderID INT,@strData VARCHAR(500),@AdditionalDiscount FLOAT,@flgCancel TINYINT,@CancelRemark VARCHAR(200),@CancelReasonId INT,@InvNumber VARCHAR(200),@InvDate DATE
		DECLARE Cur_OrderExecute CURSOR FOR
		SELECT DISTINCT TransDate,OrderID,strData,REPLACE(AdditionalDiscount,'NULL',0),REPLACE(flgCancel,'NULL',0),CancelRemark,CancelReasonId,[InvNumber],REPLACE([InvDate],'NA','01-Jan-1900') FROM @tblRawDataInvoiceExecution
		OPEN Cur_OrderExecute
		FETCH NEXT FROM Cur_OrderExecute INTO @TransDate,@OrderID,@strData,@AdditionalDiscount,@flgCancel,@CancelRemark,@CancelReasonId,@InvNumber,@InvDate
		WHILE @@FETCH_STATUS = 0  
		BEGIN 
			EXEC spInvoiceSaveInvoice @ImeiNo,@strData,@OrderID,@TransDate,@AdditionalDiscount,@flgCancel,@CancelRemark,@CancelReasonId,@InvNumber,@InvDate
			FETCH NEXT FROM Cur_OrderExecute INTO @TransDate,@OrderID,@strData,@AdditionalDiscount,@flgCancel,@CancelRemark,@CancelReasonId,@InvNumber,@InvDate
		END
		CLOSE Cur_OrderExecute
		DEALLOCATE Cur_OrderExecute

	END

	DECLARE @tblInvImages udt_image
	--Saving Invoice Images
	IF EXISTS (SELECT 1 FROM @tblRawDataInvoiceImages)
	BEGIN
		--DECLARE @InvNumber VARCHAR(50),@InvDate DATE
		DECLARE Cur_InvImages CURSOR FOR
		SELECT DISTINCT OrderID,StoreID,InvNumber,InvDate FROM @tblRawDataInvoiceImages
		OPEN Cur_InvImages
		FETCH NEXT FROM Cur_InvImages INTO @OrderID,@StoreID,@InvNumber,@InvDate
		WHILE @@FETCH_STATUS = 0  
		BEGIN 
			DELETE FROM @tblInvImages
			INSERT INTO @tblInvImages([ImageName])
			SELECT DISTINCT [ImageName] FROM @tblRawDataInvoiceImages WHERE OrderID=@OrderID AND InvNumber=@InvNumber

			EXEC SpPDASaveInvoiceImages @ImeiNo,@OrderID,@StoreID,@InvNumber,@InvDate,@tblInvImages

			FETCH NEXT FROM Cur_InvImages INTO @OrderID,@StoreID,@InvNumber,@InvDate
		END
		CLOSE Cur_InvImages
		DEALLOCATE Cur_InvImages
	END

	--- Saving of Day End Details
	IF EXISTS(SELECT 1 FROM @tblRawDataDayEndDet_N)
	BEGIN
		SELECT 'Day End Called'
		SELECT * FROM @tblRawDataDayEndDet_N
		SELECT @PersonNodeID=NodeID,@PersonNodeType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@ImeiNo) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

		IF EXISTS (SELECT 1 FROM @tblRawDataDayEndDet_N WHERE ForDate IS NULL) 
		BEGIN
			UPDATE A SET A.ForDate=CAST(AA.StartTime AS DATE) FROM @tblRawDataDayEndDet_N A INNER JOIN (SELECT A.PersonID,A.Endtime,MAX(B.Datetime) StartTime FROM tblDayEndDetails A INNER JOIN tblPersonAttendance B ON A.PersonId=B.PersonNodeID AND B.[Datetime]<=A.Endtime WHERE A.PersonId=@PersonNodeID GROUP BY A.PersonID,A.Endtime) AA ON @PersonNodeID=AA.PersonID AND A.Endtime=AA.Endtime
		END
		
		INSERT INTO tblDayEndDetails(IMEINo,StartTime,Endtime,DayEndFlag,ForDate,AppVersionID,[BatteryStatus],PersonId,LatCode,LongCode,Address,City,State,PinCode)
		SELECT [IMEINo],[StartTime],[EndTime],[DayEndFlag],[ForDate],[AppVersionID],[BatteryStatus],@PersonNodeID,LatCode,LongCode,Address,City,State,PinCode FROM @tblRawDataDayEndDet_N WHERE IMEINo=@ImeiNo
	END
	
	--########################################################################################################################################################################
	-- Saving of Distributor Stock
	IF EXISTS (SELECT 1 FROM @tblRawDistProductStock_N)
	BEGIN
		DECLARE @CustomerNodeID INT,@CustomerNodeTYpe SMALLINT,@StockDate DAte,@flgPackType TINYINT,@udt_DistProductStock udt_DistProductStock
		SELECT @CustomerNodeID=CustomerNodeID,@CustomerNodeTYpe=CustomerNodeType,@StockDate=StockDate,@flgPackType=1 FROM @tblRawDistProductStock_N
		INSERT INTO @udt_DistProductStock
		SELECT DISTINCT ProductNodeID,ProductNodeType,MONTH(StockDate),YEAR(StockDate),'',StockQty,1 FROM @tblRawDistProductStock_N

		EXEC SpPDAManageDistributorTodaysStock @CustomerNodeID,@CustomerNodeTYpe,@StockDate,@ImeiNo,@flgPackType,@udt_DistProductStock
	END

	--########################################################################################################################################################################

	--- Joint Working for ASM
	--- Saving Of Joint Visit
	
	IF EXISTS(SELECT 1 FROM @tblRawDataJointVisitMaster_N)
	BEGIN
		PRINT 'Joint Visit Data Called'
		EXEC SpSaveJointVisit_ASM @ImeiNo,@tblRawDataJointVisitMaster_N,@tblRawDataJointVisitDetail_N
		UPDATE N SET JointVisitID=A.JointVisitID FROM @tblRawDataCustomerVisit_N N INNER JOIN tblJointVisitDetails_ASM A ON A.JointVisitCode=N.JointVisitCode
		UPDATE N SET JointVisitID=A.JointVisitID FROM @tblRawDataQuestAnsMstr_N N INNER JOIN tblJointVisitDetails_ASM A ON A.JointVisitCode=N.JointVisitCode 
	END

	-- Saving of Store Visit 
	IF EXISTS (SELECT 1 FROM @tblRawDataCustomerVisit_N WHERE flgJointVisit=1)
	BEGIN 
		PRINT 'Store Visit Called'
		EXEC SpSaveStoreVisit_ASM @ImeiNo,@tblRawDataCustomerVisit_N
	
	END

	--- Saving of the Question Responses
	IF EXISTS (SELECT 1 FROM @tblRawDataQuestAnsMstr_N WHERE [flgApplicablemodule] IN (1,2,3))
	BEGIN 
		PRINT 'Feedback Data Called'
		UPDATE N SET StoreVisitCode=V.StoreVisitCode FROM @tblRawDataQuestAnsMstr_N N INNER JOIN @tblRawDataCustomerVisit_N V ON V.StoreID=N.OutletID AND V.jointVisitCode=N.JointVisitCode
		UPDATE N SET StoreCheckVisitID=S.StoreCheckVisitID FROM @tblRawDataQuestAnsMstr_N N INNER JOIN tblSFACustomerSupVisit S ON S.StoreVisitCode=N.StoreVisitCode

		EXEC SpSaveFeedbackDetails_ASM @ImeiNo,@tblRawDataQuestAnsMstr_N
	END


	--- Gate Meeting Target Saving
	IF EXISTS (SELECT 1 FROM @tblRawGateMeetingTarget)
	BEGIN 
		PRINT 'Gate Meeting Target Saving'

		--SELECT @FilePersonNodeID FilePersonNodeID
		--SELECT @FilePersonNodeType FilePersonNodeType
		--SELECT * FROM @tblRawGateMeetingTarget

		DELETE G FROM tblGateMeetingTarget G INNER JOIN @tblRawGateMeetingTarget T ON T.CovAreaNodeID=G.CovAreaNodeID AND T.CovAreaNodeType=G.CovAreaNodeType AND CAST(G.DataDate AS DATE)=CAST(T.EntryDate AS DATE)
		INSERT INTO tblGateMeetingTarget(CovAreaNodeID,CovAreaNodeType,PersonNodeID,PersonNodeType,EntryPersonNodeID,EntryPersonNodeType,DataDate,FileSetID,TimestampIns,Dstrbn_Tgt,Sales_Tgt)
		SELECT CovAreaNodeID,CovAreaNodeType,PersonNodeID,PersonNodeType,@FilePersonNodeID,@FilePersonNodeType,EntryDate,@FileSetId,GETDATE(),Dstrbn_Tgt,Sales_Tgt FROM @tblRawGateMeetingTarget

	END
	IF EXISTS (SELECT 1 FROM @tblRawGateMeetingTargetDet)
	BEGIN
		SELECT 'Coming in Focus Process'
		DELETE G FROM tblGateMeetingTargetDet G INNER JOIN tblGateMeetingTarget GM ON GM.PersonMeetingID=G.PersonMeetingID INNER JOIN
		@tblRawGateMeetingTargetDet T ON T.CovAreaNodeID=GM.CovAreaNodeID AND T.CovAreaNodeType=GM.CovAreaNodeType AND T.SKUNodeID=G.SKUNodeID AND T.SKUNodeType=G.SKUNodeType AND CAST(GM.DataDate AS DATE)=CAST(T.EntryDate AS DATE)

		--SELECT * FROM @tblRawGateMeetingTargetDet
		--SELECT * FROM tblGateMeetingTarget WHERE DataDate='05-Mar-2022'

		SELECT T.PersonMeetingID,D.SKUNodeID,D.SKUNodeType,D.Dstrbn_Tgt,D.Sales_Tgt FROM @tblRawGateMeetingTargetDet D INNER JOIN tblGateMeetingTarget T ON T.CovAreaNodeID=D.CovAreaNodeID AND T.CovAreaNodeType=D.CovAreaNodeType AND CAST(T.DataDate AS DATE)=CAST(D.EntryDate AS DATE) AND T.EntryPersonNodeID=@FilePersonNodeID AND T.EntryPersonNodeType=@FilePersonNodeType

		INSERT INTO tblGateMeetingTargetDet(PersonMeetingID,SKUNodeID,SKUNodeType,Dstrbn_Tgt,Sales_Tgt)
		SELECT T.PersonMeetingID,D.SKUNodeID,D.SKUNodeType,D.Dstrbn_Tgt,D.Sales_Tgt FROM @tblRawGateMeetingTargetDet D INNER JOIN tblGateMeetingTarget T ON T.CovAreaNodeID=D.CovAreaNodeID AND T.CovAreaNodeType=D.CovAreaNodeType AND CAST(T.DataDate AS DATE)=CAST(D.EntryDate AS DATE) AND T.EntryPersonNodeID=@FilePersonNodeID AND T.EntryPersonNodeType=@FilePersonNodeType
	END

	IF EXISTS (SELECT 1 FROM @tblPotentialDBRetailerData_XMLSaving_N)
	BEGIN
		UPDATE PR SET RetailerName=N.RetailerName,Address=N.Address,Comment=N.Comment,ContactNumber=N.ContactNumber,RetFeedback=N.RetFeedback,TimestampUpd=GETDATE(),flgFinalSubmit=1 FROM tblPotentialDistributorRetailerDet PR INNER JOIN @tblPotentialDBRetailerData_XMLSaving_N N ON N.DBNodeID=PR.DBNodeID AND N.DBNodeType=PR.DBNodeType AND N.RetailerCode=PR.RetailerCode
	END

END
