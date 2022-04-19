
--- DROP PROC spReadXMLFile_ASM
CREATE proc [dbo].[spReadXMLFile]
@SourceFolderPath varchar(500),
@DataSourceId int,
@FileSize int,
@FileName varchar(100),
@flgExecuted tinyint output,
@ImeiNo varchar(100)
as
begin
--SELECT @FileName

Declare @FileSetId int

Declare @fileSplit table(ident int identity(1,1),items varchar(100))
declare @cnt int,@year varchar(4),@month varchar(3),@day varchar(2)
,@hour varchar(2),@min varchar(2),@sec varchar(2)
insert into @fileSplit(items)
select *  from dbo.split(@FileName,'.')
set @cnt=@@rowcount

select @year=items from @fileSplit where ident=@cnt-4
select @month=items from @fileSplit where ident=@cnt-5
select @day=items from @fileSplit where ident=@cnt-6
select @hour=items from @fileSplit where ident=@cnt-3
select @min=items from @fileSplit where ident=@cnt-2
select @sec=items from @fileSplit where ident=@cnt-1

--select @year
--select @month
--select @day
--select @hour
--select @min
--select @sec

DECLARE @FileCreationDate Datetime
SELECT @FileCreationDate=convert(datetime,@year +'-'+@month +'-'+@day +' '+@hour +':'+@min +':'+@sec)

PRINT 'AA'
--SELECT convert(datetime,@year +'-'+@month +'-'+@day +' '+@hour +':'+@min +':'+@sec)
insert into tblMstrFileSet(FileSetName,FileCreationDate,FileBranchCode,FileDataDate,FileVersionNo,FileSetType,ProcessStartTime,ProcessEndTime,flgSuccess
,FileSetErrorId,BranchId,VersionId,DataSourceId,FileSize,FileDataProcessStartTime,IMEINo)

values(@FileName,@FileCreationDate,'','2000-01-01','','',Getdate(),null,0,0,0,0,@DataSourceId,@FileSize,Getdate(),@ImeiNo)

set @FileSetId=IDENT_CURRENT('tblMstrFileSet')

PRINT '@FileSetId=' + CAST(@FileSetId AS VARCHAR)
PRINT 'BB'


--- Declaration of Temp tables 
DECLARE @udt_RawDataPersonRegDetails udt_RawDataPersonRegDetails,
@udt_RawDataAttandanceDetails udt_RawDataAttandanceDetails,
@udt_RawDataStoreLocationDetails udt_RawDataLatLongDetails,
@udt_RawDataStoreList udt_RawDataStoreList,
@udt_RawDataNewStoreLocationDetails udt_RawDataNewStoreLocationDetails,
@udt_RawDataQuestAnsMstr udt_RawDataOutletQuestAnsMstr,
@udt_RawDataCustomerVisit udt_RawDataCustomerVisit,
@udt_RawDataInvoiceHeader udt_RawDataInvoiceHeader,
@udt_RawDataInvoiceDetail udt_RawDataInvoiceDetail,
@udt_RawDataCollectionData udt_RawDataCollectionData,
@udt_RawDataDayEndDet udt_RawDataDayEndDet,
@udt_RawDataNoVisitStoreDetails udt_RawDataNoVisitStoreDetails,
@udt_RawDataStoreMultipleVisitDetail udt_RawDataStoreMultipleVisitDetail,
@udt_RawStoreCheckData udt_RawStoreCheckData,
@udt_RawDataSelectedManagerDetails udt_RawDataSelectedManagerDetails,
@udt_RawDataProductReturnImage udt_RawDataProductReturnImage,
@udt_RawDataTableImage udt_RawDataTableImage,
@udt_RawDataStoreCheckImage udt_RawDataStoreCheckImage,
@udt_RawDataDeliveryDetails udt_RawDataDeliveryDetails,
@udt_RawDataStoreCloseLocationDetail udt_RawDataStoreCloseLocationDetail,
@udt_RawDataStoreClosePhotoDetail udt_RawDataStoreClosePhotoDetail,
@udt_RawDataStoreReasonDetail udt_RawDataStoreReasonSaving,
@udt_RawDataStoreReturnDetail udt_RawDataStoreReturnDetail,
--@udt_RawDataStoreReturnPhotoDetail udt_RawDataStoreReturnPhotoDetail
@udt_RawDataInvoiceExecution udt_RawDataInvoiceExecution ,
@udt_RawDataInvoiceImages udt_RawDataInvoiceImages,
@udt_RawDistProductStock udt_RawDistProductStock,
@udt_RawDataCartonMaster udt_RawDataCartonMaster,
@udt_RawDataCartonDetail udt_RawDataCartonDetail,

@udt_RawDataJointVisitMaster udt_RawDataJointVisitMaster,
@udt_RawDataJointVisitDetail udt_RawDataJointVisitDetail,
@udt_RawGateMeetingTarget udt_RawGateMeetingTarget,
@udt_RawGateMeetingTargetDet udt_RawGateMeetingTargetDet

BEGIN TRY

if object_id('tempdb..#XMLwithOpenXML') is not null
begin
drop table #XMLwithOpenXML
end
CREATE TABLE #XMLwithOpenXML(XMLData XML)

Declare @FilePath varchar(500),@SQLQuery nvarchar(1000)

set @FilePath=@SourceFolderPath+@FileName


