-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--DROP PROC SpSavePersonAttendance
CREATE PROCEDURE [dbo].[SpSavePersonAttendance]	
	@FileSetID INT,
	@PersonNodeID INT,
	@tblAttReason udt_AttReason ReadOnly,
	@Address VARCHAR(500),
	@LatCode DECIMAL(18,6),
	@LongCode DECIMAL(18,6),
	@Accuracy FLOAT,
	@AllProvidersLocation VARCHAR(MAX),
	@Datetime Datetime,
	@VisitID INT,
	@IMEINo VARCHAR(50),
	@Comments VARCHAR(200),
	@DBNodeID INT,
	@DBNodeType INT,
	@flgLocationServicesOnOff TINYINT,
	@flgGPSOnOff TINYINT,
	@flgNetworkOnOff TINYINT,
	@flgFusedOnOff TINYINT,
	@flgInternetOnOffWhileLocationTracking TINYINT,
	@tblGPS udt_RawDataLatLongDetails READONLY,
	@BatteryStatus INT,
	@PinCode BIGINT,
	@City VARCHAR(200),
	@State VARCHAR(200),
	@MapAddress VARCHAR(500),
	@MapCity VARCHAR(200),
	@MapPinCode BIGINT,
	@MapState VARCHAR(200),
	@IsNetworkTimeRecorded TINYINT,
	@OSVersion VARCHAR(200),
	@DeviceID VARCHAR(20),
	@BrandName VARCHAR(200),
	@Model VARCHAR(200),
	@DeviceDatetime DATETIME,
	@LeaveStartDate Date,
	@LeaveEndDate Date,
	@SelfieName VARCHAR(100)
AS
BEGIN
	PRINT 'Attendance Sp Called'
	DECLARE @PersonAttendanceID INT=0
	DECLARE @PersonType SMALLINT
	SELECT @PersonType=NodeType FROM tblMstrPerson WHERE NodeID=@PersonNodeID

	SELECT @PersonAttendanceID=PersonAttendanceID FROM tblPersonAttendance(nolock) WHERE PersonNodeID=@PersonNodeID AND datetime=@Datetime
	IF @PersonAttendanceID>0
	BEGIN
		UPDATE P SET Address=@Address,[Lat Code]=@LatCode,[Long Code]=@LongCode,Accuracy=@Accuracy,AllProvidersLocation=@AllProvidersLocation,TimestampUpd=GETDATE(),Comments=@Comments,DBNodeID=@DBNodeID,DBNodeType=@DBNodeType,XMLFileSetID=@FileSetID,[BatteryStatus]=@BatteryStatus,IsNetworkTimeRecorded=@IsNetworkTimeRecorded,OSVersion=@OSVersion,DeviceID=@DeviceID,BrandName=@BrandName,Model=@Model,DeviceDatetime=@DeviceDatetime FROM tblPersonAttendance P WHERE PersonNodeID=@PersonNodeID AND datetime=@Datetime
	
	END
	ELSE
	BEGIN
		INSERT INTO tblPersonAttendance(PersonNodeID,Address,[Lat Code],[Long Code],Accuracy,AllProvidersLocation,Datetime,TimestampIns,VisitID,IMEINo,Comments,DBNodeID,DBNodeType,flgLocationServicesOnOff,flgGPSOnOff,flgNetworkOnOff,flgFusedOnOff,flgInternetOnOffWhileLocationTracking,XMLFileSetID,[BatteryStatus],City,PinCode,State,MapAddress,MapPinCode,MapCity,MapState,IsNetworkTimeRecorded,OSVersion,DeviceID,BrandName,Model,DeviceDatetime,PersonNodeType,[SelfieName])
		SELECT @PersonNodeID,@Address,@LatCode,@LongCode,@Accuracy,@AllProvidersLocation,@Datetime,GETDATE(),@VisitID,@IMEINo,@Comments,@DBNodeID,@DBNodeType,@flgLocationServicesOnOff,@flgGPSOnOff,@flgNetworkOnOff,@flgFusedOnOff,@flgInternetOnOffWhileLocationTracking,@FileSetID,@BatteryStatus,@City,@PinCode,@State,@MapAddress,@MapPinCode,@MapCity,@MapState,@IsNetworkTimeRecorded,@OSVersion,@DeviceID,@BrandName,@Model,@DeviceDatetime,@PersonType,@SelfieName
		SELECT @PersonAttendanceID=@@IDENTITY
	END
	DELETE FROM PersonAttReason WHERE PersonAttendanceID=@PersonAttendanceID
	INSERT INTO PersonAttReason(PersonAttendanceID,ReasonID,ReasonDescr)
	SELECT @PersonAttendanceID,ReasonID,ResonDescr FROM @tblAttReason WHERE ReasonID<>18  -- Non Privilege Leave

	INSERT INTO PersonAttReason(PersonAttendanceID,ReasonID,ReasonDescr,StartDate,EndDate)
	SELECT @PersonAttendanceID,ReasonID,ResonDescr,@LeaveStartDate,@LeaveEndDate FROM @tblAttReason WHERE ReasonID=18 -- Privilege Leave
END
