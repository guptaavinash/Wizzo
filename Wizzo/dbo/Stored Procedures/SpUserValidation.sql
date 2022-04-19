
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 05-Nov-2019
-- Description:	
-- =============================================
-- [SpUserValidation] '552829442',1,NULL,''
CREATE PROCEDURE [dbo].[SpUserValidation] 
	@ContactNo varchar(10),
	@flgStep TINYINT,--1=Step1,2=Step2
	@OTP VARCHAR(10),
	@FCMToken VARCHAR(200)=''
AS
BEGIN
	DECLARE @flgValidated TINYINT
	DECLARE @PDACode VARCHAR(50)
	SELECT @flgValidated=0
	DECLARE @PersonNodeID INT
	DECLARE @flgLock TINYINT
	DECLARE @OTPExists VARCHAR(10)

	DECLARE @asOf DATETIME2(7) = GETDATE() 

		--OPEN SYMMETRIC KEY System_password
	 --     DECRYPTION BY CERTIFICATE Certificate_Password WITH PASSWORD = '2Si3987PephxJ#KL95234AixST';

	SELECT @PersonNodeID=NodeID FROM tblMstrPerson WHERE PersonPhone=CAST(@ContactNo AS VARCHAR)

	PRINT 'PersonNodeID=' + CAST(ISNULL(@PersonNodeID,0) AS VARCHAR)
	IF ISNULL(@PersonNodeID,0)>0
	BEGIN
		IF  NOT EXISTS(SELECT 1 FROM tblPDACodeMapping  WHERE PersonID=@PersonNodeID AND @asOf BETWEEN ValidFrom and ValidTo ) 
		BEGIN
			IF @flgStep=1
			BEGIN
				SELECT @PDACode=CONVERT(varchar(50), NEWID())

				INSERT INTO tblPDACodeMapping(PersonID,PDACode,ValidFrom,ValidTo,FCMToken)
				SELECT @PersonNodeID,@PDACode,@asOf,'31-Dec-2049',@FCMToken

				SET @flgValidated=1
			END
		END
		ELSE 
		BEGIN
			SELECT @flgLock=flgLock FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID AND CAST(@asOf AS DATE) = CAST(ValidFrom AS DATE)
			SELECT @OTPExists=OTP FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID

			PRINT '@flgLock=' + CAST(@flgLock AS VARCHAR)
			PRINT '@@OTPExists=' + CAST(@OTPExists AS VARCHAR)

			IF @flgStep=1 AND ISNULL(@OTPExists,0)<>''
			BEGIN
				IF ISNULL(@flgLock,0)=1
				BEGIN
					PRINT 'OKOK'
					SET @flgValidated=2
					SELECT @PDACode=PDACode FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID AND CAST(@asOf AS DATE) = CAST(ValidFrom AS DATE)
				END
				ELSE
				BEGIN
					SELECT @PDACode=CONVERT(varchar(50), NEWID())

					INSERT INTO tblPDACodeMapping_History(PersonID,PDACode,OTP,ValidFrom,ValidTo,FCMToken)
					SELECT PersonID,PDACode,OTP,ValidFrom,ValidTo,FCMToken FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID

					UPDATE tblPDACodeMapping SET PDACode=@PDACode,ValidFrom=@asOf,FCMToken=@FCMToken FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID

					SET @flgValidated=1
				END
			END
			ELSE IF @flgStep=1 AND ISNULL(@OTPExists,0)=''
			BEGIN
				SELECT @PDACode=CONVERT(varchar(50), NEWID())

				INSERT INTO tblPDACodeMapping_History(PersonID,PDACode,OTP,ValidFrom,ValidTo,FCMToken)
				SELECT PersonID,PDACode,OTP,ValidFrom,ValidTo,FCMToken FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID

				UPDATE tblPDACodeMapping SET PDACode=@PDACode,ValidFrom=@asOf,FCMToken=@FCMToken FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID

				SET @flgValidated=1
			END
			ELSE IF @flgStep=2 AND ISNULL(@OTPExists,0)<>''
			BEGIN
				PRINT 'Called'
				IF ISNULL(@flgLock,0)=0
				BEGIN
					SELECT @PDACode=PDACode FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID
					UPDATE tblPDACodeMapping SET OTP=@OTP,flgLock=1,FCMToken=@FCMToken FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID

					SET @flgValidated=1
				END
				ELSE
				BEGIN
					PRINT 'Not Validated'
					SET @flgValidated=2
					SELECT @PDACode=PDACode FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID

					PRINT '@flgValidated=' + CAST(@flgValidated AS VARCHAR(10))
				END
			END
			ELSE IF @flgStep=2 AND ISNULL(@OTPExists,0)=''
			BEGIN
				PRINT 'Not Called'
				SELECT @PDACode=PDACode FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID
				UPDATE tblPDACodeMapping SET OTP=@OTP,flgLock=1,FCMToken=@FCMToken FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID

				SET @flgValidated=1
			END
			--SELECT @PDACode=PDACode FROM tblPDACodeMapping FOR SYSTEM_TIME AS OF @asOf WHERE PersonID=@PersonNodeID
		END
	END
	ELSE
	BEGIN
		SET @flgValidated=0
	END

	SELECT CAST(@flgValidated AS INT) flgValidated,@PDACode PDACode
END
