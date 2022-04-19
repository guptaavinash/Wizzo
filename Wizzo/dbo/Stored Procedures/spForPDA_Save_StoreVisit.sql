--DROP PROC [spForPDA_Save_StoreVisit]
--GO
CREATE PROCEDURE [dbo].[spForPDA_Save_StoreVisit]
( 
	@StoreID INT,
	@ActualLatitude DECIMAL(27,24),
	@ActualLongitude DECIMAL(27,24),
	@VisitStartTS Datetime,
	@VisitEndTS Datetime,
	@VisitForDate  Date,
	@PDA_IMEI  VARCHAR(100),
	@LocationProvider VARCHAR(100),
	@Accuracy VARCHAR(100),
	@BatteryLeftStatus INT,
	@OutletNextDay TINYINT,
	@OutletClose TINYINT,
	@flgSubmitSalesQuoteOnly TINYINT, --0=No Sales Quote,1=Sales Quote Only
	@flgVisitSubmitType TINYINT, --0Submit from Order Screen , 1=Submit from external of Order Screen.
	@flgCollectionStatus TINYINT=0,
	@StoreVisitCode VARCHAR(100),
	@tblStoreVisits udt_StoreVisits ReadOnly,
	@tblGPSInfo udt_GPSInfo ReadOnly,
	@flgLocationServicesOnOff TINYINT,
	@flgGPSOnOff TINYINT,
	@flgNetworkOnOff TINYINT,
	@flgFusedOnOff TINYINT,
	@flgInternetOnOff TINYINT,
	@flgRestart TINYINT=0,
	@VisitId INT OUTPUT,
	@VisitComments VARCHAR(500),
	@flgIsPicAllowed TINYINT,
	@NOPicReason VARCHAR(500),
	@FileSetID INT,
	@IsGeoValidated TINYINT,
	@flgTelephonicCall TINYINT=0,
	@NoOrderReasonID INT,
	@NoOrederReasonDecr VARCHAR(200),
	@TeleCallingID INT
)
AS
BEGIN
PRINT @VisitStartTS 
	PRINT @VisitEndTS
--set @VisitStartTS =Convert(varchar,getdate())
--	set @VisitEndTS =Convert(varchar,getdate())
	PRINT @VisitStartTS 
	PRINT @VisitEndTS 
