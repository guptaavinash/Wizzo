-- =============================================
-- Author:		Avinash Gupta
-- Create date: 05-Nov-2019
-- Description:	
-- =============================================
-- [SpStoreContactValidation] 99919,9805340825,1,''
CREATE PROCEDURE [dbo].[SpStoreContactValidation] 
	@StoreID INT,
	@ContactNo BIGINT,
	@flgStep TINYINT,--1=Step1,2=Step2,3=Contact Number mapped to other retailer 
	@OTP VARCHAR(4)
AS
BEGIN
	DECLARE @flgValidated TINYINT
	SELECT @flgValidated=0
	DECLARE @flgLock TINYINT
	DECLARE @PersonNodeID INT
	DECLARE @PersonNodeType SMALLINT
	--DECLARE @OTPExists VARCHAR(10)

	--SELECT @PersonNodeID=StoreID FROM tblOutletContactDet WHERE MobNo=CAST(@ContactNo AS VARCHAR) AND ContactType=1
	--SELECT @PersonNodeID=SONodeId,@PersonNodeType=SONodeType FROM tblRouteCalendar(nolock) WHERE StoreID=@StoreID AND CAST(VisitDAte AS DATE)=CAST(GETDATE() AS DATE)
	SELECT @PersonNodeID=RV.DSENodeId,@PersonNodeType=RV.DSENodeType FROM tblRoutePlanningVisitDetail RV INNER JOIN tblRouteCoverageStoreMapping RS ON RS.RouteID=RV.RouteNodeId AND RS.RouteNodeType=RV.RouteNodetype AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate WHERE RS.StoreID=@StoreID AND CAST(VisitDAte AS DATE)>=CAST(GETDATE() AS DATE) 
	--PRINT 'PersonNodeID=' + CAST(ISNULL(@PersonNodeID,0) AS VARCHAR)
	IF ISNULL(@StoreID,0)>0
	BEGIN
		IF NOT EXISTS (
		SELECT C.StoreID FROM tblOutletContactDet C INNER JOIN tblStoreMaster SM ON SM.StoreID=C.StoreID INNER JOIN tblRouteCoverageStoreMapping RS ON RS.StoreID=SM.StoreID 
		WHERE (CAST(GETDATE() AS DATE) BETWEEN RS.FromDate AND RS.ToDate) AND (LandLineNo1=CAST(@ContactNo AS VARCHAR(12)) OR MobNo=@ContactNo) AND C.StoreID<>@StoreID AND SM.flgActive=1)
			BEGIN
			IF NOT EXISTS (SELECT StoreID FROM tblStoreContactUpdate U  WHERE U.ContactNo=@ContactNo AND StoreID<>@StoreID)
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM tblStoreContactUpdate U  WHERE U.StoreID=@StoreID AND U.ContactNo=@ContactNo)
				BEGIN
					IF @flgStep=1
					BEGIN
						PRINT 'A'
						INSERT INTO tblStoreContactUpdate(StoreID,OutCnctPersonID,OTP,TimestampIns,ContactNo,PersonNodeID,PersonNodeType)
						SELECT @StoreID,OutCnctPersonID,@OTP,GETDATE(),@ContactNo,@PersonNodeID,@PersonNodeType FROM tblOutletContactDet WHERE StoreID=@StoreID AND ContactType=1

						SET @flgValidated=1
					END
					ELSE IF @flgStep=2
					BEGIN
						INSERT INTO tblStoreContactUpdate(StoreID,OutCnctPersonID,OTP,TimestampIns,ContactNo,PersonNodeID,PersonNodeType)
						SELECT @StoreID,OutCnctPersonID,@OTP,GETDATE(),@ContactNo,@PersonNodeID,@PersonNodeType FROM tblOutletContactDet WHERE StoreID=@StoreID AND ContactType=1

						UPDATE C SET MobNo=@ContactNo,TimestampUpd=GETDATE() FROM tblOutletContactDet C WHERE StoreID=@StoreID AND ContactType=1
						
						UPDATE S SET @ContactNo=@ContactNo FROM tblStoreMaster S WHERE StoreID=@StoreID 
						SET @flgValidated=2
						
					END
				END
				ELSE		
				BEGIN
					IF @flgStep=1
					BEGIN
				
							PRINT 'B'
							INSERT INTO tblStoreContactUpdate_History(StoreID,OutCnctPersonID,OTP,flgLock,TimestampIns,TimestampUpd,ContactNo,PersonNodeID,PersonNodeType)
							SELECT StoreID,OutCnctPersonID,OTP,flgLock,TimestampIns,TimestampUpd,ContactNo,@PersonNodeID,@PersonNodeType FROM tblStoreContactUpdate WHERE StoreID=@StoreID AND ContactNo=@ContactNo

							DELETE FROM tblStoreContactUpdate WHERE StoreID=@StoreID AND ContactNo=@ContactNo

							INSERT INTO tblStoreContactUpdate(StoreID,OutCnctPersonID,OTP,TimestampIns,ContactNo,PersonNodeID,PersonNodeType)
							SELECT @StoreID,OutCnctPersonID,@OTP,GETDATE(),@ContactNo,@PersonNodeID,@PersonNodeType FROM tblOutletContactDet WHERE StoreID=@StoreID AND ContactType=1

							SET @flgValidated=1
					END
					ELSE IF @flgStep=2 --AND ISNULL(@OTPExists,0)<>0
					BEGIN
						PRINT 'C'
						--SELECT OTP INTO #OTPExists FROM tblStoreContactUpdate WHERE StoreID=@StoreID AND ContactNo=@ContactNo
						--UNION
						--SELECT OTP FROM tblStoreContactUpdate_History WHERE StoreID=@StoreID AND ContactNo=@ContactNo

						--IF @OTP IN (SELECT OTP FROM #OTPExists) --AND ISNULL(@OTPExists,0)<>0 
						--BEGIN
							UPDATE C SET MobNo=@ContactNo,TimestampUpd=GETDATE() FROM tblOutletContactDet C WHERE StoreID=@StoreID AND ContactType=1
							UPDATE S SET @ContactNo=@ContactNo FROM tblStoreMaster S WHERE StoreID=@StoreID 
							SET @flgValidated=2
						--END
						--ELSE
						--BEGIN
						--	SET @flgValidated=0
						--END
					END
				END
			END
			ELSE
			BEGIN
				SET @flgValidated=3
			END
		END
		ELSE
		BEGIN
			SET @flgValidated=3
		END
	
	END
	ELSE
	BEGIN
		SET @flgValidated=0
	END

	SELECT CAST(@flgValidated AS INT) flgValidated
END
