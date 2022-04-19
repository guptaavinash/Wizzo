
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 24 Nov 2016
-- Description:	
-- =============================================
CREATE procEDURE [dbo].[SpSaveStoreInformation] 
	@StoreIDDB INT,
	@PaymentStage [PaymentStage] readonly
AS
BEGIN
	DECLARE @OrgStoreID INT,@StoreIDPDA VARCHAR(50)
	DECLARE @GrpQuestID INT,@QstID INT,@AnsControlTypeID SMALLINT,@AnsValId VARCHAR(50),@AnsTextVal VARCHAR(MAX),@Optionvalue varchar(50),
	@CompetitorBrandID INT

	--- Data Fields
	
 DECLARE  @StoreTypeID INT,@StrStoreSpecialityID VARCHAR(100), @OutletName VARCHAR(500),@Ownername VARCHAR(500),@Mob BIGINT,@TaxNumber VARCHAR(20),@SalesPersonName VARCHAR(50),@SalesPersonContact BIGINT,
	@Address VARCHAR(200),@BillAddress1 VARCHAR(MAX),@BillCity VARCHAR(500),@BillPinCode BIGINT,@BillState VARCHAR(200)
DECLARE @PaymentStageMode TINYINT

	SET @StrStoreSpecialityID=''
	SELECT * INTO #tblPDAStoreMaster FROM tblPDASyncStoreMappingMstr P WHERE P.StoreIDDB=@StoreIDDB AND ISNULL(P.flgStoreValidated,0)=0
	SELECT * INTO #tblPDAStoreMasterDet FROM tblPDASyncStoreattributeDet P WHERE P.StoreIDDB=@StoreIDDB 

	SELECT * INTO #tblPDAStoreMasterTemp FROM dbo.tblPDAOutletQstResponseMaster R WHERE R.StoreIDDB=@StoreIDDB

	SELECT @StoreIDPDA=StoreID,@BillCity=City,@BillPinCode=PinCode,@BillState=State FROM #tblPDAStoreMaster	
	--AND ActualLatitude>0 
	DECLARE @OptionID INT,@NodeID INT,@NodeType SMALLINT
	DECLARE CurStoreData CURSOR
					FOR SELECT StoreIDDB,GrpQuestID,QstID,AnsControlTypeID,AnsValId,AnsTextVal,Optionvalue FROM #tblPDAStoreMasterTemp
	OPEN CurStoreData
	FETCH NEXT FROM CurStoreData
	INTO @StoreIDDB,@GrpQuestID,@QstID,@AnsControlTypeID,@AnsValId,@AnsTextVal,@Optionvalue
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF EXISTS (SELECT 1 FROM tblDynamic_PDAQuestMstr WHERE AnsSourceTypeID IN (1,2) AND QuestID=@QstID)
		BEGIN
			PRINT 'MM'
			SELECT @OptionID=SUBSTRING(@AnsValId,0,PATINDEX('%-%',@AnsValId))
			SELECT @NodeID=SUBSTRING(@AnsValId,PATINDEX('%-%',@AnsValId)+1,PATINDEX('%-%',SUBSTRING(@AnsValId,PATINDEX('%-%',@AnsValId)+1,LEN(@AnsValId)))-1)
			SELECT @NodeType=SUBSTRING(REVERSE(@AnsValId),0,PATINDEX('%-%',REVERSE(@AnsValId)))
			PRINT 'NN'
		END

		IF @GrpQuestID= 1 SELECT @StoreTypeID=@NodeID
		ELSE IF @GrpQuestID=2 
		BEGIN
			SELECT @StrStoreSpecialityID=@StrStoreSpecialityID + CAST(@NodeID AS VARCHAR) + '^' 
		END
		
		ELSE IF @GrpQuestID= 3 SELECT @OutletName=@AnsTextVal
		ELSE IF @GrpQuestID=4 SELECT @Ownername=@AnsTextVal
		ELSE IF @GrpQuestID=5 SELECT @Mob=CAST(@AnsTextVal AS BIGINT)
		ELSE IF @GrpQuestID=6 SELECT @TaxNumber=@AnsTextVal
		ELSE IF @GrpQuestID=7 SELECT @Address=@AnsTextVal
		ELSE IF @GrpQuestID=8 SELECT @SalesPersonName=@AnsTextVal
		ELSE IF @GrpQuestID=9 SELECT @SalesPersonContact=@AnsTextVal

		FETCH NEXT FROM CurStoreData
		INTO @StoreIDDB,@GrpQuestID,@QstID,@AnsControlTypeID,@AnsValId,@AnsTextVal,@Optionvalue
	END
	CLOSE CurStoreData
	DEALLOCATE CurStoreData

	DECLARE @RouteNodeID INT
	DECLARE @RouteNodeType SMALLINT
	DECLARE @DBRID INT
	DECLARE @DBRNodeType SMALLINT

	SELECT @RouteNodeID=RouteID,@RouteNodeType=RouteNodeType FROM #tblPDAStoreMaster WHERE StoreIDDB=@StoreIDDB
	Declare @HierTypeId tinyint=0
	select @HierTypeId=HierTypeId from tblSecMenuContextMenu where NodeType=@RouteNodeType
	
	SELECT @OrgStoreID=StoreID FROM tblStoremaster S WHERE StoreIDPDA=@StoreIDPDA
	IF ISNULL(@OrgStoreID,0)=0
	BEGIN
		PRINT 'YY'
		--SELECT @OutletName,@StoreTypeID,ActualLatitude,ActualLongitude,Imei,LocProvider,Accuracy,GETDATE(),StoreID,StoreMapAddress,City,PinCode,State,0,StoreIDDB,GETDATE(),GETDATE(),1,Address,Distance,AllProviderData,GPSLatitude,GPSLongitude,GPSAccuracy,GPSAddress,NetworkLatitude,NetworkLongitude,NetworkAccuracy,NetworkAddress,FusedLatitude,FusedLongitude,FusedAccuracy,FusedAddress,flgLocationServicesOnOff,flgGPSOnOff,flgNetworkOnOff,flgFusedOnOff,flgInternetOnOffWhileLocationTracking,flgRestart,1 
		--FROM #tblPDAStoreMaster

		INSERT INTO tblStoremaster(StoreName,StoreChannelID,[Lat Code],[Long Code],[Loc Provider],IMEINo,Accuracy,TimeStampIns,StoreIDPDA,Storemapaddress,MapCity,MapPincode,MapState,LoginIDIns,StoreIDDB,createddate,ApprovedDate,flgValidated,Address,Distance,AllProviderData,GPSLatitude,GPSLongitude,GPSAccuracy,GPSAddress,NetworkLatitude,NetworkLongitude,NetworkAccuracy,NetworkAddress,FusedLatitude,FusedLongitude,FusedAccuracy,FusedAddress,flgLocationServicesOnOff,flgGPSOnOff,flgNetworkOnOff,flgFusedOnOff,flgInternetOnOffWhileLocationTracking,flgRestart,flgApproved,DBID,DBNodeType)

		SELECT @OutletName,@StoreTypeID,ActualLatitude,ActualLongitude,LocProvider,Imei,Accuracy,GETDATE(),StoreID,StoreMapAddress,City,PinCode,State,0,StoreIDDB,GETDATE(),GETDATE(),0,Address,Distance,AllProviderData,GPSLatitude,GPSLongitude,GPSAccuracy,GPSAddress,NetworkLatitude,NetworkLongitude,NetworkAccuracy,NetworkAddress,FusedLatitude,FusedLongitude,FusedAccuracy,FusedAddress,flgLocationServicesOnOff,flgGPSOnOff,flgNetworkOnOff,flgFusedOnOff,flgInternetOnOffWhileLocationTracking,flgRestart,0,DistributorID,DistributorType
		FROM #tblPDAStoreMaster

		SELECT @OrgStoreID=@@IDENTITY
	END
	ELSE
	BEGIN
	PRINT 'XX'
		UPDATE S SET StoreName=@OutletName,StoreChannelID=@StoreTypeID,[Lat Code]=ActualLatitude,[Long Code]=ActualLongitude,IMEINo=Imei,[Loc Provider]=LocProvider,Accuracy=P.Accuracy,TimeStampUpd=GETDATE(),StoreMapAddress=P.StoreMapAddress,MapCity=City,MapPincode=PinCode,MapState=State,Address=P.Address,Distance=P.Distance,AllProviderData=P.AllProviderData,GPSLatitude=P.GPSLatitude,GPSLongitude=P.GPSLongitude,GPSAccuracy=P.GPSAccuracy,GPSAddress=P.GPSAddress,NetworkLatitude=P.NetworkLatitude,NetworkLongitude=P.NetworkLongitude,NetworkAccuracy=P.NetworkAccuracy,NetworkAddress=P.NetworkAddress,DBID=DistributorID,DBNodeType=DistributorType
		FROM tblStoremaster S INNER JOIN #tblPDAStoreMaster P ON P.StoreID=@StoreIDPDA WHERE S.StoreID=@OrgStoreID
	END 	
	PRINT 'AA'
	-- Incuding Store in the route plan
	IF ISNULL(@OrgStoreID,0)>0
	BEGIN
		IF NOT EXISTS (SELECT RouteID FROM tblRouteCoverageStoreMapping WHERE StoreID=@OrgStoreID AND ISNULL(@RouteNodeID,0)<>0)
			BEGIN
				INSERT INTO tblRouteCoverageStoreMapping(RouteID,StoreID,FRomdate,ToDate,RouteNodeType,LoginIDIns)
				SELECT @RouteNodeID,@OrgStoreID,GETDATE(),'31-Dec-2049',@RouteNodeType,1
			END
	END

	-- Adding/Updating the store Type##########################################################################################################################
	IF ISNULL(@OrgStoreID,0)>0
	BEGIN
		DELETE FROM [dbo].[tblStoreTypeDet] WHERE StoreID=@OrgStoreID
		INSERT INTO [tblStoreTypeDet](StoreID,StoretypeID)
		SELECT @OrgStoreID,StoreSpcID FROM tblPDASyncStoreSpecialityType WHERE StoreIDDB=@StoreIDDB
	END

	--##############################################################################################################################################################
	-- Updating StoreOtherbasic details #############################################################################################################################
	PRINT 'BB'
	IF ISNULL(@OrgStoreID,0)>0
	BEGIN
		UPDATE S SET TaxNumber=D.TaxNumber,OutletSalesPersonname=D.OutletSalesPersonname,OutletSalesPersonContact=D.OutletSalesPersonContact,Address=D.Address FROM tblStoremaster S INNER JOIN #tblPDAStoreMasterDet D ON D.StoreIDDB=S.StoreIDDB  WHERE S.StoreID=@OrgStoreID
	END

	---################################################################################################################################################################
	
	------- Adding/Updating the chain into master list ----@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	----DECLARE @OutChainID INT
	----SET @OutChainID=0
	----IF ISNULL(@OrgStoreID,0)>0
	----BEGIN
	----	SELECT OutChainID FROM tblOutletChainMaster WHERE ChainName=@FirmName
	----	IF ISNULL(@OutChainID,0)=0
	----	BEGIN
	----		INSERT INTO tblOutletChainMaster(ChainName,NodeType,flgActive,Timestamp_Ins)
	----		SELECT @FirmName,70,1,GETDATE()

	----		SELECT @OutChainID=@@IDENTITY

	----		UPDATE tblStoreMaster SET OutChainId=@OutChainID FROM tblStoreMaster WHERE StoreID=@OrgStoreID
	----	END
	----	ELSE
	----	BEGIN
	----		UPDATE tblStoreMaster SET OutChainId=@OutChainID FROM tblStoreMaster WHERE StoreID=@OrgStoreID
	----	END
	----END
	-------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			
	
	-- Store Contact Details
	DECLARE @ContType TINYINT
	SET @ContType=1  --Owner Information
	IF ISNULL(@ContType,0)>0
	BEGIN
		----DECLARE @OutCnctPersonID INT
		----SELECT  @OutCnctPersonID=[OutCnctPersonID] FROM [dbo].[tblOutletContactDet] WHERE StoreID=@OrgStoreID
		----IF ISNULL(@OutCnctPersonID,0)>0
		----BEGIN
		----	DELETE FROM [tblOutletContactDet] WHERE StoreID=@OrgStoreID
		----END
		IF NOT EXISTS (SELECT 1 FROM tblOutletContactDet WHERE StoreID=@OrgStoreID AND OutCnctpersonTypeID=@ContType)
		BEGIN
			PRINT 'CC'
			INSERT INTO [tblOutletContactDet](StoreID,OutCnctpersonTypeID,ContactType,FName,MobNo)
			SELECT  @OrgStoreID,StoreCnctPersonTypeID,@ContType,Ownername,OwnerMobNo FROM [tblPDASyncContDet] INNER JOIN tblStoreContactTypeMstr SC ON SC.ContactType=@ContType WHERE StoreIDDB=@StoreIDDB
		END
		ELSE
		BEGIN
			PRINT 'CC1'
			UPDATE C SET FName=D.Ownername,MobNo=D.OwnerMobNo FROM [tblPDASyncContDet] D INNER JOIN tblOutletContactDet C ON C.StoreID=@OrgStoreID WHERE C.OutCnctpersonTypeID=@ContType AND D.StoreIDDB=@StoreIDDB
		END
	END
	
	PRINT '@OrgStoreID=' + CAST(@OrgStoreID AS VARCHAR)
	DECLARE @OutAddTypeID INT
	SET @OutAddTypeID=1
	IF NOT EXISTS (SELECT 1 FROM tblOutletAddressDet WHERE StoreID=@OrgStoreID AND OutAddTypeID=@OutAddTypeID)
	BEGIN
		PRINT 'XX1'
		INSERT INTO [tblOutletAddressDet](StoreID,[OutAddTypeID],[StoreAddress1],City,[Pincode],State)
		SELECT @OrgStoreID,@OutAddTypeID,@Address,City,Pincode,State FROM tblPDASyncAddressDet M WHERE M.StoreIDDB=@StoreIDDB
	END
	ELSE
	BEGIN	
		PRINT 'YY1'
		UPDATE U SET StoreAddress1=M.Address,City=M.City,Pincode=M.PinCode,State=M.State FROM tblOutletAddressDet U INNER JOIN tblStoreMaster S ON S.StoreID=U.StoreID INNER JOIN tblPDASyncAddressDet M ON M.StoreIDDB=S.StoreIDDB WHERE S.StoreID=@OrgStoreID AND U.OutAddTypeID=@OutAddTypeID
	END
	
	DELETE FROM tblStoreImages WHERE StoreID=@OrgStoreID		
	INSERT INTO tblStoreImages(StoreImageTypeId,StoreID,StoreImagename,ImageType,flgManagerUploaded)
	SELECT B.StoreImageTypeId,@OrgStoreID,A.StoreImagename,A.ImageType,A.flgManagerUploaded
	FROM tblPDASyncStoreImages A INNER JOIN tblStoreImageTypeMstr B ON A.ImageType=B.ImageType
	WHERE A.StoreIDDB=@StoreIDDB AND B.ChannelId=1

	UPDATE P Set OrgStoreID=@OrgStoreID FROM tblPDASyncStoreMappingMstr P WHERE StoreIDDB=@StoreIDDB

	--- Update flgApproved=1 for other than hotel and MT ###################################################################################################################
	--UPDATE S SET flgApproved=1 FROM tblStoreMaster S WHERE StoreID=@OrgStoreID AND @OutletChannel IN (5)
	----IF EXISTS (SELECT 1 FROM @PaymentStage WHERE [PymtStageId]=3)
	----BEGIN
	----	UPDATE S SET flgApproved=0 FROM tblStoreMaster S WHERE StoreID=@OrgStoreID
	----END
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


	--Declare @PaymentStage PaymentStage
	--insert into @PaymentStage values(2,100,0,0,'2|4')
		Delete A FROM tblStorePaymentStageMap A Left join @PaymentStage B 
