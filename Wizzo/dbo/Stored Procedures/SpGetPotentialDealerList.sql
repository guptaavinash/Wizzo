-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- SpGetPotentialDealerList '5CB9A130-C681-4CF4-8D04-5FCEC7F13EE2'
CREATE PROCEDURE [dbo].[SpGetPotentialDealerList] 
	@PDACode VARCHAR(100)
AS
BEGIN
	DECLARE @PersonID INT   
	DECLARE @PersonType INT
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	CREATE TABLE #CoverageArea(NodeID INT,NodeType SMALLINT)

	IF @PersonType IN (220,230)
	BEGIN
		INSERT INTO  #CoverageArea
		SELECT DISTINCT P.NodeID,P.NodeType  
		FROM tblSalesPersonMapping P     
		INNER JOIN [dbo].[tblSecMenuContextMenu] S ON S.NodeType=P. NodeType     
		WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) AND S.flgCoverageArea=1
	END
	ELSE IF @PersonType=210
		INSERT INTO  #CoverageArea
		SELECT DISTINCT V.DSRAreaID,V.DSRAreaNodeType  
		FROM tblSalesPersonMapping P INNER JOIN [dbo].[VwCompanySalesHierarchy] V ON V.ASMAreaID=P.NodeID AND V.ASMAreaNodeType=P.NodeType 
		WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))

	SELECT NodeID,Nodetype,REPLACE(dbo.fnGetWorkingTypeForCoverageArea(NodeID,NodeType),0,2) WorkingTypeID INTO #WorkingType FROM #CoverageArea

	

	--SELECT TOP 2 * FROM tblDBRSalesStructureDBR

	--flgViewOrEdit --2 View , 1=Edit

	SELECT NodeID,NodeType,[Lat Code] AS LatCode,[Long Code] AS LongCode,[Descr] AS DistributorName,[Contact Person Name] AS  ContactPersonName,[Contact Person Mobile Number] As ContactPersonMobNo,[Contact Person EMailID] AS ConatctPersonEMailID,[Telephone No] AS Telephonenumber,AreaCovered,[No Of Retailers Covered] AS NoOFRetailersCovered,[Godown Area(sq/ft)] AS GodownArea,[Monthly TurnOver] AS MonthlyTurnOver,VehicleType AS VehicleTypeID,[No Of Vehicles] AS NoOFVehicles,OrderTATinDays,[CompanyProductInvestment(Lacs)] AS CompanyProductInvestment,RetailerCreditLimit,BusinessSince,DistributorReady,NextFollowupDate,DBREmployee_Dispatch AS NoEmployee_Dispatch,DBREmployee_Billing AS NoEmployee_Billing,DBREmployee_SalesStaff AS NoEmployee_SalesStaff,[Address],[Pincode],[City],[District],[State],IsOldDistributorReplaced,IsOldDistributorDFinalPaymentDone,[flgDistributor/SS] AS flgDistributorSS,IsNewLocation,[flgTownDistributor/SubD] AS flgTownDistributorSubD,Address_Godown,Pincode_Godown,City_Godown,District_Godown,State_Godown,[flgProprietor/Partner] AS flgProprietorPartner,BankAccountNumber,IFSCCode,BankAddress,[ExpectedBusiness(In Tons)] AS ExpectedBusiness,[ReqGodownSpace(Sq/ft)] AS ReqGodownSpace,[AgreedGodownSpace(Sq/ft)] AS AgreedGodownSpace,[AgreedInvestment(Lacs)] AS AgreedInvestment,IdealROI,ExpectedROI,IsCheckGiven,ChequeNumber,IsGSTDetailsSubmitted,GSTNumber,IsProprietorPanSubmited,ProprietorPanNumber,IsPartnerDeedSubmitted,IsPartner1PanSubmitted,PanNumber_Partner1,IsPartner2PanSubmitted,PanNumber_Partner2	
	,[EntryPersonNodeID],[EntryPersonNodeType],[CreatedDate],3 NoOfRetilersSection,1 AS flgViewOrEdit,ISNULL(flgAppointed,0) flgAppointed,0 AS flgExistingDBR,IsFirmPanSubmitted AS IsPANOfFirmSubmitted,PanNumber_Firm AS PANNoOfFirm,OldDistributorID,flgAtLocation AS LocationCapturedFrom,PartnerDeednumber
	INTO #Distributor FROM tblPotentialDistributor WHERE EntryPersonNodeID=@PersonID AND EntryPersonNodeType=@PersonType AND ISNULL(flgInActive,0)=0
	UNION
	SELECT DISTINCT F.DBRNodeID,F.DBRNodeType,LatCode,LongCode,DBR.Descr,ContactPerson,MobileNo,EmailId,PhoneNo,AreaCovered,NoOFRetailersCovered,GodownArea,MonthlyTurnOver,VehicleTypeID,NoOFVehicles,OrderTATinDays,CompanyProductInvestment,RetailerCreditLimit,BusinessSince,DistributorReady,NextFollowupDate,NoEmployee_Dispatch,NoEmployee_Billing,NoEmployee_SalesStaff,Address1,PinCode,City,City,StateName,IsOldDistributorReplaced,IsOldDistributorDFinalPaymentDone,flgDistributorSS,IsNewLocation,flgTownDistributorSubD,Address_Godown,Pincode_Godown,City_Godown,District_Godown,State_Godown,flgProprietorPartner,BankAcNo,IFSCCode,BankAdd,
	
	ExpectedBusiness,ReqGodownSpace,AgreedGodownSpace,AgreedInvestment,IdealROI,ExpectedROI,IsCheckGiven,ChequeNumber,IsGSTDetailsSubmitted,GSTNumber,IsProprietorPanSubmited,ProprietorPanNumber,IsPartnerDeedSubmitted,IsPartner1PanSubmitted,PanNumber_Partner1,IsPartner2PanSubmitted,PanNumber_Partner2,0,0,TimestampIns,3,1,1,1,IsFirmPanSubmitted AS IsPANOfFirmSubmitted,PanNumber_Firm AS PANNoOfFirm,0,flgAtLocation AS LocationCapturedFrom,PartnerDeednumber
	FROM #WorkingType C CROSS Apply dbo.[fnGetDistributorList](C.NodeID,C.NodeType,GETDATE()) F   INNER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=F.DBRNodeId AND DBR.NodeType=F.DBRNodetype 
	WHERE C.WorkingTypeID=2 

	--UPDATE D SET flgViewOrEdit=2 FROM #Distributor D INNER JOIN tblPotentialDistributorRetailerDet R ON R.DBNodeID=D.NodeID AND R.DBNodeType=D.NodeType

	--SELECT * FROM tblSalesPersonMapping WHERE PersonNodeID=@PersonID AND PersonType=@PersonType and ToDate>GETDATE()



	SELECT * FROM #Distributor
	SELECT NodeID,NodeType,CompetitorCompanyID,OtherCompanyCode,OtherCompany,[SalesValue(Lacs)] SalesValue_Lacs FROM tblPotentialDistributor_CompetitorCompany
	SELECT * FROM tblPotentialDistributor_CompetitorBrand

	SELECT * FROM tblCompetitorCompanyMstr
	SELECT * FROM tblCompetitorBrandMstr
	SELECT * FROM tblVehicleTypeMstr

	SELECT R.* FROM tblPotentialDistributorRetailerDet R INNER JOIN tblPotentialDistributor D ON D.NodeID=R.DBNodeID AND R.DBNodeType=D.NodeType WHERE EntryPersonNodeID=@PersonID AND EntryPersonNodeType=@PersonType AND ISNULL(flgAppointed,0)=0 AND ISNULL(flgInActive,0)=0

	SELECT * FROM tblPotentialDistributorImages

END
