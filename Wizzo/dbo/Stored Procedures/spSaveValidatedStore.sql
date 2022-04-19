-- =============================================
-- Author:		<Gaurav Gupta>
-- Create date: <Create Date,,>
-- Description:	<to move/update store details into final tables when store gets approved>
-- =============================================
--[spSaveValidatedStore]1710,1
CREATE PROCEDURE [dbo].[spSaveValidatedStore]
@StoreIDDB INT, -- ID from PDASync Table
@FlgValidated TINYINT
AS
BEGIN
	DECLARE @StoreId INT
	DECLARE @RouteNodeType INT
	DECLARE @RouteId INT
	DECLARE @DBId INT
	DECLARE @DBNodeType INT
	DECLARE @StorePaymentStageMappingId INT

	SELECT @RouteId=RouteId,@RouteNodeType=RouteNodeType FROM tblPDASyncStoreMappingMstr WHERE StoreIDDB=@StoreIDDB

	----IF @RouteNodeType=170
	----BEGIN
	----	SELECT @DBId=DBRNodeID ,@DBNodeType=DistributorNodeType  FROM vwAllDistributorHierarchy WHERE DBRRouteId=@RouteId
	----END
	IF @RouteNodeType=140
	BEGIN
		SELECT @DBId=Map.DHNodeID ,@DBNodeType=Map.DHNodeType  
		FROM VwSalesHierarchyFull vw INNER JOIN tblCompanySalesStructure_DistributorMapping Map ON vw.ComCoverageAreaID=Map.SHNodeID AND vw.ComCoverageAreaType=Map.SHNodeType 
		INNER JOIN tblCompanySalesStructureHierarchy H ON H.PNodeID=VW.ComCoverageAreaID AND H.PNodeType=Vw.ComCoverageAreaType
		WHERE H.NodeID=@RouteId AND H.NodeType=@RouteNodeType AND (GETDATE() BETWEEN Map.FromDate AND Map.ToDate) AND DHNodeType=150
	END

	IF EXISTS(SELECT 1 FROM tblStoreMaster	WHERE StoreIdDB=@StoreIDDB)
	BEGIN
		SELECT @StoreId=StoreId FROm tblStoreMaster WHERE StoreIdDB=@StoreIDDB

		UPDATE SM SET SM.StoreName=M.OutletName,SM.[Lat Code]=M.ActualLatitude,SM.[Long Code]=M.ActualLongitude, SM.IMEINo=M.Imei,SM.TimeStampIns=M.VisitEndTS,SM.StoreMapAddress=M.StoreMapAddress,SM.MapCity=M.City,SM.MapPincode=M.PinCode,SM.MapState=M.[State],SM.TimeStampUpd=GETDATE(),SM.DBID=DistributorID,SM.DBNodeType=DistributorType,SM.flgApproved=@FlgValidated,SM.TaxNumber=A.TaxNumber,SM.CreatedDate=M.CreateDate,
		SM.ContactNo=CD.OwnerMobNo,SM.ContactPerson=CD.Ownername
		FROM tblStoreMaster SM INNER JOIN tblPDASyncStoreMappingMstr M ON SM.StoreIDDB=M.StoreIDDB
		LEFT JOIN tblPDASyncStoreattributeDet A ON M.StoreIDDB=A.StoreIDDB
		LEFT JOIN tblPDASyncContDet CD ON CD.StoreIDDB=M.StoreIDDB
		WHERE SM.StoreID=@StoreId

		UPDATE A SET A.StoreAddress1=B.[Address] ,A.Landmark=B.Landmark ,A.City=B.City , A.Pincode=B.Pincode ,A.State=B.State,A.CityId=B.CityId,A.StateID=B.StateID
		FROM tblOutletAddressDet A, tblPDASyncAddressDet B 
		WHERE A.StoreId=@StoreId AND B.StoreIDDB=@StoreIDDB AND A.OutAddTypeID IN(1,2)

		--DELETE FROM tblStoreSurveyDet WHERE StoreID=@StoreId
		DELETE FROM tblStoreImages WHERE StoreID=@StoreId
		DELETE FROM tblOutletContactDet WHERE StoreID=@StoreId
		--DELETE FROM tblOutletAddressDet WHERE StoreID=@StoreId
		--DELETE FROM tblStoreProductSurveyDet WHERE StoreID=@StoreId
		DELETE FROM tblStorePaymentStageMap WHERE StoreID=@StoreId
		DELETE FROM tblStorePaymentModeMap WHERE StoreID=@StoreId
	END
	ELSE
	BEGIN
		INSERT INTO tblStoreMaster(StoreName,StoreCode,[Lat Code],[Long Code],IMEINo,TimeStampIns,StoreMapAddress,MapCity,MapPincode,MapState,StoreIDDB, CreatedDate,ApprovedDate,DBID,DBNodeType,DistNodeId,DistNodeType,flgApproved,StoreIDPDA,ChannelId,SubChannelId,SegmentationID,TAxNUmber,ContactNo,ContactPerson)
		SELECT M.OutletName,('AX_RAJ'+CONVERT([varchar],(1000000) +LEFT(CAST(RAND()*1000000000+999999 AS INT),6))),M.ActualLatitude,M.ActualLongitude,M.Imei,M.VisitEndTS,M.StoreMapAddress,M.City,M.PinCode,M.[State],M.StoreIDDB,M.CreateDate,GETDATE(),DistributorID,DistributorType,DistributorID,DistributorType,@FlgValidated,M.StoreID,A.OutletChannelID,A.OutletTypeID,A.OutletClassID,TaxNumber,CD.OwnerMobNo,CD.Ownername
		FROM tblPDASyncStoreMappingMstr M LEFT JOIN tblPDASyncStoreattributeDet A ON M.StoreIDDB=A.StoreIDDB
		LEFT JOIN tblPDASyncContDet CD ON CD.StoreIDDB=M.StoreIDDB
		WHERE M.StoreIDDB=@StoreIDDB

		Set @StoreId = SCOPE_IDENTITY() 
		
		--UPDATE S SET SToreCode=('AX_RAJ'+CONVERT([varchar],(1000000)+[Storeid])) FROM tblStoreMaster S WHERE StoreID=@StoreId

		UPDATE tblPDASyncStoreMappingMstr SET OrgStoreId=@StoreId WHERE StoreIDDB=@StoreIDDB

		INSERT INTO tblRouteCoverageStoreMapping(RouteID,StoreID,FromDate,ToDate,LoginIDIns,RouteNodeType)
		SELECT RouteID,@StoreId,GETDATE(),'31-Dec-2049',1,RouteNodeType
		FROM tblPDASyncStoreMappingMstr
		WHERE StoreIDDB=@StoreIDDB AND RouteID IS NOT NULL 

		----INSERT INTO tblStoreOpeningBalanceInfo
		----VALUES(@StoreId,0,GETDATE())

		INSERT INTO tblOutletAddressDet(OutAddTypeID,StoreID,StoreAddress1,City,Pincode,State,Landmark,CityID,StateID)
		SELECT 1,@StoreId,[Address],City,Pincode,State,Landmark,CityId,StateID
		FROM tblPDASyncAddressDet
		WHERE StoreIDDB=@StoreIDDB
		UNION
		SELECT 2,@StoreId,[Address],City,Pincode,State,Landmark,CityId,StateID
		FROM tblPDASyncAddressDet
		WHERE StoreIDDB=@StoreIDDB
		
	END

	----INSERT INTO tblStoreSurveyDet(StoreID,ApplicableDate,IsOurProduct,IsDBBilled)
	----SELECT @StoreId,M.VisitEndTS,A.IsOurProduct,A.IsDBBilled
	----FROM tblPDASyncStoreMappingMstr M LEFT JOIN tblPDASyncStoreattributeDet A ON M.StoreIDDB=A.StoreIDDB
	----WHERE M.StoreIDDB=@StoreIDDB

	DELETE FROM tblStoreImages WHERE StoreID=@StoreId		
	INSERT INTO tblStoreImages(StoreImageTypeId,StoreID,StoreImagename,ImageType,flgManagerUploaded)
	SELECT B.StoreImageTypeId,@StoreId,A.StoreImagename,A.ImageType,A.flgManagerUploaded
	FROM tblPDASyncStoreImages A INNER JOIN tblStoreImageTypeMstr B ON A.ImageType=B.ImageType
	WHERE A.StoreIDDB=@StoreIDDB AND B.ChannelId=1

	----INSERT INTO tblStoreImages(StoreID,StoreImagename,ImageType,flgManagerUploaded)
	----SELECT @StoreId,StoreImagename,ImageType,flgManagerUploaded
	----FROM tblPDASyncStoreImages
	----WHERE StoreIDDB=@StoreIDDB

	INSERT INTO tblOutletContactDet(OutCnctpersonTypeID,ContactType,StoreID,FName,MobNo,EMailID,IsSameWhatsappnumber,alternatewhatsappNo)
	SELECT 1,1,@StoreId,Ownername,OwnerMobNo,OwnerEmailID,A.IsSameWhatsappnumber,A.alternatewhatsappNo
	FROM tblPDASyncContDet C INNER JOIN tblPDASyncStoreattributeDet A ON A.StoreIDDB=C.StoreIDDB
	WHERE C.StoreIDDB=@StoreIDDB

	


	IF EXISTS(SELECT 1 FROm tblPDASyncStorePaymentStageMap WHERE StoreIDDB=@StoreIDDB)
	BEGIN
		INSERT INTO tblStorePaymentStageMap(StoreId,PymtStageId,Percentage,CreditDays,CreditLimit,FromDate,ToDate,PrdNodeId,PrdNodeType,InvoiceSettlementType,CreditPeriodType, GracePeriodinDays)
		SELECT DISTINCT @StoreId,PymtStageId,Percentage,CreditDays,CreditLimit,FromDate,ToDate,PrdNodeId,PrdNodeType,InvoiceSettlementType,CreditPeriodType, GracePeriodinDays
		FROM tblPDASyncStorePaymentStageMap
		WHERE StoreIDDB=@StoreIDDB

		IF NOT EXISTS(SELECT 1 FROM [tblPDASyncStorePaymentModeMap] WHERE StoreIDDB=@StoreIDDB AND PaymentModeId>0) 
		BEGIN	-- when no mode is available, insert default options for Cash & Checque
			INSERT INTO tblStorePaymentModeMap(StorePaymentStageMappingId,StoreId,PaymentModeId)
			SELECT StorePaymentStageMappingId,@StoreId,2
			FROM tblStorePaymentStageMap WHERE StoreId=@StoreId
			UNION
			SELECT StorePaymentStageMappingId,@StoreId,4
			FROM tblStorePaymentStageMap WHERE StoreId=@StoreId
		END
		ELSE
		BEGIN
			INSERT INTO tblStorePaymentModeMap(StorePaymentStageMappingId,StoreId,PaymentModeId)
			SELECT B.StorePaymentStageMappingId,@StoreId,A.PaymentModeId
			FROM [tblPDASyncStorePaymentModeMap] A,tblStorePaymentStageMap B
			WHERE A.StoreIDDB=@StoreIDDB AND A.PaymentModeId>0 AND B.StoreId=@StoreId
		END
	END

	--added by gaurav to get StoreId while calling this SP from MR Store saving SP
	IF object_id('tempdb..#tmpOrgStoreId') is not null
	BEGIN
		INSERT INTO #tmpOrgStoreId(OrgStoreId) VALUES(@StoreId)
	END
	UPDATE O SET O.RegionId=PR.PrcRgnNodeId FROM tblStoremaster O INNER JOIN tblOutletAddressDet A ON A.StoreID=O.StoreID INNER JOIN tblPriceRegionMstr PR ON PR.StateID=A.StateID
	UPDATE tblStoremaster SET flgValidated=@FlgValidated WHERE StoreID=@StoreId  --- Store auto approve.
	
END
