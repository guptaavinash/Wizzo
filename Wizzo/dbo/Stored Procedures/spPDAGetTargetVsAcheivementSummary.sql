
--EXEC [spPDAGetTargetVsAcheivementSummary] '26-Oct-2021', '314D6CE8-0C6A-4635-9D75-04AC1A56F27A' 
CREATE PROCEDURE [dbo].[spPDAGetTargetVsAcheivementSummary]  
@strDate VARCHAR(20),   
@PDACode VARCHAR(50),
@flgSelf TINYINT = 1, -- 1=Self , 2= Other
@SalesmanNodeID INT=0,
@SalesmanNodeType SMALLINT =0
  
AS  
  
	DECLARE @Date DATETIME,@FirstDate DATETIME,@LastDate DATETIME, @TargetCalls INT=0, @TargetCallsMTD INT=0,@TotalInvForDay DECIMAL(18,2)=0,@TotalInvMTD DECIMAL(18,2)=0  
	DECLARE @WorkingDays INT,@TargetDay DECIMAL(18,2)=0,@TargetMTD DECIMAL(18,2)=0,@AcheivedDay DECIMAL(18,2)=0,@AcheivedMTD DECIMAL(18,2)=0  
	DECLARE @PersonID INT    
	DECLARE @PersonType INT    
	DECLARE @WorkingDaysTillDate INT  
	DECLARE @WorkingDaysRemaining INT  
  
	CREATE TABLE #RouteID (RouteID INT,RouteNodeType TINYINT,FromDate Date,ToDate Date)  
  
	
	--SELECT @PDAID=PDAID FROM [dbo].[tblPDAMaster] WHERE [PDA_IMEI]=@IMENumber OR [PDA_IMEI_Sec]=@IMENumber    
	--PRINT '@PDAID=' + CAST(@PDAID AS VARCHAR)  
	IF LEN(@PDACode)>0    
	BEGIN 
		IF @flgSelf=1
			SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
		ELSE
			SELECT @PersonID=@SalesmanNodeID,@PersonType=@SalesmanNodeType
     
		INSERT INTO #RouteID(RouteID,RouteNodeType,FromDate,ToDate)  
		SELECT distinct CH.NodeID,CH.NodeType,MIN(CH.VldFrom) AS FromDate, MAX(CH.VldTo) AS ToDate 
		FROM tblSalesPersonMapping P
		INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
		INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
		INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
		WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		GROUP BY CH.NodeID,CH.NodeType

		PRINT 'PersonID=' + CAST(@PersonID AS VARCHAR)  
		PRINT 'PersonType=' + CAST(@PersonType AS VARCHAR)  
	END     
	--select * from #RouteID    
  
	Select @Date = REPLACE(CONVERT(VARCHAR, convert(datetime,@strDate,105), 106),' ','-')     
	PRINT '@Date=' + CAST(@Date AS VARCHAR)    
	SELECT @FirstDate=DATEADD(dd,-(DAY(@Date)-1),@Date)  
	PRINT '@FirstDate=' + CAST(@FirstDate AS VARCHAR)   
	SELECT @LastDate=DATEADD(dd,-(DAY(DATEADD(mm,1,@Date))),DATEADD(mm,1,@Date))  
	PRINT '@LastDate=' + CAST(@LastDate AS VARCHAR)   
  
  
	--Target Calls MTD  
	SET  @FirstDate=dateadd(dd, -1, @FirstDate)  
	CREATE TABLE #tmpDays(Dt DATE, WeekNo INT, DayNo INT,WeekEnding DATE);  
	with dateRange as  
	(   
	  select dt = dateadd(dd, 1, @FirstDate)  
	  where dateadd(dd, 1, @FirstDate) <= @LastDate  
	  union all  
	  select dateadd(dd, 1, dt)  
	  from dateRange  
	  where dateadd(dd, 1, dt) <= @LastDate  
	)  
  
	INSERT INTO #tmpDays(Dt)  
	select * from dateRange ORDER BY dt  
	--select * from #tmpDays  
  
	SET  @FirstDate=dateadd(dd, 1, @FirstDate)  
	PRINT @FirstDate  
  
	SET DATEFIRST 1  
	SELECT DISTINCT RCM.RouteId,#RouteID.RouteNodeType,D.Dt,dbo.[fnGetPlannedVisit](RCM.RouteId,RCM.NodeType,D.Dt) AS FlgPlanned INTO #tmpRoute  
	FROM tblRouteCoverage RCM INNER JOIN #RouteID ON RCM.RouteId=#RouteID.RouteID AND RCM.NodeType=#RouteID.RouteNodeType  CROSS JOIN #tmpDays D  
	WHERE (D.Dt BETWEEN #RouteID.FromDate AND #RouteID.ToDate)
	--WHERE RCM.RouteId in(143,145,146,147,148,150,153)  
	ORDER BY RouteId,Dt  
	DELETE FROM #tmpRoute WHERE FlgPlanned=0  
	--SELECT * FROM #tmpRoute WHERE RouteID=14405 ORDER BY Dt  

	CREATE TABLE #StoreCoverage(RouteID INT,RouteNodeType SMALLINT,Dt Date,FlgPlanned TINYINT,StoreID INT,flgVisit TINYINT,flgProd TINYINT)
	INSERT INTO #StoreCoverage(RouteID,RouteNodeType,Dt,FlgPlanned,StoreID)
	SELECT R.RouteID,R.RouteNodeType,R.Dt,R.FlgPlanned,RS.StoreID FROM tblRouteCoverageStoreMapping RS INNER JOIN #tmpRoute R ON RS.RouteID=R.RouteID AND RS.RouteNodeType=R.RouteNodeType AND CAST(GETDATE() AS DATE) BETWEEN RS.FromDate AND RS.ToDate 

	DECLARE @TotStorestobecovered INT
	SELECT @TotStorestobecovered=COUNT(DISTINCT StoreID) FROM #StoreCoverage

	PRINT '@TotStorestobecovered=' + CAST(@TotStorestobecovered AS VARCHAR)

	DECLARE @TotStorestobeVisited INT
	SELECT @TotStorestobeVisited=COUNT(StoreID) FROM #StoreCoverage WHERE FlgPlanned=1

	UPDATE S SET flgVisit=1 FROM #StoreCoverage S INNER JOIN tblVisitMaster VM ON VM.StoreID=S.StoreID AND VM.VisitDate=S.Dt WHERE VM.EntryPersonNodeID=@PersonID AND VM.EntryPersonNodeType=@PersonType
	
	DECLARE @UniqueStoresVisitedMTD INT
	SELECT @UniqueStoresVisitedMTD=COUNT(DISTINCT StoreID) FROM #StoreCoverage WHERE flgVisit=1

	PRINT '@UniqueStoresVisitedMTD=' + CAST(@UniqueStoresVisitedMTD AS VARCHAR)

	DECLARE @ToDaysVisits INT
	SELECT @ToDaysVisits=COUNT(DISTINCT StoreID) FROM #StoreCoverage WHERE flgVisit=1 AND dt=CAST(GETDATE() AS DATE)

	PRINT '@ToDaysVisits=' + CAST(@ToDaysVisits AS VARCHAR)

	DECLARE @StoresVisitedMTD INT
	SELECT @StoresVisitedMTD=COUNT(StoreID) FROM #StoreCoverage WHERE flgVisit=1

	PRINT '@StoresVisitedMTD=' + CAST(@StoresVisitedMTD AS VARCHAR)
	  
	--Total Orders
	SELECT OM.StoreID,VM.VisitID,VM.VisitDate,OM.TotOrderVal INTO #AllOrders FROM tblOrderMaster OM INNER JOIN tblVisitMaster VM ON VM.VisitID=OM.VisitID WHERE OM.EntryPersonNodeId=@PersonID AND OM.EntryPersonNodeType=@PersonType 

	--SELECT * FROM #AllOrders

	UPDATE T SET flgProd=1 FROM #StoreCoverage T INNER JOIN #AllOrders A ON A.StoreID=T.StoreID AND A.VisitDate=T.Dt

	DECLARE @ProdVisitToday INT
	SELECT @ProdVisitToday=COUNT(StoreID) FROM #StoreCoverage WHERE flgProd=1 AND dt=CAST(GETDATE() AS DATE)

	DECLARE @ProdVisitMTD INT
	SELECT @ProdVisitMTD=COUNT(StoreID) FROM #StoreCoverage WHERE flgProd=1
	 
	SELECT * INTO #PrdHier FROm [VwSFAProductHierarchy]

	SELECT OM.StoreID,#PrdHier.SKUNodeID AS PrdHierNodeId,#PrdHier.SKUNodeType AS PrdHierNodeType,ISNULL(SUM(OD.NetLineOrderVal),0) AS OrderVal,SUM(OD.OrderQty) AS OrderQty, CONVERT(VARCHAR(8), OM.OrderDate, 112) AS OrderDate,SUM(OD.OrderQty * #PrdHier.Grammage) OrderVol,OM.OrderID INTO #Order  
	FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId  
	INNER JOIN #PrdHier ON OD.ProductId=#PrdHier.SKUNodeId
	WHERE ISNULL(OM.OrderStatusID,0)<>3 AND OM.SalesPersonId=@PersonID AND OM.SalesPersonType=@PersonType AND MONTH(OM.OrderDate) = MONTH(@Date) AND YEAR(OM.OrderDAte)=YEAR(@Date)  
	GROUP BY OM.StoreID,#PrdHier.SKUNodeID,#PrdHier.SKUNodeType,CONVERT(VARCHAR(8), OM.OrderDate, 112),OM.OrderID 

	DECLARE @UniqueStoresBilledMTD INT
	SELECT @UniqueStoresBilledMTD=COUNT(DISTINCT StoreID) FROM #Order WHERE OrderQty>0

	PRINT '@@UniqueStoresBilledMTD=' + CAST(@UniqueStoresBilledMTD AS VARCHAR)

	DECLARE @ToDaysBilled INT
	SELECT @ToDaysBilled=COUNT(DISTINCT StoreID) FROM #Order WHERE OrderQty>0 AND OrderDate=CAST(GETDATE() AS DATE)

	PRINT '@ToDaysBilled=' + CAST(@ToDaysBilled AS VARCHAR)


	
	--SELECT * FROM #Order 
	DECLARE @AVG_LPC FLOAT
	SELECT COUNT(DISTINCT PrdHierNodeId) Lines,OrderID INTO #LPC FROM #Order GROUP BY OrderID

	SELECT @AVG_LPC = CAST(SUM(Lines) AS FLOAT)/COUNT(OrderID) FROM #LPC

	PRINT '@AVG_LPC=' + CAST(@AVG_LPC AS VARCHAR)
  
	SELECT #PrdHier.SKUNodeID AS PrdHierNodeId,#PrdHier.SKUNodeType AS PrdHierNodeType,ISNULL(SUM(ID.NetLineInvVal),0) AS InvVal,SUM(ID.InvQty) AS InvQty, CONVERT(VARCHAR(8), OM.OrderDate, 112) AS OrderDate INTO #Invoice  
	FROM      tblInvMaster IM  INNER JOIN tblInvDetail ID ON IM.InvId=ID.InvId   
	INNER JOIN tblOrderMaster OM ON IM.OrderId=OM.OrderId  
	INNER JOIN #PrdHier ON ID.ProductId=#PrdHier.SKUNodeId
	WHERE OM.SalesPersonId=@PersonID AND OM.SalesPersonType=@PersonType AND (CONVERT(VARCHAR(6), OM.OrderDate, 112) = CONVERT(VARCHAR(6), @Date, 112))  
	GROUP BY #PrdHier.SKUNodeID,#PrdHier.SKUNodeType,CONVERT(VARCHAR(8), OM.OrderDate, 112)  
  
	--SELECT * FROM #Invoice  
  
	----SELECT @TotalInvForDay=ISNULL(ROUND(SUM(OrderVal),2),0) FROM #Order WHERE OrderDate = CONVERT(VARCHAR, @Date, 112)  
	----SELECT @TotalInvMTD=ISNULL(ROUND(SUM(InvVal),2),0) FROM #Invoice  
	----PRINT '@TotalInvForDay=' + CAST(@TotalInvForDay AS VARCHAR)  
	----PRINT '@TotalInvMTD=' + CAST(@TotalInvMTD AS VARCHAR)  
  
	----SELECT @AcheivedMTD = ISNULL(ROUND(SUM(OrderVal),2),0) FROM #Order WHERE OrderDate < CONVERT(VARCHAR, @Date, 112)  
	----PRINT 'AcheivedMTD=' + CAST(@AcheivedMTD AS VARCHAR)  
  
	SELECT @WorkingDaysRemaining=COUNT(DISTINCT Dt) FROM #tmpRoute WHERE CONVERT(VARCHAR, Dt, 112) >= CONVERT(VARCHAR, @Date, 112)  
	PRINT 'WorkingDaysRemaining=' + CAST(@WorkingDaysRemaining AS VARCHAR)  
  
	SELECT @WorkingDaysTillDate=COUNT(DISTINCT Dt) FROM #tmpRoute WHERE CONVERT(VARCHAR, Dt, 112) <= CONVERT(VARCHAR, @Date, 112)  
	PRINT 'WorkingDaysTillDate=' + CAST(@WorkingDaysTillDate AS VARCHAR)  
  
	SELECT @WorkingDays=COUNT(DISTINCT Dt) FROM #tmpRoute  
	PRINT 'WorkingDays=' + CAST(@WorkingDays AS VARCHAR)  


	CREATE TABLE #TargetReport(TgtMeasureCrtraID INT,TgtMeasureID INT,TgtMeasureName VARCHAR(200),IsPer TINYINT,Tgt INT DEFAULT 0 NOT NULL,[Today^Target] INT DEFAULT 0 NOT NULL,[Today^Ach] INT DEFAULT 0 NOT NULL,[Today^AchPer] INT DEFAULT 0,Todayflg TINYINT DEFAULT 0,MonthTargetProData INT DEFAULT 0 NOT NULL,[MTD^Target] FLOAT DEFAULT 0 NOT NULL,[MTD^Ach] FLOAT DEFAULT 0 NOT NULL,[MTD^AchPer] INT DEFAULT 0,Monthflg TINYINT DEFAULT 0,flgLevel TINYINT DEFAULT 0,LevelNo TINYINT,IsStoreLevel TINYINT,Seq INT)
	
	INSERT INTO #TargetReport(TgtMeasureCrtraID,TgtMeasureID,TgtMeasureName,flgLevel,IsPer,Tgt,LevelNo,IsStoreLevel,Seq)
	SELECT TC.TgtMeasureCrtraID,TC.TgtMeasureID,TC.TgtMeasureName,TC.IsMeasureAggregated,TC.IsPercentage,TD.TargetVal,TC.AggregatedLevel,TC.IsStoreLevel,M.Seq FROM tblTargetMstr TM INNER JOIN tblTargetMeasureCriteria TC ON TM.TgtMeasureCrtraID=TC.TgtMeasureCrtraID INNER JOIN tblTargetMeasureMstr M ON M.TgtMeasureID=TC.TgtMeasureID INNER JOIN tblTargetTimePeriodMstr TP ON TP.TimePeriodNodeId=TC.TimePeriodNodeId AND TP.TimePeriodNodeType=TC.TimePeriodNodeType AND TP.TimePeriodKey=YEAR(CAST(@strDate AS DATE)) * 100 + MONTH(CAST(@strDate AS DATE)) AND TC.TimePeriodNodeType=3 INNER JOIN tblTargetDet TD ON TD.TgtMstrId=TM.TgtMstrID AND TD.SalesmanNodeId=@PersonID AND TD.SalesmanNodeType=@PersonType ORDER BY M.Seq


	--SELECT * FROM #TargetReport
	-- UBO MEasure  ---------------------------------------------------------------------------------------------------------
	UPDATE T SET [MTD^Target]=(Tgt* @TotStorestobecovered)/100  FROM #TargetReport T WHERE T.IsPer=1 AND T.TgtMeasureID=1
	
	UPDATE T SET [MTD^Ach]=@UniqueStoresBilledMTD FROM #TargetReport T WHERE T.IsPer=1 AND T.TgtMeasureID=1
	
	UPDATE T SET [Today^Target]=CASE WHEN [MTD^Target]=0 THEN 0 WHEN @WorkingDaysRemaining=0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))<=0 THEN 0 WHEN @WorkingDaysRemaining=0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))>0 THEN ([MTD^Target]-ISNULL([MTD^Ach],0)) WHEN @WorkingDaysRemaining>0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))<0 THEN 0 ELSE ISNULL(([MTD^Target]-ISNULL([MTD^Ach],0))/CAST(@WorkingDaysRemaining AS FLOAT),0) END FROM #TargetReport T WHERE T.TgtMeasureID=1

	UPDATE T SET [Today^Ach]=@ToDaysBilled FROM #TargetReport T WHERE T.IsPer=1 AND T.TgtMeasureID=1

	---EC Measure-----------------------------------------------------------------------------------------------------------
	UPDATE T SET [MTD^Target]=(Tgt* @TotStorestobeVisited)/100  FROM #TargetReport T WHERE T.IsPer=1 AND T.TgtMeasureID=2
	
	UPDATE T SET [MTD^Ach]=@StoresVisitedMTD FROM #TargetReport T WHERE T.IsPer=1 AND T.TgtMeasureID=2
	
	UPDATE T SET [Today^Target]=CASE WHEN [MTD^Target]=0 THEN 0 WHEN @WorkingDaysRemaining=0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))<=0 THEN 0 WHEN @WorkingDaysRemaining=0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))>0 THEN ([MTD^Target]-ISNULL([MTD^Ach],0)) WHEN @WorkingDaysRemaining>0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))<0 THEN 0 ELSE ISNULL(([MTD^Target]-ISNULL([MTD^Ach],0))/CAST(@WorkingDaysRemaining AS FLOAT),0) END FROM #TargetReport T WHERE T.TgtMeasureID=2

	UPDATE T SET [Today^Ach]=@ToDaysVisits FROM #TargetReport T WHERE T.IsPer=1 AND T.TgtMeasureID=2

	---PC Measure-----------------------------------------------------------------------------------------------------------
	-- Target is calculated based on the effective Calls
	--UPDATE T SET [MTD^Target]=(Tgt* @TotStorestobeVisited)/100  FROM #TargetReport T WHERE T.IsPer=1 AND T.TgtMeasureID=3
	UPDATE T SET [MTD^Target]=X.[MTD^Ach] FROM #TargetReport T,
	( SELECT * FROM  #TargetReport T1 WHERE T1.TgtMeasureID=2 ) X 
	WHERE T.IsPer=1 AND T.TgtMeasureID=3
	
	UPDATE T SET [MTD^Ach]=@ProdVisitMTD FROM #TargetReport T WHERE T.IsPer=1 AND T.TgtMeasureID=3
	
	----UPDATE T SET [Today^Target]=CASE WHEN [MTD^Target]=0 THEN 0 WHEN @WorkingDaysRemaining=0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))<=0 THEN 0 WHEN @WorkingDaysRemaining=0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))>0 THEN ([MTD^Target]-ISNULL([MTD^Ach],0)) WHEN @WorkingDaysRemaining>0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))<0 THEN 0 ELSE ISNULL(([MTD^Target]-ISNULL([MTD^Ach],0))/CAST	(@WorkingDaysRemaining AS FLOAT),0) END FROM #TargetReport T WHERE T.TgtMeasureID=3

	UPDATE T SET [Today^Target]=X.[Today^Ach] FROM #TargetReport T,
	( SELECT * FROM  #TargetReport T1 WHERE T1.TgtMeasureID=2 ) X 
	WHERE T.IsPer=1 AND T.TgtMeasureID=3


	UPDATE T SET [Today^Ach]=@ProdVisitToday FROM #TargetReport T WHERE T.IsPer=1 AND T.TgtMeasureID=3


	---Avg LPC Measure-----------------------------------------------------------------------------------------------------------
	UPDATE T SET [MTD^Target]=Tgt  FROM #TargetReport T WHERE  T.TgtMeasureID=17
	
	UPDATE T SET [MTD^Ach]=ISNULL(@AVG_LPC,0) FROM #TargetReport T WHERE T.TgtMeasureID=17


	--- Product related target ##############################################################################################################
	SELECT C.TgtMeasureCrtraID,D.TargetVal INTO #PrdTarget FROM tblTargetMstr T INNER JOIN tblTargetDet D ON T.TgtMstrID=D.TgtMstrId INNER JOIN tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=T.TgtMeasureCrtraID WHERE SalesmanNodeId=@PersonID AND SalesmanNodeType=@PersonType AND C.IsProductLevel=1


	--- Non Aggregated Measures ------------------------------------------------------------------------------------------------------------------
	SELECT TA.TgtMeasureCrtraID,TA.TgtMeasureID,SUM(O.OrderVol) OrdVol INTO #AchMTD FROM #Order O INNER JOIN tblTargetMeasureAttributeMapping TA ON TA.NodeID=O.PrdHierNodeId AND TA.NodeType=O.PrdHierNodeType WHERE O.Orderdate<=CAST(@strdate AS DATE) GROUP BY TA.TgtMeasureCrtraID,TA.TgtMeasureID

	--SELECT * FROM #Order
	
	SELECT TA.TgtMeasureCrtraID,TA.TgtMeasureID,SUM(O.OrderVol) OrdVol INTO #AchToday FROM #Order O INNER JOIN tblTargetMeasureAttributeMapping TA ON TA.NodeID=O.PrdHierNodeId AND TA.NodeType=O.PrdHierNodeType INNER JOIN #TargetReport R ON R.TgtMeasureCrtraID=TA.TgtMeasureCrtraID 	
	WHERE CAST(O.Orderdate AS DATE)=CAST(@strdate AS DATE) GROUP BY TA.TgtMeasureCrtraID,TA.TgtMeasureID

	--SELECT * FROM #AchToday


	UPDATE T SET [MTD^Target]=Tgt FROM #TargetReport T INNER JOIN tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=T.TgtMeasureCrtraID WHERE T.IsPer=0 AND C.IsMeasureAggregated=0 AND C.IsProductLevel=1


	UPDATE T SET [MTD^Ach]=OrdVol FROM #TargetReport T INNER JOIN #AchMTD A ON A.TgtMeasureCrtraID=T.TgtMeasureCrtraID

	--SELECT * FROM #TargetReport

	UPDATE T SET [Today^Target]=CASE WHEN [MTD^Target]=0 THEN 0 WHEN @WorkingDaysRemaining=0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))<=0 THEN 0 WHEN @WorkingDaysRemaining=0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))>0 THEN ([MTD^Target]-ISNULL([MTD^Ach],0)) WHEN @WorkingDaysRemaining>0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))<0 THEN 0 ELSE ISNULL(([MTD^Target]-ISNULL([MTD^Ach],0))/CAST(@WorkingDaysRemaining AS FLOAT),0) END FROM #TargetReport T INNER JOIN tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=T.TgtMeasureCrtraID  WHERE T.IsPer=0 AND C.IsMeasureAggregated=0 AND C.IsProductLevel=1

	--SELECT * FROM #TargetReport


	UPDATE T SET [Today^Ach]=A.OrdVol FROM #TargetReport T INNER JOIN tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=T.TgtMeasureCrtraID  INNER JOIN #AchToday A ON A.TgtMeasureCrtraID=T.TgtMeasureCrtraID WHERE T.IsPer=0 AND C.IsProductLevel=1 AND C.IsMeasureAggregated=0


	--- Calculation on Aggregated Measures   &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	DECLARE @Count INT,@MAXCount INT
	SELECT @Count=1
	CREATE TABLE #AggMeasure(ID INT IDENTITY(1,1),Level INT)

	INSERT INTO #AggMeasure(Level)
	SELECT DISTINCT M.AggregatedLevel FROM #TargetReport R INNER JOIN tblTargetMeasureCriteria M ON M.TgtMeasureCrtraID=R.TgtMeasureCrtraID WHERE IsMeasureAggregated=1 ORDER BY M.AggregatedLevel asc

	SELECT @MAXCount=COUNT(ID) FROM #AggMeasure
	WHILE @Count<=@MAXCount
	BEGIN
		UPDATE T SET [MTD^Target]=X.TargetVal FROM #TargetReport T ,
		(SELECT C.TgtMeasureCrtraID,SUM(TV.[MTD^Target]) TargetVal FROM #TargetReport T INNER JOIN tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=T.TgtMeasureCrtraID INNER JOIN tblTargetMeasureCriteriaDepMeasure DM ON DM.TgtMeasureCrtraID=C.TgtMeasureCrtraID INNER JOIN #TargetReport TV ON TV.TgtMeasureCrtraID=DM.Depto_TgtMeasureCrtraID WHERE C.IsMeasureAggregated=1 AND C.AggregatedLevel=@Count
		GROUP BY C.TgtMeasureCrtraID ) X WHERE X.TgtMeasureCrtraID=T.TgtMeasureCrtraID

		UPDATE T SET [MTD^Ach]=X.AchVal FROM #TargetReport T ,
		(SELECT C.TgtMeasureCrtraID,SUM(TV.[MTD^Ach]) AchVal FROM #TargetReport T INNER JOIN tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=T.TgtMeasureCrtraID INNER JOIN tblTargetMeasureCriteriaDepMeasure DM ON DM.TgtMeasureCrtraID=C.TgtMeasureCrtraID INNER JOIN #TargetReport TV ON TV.TgtMeasureCrtraID=DM.Depto_TgtMeasureCrtraID WHERE  C.IsMeasureAggregated=1 AND C.AggregatedLevel=@Count 
		GROUP BY C.TgtMeasureCrtraID ) X WHERE X.TgtMeasureCrtraID=T.TgtMeasureCrtraID

		------------	UPDATE #tmp SET #tmp.TodayTarget=CASE WHEN ISNULL(#tmp.MonthTarget,0)=0 THEN 0 WHEN @WorkingDaysRemaining=0 THEN ((#tmp.MonthTarget)-ISNULL(AA.AcheivedOrderQty,0)) ELSE ROUND(((#tmp.MonthTarget)-ISNULL(AA.AcheivedOrderQty,0))/CAST(@WorkingDaysRemaining AS FLOAT),0) END   
