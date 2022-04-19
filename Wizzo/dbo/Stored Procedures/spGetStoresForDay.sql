--exec [SpGetStoresForDay] @PDACode=N'38181548-F578-46D6-B665-C0979BDB3A25',@Date=N'14-Dec-2021',@RouteID=0,@RouteNodeType=0,@SysDate=N'14-Dec-2021',@AppVersionID=34,@flgAllRoutesData=1,@CoverageAreaNodeID=2,@coverageAreaNodeType=130
--exec SpGetStoresForDay '07-Dec-2021','DFD7BFE6-0299-423B-AE7B-48A3681E0141','0','0','07-Dec-2021','1',1,0,0

CREATE PROCEDURE [dbo].[spGetStoresForDay]   

@Date Date,

@PDACode VARCHAR(50),

@RouteID INT,

@RouteNodeType SMALLINT=170, 

@SysDate Datetime,

@AppVersionID INT ,

@flgAllRoutesData  TINYINT,  -- 1:to show all routes, 0: to show only given route 

@CoverageAreaNodeID INT = 0,

@coverageAreaNodeType SMALLINT  =0

AS  

BEGIN
	PRINT CAST(GETDATE() AS VARCHAR)
	DECLARE @PersonID INT     

	DECLARE @PersonType INT  

	--DECLARE @VisitDate Date

	--SET @VisitDate=CONVERT(Date,@Date,105)

	DECLARE @RouteVisitID INT
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	PRINT '@PersonID=' + CAST(@PersonID AS VARCHAR) 

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
	BEGIN
		IF @CoverageAreaNodeID>0 AND @coverageAreaNodeType>0
		BEGIN
			INSERT INTO  #CoverageArea
			SELECT @CoverageAreaNodeID,@coverageAreaNodeType
		END
		ELSE
		BEGIN
			INSERT INTO  #CoverageArea
			SELECT DISTINCT V.DSRAreaID,V.DSRAreaNodeType  
			FROM tblSalesPersonMapping P INNER JOIN [dbo].[VwCompanySalesHierarchy] V ON V.ASMAreaID=P.NodeID AND V.ASMAreaNodeType=P.NodeType 
			WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		END
	END



	DECLARE @LastVisitDtOfMerchandiser INT

	PRINT 'Called'

	PRINT CAST(GETDATE() AS VARCHAR)
	CREATE TABLE #tblOutletList (ID INT, StoreID int,StoreCode VARCHAR(50), StoreName VARCHAR(250),OwnerName VARCHAR(200),StoreContactNo VARCHAR(100),StoreAddress VARCHAR(500),StoreCity VARCHAR(200),StorePinCode BIGINT,StoreState VARCHAR(100),OutStanding FLOAT DEFAULT 0,OverDue FLOAT DEFAULT 0,flgRuleTaxVal TINYINT,StoreCatType VARCHAR(200),StoreLatitude decimal(28,24), StoreLongitude decimal(28,24), StoreType INT,LastTransactionDate Date, LastVisitDate Date, Sstat VARCHAR(10), IsClose INT, IsNextDat INT,flgGSTCapture INT,flgGSTCompliance INT,GSTNumber VARCHAR(50),flgSubmitFromQuotation tinyint, StoreChannelID INT,DBR VARCHAR(20),DisplaySeq INT,CollectionReq decimal(18, 4),StoreIDPDA VARCHAR(100),flgHasBussiness TINYINT DEFAULT 0,flgfeedbackReq TINYINT DEFAULT 0,RouteId INT,RouteNodeType INT,flgTransType TINYINT,OutletSalesPersonName VARCHAR(200),OutletSalesPersonContact BigInt,TaxNumber VARCHAR(20),IsComposite TINYINT DEFAULT 0,CityID INT,StateID INT,flgCollDefControl TINYINT DEFAULT 0,CollectionPer DECIMAL(10,2) DEFAULT 0,Region VARCHAR(100),RegionID INT,StoreTypeDesc VARCHAR(50),DBRName VARCHAR(100),IsDiscountApplicable TINYINT,WhatsappNumber BIGINT,EmailID VARCHAR(200),CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT,flgBoughtLast3Months TINYINT Default 0,flgStarOutlet TINYINT,[flgUnproductive(P3M)] TINYINT)

	--flgCollDefControl : 0=No Control,1=No Credit,Full Amount Need to be Collected,2=Previous Amount to be Collected.

	CREATE TABLE #DSRRouteList (CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT,CoverageArea VARCHAR(500),PersonNodeID INT,PersonNodeType SMALLINT,PersonName VARCHAR(200), RouteNodeID INT,RouteNodeType SMALLINT,Route VARCHAR(500),flgDefaultRoute TINYINT)

	----SELECT DISTINCT V.SalesAreaNodeID,V.SalesAreaNodeType,V.VanID VanNodeID,260 AS VanNodeType INTO #TodaysCoverageArea FROM tblVanStockMaster V INNER JOIN tblmstrperson P ON P.NodeID=V.SalesManNodeId AND P.NodeType=V.SalesManNodeType,(SELECT SalesmanNodeID,MAX(TransDate) TransDate FROM tblVanStockMaster WHERE SalesmanNodeID=@PersonID AND SalesmanNodeType=@PersonType AND CAST(TransDate AS DATE)<=@Date GROUP BY SalesmanNodeID) X  WHERE X.TransDate=V.TransDate AND X.SalesmanNodeID=V.SalesmanNodeID

	PRINT CAST(GETDATE() AS VARCHAR)
	INSERT INTO #DSRRouteList(CoverageAreaNodeID,CoverageAreaNodeType,RouteNodeID,RouteNodeType)
	SELECT DISTINCT  C.NodeID,C.NodeType,RouteNodeId,RouteNodetype FROM tblRoutePlanningVisitDetail RP INNER JOIN #CoverageArea C ON C.NodeID=RP.CovAreaNodeID AND C.NodeType=RP.CovAreaNodeType 
	
	--SELECT * FROM #DSRRouteList
	PRINT CAST(GETDATE() AS VARCHAR)
	INSERT INTO #tblOutletList (ID, StoreID, StoreName,StoreLatitude, StoreLongitude,StoreType,StoreChannelID,RouteId,RouteNodeType,DisplaySeq,DBR,StoreCatType,TaxNumber,IsComposite,StoreCode,Region,RegionID,StoreTypeDesc,DBRName,IsDiscountApplicable,flgGSTCompliance,GSTNumber,CoverageAreaNodeID,CoverageAreaNodeType)

	SELECT DISTINCT tblStoreMaster.StoreID AS ID, tblStoreMaster.StoreID,tblStoreMaster.StoreName AS StoreName,ISNULL(tblStoreMaster.[Lat Code], 0) AS StoreLatitude,     

