-- =============================================
-- Author:		Avinash Gupta
-- Create date: 13-Apr-2021
-- Description:	
-- =============================================
--DROP PROC [SpSavePersonAttendance_Direct]
--GO
CREATE PROCEDURE [dbo].[SpSavePersonAttendance_Direct] 
	@ImeiNo VARCHAR(50),
	@tblRawDataAttandanceDetails udt_RawDataAttandanceDetails READONLY,
	@tblRawDataStoreLocationDetails udt_RawDataLatLongDetails READONLY
AS
BEGIN
	DECLARE @tblRawDataAttandanceDetails_N udt_RawDataAttandanceDetails
	INSERT INTO @tblRawDataAttandanceDetails_N SELECT * FROM @tblRawDataAttandanceDetails

	DECLARE @tblRawDataStoreLocationDetails_N udt_RawDataLatLongDetails
	INSERT INTO @tblRawDataStoreLocationDetails_N SELECT * FROM @tblRawDataStoreLocationDetails

	UPDATE N SET Pincode=NULL FROM @tblRawDataAttandanceDetails_N N WHERE Pincode='null'
	UPDATE N SET MapPinCode=NULL FROM @tblRawDataAttandanceDetails_N N WHERE MapPinCode='null'
	UPDATE N SET Pincode=NULL FROM @tblRawDataAttandanceDetails_N N WHERE Pincode='NA'
	UPDATE N SET MapPinCode=NULL FROM @tblRawDataAttandanceDetails_N N WHERE MapPinCode='NA'

	UPDATE N SET LeaveStartDate=NULL FROM @tblRawDataAttandanceDetails_N N WHERE LeaveStartDate='NA'
	UPDATE N SET LeaveEndDate=NULL FROM @tblRawDataAttandanceDetails_N N WHERE LeaveEndDate='NA'

	UPDATE N SET [fnAccuracy]=CAST(ROUND([fnAccuracy],0) AS INT),[GpsAccuracy]=CAST(ROUND([GpsAccuracy],0) AS INT),[NetwAccuracy]=CAST(ROUND([NetwAccuracy],0) AS INT),[FusedAccuracy]=CAST(ROUND([FusedAccuracy],0) AS INT) FROM @tblRawDataStoreLocationDetails_N N


	--- Person Attendance
	DECLARE @PersonNodeID INT,@tblAttReason udt_AttReason,@Address VARCHAR(500),@LatCode DECIMAL(18,6),@LongCode DECIMAL(18,6),@AllProvidersLocation VARCHAR(MAX),@Datetime Datetime,@Comments VARCHAR(200),@DBNodeID INT,@DBNodetype TINYINT,@strReasonId VARCHAR(200),@strReason VARCHAR(500),@Accuracy NUMERIC(10,2),@VisitID INT,@flgLocationServicesOnOff TINYINT,@flgGPSOnOff TINYINT,@flgNetworkOnOff TINYINT,@flgFusedOnOff TINYINT,@flgInternetOnOffWhileLocationTracking TINYINT,@BatteryStatus INT,
	@PinCode VARCHAR(20),@City VARCHAR(100),@State VARCHAR(200),@MapAddress VARCHAR(500),@MapCity VARCHAR(200),@MapPinCode VARCHAR(50),@MapState VARCHAR(200),@IsNetworkTimeRecorded TINYINT,@OSVersion VARCHAR(100),@DeviceID VARCHAR(100),@BrandName VARCHAR(100),@Model VARCHAR(100),@DeviceDatetime Datetime,@LeaveStartDate Date,@LeaveEndDate Date,@SelfieName VARCHAR(200)
	
	IF EXISTS(SELECT 1 FROM @tblRawDataAttandanceDetails_N WHERE isnull(PersonNodeID,0)<>0)
	BEGIN
		CREATE TABLE #ReasonId(ID INT IDENTITY(1,1),ReasonId INT)
		CREATE TABLE #Reason(ID INT IDENTITY(1,1),ReasonDescr VARCHAR(200))


		SELECT @Datetime=AttandanceTime,@PersonNodeID=PersonNodeID,@Address=fnAddress,@PinCode=PinCode,@City=City,@State=State,@MapAddress=MapAddress,@MapCity=MapCity,@MapPinCode=MapPinCode,@MapState=MapState,@LatCode=REPLACE(fnLati,'NA',0),@LongCode=REPLACE(fnLongi,'NA',0),@Accuracy=REPLACE(fnAccuracy,'NA',0), @AllProvidersLocation=AllProvidersLocation,@Comments=Comment,@strReasonId=ReasonID,@strReason=ReasonDesc,@VisitID=0,@DBNodeID=0,@DBNodetype=0,@flgLocationServicesOnOff=flgLocationServicesOnOff,@flgGPSOnOff=flgGPSOnOff,@flgNetworkOnOff=flgNetworkOnOff,@flgFusedOnOff=flgFusedOnOff,@flgInternetOnOffWhileLocationTracking=flgInternetOnOffWhileLocationTracking,@BatteryStatus=[BatteryStatus],@IsNetworkTimeRecorded=[IsNetworkTimeRecorded],@OSVersion=[OSVersion],@DeviceID=[device],@BrandName=[BrandName],@Model=[Model],@DeviceDatetime=DeviceDatetime,@LeaveStartDate=LeaveStartDate,@LeaveEndDate=LeaveEndDate,@SelfieName=[SelfieName]
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
		
		--SELECT * FROM @tblRawDataAttandanceDetails_N
		--SELECT 1
		EXEC [SpSavePersonAttendance] 0,@PersonNodeID,@tblAttReason,@Address,@LatCode,@LongCode,@Accuracy,@AllProvidersLocation,@Datetime,@VisitID,@ImeiNo,@Comments,@DBNodeID,@DBNodetype,@flgLocationServicesOnOff,	@flgGPSOnOff,@flgNetworkOnOff,@flgFusedOnOff,@flgInternetOnOffWhileLocationTracking,@tblRawDataStoreLocationDetails_N,@BatteryStatus,@PinCode,@City,@State,@MapAddress,@MapCity,@MapPinCode,@MapState,@IsNetworkTimeRecorded,@OSVersion,@DeviceID,@BrandName,@Model,@DeviceDatetime,@LeaveStartDate,@LeaveEndDate,@SelfieName
		PRINT 'Attendance Saved'

		DECLARE @flgTodaysAttendance INT
		SET @flgTodaysAttendance=0
		SELECT @flgTodaysAttendance=1 FROM tblPersonAttendance(nolock) WHERE CAST(Datetime AS DATE)=CAST(GETDATE() AS DATE) AND PersonNodeID=@PersonNodeID

		SELECT @flgTodaysAttendance flgTodaysAttendance
	
	END
END