------------FROM #tmp --INNER JOIN tblPrdMstrSKULvl B ON #tmp.PrdNodeId=B.NodeId AND #tmp.PrdNodeType=B.NodeType  
------------LEFT JOIN  (SELECT PrdHierNodeId,PrdHierNodeType,ISNULL(SUM(OrderQty),0) AcheivedOrderQty FROM #Order WHERE OrderDate < CONVERT(VARCHAR, @Date, 112) GROUP BY PrdHierNodeId,PrdHierNodeType) AA ON #tmp.PrdHierNodeId=AA.PrdHierNodeId AND #tmp.PrdHierNodeType=AA.PrdHierNodeType 

		UPDATE T SET [Today^Target]=CASE WHEN [MTD^Target]=0 THEN 0 WHEN @WorkingDaysRemaining=0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))<=0 THEN 0 WHEN @WorkingDaysRemaining=0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))>0 THEN ([MTD^Target]-ISNULL([MTD^Ach],0)) WHEN @WorkingDaysRemaining>0 AND ([MTD^Target]-ISNULL([MTD^Ach],0))<0 THEN 0 ELSE ISNULL(([MTD^Target]-ISNULL([MTD^Ach],0))/CAST(@WorkingDaysRemaining AS FLOAT),0) END FROM #TargetReport T INNER JOIN tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=T.TgtMeasureCrtraID  WHERE C.IsMeasureAggregated=1 AND C.AggregatedLevel=@Count

		--UPDATE T SET [Today^Target]=CASE WHEN ISNULL([MTD^Target],0)=0 THEN 0 WHEN @WorkingDaysRemaining=0 THEN ((T.[MTD^Target])-ISNULL(T.[MTD^Ach],0)) ELSE ROUND(((T.[MTD^Target])-ISNULL(T.[MTD^Ach],0))/CAST(@WorkingDaysRemaining AS FLOAT),0) END FROM #TargetReport T 


		--X.TodayTarget FROM #TargetReport T ,
		--(SELECT C.TgtMeasureCrtraID,SUM(TV.[Today^Target]) TodayTarget FROM #TargetReport T INNER JOIN tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=T.TgtMeasureCrtraID INNER JOIN tblTargetMeasureCriteriaDepMeasure DM ON DM.TgtMeasureCrtraID=C.TgtMeasureCrtraID INNER JOIN #TargetReport TV ON TV.TgtMeasureCrtraID=DM.Depto_TgtMeasureCrtraID WHERE C.IsMeasureAggregated=1  AND C.AggregatedLevel=@Count
		--GROUP BY C.TgtMeasureCrtraID ) X WHERE X.TgtMeasureCrtraID=T.TgtMeasureCrtraID

		UPDATE T SET [Today^Ach]=X.TodayAch FROM #TargetReport T ,
		(SELECT C.TgtMeasureCrtraID,SUM(TV.[Today^Ach]) TodayAch FROM #TargetReport T INNER JOIN tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=T.TgtMeasureCrtraID INNER JOIN tblTargetMeasureCriteriaDepMeasure DM ON DM.TgtMeasureCrtraID=C.TgtMeasureCrtraID INNER JOIN #TargetReport TV ON TV.TgtMeasureCrtraID=DM.Depto_TgtMeasureCrtraID WHERE C.IsMeasureAggregated=1 AND C.AggregatedLevel=@Count
		GROUP BY C.TgtMeasureCrtraID ) X WHERE X.TgtMeasureCrtraID=T.TgtMeasureCrtraID
	
		SELECT @Count=@Count + 1
	END
	   	 	

	---- &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	  	 
	--UPDATE #TargetReport SET [Today^Bal]=[Today^Target]-ISNULL([Today^Ach],0) WHERE ISNULL([Today^Target],0)>=0 AND [Today^Target]-ISNULL([Today^Ach],0)>0
	--UPDATE #TargetReport SET [MTD^Bal]=[MTD^Target]-ISNULL([MTD^Ach],0) WHERE ISNULL([MTD^Target],0)>=0 AND [MTD^Target]-ISNULL([MTD^Ach],0)>0 

	UPDATE #TargetReport SET [Today^AchPer]=CAST(ISNULL([Today^Ach],0) * 100/[Today^Target] AS INT) WHERE ISNULL([Today^Target],0)>0 
	UPDATE #TargetReport SET [MTD^AchPer]=CAST(ISNULL([MTD^Ach],0) * 100/[MTD^Target] AS INT) WHERE ISNULL([MTD^Target],0)>0 
	
	UPDATE #TargetReport SET #TargetReport.MonthTargetProData=CASE @WorkingDays WHEN 0 THEN [MTD^Target] ELSE CAST(([MTD^Target]*@WorkingDaysTillDate) AS FLOAT)/CAST(@WorkingDays AS FLOAT) END

	UPDATE #TargetReport SET Todayflg=CASE WHEN ROUND(([Today^Ach]/[Today^Target])*100,0)<90 THEN 1 WHEN ROUND(([Today^Ach]/[Today^Target])*100,0)>=90 AND ROUND(([Today^Ach]/[Today^Target])*100,0)<100 THEN 2 WHEN ROUND(([Today^Ach]/[Today^Target])*100,0)>=100 AND ROUND(([Today^Ach]/[Today^Target])*100,0)<=105 THEN 3 WHEN ROUND(([Today^Ach]/[Today^Target])*100,0)>105 THEN 4 END  
	WHERE ISNULL([Today^Target],0)>0   
  
    UPDATE #TargetReport SET Todayflg= 4 WHERE ISNULL([Today^Target],0)=0 


	UPDATE #TargetReport SET Monthflg=CASE WHEN ROUND(([MTD^Ach]/MonthTargetProData)*100,0)<90 THEN 1 WHEN ROUND(([MTD^Ach]/MonthTargetProData)*100,0)>=90 AND ROUND(([MTD^Ach]/MonthTargetProData)*100,0)<100 THEN 2 WHEN ROUND(([MTD^Ach]/MonthTargetProData)*100,0)>=100 AND ROUND(([MTD^Ach]/MonthTargetProData)*100,0)<=105 THEN 3 WHEN ROUND(([MTD^Ach]/MonthTargetProData)*100,0)>105 THEN 4 END  
	WHERE ISNULL(MonthTargetProData,0)>0  

	
  


	SELECT TgtMeasureName Descr,[Today^Target] TodayTarget,[Today^Ach] TodayAchieved,[Today^AchPer] TodayAchPer,Todayflg,ROUND([MTD^Target],0) MonthTarget,ROUND([MTD^Ach],2) MonthAchieved,[MTD^AchPer] MonthAchPer,Monthflg,flgLevel,CASE WHEN TgtMeasureID IN (4,11,16) THEN 1 ELSE 0 END flgStyleBold,IsStoreLevel FROM #TargetReport ORDER BY Seq


  
