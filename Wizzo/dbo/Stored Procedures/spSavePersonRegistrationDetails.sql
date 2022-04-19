-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSavePersonRegistrationDetails] 
@IMEINo VARCHAR(100),
@Name VARCHAR(200),
@ContactNo VARCHAR(15),
@DOB VARCHAR(25),
@Gender VARCHAR(10),
@IsMarried TINYINT,
@MarriageDate VARCHAR(25),
@Qualification VARCHAR(100),
@EmailId VARCHAR(200),
@BloodGroup VARCHAR(5),
@SelfieName VARCHAR(200),
@PhotoName VARCHAR(200),
@SignImgName VARCHAR(200),
@PersonNodeId INT,
@PersonNodeType INT,
@RegistrationDateTime VARCHAR(25),
@FileSetID INT
AS
BEGIN
	--DECLARE @PDAId INT
	DECLARE @ExistingPersonId INT=0
	DECLARE @ExistingPersonType INT=0

	--SELECT @PDAId=PDAId FROM tblPDAMaster WHERE PDA_IMEI=@IMEINo OR PDA_IMEI_Sec=@IMEINo

	--IF @PersonNodeId=0
	--BEGIN
	--	SELECT @PersonNodeId=PersonNodeId,@PersonNodeType=PersonNodeType FROM tblRegisteredPersonDetails WHERE ContactNo=@ContactNo AND DOB=CONVERT(DATETIME, @DOB, 105)
	--END

	SELECT @PersonNodeID=NodeID,@PersonNodeType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@IMEINo) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	PRINT '@IMEINo=' + @IMEINo
	PRINT '@PersonNodeID' + CAST(@PersonNodeID AS VARCHAR)
	PRINT '@ContactNo=' + CAST(@ContactNo AS VARCHAR(15))

	IF ISNULL(@PersonNodeId,0)=0
	BEGIN
		SELECT @PersonNodeId=NodeID,@PersonNodeType=NodeType FROM tblMstrPerson WHERE PersonPhone=@ContactNo
	END

	IF @PersonNodeId=0
	BEGIN
		INSERT INTO tblMstrPerson(Descr,PersonEmailID,PersonPhone,NodeType,FromDate,ToDate,flgRegistered)
		SELECT @Name, @EmailId,@ContactNo,@PersonNodeType,GETDATE(),'31-Dec-2049',1

		SELECT @PersonNodeId = IDENT_CURRENT('tblMstrPerson')

		INSERT INTO tblRegisteredPersonDetails(PersonNodeId,PersonNodeType,FirstName,ContactNo,DOB,Gender,IsMarried,MarriageDate,Qualification,EmailId,BloodGroup, SelfieName,SignImgName,TimeStampIns,FileSetID)
		SELECT @PersonNodeId,@PersonNodeType,@Name,@ContactNo,CONVERT(DATETIME, @DOB, 105),@Gender,@IsMarried,CASE @IsMarried WHEN 0 THEN NULL ELSE CONVERT(DATETIME, @MarriageDate, 105) END,@Qualification,@EmailId,@BloodGroup,CASE WHEN LEN(ISNULL(@SelfieName,''))>1 THEN @SelfieName ELSE @PhotoName END AS SelfieName,@SignImgName,GETDATE(),@FileSetID
	END
	ELSE
	BEGIN
		UPDATE tblMstrPerson SET flgRegistered=1 WHERE NodeId=@PersonNodeId AND NodeType=@PersonNodeType

		IF EXISTS(SELECT 1 FROM tblRegisteredPersonDetails WHERE PersonNodeId=@PersonNodeId AND PersonNodeType=@PersonNodeType)
		BEGIN
			UPDATE tblRegisteredPersonDetails SET FirstName=@Name,ContactNo=@ContactNo,DOB=CONVERT(DATETIME, @DOB, 105),Gender=@Gender, IsMarried=@IsMarried, MarriageDate=CASE @IsMarried WHEN 0 THEN NULL ELSE CONVERT(DATETIME, @MarriageDate, 105) END,Qualification=@Qualification,EmailId=@EmailId, BloodGroup=@BloodGroup, SelfieName=CASE WHEN LEN(ISNULL(@SelfieName,''))>1 THEN @SelfieName ELSE @PhotoName END,SignImgName=@SignImgName,TimeStampUpd=GETDATE()
			WHERE PersonNodeId=@PersonNodeId AND PersonNodeType=@PersonNodeType
		END
		ELSE
		BEGIN
			INSERT INTO tblRegisteredPersonDetails(PersonNodeId,PersonNodeType,FirstName,ContactNo,DOB,Gender,IsMarried,MarriageDate,Qualification,EmailId,BloodGroup, SelfieName,SignImgName,TimeStampIns,FileSetID)
			SELECT @PersonNodeId,@PersonNodeType,@Name,@ContactNo,CONVERT(DATETIME, @DOB, 105),@Gender,@IsMarried, CASE @IsMarried WHEN 0 THEN NULL ELSE CONVERT(DATETIME, @MarriageDate, 105) END,@Qualification,@EmailId,@BloodGroup,CASE WHEN LEN(ISNULL(@SelfieName,''))>1 THEN @SelfieName ELSE @PhotoName END AS SelfieName,@SignImgName,GETDATE(),@FileSetID
		END
	END

	----SELECT @ExistingPersonId = PersonID, @ExistingPersonType= PersonType
	----FROM tblPDAMaster P INNER JOIN tblPDA_UserMapMaster M ON P.PDAId=M.PDAId
	----WHERE P.PDA_IMEI = @IMEINo OR P.PDA_IMEI_Sec=@IMEINo AND (GETDATE() BETWEEN M.DateFrom AND ISNULL(M.DateTo,GETDATE()))

	----IF @ExistingPersonId<>@PersonNodeId
	----BEGIN
	----	IF NOT EXISTS(SELECT 1 FROM tblPDA_UserMapMaster WHERE PersonID=@PersonNodeId AND (GETDATE() BETWEEN DateFrom AND ISNULL(DateTo,GETDATE())))
	----	BEGIN
	----		UPDATE tblPDA_UserMapMaster SET DateTo=DATEADD(dd,-1,GETDATE()) WHERE PDAId=@PDAId AND PersonID=@ExistingPersonId AND PersonType=@ExistingPersonType

	----		INSERT INTO tblPDA_UserMapMaster(PDAID,PersonID,PersonType,DateFrom,DateTo)
	----		SELECT @PDAId,@PersonNodeId,@PersonNodeType,GETDATE(),'31-Dec-2049'

	----		SELECT NodeID,NodeType INTO #AssignedAreas FROM tblSalesPersonMapping 
	----		WHERE PersonNodeID=@ExistingPersonId AND PersonType=@ExistingPersonType AND (GETDATE() BETWEEN FromDate AND ToDate)

	----		UPDATE A SET ToDate=DATEADD(dd,-1,GETDATE()) FROM tblSalesPersonMapping A --INNER JOIN #AssignedAreas B ON A.NodeID=B.NodeID AND A.NodeType=B.NodeType 
	----		WHERE A.PersonNodeID=@ExistingPersonId AND PersonType=@ExistingPersonType AND (GETDATE() BETWEEN FromDate AND ToDate)
			
	----		INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,FromDate,ToDate)
	----		SELECT @PersonNodeId,@PersonNodeType,A.NodeID,A.NodeType,GETDATE(),'31-Dec-2049'
	----		FROM #AssignedAreas A LEFT OUTER JOIN tblSalesPersonMapping B ON A.NodeID=B.NodeID AND A.NodeType=B.NodeType AND B.PersonNodeID=@PersonNodeId AND B.PersonType=@PersonNodeType
	----		WHERE B.PersonNodeID IS NULL AND B.PersonType IS NULL AND B.NodeID IS NULL AND B.NodeType IS NULL


	----		-- Update the Van Assigment also
	----		DECLARE @VanLoadUnLoadCycID INT
	----		SELECT @VanLoadUnLoadCycID=VanLoadUnLoadCycID FROM [tblVanStockMaster] WHERE SalesManNodeId=@ExistingPersonId AND SalesManNodeType=@ExistingPersonType AND CAST(TransDate AS DATE)=CAST(GETDATE() AS DATE)

	----		UPDATE [dbo].[tblVanStockMaster] SET SalesManNodeId=@PersonNodeId,SalesManNodeType=@PersonNodeType WHERE VanLoadUnLoadCycID=@VanLoadUnLoadCycID


	----	END

	----END
END