PRINT 1
	DECLARE @Channel VARCHAR(100)

	
	DECLARE @StoreVisitID INT, @RouteVisitID INT, @DeviceID INT, @OrderID INT, @OrderDetailID INT
	DECLARE @ProductReturnIdXML INT
	DECLARE @ProductReturnIdTran INT
	DECLARE @FlgOnRoute Tinyint
	DECLARE @PersonNodeID INT
	DECLARE @PersonType TINYINT
	DECLARE @RouteNodeID INT
	DECLARE @RouteNodeType INT

	--------------------------added by gaurav  to save the visit co-ordinate as co-ordinate of store if not available--------------------

	IF EXISTS(SELECT 1 FROM tblStoreMaster WHERE StoreId=@StoreID AND ISNULL([Lat Code],0)=0)
	BEGIN
		UPDATE tblStoreMaster SET [Lat Code]=@ActualLatitude,[Long Code]=@ActualLongitude WHERE StoreId=@StoreID
	END

	------------------------------------------------------------------------------------------------------------------------------------


	----Select @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI
	----SELECT @PersonNodeID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@DeviceID  AND GETDATE() BETWEEN DateFrom AND DateTo
	DECLARE @EntryPersonNodeType SMALLINT,@EntryPersonNodeID INT

	SELECT @EntryPersonNodeID=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@PDA_IMEI) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	SELECT @EntryPersonNodeType=PersonType FROM tblSalesPersonMapping WHERE PersonNodeID=@EntryPersonNodeID

	SELECT @RouteNodeID=RouteID,@RouteNodeType=Routenodetype  FROM [tblRouteCoverageStoreMapping]
	WHERE StoreID=@StoreID AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate

	PRINT '@RouteNodeID=' + CAST(@RouteNodeID AS VARCHAR)
	PRINT '@RouteNodeType=' + CAST(@RouteNodeType AS VARCHAR)

	SELECT @PersonNodeID=RV.DSENodeId,@PersonType=RV.DSENodeType FROM tblRoutePlanningVisitDetail RV WHERE RV.RouteNodeId=@RouteNodeID AND RV.RouteNodetype=@RouteNodeType AND RV.VisitDate>=CAST(GETDATE() AS DATE)

	IF ISNULL(@PersonNodeID,0)=0
		SELECT @PersonNodeID=RV.DSENodeId,@PersonType=RV.DSENodeType FROM tblRoutePlanningVisitDetail RV WHERE RV.RouteNodeId=@RouteNodeID AND RV.RouteNodetype=@RouteNodeType ORDER BY VisitDate DESC --AND RV.VisitDate>=CAST(GETDATE() AS DATE) 


	----SELECT        @PersonNodeID = tblSalesPersonMapping.PersonNodeID,@PersonType=tblSalesPersonMapping.PersonType
	----FROM            tblSalesPersonMapping WHERE tblSalesPersonMapping.NodeID = @RouteNodeID AND tblSalesPersonMapping.NodeType=@RouteNodeType	
	----AND (CAST(@VisitForDate AS DATE) BETWEEN  CAST(tblSalesPersonMapping.FromDate AS DATE) AND CAST(tblSalesPersonMapping.ToDate AS DATE)) 

	--SELECT @PersonNodeID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDA_IMEI) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	-- To Get the Van Assigment detail
	DECLARE @VanID INT

	----SELECT @VanID=SH.VanID  FROM tblSalesHierVanMapping SH INNER JOIN tblSalesPersonMapping SM ON SM.NodeID=SH.SalesNodeID AND SM.NodeType=SH.SalesNodetype INNER JOIN tblMstrPerson P ON P.NodeID=SM.PersonNodeID AND P.NodeType=SM.PersonType WHERE @VisitForDate BETWEEN SM.FromDate AND SM.ToDate AND CAST(@VisitForDate AS DATE) BETWEEN CAST(SH.Fromdate AS DATE) AND CAST(SH.Todate AS DATE) AND @VisitForDate BETWEEN P.FromDate AND P.ToDate AND SM.PersonNodeID=@PersonNodeID AND SM.PersonType=@PersonType


	
	----SELECT @VanID=VanID FROM tblVanStockMaster V,(SELECT SalesManNodeId,MAX(TransDate) TransDate FROM tblVanStockMaster WHERE SalesManNodeId=@PersonNodeID AND SalesManNodeType=@PersonType AND CAST(TransDate AS DATE)<=CAST(@VisitForDate AS DATE) GROUP BY SalesManNodeId) X WHERE X.TransDate=V.TransDate AND X.SalesManNodeId=V.SalesManNodeId

	SELECT  @VanID=VanID FROM dbo.fnGetLastPersonAssignedBasedOnPDACode(@PDA_IMEI,@VisitForDate)

	-- Commented By Avinash as any person can visit any coverage area
	----SELECT        @PersonNodeID = tblSalesPersonMapping.PersonNodeID,@PersonType=tblSalesPersonMapping.PersonType
	----FROM            tblSalesPersonMapping WHERE tblSalesPersonMapping.NodeID = @RouteID AND tblSalesPersonMapping.NodeType=@RouteNodeType	
	----AND (CONVERT(Date,@VisitForDate,105) BETWEEN  CAST(tblSalesPersonMapping.FromDate AS DATE) AND CAST(tblSalesPersonMapping.ToDate AS DATE)) 

	--Select [dbo].[fncGetRouteVisitID](CONVERT(DATE,@VisitStartTS,105), @RouteID, @DeviceID,@RouteNodeTyoe)

	PRINT '@StoreID=' + CAST(ISNULL(@StoreID,0) AS VARCHAR)

	--SELECT @RouteNodeID=RouteID,@RouteNodeType=Routenodetype  FROM [tblRouteCoverageStoreMapping] WHERE StoreID=@StoreID AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate

	--SELECT @RouteNodeID=RouteNodeId,@RouteNodeType=RouteNodeType FROM tblRouteCalendar(nolock) RC WHERE  StoreId=@StoreID AND SONodeId=@PersonNodeID AND SONodeType=@PersonType
	SELECT @RouteNodeID=RM.RouteID, @RouteNodeType=RM.RouteNodeType FROM tblRouteCoverageStoreMapping RM WHERE CAST(GETDATE() AS DATE) BETWEEN RM.FromDate AND RM.ToDate AND  StoreId=@StoreID 

	PRINT '@RouteNodeID=' + CAST(@RouteNodeID AS VARCHAR)
	PRINT '@RouteNodeType=' + CAST(@RouteNodeType AS VARCHAR)

	----SELECT @RouteVisitID=MAX(RouteVisitID) FROM tblTranVisitDetails T WHERE T.RouteID=@RouteNodeID AND T.RouteType=@RouteNodeType  AND
	----CAST(VisitForDate AS DATE)=CAST(@VisitForDate AS DATE)
	
	----PRINT '@RouteVisitID=' + CAST(ISNULL(@RouteVisitID,0) AS VARCHAR)
	DECLARE @WeekNumber INT, @DayofWeek INT
	--select @WeekNumber = datepart(day, datediff(day, 0, CONVERT(DATETIME,@VisitForDate,105))/7 * 7)/7 + 1
	SET DATEFirst 1
	/*
	SELECT @WeekNumber=DATEPART(WEEK, CONVERT(DATETIME,@VisitForDate,105))  -  DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,CONVERT(DATETIME,@VisitForDate,105)), 0))+ 1
PRINT '@WeekNumber=' + CAST(ISNULL(@WeekNumber,0) AS VARCHAR)

	select @DayofWeek = datepart(dw,CONVERT(DATETIME,@VisitForDate,105)) 
	SET DATEFirst 7
--print 3	
	Set @FlgOnRoute = 0
	Select @FlgOnRoute=1 From tblRouteCoverage INNER JOIN [dbo].[tblCoverageFrequencyWeekMappig] ON
	[dbo].[tblCoverageFrequencyWeekMappig].[CovFrqID] = tblRouteCoverage.CovFrqID
	Where RouteID = @RouteId AND NodeType=@RouteNodeType AND [dbo].[tblCoverageFrequencyWeekMappig].WeekNo = @WeekNumber AND Weekday = @DayofWeek
	AND CONVERT(VARCHAR, CONVERT(DATETIME,@VisitForDate,105), 112) BETWEEN CONVERT(VARCHAR,tblRouteCoverage.FromDate,112) AND 
	CONVERT(VARCHAR,tblRouteCoverage.ToDate,112)
	*/
	Set @FlgOnRoute = 0

	SELECT @FlgOnRoute=[dbo].[fnGetPlannedVisit](@RouteNodeID,@RouteNodeType,@VisitForDate)

	SET DATEFirst 7