------------	--SELECT @Date='05-Mar-2017'  
------------	SELECT #PrdHier.CategoryNodeId AS PrdHierNodeId,#PrdHier.CategoryNodeType AS PrdHierNodeType,ISNULL(SUM(#PrdHier.StandardRate*B.TargetVal),0) AS TargetVal,SUM(B.TargetVal) AS TargetVolnPcs INTO #tmpPrdWiseTarget  
------------	FROM tblTargetMstr A INNER JOIN tblTargetDet B ON A.TgtMstrId=B.TgtMstrId  
------------	INNER JOIN tblTargetTimePeriodMstr C ON A.TimePeriodNodeId=C.TimePeriodNodeId AND A.TimePeriodNodeType=C.TimePeriodNodeType  
------------	INNER JOIN #PrdHier ON B.PrdNodeId=#PrdHier.SKUNodeId AND B.PrdNodeType=#PrdHier.SKUNodeType  
------------	WHERE A.MeasureId=1 AND B.SalesmanNodeId=@PersonID AND B.SalesmanNodeType=@PersonType AND C.TimePeriodKey=CONVERT(VARCHAR(6), @Date, 112)  
------------	GROUP BY #PrdHier.CategoryNodeId,#PrdHier.CategoryNodeType  
  
------------	--SELECT * FROM #tmpPrdWiseTarget  
  
