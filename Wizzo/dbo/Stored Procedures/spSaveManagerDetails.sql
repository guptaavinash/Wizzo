
CREATE PROCEDURE [dbo].[spSaveManagerDetails]
@PDA_IMEI VARCHAR(50),
@VisitDate Date,
@SalesPersonNodeId INT,
@SalesPersonNodeType INT,
@ManagerNodeId INT,
@ManagerNodeType INT,
@ManagerName VARCHAR(200),
@OtherManagerName VARCHAR(200)
AS
BEGIN
	DECLARE @DeviceID INT, @VisitDateFor DATE

	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI
	--SELECT @VisitDateFor = CONVERT(DATETIME,@VisitDate,105)
	SELECT @VisitDateFor =@VisitDate
	--SELECT @ManagerNodeId

	IF @ManagerNodeId<>0
	BEGIN
		IF @ManagerNodeId=-99
		BEGIN
			--SELECT 1
			IF EXISTS(SELECT * FROM tblManagerDetailsForIndVisit WHERE SalesPersonNodeId=@SalesPersonNodeId AND SalesPersonNodeType=@SalesPersonNodeType AND VisitDate=@VisitDateFor AND ManagerNodeId=@ManagerNodeId AND ManagerNodeType=@ManagerNodeType AND ManagerName=@OtherManagerName)
			BEGIN
				--SELECT 11
				UPDATE tblManagerDetailsForIndVisit SET TimeStampUpd=GETDATE()
				WHERE SalesPersonNodeId=@SalesPersonNodeId AND SalesPersonNodeType=@SalesPersonNodeType AND VisitDate=@VisitDateFor AND ManagerNodeId=@ManagerNodeId AND ManagerNodeType=@ManagerNodeType AND ManagerName=@OtherManagerName
				--UPDATE tblManagerDetailsForIndVisit SET DeviceId=@DeviceID,ManagerNodeId=@ManagerNodeId,ManagerNodeType=@ManagerNodeType,ManagerName=@ManagerName
				--WHERE SalesPersonNodeId=@SalesPersonNodeId AND SalesPersonNodeType=@SalesPersonNodeType AND VisitDate=@VisitDateFor
			END
			ELSE
			BEGIN
				--SELECT 12
				INSERT INTO tblManagerDetailsForIndVisit(DeviceId,VisitDate,SalesPersonNodeId,SalesPersonNodeType,ManagerNodeId,ManagerNodeType,ManagerName,TimeStampIn)
				SELECT @DeviceID,@VisitDateFor,@SalesPersonNodeId,@SalesPersonNodeType,@ManagerNodeId,@ManagerNodeType,@OtherManagerName,GETDATE()
			END
		END
		ELSE
		BEGIN
			--SELECT 2
			IF EXISTS(SELECT * FROM tblManagerDetailsForIndVisit WHERE SalesPersonNodeId=@SalesPersonNodeId AND SalesPersonNodeType=@SalesPersonNodeType AND VisitDate=@VisitDateFor AND ManagerNodeId=@ManagerNodeId AND ManagerNodeType=@ManagerNodeType AND ManagerName=@ManagerName)
			BEGIN
				--SELECT 21
				UPDATE tblManagerDetailsForIndVisit SET TimeStampUpd=GETDATE()
				WHERE SalesPersonNodeId=@SalesPersonNodeId AND SalesPersonNodeType=@SalesPersonNodeType AND VisitDate=@VisitDateFor AND ManagerNodeId=@ManagerNodeId AND ManagerNodeType=@ManagerNodeType AND ManagerName=@ManagerName
				--UPDATE tblManagerDetailsForIndVisit SET DeviceId=@DeviceID,ManagerNodeId=@ManagerNodeId,ManagerNodeType=@ManagerNodeType,ManagerName=@ManagerName
				--WHERE SalesPersonNodeId=@SalesPersonNodeId AND SalesPersonNodeType=@SalesPersonNodeType AND VisitDate=@VisitDateFor
			END
			ELSE
			BEGIN
				--SELECT 22
				INSERT INTO tblManagerDetailsForIndVisit(DeviceId,VisitDate,SalesPersonNodeId,SalesPersonNodeType,ManagerNodeId,ManagerNodeType,ManagerName,TimeStampIn)
				SELECT @DeviceID,@VisitDateFor,@SalesPersonNodeId,@SalesPersonNodeType,@ManagerNodeId,@ManagerNodeType,@ManagerName,GETDATE()
			END
		END
	END
END

