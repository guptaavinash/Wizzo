-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--DROP PROC [SpSavePotentialDistributor]
--GO
CREATE PROCEDURE [dbo].[SpSaveStoreDetails] 
	@FileSetID INT,
	@PDACode VARCHAR(100),
	@RouteNodeID INT,
	@RouteNodeType SMALLINT,
	@CustomerNodeID INT,
	@CustomerNodeType SMALLINT,
	@LatCode NUMERIC(27,24),
	@LongCode NUMERIC(27,24),
	@CustomerIDPDA VARCHAR(100),
	@CustomerName VARCHAR(100),
	@FatherORSpouse VARCHAR(200),
	@DOB DATE,
	@Gender VARCHAR(20),
	@ShopType SMALLINT,
	@ContactPersonName VARCHAR(100),
	@ContactPersonMobNo BIGINT,
	@ConatctPersonEMailID VARCHAR(100),
	@Telephonenumber VARCHAR(100),
	@Address VARCHAR(500),
	@PinCode BIGINT,
	@City VARCHAR(100),
	@District VARCHAR(100),
	@State VARCHAR(200),
	@Address_Owner VARCHAR(200),
	@Pincode_Owner BIGINT,
	@City_Owner VARCHAR(200),
	@District_Owner VARCHAR(100),
	@State_Owner VARCHAR(100),
	@FirmType TINYINT, -- 1=Proprieter,2=Partner
	@IsGSTSubmitted TINYINT,
	@GSTNumber VARCHAR(100),
	@IsPanSubmited SMALLINT,
	@PanNumber VARCHAR(20),
	@IsAadharSubmitted SMALLINT,
	@AadharNumber VARCHAR(20),
	@IsElectricBillSubmitted SMALLINT,
	@ElectricBillNumber VARCHAR(20),
	@IsVoterIDSubmitted SMALLINT,
	@VoterIDNumber VARCHAR(20),
	@StoreMapAddress VARCHAR(500),
	@StoreMapPinCode VARCHAR(10),
	@StoreMapCity VARCHAR(100),
	@StoreMapState VARCHAR(100),
	@CreatedDate Date ,
	@StoreImages udt_Image ReadOnly