------------	SELECT @TargetMTD=ISNULL(SUM(TargetVal),0) FROM #tmpPrdWiseTarget  
------------	PRINT 'TargetMTD=' + CAST(@TargetMTD AS VARCHAR)  
  
------------	SELECT @TargetDay = CASE WHEN @TargetMTD=0 THEN 0 WHEN @WorkingDaysRemaining=0 THEN (@TargetMTD-ISNULL(@AcheivedMTD,0)) ELSE ISNULL((@TargetMTD-ISNULL(@AcheivedMTD,0))/CAST	(@WorkingDaysRemaining AS FLOAT),0) END  
------------	PRINT 'TargetDay=' + CAST(@TargetDay AS VARCHAR)  
  
  
------------	CREATE TABLE #tmp(PrdHierNodeId INT,PrdHierNodeType INT,Descr VARCHAR(200),TodayTarget FLOAT DEFAULT 0 NOT NULL,TodayAchieved FLOAT DEFAULT 0 NOT NULL,TodayBalance FLOAT DEFAULT 0 NOT NULL,Todayflg TINYINT,MonthTargetProData FLOAT DEFAULT 0 NOT NULL,MonthTarget FLOAT DEFAULT 0 NOT NULL,MonthAchieved FLOAT DEFAULT 0 NOT NULL,MonthBalance FLOAT DEFAULT 0 NOT NULL,Monthflg TINYINT)  
  
