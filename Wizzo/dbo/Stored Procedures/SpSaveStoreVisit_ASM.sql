-- =============================================
-- Author:		Avinash Gupta
-- Create date: 28-Feb-2019
-- Description:	Sp to Save the ASM Store Visit Details
-- =============================================
--DROP PROC [SpSaveStoreVisit_ASM]
CREATE Procedure [dbo].[SpSaveStoreVisit_ASM] 
	@IMEINo VARCHAR(100),
	@tblRawDataCustomerSupVisit udt_RawDataCustomerVisit READONLY
AS
BEGIN
	--DECLARE @PDAID INT=0
	--SELECT @PDAID=PDAID FROM tblPDAMaster WHERE PDA_IMEI=@IMEINo OR PDA_IMEI_Sec=@IMEINo

	DECLARE @VisitPersonNodeID INT
	DECLARE @VisitPersonNodeType SMALLINT
	--SELECT @VisitPersonNodeID=PersonID,@VisitPersonNodeType=PersonType FROM tblPDA_UserMapMaster PU WHERE PU.PDAID=@PDAID AND GETDATE() BETWEEN PU.DateFrom AND PU.DateTo
	SELECT @VisitPersonNodeID=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@IMEINo) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	SELECT @VisitPersonNodeType=PersonType FROM tblSalesPersonMapping WHERE PersonNodeID=@VisitPersonNodeID


	DECLARE @StoreVisitCode VARCHAR(100)
	--IF @PDAID>0
	--BEGIN
		-- Reading the total Supervisor Visit
		DECLARE Cur_StoreVisit CURSOR FOR
			SELECT StoreVisitCode FROM @tblRawDataCustomerSupVisit WHERE flgJointVisit=1

		OPEN Cur_StoreVisit
		FETCH NEXT FROM Cur_StoreVisit INTO @StoreVisitCode
		WHILE @@FETCH_STATUS = 0  
		BEGIN 
			SELECT * FROM @tblRawDataCustomerSupVisit WHERE StoreVisitCode=@StoreVisitCode

			IF NOT EXISTS(SELECT 1 FROM tblSFACustomerSupVisit WHERE StoreVisitCode=@StoreVisitCode)
			BEGIN
				INSERT INTO tblSFACustomerSupVisit(StoreID,StoreVisitCode,JointVisitID,flgJointVisit,VisitLatitude,VisitLongitude,VisitDate,VisitPersonNodeID,VisitPersonNodetype,DeviceVisitStartTS,DeviceVisitEndTS,flgOutletClose,BatteryLeftStatus,LocationProvider,Accuracy,TIMESTAMP,AllProviderData,GPSLatitude,GPSLongitude,GPSAccuracy,GPSAddress,NetworkLatitude,NetworkLongitude,NetworkAccuracy,NetworkAddress,FusedLatitude,FusedLongitude,FusedAccuracy,FusedAddress,flgLocationServicesOnOff,flgGPSOnOff,flgNetworkOnOff,flgFusedOnOff,flgInternetOnOffWhileLocationTracking,flgRestart)
				SELECT StoreID,StoreVisitCode,JointVisitID,flgJointVisit,VisitLatitude,VisitLongitude,VisitDate,@VisitPersonNodeID,@VisitPersonNodeType,[VisitTimeOutSideStore],[VisitTimeInSideStore],[StoreClose],[BateryLeftStatus],[LocProvider],[Accuracy],GETDATE(), [AllProviderData],[GPSLatitude],[GPSLongitude],[GPSAccuracy],[GPSAddress],[NetworkLatitude],[NetworkLongitude],[NetworkAccuracy],[NetworkAddress],[FusedLatitude],[FusedLongitude],[FusedAccuracy],[FusedAddress],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking],0 FROM @tblRawDataCustomerSupVisit WHERE StoreVisitCode=@StoreVisitCode
			END
			ELSE
			BEGIN
				UPDATE tblSFACustomerSupVisit SET JointVisitID=SV.JointVisitID,flgJointVisit=SV.flgJointVisit,VisitLatitude=SV.VisitLatitude,VisitLongitude=SV.VisitLongitude,VisitDate=SV.VisitDate,VisitPersonNodeID=@VisitPersonNodeID,VisitPersonNodetype=@VisitPersonNodeType,DeviceVisitStartTS=SV.[VisitTimeOutSideStore],DeviceVisitEndTS=SV.VisitTimeInSideStore,flgOutletClose=SV.StoreClose,BatteryLeftStatus=SV.BateryLeftStatus,LocationProvider=SV.LocProvider,Accuracy=SV.Accuracy,AllProviderData=SV.AllProviderData,GPSLatitude=SV.GPSLatitude,GPSLongitude=SV.GPSLongitude,GPSAccuracy=SV.GPSAccuracy,GPSAddress=SV.GPSAddress,NetworkLatitude=SV.NetworkLatitude,NetworkLongitude=SV.NetworkLongitude,NetworkAccuracy=SV.NetworkAccuracy,NetworkAddress=SV.NetworkAddress,FusedLatitude=SV.FusedLatitude,FusedLongitude=SV.FusedLongitude,FusedAccuracy=SV.FusedAccuracy,FusedAddress=SV.FusedAddress,flgLocationServicesOnOff=SV.flgLocationServicesOnOff,flgGPSOnOff=SV.flgGPSOnOff,flgNetworkOnOff=SV.flgNetworkOnOff,flgFusedOnOff=SV.flgFusedOnOff,flgInternetOnOffWhileLocationTracking=SV.flgInternetOnOffWhileLocationTracking,flgRestart=0 FROM tblSFACustomerSupVisit S INNER JOIN @tblRawDataCustomerSupVisit SV ON S.StoreVisitCode=SV.StoreVisitCode
			END

			FETCH NEXT FROM Cur_StoreVisit INTO @StoreVisitCode
		END
		CLOSE Cur_StoreVisit
		DEALLOCATE Cur_StoreVisit
	--END
END