ISNULL(tblStoreMaster.[Long Code], 0) AS StoreLongitude, 1 AS StoreType  ,tblStoreMaster.ChannelId,RCM.RouteID,RCM.RouteNodeType, 1,'0-' + CAST(tblStoreMaster.DBID AS VARCHAR) + '-' + CAST(tblStoreMaster.DBNodeType AS VARCHAR),'',0,0 , StoreCode , NULL,0,tblStoreMaster.ShopType,DBR.Descr,tblStoreMaster.IsDiscountApplicable,0 ,tblStoreMaster.GSTNumber,R.CoverageAreaNodeID,R.CoverageAreaNodeType

	FROM    tblRouteCoverageStoreMapping RCM INNER JOIN tblStoreMaster(nolock) ON RCM.StoreID = tblStoreMaster.StoreID    

	INNER JOIN tblMstrChannel on tblMstrChannel.ChannelId=tblStoreMaster.ChannelId

	INNER JOIN #DSRRouteList R ON RCM.RouteID=R.RouteNodeID AND RCM.RouteNodeType=R.RouteNodeType

	--LEFT OUTER JOIN tblPriceRegionMstr PR ON PR.PrcRgnNodeId=tblStoreMaster.RegionID

	LEFT OUTER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=tblStoreMaster.DBID AND DBR.NodeType=tblStoreMaster.DBNodeType

	WHERE   (ISNULL(tblStoreMaster.flgActive, 1) = 1) AND CAST(GETDATE() AS DATE) BETWEEN RCM.FromDate AND RCM.ToDate 


	--SELECT * FROM #tblOutletList


	PRINT CAST(GETDATE() AS VARCHAR)
	---- Contact person updation

	UPDATE O SET OwnerName=RTRIM(LTRIM(ISNULL(C.FName,'') + ' ' + ISNULL(C.Lname,''))),StoreContactNo=MobNo ,WhatsappNumber=CASE WHEN C.IsSameWhatsappnumber=1 THEN MobNo ELSE alternatewhatsappNo END,EmailID=C.EMailID	
	FROM #tblOutletList O INNER JOIN [tblOutletContactDet] C ON C.StoreID=O.StoreID WHERE C.ContactType=1
	
	-----################################################################################################### 
	--- Logic to update the collection flag and available credit limit percentage ###########################################################################################


	--###################################################################################################################################################################3##


	PRINT 'Called'
	PRINT CAST(GETDATE() AS VARCHAR)
	--- Store Address Updation #######################################################################################

	UPDATE O SET StoreAddress=OA.StoreAddress1,StoreCity=OA.City,StorePinCode=OA.PinCode ,StoreState=OA.State,CityID=OA.CityID,StateID=OA.StateID FROM #tblOutletList O INNER JOIN tblOutletAddressDet OA ON OA.StoreID=O.StoreID

	PRINT 'Called1'

	---################################################################################################################



	--- Store Outstanding Updation ########################################################################################

		SELECT V.StoreID, MAX(V.VisitID) AS VisitID, 0 AS flgOrder INTO [#MaxLastVisit]

		FROM tblVisitMaster(nolock) V INNER JOIN #tblOutletList O ON V.StoreID=O.StoreID

		WHERE CAST(VisitDate AS DATE)<=@Date 

		GROUP BY V.StoreID

	PRINT CAST(GETDATE() AS VARCHAR)		
	PRINT CAST(GETDATE() AS VARCHAR)

	update #tblOutletList set  flgSubmitFromQuotation=0 



	UPDATE #tblOutletList SET flgRuleTaxVal=1   --- 1=Price Before Tax  2=Price After Tax



	UPDATE #tblOutletList SET flgTransType=1   --- 1=Invoice  2=Regular Order,3=Sample,4=Trial

	

	UPDATE O SET O.StoreIDPDA=P.StoreID FROM #tblOutletList O INNER JOIN tblStoreMaster S ON S.StoreID=O.StoreID LEFT OUTER join [tblPDASyncStoreMappingMstr] P ON P.OrgStoreID=S.StoreID

	
	PRINT CAST(GETDATE() AS VARCHAR)
----	UPDATE O SET O.CollectionReq=A.CollectionReq FROM #tblOutletList O INNER JOIN tblStoreCollectionDet A ON O.StoreId=A.StoreId INNER JOIN

----(SELECT A.StoreId,MAX(Entrydate) LastEntrydate FROM tblStoreCollectionDet A INNER JOIN  #tblOutletList B ON A.StoreId=B.StoreId GROUP BY A.StoreId) AA ON A.StoreId=AA.StoreId AND A.Entrydate=AA.LastEntrydate



	UPDATE #tblOutletList SET LastTransactionDate =  ISNULL((SELECT MAX(OrderDate)  

	FROM [dbo].[tblOrderMaster]  WHERE StoreID = #tblOutletList.StoreID AND convert(datetime,OrderDate ,105) <=  @Date), @Date) 

	PRINT 4

	UPDATE #tblOutletList SET LastVisitDate =    ISNULL((SELECT MAX(convert(datetime,VisitDate,105))  

	FROM [dbo].[tblVisitMaster] WHERE StoreID = #tblOutletList.StoreID AND CONVERT(VARCHAR,convert(datetime,VisitDate,105),112) <= CONVERT(VARCHAR,@Date,112)),	@Date)

	PRINT 5  

	

	UPDATE #tblOutletList   SET Sstat = 4    ,flgSubmitFromQuotation=[dbo].[tblVisitMaster].flgSubmitSalesQuoteOnly

	FROM [dbo].[tblVisitMaster] INNER JOIN #tblOutletList ON #tblOutletList.StoreID = [tblVisitMaster].StoreID AND CONVERT(VARCHAR,VisitDate,112) =CONVERT(VARCHAR,@Date,112)    


	PRINT CAST(GETDATE() AS VARCHAR)
	UPDATE #tblOutletList SET IsClose = ISNULL(flgOutletClose,0),IsNextDat = ISNULL(flgOutletNextDay,0) FROM [dbo].[tblVisitMaster]  

	WHERE [dbo].[tblVisitMaster].StoreID = #tblOutletList.StoreID AND CONVERT(VARCHAR,convert(datetime,VisitDate,105),112) =CONVERT(VARCHAR,@Date,112)


	UPDATE O SET flgBoughtLast3Months=1 FROM 
	tblOrderMaster(nolock) OM INNER JOIN tblOrderDetail(nolock) OD ON OD.OrderID=OM.OrderID INNER JOIN #tblOutletList O ON O.StoreID=OM.StoreID WHERE OD.OrderQty>0 AND DATEADD(d,-90,getdate()) <OrderDate


	PRINT CAST(GETDATE() AS VARCHAR)
	SELECT ID,StoreID,StoreName,StoreLatitude,StoreLongitude,StoreType,StoreChannelID,LastTransactionDate,LastVisitDate,ISNULL(Sstat,0) AS Sstat, ISNULL(IsClose,0) AS IsClose, ISNULL(IsNextDat,0) AS IsNextDat, A.RouteID,ISNULL(STUFF((SELECT '$' + CAST(AA.PymtStageId AS VARCHAR)+'~'+CAST(convert(numeric(6,0), AA.Percentage) AS VARCHAR)+'~'+CAST(AA.CreditDays AS VARCHAR)+'~'+CAST([dbo].[fncSetAmtFormat](AA.CreditLimit) AS VARCHAR)+'~'+ISNULL(STUFF((SELECT '|' +  CAST(AB.PaymentModeId AS VARCHAR),A.RouteNodeType,A.DisplaySeq

	FROM tblStorePaymentModeMap AB WHERE AB.StorePaymentStageMappingId=AA.StorePaymentStageMappingId FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,''),'')   

	FROM tblStorePaymentStageMap AA WHERE A.StoreId=AA.StoreId FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,''),'') as PaymentStage  ,0 AS flgHasQuote,1 AS flgAllowQuotation  ,flgSubmitFromQuotation,A.RouteNodeType,DBR

,CollectionReq,A.StoreIDPDA,A.flgHasBussiness,A.flgfeedbackReq,A.DisplaySeq,OwnerName,StoreContactNo,StoreCatType, StoreAddress,StoreCity,StorePinCode,StoreState,flgRuleTaxVal ,OutStanding,OverDue,flgTransType,OutletSalesPersonName,OutletSalesPersonContact ,A.TaxNumber,A.IsComposite,A.CityID,A.StateID,flgCollDefControl,CollectionPer , StoreCode ,Region,RegionID,StoreTypeDesc,DBRName,IsDiscountApplicable,flgGSTCompliance,GSTNumber,EmailID,WhatsappNumber,CoverageAreaNodeID,CoverageAreaNodeType,flgBoughtLast3Months,0 AS P3MValue,0 AS MTDValue,0 AS NoOfBrands,0 AS flgProductive,flgStarOutlet,[flgUnproductive(P3M)]

	INTO #Outlet    

	FROM #tblOutletList  A 


	--SELECT * FROM #Outlet
	IF @PersonType IN (210)
	BEGIN
		PRINT 'ASM App'
		DECLARE @p udt_StoreID
		INSERT INTO @P SELECT DISTINCT StoreID FROM #Outlet
		CREATE TABLE #OrderData(StoreId INT,P3MVolumeInKG FLOAT,MTDVolumeInKG FLOAT,NoOfBrands INT,FlgProductive TINYINT)
		INSERT INTO #OrderData(StoreId,P3MVolumeInKG,MTDVolumeInKG,NoOfBrands,FlgProductive)
		EXEC [SpGetStorelevelDataForPDA] @Date,@p

		UPDATE A SET A.P3MValue=B.P3MVolumeInKG,A.MTDValue=B.MTDVolumeInKG,A.NoOfBrands=B.NoOfBrands,A.FlgProductive=B.FlgProductive
		FROM #Outlet A INNER JOIN #OrderData B ON A.StoreId=B.StoreId
	END

	UPDATE O SET flgStarOutlet=R.flgStarOutlets,[flgUnproductive(P3M)]=R.NonProductive_P3M FROM #Outlet O INNER JOIN tblRptBeatProfileData(nolock) R ON R.StoreId=O.StoreID

	PRINT CAST(GETDATE() AS VARCHAR)
	SELECT ID, StoreID, StoreName  AS StoreName,StoreLatitude, StoreLongitude,  StoreType,FORMAT(LastTransactionDate,'dd-MMM') LastTransactionDate, FORMAT(LastVisitDate,'dd-MMM') LastVisitDate,Sstat,IsClose,IsNextDat,RouteID, CASE WHEN ISNULL(PaymentStage,'')='' THEN '2~100~0~0.00~2|4' ELSE PaymentStage END AS PaymentStage,flgHasQuote,CASE StoreChannelID WHEN 2 THEN 1 ELSE 0 END AS flgAllowQuotation, flgSubmitFromQuotation,RouteNodeType ,DBR,CollectionReq,StoreIDPDA,flgHasBussiness,flgfeedbackReq,OwnerName,StoreContactNo,StoreCatType, StoreAddress,StoreCity,StorePinCode,StoreState,flgRuleTaxVal ,OutStanding,OverDue,flgTransType,OutletSalesPersonName AS SalesPersonName,OutletSalesPersonContact AS SalesPersonContact  ,TaxNumber, IsComposite,CityID,StateID,flgCollDefControl,CollectionPer , StoreCode, Region,RegionID,StoreTypeDesc,DBRName,CASE ISNULL(IsDiscountApplicable,0) WHEN 0 THEN 'No' ELSE 'Yes' END IsDiscountAllow, 1 AS IsDiscountApplicable,flgGSTCompliance,GSTNumber,EmailID,WhatsappNumber,CoverageAreaNodeID,CoverageAreaNodeType,flgBoughtLast3Months,P3MValue,MTDValue,NoOfBrands,flgProductive,flgStarOutlet,[flgUnproductive(P3M)]
	FROM #Outlet  

	ORDER BY RouteID,DisplaySeq



	----SELECT  A.PrdId,b.customerid,max(A.SalesQuoteId) as SalesQuoteId INTO #tmpSalesQuote 

	----FROM    tblSalesQuoteDetail AS A INNER JOIN  tblSalesQuoteMaster AS b ON A.SalesQuoteId = b.SalesQuoteId  

	----INNER JOIN #Outlet c ON c.storeid=b.customerid 

	----WHERE   @Date between  A.ValidFrom AND A.ValidTo  and b.SalesQuotePrcsId=5 GROUP BY A.PrdId,b.customerid  

	
	PRINT CAST(GETDATE() AS VARCHAR)
	SELECT b.StoreID,b.OutAddTypeID,Left(isnull(StoreAddress1,'') +isnull(' ,'+StoreAddress2,'')+ISNULL(', '+B.City,'')+ISNULL(' PinCode:-'+convert(varchar,PinCode),''),25) as Address,isnull(StoreAddress1,'') +isnull(' ,'+StoreAddress2,'')+ISNULL(', '+B.City,'')+ISNULL(' PinCode:-'+convert(varchar,PinCode),'') as AddressDet,b.OutAddID INTO #AddDet 

	FROM #tblOutletList A join tblOutletAddressDet B on A.StoreId=B.StoreId --left join tblLoclvl3 c on b.CityId=c.nodeid         



	INSERT INTO #AddDet(StoreID,OutAddTypeID,Address,AddressDet,OutAddID)

	SELECT AA.StoreID,AA.OutAddTypeID,AA.Address,AA.AddressDet,AA.OutAddID FROM

	(SELECT b.StoreID,2 AS OutAddTypeID,Left(isnull(StoreAddress1,'') +isnull(' ,'+StoreAddress2,'')+ISNULL(', '+B.City,'')+ISNULL(' PinCode:-'+convert(varchar,PinCode),''),25) as Address,isnull(StoreAddress1,'') +isnull(' ,'+StoreAddress2,'')+ISNULL(', '+B.City,'')+ISNULL(' PinCode:-'+convert(varchar,PinCode),'') as AddressDet,b.OutAddID 

	from #tblOutletList A join tblOutletAddressDet B on A.StoreId=B.StoreId) AA --left join tblLoclvl3 c on b.CityId=c.nodeid  

	LEFT OUTER JOIN #AddDet C ON AA.StoreID=C.StoreID AND AA.OutAddTypeID=C.OutAddTypeID WHERE C.StoreId IS NULL AND C.OutAddTypeID IS NULL



	SELECT * FROM #AddDet ORDER BY StoreId,OutAddTypeID



	----SELECT a.PrdId,a.customerid as StoreId,b.RateOffer as QPBT,b.RateOffer+(b.RateOffer*b.TaxRate/100) as QPAT,b.RateOffer*b.TaxRate/100 AS QPTaxAmt,b.MinDlvryQty,b.UOMID 

	----from #tmpSalesQuote A join tblSalesQuoteDetail B  ON A.PrdId=B.PrdId  AND A.SalesQuoteId=B.SalesQuoteId  


	PRINT CAST(GETDATE() AS VARCHAR)
	SELECT tblVisitMaster.StoreID, tblVisitMaster.VisitID INTO [#LastVisit] 

	FROM tblVisitMaster INNER JOIN tblOrderMaster ON tblVisitMaster.VisitID = tblOrderMaster.VisitID join #tblOutletList C on C.StoreId= tblVisitMaster.StoreId 

	WHERE CAST(VisitDate AS DATE)<=@Date  


	DECLARE @FYID INT=0
	SELECT @FYID=FYID FROM TBLfINANCIALYEAR WHERE @Date Between FYStartDate and FYEndDate
	DECLARE @LastDeliveryNoteNumber VARCHAR(20)
	----SELECT @LastDeliveryNoteNumber=ISNULL(LastGenNum,0) FROM [tblMstrSequenceForTrnTable_Direct] WHERE TableUnqTag='I' AND SalesNodeId=@VanNodeID AND SalesNodeType=@VanNodetype AND FYID=@FYID

	SELECT ISNULL(@LastDeliveryNoteNumber,0) LastDeliveryNoteNumber

	
	SELECT DISTINCT PD.DBRCode,PD.Descr Distributor,RD.DBNodeID,RD.DBNodeType,RD.RetailerCode,RD.RetailerName,RD.Address,RD.Comment,RD.RetFeedback,RD.ContactNumber FROM tblPotentialDistributor PD INNER JOIN tblPotentialDistributorRetailerDet RD ON RD.DBNodeID=PD.NodeID AND RD.DBNodeType=PD.NodeType WHERE PD.EntryPersonNodeID=@PersonID AND PD.EntryPersonNodeType=@PersonType --AND PD.flgFinalSubmit=0



END