------------	INSERT INTO #tmp(PrdHierNodeId,PrdHierNodeType,Descr,TodayTarget,TodayAchieved,Todayflg,MonthTarget,MonthTargetProData,MonthAchieved,Monthflg)  
------------SELECT 0,0,'Value Target',@TargetDay,@TotalInvForDay,0,@TargetMTD,CASE @WorkingDays WHEN 0 THEN @TargetMTD ELSE CAST((@TargetMTD*@WorkingDaysTillDate) AS FLOAT)/CAST(@WorkingDays AS FLOAT) END,@TotalInvMTD,0  
--------------SELECT 0,0,'Value Target',@TargetDay,CAST(ROUND(@TotalInvForDay,2) AS DECIMAL(18,2)),0,CAST(ROUND(@TargetMTD,2) AS DECIMAL(18,2)),CAST(ROUND(@TotalInvMTD,2) AS DECIMAL(18,2)),0  
  
------------	INSERT INTO #tmp(PrdHierNodeId,PrdHierNodeType,Descr,Todayflg,Monthflg)  
------------	SELECT DISTINCT CategoryNodeId,CategoryNodeType,Category + '-' + Category,0,0  
------------	FROM #PrdHier --WHERE IsActive=1  
  
  
--------------UPDATE #tmp SET #tmp.MonthTarget=AA.TargetVolInCase FROM #tmp INNER JOIN (SELECT PrdNodeId,PrdNodeType,ISNULL(TargetVolInCase,0) TargetVolInCase FROM #tmpPrdWiseTarget) AA ON #tmp.PrdNodeId=AA.PrdNodeId AND #tmp.PrdNodeType=AA.PrdNodeType  
  
