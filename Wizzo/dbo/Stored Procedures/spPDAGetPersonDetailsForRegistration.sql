
-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================
--[spPDAGetPersonDetailsForRegistrationOriginal] '353202065143237','9810342130','29/Apr/1981'
CREATE PROCEDURE [dbo].[spPDAGetPersonDetailsForRegistration]
@PDACode VARCHAR(100),
@MobNo VARCHAR(15),
@DOB Date

AS

BEGIN
	--select CONVERT(DATETIME, '22/Sep/2017', 105),getdate()
	DECLARE @ExistingPersonId INT=0
	DECLARE @ExistingPersonType INT=0
	DECLARE @PersonNodeId INT=0
	DECLARE @PersonNodeType INT=0
	DECLARE @Flag TINYINT
	DEClARE @MsgToDisplay VARCHAR(200)=''

	

	IF NOT EXISTS(SELECT 1 FROM tblRegisteredPersonDetails WHERE ContactNo=@MobNo AND DOB=@DOB)
	BEGIN
		SET @Flag=0
		SET @MsgToDisplay=''
	END
	ELSE
	BEGIN
		--IF NOT EXISTS(SELECT 1 FROM tblMstrPerson WHERE PersonPhone=@MobNo)
		--BEGIN
		--	SET @Flag=0
		--	SET @MsgToDisplay=''
		--END
		--ELSE
		--BEGIN
			SELECT @PersonNodeId=PersonNodeId,@PersonNodeType=PersonNodeType FROM tblRegisteredPersonDetails WHERE ContactNo=@MobNo AND DOB=@DOB
			--SELECT @PersonNodeId
			SELECT @ExistingPersonId = PersonID
			FROM tblPDACodeMapping P 
			WHERE P.PDACode=@PDACode 
			--SELECT @ExistingPersonId
			IF @ExistingPersonId=@PersonNodeId
			BEGIN
				SET @Flag=2
				SET @MsgToDisplay=''
			END
			ELSE 
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM tblPDACodeMapping WHERE PersonID=@PersonNodeId )
				BEGIN
					SET @Flag=2
					SET @MsgToDisplay=''	
				END
				ELSE
				BEGIN
					SET @Flag=1
					SET @MsgToDisplay='You are not allowed to save the details currently. Please contact the adminostrator.'
				END
			END
		--END
		--SET @Flag=1
	END
	SELECT @Flag AS Flag,@MsgToDisplay MsgToDisplay

	SELECT PersonNodeId,
PersonNodeType,
FirstName,
LastName,
ContactNo,
FORMAT(DOB,'dd-MMM-yyyy') DOB,
Gender,
IsMarried,
FORMAT(MarriageDate,'dd-MMM-yyyy') MarriageDate,
Qualification,
EmailId,
BloodGroup,
PhotoName,
SelfieName,
SignImgName,
TimeStampIns,
TimeStampUpd FROM tblRegisteredPersonDetails
	WHERE PersonNodeId=@PersonNodeId AND PersonNodeType=@PersonNodeType







END