--print 4	
	SELECT @VisitID = VisitID FROM tblVisitMaster WHERE CAST(VisitDate AS DATE)=@VisitForDate AND StoreID = @StoreID
	--SELECT @VisitID=VisitID FROM tblVisitMaster WHERE StoreVisitCode=@StoreVisitCode

	--BEGIN TRANSACTION
	IF ISNULL(@VisitID,0)=0
	BEGIN
		---- SELECT @OrderID = OrderID FROM tblOrderMaster WHERE VisitID = @VisitID
		---- Select @OrderDetailID = OrderDetailID FROM tblOrderDetail WHERE OrderID = @OrderID
		----BEGIN TRANSACTION	
		----	BEGIN
		----			DELETE FROM tblVisitMaster WHERE VisitID = @VisitID
		----			--DELETE FROM tblOrderDelivery WHERE OrderDetailID = @OrderDetailID
		----			--DELETE FROM tblOrderTaxDetail WHERE OrderDetailID = @OrderDetailID
		----			DELETE FROM tblOrderDetail WHERE OrderID = @OrderID
		----			DELETE FROM tblOrderMaster WHERE VisitID = @VisitID
		----			DELETE FROM tblOrderReturnMstr WHERE VisitID=@VisitID
		----	END
		----COMMIT TRANSACTION
		INSERT INTO tblVisitMaster (RouteID,RouteType,RouteVisitID,StoreID,VisitLatitude,VisitLongitude,VisitDate,DeviceVisitStartTS,DeviceVisitEndTS,FlgOnRoute,flgOutletNextDay,
		flgOutletClose,BatteryLeftStatus,LocationProvider,Accuracy,TIMESTAMP,flgSubmitSalesQuoteOnly,flgVisitSubmitType,SalesPersonID,SalesPersonType,flgCollectionStatus,VanID,StoreVisitCode,EntryPersonNodeID,EntryPersonNodeType,VisitComments,flgIsPicAllowed,NoPicReason,FileSetID,isGeoValidated,flgTelephonicCall,NoOrderReasonID,NoOrderReasonDescr,TeleCallingID)
		SELECT ISNULL(@RouteNodeID,0),ISNULL(@RouteNodeType,0),@RouteVisitID, @StoreID, @ActualLatitude, @ActualLongitude, @VisitForDate,@VisitStartTS,@VisitEndTS, @FlgOnRoute, @OutletNextDay, @OutletClose,@BatteryLeftStatus, @LocationProvider, @Accuracy, GETDATE(),@flgSubmitSalesQuoteOnly,@flgVisitSubmitType, @PersonNodeID,@PersonType,@flgCollectionStatus,@VanID,@StoreVisitCode,@EntryPersonNodeID,@EntryPersonNodeType,@VisitComments,@flgIsPicAllowed,@NOPicReason,@FileSetID,@IsGeoValidated,@flgTelephonicCall,@NoOrderReasonID,@NoOrederReasonDecr,@TeleCallingID

			
		SELECT @VisitID = IDENT_CURRENT('tblVisitMaster')
	END
	ELSE
	BEGIN
		UPDATE V SET RouteID=ISNULL(@RouteNodeID,0),RouteType=ISNULL(@RouteNodeType,0),RouteVisitID=@RouteVisitID,VisitLatitude=@ActualLatitude,VisitLongitude=@ActualLongitude,DeviceVisitStartTS=@VisitStartTS,DeviceVisitEndTS=@VisitEndTS,FlgOnRoute=@FlgOnRoute,flgOutletNextDay=@OutletNextDay, flgOutletClose=@OutletClose, BatteryLeftStatus=@BatteryLeftStatus,LocationProvider=@LocationProvider,Accuracy=@Accuracy,TIMESTAMP= GETDATE(),flgSubmitSalesQuoteOnly=@flgSubmitSalesQuoteOnly, flgVisitSubmitType=@flgVisitSubmitType,SalesPersonID=@PersonNodeID,SalesPersonType=@PersonType,flgCollectionStatus=@flgCollectionStatus,VanID=@VanID,StoreVisitCode=@StoreVisitCode,EntryPersonNodeID=@EntryPersonNodeID,EntryPersonNodeType=@EntryPersonNodeType,VisitComments=@VisitComments,flgIsPicAllowed=@flgIsPicAllowed,NoPicReason=@NOPicReason,IsGeoValidated=@IsGeoValidated,flgTelephonicCall=@flgTelephonicCall,NoOrderReasonID=@NoOrderReasonID,NoOrderReasonDescr=@NoOrederReasonDecr,TeleCallingID=@TeleCallingID
		FROM tblVisitMaster V WHERE CAST(VisitDate AS DATE)=@VisitForDate AND StoreID = @StoreID
	END

	UPDATE V SET Address=T.Address, Distance=T.Distance,AllProviderData=T.AllProviderData,GPSLatitude=T.GPSLatitude,GPSLongitude=T.GPSLongitude,GPSAccuracy=T.GPSAccuracy,
		GPSAddress=T.GPSAddress,NetworkLatitude=T.NetworkLatitude,NetworkLongitude=T.NetworkLongitude,NetworkAccuracy=T.NetworkAccuracy,NetworkAddress=T.NetworkAddress,	  FusedLatitude=T.FusedLatitude,FusedLongitude=T.FusedLongitude,FusedAccuracy=T.FusedAccuracy,FusedAddress=T.FusedAddress,flgLocationServicesOnOff=@flgLocationServicesOnOff,flgGPSOnOff=@flgGPSOnOff,flgNetworkOnOff=@flgNetworkOnOff,flgFusedOnOff=@flgFusedOnOff,flgInternetOnOffWhileLocationTracking=@flgInternetOnOff,flgRestart=@flgRestart
		FROM tblVisitMaster V LEFT OUTER JOIN @tblGPSInfo T ON T.StoreID=V.StoreID WHERE V.VisitID = @VisitID
		
