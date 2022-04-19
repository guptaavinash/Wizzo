
--DROP PROC  spPDA_Save_StoreMappingDetails_SFA
CREATE PROCEDURE [dbo].[spPDA_Save_StoreMappingDetails_SFA]  
@StoreID nvarchar(100), -- It can be key from PDA or Storeid from store master  
@VisitStartTS Datetime,  
@VisitEndTS Datetime,  
@AppVersion INT,  
@ActualLatitude decimal(30, 27),  
@ActualLongitude decimal(30, 27),  
@LocProvider varchar(20),  
@Accuracy varchar (100),  
@BatteryStatus varchar(10),  
@Imei varchar (100),  
@XMLFullDate varchar (100),  
@XMLReceiveDate Datetime,		
@OutStat int,  
@tblQuestAns udtResponse Readonly , 
@PaymentStage [PaymentStage] readonly,
@StoreMapAddress VARCHAR(2000)  ='',
@City VARCHAR(200),
@PinCode BIGINT,
@State VARCHAR(200),
@StoreImages udt_Image ReadOnly,
@tblGPSInfo udt_GPSInfo ReadOnly,
@flgLocationServicesOnOff TINYINT,
@flgGPSOnOff TINYINT,
@flgNetworkOnOff TINYINT,
@flgFusedOnOff TINYINT,
@flgInternetOnOff TINYINT,
@flgRestart TINYINT,
@Address VARCHAR(200),
@MapCity VARCHAR(200),
@MapState VARCHAR(200),
@MapPinCode BIGINT,
@CityID INT,
@StateID INT,
@FileSetID	int

AS  
BEGIN  
 Declare @StoreIDDB int 
 DECLARE @PersonNodeId INT=0
 DECLARE @PersonNodeType INT=0
 DECLARE @PDAID INT=0
 
 SELECT @PersonNodeID=NodeID,@PersonNodeType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@Imei) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
 ----SELECT @PDAID=PDAID FROM tblPDAMaster WHERE PDA_IMEI=@Imei OR PDA_IMEI_Sec=@Imei

 ----IF @PDAID>0
 ----BEGIN
	----SELECT @PersonNodeId=PersonID,@PersonNodeType=PersonType FROM tblPDA_UserMapMaster WHERE PDAID=@PDAID AND (GETDATE() BETWEEN DateFrom AND DateTo)
 ----END

 PRINT '@PersonNodeId=' + CAST(@PersonNodeId AS VARCHAR)
 PRINT '@PersonNodeType=' + CAST(@PersonNodeType AS VARCHAR)

 
  
 SET @StoreIDDB=0  
 Declare @VisitSTS datetime  
 SET @VisitSTS=@VisitStartTS
 --Set @VisitSTS = CONVERT(datetime,dbo.fncGetDateFromString(SUBSTRING(@VisitStartTS,1,10))+ SUBSTRING(@VisitStartTS,11,Len(@VisitStartTS)))  
   
 Declare @VisitETS datetime 
  SET @VisitETS=@VisitEndTS 
 --Set @VisitETS = CONVERT(datetime,dbo.fncGetDateFromString(SUBSTRING(@VisitEndTS,1,10))+ SUBSTRING(@VisitEndTS,11,Len(@VisitEndTS)))  
   
 PRINT '@XMLReceiveDate=' + CAST(@XMLReceiveDate  AS VARCHAR)  
 Declare @XMLRecDate datetime
 Set @XMLRecDate =CONVERT(Date,@XMLReceiveDate,105)
   Set @XMLRecDate =@XMLReceiveDate
 --Set @XMLRecDate = CONVERT(datetime,dbo.fncGetDateFromString(SUBSTRING(@XMLReceiveDate,1,10))+ SUBSTRING(@XMLReceiveDate,11,Len(@XMLReceiveDate)))  


  --- Code added to check the Van Details for the Person ######################################################################################################
 DECLARE @VanID INT
 DECLARE @VanNodeType SMALLINT

 SELECT @VanID=VanID,@VanNodeType=260 FROM tblVanStockMaster WHERE SalesManNodeId=@PersonNodeId AND SalesManNodeType=@PersonNodeType AND CAST(TransDate AS DATE)=CAST(@VisitSTS AS DATE)
 PRINT '@VanID=' + CAST(@VanID AS VARCHAR)
 PRINT '@VanNodeType=' + CAST(@VanNodeType AS VARCHAR)

 IF ISNULL(@VanID,0)=0
 BEGIN
	SELECT @VanID=VanID,@VanNodeType=VanNodeType FROM [dbo].[tblSalesHierVanMapping] SV INNER JOIN tblSalesPersonMapping SP ON SP.NodeID=SV.SalesNodeID AND SV.SalesNodetype=SP.NodeType WHERE GETDATE() BETWEEN CAST(SP.FromDate AS DATE) AND CAST(SP.ToDate AS DATE) AND GETDATE() BETWEEN CAST(SV.FromDate AS DATE) AND CAST(SV.ToDate AS DATE) AND SP.PersonNodeID=@PersonNodeId AND SP.PersonType=@PersonNodeType
 END


 --#############################################################################################################################################################
  
   
 --PRINT '@XMLRecDate=' + CAST(@XMLRecDate  AS VARCHAR)  
 SELECT @StoreIDDB=StoreIDDB FROM tblPDASyncStoreMappingMstr WHERE StoreID=@StoreID
 IF PATINDEX('%-%', @StoreID)<=0
  SELECT @StoreIDDB=StoreIDDB FROM tblPDASyncStoreMappingMstr WHERE StoreIDDB=CAST(@StoreID AS INT)
 
  -- TO find out the default route
 DECLARE @AnsValId VARCHAR(200),@OptionID INT,@RouteID INT,@RouteNodeType SMALLINT
 SELECT @AnsValId=AnsValID FROM @tblQuestAns WHERE QstID=14

