-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--DROP PROC [SpSavePotentialDistributor]
--GO
CREATE PROCEDURE [dbo].[SpSavePotentialDistributor] 
	@PDACode VARCHAR(100),
	@NodeID INT,
	@NodeType SMALLINT,
	@NewDBRCode VARCHAR(100),
	@DistributorName VARCHAR(100),
	@LatCode NUMERIC(27,24),
	@LongCode NUMERIC(27,24),
	@ContactPersonName VARCHAR(100),
	@ContactPersonMobNo BIGINT,
	@ConatctPersonEMailID VARCHAR(100),
	@Telephonenumber VARCHAR(100),
	@AreaCovered VARCHAR(500),
	@NoOFRetailersCovered INT,
	@GodownArea INT,
	@MonthlyTurnOver INT,
	@VehicleTypeID SMALLINT,
	@NoOFVehicles INT,
	@OrderTATindays INT,
	@CompanyProductInvestment INT,
	@RetailerCreditLimit INT,
	@BusinessSince INT,
	@DistributorReady SMALLINT,
	@NextFollowupDate Date,
	@NoEmployee_Dispatch INT,
	@NoEmployee_Billing INT,
	@NoEmployee_SalesStaff INT,
	@Address VARCHAR(500),
	@PinCode BIGINT,
	@City VARCHAR(100),
	@District VARCHAR(100),
	@State VARCHAR(200),
	@IsOldDistributorReplaced SMALLINT,
	@IsOldDistributorDFinalPaymentDone SMALLINT,
	@flgDistributorSS SMALLINT,
	@IsNewLocation SMALLINT,
	@flgTownDistributorSubD SMALLINT,
	@Address_Godown VARCHAR(200),
	@Pincode_Godown BIGINT,
	@City_Godown VARCHAR(200),
	@District_Godown VARCHAR(100),
	@State_Godown VARCHAR(100),
	@flgProprietorPartner SMALLINT,
	@BankAccountNumber VARCHAR(20),
	@IFSCCode VARCHAR(20),
	@BankAddress VARCHAR(500),
	@ExpectedBusiness INT,
	@ReqGodownSpace INT,
	@AgreedGodownSpace INT,
	@AgreedInvestment INT,
	@IdealROI INT,
	@ExpectedROI INT,
	@IsCheckGiven SMALLINT,
	@ChequeNumber VARCHAR(20),
	@IsGSTDetailsSubmitted SMALLINT,
	@GSTNumber VARCHAR(20),
	@IsProprietorPanSubmited SMALLINT,
	@ProprietorPanNumber VARCHAR(20),
	@IsPartnerDeedSubmitted SMALLINT,
	@IsPartner1PanSubmitted SMALLINT,
	@PanNumber_Partner1 VARCHAR(20),
	@IsPartner2PanSubmitted SMALLINT,
	@PanNumber_Partner2 VARCHAR(20),
	@tblCompetitorCompany udt_CompetitorCompany READONLY,
	@tblCompetitorBrand udt_CompetitorBrand READONLY,
	@tblDistributorImages udt_PotentialDistributorImage READONLY,
	@flgAppointed SMALLINT,
	@OldDistributorID INT,
	@PartnerDeedNUmber VARCHAR(20),
	@flgAtLocation TINYINT, --1=Office,2=Godown,3=Other
	@IsFirmPanSubmitted SMALLINT,
	@PanNumber_Firm VARCHAR(20)