print 5

--- Code to make an entry in the store visit detail tale #########################################################################################################################################
DELETE FROM tblVisitDet WHERE StoreVisitCode=@StoreVisitCode
INSERT INTO tblVisitDet(StoreID,VisitID,StoreVisitCode,TempStoreVisitCode,VisitStartDate,VisitEndDate,TimestampIns,LatCode,LongCode,flgTelePhonic)
SELECT @StoreID,@VisitID,StoreVisitCode,TempStoreVisitCode,VisitStartTime,VisitEndTime,GETDATE(),[LatCode],[LongCode],[flgTelePhonic] FROM @tblStoreVisits
---##########################################################################################################################################################################################$###	


-- Code to update if the person is in joint working with manager
UPDATE V SET V.flgIsinJointVisit=1,V.JointVisitID=SV.JointVisitID FROM tblVisitMaster V INNER JOIN tblSFACustomerSupVisit SV ON SV.StoreID=V.StoreID AND SV.VisitDate=V.VisitDate
	
	SELECT @VisitID AS StoreVisitID
	    
	--COMMIT TRANSACTION
	RETURN 0	

	--Error_exit:
	--	IF (@@TRANCOUNT > 0) 
	--		ROLLBACK TRANSACTION
	--	RETURN -1 -- Failed Transaction
	

END