SELECT @OptionID=SUBSTRING(@AnsValId,0,PATINDEX('%-%',@AnsValId))
SELECT @RouteID=SUBSTRING(@AnsValId,PATINDEX('%-%',@AnsValId)+1,PATINDEX('%-%',SUBSTRING(@AnsValId,PATINDEX('%-%',@AnsValId)+1,LEN(@AnsValId)))-1)
SELECT @RouteNodeType=SUBSTRING(@AnsValId,LEN(@AnsValId) - CHARINDEX('-',REVERSE(@AnsValId)) +2,LEN(@AnsValId))  

DECLARE @DBNodeID INT,@DBNodeType SMALLINT
SELECT @DBNodeID=DBRNodeID,@DBNodeType=DBRNodeType FROM [dbo].[fnGetDistributorList](@RouteID,@RouteNodeType,@VisitSTS)
  
 IF ISNULL(@StoreIDDB,0)>0  
 BEGIN  
	  INSERT INTO tblPDASyncStoreMappingMstr_History
	  SELECT * FROM tblPDASyncStoreMappingMstr WHERE StoreIDDB=@StoreIDDB
	  UPDATE P SET VisitStartTS=@VisitSTS,VisitEndTS=@VisitETS,AppVersion=@AppVersion,ActualLatitude=@ActualLatitude,ActualLongitude=@ActualLongitude,  
	  LocProvider=@LocProvider,Accuracy=@Accuracy,BatteryStatus=@BatteryStatus,Imei=@Imei,XMLFullDate=@XMLFullDate,XMLReceiveDate=CAST(@XMLRecDate AS DATETIME),OutStat=@OutStat,  
	  RouteID=@RouteID,RouteNodeType=@RouteNodeType,Storemapaddress=@StoreMapAddress,City=@City,PinCode=@PinCode,State=@State,[CityID]=@CityID,[StateID]=@StateID,flgStoreValidated=CASE @PersonNodeType WHEN 220 THEN 1 ELSE 0 END,PersonId=@PersonNodeId,PersonType=@PersonNodeType
	  FROM tblPDASyncStoreMappingMstr P WHERE StoreIDDB=@StoreIDDB   
 END  
 ELSE  
 BEGIN  
	  INSERT INTO tblPDASyncStoreMappingMstr(StoreID,VisitStartTS,VisitEndTS,AppVersion,ActualLatitude,ActualLongitude,LocProvider,Accuracy,BatteryStatus,Imei,  
	  XMLFullDate,XMLReceiveDate,OutStat,RouteID,RouteNodeType,StoreMapAddress,City,PinCode,State,PersonId,PersonType,flgStoreValidated,DistributorID,DistributorType,[CityID],[StateID],VanNodeID,VanNodeType,FileSetID,CreateDate)  
	  Values  
	  (@StoreID ,@VisitSTS,@VisitETS,@AppVersion, @ActualLatitude ,@ActualLongitude,@LocProvider ,@Accuracy ,@BatteryStatus,@Imei ,@XMLFullDate,CAST(@XMLRecDate AS DATETIME),@OutStat,@RouteID,@RouteNodeType,@StoreMapAddress, @City,@PinCode,@State,@PersonNodeId,@PersonNodeType,CASE @PersonNodeType WHEN 220 THEN 1 ELSE 0 END,@DBNodeID,@DBNodeType,@CityID,@StateID,@VanID,@VanNodeType,@FileSetID,@VisitEndTS)  
   
	 Set @StoreIDDB = SCOPE_IDENTITY()  
 END  