set @SQLQuery='SELECT CONVERT(XML, BulkColumn) AS BulkColumn FROM OPENROWSET(BULK '''+@FilePath+''', SINGLE_BLOB) AS x;'
INSERT INTO #XMLwithOpenXML(XMLData)
exec sp_executesql @SQLQuery

DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)


SELECT @XML = XMLData FROM #XMLwithOpenXML

--SELECT a.b.value('row/col[1]','varchar(10)') AS Color1 FROM @XML.nodes('database/table/@tblSaveStoreWareHouseDetails') a(b)


EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML

--- Person Reg Details
	insert into @udt_RawDataPersonRegDetails(
	
	[IMEI],[ClickedDateTime],[Name],[ContactNo],DOB,Sex,MaritalStatus,MarriedDate,Qualification,SelfieName,SelfiePath,EmailID,BloodGroup,SignName,SignPath,Sstat,PhotoName,PersonNodeId,PersonNodeType)
	SELECT [IMEI],[ClickedDateTime],[FirstName],[ContactNo],DOB,Sex,MaritalStatus,MarriedDate,Qualification,SelfieName,SelfiePath,EmailID,BloodGroup,SignName,SignPath,Sstat,PhotoName,PersonNodeId,PersonNodeType
	FROM OPENXML(@hDoc,'database/table[@name=''tblDsrRegDetails'']/row')
		WITH 
		(
			[IMEI] [nvarchar](500) 'col[@name=''PDACode'']',
			[ClickedDateTime] [nvarchar](500) 'col[@name=''ClickedDateTime'']',
			[FirstName] [nvarchar](500) 'col[@name=''FirstName'']',
			[ContactNo] [nvarchar](500) 'col[@name=''ContactNo'']',
			DOB [nvarchar](500) 'col[@name=''DOB'']',
			Sex [nvarchar](500) 'col[@name=''Sex'']',
			MaritalStatus [nvarchar](500) 'col[@name=''MaritalStatus'']',
			MarriedDate [nvarchar](500) 'col[@name=''MarriedDate'']',
			Qualification [nvarchar](500) 'col[@name=''Qualification'']',
			SelfieName [nvarchar](500) 'col[@name=''SelfieName'']',
			SelfiePath [nvarchar](500) 'col[@name=''SelfiePath'']',
			EmailID [nvarchar](500) 'col[@name=''EmailID'']',
			BloodGroup [nvarchar](500) 'col[@name=''BloodGroup'']',
			SignName [nvarchar](500) 'col[@name=''SignName'']',
			SignPath [nvarchar](500) 'col[@name=''SignPath'']',
			Sstat [nvarchar](500) 'col[@name=''Sstat'']',
			PhotoName [nvarchar](500) 'col[@name=''PhotoName'']',
			PersonNodeId [nvarchar](500) 'col[@name=''PersonNodeId'']',
			PersonNodeType [nvarchar](500) 'col[@name=''PersonNodeType'']'
		)

	-- Person Attandance Details
	insert into @udt_RawDataAttandanceDetails([AttandanceTime],[ReasonDesc],[fnLati],[PersonNodeID],[ReasonID],[fnLongi],[PersonNodeType],[fnAccuracy],[fnAddress],[PinCode],[City],[State],[MapAddress],[MapCity],[MapPinCode],[MapState],[flgLocNotFound],[AllProvidersLocation],[GPSLatitude],[GPSLongitude],[GPSAccuracy],[GPSAddress],[NetworkLatitude],[NetworkLongitude],[NetworkAccuracy],[NetworkAddress],[FusedLatitude],[FusedLongitude],[FusedAccuracy],[FusedAddress],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking],[BatteryStatus],[Comment])	
	SELECT [AttandanceTime],[ReasonDesc],[ActualLati],[PersonNodeID],[ReasonID],[ActualLongi],[PersonNodeType],[ActualAccuracy],[Address],[PinCode],[City],[State],[MapAddress],[MapCity],[MapPinCode],[MapState],[flgLocNotFound],[AllProvidersLocation],[GPSLatitude],[GPSLongitude],[GPSAccuracy],[GPSAddress],[NetworkLatitude],[NetworkLongitude],[NetworkAccuracy],[NetworkAddress],[FusedLatitude],[FusedLongitude],[FusedAccuracy],[FusedAddress],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking],[BatteryStatus],[Comment] 
	FROM OPENXML(@hDoc, 'database/table[@name=''tblAttandanceDetails'']/row')
	WITH 
	(
		[AttandanceTime] nvarchar(500) 'col[@name="AttandanceTime"]',
		[PersonNodeID] nvarchar(500) 'col[@name="PersonNodeID"]',
		[PersonNodeType] nvarchar(500) 'col[@name="PersonNodeType"]',
		[ReasonID] nvarchar(500) 'col[@name="ReasonID"]',
		[ReasonDesc] nvarchar(500) 'col[@name="ReasonDesc"]',
		[Address] nvarchar(500) 'col[@name="fnAddress"]',
		[PinCode] nvarchar(500) 'col[@name="fnPinCode"]',
		[City] nvarchar(500) 'col[@name="fnCity"]',
		[State] nvarchar(500) 'col[@name="fnState"]',
		[MapAddress] nvarchar(500) 'col[@name="MapAddress"]',
		[MapCity] nvarchar(500) 'col[@name="MapCityOrVillage"]',
		[MapPinCode] nvarchar(500) 'col[@name="MapPinCode"]',
		[MapState] nvarchar(500) 'col[@name="MapState"]',
		[ActualLati] nvarchar(500) 'col[@name="fnLati"]',
		[ActualLongi] nvarchar(500) 'col[@name="fnLongi"]',
		[ActualAccuracy] nvarchar(500) 'col[@name="fnAccuracy"]',
		[flgLocNotFound] nvarchar(500) 'col[@name="flgGLocNotFound"]',
		[AllProvidersLocation] nvarchar(500) 'col[@name="AllProvidersLocation"]',
		[GPSLatitude] [nvarchar](500) 'col[@name=''GPSLatitude'']',
		[GPSLongitude] [nvarchar](500) 'col[@name=''GPSLongitude'']',
		[GPSAccuracy] [nvarchar](500) 'col[@name=''GpsAccuracy'']',
		[GPSAddress] [nvarchar](500) 'col[@name=''GpsAddress'']',
		[NetworkLatitude] [nvarchar](500) 'col[@name=''NetworkLatitude'']',
		[NetworkLongitude] [nvarchar](500) 'col[@name=''NetworkLongitude'']',
		[NetworkAccuracy] [nvarchar](500) 'col[@name=''NetworkAccuracy'']',
		[NetworkAddress] [nvarchar](500) 'col[@name=''NetworkAddress'']',
		[FusedLatitude] [nvarchar](500) 'col[@name=''FusedLatitude'']',
		[FusedLongitude] [nvarchar](500) 'col[@name=''FusedLongitude'']',
		[FusedAccuracy] [nvarchar](500) 'col[@name=''FusedAccuracy'']',
		[FusedAddress] [nvarchar](500) 'col[@name=''FusedAddress'']',
		[flgLocationServicesOnOff] nvarchar(500) 'col[@name="flgLocationServicesOnOff"]',
		[flgGPSOnOff] nvarchar(500) 'col[@name="flgGPSOnOff"]',
		[flgNetworkOnOff] nvarchar(500) 'col[@name="flgNetworkOnOff"]',
		[flgFusedOnOff] nvarchar(500) 'col[@name="flgFusedOnOff"]',
		[flgInternetOnOffWhileLocationTracking] nvarchar(500) 'col[@name="flgInternetOnOffWhileLocationTracking"]',
		[BatteryStatus] nvarchar(500) 'col[@name="BatteryStatus"]',
		[Comment] nvarchar(500) 'col[@name="Comment"]'
		
	)

	--- Visited Store List/New Store Added
	insert into @udt_RawDataStoreList([IMEINumber],[StoreID],[StoreName],[OwnerName],[StoreContactNo],[StoreAddress],[StoreType],[StoreLatitude],[StoreLongitude],[LastVisitDate],[LastTransactionDate],[IsNewStore],[PaymentStage],[DBR],[StoreCity],[StorePinCode],[StoreState],[flgRestart],[AppVersion],[StoreStateID],[StoreCityID],[Accuracy],[BateryLeftStatus],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking],[CreatedDate])
	SELECT [IMEINumber],[StoreID],[StoreName],[OwnerName],[StoreContactNo],[StoreAddress],[StoreType],[StoreLatitude],[StoreLongitude],[LastVisitDate],[LastTransactionDate],[IsNewStore],[PaymentStage],[DBR],[StoreCity],[StorePinCode],[StoreState],[flgRestart],[AppVersion],[StoreStateID],[StoreCityID],[Accuracy],[BateryLeftStatus],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking],[CreatedDate]
	FROM OPENXML(@hDoc,'database/table[@name=''tblStoreList'']/row')
		WITH 
		(
		[IMEINumber] [nvarchar](500) 'col[@name=''IMEINumber'']',
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[StoreName] [nvarchar](500) 'col[@name=''StoreName'']',
		[OwnerName] [nvarchar](500) 'col[@name=''OwnerName'']',
		[StoreContactNo] [nvarchar](500) 'col[@name=''StoreContactNo'']',
		[StoreAddress] [nvarchar](500) 'col[@name=''StoreAddress'']',
		[StoreType] [nvarchar](500) 'col[@name=''StoreType'']',
		[StoreLatitude] [nvarchar](500) 'col[@name=''StoreLatitude'']',
		[StoreLongitude] [nvarchar](500) 'col[@name=''StoreLongitude'']',
		[LastVisitDate] [nvarchar](500) 'col[@name=''LastVisitDate'']',
		[LastTransactionDate] [nvarchar](500) 'col[@name=''LastTransactionDate'']',
		[IsNewStore] [nvarchar](500) 'col[@name=''ISNewStore'']',
		[PaymentStage] [nvarchar](500) 'col[@name=''PaymentStage'']',
		[DBR] [nvarchar](500) 'col[@name=''DBR'']',
		[StoreCity] [nvarchar](500) 'col[@name=''StoreCity'']',
		[StorePinCode] [nvarchar](500) 'col[@name=''StorePinCode'']',
		[StoreState] [nvarchar](500) 'col[@name=''StoreState'']',
		[flgRestart] [nvarchar](500) 'col[@name=''flgRestart'']',
		[AppVersion] [nvarchar](500) 'col[@name=''AppVersion'']',
		[StoreStateID] [nvarchar](500) 'col[@name=''StoreStateID'']',
		[StoreCityID] [nvarchar](500) 'col[@name=''StoreCityID'']'	,
		[Accuracy] [nvarchar](500) 'col[@name=''Accuracy'']'	,
		[BateryLeftStatus] [nvarchar](500) 'col[@name=''BateryLeftStatus'']'	,
		[flgLocationServicesOnOff] [nvarchar](500) 'col[@name=''flgLocationServicesOnOff'']'	,
		[flgGPSOnOff] [nvarchar](500) 'col[@name=''flgGPSOnOff'']'	,
		[flgNetworkOnOff] [nvarchar](500) 'col[@name=''flgNetworkOnOff'']'	,
		[flgFusedOnOff] [nvarchar](500) 'col[@name=''flgFusedOnOff'']',	
		[flgInternetOnOffWhileLocationTracking] [nvarchar](500) 'col[@name=''flgInternetOnOffWhileLocationTracking'']',	
		[CreatedDate] [nvarchar](500) 'col[@name=''device_time'']'
	)

	--- New Store location Details
	INSERT INTO @udt_RawDataNewStoreLocationDetails([StoreID],[VisitEndTS],[LocProvider],[Accuracy],[BateryLeftStatus],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking],[Sstat])
	SELECT [StoreID],[VisitEndTS],[LocProvider],[Accuracy],[BateryLeftStatus],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking],
	[Sstat]
	FROM OPENXML(@hDoc,'database/table[@name=''tblNewAddedStoreLocationDetails'']/row')
		WITH 
		(
			[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
			[VisitEndTS] [nvarchar](500) 'col[@name=''VisitEndTS'']',
			[LocProvider] [nvarchar](500) 'col[@name=''LocProvider'']',
			[Accuracy] [nvarchar](500) 'col[@name=''Accuracy'']',
			[BateryLeftStatus] [nvarchar](500) 'col[@name=''BateryLeftStatus'']',
			[flgLocationServicesOnOff] [nvarchar](500) 'col[@name=''flgLocationServicesOnOff'']',
			[flgGPSOnOff] [nvarchar](500) 'col[@name=''flgGPSOnOff'']',
			[flgNetworkOnOff] [nvarchar](500) 'col[@name=''flgNetworkOnOff'']',
			[flgFusedOnOff] [nvarchar](500) 'col[@name=''flgFusedOnOff'']',
			[flgInternetOnOffWhileLocationTracking] [nvarchar](500) 'col[@name=''flgInternetOnOffWhileLocationTracking'']',
			[Sstat] [nvarchar](500) 'col[@name=''Sstat'']'
		)

	--- No Store Visit Details
	insert into @udt_RawDataNoVisitStoreDetails([IMEI],[CurDate],[ReasonId],[ReasonDescr],[flgHasVisit])	
	SELECT  [IMEI],[CurDate],[ReasonId],[ReasonDescr],[flgHasVisit]

	FROM OPENXML(@hDoc, 'database/table[@name=''tblNoVisitStoreDetails'']/row')
	WITH 
	(
		[IMEI] [nvarchar](500) 'col[@name=''PDACode'']',
		[CurDate] [nvarchar](500) 'col[@name=''CurDate'']',
		[ReasonId] [nvarchar](500) 'col[@name=''ReasonId'']',
		[ReasonDescr] [nvarchar](500) 'col[@name=''ReasonDescr'']',
		[flgHasVisit] [nvarchar](500) 'col[@name=''flgHasVisit'']'
	)


	--- New Store Addition Questions Response Details
	insert into @udt_RawDataQuestAnsMstr(OutletID,QuestID,AnswerType,AnswerValue,QuestionGroupID,sectionID,Sstat,StoreVisitCode,JointVisitCode,flgApplicablemodule)	
	SELECT  OutletID,QuestID,AnswerType,AnswerValue,QuestionGroupID,sectionID,Sstat,StoreVisitCode,JointVisitCode,flgApplicablemodule

	FROM OPENXML(@hDoc, 'database/table[@name=''tblOutletQuestAnsMstr'']/row')
	WITH 
	(
		[OutletID] nvarchar(500) 'col[@name=''OutletID'']',
		[QuestID] nvarchar(500) 'col[@name=''QuestID'']',
		[AnswerType] nvarchar(500) 'col[@name=''AnswerType'']',
		[AnswerValue] nvarchar(500) 'col[@name=''AnswerValue'']',
		[QuestionGroupID] nvarchar(500) 'col[@name=''QuestionGroupID'']',
		[sectionID] nvarchar(500) 'col[@name=''sectionID'']',
		[Sstat] nvarchar(500) 'col[@name=''Sstat'']',
		[StoreVisitCode] nvarchar(500) 'col[@name=''StoreVisitCode'']',
		[JointVisitCode] nvarchar(500) 'col[@name=''JointVisitID'']',
		[flgApplicablemodule] nvarchar(500) 'col[@name=''flgApplicablemodule'']'
	)


	--- Store Visit Master Data
	insert into @udt_RawDataCustomerVisit([IMEINumber],[StoreID],[StoreVisitCode],[JointVisitCode],[VisitDate],[VisitLatitude],[VisitLongitude],[flgJointVisit],[VisitTimeOutSideStore],[VisitTimeInSideStore],[VisitTimeCheckStore],[VisitEndTS],[LocProvider],[Accuracy],[BateryLeftStatus],[StoreClose],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking],[MapAddress],[MapCity],[MapState],[MapPinCode],[NoOrderReasonID],[NoOrderReasonDescr],[flgVisitType],[TeleCallingID],[flgOrderCancel],[VisitComments],[flgIsPicsAllowed],[NOPIcsReason],[IsGeoValidated],[flgOnBehalfOf])
	SELECT [IMEINumber],[StoreID],[StoreVisitCode],[JointVisitCode],[VisitDate],[VisitLatitude],[VisitLongitude],[flgJointVisit],[VisitTimeOutSideStore],[VisitTimeInSideStore],[VisitTimeCheckStore],[VisitEndTS],[LocProvider],[Accuracy],[BateryLeftStatus],[StoreClose],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking],[MapAddress],[MapCity],[MapState],[MapPinCode],[NoOrderReasonID],[NoOrderReasonDescr],[flgVisitType],[TeleCallingID],[flgOrderCancel],[VisitComments],[flgIsPicsAllowed],[NOPIcsReason],[IsGeoValidated],[flgOnBehalfOf]

	FROM OPENXML(@hDoc,'database/table[@name=''tblStoreVisitMstr'']/row')
		WITH 
		(
		[IMEINumber] [nvarchar](500) 'col[@name=''PDACode'']',
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[StoreVisitCode] [nvarchar](500) 'col[@name=''StoreVisitCode'']',
		[JointVisitCode] [nvarchar](500) 'col[@name=''JointVisitId'']',
		[VisitDate]  [nvarchar](500) 'col[@name=''ForDate'']',
		[VisitLatitude] [nvarchar](500) 'col[@name=''ActualLatitude'']',
		[VisitLongitude] [nvarchar](500) 'col[@name=''ActualLongitude'']',
		[flgJointVisit] [nvarchar](500) 'col[@name=''flgJointVisit'']',
		[VisitTimeOutSideStore] [nvarchar](500) 'col[@name=''VisitTimeOutSideStore'']',
		[VisitTimeInSideStore] [nvarchar](500) 'col[@name=''VisitTimeInSideStore'']',
		[VisitTimeCheckStore] [nvarchar](500) 'col[@name=''VisitTimeCheckStore'']',
		[VisitEndTS] [nvarchar](500) 'col[@name=''VisitEndTS'']',
		[LocProvider] [nvarchar](500) 'col[@name=''LocProvider'']',
		[Accuracy] [nvarchar](500) 'col[@name=''Accuracy'']',
		[BateryLeftStatus] [nvarchar](500) 'col[@name=''BateryLeftStatus'']',
		[StoreClose] [nvarchar](500) 'col[@name=''StoreClose'']',
		[flgLocationServicesOnOff] [nvarchar](500) 'col[@name=''flgLocationServicesOnOff'']',
		[flgGPSOnOff] [nvarchar](500) 'col[@name=''flgGPSOnOff'']',
		[flgNetworkOnOff] [nvarchar](500) 'col[@name=''flgNetworkOnOff'']',
		[flgFusedOnOff] [nvarchar](500) 'col[@name=''flgFusedOnOff'']',
		[flgInternetOnOffWhileLocationTracking] [nvarchar](500) 'col[@name=''flgInternetOnOffWhileLocationTracking'']',
		[MapAddress] [nvarchar](500) 'col[@name=''MapAddress'']',
		[MapCity] [nvarchar](500) 'col[@name=''MapCity'']',
		[MapState] [nvarchar](500) 'col[@name=''MapState'']',
		[MapPinCode] [nvarchar](500) 'col[@name=''MapPinCode'']',
		[NoOrderReasonID] [nvarchar](500) 'col[@name=''NoOrderReasonID'']',
		[NoOrderReasonDescr] [nvarchar](500) 'col[@name=''NoOrderReasonDescr'']',
		[flgVisitType] [nvarchar](500) 'col[@name=''flgVisitType'']',
		[TeleCallingID] [nvarchar](500) 'col[@name=''TeleCallingID'']',
		[flgOrderCancel] [nvarchar](500) 'col[@name=''flgOrderCancel'']',
		[VisitComments] [nvarchar](500) 'col[@name=''OrderComments'']',
		[flgIsPicsAllowed] [nvarchar](500) 'col[@name=''flgIsPicsAllowed'']',
		[NOPIcsReason] [nvarchar](500) 'col[@name=''NoPicsReason'']',
		[IsGeoValidated] [nvarchar](500) 'col[@name=''isVisitInRange'']',
		[flgOnBehalfOf] [nvarchar](500) 'col[@name=''flgOnBehalfOf'']'

	)

	--- Store Visit Detail
	INSERT INTO @udt_RawDataStoreMultipleVisitDetail([IMEINumber],[StoreVisitCode],[StoreID],[TempStoreVisitCode],[ForDate],[Sstat],[VisitTimeStartAtStore],[VisitTimeEndStore],[VisitLatCode],[VisitLongCode],[flgTelephonic])
	SELECT [IMEINumber],[StoreVisitCode],[StoreID],[TempStoreVisitCode],[ForDate],[Sstat],[VisitTimeStartAtStore],[VisitTimeEndStore],[VisitLatCode],[VisitLongCode],[flgTelephonic]
	FROM OPENXML(@hDoc,'database/table[@name=''tblStoreOrderVisitDayActivity'']/row')
	WITH 
	(
		[IMEINumber] [nvarchar](500) 'col[@name=''IMEINumber'']',
		[StoreVisitCode] [nvarchar](500) 'col[@name=''StoreVisitCode'']',
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[TempStoreVisitCode] [nvarchar](500) 'col[@name=''TempStoreVisitCode'']',
		[ForDate] [nvarchar](500) 'col[@name=''ForDate'']',
		[Sstat] [nvarchar](500) 'col[@name=''Sstat'']',
		[VisitTimeStartAtStore] [nvarchar](500) 'col[@name=''VisitTimeStartAtStore'']',
		[VisitTimeEndStore] [nvarchar](500) 'col[@name=''VisitTimeEndStore'']'	,
		[VisitLatCode] [nvarchar](500) 'col[@name=''VisitLatCode'']',
		[VisitLongCode] [nvarchar](500) 'col[@name=''VisitLongCode'']',
		[flgTelephonic] [nvarchar](500) 'col[@name=''flgTelephonic'']'

	)

	--- Store Visit location Details
	INSERT INTO @udt_RawDataStoreLocationDetails([StoreID],[StoreVisitCode],[fnLati],[fnLongi],[fnAccuracy],[flgLocNotFound],[fnAccurateProvider],[AllProvidersLocation],[fnAddress],[GpsLat],[GpsLong],[GpsAccuracy],[GpsAddress],[NetwLat],[NetwLong],[NetwAccuracy],[NetwAddress],[FusedLat],[FusedLong],[FusedAccuracy],[FusedAddress],[FusedLocationLatitudeWithFirstAttempt],[FusedLocationLongitudeWithFirstAttempt],[FusedLocationAccuracyWithFirstAttempt],[Sstat])
	SELECT [StoreID],[StoreVisitCode],[fnLati],[fnLongi],[fnAccuracy],[flgLocNotFound],[fnAccurateProvider],[AllProvidersLocation],[fnAddress],[GpsLat],[GpsLong],[GpsAccuracy],[GpsAddress],[NetwLat],[NetwLong],[NetwAccuracy],[NetwAddress],[FusedLat],[FusedLong],[FusedAccuracy],[FusedAddress],[FusedLocationLatitudeWithFirstAttempt],[FusedLocationLongitudeWithFirstAttempt],[FusedLocationAccuracyWithFirstAttempt],[Sstat]
	FROM OPENXML(@hDoc, 'database/table[@name=''tblLatLongDetails'']/row')
	WITH 
	(
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[JointVisitID] [nvarchar](500) 'col[@name=''JointVisitID'']',
		[StoreVisitCode] [nvarchar](500) 'col[@name=''StoreVisitCode'']',
		[JointVisitCode] [nvarchar](500) 'col[@name=''JointVisitCode'']',
		[fnLati] [nvarchar](500) 'col[@name=''fnLati'']',
		[fnLongi] [nvarchar](500) 'col[@name=''fnLongi'']',
		[fnAccuracy] [nvarchar](500) 'col[@name=''fnAccuracy'']',
		[flgLocNotFound] [nvarchar](500) 'col[@name=''flgLocNotFound'']',
		[fnAccurateProvider] [nvarchar](500) 'col[@name=''fnAccurateProvider'']',
		[AllProvidersLocation] [nvarchar](500) 'col[@name=''AllProvidersLocation'']',
		[fnAddress] [nvarchar](500) 'col[@name=''fnAddress'']',
		[GpsLat] [nvarchar](500) 'col[@name=''GpsLat'']',
		[GpsLong] [nvarchar](500) 'col[@name=''GpsLong'']',
		[GpsAccuracy] [nvarchar](500) 'col[@name=''GpsAccuracy'']',
		[GpsAddress] [nvarchar](500) 'col[@name=''GpsAddress'']',
		[NetwLat] [nvarchar](500) 'col[@name=''NetwLat'']',
		[NetwLong] [nvarchar](500) 'col[@name=''NetwLong'']',
		[NetwAccuracy] [nvarchar](500) 'col[@name=''NetwAccuracy'']',
		[NetwAddress] [nvarchar](500) 'col[@name=''NetwAddress'']',
		[FusedLat] [nvarchar](500) 'col[@name=''FusedLat'']',
		[FusedLong] [nvarchar](500) 'col[@name=''FusedLong'']',
		[FusedAccuracy] [nvarchar](500) 'col[@name=''FusedAccuracy'']',
		[FusedAddress] [nvarchar](500) 'col[@name=''FusedAddress'']',
		[FusedLocationLatitudeWithFirstAttempt] [nvarchar](500) 'col[@name=''FusedLocationLatitudeWithFirstAttempt'']',
		[FusedLocationLongitudeWithFirstAttempt] [nvarchar](500) 'col[@name=''FusedLocationLongitudeWithFirstAttempt'']',
		[FusedLocationAccuracyWithFirstAttempt] [nvarchar](500) 'col[@name=''FusedLocationAccuracyWithFirstAttempt'']',
		[Sstat] [nvarchar](500) 'col[@name=''Sstat'']'
	)

	--- Store Close
	
	INSERT INTO @udt_RawDataStoreCloseLocationDetail([StoreID],[StoreVisitCode],[Lattitude],[Longitude],[Accuracy],[Address],[City],[Pincode],[State],[fnAccurateProvider],[GpsLat],[GpsLong],[GpsAccuracy],[GpsAddress],[NetwLat],[NetwLong],[NetwAccuracy],[NetwAddress],[FusedLat],[FusedLong],[FusedAccuracy],[FusedAddress])
	SELECT [StoreID],[StoreVisitCode],[Lattitude],[Longitude],[Accuracy],[Address],[City],[Pincode],[State],[fnAccurateProvider],[GpsLat],[GpsLong],[GpsAccuracy],[GpsAddress],[NetwLat],[NetwLong],[NetwAccuracy],[NetwAddress],[FusedLat],[FusedLong],[FusedAccuracy],[FusedAddress]
	FROM OPENXML(@hDoc,'database/table[@name=''tblStoreCloseLocationDetails'']/row')
	WITH 
	(
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[StoreVisitCode] [nvarchar](500) 'col[@name=''StoreVisitCode'']',
		[Lattitude] [nvarchar](500) 'col[@name=''Lattitude'']',
		[Longitude] [nvarchar](500) 'col[@name=''Longitude'']',
		[Accuracy] [nvarchar](500) 'col[@name=''Accuracy'']',
		[Address] [nvarchar](500) 'col[@name=''Address'']',
		[City] [nvarchar](500) 'col[@name=''City'']',
		[Pincode] [nvarchar](500) 'col[@name=''Pincode'']',
		[State] [nvarchar](500) 'col[@name=''State'']',
		[fnAccurateProvider] [nvarchar](500) 'col[@name=''fnAccurateProvider'']',
		[GpsLat] [nvarchar](500) 'col[@name=''GpsLat'']',
		[GpsLong] [nvarchar](500) 'col[@name=''GpsLong'']',
		[GpsAccuracy] [nvarchar](500) 'col[@name=''GpsAccuracy'']',
		[GpsAddress] [nvarchar](500) 'col[@name=''CollectionCode'']',
		[NetwLat] [nvarchar](500) 'col[@name=''NetwLat'']',
		[NetwLong] [nvarchar](500) 'col[@name=''NetwLong'']',
		[NetwAccuracy] [nvarchar](500) 'col[@name=''NetwAccuracy'']',
		[NetwAddress] [nvarchar](500) 'col[@name=''NetwAddress'']',
		[FusedLat] [nvarchar](500) 'col[@name=''FusedLat'']',
		[FusedLong] [nvarchar](500) 'col[@name=''FusedLong'']',
		[FusedAccuracy] [nvarchar](500) 'col[@name=''FusedAccuracy'']',
		[FusedAddress] [nvarchar](500) 'col[@name=''FusedAddress'']'

	)

	--- Store Close Photo Details
	
	INSERT INTO @udt_RawDataStoreClosePhotoDetail([StoreID],[ClickedDateTime],[PhotoName],[PDAPhotoPath],[Sstat],[StoreVisitCode])
	SELECT [StoreID],[ClickedDateTime],[PhotoName],[PDAPhotoPath],[Sstat],[StoreVisitCode]
	FROM OPENXML(@hDoc,'database/table[@name=''tblStoreClosedPhotoDetail'']/row')
	WITH 
	(
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[ClickedDateTime] [nvarchar](500) 'col[@name=''ClickedDateTime'']',
		[PhotoName] [nvarchar](500) 'col[@name=''PhotoName'']',
		[PDAPhotoPath] [nvarchar](500) 'col[@name=''PDAPhotoPath'']',
		[Sstat] [nvarchar](500) 'col[@name=''Sstat'']',
		[StoreVisitCode] [nvarchar](500) 'col[@name=''StoreVisitCode'']'

	)

	--- Store Close Reason Details
	
	INSERT INTO @udt_RawDataStoreReasonDetail([StoreID],[ReasonID],[ReasonDescr],[Sstat],[StoreVisitCode])
	SELECT [StoreID],[ReasonID],[ReasonDescr],[Sstat],[StoreVisitCode]
	FROM OPENXML(@hDoc,'database/table[@name=''tblStoreCloseReasonSaving'']/row')
	WITH 
	(
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[ReasonID] [nvarchar](500) 'col[@name=''ReasonID'']',
		[ReasonDescr] [nvarchar](500) 'col[@name=''ReasonDescr'']',
		[Sstat] [nvarchar](500) 'col[@name=''Sstat'']',
		[StoreVisitCode] [nvarchar](500) 'col[@name=''StoreVisitCode'']'

	)

	--- Store Return Details
	
	INSERT INTO @udt_RawDataStoreReturnDetail([StoreID],[RouteID],[ReturnProductID],[ProdReturnQty],[ProdReturnReason],[ProdReturnReasonIndex],[ReturnDate],[outstat],[OrderIDPDA],[StoreVisitCode])
	SELECT [StoreID],[RouteID],[ReturnProductID],[ProdReturnQty],[ProdReturnReason],[ProdReturnReasonIndex],[ReturnDate],[outstat],[OrderIDPDA],[StoreVisitCode]
	FROM OPENXML(@hDoc,'database/table[@name=''tblStoreReturnDetail'']/row')
	WITH 
	(
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[RouteID] [nvarchar](500) 'col[@name=''RouteID'']',
		[ReturnProductID] [nvarchar](500) 'col[@name=''ReturnProductID'']',
		[ProdReturnQty] [nvarchar](500) 'col[@name=''ProdReturnQty'']',
		[ProdReturnReason] [nvarchar](500) 'col[@name=''ProdReturnReason'']',
		[ProdReturnReasonIndex] [nvarchar](500) 'col[@name=''ProdReturnReasonIndex'']',
		[ReturnDate] [nvarchar](500) 'col[@name=''ReturnDate'']',
		[outstat] [nvarchar](500) 'col[@name=''outstat'']',
		[OrderIDPDA] [nvarchar](500) 'col[@name=''OrderIDPDA'']',
		[StoreVisitCode] [nvarchar](500) 'col[@name=''StoreVisitCode'']'

	)

	------- Store Return Photo Details
	
	----INSERT INTO @udt_RawDataStoreReturnPhotoDetail([StoreID],[ProductID],[ClickedDateTime],[PhotoName],[PhotoValidation],[PDAPhotoPath],[OrderIDPDA])
	----SELECT [StoreID],[ProductID],[ClickedDateTime],[PhotoName],[PhotoValidation],[PDAPhotoPath],[OrderIDPDA]
	----FROM OPENXML(@hDoc,'database/table[@name=''tblStoreReturnPhotoDetail'']/row')
	----WITH 
	----(
	----	[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
	----	[ProductID] [nvarchar](500) 'col[@name=''ProductID'']',
	----	[ClickedDateTime] [nvarchar](500) 'col[@name=''ClickedDateTime'']',
	----	[PhotoName] [nvarchar](500) 'col[@name=''PhotoName'']',
	----	[PhotoValidation] [nvarchar](500) 'col[@name=''PhotoValidation'']',
	----	[PDAPhotoPath] [nvarchar](500) 'col[@name=''PDAPhotoPath'']',
	----	[OrderIDPDA] [nvarchar](500) 'col[@name=''OrderIDPDA'']'	

	----)


	-- Store Close 

	--- Manager Details
	insert into @udt_RawDataSelectedManagerDetails([CurDate],IMEI,ManagerID,ManagerName,ManagerType,OtherName,PersonID,PersonName,PersonType,Sstat)

	SELECT [CurDate],IMEI,ManagerID,ManagerName,ManagerType,OtherName,PersonID,PersonName,PersonType,Sstat
	FROM OPENXML(@hDoc,'database/table[@name=''tblSelectedManagerDetails'']/row')
	WITH 
	(
	[CurDate] nvarchar(500) 'col[@name=''CurDate'']',
	[IMEI] nvarchar(500) 'col[@name=''PDACode'']',
	[ManagerID] nvarchar(500) 'col[@name=''ManagerID'']',
	[ManagerName] nvarchar(500) 'col[@name=''ManagerName'']',
	[ManagerType] nvarchar(500) 'col[@name=''ManagerType'']',
	[OtherName] nvarchar(500) 'col[@name=''OtherName'']',
	[PersonID] nvarchar(500) 'col[@name=''PersonID'']',
	[PersonName] nvarchar(500) 'col[@name=''PersonName'']',
	[PersonType] nvarchar(500) 'col[@name=''PersonType'']',
	[Sstat] nvarchar(500) 'col[@name=''Sstat'']'

	)
		
	--- Store Check data
	INSERT INTO @udt_RawStoreCheckData([StoreID],[ProductID],[StockQty],[StoreVisitCode])
	SELECT [StoreID],[ProductID],[StockQty],[StoreVisitCode]
	FROM OPENXML(@hDoc,'database/table[@name=''tblActualVisitStock'']/row')
	WITH 
	(
		[StoreID] [nvarchar](500) 'col[@name=''storeID'']',
		[ProductID] [nvarchar](500) 'col[@name=''ProductID'']',
		[StockQty] [nvarchar](500) 'col[@name=''Stock'']'	,
		[StoreVisitCode] [nvarchar](500) 'col[@name=''StoreVisitCode'']'
	)


	--- Invoice header 
	INSERT INTO @udt_RawDataInvoiceHeader([StoreVisitCode],[InvoiceNumber],[TmpInvoiceCodePDA],[StoreID],[InvoiceDate],[TotalBeforeTaxDis],[TaxAmt],[TotalDis],[InvoiceVal],[FreeTotal],[InvAfterDis],[AddDis],[NoCoupon],[TotalCoupunAmount],[TransDate],[FlgInvoiceType],
[flgWholeSellApplicable],[flgProcessedInvoice],[CycleID],[RouteNodeTypeflgDrctslsIndrctSls],RouteNodeID,RouteNodeType,[TeleCallingID])
SELECT [StoreVisitCode],[InvoiceNumber],[TmpInvoiceCodePDA],[StoreID],[InvoiceDate],[TotalBeforeTaxDis],[TaxAmt],[TotalDis],[InvoiceVal],[FreeTotal],[InvAfterDis],[AddDis],[NoCoupon],[TotalCoupunAmount],[TransDate],[FlgInvoiceType],
[flgWholeSellApplicable],[flgProcessedInvoice],[CycleID],[RouteNodeTypeflgDrctslsIndrctSls],[RouteNodeID],[RouteNodeType],[TeleCallingID]
FROM OPENXML(@hDoc,'database/table[@name=''tblInvoiceHeader'']/row')
	WITH 
	(
		[StoreVisitCode] [nvarchar](500) 'col[@name=''StoreVisitCode'']',
		[InvoiceNumber] [nvarchar](500) 'col[@name=''InvoiceNumber'']',
		[TmpInvoiceCodePDA] [nvarchar](500) 'col[@name=''TmpInvoiceCodePDA'']',
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[InvoiceDate] [nvarchar](500) 'col[@name=''InvoiceDate'']',
		[TotalBeforeTaxDis] [nvarchar](500) 'col[@name=''TotalBeforeTaxDis'']',
		[TaxAmt] [nvarchar](500) 'col[@name=''TaxAmt'']',
		[TotalDis] [nvarchar](500) 'col[@name=''TotalDis'']',
		[InvoiceVal] [nvarchar](500) 'col[@name=''InvoiceVal'']',
		[FreeTotal] [nvarchar](500) 'col[@name=''FreeTotal'']',
		[InvAfterDis] [nvarchar](500) 'col[@name=''InvAfterDis'']',
		[AddDis] [nvarchar](500) 'col[@name=''AddDis'']',
		[NoCoupon] [nvarchar](500) 'col[@name=''NoCoupon'']',
		[TotalCoupunAmount] [nvarchar](500) 'col[@name=''TotalCoupunAmount'']',
		[TransDate] [nvarchar](500) 'col[@name=''TransDate'']',
		[FlgInvoiceType] [nvarchar](500) 'col[@name=''FlgInvoiceType'']',
		[flgWholeSellApplicable] [nvarchar](500) 'col[@name=''flgWholeSellApplicable'']',
		[flgProcessedInvoice] [nvarchar](500) 'col[@name=''flgProcessedInvoice'']',
		[CycleID] [nvarchar](500) 'col[@name=''CycleID'']',
		[RouteNodeTypeflgDrctslsIndrctSls] [nvarchar](500) 'col[@name=''flgDrctslsIndrctSls'']',
		[RouteNodeID] [nvarchar](500) 'col[@name=''RouteNodeID'']',
		[RouteNodeType] [nvarchar](500) 'col[@name=''RouteNodeType'']',
		[TeleCallingID] [nvarchar](500) 'col[@name=''TeleCallingID'']'
		

	)
		
		--- Invoice Detail 
	INSERT INTO @udt_RawDataInvoiceDetail([InvoiceNumber],[TmpInvoiceCodePDA],[StoreID],[CatID],[ProdID],[ProductPrice],[TaxRate],[flgRuleTaxVal],[OrderQty],[UOMId],[LineValBfrTxAftrDscnt],[LineValAftrTxAftrDscnt],[FreeQty],[DisVal],[SampleQuantity],[ProductShortName],[TaxValue],[OrderIDPDA],[flgIsQuoteRateApplied],[ServingDBRId],	[flgWholeSellApplicable],[ProductExtraOrder],[flgDrctslsIndrctSls],[flgInCarton])
SELECT [InvoiceNumber],[TmpInvoiceCodePDA],[StoreID],[CatID],[ProdID],[ProductPrice],[TaxRate],[flgRuleTaxVal],[OrderQty],[UOMId],[LineValBfrTxAftrDscnt],[LineValAftrTxAftrDscnt],[FreeQty],[DisVal],[SampleQuantity],[ProductShortName],[TaxValue],[OrderIDPDA],[flgIsQuoteRateApplied],[ServingDBRId],	[flgWholeSellApplicable],[ProductExtraOrder],[flgDrctslsIndrctSls],[flgInCarton]
FROM OPENXML(@hDoc,'database/table[@name=''tblInvoiceDetails'']/row')
	WITH 
	(
		[InvoiceNumber] [nvarchar](500) 'col[@name=''InvoiceNumber'']',
		[TmpInvoiceCodePDA] [nvarchar](500) 'col[@name=''TmpInvoiceCodePDA'']',
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[CatID] [nvarchar] (500) 'col[@name=''CatID'']',
		[ProdID] [nvarchar] (500) 'col[@name=''ProdID'']',
		[ProductPrice] [nvarchar](500) 'col[@name=''ProductPrice'']',
		[TaxRate] [nvarchar](500) 'col[@name=''TaxRate'']',
		[flgRuleTaxVal] [nvarchar](500) 'col[@name=''flgRuleTaxVal'']',
		[OrderQty] [nvarchar](500) 'col[@name=''OrderQty'']',
		[UOMId] [nvarchar](500) 'col[@name=''UOMId'']',
		[LineValBfrTxAftrDscnt] [nvarchar](500) 'col[@name=''LineValBfrTxAftrDscnt'']',
		[LineValAftrTxAftrDscnt] [nvarchar](500) 'col[@name=''LineValAftrTxAftrDscnt'']',
		[FreeQty] [nvarchar](500) 'col[@name=''FreeQty'']',
		[DisVal] [nvarchar](500) 'col[@name=''DisVal'']',
		[SampleQuantity] [nvarchar](500) 'col[@name=''SampleQuantity'']',
		[ProductShortName] [nvarchar](500) 'col[@name=''ProductShortName'']',
		[TaxValue] [nvarchar](500) 'col[@name=''TaxValue'']',
		[OrderIDPDA] [nvarchar](500) 'col[@name=''OrderIDPDA'']',
		[flgIsQuoteRateApplied] [nvarchar](500) 'col[@name=''flgIsQuoteRateApplied'']',
		[ServingDBRId] [nvarchar](500) 'col[@name=''ServingDBRId'']',
		[flgWholeSellApplicable] [nvarchar](500) 'col[@name=''flgWholeSellApplicable'']',
		[ProductExtraOrder] [nvarchar](500) 'col[@name=''ProductExtraOrder'']',
		[flgDrctslsIndrctSls] [nvarchar](500) 'col[@name=''flgDrctslsIndrctSls'']',
		[flgInCarton] [nvarchar](500) 'col[@name=''flgInCarton'']'
	)
	--- Carton Master


	INSERT INTO @udt_RawDataCartonMaster([StoreID],[InvoiceNumber],[CartonID],[CategoryID],[UOMType],[NoOfCarton],[TotalExpectedQty],[TotalActualQty],[CartonDiscount])
SELECT [StoreID],[InvoiceNumber],[CartonID],[CategoryID],[UOMType],[NoOfCarton],[TotalExpectedQty],[TotalActualQty],[CartonDiscount]
FROM OPENXML(@hDoc,'database/table[@name=''tblStoreCartonMaster'']/row')
	WITH 
	(
		[InvoiceNumber] [nvarchar](500) 'col[@name=''OrderID'']',
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[CartonID] [nvarchar](500) 'col[@name=''CartonID'']',
		[CategoryID] [nvarchar] (500) 'col[@name=''CatID'']',
		[UOMType] [nvarchar] (500) 'col[@name=''UOMType'']',
		[NoOfCarton] [nvarchar](500) 'col[@name=''NoOfCarton'']',
		[TotalExpectedQty] [nvarchar](500) 'col[@name=''TotalExpectedQty'']',
		[TotalActualQty] [nvarchar](500) 'col[@name=''TotalActualQty'']',
		[CartonDiscount] [nvarchar](500) 'col[@name=''CartonDiscount'']'
	)

	-- Carton Detail
	INSERT INTO @udt_RawDataCartonDetail([CartonID],[ProductID],[OrderQty],[CartonProductDiscount])
SELECT [CartonID],[ProductID],[OrderQty],[CartonProductDiscount]
FROM OPENXML(@hDoc,'database/table[@name=''tblStoreCartonDetails'']/row')
	WITH 
	(
		[CartonID] [nvarchar](500) 'col[@name=''CartonID'']',
		[ProductID] [nvarchar] (500) 'col[@name=''PrdID'']',
		[OrderQty] [nvarchar] (500) 'col[@name=''PrdQty'']',
		[CartonProductDiscount] [nvarchar](500) 'col[@name=''CartonProductDiscount'']'
	)
















	--- Store Order Delivery Details
	INSERT INTO @udt_RawDataDeliveryDetails([StoreID],[BillToAddress],[ShipToAddress],[Sstat])
	SELECT [StoreID],[BillToAddress],[ShipToAddress],[Sstat]
	FROM OPENXML(@hDoc,'database/table[@name=''tblStoreOrderBillAddressDetails'']/row')
	WITH
	(
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[BillToAddress] [nvarchar](500) 'col[@name=''BillToAddress'']',
		[ShipToAddress] [nvarchar](500) 'col[@name=''ShipToAddress'']',
		[Sstat] [nvarchar](500) 'col[@name=''Sstat'']'
	)

	-- Collection Data
	INSERT INTO @udt_RawDataCollectionData ([StoreVisitCode],[StoreID],[PaymentMode],[PaymentModeID],[Amount],[RefNoChequeNoTrnNo],	[Date],[Bank],[TmpInvoiceCodePDA],[CollectionCode])
	SELECT [StoreVisitCode],[StoreID],[PaymentMode],[PaymentModeID],[Amount],[RefNoChequeNoTrnNo],	[Date],[Bank],[TmpInvoiceCodePDA],[CollectionCode]
	FROM OPENXML(@hDoc,'database/table[@name=''tblAllCollectionData'']/row')
	WITH 
	(
		[StoreVisitCode] [nvarchar](500) 'col[@name=''StoreVisitCode'']',
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[PaymentMode] [nvarchar](500) 'col[@name=''PaymentMode'']',
		[PaymentModeID] [nvarchar](500) 'col[@name=''PaymentModeID'']',
		[Amount] [nvarchar](500) 'col[@name=''Amount'']',
		[RefNoChequeNoTrnNo] [nvarchar](500) 'col[@name=''RefNoChequeNoTrnNo'']',
		[Date] [nvarchar](500) 'col[@name=''Date'']',
		[Bank] [nvarchar](500) 'col[@name=''Bank'']',
		[TmpInvoiceCodePDA] [nvarchar](500) 'col[@name=''TmpInvoiceCodePDA'']',
		[CollectionCode] [nvarchar](500) 'col[@name=''CollectionCode'']'
	)

	-- Product Return Data
	INSERT INTO @udt_RawDataProductReturnImage ([StoreId],[ProductId],[QstIdAnsCntrlTyp],[PhotoName],[imagePath],[ImageClicktime],[ReasonForReturn],[PhotoValidation],	[OrderIDPDA],[TmpInvoiceCodePDA],[Sstat])
	SELECT [StoreId],[ProductId],[QstIdAnsCntrlTyp],[PhotoName],[imagePath],[ImageClicktime],[ReasonForReturn],[PhotoValidation],[OrderIDPDA],[TmpInvoiceCodePDA],[Sstat]
	FROM OPENXML(@hDoc,'database/table[@name=''tblStoreProductPhotoDetail'']/row')
	WITH 
	(
		[StoreId] [nvarchar](500) 'col[@name=''StoreId'']',
		[ProductId] [nvarchar](500) 'col[@name=''ProductId'']',
		[QstIdAnsCntrlTyp] [nvarchar](500) 'col[@name=''QstIdAnsCntrlTyp'']',
		[PhotoName] [nvarchar](500) 'col[@name=''imageName'']',
		[imagePath] [nvarchar](500) 'col[@name=''imagePath'']',
		[ImageClicktime] [nvarchar](500) 'col[@name=''ImageClicktime'']',
		[ReasonForReturn] [nvarchar](500) 'col[@name=''ReasonForReturn'']',
		[PhotoValidation] [nvarchar](500) 'col[@name=''PhotoValidation'']',
		[OrderIDPDA] [nvarchar](500) 'col[@name=''OrderIDPDA'']',
		[TmpInvoiceCodePDA] [nvarchar](500) 'col[@name=''TmpInvoiceCodePDA'']',
		[Sstat] [nvarchar](500) 'col[@name=''Sstat'']'
	)


	-- Store Images

	INSERT INTO @udt_RawDataTableImage ([StoreId],[QstIdAnsCntrlTyp],[PhotoName],[imagePath],[ImageClicktime],[Sstat])
	SELECT [StoreId],[QstIdAnsCntrlTyp],[PhotoName],[imagePath],[ImageClicktime],[Sstat]
	FROM OPENXML(@hDoc,'database/table[@name=''tableImage'']/row')
	WITH 
	(
		[StoreId] [nvarchar](500) 'col[@name=''StoreID'']',
		[QstIdAnsCntrlTyp] [nvarchar](500) 'col[@name=''QstIdAnsCntrlTyp'']',
		[PhotoName] [nvarchar](500) 'col[@name=''imageName'']',
		[imagePath] [nvarchar](500) 'col[@name=''imagePath'']',
		[ImageClicktime] [nvarchar](500) 'col[@name=''ImageClicktime'']',
		[Sstat] [nvarchar](500) 'col[@name=''Sstat'']'
	)

	-- Store Check Images
	
	INSERT INTO @udt_RawDataStoreCheckImage ([StoreId],[PhotoName],[ImageClicktime],[ImageType],[StoreVisitCode])
	SELECT [StoreId],[PhotoName],[ImageClicktime],[ImageType],[StoreVisitCode]
	FROM OPENXML(@hDoc,'database/table[@name=''tblStoreImageDetail'']/row')
	WITH 
	(
		[StoreId] [nvarchar](500) 'col[@name=''StoreID'']',
		[PhotoName] [nvarchar](500) 'col[@name=''ImageName'']',
		[ImageClicktime] [nvarchar](500) 'col[@name=''ImageClicktime'']',
		[ImageType] [nvarchar](500) 'col[@name=''ImageType'']',
		[StoreVisitCode] [nvarchar](500) 'col[@name=''StoreVisitCode'']'
	)

	--- Day End File
	INSERT INTO @udt_RawDataDayEndDet(IMEINo,StartTime,EndTime,DayEndFlag,ForDate,AppVersionID,[BatteryStatus],[LatCode],[LongCode])
	SELECT IMEINo,StartTime,EndTime,DayEndFlag,ForDate,AppVersionID,[BatteryStatus],[LatCode],[LongCode]
	FROM OPENXML(@hDoc,'database/table[@name=''tblDayStartEndDetails'']/row')
	WITH 
	(
		IMEINo [nvarchar](500) 'col[@name=''PDACode'']',
		StartTime [nvarchar](500) 'col[@name=''SyncTime'']',
		EndTime [nvarchar](500) 'col[@name=''EndTime'']',
		DayEndFlag [nvarchar](500) 'col[@name=''DayEndFlag'']',
		ForDate [nvarchar](500) 'col[@name=''ForDate'']',
		AppVersionID [nvarchar](500) 'col[@name=''AppVersionID'']',
		[BatteryStatus] nvarchar(500) 'col[@name="BatteryStatus"]',
		[LatCode] nvarchar(500) 'col[@name="LatCode"]',
		[LongCode] nvarchar(500)  'col[@name="LongCode"]'
		
	)

	--- Invoice execution
	INSERT INTO @udt_RawDataInvoiceExecution([TransDate],[OrderID],[strData],[AdditionalDiscount],[flgCancel])
	SELECT [TransDate],[OrderID],[strData],[AdditionalDiscount],[flgCancel]
	FROM OPENXML(@hDoc,'database/table[@name=''tblInvoiceButtonTransac'']/row')
	WITH 
	(
		[TransDate] [nvarchar](500) 'col[@name=''TransDate'']',
		[OrderID] [nvarchar](500) 'col[@name=''OrderID'']',
		[strData] [nvarchar](500) 'col[@name=''strData'']',
		[AdditionalDiscount] [nvarchar](500) 'col[@name=''additionalDiscount'']',
		[flgCancel] [nvarchar](500) 'col[@name=''flgCancel'']'
		
	)

	INSERT INTO @udt_RawDataInvoiceImages([StoreID],[OrderID],[ImageName],[InvNumber],[InvDate])
	SELECT [StoreID],[OrderID],[ImageName],[InvNumber],[InvDate]
	FROM OPENXML(@hDoc,'database/table[@name=''tblExecutionImages'']/row')
	WITH 
	(
		[StoreID] [nvarchar](500) 'col[@name=''StoreID'']',
		[OrderID] [nvarchar](500) 'col[@name=''OrderID'']',
		[ImageName] [nvarchar](500) 'col[@name=''ImageName'']',
		[InvNumber] [nvarchar](500) 'col[@name=''InvNumber'']',
		[InvDate] [nvarchar](500) 'col[@name=''InvDate'']'
		
	)

	-- Distributor Stock
	INSERT INTO @udt_RawDistProductStock([CustomerNodeID],[CustomerNodeType],[StockDate],[ProductNodeID],[ProductNodeType],[StockQty])
	SELECT [CustomerNodeID],[CustomerNodeType],[StockDate],[ProductNodeID],[ProductNodeType],[StockQty]
	FROM OPENXML(@hDoc,'database/table[@name=''tblDistributorSavedData'']/row')
	WITH 
	(
		[CustomerNodeID] [nvarchar](500) 'col[@name=''DistribtrId'']',
		[CustomerNodeType] [nvarchar](500) 'col[@name=''DistributorNodeType'']',
		[StockDate] [nvarchar](500) 'col[@name=''StockDate'']',
		[ProductNodeID] [nvarchar](500) 'col[@name=''ProductID'']',
		[ProductNodeType] [nvarchar](500) 'col[@name=''ProductNodeType'']',
		[StockQty] [nvarchar](500) 'col[@name=''EnteredValue'']'
		
	)


	--- ASM Tables
	--- Joint Visit Master
	insert into @udt_RawDataJointVisitMaster([JointVisitCode],[ManagerNodeId],[ManagerNodeType],[CoverageNodeID],[CoverageNodeType],[VisitDate],[VisitStartDateTime],[VisitEndDatetime],[MapAddress],[MapPinCode],[MapCity],[MapState],[ActualLatitude],[Actuallongitude],[LocProvider],[Accuracy],[BateryLeftStatus],
	[AllProviderData],[GPSLatitude],[GPSLongitude],[GPSAccuracy],[GPSAddress],[NetworkLatitude],[NetworkLongitude],[NetworkAccuracy],[NetworkAddress],[FusedLatitude],[FusedLongitude],[FusedAccuracy],[FusedAddress],[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking])	
	SELECT  [JointVisitCode],[ManagerNodeId],[ManagerNodeType],[CoverageNodeID],[CoverageNodeType],[VisitDate],[VisitStartDateTime],[VisitEndDatetime],[MapAddress],[MapPinCode],[MapCity],[MapState],[ActualLatitude],[Actuallongitude],[LocProvider],[Accuracy],[BateryLeftStatus],[AllProviderData],[GPSLatitude],[GPSLongitude],
	[GPSAccuracy],[GPSAddress],[NetworkLatitude],[NetworkLongitude],[NetworkAccuracy],[NetworkAddress],[FusedLatitude],[FusedLongitude],[FusedAccuracy],[FusedAddress],
	[flgLocationServicesOnOff],[flgGPSOnOff],[flgNetworkOnOff],[flgFusedOnOff],[flgInternetOnOffWhileLocationTracking]

	FROM OPENXML(@hDoc, 'database/table[@name=''tblJointVisitMstr'']/row')
	WITH 
	(
		[JointVisitCode] [nvarchar](500) 'col[@name=''JointVisitId'']',
		[ManagerNodeId] [nvarchar](500) 'col[@name=''ManagerNodeId'']',
		[ManagerNodeType] [nvarchar](500) 'col[@name=''ManagerNodeType'']',
		[CoverageNodeID] [nvarchar](500) 'col[@name=''CoverageAreaNodeID'']',
		[CoverageNodeType] [nvarchar](500) 'col[@name=''CoverageAreaType'']',
		[VisitDate] [nvarchar](500) 'col[@name=''VisitDate'']',
		[VisitStartDateTime] [nvarchar](500) 'col[@name=''VisitStartTime'']',
		[VisitEndDatetime] [nvarchar](500) 'col[@name=''VisitEndtime'']',
		[MapAddress] [nvarchar](500) 'col[@name=''MapAddress'']',
		[MapPinCode] [nvarchar](500) 'col[@name=''MapPinCode'']',
		[MapCity] [nvarchar](500) 'col[@name=''MapCity'']',
		[MapState] [nvarchar](500) 'col[@name=''MapState'']',
		[ActualLatitude] [nvarchar](500) 'col[@name=''ActualLatitude'']',
		[Actuallongitude] [nvarchar](500) 'col[@name=''ActualLongitude'']',
		[LocProvider] [nvarchar](500) 'col[@name=''LocProvider'']',
		[Accuracy] [nvarchar](500) 'col[@name=''Accuracy'']',
		[BateryLeftStatus] [nvarchar](500) 'col[@name=''BateryLeftStatus'']',
		[AllProviderData] [nvarchar](500) 'col[@name=''AllProviderData'']',
		[GPSLatitude] [nvarchar](500) 'col[@name=''GPSLatitude'']',
		[GPSLongitude] [nvarchar](500) 'col[@name=''GPSLongitude'']',
		[GPSAccuracy] [nvarchar](500) 'col[@name=''GpsAccuracy'']',
		[GPSAddress] [nvarchar](500) 'col[@name=''GpsAddress'']',
		[NetworkLatitude] [nvarchar](500) 'col[@name=''NetworkLatitude'']',
		[NetworkLongitude] [nvarchar](500) 'col[@name=''NetworkLongitude'']',
		[NetworkAccuracy] [nvarchar](500) 'col[@name=''NetworkAccuracy'']',
		[NetworkAddress] [nvarchar](500) 'col[@name=''NetworkAddress'']',
		[FusedLatitude] [nvarchar](500) 'col[@name=''FusedLatitude'']',
		[FusedLongitude] [nvarchar](500) 'col[@name=''FusedLongitude'']',
		[FusedAccuracy] [nvarchar](500) 'col[@name=''FusedAccuracy'']',
		[FusedAddress] [nvarchar](500) 'col[@name=''FusedAddress'']',
		[flgLocationServicesOnOff] [nvarchar](500) 'col[@name=''flgLocationServicesOnOff'']',
		[flgGPSOnOff] [nvarchar](500) 'col[@name=''flgGpsOnOff'']',
		[flgNetworkOnOff] [nvarchar](500) 'col[@name=''flgNetworkOnOff'']',
		[flgFusedOnOff] [nvarchar](500) 'col[@name=''flgFusedOnOff'']'	,
		[flgInternetOnOffWhileLocationTracking] [nvarchar](500) 'col[@name=''flgInternetOnOffWhileLocationTracking'']'

	)

	--- Joint Visit Detail
	insert into @udt_RawDataJointVisitDetail([JointVisitCode],[FellowPersonNodeId],[FellowPersonNodeType])	
	SELECT  [JointVisitCode],[FellowPersonNodeId],[FellowPersonNodeType]

	FROM OPENXML(@hDoc, 'database/table[@name=''tblJointVisitDetails'']/row')
	WITH 
	(
		[JointVisitCode] [nvarchar](500) 'col[@name=''JointVisitId'']',
		[FellowPersonNodeId] [nvarchar](500) 'col[@name=''FellowPersonNodeId'']',
		[FellowPersonNodeType] [nvarchar](500) 'col[@name=''FellowPersonNodeType'']'		

	)


	--- Gate Meeting TArget Saving
	insert into @udt_RawGateMeetingTarget(CovAreaNodeID,CovAreaNodeType,PersonNodeID,PersonNodeType,Dstrbn_Tgt,Sales_Tgt,PDACode,EntryDate)	
	SELECT  CovAreaNodeID,CovAreaNodeType,PersonNodeID,PersonNodeType,Dstrbn_Tgt,Sales_Tgt,PDACode,EntryDate

	FROM OPENXML(@hDoc, 'database/table[@name=''tblPersonGateMeetingTargetDetails'']/row')
	WITH 
	(
		CovAreaNodeID [nvarchar](500) 'col[@name=''CovAreaNodeID'']',
		CovAreaNodeType [nvarchar](500) 'col[@name=''CovAreaNodeType'']',
		PersonNodeID [nvarchar](500) 'col[@name=''PersonNodeID'']'	,
		PersonNodeType [nvarchar](500) 'col[@name=''PersonNodeType'']'	,
		Dstrbn_Tgt [nvarchar](500) 'col[@name=''Dstrbn_Tgt'']'	,
		Sales_Tgt [nvarchar](500) 'col[@name=''Sales_Tgt'']'	,
		PDACode [nvarchar](500) 'col[@name=''PDACode'']',
		EntryDate [nvarchar](500) 'col[@name=''EntryDate'']'

	)

	insert into @udt_RawGateMeetingTargetDet(CovAreaNodeID,CovAreaNodeType,PersonNodeID,PersonNodeType,SKUNodeID,SKUNodeType,Dstrbn_Tgt,Sales_Tgt,PDACode,EntryDate)	
	SELECT  CovAreaNodeID,CovAreaNodeType,PersonNodeID,PersonNodeType,SKUNodeID,SKUNodeType,Dstrbn_Tgt,Sales_Tgt,PDACode,EntryDate

	FROM OPENXML(@hDoc, 'database/table[@name=''tblPersonGateMeetingFocusedProductCoverageWiseDetails'']/row')
	WITH 
	(
		CovAreaNodeID [nvarchar](500) 'col[@name=''CovAreaNodeID'']',
		CovAreaNodeType [nvarchar](500) 'col[@name=''CovAreaNodeType'']',
		PersonNodeID [nvarchar](500) 'col[@name=''PersonNodeID'']'	,
		PersonNodeType [nvarchar](500) 'col[@name=''PersonNodeType'']'	,
		SKUNodeID [nvarchar](500) 'col[@name=''SKUNodeID'']'	,
		SKUNodeType [nvarchar](500) 'col[@name=''SKUNodeType'']'	,
		Dstrbn_Tgt [nvarchar](500) 'col[@name=''Dstrbn_Tgt'']'	,
		Sales_Tgt [nvarchar](500) 'col[@name=''Sales_Tgt'']'	,
		PDACode [nvarchar](500) 'col[@name=''PDACode'']',
		EntryDate [nvarchar](500) 'col[@name=''EntryDate'']'

	)



	UPDATE N SET EntryDate=@FileCreationDate FROM @udt_RawGateMeetingTarget N

	UPDATE @udt_RawDistProductStock SET PDACOde=@ImeiNo
----SELECT * FROM @udt_RawDataPersonRegDetails 
----SELECT * FROM  @udt_RawDataAttandanceDetails 
----SELECT * FROM  @udt_RawDataNoVisitStoreDetails 
----SELECT * FROM  @udt_RawDataStoreList 
----SELECT * FROM  @udt_RawDataStoreMultipleVisitDetail 
----SELECT * FROM  @udt_RawDataCustomerVisit 
----SELECT * FROM  @udt_RawDataStoreLocationDetails 
----SELECT * FROM  @udt_RawDataQuestAnsMstr 
----SELECT * FROM @udt_RawStoreCheckData
SELECT * FROM  @udt_RawDataDayEndDet 
----SELECT * FROM @udt_RawDataSelectedManagerDetails

----SELECT * FROM @udt_RawDataInvoiceHeader
----SELECT * FROM @udt_RawDataInvoiceDetail
----SELECT * FROM @udt_RawDataDeliveryDetails

----SELECT * FROM @udt_RawDataCollectionData
----SELECT * FROM @udt_RawDataProductReturnImage
----SELECT * FROM @udt_RawDataTableImage
----SELECT * FROM @udt_RawDataStoreCheckImage

----SELECT * FROM @udt_RawDataStoreCloseLocationDetail 
----SELECT * FROM @udt_RawDataStoreClosePhotoDetail 
----SELECT * FROM @udt_RawDataStoreReasonDetail 
----SELECT * FROM @udt_RawDataStoreReturnDetail 
------SELECT * FROM @udt_RawDataStoreReturnPhotoDetail 
----SELECT * FROM @udt_RawDataNewStoreLocationDetails
--@udt_RawDataJointVisitMaster udt_RawDataJointVisitMaster,
--@udt_RawDataJointVisitDetail udt_RawDataJointVisitDetail

EXEC sp_xml_removedocument @hDoc 

Declare @receivedDate varchar(100)=@year +'-'+@month +'-'+@day +' '+@hour +':'+@min +':'+@sec

EXEC SpSaveAllData @FileSetID,@ImeiNo,@FileName,@receivedDate,@udt_RawDataPersonRegDetails,@udt_RawDataAttandanceDetails,@udt_RawDataStoreLocationDetails,@udt_RawDataStoreList,@udt_RawDataQuestAnsMstr,@udt_RawDataNewStoreLocationDetails,@udt_RawDataCustomerVisit,@udt_RawDataInvoiceHeader,@udt_RawDataInvoiceDetail,@udt_RawDataDeliveryDetails,@udt_RawDataCollectionData,@udt_RawDataStoreReturnDetail,@udt_RawDataStoreCloseLocationDetail,@udt_RawDataStoreClosePhotoDetail,@udt_RawDataStoreReasonDetail,@udt_RawDataDayEndDet,@udt_RawDataNoVisitStoreDetails,@udt_RawDataStoreMultipleVisitDetail,@udt_RawStoreCheckData,@udt_RawDataSelectedManagerDetails,@udt_RawDataProductReturnImage,@udt_RawDataTableImage,@udt_RawDataStoreCheckImage,@udt_RawDataInvoiceExecution,@udt_RawDataInvoiceImages,@udt_RawDistProductStock,@udt_RawDataCartonMaster,@udt_RawDataCartonDetail,@udt_RawDataJointVisitMaster,@udt_RawDataJointVisitDetail,@udt_RawGateMeetingTarget,@udt_RawGateMeetingTargetDet

END TRY
BEGIN CATCH
insert into [dbo].[tblFileSetErrorLog](FileSetId,ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure
,ErrorLine
,ErrorMessage)
SELECT  @FileSetId,
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_LINE() AS ErrorLine  
        ,ERROR_MESSAGE() AS ErrorMessage; 

set @flgExecuted=2
UPDATE tblMstrFileSet SET FileDataProcessEndTime=GETDATE(),FileSetErrorId=1,flgSuccess=2 where FileSetId=@FileSetId

return
END CATCH

set @flgExecuted=1
update tblMstrFileSet set FileDataProcessEndTime=Getdate() where filesetid=@FileSetId
end