on A.PymtStageId=b.PymtStageId
WHERE A.StoreId=@OrgStoreID AND B.PymtStageId is null 


Declare @Date date=Getdate()
Delete from tblStorePaymentStageMap where StoreId=@OrgStoreID and FromDate=@Date
Update tblStorePaymentStageMap set ToDate=DateAdd(dd,-1,@Date) where StoreId=@OrgStoreID and @Date between FromDate and ToDate

insert into tblStorePaymentStageMap(StoreId,PymtStageId,Percentage,CreditDays,CreditLimit,FromDate,ToDate,PrdNodeId,PrdNodeType,InvoiceSettlementType,CreditPeriodType,GracePeriodinDays)
select @OrgStoreID,PymtStageId,Percentage,CreditDays,CreditLimit,@Date,'31-Dec-2050',0,0,case when [CreditPeriodTypeId]>1 then 2 else CreditPeriodTypeId end,CreditPeriodTypeId,[GracePeriodInDays]  from @PaymentStage

Delete A FROM [tblStorePaymentModeMap] A Left join tblStorePaymentStageMap B 
on A.StorePaymentStageMappingId=b.StorePaymentStageMappingId
WHERE b.StorePaymentStageMappingId IS NULL

insert into [tblStorePaymentModeMap]
select distinct b.StorePaymentStageMappingId,@OrgStoreID,c.items from @PaymentStage A join tblStorePaymentStageMap B on A.PymtStageId=B.PymtStageId
cross apply dbo.split(A.PymtMode,'|') c
WHERE B.StoreId=@OrgStoreID and @Date between B.FromDate and B.ToDate
AND c.items<>''

----insert into tblStoreOpeningBalanceInfo
----select A.storeId,0,@Date from tblstoremaster A left join tblStoreOpeningBalanceInfo B on A.STOREiD=B.STOREID where A.storeId=@OrgStoreId
----AND B.STOREID IS NULL



----update A set PymtStageId=B.PymtStageId,Percentage=B.Percentage,CreditDays=B.CreditDays,CreditLimit=B.CreditLimit  from tblOrderPaymentStageMap A join tblOrderMaster C on C.OrderId=A.OrderId cross join @PaymentStage B
----WHERE C.StoreId=@OrgStoreID
----and not exists(select orderid from tblorderconfirmmaster where orderid=c.orderid)

set @Date=DateAdd(dd,-1,@Date)
--exec [spUpdateStoreAccountStatusByStoreId] @OrgStoreID,@Date

--exec spUpdateStoreAccountStatus_Current @DBRID,@DBRNodeType

END