IF EXISTS(SELECT 1 FROM @tblGPSInfo)
	BEGIN
		UPDATE P SET Address=T.Address,Distance=T.Distance,AllProviderData=T.AllProviderData,GPSLatitude=T.GPSLatitude,GPSLongitude=T.GPSLongitude,GPSAccuracy=T.GPSAccuracy,
		  GPSAddress=T.GPSAddress,NetworkLatitude=T.NetworkLatitude,NetworkLongitude=T.NetworkLongitude,NetworkAccuracy=T.NetworkAccuracy,NetworkAddress=T.NetworkAddress,	  FusedLatitude=T.FusedLatitude,FusedLongitude=T.FusedLongitude,FusedAccuracy=T.FusedAccuracy,FusedAddress=T.FusedAddress,flgLocationServicesOnOff=@flgLocationServicesOnOff,flgGPSOnOff=@flgGPSOnOff,flgNetworkOnOff=@flgNetworkOnOff,flgFusedOnOff=@flgFusedOnOff,flgInternetOnOffWhileLocationTracking=@flgInternetOnOff,flgRestart=@flgRestart,DistributorID=@DBNodeID,DistributorType=@DBNodeType,VanNodeID=@VanID,VanNodeType=@VanNodeType
		  FROM tblPDASyncStoreMappingMstr P INNER JOIN @tblGPSInfo T ON T.StoreID=P.StoreID WHERE StoreIDDB=@StoreIDDB
	END 
   
   Declare @Date date=Getdate()
   PRINT '@StoreIDDB=' + CAST(@StoreIDDB AS VARCHAR) 
 IF ISNULL(@StoreIDDB,0)>0  
 BEGIN  
	--SELECT * FROM @tblQuestAns  
	PRINT '@StoreIDDB=' + CAST(@StoreIDDB AS VARCHAR)  
	INSERT INTO tblPDAOutletQstResponseMaster_History
	SELECT * FROM tblPDAOutletQstResponseMaster WHERE StoreIDDB=@StoreIDDB

	DELETE FROM tblPDAOutletQstResponseMaster WHERE StoreIDDB=@StoreIDDB  
	INSERT INTO tblPDAOutletQstResponseMaster(StoreIDDB,GrpQuestID,QstId,AnsControlTypeID,AnsValId,AnsTextVal,TimeStampIn,Optionvalue)  
	SELECT @StoreIDDB,[GrpQuestID],[QstID],[AnsControlTypeID],[AnsValID],[AnsTextVal],GETDATE(),optionvalue FROM @tblQuestAns  
	
 END  

  IF ISNULL(@StoreIDDB,0)>0  
 BEGIN 
	INSERT INTO tblPDASyncStoreImages_History
	SELECT * FROM tblPDASyncStoreImages WHERE StoreIDDB=@StoreIDDB

	IF EXISTS(SELECT 1 FROM @StoreImages)
	BEGIN
		DELETE FROM tblPDASyncStoreImages WHERE StoreIDDB=@StoreIDDB  
		INSERT INTO tblPDASyncStoreImages(StoreIDDB,StoreImagename,ImageType)
		SELECT @StoreIDDB,Imagename,ImgType FROM @StoreImages
	END
 END

    
 DECLARE @GrpQuestID INT  
 DECLARE @QuestID INT  
 DECLARE @AnsControlTypeID INT  
 DECLARE @AnswerType INT  
 DECLARE @AnswerValID VARCHAR(200)  
 DECLARE @AnswerValue VARCHAR(1000) 

