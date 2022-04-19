
--EXEC [spPDAGetDayAndMTDSummary] '29-Nov-2021', '8CD43106-60E2-46EE-8AD3-DF47358DF559'
CREATE PROCEDURE [dbo].[spPDAGetDayAndMTDSummary]
@strDate VARCHAR(20), 
@PDACode VARCHAR(50), --IMEI of Working person,who is using the PDA
@SalesmanNodeId INT=0, -- If SO is working, PersonId of Salesman working under him in case of @flgDataScope=2, Distributor Id in case of @flgDataScope=4 
@SalesmanNodeType INT=0,
@flgDataScope TINYINT=1 --1:Self, 2: Salesman working under(in this case only @PersonNodeId is to be used), 3: Self as well salesmen working under,4: Distributor

AS

	DECLARE @Date DATETIME,@FirstDate DATETIME,@LastDate DATETIME, @TargetCalls INT=0, @TargetCallsMTD INT=0, @ActualCallsONROute INT=0, @ActualCallsOffROute INT=0, @ProdCallOnRoute INT=0, @ProdCallOffRoute INT=0, @ActualCallsONROuteMTD INT=0, @ActualCallsOffROuteMTD INT=0, @ProdCallOnRouteMTD INT=0, @ProdCallOffRouteMTD INT=0, @CallsRemaining INT=0,@TotalSalesForDay DECIMAL(18,2)=0,@TotalSalesMTD DECIMAL(18,2)=0,@TotalDiscForDay DECIMAL(18,2)=0,@TotalDiscMTD DECIMAL(18,2)=0,@TotalOrderDiscForDay DECIMAL(18,2)=0,@TotalOrderDiscMTD DECIMAL(18,2)=0,@TotalLines INT=0,@TotalLinesMTD INT=0,@TotalInvForDay DECIMAL(18,2)=0,@TotalInvMTD DECIMAL(18,2)=0,@PlacementOutletsDay INT=0,@PlacementOutletsMTD INT=0,@NoOfStoresAddeddDay INT=0,@NoOfStoresAddeddMTD INT=0
	DECLARE @NoOfSKUsDay INT=0
	DECLARE @NoOfSKUsMTD INT=0
	DECLARE @OrderVolInKG DECIMAL(18,2)
	DECLARE @OrderVolInKG_MTD DECIMAL(18,2)
	DECLARE @Counter INT=0
	DECLARE @MaxCount INT=0
	DECLARE @CategoryNodeId INT
	DECLARE @Category VARCHAR(200)
	DECLARE @strSql VARCHAR(2000)=''
	DECLARE @ASMAreaNodeId INT
	DECLARE @ASMAreaNodeType INT

	DECLARE @TargetStoreCount INT=0
	DECLARE @TargetStoreCountMTD INT=0
	DECLARE @ActualStoresVisited INT=0
	DECLARE @ActualStoresVisitedMTD INT=0
	DECLARE @ProdStores INT=0
	DECLARE @ProdStoresMTD INT=0

	CREATE TABLE #RouteID (RouteID INT,RouteNodeType TINYINT,FromDate Date,ToDate Date,CovFrqID INT,Weekday INT,flgPrimary TINYINT,Active TINYINT,FrqVal INT,WeekID INT)
	CREATE TABLE #PersonList(PersonNodeId INT,PersonNodeType INT)
	CREATE TABLE #ColorCodes(TableNo INT,ColorCode VARCHAR(10))
	DECLARE @PersonID INT  =0
	DECLARE @PersonType INT  =0

	INSERT INTO #ColorCodes(TableNo,ColorCode)
	SELECT 1,'#E26B0A'
	UNION
	SELECT 2,'#92D050'
	UNION
	SELECT 3,'#538DD5'
	UNION
	SELECT 4,'#B1A0C7'
	UNION
	SELECT 5,'#FFC000'
	UNION
	SELECT 6,'#70558D'
	UNION
	SELECT 7,'#00B0F0'


	--SELECT @PDAID=PDAID FROM [dbo].[tblPDAMaster] WHERE [PDA_IMEI]=@IMENumber OR [PDA_IMEI_Sec]=@IMENumber  
	--PRINT '@PDAID=' + CAST(@PDAID AS VARCHAR)

	--SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@PDAID  AND GETDATE() BETWEEN DateFrom AND DateTo

	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	PRINT '@PersonID=' + CAST(@PersonID AS VARCHAR)
	PRINT '@@PersonType=' + CAST(@PersonType AS VARCHAR)

	----SELECT DISTINCT SalesAreaNodeID,SalesAreaNodeType,TransDate as fromdate,TransDate todate INTO #TodaysCoverageArea FROM tblVanStockMaster WHERE SalesmanNodeID=@PersonID AND SalesmanNodeType=@PersonType AND SalesAreaNodeID IS NOT NULL
	--select * from #TodaysCoverageArea
	--IF @PDAID>0  
	--BEGIN  
		IF @flgDataScope=1 OR @flgDataScope=0
		BEGIN		 
			----IF EXISTS(SELECT 1 FROM #TodaysCoverageArea)
			----BEGIN
			----	PRINT 'A'
			----	INSERT INTO #RouteID(RouteID,RouteNodeType,FromDate,ToDate)
			----	SELECT DISTINCT V.DSRRouteNodeID,V.DSRRouteNodeType,fromdate,todate FROM #TodaysCoverageArea A INNER JOIN VwCompanyDSRFullDetail V ON V.DSRAreaID=A.SalesAreaNodeID AND V.DSRAreaNodeType=A.SalesAreaNodeType
			----	UNION
			----	SELECT DISTINCT V.DBRRouteID,V.RouteNodeType,fromdate,todate FROM #TodaysCoverageArea A INNER JOIN [dbo].[VwDistributorDSRFullDetail] V ON V.DBRCoverageID=A.SalesAreaNodeID AND V.DBRCoverageNodeType=A.SalesAreaNodeType
			----	UNION
			----	SELECT distinct P.NodeID,P.NodeType,MIN(CAST(P.FromDate AS DATE)), MAX(CAST(P.ToDate AS DATE)) 
			----	FROM tblSalesPersonMapping P INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
			----	WHERE ISNULL(C.flgRoute,0)=1 AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) ANd P.PersonNodeId=@PersonID ANd P.PersonType=@PersonType
			----	GROUP BY P.NodeID,P.NodeType

			----	--SELECT * FROM #RouteID
			----END
			----ELSE
			BEGIN
				PRINT 'AB'

				INSERT INTO #RouteID(RouteID,RouteNodeType,FromDate,ToDate)
				SELECT distinct CH.NodeID,CH.NodeType,MIN(P.FromDate),MIN(P.ToDate)
				FROM tblSalesPersonMapping(nolock) P
				INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
				INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
				INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
				WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) 
				GROUP BY CH.NodeID,CH.NodeType
			END
			

			----SELECT DISTINCT RouteNodeId,RouteNodeType,RC.VisitDate,'31-Dec-2021' FROM tblRouteCalendar(nolock) RC WHERE RC.SONodeId=@PersonID AND RC.SONodeType=@PersonType 
	  
			INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
			SELECT @PersonID,@PersonType

			PRINT 'PersonID=' + CAST(@PersonID AS VARCHAR)
			PRINT 'PersonType=' + CAST(@PersonType AS VARCHAR)
		END 
		ELSE IF @flgDataScope=2
		BEGIN
			PRINT 'C'
			INSERT INTO #RouteID(RouteID,RouteNodeType,FromDate,ToDate)
			SELECT distinct CH.NodeID,CH.NodeType ,MIN(P.FromDate),MIN(P.TODate)
			FROM tblSalesPersonMapping P
			INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
			INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
			INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
			
			WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@SalesmanNodeId AND P.PersonType=@SalesmanNodeType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) 
			GROUP BY CH.NodeID,CH.NodeType

			--SELECT DISTINCT RouteNodeId,RouteNodeType,RC.VisitDate,'31-Dec-2021' FROM tblRouteCalendar RC INNER JOIN tblCompanySalesStructureRouteMstr RM ON RM.NodeID=RC.RouteNodeId AND RC.RouteNodeType=RM.NodeType WHERE RC.SONodeId=@PersonID AND RC.SONodeType=@PersonType 

			INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
			SELECT @SalesmanNodeId,@SalesmanNodeType
		END
		ELSE IF @flgDataScope=3
		BEGIN
			PRINT 'AD'
			--Self 
			--SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@PDAID  AND GETDATE() BETWEEN DateFrom AND DateTo
			SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

			INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
			SELECT @PersonID,@PersonType

			--Company Salesmna working under SO
			SELECT * INTO #SalesHier FROM VwCompanyDSRFullDetail

			SELECT @ASMAreaNodeId=NodeId,@ASMAreaNodeType=NodeType
			FROM tblSalesPersonMapping SP
			WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(SP.ToDate,GETDATE())) AND SP.PersonNodeId=@PersonID ANd SP.PersonType=@PersonType AND SP.NodeType=110

			--SELECT * FROM #SalesHier

			INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
			SELECT DISTINCT SP.PersonNodeId,SP.PersonType
			FROM #SalesHier H INNER JOIN tblSalesPersonMapping SP ON H.DSRAreaID=SP.NodeId AND H.DSRAreaNodeType=SP.NodeType
			WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(SP.ToDate,GETDATE())) ANd H.ASMAreaID=@ASMAreaNodeId AND H.ASMAreaNodeType=@ASMAreaNodeType AND SP.PersonNodeId<>@PersonID

			--SELECT * FROM #PersonList

			------Distributor Salesmna working under SO
			----INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
			----SELECT DISTINCT SP.PersonNodeId,SP.PersonType
			----FROM #SalesHier H INNER JOIN tblCompanySalesStructure_DistributorMapping Map ON H.SOID=Map.SHNodeId AND H.SOAreaType=Map.SHNodeType
			----INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=Map.DHNodeType
			----INNER JOIN tblSalesPersonMapping SP ON Map.DHNodeId=SP.NodeId AND Map.DHNodeType=SP.NodeType 
			----WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(SP.ToDate,GETDATE())) AND (GETDATE() BETWEEN Map.FromDate AND ISNULL(Map.ToDate,GETDATE())) ANd H.SOID=@SOAreaNodeId AND H.SOAreaType=@SOAreaNodeType AND ISNULL(C.flgCoverageArea,0)=1 AND SP.PersonNodeId NOT IN(SELECT PersonNodeId FROM #PersonList)
		

			INSERT INTO #RouteID(RouteID,RouteNodeType,FromDate,ToDate)
			SELECT distinct CH.NodeID,CH.NodeType,MIN(P.FromDate),MIN(P.ToDate)
				FROM tblSalesPersonMapping(nolock) P
				INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
				INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
				INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
				INNER JOIN #PersonList PL ON P.PersonNodeId=PL.PersonNodeId AND P.PersonType=PL.PersonNodeType
				WHERE ISNULL(C.flgRoute,0)=1  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) 
				GROUP BY CH.NodeID,CH.NodeType
		
		END   
		----ELSE IF @flgDataScope=4--DBR
		----BEGIN
		----	--DBR Route
		----	INSERT INTO #RouteID(RouteID,RouteNodeType,FromDate,ToDate)
		----	SELECT distinct SP.NodeID,SP.NodeType,MIN(SP.FromDate), MAX(SP.ToDate) 
		----	FROM tblSalesPersonMapping SP INNER JOIN VwAllDistributorHierarchy vwDBR ON vwDBR.DBRRouteID=SP.NodeId AND vwDBR.RouteNodeType=SP.NodeType
		----	WHERE vwDBR.DBRNodeID=@SalesmanNodeId AND VwDBR.DistributorNodeType=@SalesmanNodeType
		----	GROUP BY SP.NodeID,SP.NodeType

		----	--Company Route
		----	INSERT INTO #RouteID(RouteID,RouteNodeType,FromDate,ToDate)
		----	SELECT distinct SP.NodeID,SP.NodeType,MIN(SP.FromDate), MAX(SP.ToDate) 
		----	FROM tblSalesPersonMapping SP INNER JOIN VwSalesHierarchy vwS ON vwS.RouteID=SP.NodeId AND vwS.RouteType=SP.NodeType
		----	INNER JOIN tblCompanySalesStructure_DistributorMapping Map ON vwS.ComCoverageAreaID=Map.SHNodeId AND vwS.ComCoverageAreaType=Map.SHNodeType
		----	WHERE Map.DHNodeID=@SalesmanNodeId AND Map.DHNodeType=@SalesmanNodeType AND (GETDATE() BETWEEN Map.FromDate AND Map.ToDate)
		----	GROUP BY SP.NodeID,SP.NodeType
		----END	
	--END   
	--UPDATE #RouteID SET FromDate='12-Sep-2017' where RouteID=75
	--SELECT * FROM #RouteID	 
	

	Select @Date = REPLACE(CONVERT(VARCHAR, convert(datetime,@strDate,105), 106),' ','-')   
	PRINT '@Date=' + CAST(@Date AS VARCHAR)  
	SELECT @FirstDate=DATEADD(dd,-(DAY(@Date)-1),@Date)
	PRINT '@FirstDate=' + CAST(@FirstDate AS VARCHAR) 
	SELECT @LastDate=DATEADD(dd,-(DAY(DATEADD(mm,1,@Date))),DATEADD(mm,1,@Date))
	PRINT '@LastDate=' + CAST(@LastDate AS VARCHAR) 

	--Target Calls MTD
	SET  @FirstDate=dateadd(dd, -1, @FirstDate)
	CREATE TABLE #tmpDays(Dt DATE, WeekNo INT, DayNo INT,WeekEnding DATE);
	WITH dateRange AS
	(	
	  SELECT dt = dateadd(dd, 1, @FirstDate)
	  WHERE dateadd(dd, 1, @FirstDate) <= @LastDate
	  UNION ALL
	  SELECT dateadd(dd, 1, dt)
	  FROM dateRange
	  WHERE dateadd(dd, 1, dt) <= @LastDate
	)

	INSERT INTO #tmpDays(Dt)
	SELECT * FROM dateRange ORDER BY dt
 
	--select * from #tmpDays
	SET  @FirstDate=dateadd(dd, 1, @FirstDate)
	PRINT @FirstDate

	SET DATEFIRST 1
	DECLARE @DayofWeek INT
	SELECT @DayofWeek = datepart(dw,@Date)

	UPDATE O SET O.Active=ISNULL(A.Active,0) FROM #RouteID O INNER JOIN (SELECT RouteNodeId,RouteNodeType,1 AS Active FROM tblRoutePlanningVisitDetail WHERE VisitDate=@strDate GROUP BY RouteNodeId,RouteNodeType) A ON A.RouteNodeId=O.RouteID AND A.RouteNodeType=O.RouteNodeType

	UPDATE A SET FrqVal=value FROM #RouteID A INNER JOIN tblRoutePlanDetails R ON R.WeekId=A.WeekID AND R.CovFrqID=A.CovFrqID
	--SELECT * FROM [#AllRoutes] order by Weekday

	----UPDATE A SET Active=1 FROM #RouteID A INNER JOIN tblRoutePlanDetails R ON R.CovFrqID=A.CovFrqID AND Value=A.FrqVal AND Weekday=@DayofWeek 
	----AND (CAST(@Date AS DATE) BETWEEN WeekFrom AND WeekTo)

	--SELECT * FROM #RouteID

	SELECT DISTINCT RID.RouteID ,RID.RouteNodeType RouteNodetype,R.Descr,D.Dt,SM.DBID,SM.StoreID,DATEPART(WEEK, D.Dt)  -  DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,D.Dt), 0))+ 1 WeekID,Active AS FlgPlanned INTO #tmpRoute
	FROM #RouteID RID 
	INNER JOIN tblRouteCoverageStoreMapping RM ON RM.RouteID=RID.RouteID AND RM.RouteNodeType=RID.RouteNodeType
	LEFT OUTER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=RID.RouteID AND R.NodeType=RID.RouteNodeType
	LEFT OUTER JOIN tblStoreMaster(nolock) SM ON SM.StoreID=RM.StoreID CROSS JOIN #tmpDays D WHERE GETDATE() BETWEEN RM.FromDate AND RM.ToDate


	----SELECT DISTINCT RCM.RouteNodeId RouteId,RCM.RouteNodeType AS RouteNodeType,D.Dt,Active AS FlgPlanned INTO #tmpRoute
	----FROM tblRouteCalendar(nolock) RCM INNER JOIN #RouteID ON RCM.RouteNodeId=#RouteID.RouteID AND RCM.RouteNodeType=#RouteID.RouteNodeType  CROSS JOIN #tmpDays D
	----WHERE (D.Dt BETWEEN #RouteID.FromDate AND #RouteID.ToDate)
	----ORDER BY RouteId,Dt

	
	

	--SELECT * FROM #tmpRoute

	DELETE FROM #tmpRoute WHERE FlgPlanned=0

	--SELECT * FROM #tmpRoute WHERE RouteID=44569 Order by RouteId,Dt

	CREATE TABLE #PlannedCalls(RouteId INT,RouteNodeType INT,StoreId INT,[Date] DATE,RptMonthYear INT,PlannedCalls INT)
	IF @flgDataScope=4--DBR
	BEGIN
		INSERT INTO #PlannedCalls(RouteId,RouteNodeType,StoreId,[Date],RptMonthYear,PlannedCalls)
		SELECT RouteNodeId,RC.RouteNodeType,RC.StoreId,VisitDate,CONVERT(VARCHAR(6),VisitDate,112),COUNT(VisitDate) FROM tblRouteCoverageStoreMapping (nolock) RC 
		INNER JOIN tblStoreMaster SM ON SM.StoreID=RC.StoreId
		INNER JOIN tblRoutePlanningVisitDetail P ON P.RouteNodeId=RC.RouteID AND P.RouteNodetype=RC.RouteNodeType
		WHERE P.DSENodeId=@PersonID AND P.DSENodeType=@PersonType
		AND MONTH(VisitDate)=MONTH(GETDATE())
		GROUP BY RouteNodeId,RC.RouteNodeType,RC.StoreId,VisitDate,CONVERT(VARCHAR(6),VisitDate,112)
		ORDER BY VisitDate,StoreId
		----SELECT A.RouteId,A.RouteNodeType,B.StoreId,Dt AS [Date],CONVERT(VARCHAR(6),Dt,112) AS RptMonthYear,COUNT(Dt) AS PlannedCalls --INTO #PlannedCalls
		----FROM  #tmpRoute A INNER JOIN tblRouteCalendar B ON A.RouteId=B.RouteNodeId AND A.RouteNodeType=B.RouteNodeType AND (A.Dt BETWEEN B.FromDate AND B.ToDate)
		----INNER JOIN tblStoreMaster SM ON B.StoreId=SM.StoreId
		----WHERE SM.DBId=@SalesmanNodeId AND SM.DBNodeType=@SalesmanNodeType 
		----GROUP BY A.RouteId,A.RouteNodeType,A.FlgPlanned,B.StoreId,Dt,CONVERT(VARCHAR(6),Dt,112)
		----ORDER BY Dt,B.Storeid
	END
	ELSE
	BEGIN
		----INSERT INTO #PlannedCalls(RouteId,RouteNodeType,StoreId,[Date],RptMonthYear,PlannedCalls)
		----SELECT RouteNodeId,RouteNodeType,StoreId,VisitDate,CONVERT(VARCHAR(6),VisitDate,112),COUNT(VisitDate) FROM tblRouteCalendar(nolock) WHERE SONodeId=@PersonID AND SONodeType=@PersonType
		----AND MONTH(VisitDate)=MONTH(GETDATE())
		----GROUP BY RouteNodeId,RouteNodeType,StoreId,VisitDate,CONVERT(VARCHAR(6),VisitDate,112)
		----ORDER BY VisitDate,StoreId

		INSERT INTO #PlannedCalls(RouteId,RouteNodeType,StoreId,[Date],RptMonthYear,PlannedCalls)
		SELECT DISTINCT A.RouteId,A.RouteNodeType,B.StoreId,Dt AS [Date],CONVERT(VARCHAR(6),Dt,112) AS RptMonthYear,A.FlgPlanned AS PlannedCalls --INTO #PlannedCalls
		FROM  #tmpRoute A INNER JOIN tblRouteCoverageStoreMapping B ON A.RouteId=B.RouteId AND A.RouteNodeType=B.RouteNodeType AND (A.Dt BETWEEN B.FromDate AND B.ToDate)
		INNER JOIN tblRoutePlanningVisitDetail V ON V.RouteNodeId=A.RouteID AND V.RouteNodetype=A.RouteNodetype
		WHERE A.FlgPlanned=1
		GROUP BY A.RouteId,A.RouteNodeType,A.FlgPlanned,B.StoreId,Dt,CONVERT(VARCHAR(6),Dt,112)
		ORDER BY Dt,B.Storeid
	END
	--SELECT * FROM #PlannedCalls WHERE Date=CAST(GETDATE() AS DATE) order by StoreId--routeid,date

	SELECT @TargetCalls =ISNULL(SUM(PlannedCalls),0) FROM    #PlannedCalls WHERE (CONVERT(VARCHAR, [Date], 112) = CONVERT(VARCHAR, @Date, 112))
	PRINT '@TargetCalls=' + CAST(@TargetCalls AS VARCHAR)

	SELECT @TargetCallsMTD =ISNULL(SUM(PlannedCalls),0) FROM    #PlannedCalls
	PRINT '@TargetCallsMTD=' + CAST(@TargetCallsMTD AS VARCHAR)
	
	--SELECT * FROM #PlannedCalls
	--Target Store Count
	SELECT @TargetStoreCount =ISNULL(COUNT(DISTINCT StoreId),0) FROM    #PlannedCalls WHERE (CONVERT(VARCHAR, [Date], 112) = CONVERT(VARCHAR, @Date, 112))
	PRINT '@TargetStoreCount=' + CAST(@TargetStoreCount AS VARCHAR)

	SELECT @TargetStoreCountMTD =ISNULL(COUNT(DISTINCT StoreId),0) FROM    #PlannedCalls
	PRINT '@TargetStoreCountMTD=' + CAST(@TargetStoreCountMTD AS VARCHAR)


	--Actual Calls
	CREATE TABLE #Visits(VisitID INT,StoreId INT,VisitDate DATE,FlgOnRoute TINYINT)

	IF @flgDataScope=4--DBR
	BEGIN
		INSERT INTO #Visits(VisitID,StoreId,VisitDate,FlgOnRoute)
		SELECT VM.VisitID,VM.StoreId,VM.VisitDate,VM.FlgOnRoute
		FROM    tblVisitMaster VM INNER JOIN tblStoreMaster SM ON VM.StoreID= SM.StoreID
		WHERE (CONVERT(VARCHAR(6), VM.VisitDate, 112) = CONVERT(VARCHAR(6), @Date, 112)) AND SM.DBId=@SalesmanNodeId AND SM.DBNodeType=@SalesmanNodeType
	END
	ELSE
	BEGIN
		INSERT INTO #Visits(VisitID,StoreId,VisitDate,FlgOnRoute)
		SELECT VM.VisitID,VM.StoreId,VM.VisitDate,VM.FlgOnRoute 
		FROM            tblVisitMaster VM --INNER JOIN #RouteID ON VM.RouteId= #RouteID.RouteID AND VM.RouteType=#RouteID.RouteNodeType
		INNER JOIN #PersonList P ON VM.SalesPersonId=P.PersonNodeId AND VM.SalesPersonType=P.PersonNodeType
		WHERE (CONVERT(VARCHAR(6), VM.VisitDate, 112) = CONVERT(VARCHAR(6), @Date, 112)) --AND VM.SalesPersonId=@PersonID AND VM.SalesPersonType=@PersonType
	END
	--SELECT * FROM #Visits

	SELECT  @ActualCallsONROute = COUNT(DISTINCT VM.VisitId) FROM #Visits VM
	WHERE   (CONVERT(VARCHAR, VM.VisitDate, 112) = CONVERT(VARCHAR, @Date, 112)) AND FlgOnRoute=1
	PRINT '@ActualCallsONROute=' + CAST(@ActualCallsONROute AS VARCHAR)

	SELECT  @ActualCallsOffROute = COUNT(DISTINCT VM.VisitId) FROM #Visits VM
	WHERE   (CONVERT(VARCHAR, VM.VisitDate, 112) = CONVERT(VARCHAR, @Date, 112))  AND FlgOnRoute=0
	PRINT '@ActualCallsOffROute=' + CAST(@ActualCallsOffROute AS VARCHAR)

	SELECT  @ActualCallsONROuteMTD = COUNT(DISTINCT VM.VisitId) FROM #Visits VM
	WHERE   FlgOnRoute=1
	PRINT '@ActualCallsONROuteMTD=' + CAST(@ActualCallsONROuteMTD AS VARCHAR)
	
	SELECT  @ActualCallsOffROuteMTD = COUNT(DISTINCT VM.VisitId) FROM #Visits VM
	WHERE   FlgOnRoute=0
	PRINT '@ActualCallsOffROuteMTD=' + CAST(@ActualCallsOffROuteMTD AS VARCHAR)

	--Count of Stores Visited
	SELECT  @ActualStoresVisited = COUNT(DISTINCT VM.StoreId) FROM #Visits VM WHERE   (CONVERT(VARCHAR, VM.VisitDate, 112) = CONVERT(VARCHAR, @Date, 112)) --AND FlgOnRoute=1
	PRINT '@ActualStoresVisited=' + CAST(@ActualStoresVisited AS VARCHAR)

	SELECT  @ActualStoresVisitedMTD = COUNT(DISTINCT VM.StoreId) FROM #Visits VM --WHERE FlgOnRoute=1
	PRINT '@ActualStoresVisitedMTD=' + CAST(@ActualStoresVisitedMTD AS VARCHAR)

	--Productive Calls
	CREATE TABLE #Orders(VisitId INT,StoreId INT,FlgOnRoute TINYINT,OrderDate DATE,ProductID INT,OrderQty INT,OrderQtyInKG FLOAT,CategoryNodeId INT,Category VARCHAR(200), CategoryOrdr TINYINT )
	SELECT * INTO #PrdHier FROm VwSFAProductHierarchy

	IF @flgDataScope=4--DBR
	BEGIN
		INSERT INTO #Orders(VisitId,StoreId,FlgOnRoute,OrderDate,ProductID,OrderQty,OrderQtyInKG,CategoryNodeId,Category,CategoryOrdr)
		SELECT OM.VisitId,OM.StoreID,VM.FlgOnRoute,OM.OrderDate,OD.ProductID,OD.OrderQty,OD.OrderQty/C.RelConversionUnits AS OrderQtyInKG,Hier.CategoryNodeId,Hier.Category, Hier.CatOrdr
		FROM tblVisitMaster VM INNER JOIN tblOrderMaster OM ON VM.VisitId=OM.VisitId 
		INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
		INNER JOIN #PrdHier Hier ON OD.ProductId=Hier.SKUNodeId
		INNER JOIN tblStoreMaster SM ON VM.StoreID= SM.StoreID
		LEFT OUTER JOIN [tblPrdMstrPackingUnits_ConversionUnits] C ON C.SKUID=OD.ProductID AND C.BaseUOMID=3
		WHERE (CONVERT(VARCHAR(6), OM.OrderDate, 112) = CONVERT(VARCHAR(6), @Date, 112)) AND OD.OrderQty>0 AND ISNULL(OM.OrderStatusId,0)<>3 AND SM.DBId=@SalesmanNodeId AND SM.DBNodeType=@SalesmanNodeType
	END
	ELSE
	BEGIN
		INSERT INTO #Orders(VisitId,StoreId,FlgOnRoute,OrderDate,ProductID,OrderQty,OrderQtyInKG,CategoryNodeId,Category,CategoryOrdr)
		SELECT OM.VisitId,OM.StoreID,VM.FlgOnRoute,OM.OrderDate,OD.ProductID,OD.OrderQty,OD.OrderQty/C.RelConversionUnits AS OrderQtyInKG,Hier.CategoryNodeId,Hier.Category, Hier.CatOrdr
		FROM tblVisitMaster VM INNER JOIN tblOrderMaster OM ON VM.VisitId=OM.VisitId 
		INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
		INNER JOIN #PrdHier Hier ON OD.ProductId=Hier.SKUNodeId
		INNER JOIN #PersonList P ON OM.SalesPersonId=P.PersonNodeId AND OM.SalesPersonType=P.PersonNodeType
		LEFT OUTER JOIN [tblPrdMstrPackingUnits_ConversionUnits] C ON C.SKUID=OD.ProductID AND C.BaseUOMID=3
		WHERE (CONVERT(VARCHAR(6), OM.OrderDate, 112) = CONVERT(VARCHAR(6), @Date, 112)) AND OD.OrderQty>0 AND ISNULL(OM.OrderStatusId,0)<>3 
	END	
	--SELECT * FROM #Orders

	CREATE TABLE #PriOrders(DBNodeID INT,OrderDate DATE,ProductID INT,OrderQty INT,OrderQtyInKG FLOAT,CategoryNodeId INT,Category VARCHAR(200), CategoryOrdr TINYINT )
	INSERT INTO #PriOrders(DBNodeID,OrderDate,ProductID,OrderQty,OrderQtyInKG,CategoryNodeId,Category,CategoryOrdr) 
	SELECT OM.SalesNodeId,OM.ReqDate,OD.PrdId,OD.Qty,OD.Qty/C.RelConversionUnits AS OrderQtyInKG,Hier.CategoryNodeId,Hier.Category, Hier.CatOrdr
	FROM [tblPurchaseReqMaster] OM
	INNER JOIN tblPurchaseReqDetail OD ON OM.[PurchReqId]=OD.[PurchReqId]
	INNER JOIN #PrdHier Hier ON OD.PrdId=Hier.SKUNodeId
	LEFT OUTER JOIN [tblPrdMstrPackingUnits_ConversionUnits] C ON C.SKUID=OD.PrdId AND C.BaseUOMID=3
	LEFT OUTER JOIN tblSecUserLogin L ON L.LoginID=OM.LoginIDIns
	LEFT OUTER JOIN tblSecUser S ON S.UserID=L.UserID
	WHERE (CONVERT(VARCHAR(6), OM.ReqDate, 112) = CONVERT(VARCHAR(6), @Date, 112)) AND OD.Qty>0 AND S.NodeID=@SalesmanNodeId AND S.NodeType=@SalesmanNodeType AND OM.SalesNodeType=150



	CREATE TABLE #CatWiseMTDOrder(ID INT IDENTITY(1,1),CategoryNodeId INT,Category VARCHAR(200),OrderQty FLOAT,OrderQtyInKG FLOAT,UOM VARCHAR(15),UOMId INT,CategoryOrdr TINYINT)

	INSERT INTO #CatWiseMTDOrder(CategoryNodeId,Category,OrderQty,OrderQtyInKG,CategoryOrdr)
	SELECT CategoryNodeId,Category,SUM(OrderQty) OrderQty,SUM(OrderQtyInKG) OrderQtyInKG,CategoryOrdr
	FROM #Orders
	GROUP BY CategoryNodeId,Category,CategoryOrdr
	--SELECT * FROM #CatWiseMTDOrder

	
	SELECT A.CategoryNodeId,MAX(A.UOMId) UOMId INTO #UOM
	FROM #PrdHier A INNER JOIN #CatWiseMTDOrder B On A.CategoryNodeId=B.CategoryNodeId GROUP BY A.CategoryNodeId
	UPDATE #UOM SET UOMId=11 WHERE UOMId IN(14,15)
	UPDATE #UOM SET UOMId=12 WHERE UOMId IN(13)
	--SELECT * FROM #UOM
	--SELECT * FROM #CatWiseMTDOrder
	PRINT 'AA'
	UPDATE A SET A.UOM=UOM.BUOMName,A.UOMId=AA.UOMId  FROM #CatWiseMTDOrder A INNER JOIN #UOM AA ON A.CategoryNodeId=AA.CategoryNodeId
	INNER JOIN tblPrdMstrBUOMMaster UOM ON AA.UOmId=UOM.BUOMID
	--SELECT * FROM #CatWiseMTDOrder
	PRINT 'A'
	SELECT CategoryNodeId,Category,SUM(OrderQty) OrderQty,SUM(OrderQtyInKG) OrderQtyInKG INTO #CatWiseTodayOrder
	FROM #Orders
	WHERE (OrderDate = CONVERT(VARCHAR, @Date, 112))
	GROUP BY CategoryNodeId,Category
	--SELECT * FROM #CatWiseTodayOrder

	--SELECT @OrderVolInKG=ROUND(SUM(OrderQtyInKG),2) FROM #Orders
	--WHERE (CONVERT(VARCHAR, OrderDate, 112) = CONVERT(VARCHAR, @Date, 112))
	--PRINT '@OrderVolInKG=' + CAST(@OrderVolInKG AS VARCHAR)

	--SELECT @OrderVolInKG_MTD=ROUND(SUM(OrderQtyInKG),2) FROM #Orders
	--PRINT '@OrderVolInKG_MTD=' + CAST(@OrderVolInKG_MTD AS VARCHAR)

	SELECT  @ProdCallOnRoute = COUNT(DISTINCT OM.VisitId) FROM   #Orders OM	WHERE (CONVERT(VARCHAR, OM.OrderDate, 112) = CONVERT(VARCHAR, @Date, 112)) AND FlgOnRoute=1
	PRINT '@ProdCallOnRoute=' + CAST(@ProdCallOnRoute AS VARCHAR)

	SELECT @ProdCallOffRoute = COUNT(DISTINCT OM.VisitId) FROM  #Orders OM WHERE (CONVERT(VARCHAR, OM.OrderDate, 112) = CONVERT(VARCHAR, @Date, 112))  AND FlgOnRoute=0
	PRINT '@ProdCallOffRoute=' + CAST(@ProdCallOffRoute AS VARCHAR)

	SELECT  @ProdCallOnRouteMTD = COUNT(DISTINCT OM.VisitId) FROM  #Orders OM WHERE FlgOnRoute=1
	PRINT '@ProdCallOnRouteMTD=' + CAST(@ProdCallOnRouteMTD AS VARCHAR)

	SELECT @ProdCallOffRouteMTD = COUNT(DISTINCT OM.VisitId) FROM  #Orders OM WHERE FlgOnRoute=0
	PRINT '@ProdCallOffRouteMTD=' + CAST(@ProdCallOffRouteMTD AS VARCHAR)

	--Productive Stores
	SELECT  @ProdStores = COUNT(DISTINCT OM.StoreId) FROM   #Orders OM WHERE (CONVERT(VARCHAR, OM.OrderDate, 112) = CONVERT(VARCHAR, @Date, 112)) --AND FlgOnRoute=1
	PRINT '@ProdStores=' + CAST(@ProdStores AS VARCHAR)

	SELECT  @ProdStoresMTD = COUNT(DISTINCT OM.StoreId) FROM  #Orders OM --WHERE FlgOnRoute=1
	PRINT '@ProdStoresMTD=' + CAST(@ProdStoresMTD AS VARCHAR)

	SELECT @TotalLines = COUNT(OM.ProductID) FROM  #Orders OM WHERE (CONVERT(VARCHAR, OM.OrderDate, 112) = CONVERT(VARCHAR, @Date, 112))
	PRINT '@TotalLines=' + CAST(@TotalLines AS VARCHAR)

	SELECT @TotalLinesMTD = COUNT(OM.ProductID) FROM #Orders OM 
	PRINT '@TotalLinesMTD=' + CAST(@TotalLinesMTD AS VARCHAR)

	SELECT @NoOfSKUsDay = COUNT(DISTINCT OM.ProductID) FROM  #Orders OM WHERE (CONVERT(VARCHAR, OM.OrderDate, 112) = CONVERT(VARCHAR, @Date, 112))
	PRINT '@NoOfSKUsDay=' + CAST(@NoOfSKUsDay AS VARCHAR)

	SELECT @NoOfSKUsMTD = COUNT(DISTINCT OM.ProductID) FROM #Orders OM
	PRINT '@NoOfSKUsMTD=' + CAST(@NoOfSKUsMTD AS VARCHAR)

	--Order Value
	/*
	SELECT     ISNULL(SUM(OD.NetLineOrderVal), 0) AS TotOrderVal,ISNULL(SUM(OD.TotLineDiscVal), 0) AS TotDiscVal, CONVERT(VARCHAR(8), OM.OrderDate, 112) AS OrderDate
	INTO            [#AllMonthsData]
	FROM         tblOrderDetail OD INNER JOIN tblOrderMaster OM ON OD.OrderID = OM.OrderID 
					--INNER JOIN tblVisitMaster ON tblOrderMaster.VisitId=tblVisitMaster.VisitId 
					--INNER JOIN #RouteID ON tblVisitMaster.RouteId=#RouteID.RouteID 
	WHERE OM.SalesPersonId=@PersonID AND OM.SalesPersonType=@PersonType AND (CONVERT(VARCHAR(6), OM.OrderDate, 112) = CONVERT(VARCHAR(6), @Date, 112))
	GROUP BY CONVERT(VARCHAR(8), OM.OrderDate, 112)
	--select * from [#AllMonthsData]

	SELECT ISNULL(SUM(OM.TotDiscVal),0) AS OrderDiscVal, CONVERT(VARCHAR(8), OM.OrderDate, 112) AS OrderDate INTO #OrderDisc
	FROM            tblOrderMaster OM --INNER JOIN
					--tblOrderDetail OD ON OM.OrderID = OD.OrderID INNER JOIN
					--tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN #RouteID ON VM.RouteID = #RouteID.RouteID 
	WHERE OM.SalesPersonId=@PersonID AND OM.SalesPersonType=@PersonType AND (CONVERT(VARCHAR(6), OM.OrderDate, 112) = CONVERT(VARCHAR(6), @Date, 112))
	GROUP BY CONVERT(VARCHAR(8), OM.OrderDate, 112)

	--select * from #OrderDisc

	SELECT ISNULL(SUM(ID.NetLineInvVal),0) AS InvVal, CONVERT(VARCHAR(8), OM.OrderDate, 112) AS OrderDate INTO #Invoice
	FROM      tblInvoiceMaster IM  INNER JOIN tblInvoiceDetail ID ON IM.InvId=ID.InvId 
	INNER JOIN tblOrderMaster OM ON IM.OrderId=OM.OrderId
	--INNER JOIN tblVisitMaster VM ON OM.VisitID = VM.VisitID INNER JOIN #RouteID ON VM.RouteID = #RouteID.RouteID 
	WHERE  OM.SalesPersonId=@PersonID AND OM.SalesPersonType=@PersonType AND (CONVERT(VARCHAR(6), OM.OrderDate, 112) = CONVERT(VARCHAR(6), @Date, 112))
	GROUP BY CONVERT(VARCHAR(8), OM.OrderDate, 112)

	--SELECT * FROM #Invoice

	Select @TotalSalesForDay = ISNULL(ROUND(SUM(TotOrderVal),2),0) FROM #AllMonthsData WHERE OrderDate = CONVERT(VARCHAR, @Date, 112)
	Select @TotalSalesMTD = ISNULL(ROUND(SUM(TotOrderVal),2),0) FROM #AllMonthsData
	PRINT '@TotalSalesForDay=' + CAST(@TotalSalesForDay AS VARCHAR)
	PRINT '@TotalSalesMTD=' + CAST(@TotalSalesMTD AS VARCHAR)
	SELECT @TotalDiscForDay = ISNULL(ROUND(SUM(TotDiscVal),2),0) FROM #AllMonthsData WHERE OrderDate = CONVERT(VARCHAR, @Date, 112)
	SELECT @TotalDiscMTD = ISNULL(ROUND(SUM(TotDiscVal),2),0) FROM #AllMonthsData
	 PRINT '@TotalDiscForDay=' + CAST(@TotalDiscForDay AS VARCHAR)
	 PRINT '@TotalDiscMTD=' + CAST(@TotalDiscMTD AS VARCHAR)
 
	 SELECT @TotalOrderDiscForDay=ISNULL(ROUND(SUM(OrderDiscVal),2),0) FROM #OrderDisc WHERE OrderDate = CONVERT(VARCHAR, @Date, 112)
	 SELECT @TotalOrderDiscMTD=ISNULL(ROUND(SUM(OrderDiscVal),2),0) FROM #OrderDisc
	 PRINT '@TotalOrderDiscForDay=' + CAST(@TotalOrderDiscForDay AS VARCHAR)
	 PRINT '@TotalOrderDiscMTD=' + CAST(@TotalOrderDiscMTD AS VARCHAR)
 
	 SELECT @TotalInvForDay=ISNULL(ROUND(SUM(TotOrderVal),2),0) FROM #AllMonthsData WHERE OrderDate = CONVERT(VARCHAR, @Date, 112)
	 SELECT @TotalInvMTD=ISNULL(ROUND(SUM(InvVal),2),0) FROM #Invoice
	 PRINT '@TotalInvForDay=' + CAST(@TotalInvForDay AS VARCHAR)
	 PRINT '@TotalInvMTD=' + CAST(@TotalInvMTD AS VARCHAR)
	 */

	--select * from #RouteID
	CREATE TABLE #tmpStoreAdded(StoreId INT,DateAdded DATE)

	IF @flgDataScope=4--DBR
	BEGIN
		INSERT INTO #tmpStoreAdded(StoreId,DateAdded)
		SELECT SM.StoreId,CAST(SM.TimeStampIns AS DATE) AS DateAdded
		FROM  tblStoreMaster SM
		WHERE CONVERT(VARCHAR(6),SM.TimeStampIns,112)=CONVERT(VARCHAR(6),@Date,112) AND SM.DBId=@SalesmanNodeId AND SM.DBNodeType=@SalesmanNodeType
		ORDER BY SM.TimeStampIns --RouteId,StoreId 
	END
	ELSE
	BEGIN
		INSERT INTO #tmpStoreAdded(StoreId,DateAdded)
		SELECT tblStoreMaster.StoreId,CAST(tblStoreMaster.TimeStampIns AS DATE) AS DateAdded
		FROM    #RouteID INNER JOIN
		tblRouteCoverageStoreMapping RC ON RC.RouteID=#RouteID.RouteID AND RC.RouteNodeType=#RouteID.RouteNodeType
		AND CAST(GETDATE()AS DATE) BETWEEN RC.FromDate AND RC.ToDate
				 INNER JOIN tblStoreMaster ON RC.StoreId=tblStoreMaster.StoreId
		WHERE CONVERT(VARCHAR(6),tblStoreMaster.TimeStampIns,112)=CONVERT(VARCHAR(6),@Date,112)
		ORDER BY tblStoreMaster.TimeStampIns --RouteId,StoreId 
	END
	--SELECT * FROM #tmpStoreAdded

	SELECT @NoOfStoresAddeddDay=COUNT(DISTINCT StoreId) FROM #tmpStoreAdded WHERE CONVERT(VARCHAR,DateAdded,112) = CONVERT(VARCHAR, @Date, 112)
	PRINT 'NoOfStoresAddeddDay-' + CAST(@NoOfStoresAddeddDay AS VARCHAR)
	SELECT @NoOfStoresAddeddMTD=COUNT(DISTINCT StoreId) FROM #tmpStoreAdded
	PRINT 'NoOfStoresAddeddMTD-' + CAST(@NoOfStoresAddeddMTD AS VARCHAR)


	--Target
	/*
	DECLARE @WorkingDays INT,@TargetDay DECIMAL(18,2)=0,@TargetMTD DECIMAL(18,2)=0,@AcheivedDay DECIMAL(18,2)=0,@AcheivedMTD DECIMAL(18,2)=0,@TargetVolMTD FLOAT,@BalanceDay DECIMAL(18,2)=0,@BalanceMTD DECIMAL(18,2)=0

	--Select @AcheivedDay = ISNULL(ROUND(SUM(InvoiceSalesVolumeKG),2),0) FROM #Invoice WHERE InvDate = CONVERT(VARCHAR, @Date, 112)
	Select @AcheivedMTD = ISNULL(ROUND(SUM(TotOrderVal),2),0) FROM #AllMonthsData WHERE OrderDate < CONVERT(VARCHAR, @Date, 112)
	--PRINT 'AcheivedDay=' + CAST(@AcheivedDay AS VARCHAR)
	PRINT 'AcheivedMTD=' + CAST(@AcheivedMTD AS VARCHAR)
	SELECT @WorkingDays=COUNT(DISTINCT Dt) FROM #tmpRoute
	WHERE CONVERT(VARCHAR, Dt, 112) >= CONVERT(VARCHAR, @Date, 112)
	PRINT 'WorkingDays=' + CAST(@WorkingDays AS VARCHAR)

	--SELECT @Date='05-Mar-2017'
	----SELECT @TargetVolMTD=ISNULL(SUM((CAST(D.CaseSize AS FLOAT)*D.StandardRate)*B.TargetVal),0)
	----FROM tblTargetMstr A INNER JOIN tblTargetDet B ON A.TgtMstrId=B.TgtMstrId
	----INNER JOIN tblTargetTimePeriodMstr C ON A.TimePeriodNodeId=C.TimePeriodNodeId AND A.TimePeriodNodeType=C.TimePeriodNodeType
	----INNER JOIN tblPrdMstrSKULvl D ON B.PrdNodeId=D.NodeId AND B.PrdNodeType=D.NodeType
	----WHERE C.TimePeriodKey=CONVERT(VARCHAR(6), @Date, 112) AND A.MeasureId=1 AND B.SalesmanNodeId=@PersonID AND B.SalesmanNodeType=@PersonType
	----PRINT 'TargetVolMTD=' + CAST(@TargetVolMTD AS VARCHAR)
	--SELECT @TargetVolMTD

	----Select @TargetDay = CASE @TargetVolMTD WHEN 0 THEN 0 ELSE ISNULL(ROUND((@TargetVolMTD-@AcheivedMTD)/CAST(@WorkingDays AS FLOAT),2),0) END
	Select @TargetDay = CASE WHEN @TargetVolMTD=0 THEN 0 WHEN @WorkingDays=0 THEN ROUND((@TargetVolMTD-ISNULL(@AcheivedMTD,0)),2) ELSE ISNULL(ROUND((@TargetVolMTD-ISNULL(@AcheivedMTD,0))/CAST(@WorkingDays AS FLOAT),2),0) END
	--Select @TargetMTD = ISNULL(ROUND(@TargetVolMTD,2),0)
	PRINT 'TargetDay=' + CAST(@TargetDay AS VARCHAR)
	--PRINT 'TargetMTD=' + CAST(@TargetMTD AS VARCHAR)
	*/

	--- Sales Target Calculation
	--SELECT OrderDate,NetOrderValue INTO #Sales FROM tblOrderMaster(nolock) OM  WHERE EntryPersonNodeId=@PersonID AND MONTH(OrderDate)=MONTH(GETDATE())
	-- AND YEAR(OrderDate)=YEAR(GETDATE())

	--- Target Calculation
	CREATE TABLE #Target_Ach([LevelNo] INT,MeasureID INT,Measure VARCHAR(50),[MonthTgt] NUMERIC(10,4) DEFAULT 0,[MTD_Ach] NUMERIC(10,4) DEFAULT 0,[CurrentDayRate] NUMERIC(10,4) DEFAULT 0,[RequiredDayRate] NUMERIC(10,4) DEFAULT 0)

	--Level=0 MonthData
	INSERT INTO #Target_Ach([LevelNo],MeasureID,Measure)
	SELECT 0,1,'OverAll Volume'
	UNION
	SELECT 0,2,'OverAll Distribution'
	UNION
	SELECT 0,3,'FB-Volume'
	UNION
	SELECT 0,4,'FB-Distribution'

	--Level=1 DaywiseData
	INSERT INTO #Target_Ach([LevelNo],MeasureID,Measure)
	SELECT 1,1,'OverAll Volume'
	UNION
	SELECT 1,2,'OverAll Distribution'
	UNION
	SELECT 1,3,'FB-Volume'
	UNION
	SELECT 1,4,'FB-Distribution'

	CREATE TABLE #Target_AchDet(DataDate Date,MeasureID INT,Measure VARCHAR(100),Target NUMERIC(10,4) DEFAULT 0,Achievement NUMERIC(10,4) DEFAULT 0)

	INSERT INTO #Target_AchDet(DataDate,MeasureID,Measure,Target,Achievement)
	SELECT '01-Feb-2022',1,'OverAll Volume',0,0
	UNION
	SELECT '01-Feb-2022',2,'OverAll Distribution',0,0
	UNION
	SELECT '01-Feb-2022',3,'FB-Volume',0,0
	UNION
	SELECT '01-Feb-2022',4,'FB-Distribution',0,0

	 DECLARE @TotalMonthPriSales NUMERIC(6,2),@TodaysPriSales NUMERIC(6,2)
	 DECLARE @TotalMonthSecSales NUMERIC(6,2),@TodaysSecSales NUMERIC(6,2)

	 SELECT @TotalMonthSecSales=SUM(OrderQty * Grammage)/1000 FROM #Orders O INNER JOIN #PrdHier P ON P.SKUNodeID=O.ProductID
	 SELECT @TodaysSecSales=SUM(OrderQtyInKG * Grammage)/1000 FROM #Orders O INNER JOIN #PrdHier P ON P.SKUNodeID=O.ProductID WHERE OrderDate=CAST(GETDATE() AS DATE)


	 SELECT @TotalMonthPriSales=SUM(OrderQtyInKG)/1000 FROM #PriOrders
	 SELECT @TodaysPriSales=SUM(OrderQtyInKG)/1000 FROM #PriOrders WHERE OrderDate=CAST(GETDATE() AS DATE)

	 

	 


	CREATE TABLE #tmp(Measures VARCHAR(200),TodaysSummary VARCHAR(50),MTDSummary VARCHAR(50),TableNo TINYINT)
	--- Target Sales Added
	----INSERT INTO #tmp(Measures,TodaysSummary,MTDSummary,TableNo)
	----SELECT 'Primary Target(Tonne)',ROUND(CAST(PrimaryTarget/30 AS FLOAT),2),PrimaryTarget,1 FROM tblCompanyTarget T INNER JOIN #PersonList L ON L.PersonNodeId=T.PersonNodeID WHERE T.RptMonthYear=YEAR(@Date) * 100 + MONTH(@Date)
	----UNION ALL
	----SELECT 'Primary Actual(Tonne)',ISNULL(@TodaysPriSales,0),ISNULL(@TotalMonthPriSales,0),1 FROM tblCompanyTarget T INNER JOIN #PersonList L ON L.PersonNodeId=T.PersonNodeID WHERE T.RptMonthYear=YEAR(@Date) * 100 + MONTH(@Date)
	----UNION ALL
	----SELECT 'Secondary Target(Tonne)',ROUND(SecondaryTarget/30,2),SecondaryTarget,1 FROM tblCompanyTarget T INNER JOIN #PersonList L ON L.PersonNodeId=T.PersonNodeID
	----WHERE T.RptMonthYear=YEAR(@Date) * 100 + MONTH(@Date)
	----UNION ALL
	----SELECT 'Secondary Actual(Tonne)',ISNULL(@TodaysSecSales,0),ISNULL(@TotalMonthSecSales,0),1 FROM tblCompanyTarget T INNER JOIN #PersonList L ON L.PersonNodeId=T.PersonNodeID WHERE T.RptMonthYear=YEAR(@Date) * 100 + MONTH(@Date)


	INSERT INTO #tmp(Measures,TodaysSummary,MTDSummary,TableNo)
	SELECT 'Target Calls' AS Measures, @TargetCalls AS 'TodaysSummary', @TargetCallsMTD AS 'MTDSummary',2
	UNION ALL
	SELECT 'Actual Calls' AS Measures, ISNULL(@ActualCallsONROute,0) + ISNULL(@ActualCallsOffROute,0) AS 'TodaysSummary', ISNULL(@ActualCallsONROuteMTD,0) + ISNULL(@ActualCallsOffROuteMTD,0)  AS 'MTDSummary',2
	--UNION ALL
	--SELECT 'Actual Calls On-Route' AS Measures, @ActualCallsONROute AS 'TodaysSummary', @ActualCallsONROuteMTD AS 'MTDSummary',1
	--UNION ALL
	--SELECT 'Actual Calls Off-Route' AS Measures, @ActualCallsOffROute AS 'TodaysSummary', @ActualCallsOffROuteMTD AS 'MTDSummary',1
	UNION ALL
	SELECT 'Productive Calls' AS Measures, ISNULL(@ProdCallOnRoute,0) + ISNULL(@ProdCallOffRoute,0) AS 'TodaysSummary', ISNULL(@ProdCallOnRouteMTD,0) + ISNULL(@ProdCallOffRouteMTD,0)  AS 'MTDSummary',2
	--UNION ALL
	--SELECT 'Productive Calls On-Route' AS Measures, @ProdCallOnRoute AS 'TodaysSummary', @ProdCallOnRouteMTD AS 'MTDSummary',1
	--UNION ALL
	--SELECT 'Productive Calls Off-Route' AS Measures, @ProdCallOffRoute AS 'TodaysSummary', @ProdCallOffRouteMTD AS 'MTDSummary',1
	UNION ALL
	SELECT 'Calls Remaining' AS Measures, CASE WHEN @TargetCalls-(ISNULL(@ActualCallsONROute,0) + ISNULL(@ActualCallsOffROute,0))<0 THEN 0 ELSE @TargetCalls-(ISNULL(@ActualCallsONROute,0) + ISNULL(@ActualCallsOffROute,0)) END AS 'TodaysSummary', CASE WHEN @TargetCallsMTD-(ISNULL(@ActualCallsONROuteMTD,0) + ISNULL(@ActualCallsOffROuteMTD,0))<0 THEN 0 ELSE @TargetCallsMTD-(ISNULL(@ActualCallsONROuteMTD,0) + ISNULL(@ActualCallsOffROuteMTD,0)) END AS 'MTDSummary',2
	--SELECT 'Calls Remaining' AS Measures, @TargetCalls-@ActualCallsONROute AS 'TodaysSummary', @TargetCallsMTD-@ActualCallsONROuteMTD AS 'MTDSummary',1
	UNION ALL
	SELECT 'Target Stores' AS Measures, @TargetStoreCount AS 'TodaysSummary', @TargetStoreCountMTD AS 'MTDSummary',3
	UNION ALL
	SELECT 'Visited Stores' AS Measures, ISNULL(@ActualStoresVisited,0) AS 'TodaysSummary', ISNULL(@ActualStoresVisitedMTD,0)  AS 'MTDSummary',3
	UNION ALL
	SELECT 'Productive Stores' AS Measures, ISNULL(@ProdStores,0) AS 'TodaysSummary', ISNULL(@ProdStoresMTD,0)  AS 'MTDSummary',3
	UNION ALL
	SELECT 'Stores Remaining' AS Measures, CASE WHEN @TargetStoreCount-(ISNULL(@ActualStoresVisited,0))<0 THEN 0 ELSE @TargetStoreCount-(ISNULL(@ActualStoresVisited,0)) END AS 'TodaysSummary', CASE WHEN @TargetStoreCountMTD-(ISNULL(@ActualStoresVisitedMTD,0))<0 THEN 0 ELSE @TargetStoreCountMTD-(ISNULL(@ActualStoresVisitedMTD,0)) END AS 'MTDSummary',3
	UNION ALL
	SELECT 'Total Lines Ordered' AS Measures,@TotalLines AS 'TodaysSummary',@TotalLinesMTD AS 'MTDSummary',4
	UNION ALL
	SELECT 'Avg Lines per Store' AS Measures,CASE (ISNULL(@ProdCallOnRoute,0)+ISNULL(@ProdCallOffRoute,0)) WHEN 0 THEN 0 ELSE ROUND(CAST(ISNULL(@TotalLines,0) AS FLOAT)/(CAST(ISNULL(@ProdCallOnRoute,0) AS FLOAT)+CAST(ISNULL(@ProdCallOffRoute,0) AS FLOAT)),2) END AS 'TodaysSummary', CASE (ISNULL(@ProdCallOnRouteMTD,0)+ISNULL(@ProdCallOffRouteMTD,0)) WHEN 0 THEN 0 ELSE ROUND(CAST(ISNULL(@TotalLinesMTD,0) AS FLOAT)/(CAST(ISNULL(@ProdCallOnRouteMTD,0) AS FLOAT)+CAST(ISNULL(@ProdCallOffRouteMTD,0) AS FLOAT)),2) END AS 'MTDSummary',4
	UNION ALL
	SELECT 'No of SKUs Ordered' AS Measures,@NoOfSKUsDay AS 'TodaysSummary',@NoOfSKUsMTD AS 'MTDSummary',4
	--UNION ALL
	--SELECT 'Order Vol in KG' AS Measures,@OrderVolInKG AS 'TodaysSummary',@OrderVolInKG_MTD AS 'MTDSummary',3
	--UNION ALL
	--SELECT 'Total Order Value' AS Measures, @TotalSalesForDay AS 'TodaysSummary', @TotalSalesMTD AS 'MTDSummary'
	--UNION ALL
	--SELECT 'Total Sales Value' AS Measures, @TotalInvForDay AS 'TodaysSummary', @TotalInvMTD AS 'MTDSummary'
	--UNION ALL
	--SELECT 'Total Discount Value' AS Measures, @TotalDiscForDay+@TotalOrderDiscForDay AS 'TodaysSummary', @TotalDiscMTD+@TotalOrderDiscMTD AS 'MTDSummary'
	--UNION ALL
	--SELECT 'Placement Outlets' AS Measures, @PlacementOutletsDay AS 'TodaysSummary', @PlacementOutletsMTD AS 'MTDSummary'
	--UNION ALL
	--SELECT 'No of Stores added' AS Measures, @NoOfStoresAddeddDay AS 'TodaysSummary', @NoOfStoresAddeddMTD AS 'MTDSummary',4
	--UNION ALL
	--SELECT '[Value % Achieved]' AS Measure, CASE ISNULL(@TargetDay,0) WHEN 0 THEN 0 ELSE CAST(ROUND((@TotalInvForDay/@TargetDay)*100,2) AS DECIMAL(18,2)) END AS 'TodaysSummary', CASE ISNULL(@TargetVolMTD,0) WHEN 0 THEN 0 ELSE CAST(ROUND((@TotalInvMTD/@TargetVolMTD)*100,2) AS DECIMAL(18,2)) END AS 'MTDSummary'
	----SELECT * FROm #CatWiseMTDOrder
	----SELECT * FROM #CatWiseTodayOrder
	INSERT INTO #tmp(Measures,TodaysSummary,MTDSummary,TableNo)
	SELECT 'Total Order Qty(' + ISNULL(MAX(MTD.UOM),'pcs') + ') : ',CASE MAX(MTD.UOMId) WHEN 3 THEN CAST(SUM(ISNULL(Today.OrderQty,0)) AS INT) ELSE CAST(ISNULL(ROUND(SUM(Today.OrderQtyInKG),2),0) AS DECIMAl(18,2)) END,CASE MAX(MTD.UOMId) WHEN 3 THEN CAST(ISNULL(SUM(MTD.OrderQty),0) AS INT) ELSE CAST(ISNULL(ROUND(SUM(MTD.OrderQtyInKG),2),0) AS DECIMAl(18,2)) END,5
	FROM #CatWiseMTDOrder MTD LEFT JOIN #CatWiseTodayOrder Today ON MTD.CategoryNodeId=Today.CategoryNodeId

	INSERT INTO #tmp(Measures,TodaysSummary,MTDSummary,TableNo)
	SELECT 'Order Qty(' + ISNULL(MTD.UOM,'pcs') + ') : ' + MTD.Category,CASE MTD.UOMId WHEN 3 THEN CAST(ISNULL(Today.OrderQty,0) AS INT) ELSE CAST(ISNULL(ROUND(Today.OrderQtyInKG,2),0) AS DECIMAl(18,2)) END,CASE MTD.UOMId WHEN 3 THEN CAST(ISNULL(MTD.OrderQty,0) AS INT) ELSE CAST(ISNULL(ROUND(MTD.OrderQtyInKG,2),0) AS DECIMAl(18,2)) END,5
	FROM #CatWiseMTDOrder MTD LEFT JOIN #CatWiseTodayOrder Today ON MTD.CategoryNodeId=Today.CategoryNodeId

	INSERT INTO #tmp(Measures,TodaysSummary,MTDSummary,TableNo)
	SELECT 'No of Stores added' AS Measures, @NoOfStoresAddeddDay AS 'TodaysSummary', @NoOfStoresAddeddMTD AS 'MTDSummary',CASE WHEN EXISTS(SELECT 1 FROM #CatWiseMTDOrder) THEN 6 ELSE 5 END


	INSERT INTO #tmp(Measures,TodaysSummary,MTDSummary,TableNo)
	SELECT 'Actual Calls On-Route' AS Measures, @ActualCallsONROute AS 'TodaysSummary', @ActualCallsONROuteMTD AS 'MTDSummary',CASE WHEN EXISTS(SELECT 1 FROM #CatWiseMTDOrder) THEN 7 ELSE 6 END
	UNION ALL
	SELECT 'Actual Calls Off-Route' AS Measures, @ActualCallsOffROute AS 'TodaysSummary', @ActualCallsOffROuteMTD AS 'MTDSummary',CASE WHEN EXISTS(SELECT 1 FROM #CatWiseMTDOrder) THEN 7 ELSE 6 END
	UNION ALL
	SELECT 'Productive Calls On-Route' AS Measures, @ProdCallOnRoute AS 'TodaysSummary', @ProdCallOnRouteMTD AS 'MTDSummary',CASE WHEN EXISTS(SELECT 1 FROM #CatWiseMTDOrder) THEN 7 ELSE 6 END
	UNION ALL
	SELECT 'Productive Calls Off-Route' AS Measures, @ProdCallOffRoute AS 'TodaysSummary', @ProdCallOffRouteMTD AS 'MTDSummary',CASE WHEN EXISTS(SELECT 1 FROM #CatWiseMTDOrder) THEN 7 ELSE 6 END

	SELECT A.Measures,A.TodaysSummary,A.MTDSummary,A.TableNo,B.ColorCode
	FROM #tmp A LEFT JOIN #ColorCodes B ON A.TableNo=B.TableNo

	DECLARE @LastProcessTime Datetime

	SELECT @LastProcessTime=TimestampIns FROM tblOrderMaster OM WHERE EntryPersonNodeId=@PersonID 

	--SELECT @LastProcessTime

	SELECT @LastProcessTime=TIMESTAMP FROM tblVisitMaster VM WHERE EntryPersonNodeId=@PersonID AND  ISNULL(@LastProcessTime,'01-Jan-1900')<TIMESTAMP

	SELECT FORMAT(ISNULL(@LastProcessTime,'01-Jan-1900'),'dd-MMM-yyyy hh:mm:ss tt') LastProcessTime

	SELECT * FROM #Target_Ach
	SELECT * FROM #Target_AchDet

