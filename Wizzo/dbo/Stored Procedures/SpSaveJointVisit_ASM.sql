-- =============================================
-- Author:		Avinash Gupta
-- Create date: 27-Feb-2019
-- Description:	Sp to Save the data coming from asm app for the joint visit.
-- =============================================
-- DROP PROC SpSaveJointVisit_ASM
CREATE Procedure [dbo].[SpSaveJointVisit_ASM] 
	@IMEINo VARCHAR(100),
	@tblRawDataJointVisitMaster udt_RawDataJointVisitMaster READONLY,
	@tblRawDataJointVisitDetails udt_RawDataJointVisitDetail READONLY	
AS
BEGIN
--	DECLARE @PDAID INT=0
	DECLARE @ManagerNodeId INT
	DECLARE @ManagerNodeType INT
	
	PRINT 'SpSaveJointVisit_ASM'
	--SELECT * FROM @tblRawDataJointVisitMaster
	--SELECT * FROM @tblRawDataJointVisitDetails
	DECLARE @tblRawDataJointVisitMaster_N udt_RawDataJointVisitMaster
	INSERT INTO @tblRawDataJointVisitMaster_N
	SELECT * FROM @tblRawDataJointVisitMaster

	UPDATE N SET ActualLatitude=NULL FROM @tblRawDataJointVisitMaster_N N WHERE ActualLatitude='null'
	UPDATE N SET Actuallongitude=NULL FROM @tblRawDataJointVisitMaster_N N WHERE Actuallongitude='null'
	UPDATE N SET MapAddress=NULL FROM @tblRawDataJointVisitMaster_N N WHERE MapAddress='null'
	UPDATE N SET MapCity=NULL FROM @tblRawDataJointVisitMaster_N N WHERE MapCity='null'
	UPDATE N SET MapState=NULL FROM @tblRawDataJointVisitMaster_N N WHERE MapState='null'
	UPDATE N SET AllProviderData=NULL FROM @tblRawDataJointVisitMaster_N N WHERE AllProviderData='null'
	UPDATE N SET GPSAddress=NULL FROM @tblRawDataJointVisitMaster_N N WHERE GPSAddress='null'
	UPDATE N SET NetworkLatitude=NULL FROM @tblRawDataJointVisitMaster_N N WHERE NetworkLatitude='null'
	UPDATE N SET NetworkLongitude=NULL FROM @tblRawDataJointVisitMaster_N N WHERE NetworkLongitude='null'
	UPDATE N SET FusedLatitude=NULL FROM @tblRawDataJointVisitMaster_N N WHERE FusedLatitude='null'
	UPDATE N SET FusedLongitude=NULL FROM @tblRawDataJointVisitMaster_N N WHERE FusedLongitude='null'

	UPDATE N SET VisitStartDateTime=NULL FROM @tblRawDataJointVisitMaster_N N WHERE VisitStartDateTime='null'
	UPDATE N SET VisitEndDateTime=NULL FROM @tblRawDataJointVisitMaster_N N WHERE VisitEndDateTime='null'


	--SELECT @PDAID=PDAID FROM tblPDAMaster WHERE PDA_IMEI=@IMEINo OR PDA_IMEI_Sec=@IMEINo
	DECLARE @JointVisitID INT,@JointVisitCode VARCHAR(100)
	--IF @PDAID>0
	--BEGIN
	--	PRINT '@PDAID=' + CAST(@PDAID AS VARCHAR)
		SELECT @ManagerNodeId=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@IMEINo) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
		SELECT @ManagerNodeType=PersonType FROM tblSalesPersonMapping WHERE PersonNodeID=@ManagerNodeId


		--SELECT @ManagerNodeId=PersonID,@ManagerNodeType=PersonType FROM tblPDA_UserMapMaster WHERE PDAID=@PDAID AND (CAST(GETDATE() AS DATE) BETWEEN DateFrom AND DateTo)

		--- Reading the total joint visits
		DECLARE Cur_JointVisit CURSOR FOR
			SELECT JointVisitCode FROM @tblRawDataJointVisitMaster_N

		OPEN Cur_JointVisit
		FETCH NEXT FROM Cur_JointVisit INTO @JointVisitCode
		WHILE @@FETCH_STATUS = 0  
		BEGIN 
			IF NOT EXISTS(SELECT 1 FROM tblJointVisitMaster_ASM WHERE JointVisitCode=@JointVisitCode)
			BEGIN
				PRINT 'INSERT JOINTVISIT CALLED'
				SELECT [JointVisitCode],[ManagerNodeId],[ManagerNodeType],[CoverageNodeID],[CoverageNodeType],[VisitDate],[ActualLatitude],[Actuallongitude],[VisitStartDateTime],[VisitEndDatetime],[MapAddress],[MapPinCode],[MapCity],[MapState],[LocProvider],[Accuracy],@IMEINo,GETDATE(),[AllProviderData],[GPSLatitude],[GPSLongitude],[GPSAccuracy],[GPSAddress],[NetworkLatitude],[NetworkLongitude],[NetworkAccuracy],[NetworkAddress],[FusedLatitude],[FusedLongitude],[FusedAccuracy],[FusedAddress],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking],[flgRestart] FROM @tblRawDataJointVisitMaster_N WHERE JointVisitCode=@JointVisitCode

				INSERT INTO tblJointVisitMaster_ASM(JointVisitCode,ManagerNodeId,ManagerNodeType,CoverageID,CoverageNodeType,VisitDate,ActualLatitude,ActualLongitude,VisitStartDateTime,VisitEndDatetime,MapAddress,MapPinCode,MapCity,MapState,LocationProvider,Accuracy,IMEINo,TIMESTAMP,AllProviderData,GPSLatitude,GPSLongitude,GPSAccuracy,GPSAddress,NetworkLatitude,NetworkLongitude,NetworkAccuracy,NetworkAddress,FusedLatitude,FusedLongitude,FusedAccuracy,FusedAddress,flgLocationServicesOnOff,flgGPSOnOff,flgNetworkOnOff,flgFusedOnOff,flgInternetOnOffWhileLocationTracking,flgRestart)
				SELECT [JointVisitCode],[ManagerNodeId],[ManagerNodeType],[CoverageNodeID],[CoverageNodeType],[VisitDate],[ActualLatitude],[Actuallongitude],[VisitStartDateTime],[VisitEndDatetime],[MapAddress],[MapPinCode],[MapCity],[MapState],[LocProvider],[Accuracy],@IMEINo,GETDATE(),[AllProviderData],[GPSLatitude],[GPSLongitude],[GPSAccuracy],[GPSAddress],[NetworkLatitude],[NetworkLongitude],[NetworkAccuracy],[NetworkAddress],[FusedLatitude],[FusedLongitude],[FusedAccuracy],[FusedAddress],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking],[flgRestart] FROM @tblRawDataJointVisitMaster_N WHERE JointVisitCode=@JointVisitCode

				SELECT @JointVisitID=SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
				UPDATE tblJointVisitMaster_ASM SET VisitEndDatetime=J.[VisitEndDatetime] FROM tblJointVisitMaster_ASM A INNER JOIN @tblRawDataJointVisitMaster_N J ON A.JointVisitCode=J.JointVisitCode WHERE J.JointVisitCode=@JointVisitCode
			END
			IF ISNULL(@JointVisitID,0)>0
			BEGIN
				DELETE FROM [dbo].[tblJointVisitDetails_ASM] WHERE JointVisitCode=@JointVisitCode
				INSERT INTO tblJointVisitDetails_ASM(JointVisitID,[JointVisitCode],[FellowPersonNodeId],[FellowPersonNodeType])
				SELECT @JointVisitID,JointVisitCode,[FellowPersonNodeId],[FellowPersonNodeType] FROM @tblRawDataJointVisitDetails WHERE JointVisitCode=@JointVisitCode
			END

			FETCH NEXT FROM Cur_JointVisit INTO @JointVisitCode
		END
		CLOSE Cur_JointVisit
		DEALLOCATE Cur_JointVisit
	--END
	SELECT * FROM [dbo].tblJointVisitMaster_ASM
END