DECLARE @NodeID INT,@NodeType SMALLINT

 DECLARE @StoreTypeID INT,@StoreClassID INT, @OutletName VARCHAR(500),@Ownername VARCHAR(500),@Mob BIGINT,@TaxNumber VARCHAR(20),@SalesPersonName VARCHAR(50),@SalesPersonContact BIGINT,
	@BillAddress1 VARCHAR(MAX),@BillCity VARCHAR(500),@BillPinCode BIGINT,@BillState VARCHAR(200),@IsGSTCompliance TINYINT,@GTSNumber VARCHAR(50),@IsWhatsappNoSame TINYINT,@WhatsappNo BIGINT,@EMailID VARCHAR(200),@STDNo VARCHAR(10),@Landline BIGINT
DECLARE @PaymentStageMode TINYINT,@UPIID VARCHAR(100),@ChannelID INT

 -- SET  @StrStoreClassID=''
 DECLARE CurQuest CURSOR  
  FOR SELECT [GrpQuestID],QstID,[AnsControlTypeID],[AnsValID],[AnsTextVal] FROM @tblQuestAns  
 OPEN CurQuest  
 FETCH NEXT FROM CurQuest  
 INTO @GrpQuestID,@QuestID,@AnsControlTypeID,@AnswerValID,@AnswerValue  
 WHILE @@FETCH_STATUS=0  
 BEGIN  
		PRINT '@GrpQuestID=' + CAST(@GrpQuestID AS VARCHAR)
		SET @OptionID=0
		SET @NodeID=0
		SET @NodeType=0
		--SET @Landline=NULL
		IF EXISTS (SELECT 1 FROM tblDynamic_PDAQuestMstr WHERE AnsSourceTypeID IN (1,2) AND QuestID=@QuestID)
		BEGIN
			SELECT @OptionID=SUBSTRING(@AnswerValID,0,PATINDEX('%-%',@AnswerValID))
			SELECT @NodeID=SUBSTRING(@AnswerValID,PATINDEX('%-%',@AnswerValID)+1,PATINDEX('%-%',SUBSTRING(@AnswerValID,PATINDEX('%-%',@AnswerValID)+1,LEN(@AnswerValID)))-1)
			SELECT @NodeType=SUBSTRING(@AnswerValID,LEN(@AnswerValID) - CHARINDEX('-',REVERSE(@AnswerValID)) +2,LEN(@AnswerValID)) 
		END
		 
		PRINT '@GrpQuestID=' + CAST(@GrpQuestID AS VARCHAR) + '@OptionID=' + CAST(@OptionID AS VARCHAR) + '@NodeID=' + CAST(@NodeID AS VARCHAR) + '@NodeType=' + CAST(@NodeType AS VARCHAR)

		IF @GrpQuestID= 1 SELECT @ChannelID=@NodeID
		ELSE IF @GrpQuestID= 15 
		BEGIN
			SELECT @DBNodeID=@NodeID
			SELECT @DBNodeType=@NodeType
		END
		ELSE IF @GrpQuestID=8
		BEGIN
			SELECT @StoreTypeID=@NodeID
		END
		ELSE IF @GrpQuestID=18 
		BEGIN
			SELECT @StoreClassID=@NodeID
		END
		
		ELSE IF @GrpQuestID= 2 SELECT @OutletName=@AnswerValue
		ELSE IF @GrpQuestID=3 SELECT @Ownername=@AnswerValue
		ELSE IF @GrpQuestID=4 SELECT @Mob=CAST(@AnswerValue AS BIGINT)
		--ELSE IF @GrpQuestID=6 SELECT @TaxNumber=@AnswerValue
		ELSE IF @GrpQuestID=6 SELECT @Address=@AnswerValue
		--ELSE IF @GrpQuestID=8 SELECT @SalesPersonName=@AnswerValue
		--ELSE IF @GrpQuestID=9 SELECT @SalesPersonContact=@AnswerValue	
		--ELSE IF @GrpQuestID=87 SELECT @UPIID=@AnswerValue
		ELSE IF @GrpQuestID=11 SELECT @IsGSTCompliance=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
		ELSE IF @GrpQuestID=12 SELECT @TaxNumber=@AnswerValue
		ELSE IF @GrpQuestID=9 SELECT @IsWhatsappNoSame=AnsVal FROM tblDynamic_PDAQuestOptionMstr WHERE OptID=@OptionID
		ELSE IF @GrpQuestID=10 SELECT @WhatsappNo=@AnswerValue
		ELSE IF @GrpQuestID=7 
		BEGIN
			SELECT @STDNo=SUBSTRING(@AnswerValue,0,PATINDEX('%$%',@AnswerValue))
			SELECT @Landline=CAST(SUBSTRING(@AnswerValue,PATINDEX('%$%',@AnswerValue)+1,LEN(@AnswerValue)) AS BIGINT)
		END
		ELSE IF @GrpQuestID=5 SELECT @EMailID=@AnswerValue
						
  FETCH NEXT FROM CurQuest  
  INTO @GrpQuestID,@QuestID,@AnsControlTypeID,@AnswerValID,@AnswerValue  
 END  
 CLOSE CurQuest  
 DEALLOCATE CurQuest  
 PRINT 'End'

 PRINT '@Landline=' + CAST(ISNULL(@Landline,0) AS VARCHAR(10))

 UPDATE P SET Outletname=@OutletName,DistributorID=@DBNodeID,DistributorType=@DBNodeType FROM tblPDASyncStoreMappingMstr P WHERE StoreIDDB=@StoreIDDB   
 
 INSERT INTO tblPDASyncAddressDet_History