AS
BEGIN
	DECLARE @DBNodeID INT
	DECLARE @DBNodeType SMALLINT
	DECLARE @CovAreaNodeID INT
	DECLARE @CovAreaNodeType SMALLINT
	
	SET @IsPanSubmited=CASE WHEN @IsPanSubmited<0 THEN NULL ELSE @IsPanSubmited END
	SET @IsAadharSubmitted=CASE WHEN @IsAadharSubmitted<0 THEN NULL ELSE @IsAadharSubmitted END
	SET @IsElectricBillSubmitted=CASE WHEN @IsElectricBillSubmitted<0 THEN NULL ELSE @IsElectricBillSubmitted END
	SET @IsVoterIDSubmitted=CASE WHEN @IsVoterIDSubmitted<0 THEN NULL ELSE @IsVoterIDSubmitted END
	


	DECLARE @PersonID INT   
	DECLARE @PersonType INT
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	SELECT @CovAreaNodeID=CovAreaNodeId,@CovAreaNodeType=CovAreaNodeType,@DBNodeID=DM.DHNodeID,@DBNodeType=DM.DHNodeType FROM tblRoutePlanningMstr RP INNER JOIN tblCompanySalesStructure_DistributorMapping DM ON DM.SHNodeID=RP.CovAreaNodeId AND DM.SHNodeType=RP.CovAreaNodeType WHERE @CreatedDate BETWEEN RP.FromDate AND RP.ToDate AND @CreatedDate BETWEEN DM.FromDate AND DM.ToDate AND RouteNodeId=@RouteNodeID AND RouteNodeType=@RouteNodeType

	IF @CustomerNodeID=0
		SELECT @CustomerNodeID=StoreID FROM tblStoreMaster WHERE StoreIDPDA=@CustomerIDPDA

	IF @CustomerNodeID=0
	BEGIN
		INSERT INTO tblStoreMaster(StoreName,[Lat Code],[Long Code],flgActive,TimeStampIns,ChannelId,FileSetIdIns,ShopType,IMEINo,StoreMapAddress,MapCity,MapPincode,MapState,CreatedDate,StoreIDPDA,FirmType,IsGSTSubmitted,GSTNumber,IsPanSubmitted,PanNumber,IsAadharSubmitted,AadharNumber,IsElectricityBillSubmitted,ElectricityBillNumber,IsVoterIDSubmitted,VoterIDNumber,DBID,DBNodeType)
		SELECT    @CustomerName,@LatCode,@LongCode,1,GETDATE(),1,@FileSetID,@ShopType,@PDACode,@StoreMapAddress,@StoreMapCity,@StoreMapPinCode,@StoreMapState,@CreatedDate,@CustomerIDPDA,@FirmType,@IsGSTSubmitted,@GSTNumber,@IsPanSubmited,@PanNumber,@IsAadharSubmitted,@AadharNumber,@IsElectricBillSubmitted,@ElectricBillNumber,@IsVoterIDSubmitted,@VoterIDNumber,1,150

		SELECT @CustomerNodeID=@@IDENTITY

		UPDATE S SET StoreCode='Wizzo-' + CAST((1000000 + StoreID) AS VARCHAR) FROM tblStoreMaster S WHERE StoreID=@CustomerNodeID
	END
	ELSE
	BEGIN
		UPDATE S SET StoreName=@CustomerName,[Lat Code]=@LatCode,[Long Code]=@LongCode,FileSetIdUpd=@FileSetID,ShopType=@ShopType,IMEINo=@PDACode,StoreMapAddress=@StoreMapAddress,MapPincode=@StoreMapPinCode,MapCity=@StoreMapCity,MapState=@StoreMapState,CreatedDate=@CreatedDate,FirmType=@FirmType,IsGSTSubmitted=@IsGSTSubmitted,GSTNumber=@GSTNumber,IsPanSubmitted=@IsPanSubmited,PanNumber=@PanNumber,IsAadharSubmitted=@IsAadharSubmitted,AadharNumber=@AadharNumber,IsElectricityBillSubmitted=@IsElectricBillSubmitted,ElectricityBillNumber=@ElectricBillNumber,IsVoterIDSubmitted=@IsVoterIDSubmitted,VoterIDNumber=@VoterIDNumber FROM tblStoreMaster S WHERE StoreID=@CustomerNodeID
	END

	IF ISNULL(@CustomerNodeID,0)>0 AND NOT EXISTS(SELECT 1 FROM tblOutletContactDet WHERE StoreID=@CustomerNodeID)
	BEGIN
		INSERT INTO tblOutletContactDet(OutCnctpersonTypeID,ContactType,StoreID,FName,MobNo,EMailID,IsSameWhatsappnumber,alternatewhatsappNo)
		SELECT 1,1,@CustomerNodeID,@ContactPersonName,@ContactPersonMobNo,@ConatctPersonEMailID,0,NULL

		INSERT INTO tblOutletAddressDet(OutAddTypeID,StoreID,StoreAddress1,City,Pincode,State,Landmark,CityID,StateID)
		SELECT 1,@CustomerNodeID,@Address,@City,@PinCode,@State,NULL,NULL,NULL
		UNION
		SELECT 2,@CustomerNodeID,@Address,@City,@PinCode,@State,NULL,NULL,NULL
		UNION
		SELECT 3,@CustomerNodeID,@Address_Owner,@City_Owner,@Pincode_Owner,@State_Owner,NULL,NULL,NULL

		INSERT INTO tblRouteCoverageStoreMapping(RouteID,StoreID,FromDate,ToDate,LoginIDIns,RouteNodeType)
		SELECT @RouteNodeID,@CustomerNodeID,GETDATE(),'31-Dec-2049',1,@RouteNodeType
			
	END
	
	IF ISNULL(@CustomerNodeID,0)>0 AND EXISTS (SELECT 1 FROM @StoreImages)
	BEGIN
		DELETE B FROM tblStoreImages B WHERE StoreID=@CustomerNodeID
		INSERT INTO tblStoreImages (StoreID,ImageType,StoreImagename)
		SELECT @CustomerNodeID,ImgType,ImageName FROM @StoreImages
	END


	

		DECLARE @flgStatus INT
		SET @flgStatus=1
		
		SELECT @flgStatus flgStatus
	
END