AS
BEGIN
	SELECT @IsOldDistributorReplaced=CASE WHEN @IsOldDistributorReplaced<0 THEN NULL ELSE @IsOldDistributorReplaced END
	SET @DistributorReady=CASE WHEN @DistributorReady<0 THEN NULL ELSE @DistributorReady END
	SET @IsOldDistributorDFinalPaymentDone=CASE WHEN @IsOldDistributorDFinalPaymentDone<0 THEN NULL ELSE @IsOldDistributorDFinalPaymentDone END
	SET @flgDistributorSS=CASE WHEN @flgDistributorSS<0 THEN NULL ELSE @flgDistributorSS END
	SET @IsNewLocation=CASE WHEN @IsNewLocation<0 THEN NULL ELSE @IsNewLocation END
	SET @flgTownDistributorSubD=CASE WHEN @flgTownDistributorSubD<0 THEN NULL ELSE @flgTownDistributorSubD END
	SET @flgProprietorPartner=CASE WHEN @flgProprietorPartner<0 THEN NULL ELSE @flgProprietorPartner END
	SET @IsCheckGiven=CASE WHEN @IsCheckGiven<0 THEN NULL ELSE @IsCheckGiven END
	SET @IsGSTDetailsSubmitted=CASE WHEN @IsGSTDetailsSubmitted<0 THEN NULL ELSE @IsGSTDetailsSubmitted END
	SET @IsProprietorPanSubmited=CASE WHEN @IsProprietorPanSubmited<0 THEN NULL ELSE @IsProprietorPanSubmited END
	SET @IsPartnerDeedSubmitted=CASE WHEN @IsPartnerDeedSubmitted<0 THEN NULL ELSE @IsPartnerDeedSubmitted END
	SET @IsPartner1PanSubmitted=CASE WHEN @IsPartner1PanSubmitted<0 THEN NULL ELSE @IsPartner1PanSubmitted END
	SET @IsPartner2PanSubmitted=CASE WHEN @IsPartner2PanSubmitted<0 THEN NULL ELSE @IsPartner2PanSubmitted END
	SET @IsFirmPanSubmitted=CASE WHEN @IsFirmPanSubmitted<0 THEN NULL ELSE @IsFirmPanSubmitted END
	SET @flgAppointed=CASE WHEN @flgAppointed<0 THEN NULL ELSE @flgAppointed END


	DECLARE @PersonID INT   
	DECLARE @PersonType INT
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	IF @NOdeID=0
		SELECT @NOdeID=NodeID FROM tblPotentialDistributor WHERE DBRCode=@NewDBRCode

	IF @NodeID=0
	BEGIN
		INSERT INTO tblPotentialDistributor(DBRCode,[Lat Code],[Long Code],Descr,[Contact Person Name],[Contact Person Mobile Number],[Contact Person EMailID],[Telephone No],AreaCovered,[No Of Retailers Covered],[Godown Area(sq/ft)],[Monthly TurnOver],VehicleType,[No Of Vehicles],OrderTATinDays,[CompanyProductInvestment(Lacs)],RetailerCreditLimit,BusinessSince,DistributorReady,NextFollowupDate,DBREmployee_Dispatch,DBREmployee_Billing,DBREmployee_SalesStaff,Address,Pincode,City,District,State,IsOldDistributorReplaced,IsOldDistributorDFinalPaymentDone,[flgDistributor/SS],IsNewLocation,[flgTownDistributor/SubD],Address_Godown,Pincode_Godown,City_Godown,District_Godown,State_Godown,[flgProprietor/Partner],BankAccountNumber,IFSCCode,BankAddress,[ExpectedBusiness(In Tons)],[ReqGodownSpace(Sq/ft)],[AgreedGodownSpace(Sq/ft)],[AgreedInvestment(Lacs)],IdealROI,ExpectedROI,IsCheckGiven,ChequeNumber,IsGSTDetailsSubmitted,GSTNumber,IsProprietorPanSubmited,ProprietorPanNumber,IsPartnerDeedSubmitted,IsPartner1PanSubmitted,PanNumber_Partner1,IsPartner2PanSubmitted,PanNumber_Partner2,		
		EntryPersonNodeID,EntryPersonNodeType,CreatedDate,flgAppointed,PartnerDeedNumber,OLDDistributorID,flgAtLocation,IsFirmPanSubmitted,PanNumber_Firm)
		SELECT @NewDBRCode,@LatCode,@LongCode,@DistributorName,@ContactPersonName,@ContactPersonMobNo,@ConatctPersonEMailID,@Telephonenumber,@AreaCovered,@NoOFRetailersCovered,@GodownArea,@MonthlyTurnOver,@VehicleTypeID,@NoOFVehicles,@OrderTATindays,@CompanyProductInvestment,@RetailerCreditLimit,@BusinessSince,@DistributorReady,@NextFollowupDate,@NoEmployee_Dispatch,@NoEmployee_Billing,@NoEmployee_SalesStaff,@Address,@PinCode,@City,@District,@State,
		