SELECT * FROM tblPDASyncAddressDet WHERE StoreIDDB=@StoreIDDB

 DELETE FROM tblPDASyncAddressDet WHERE StoreIDDB=@StoreIDDB
 INSERT INTO tblPDASyncAddressDet(StoreIDDB,Address,City,Pincode,State,CityID,StateID)
 SELECT @StoreIDDB,@Address,City,Pincode,State,@CityID,@StateID FROM tblPDASyncStoreMappingMstr P WHERE StoreIDDB=@StoreIDDB

  INSERT INTO tblPDASyncContDet_History
SELECT * FROM tblPDASyncContDet WHERE StoreIDDB=@StoreIDDB

 DELETE FROM tblPDASyncContDet WHERE StoreIDDB=@StoreIDDB
 INSERT INTO tblPDASyncContDet(StoreIDDB,Ownername,OwnerMobNo,OwnerEmailID)
 SELECT @StoreIDDB,@Ownername,@Mob,@EMailID FROM tblPDASyncStoreMappingMstr P WHERE StoreIDDB=@StoreIDDB

   INSERT INTO tblPDASyncStoreattributeDet_History
SELECT * FROM tblPDASyncStoreattributeDet WHERE StoreIDDB=@StoreIDDB

 DELETE FROM tblPDASyncStoreattributeDet WHERE StoreIDDB=@StoreIDDB
 INSERT INTO tblPDASyncStoreattributeDet(StoreIDDB,OutletTypeID,OutletChannelID,TaxNumber,Address,OutletSalesPersonname,OutletSalesPersonContact,STD,LandLine,IsGSTCompliance,IsSameWhatsappnumber,alternatewhatsappNo,OutletClassID)
   SELECT @StoreIDDB,@StoreTypeID,@ChannelID,@TaxNumber,@Address,@SalesPersonName,@SalesPersonContact,@STDNo,@Landline,@IsGSTCompliance,@IsWhatsappNoSame,@WhatsappNo,@StoreClassID

 ----  DECLARE @OutletSpcID INT
 ---- DELETE FROM tblPDASyncStoreSpecialityType WHERE StoreIDDB=@StoreIDDB
 ---- PRINT '@StrStoreClassID=' + @StrStoreClassID
 ---- WHILE PATINDEX('%^%',@StrStoreClassID)>0
 ---- BEGIN
	----SET @OutletSpcID=CAST(SUBSTRING(@StrStoreClassID,0,PATINDEX('%^%',@StrStoreClassID)) AS INT)
	----SET @StrStoreClassID=SUBSTRING(@StrStoreClassID,PATINDEX('%^%',@StrStoreClassID) + 1,LEN(@StrStoreClassID))

	----INSERT INTO tblPDASyncStoreSpecialityType(StoreIDDB,StoreSpcID)
	----SELECT @StoreIDDB,@OutletSpcID
 ---- END
     
  PRINT @StoreIDDB 
 IF EXISTS (SELECT 1 FROM tblStoreMaster WHERE CAST(StoreID AS VARCHAR(50))=@StoreID)  
 BEGIN  
  UPDATE tblPDASyncStoreMappingMstr SET OrgStoreId=CAST(@StoreID AS INT) FROM tblPDASyncStoreMappingMstr WHERE StoreIDDB=@StoreIDDB  
 END  

 --To make store auto insert to store master %%%%%%%%%%%%%%%%%%%%%%%

 --EXEC spSaveValidatedStore @StoreIDDB,0

 UPDATE tblPDASyncStoreMappingMstr SET RecordUpdated=1,CreateDate=GETDATE(),flgStoreValidated=0 WHERE StoreIDDB=@StoreIDDB

 ---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 SELECT OrgStoreId ID,OrgStoreId StoreID,OutletName StoreName,CAST(ActualLatitude AS FLOAT) StoreLatitude,CAST(ActualLongitude AS FLOAT) StoreLongitude,GETDATE() AS LastTransactionDate,GETDATE() AS LastVisitDate,       
