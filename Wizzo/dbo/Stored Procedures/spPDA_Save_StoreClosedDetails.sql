
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--DROP PROC spPDA_Save_StoreClosedDetails
--GO
CREATE Procedure [dbo].[spPDA_Save_StoreClosedDetails]
@StoreID INT,
@StoreVisitCode VARCHAR(100),
@VisitID INT,
@ReasonId INT,
@ReasonDescr VARCHAR(200),
@ActualLatitude decimal(30, 27),  
@ActualLongitude decimal(30, 27),  
@LocProvider varchar(20),  
@Accuracy varchar (100),  
@City VARCHAR(200),
@Pincode VARCHAR(20),
@State VARCHAR(200),
@Imei varchar (100),  
@tblImages udt_ClosedStoreImages ReadOnly,
@tblGPSInfo udt_GPSInfo ReadOnly

AS
BEGIN
	DECLARE @VisitDate DATE
	--DECLARE @VisitID INT
	DECLARE @ClosedStoreVisitID INT
	
	--SELECT @VisitDate=CONVERT(DATE,@VisitForDate,105)
	--SELECT @VisitDate=@VisitForDate

	--SELECT @VisitID = VisitID FROM tblVisitMaster WHERE StoreID=@StoreID AND VisitDate=@VisitForDate

	SELECT @ClosedStoreVisitID = ClosedStoreVisitID FROM tblClosedStoreVisitDetails WHERE VisitID=@VisitID AND StoreID = @StoreID

	IF (@ReasonDescr='NA' OR ISNULL(@ReasonDescr,'')='') AND @ReasonId<>-99
	BEGIN
		SELECT @ReasonDescr=ReasonDescr FROM tblMstrReasonForClosedStore WHERE ReasonId=@ReasonId
	END

	IF @Pincode='NA'
	BEGIN
		SET @Pincode=0
	END

	IF ISNULL(@ClosedStoreVisitID,0)=0
	BEGIN
		INSERT INTO tblClosedStoreVisitDetails(StoreID,VisitID,ReasonId,ReasonDescr,ActualLatitude,ActualLongitude,LocProvider,Accuracy,Imei,City,PinCode,[State],TimeStampIns)
		SELECT @StoreID, @VisitID,@ReasonId,@ReasonDescr,@ActualLatitude,@ActualLongitude,@LocProvider,@Accuracy,@Imei, @City,@Pincode,@State,GETDATE()
			
		SELECT @ClosedStoreVisitID = IDENT_CURRENT('tblClosedStoreVisitDetails')
	END
	ELSE
	BEGIN
		UPDATE V SET ReasonId=@ReasonId,ReasonDescr=@ReasonDescr,ActualLatitude=@ActualLatitude,ActualLongitude=@ActualLongitude,LocProvider=@LocProvider,Accuracy=@Accuracy, Imei=@Imei,City=@City,PinCode=@Pincode,[State]=@State,TimeStampUpd= GETDATE()
		FROM tblClosedStoreVisitDetails V WHERE VisitID=@VisitID AND StoreID = @StoreID
	END

	DELETE FROM tblClosedStoreImageDetails WHERE ClosedStoreVisitID=@ClosedStoreVisitID

	INSERT INTO tblClosedStoreImageDetails(ClosedStoreVisitID,PhotoName,ClickedDateTime)
	SELECT @ClosedStoreVisitID,ImageName,CONVERT(DATETIME,ClickedDateTime,105)
	FROM @tblImages
	

	IF EXISTS(SELECT 1 FROM @tblGPSInfo)
	BEGIN
		SELECT 1
		UPDATE P SET Address=T.Address,AllProviderData=T.AllProviderData,GPSLatitude=T.GPSLatitude,GPSLongitude=T.GPSLongitude,GPSAccuracy=T.GPSAccuracy,GPSAddress=T.GPSAddress, NetworkLatitude=T.NetworkLatitude,NetworkLongitude=T.NetworkLongitude,NetworkAccuracy=T.NetworkAccuracy,NetworkAddress=T.NetworkAddress,FusedLatitude=T.FusedLatitude, FusedLongitude=T.FusedLongitude,FusedAccuracy=T.FusedAccuracy,FusedAddress=T.FusedAddress
		FROM tblClosedStoreVisitDetails P INNER JOIN @tblGPSInfo T ON T.StoreID=P.StoreID WHERE P.ClosedStoreVisitID=@ClosedStoreVisitID
	END 
END