------------	UPDATE #tmp SET #tmp.MonthTarget=ISNULL(AA.TargetVolnPcs,0) FROM #tmp INNER JOIN #tmpPrdWiseTarget AA ON #tmp.PrdHierNodeId=AA.PrdHierNodeId AND #tmp.PrdHierNodeType=AA.PrdHierNodeType  
------------	UPDATE #tmp SET #tmp.MonthTargetProData=CASE @WorkingDays WHEN 0 THEN MonthTarget ELSE CAST((MonthTarget*@WorkingDaysTillDate) AS FLOAT)/CAST(@WorkingDays AS FLOAT) END  
  
------------	UPDATE #tmp SET #tmp.MonthAchieved=ROUND(CAST(AA.InvQty AS FLOAT),1) FROM #tmp INNER JOIN (SELECT PrdHierNodeId,PrdHierNodeType,ISNULL(SUM(InvQty),0) InvQty FROM #Invoice GROUP BY PrdHierNodeId,PrdHierNodeType) AA ON #tmp.PrdHierNodeId=AA.PrdHierNodeId AND #tmp.PrdHierNodeType=AA.PrdHierNodeType 
------------	--INNER JOIN tblPrdMstrSKULvl B ON AA.PrdNodeId=B.NodeId AND AA.PrdNodeType=B.NodeType  
  