@IsOldDistributorReplaced,@IsOldDistributorDFinalPaymentDone,@flgDistributorSS,@IsNewLocation,@flgTownDistributorSubD,@Address_Godown,@Pincode_Godown,@City_Godown,@District_Godown,@State_Godown,@flgProprietorPartner,@BankAccountNumber,@IFSCCode,@BankAddress,@ExpectedBusiness,@ReqGodownSpace,@AgreedGodownSpace,@AgreedInvestment,@IdealROI,@ExpectedROI,@IsCheckGiven,@ChequeNumber,@IsGSTDetailsSubmitted,@GSTNumber,@IsProprietorPanSubmited,@ProprietorPanNumber,@IsPartnerDeedSubmitted,@IsPartner1PanSubmitted,@PanNumber_Partner1,@IsPartner2PanSubmitted,@PanNumber_Partner2,		
		@PersonID,@PersonType,GETDATE(),@flgAppointed,@PartnerDeedNUmber,@OldDistributorID,@flgAtLocation,@IsFirmPanSubmitted,@PanNumber_Firm

		SELECT @NodeID=@@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE D SET [Lat Code]=@LatCode,[Long Code]=@LongCode,Descr=@DistributorName,[Contact Person Name]=@ContactPersonName,[Contact Person Mobile Number]=@ContactPersonMobNo,[Contact Person EMailID]=@ConatctPersonEMailID,[Telephone No]=@Telephonenumber,GSTNumber=@GSTNumber,AreaCovered=@AreaCovered,[No Of Retailers Covered]=@NoOFRetailersCovered,[Godown Area(sq/ft)]=@GodownArea,[Monthly TurnOver]=@MonthlyTurnOver,VehicleType=@VehicleTypeID,[No Of Vehicles]=@NoOFVehicles,OrderTATinDays=@OrderTATindays,[CompanyProductInvestment(Lacs)]=@CompanyProductInvestment,RetailerCreditLimit=@RetailerCreditLimit,BusinessSince=@BusinessSince,DistributorReady=@DistributorReady,NextFollowupDate=@NextFollowupDate,DBREmployee_Billing=@NoEmployee_Billing,DBREmployee_Dispatch=@NoEmployee_Dispatch,DBREmployee_SalesStaff=@NoEmployee_SalesStaff,Address=@Address,Pincode=@PinCode,City=@City,District=@District,State=@State,IsOldDistributorReplaced=@IsOldDistributorReplaced,IsOldDistributorDFinalPaymentDone=@IsOldDistributorDFinalPaymentDone,[flgDistributor/SS]=@flgDistributorSS,IsNewLocation=@IsNewLocation,flgAppointed=@flgAppointed,OldDistributorID=@OldDistributorID,flgAtLocation=@flgAtLocation,PartnerDeednumber=@PartnerDeedNUmber,[flgProprietor/Partner]=@flgProprietorPartner,IsCheckGiven=@IsCheckGiven,IsGSTDetailsSubmitted=@IsGSTDetailsSubmitted,IsProprietorPanSubmited=@IsProprietorPanSubmited,
		[flgTownDistributor/SubD]=@flgTownDistributorSubD,Address_Godown=@Address_Godown,Pincode_Godown=@Pincode_Godown,City_Godown=@City_Godown,District_Godown=@District_Godown,State_Godown=@State_Godown,BankAccountNumber=@BankAccountNumber,IFSCCode=@IFSCCode,BankAddress=@BankAddress,[ExpectedBusiness(In Tons)]=@ExpectedBusiness,[ReqGodownSpace(Sq/ft)]=@ReqGodownSpace,[AgreedGodownSpace(Sq/ft)]=@AgreedGodownSpace,[AgreedInvestment(Lacs)]=@AgreedInvestment,IdealROI=@IdealROI,ExpectedROI=@ExpectedROI,ChequeNumber=@ChequeNumber,ProprietorPanNumber=@ProprietorPanNumber,IsPartnerDeedSubmitted=@IsPartnerDeedSubmitted,PanNumber_Partner1=@PanNumber_Partner1,IsPartner2PanSubmitted=@IsPartner2PanSubmitted,PanNumber_Partner2=@PanNumber_Partner2,IsPartner1PanSubmitted=@IsPartner1PanSubmitted,IsFirmPanSubmitted=@IsFirmPanSubmitted,PanNumber_Firm=@PanNumber_Firm
		FROM tblPotentialDistributor D WHERE NodeID=@NodeID AND NodeType=@NodeType 
	END

	IF ISNULL(@NodeID,0)>0 AND EXISTS (SELECT 1 FROM @tblCompetitorCompany)
	BEGIN
		DELETE C FROM tblPotentialDistributor_CompetitorCompany C WHERE NodeID=@NodeID AND NodeType=@NodeType
		INSERT INTO tblPotentialDistributor_CompetitorCompany(NodeID,NodeType,CompetitorCompanyID,OtherCompanyCode,OtherCompany,[SalesValue(Lacs)]) 
		SELECT @NodeID,@NodeType,CompetitorCompanyID,OtherCompanyCode,OtherCompany,[SalesValue(Lacs)] FROM @tblCompetitorCompany
	END

	IF ISNULL(@NodeID,0)>0 AND EXISTS (SELECT 1 FROM @tblCompetitorBrand)
	BEGIN
		DELETE B FROM tblPotentialDistributor_CompetitorBrand B WHERE NodeID=@NodeID AND NodeType=@NodeType
		INSERT INTO tblPotentialDistributor_CompetitorBrand (NodeID,NodeType,CompetitorBrandID,OtherBrandCode,OtherBrand)
		SELECT @NodeID,@NodeType,CompetitorBrandID,[OtherBrandCode],OtherBrand FROM @tblCompetitorBrand
	END

	IF ISNULL(@NodeID,0)>0 AND EXISTS (SELECT 1 FROM @tblDistributorImages)
	BEGIN
		DELETE B FROM tblPotentialDistributorImages B WHERE NodeID=@NodeID AND NodeType=@NodeType
		INSERT INTO tblPotentialDistributorImages (NodeID,NodeType,ImageType,ImageName)
		SELECT @NodeID,@NodeType,ImageType,ImageName FROM @tblDistributorImages
	END

	IF @PersonType=210
		UPDATE D SET flgFinalSubmit=1 FROM tblPotentialDistributor D WHERE NodeID=@NodeID AND NodeType=@NodeType

	--SELECT @NodeID NodeID,180 NodeType

		DECLARE @flgStatus INT
		SET @flgStatus=1
		
		SELECT @flgStatus flgStatus
	
END