0 AS Sstat, 0 AS IsClose, 0 AS IsNextDat, @RouteID AS RouteID  ,@RouteNodeType AS RouteType,0 AS flgHasQuote,1 AS flgAllowQuotation,
0 AS flgSubmitFromQuotation,0  AS StoreType 
FROM tblPDASyncStoreMappingMstr left outer join tblstoremaster S on S.Storeid=tblPDASyncStoreMappingMstr.OrgStoreId
LEFT OUTER JOIN tblMstrChannel C ON C.ChannelId=S.ChannelId
WHERE tblPDASyncStoreMappingMstr.StoreIDDB=@StoreIDDB  
    
	PRINT @StoreIDDB

	--added by gaurav to get StoreIdDB while calling this SP from MR Store saving SP
  IF object_id('tempdb..#tmpStoreIdDB') is not null
	BEGIN
		INSERT INTO #tmpStoreIdDB(StoreIdDB) VALUES(@StoreIDDB)
	END

 Select @StoreIDDB StoreIDDB,OrgStoreId StoreID FROM tblPDASyncStoreMappingMstr WHERE StoreIDDB=@StoreIDDB  

  ----select b.StoreID,b.OutAddTypeID,Left(isnull(StoreAddress1,'') +isnull(' ,'+StoreAddress2,'')+ISNULL(' PinCode:-'+convert(varchar,P.PinCode),''),25) as Address,
  ----isnull(StoreAddress1,'') +isnull(' ,'+StoreAddress2,'')+ISNULL(', ','')+ISNULL(' PinCode:-'+convert(varchar,P.PinCode),'') as AddressDet,b.OutAddID  from tblOutletAddressDet B 
  ----inner JOIN tblPDASyncStoreMappingMstr p on p.OrgStoreID=B.StoreID 
  ----WHERE p.StoreIDDB=@StoreIDDB

 --SELECT o.* FROM tblOutletAddressDet o inner JOIN tblPDASyncStoreMappingMstr p on p.OrgStoreID=o.StoreID WHERE StoreIDDB=@StoreIDDB
END