------------	--UPDATE #tmp SET #tmp.MonthAchieved=AA.InvQty FROM #tmp INNER JOIN  (SELECT A.PrdNodeId,A.PrdNodeType,ROUND(CAST(ISNULL(A.InvQty,0) AS FLOAT)/CAST(B.CaseSize AS FLOAT),2) InvQty FROM #Invoice A INNER JOIN tblPrdMstrSKULvl B ON A.PrdNodeId=B.NodeId AND A.PrdNodeType=B.NodeType) AA ON #tmp.PrdNodeId=AA.PrdNodeId AND #tmp.PrdNodeType=AA.PrdNodeType  
  
------------	--UPDATE #tmp SET #tmp.TodayAchieved=AA.AcheivedInvQty FROM #tmp INNER JOIN  (SELECT PrdNodeId,PrdNodeType,ISNULL(InvQty,0) AcheivedInvQty FROM #Invoice WHERE OrderDate = CONVERT(VARCHAR, @Date, 112)) AA ON #tmp.PrdNodeId=AA.PrdNodeId AND #tmp.PrdNodeType=AA.PrdNodeType  
  
------------	UPDATE #tmp SET #tmp.TodayAchieved=ISNULL(AA.OrderQty,0) FROM #tmp INNER JOIN #Order AA ON #tmp.PrdHierNodeId=AA.PrdHierNodeId AND #tmp.PrdHierNodeType=AA.PrdHierNodeType  
------------WHERE OrderDate = CONVERT(VARCHAR, @Date, 112)  
  
------------	UPDATE #tmp SET #tmp.TodayTarget=CASE WHEN ISNULL(#tmp.MonthTarget,0)=0 THEN 0 WHEN @WorkingDaysRemaining=0 THEN ((#tmp.MonthTarget)-ISNULL(AA.AcheivedOrderQty,0)) ELSE ROUND(((#tmp.MonthTarget)-ISNULL(AA.AcheivedOrderQty,0))/CAST(@WorkingDaysRemaining AS FLOAT),0) END   
------------FROM #tmp --INNER JOIN tblPrdMstrSKULvl B ON #tmp.PrdNodeId=B.NodeId AND #tmp.PrdNodeType=B.NodeType  
------------LEFT JOIN  (SELECT PrdHierNodeId,PrdHierNodeType,ISNULL(SUM(OrderQty),0) AcheivedOrderQty FROM #Order WHERE OrderDate < CONVERT(VARCHAR, @Date, 112) GROUP BY PrdHierNodeId,PrdHierNodeType) AA ON #tmp.PrdHierNodeId=AA.PrdHierNodeId AND #tmp.PrdHierNodeType=AA.PrdHierNodeType  
  
------------	UPDATE #tmp SET Todayflg=CASE WHEN ROUND((TodayAchieved/TodayTarget)*100,0)<90 THEN 1 WHEN ROUND((TodayAchieved/TodayTarget)*100,0)>=90 AND ROUND((TodayAchieved/TodayTarget)*100,0)<100 THEN 2 WHEN ROUND((TodayAchieved/TodayTarget)*100,0)>=100 AND ROUND((TodayAchieved/TodayTarget)*100,0)<=105 THEN 3 WHEN ROUND((TodayAchieved/TodayTarget)*100,0)>105 THEN 4 END  
------------WHERE ISNULL(TodayTarget,0)>0   
  
------------	UPDATE #tmp SET Monthflg=CASE WHEN ROUND((MonthAchieved/MonthTargetProData)*100,0)<90 THEN 1 WHEN ROUND((MonthAchieved/MonthTargetProData)*100,0)>=90 AND ROUND((MonthAchieved/MonthTargetProData)*100,0)<100 THEN 2 WHEN ROUND((MonthAchieved/MonthTargetProData)*100,0)>=100 AND ROUND((MonthAchieved/MonthTargetProData)*100,0)<=105 THEN 3 WHEN ROUND((MonthAchieved/MonthTargetProData)*100,0)>105 THEN 4 END  
------------WHERE ISNULL(MonthTargetProData,0)>0  
  
	------------UPDATE #tmp SET TodayBalance=TodayTarget-ISNULL(TodayAchieved,0) WHERE ISNULL(TodayTarget,0)>0  
	------------UPDATE #tmp SET MonthBalance=MonthTarget-ISNULL(MonthAchieved,0) WHERE ISNULL(MonthTarget,0)>0  
  
--SELECT * FROM #tmp  
  
--SELECT Descr,CASE PrdNodeId WHEN 0 THEN 'Rs ' + CAST(CAST(TodayTarget AS DECIMAL(18,0)) AS VARCHAR) ELSE CAST(TodayTarget AS VARCHAR) + ' Pcs' END AS TodayTarget,   
--CASE PrdNodeId WHEN 0 THEN 'Rs ' + CAST(CAST(TodayAchieved AS DECIMAL(18,0)) AS VARCHAR) ELSE CAST(TodayAchieved AS VARCHAR) + ' Pcs' END AS TodayAchieved,Todayflg,  
--CASE PrdNodeId WHEN 0 THEN 'Rs ' + CAST(CAST(MonthTarget AS DECIMAL(18,0)) AS VARCHAR) ELSE CAST(MonthTarget AS VARCHAR) + ' Cases' END AS MonthTarget,  
--CASE PrdNodeId WHEN 0 THEN 'Rs ' + CAST(CAST(MonthAchieved AS DECIMAL(18,0)) AS VARCHAR) ELSE CAST(MonthAchieved AS VARCHAR) + ' Cases' END AS MonthAchieved,Monthflg  
--FROM #tmp  
--WHERE PrdNodeId=0  
  
	----------SELECT Descr, 'Rs ' + CAST(CAST(TodayTarget AS DECIMAL(18,0)) AS VARCHAR) AS TodayTarget,'Rs ' + CAST(CAST(TodayAchieved AS DECIMAL(18,0)) AS VARCHAR) AS TodayAchieved,'Rs ' + CAST(CAST(TodayBalance AS DECIMAL(18,0)) AS VARCHAR) AS TodayBalance,Todayflg, 'Rs ' + CAST(CAST(MonthTarget AS DECIMAL(18,0)) AS VARCHAR) AS MonthTarget,'Rs ' + CAST(CAST(MonthAchieved AS DECIMAL(18,0)) AS VARCHAR) AS MonthAchieved,'Rs ' + CAST(CAST(MonthBalance AS DECIMAL(18,0)) AS VARCHAR) AS MonthBalance,Monthflg  
	----------FROM #tmp  
	----------WHERE PrdHierNodeId=0  
  
	----------SELECT Descr,TodayTarget,TodayAchieved,TodayBalance,Todayflg,MonthTarget,MonthAchieved,MonthBalance,Monthflg  
	----------FROM #tmp  
	----------WHERE PrdHierNodeId>0  
	----------ORDER BY Descr
  
	SELECT '' AS MsgToDisplay ,@TotStorestobecovered TotalStores 
  
  
