-- SpTargetVsAchievement_New 'DF57195F-D633-4041-B8A6-EBC2D0506E98',0,0
CREATE PROCEDURE [dbo].[SpTargetVsAchievement_New] 
	@PDACode VARCHAR(50),
	@SalesPersonID INT,
	@SalesPersonType SMALLINT
AS
BEGIN
	DECLARE @PersonID INT  =0
	DECLARE @PersonType INT  =0
	DECLARE @ASMAreaNodeId INT
	DECLARE @ASMAreaNodeType INT

	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	PRINT '@PersonID=' + CAST(@PersonID AS VARCHAR)
	PRINT '@@PersonType=' + CAST(@PersonType AS VARCHAR)

	CREATE TABLE #PersonList(PersonNodeId INT,PersonNodeType INT)

	IF @PersonType=210 AND @SalesPersonID=0
	BEGIN
		INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
		SELECT @PersonID,@PersonType

		SELECT * INTO #SalesHier FROM VwSalesHierarchyFull

		SELECT @ASMAreaNodeId=NodeId,@ASMAreaNodeType=NodeType
		FROM tblSalesPersonMapping SP
		WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(SP.ToDate,GETDATE())) AND SP.PersonNodeId=@PersonID ANd SP.PersonType=@PersonType AND SP.NodeType=110

		INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
		SELECT DISTINCT SP.PersonNodeId,SP.PersonType
		FROM #SalesHier H INNER JOIN tblSalesPersonMapping SP ON H.ComCoverageAreaID=SP.NodeId AND H.ComCoverageAreaType=SP.NodeType
		WHERE (GETDATE() BETWEEN SP.FromDate AND ISNULL(SP.ToDate,GETDATE())) ANd H.ASMAreaNodeId=@ASMAreaNodeId AND H.ASMAreaNodeType=@ASMAreaNodeType AND SP.PersonNodeId<>@PersonID


	END
	ELSE IF @PersonType=220 AND @SalesPersonID=0
	BEGIN
		INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
		SELECT @PersonID,@PersonType
	END
	ELSE IF @PersonType=210 AND @SalesPersonID>0
	BEGIN
		INSERT INTO #PersonList(PersonNodeId,PersonNodeType)
		SELECT @SalesPersonID,@SalesPersonType
	END

	-- Month Target
	SELECT CT.CovNodeID,CT.CovNodeType,P.PersonNodeId,P.PersonNodeType,CT.PrimaryTarget,CT.SecondaryTarget INTO #MonthSalesTarget FROM tblCompanyTarget CT INNER JOIN #PersonList P ON P.PersonNodeId=CT.PersonNodeID AND P.PersonNodeType=CT.PersonNodeType WHERE YEAR(GETDATE()) * 100 + MONTH(GETDATE())=RptMonthYear

	SELECT SUM(PrimaryTarget) PrimaryTarget,SUM(SecondaryTarget) SecondaryTarget INTO #OverAllMTDTarget FROM #MonthSalesTarget

	--- Gate Meeting Target for the month
	SELECT DataDate,Sales_Tgt,Dstrbn_Tgt INTO #GatemeetingTgtDaywise FROM tblGateMeetingTarget G INNER JOIN #PersonList P ON P.PersonNodeId=G.PersonNodeID WHERE YEAR(GETDATE()) * 100 + MONTH(GETDATE())=YEAR(DataDate) * 100 + MONTH(DataDate)
	
	-- Focus brand GAte Meeting Target 
	SELECT DataDate,D.SKUNodeID,D.SKUNodeType,D.Sales_Tgt,D.Dstrbn_Tgt INTO #FocusbrandGatemeetingTgtDaywise FROM tblGateMeetingTarget G INNER JOIN tblGateMeetingTargetDet D ON D.PersonMeetingID=G.PersonMeetingID WHERE YEAR(GETDATE()) * 100 + MONTH(GETDATE())=YEAR(DataDate) * 100 + MONTH(DataDate)

	

	-- Distribution Target
	SELECT P.PersonNodeId,P.PersonNodeType,RV.RouteNodeId,RV.RouteNodetype,RS.StoreID,RV.VisitDate INTO #DistributionTArget FROM tblRoutePlanningVisitDetail(nolock) RV INNER JOIN #PersonList P ON P.PersonNodeId=RV.DSENodeId AND P.PersonNodeType=RV.DSENodeType INNER JOIN tblRouteCoverageStoreMapping RS ON RS.RouteID=RV.RouteNodeId AND RS.RouteNodeType=RV.RouteNodetype
	WHERE YEAR(GETDATE()) * 100 + MONTH(GETDATE())=YEAR(RV.VisitDate) * 100 + MONTH(RV.VisitDate) AND RS.ToDate>=CAST(GETDATE() AS DATE)

	-- Achievement Sales 
	CREATE TABLE #Orders(VisitId INT,StoreId INT,OrderDate DATE,ProductID INT,OrderQty INT,OrderQtyInKG FLOAT,CategoryNodeId INT,Category VARCHAR(200), CategoryOrdr TINYINT )
	SELECT * INTO #PrdHier FROm VwSFAProductHierarchy

	INSERT INTO #Orders(VisitId,StoreId,OrderDate,ProductID,OrderQty,OrderQtyInKG,CategoryNodeId,Category,CategoryOrdr)
	SELECT OM.VisitId,OM.StoreID,OM.OrderDate,OD.ProductID,OD.OrderQty,(OD.OrderQty * Grammage)/1000 AS OrderQtyInKG,Hier.CategoryNodeId,Hier.Category, Hier.CatOrdr
	FROM tblVisitMaster VM INNER JOIN tblOrderMaster OM ON VM.VisitId=OM.VisitId 
	INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
	INNER JOIN #PrdHier Hier ON OD.ProductId=Hier.SKUNodeId
	INNER JOIN #PersonList P ON OM.SalesPersonId=P.PersonNodeId AND OM.SalesPersonType=P.PersonNodeType
	WHERE (CONVERT(VARCHAR(6), OM.OrderDate, 112) = CONVERT(VARCHAR(6), GETDATE(), 112)) AND OD.OrderQty>0 AND ISNULL(OM.OrderStatusId,0)<>3 

	SELECT D.VisitDate DataDate,SUM(OrderQtyInKG) VolSales INTO #OverAllDateWiseSales FROM #Orders O INNER JOIN #DistributionTArget D ON D.StoreID=O.StoreId GROUP BY D.VisitDate
	SELECT SUM(VolSales) VolSales INTO #OverAllSales FROM #OverAllDateWiseSales O

	SELECT COUNT(DISTINCT StoreID) Dstrbn INTO #DistributionAch FROM #Orders
	SELECT OrderDate,COUNT(DISTINCT StoreID) Dstrbn INTO #DistributionDayWiseAch FROM #Orders GROUP BY OrderDate

	DECLARE @CurrentDayRate_Dist FLOAT
	SELECT @CurrentDayRate_Dist= (SELECT Dstrbn  FROM #DistributionAch)/(SELECT COUNT(DISTINCT VisitDAte) FROM #DistributionTArget WHERE VisitDate<GETDATE()) WHERE (SELECT COUNT(DISTINCT VisitDAte) FROM #DistributionTArget WHERE VisitDate<GETDATE())>0

	DECLARE @RequiredDayRAte_Dist FLOAT
	SELECT @RequiredDayRAte_Dist=(SELECT COUNT(DISTINCT StoreID) FROM #DistributionTArget) - (SELECT Dstrbn  FROM #DistributionAch)/(SELECT COUNT(DISTINCT VisitDAte) FROM #DistributionTArget WHERE VisitDate>=CAST(GETDATE() AS DATE)) WHERE  (SELECT COUNT(DISTINCT VisitDAte) FROM #DistributionTArget WHERE VisitDate>=CAST(GETDATE() AS DATE))>0

	DECLARE @CurrentDayRAte FLOAT
	SELECT @CurrentDayRAte= (SELECT SUM(VolSales) VolSales  FROM #OverAllDateWiseSales)/(SELECT COUNT(DISTINCT VisitDAte) FROM #DistributionTArget WHERE VisitDate<GETDATE()) WHERE (SELECT COUNT(DISTINCT VisitDAte) FROM #DistributionTArget WHERE VisitDate<GETDATE())>0

	DECLARE @RequiredDayRAte FLOAT
	SELECT @RequiredDayRAte=(SELECT SUM(SecondaryTarget) FROM #MonthSalesTarget) - (SELECT CAST(SUM(VolSales) AS FLOAT)/1000 VolSales  FROM #OverAllDateWiseSales)/(SELECT COUNT(DISTINCT VisitDAte) FROM #DistributionTArget WHERE VisitDate>=CAST(GETDATE() AS DATE)) WHERE (SELECT COUNT(DISTINCT VisitDAte) FROM #DistributionTArget WHERE VisitDate>=CAST(GETDATE() AS DATE))>0

	-- Focus Brand
	SELECT TOP 1 SKUNodeID,SKUNOdeType INTO #tblFocusbrandmapping FROM tblFocusbrandmapping WHERE ToDate>GETDATE()
	SELECT FB.SKUNodeID,D.VisitDate DataDate,SUM(OrderQtyInKG) VolSales INTO #FocusBrandDateWiseSales FROM #Orders O INNER JOIN #DistributionTArget D ON D.StoreID=O.StoreId INNER JOIN #tblFocusbrandmapping FB ON FB.SKUNodeID=O.ProductID GROUP BY FB.SKUNodeID,D.VisitDate

	SELECT SKUNodeID,SUM(VolSales) VolSales INTO #FocusBrandSales  FROM #FocusBrandDateWiseSales GROUP BY SKUNodeID

	SELECT FB.SKUNodeID,D.VisitDate DataDate,COUNT(DISTINCT O.StoreID) Dstrbn INTO #FocusBrandDateWiseDistribution FROM #Orders O INNER JOIN #DistributionTArget D ON D.StoreID=O.StoreId INNER JOIN #tblFocusbrandmapping FB ON FB.SKUNodeID=O.ProductID GROUP BY FB.SKUNodeID,D.VisitDate 

	SELECT SKUNodeID,COUNT(DISTINCT O.StoreID) Dstrbn INTO #FocusBrandDistribution  FROM #Orders O INNER JOIN #DistributionTArget D ON D.StoreID=O.StoreId INNER JOIN #tblFocusbrandmapping FB ON FB.SKUNodeID=O.ProductID GROUP BY SKUNodeID

	--CREATE TABLE #ReportDaywise(DataDate Date,SKUNOdeID INT,SKUNOdeType)

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

	-- OverAll Volume

	UPDATE #Target_Ach SET [MonthTgt]=M.SecondaryTarget FROM  #OverAllMTDTarget M  WHERE LevelNo=0 AND MeasureID=1
	UPDATE #Target_Ach SET [MTD_Ach]=S.VolSales FROM #OverAllSales S  WHERE LevelNo=0 AND MeasureID=1
	UPDATE #Target_Ach SET [CurrentDayRate]=@CurrentDayRAte FROM #Target_Ach  WHERE LevelNo=0 AND MeasureID=1
	UPDATE #Target_Ach SET RequiredDayRate=@RequiredDayRAte FROM #Target_Ach  WHERE LevelNo=0 AND MeasureID=1

	--- OverAll Distribution

	UPDATE #Target_Ach SET [MonthTgt]=D.Dstrbn FROM (SELECT COUNT(DISTINCT StoreID) Dstrbn FROM #DistributionTArget) D  WHERE LevelNo=0 AND MeasureID=2
	UPDATE #Target_Ach SET [MTD_Ach]=Dstrbn FROM #DistributionAch  WHERE LevelNo=0 AND MeasureID=2
	UPDATE #Target_Ach SET [CurrentDayRate]=@CurrentDayRate_Dist FROM #DistributionAch  WHERE LevelNo=0 AND MeasureID=2
	UPDATE #Target_Ach SET RequiredDayRate=@RequiredDayRAte_Dist FROM #DistributionAch  WHERE LevelNo=0 AND MeasureID=2

	--- Focus Brand
	UPDATE #Target_Ach SET [MTD_Ach]=S.VolSales FROM #FocusBrandSales S  WHERE LevelNo=0 AND MeasureID=3
	UPDATE #Target_Ach SET [MTD_Ach]=Dstrbn FROM #FocusBrandDistribution S  WHERE LevelNo=0 AND MeasureID=4 


	   	  
	--DayData
	CREATE TABLE #Target_AchDay([LevelNo] TINYINT,DataDate Date,MeasureID INT,Measure VARCHAR(100),Target NUMERIC(10,4) DEFAULT 0,Achievement NUMERIC(10,4) DEFAULT 0)

	INSERT INTO #Target_AchDay([LevelNo],MeasureID,Measure,Target,Achievement)
	SELECT 0,1,'OverAll Volume',0,0
	UNION
	SELECT 0,2,'OverAll Distribution',0,0
	UNION
	SELECT 0,3,'FB-Volume',0,0
	UNION
	SELECT 0,4,'FB-Distribution',0,0


	--- Daywise Gatemeeting target update
	UPDATE #Target_AchDay SET Target=S.Sales_Tgt FROM #GatemeetingTgtDaywise S  WHERE LevelNo=0 AND MeasureID=1 AND S.DataDate=CAST(GETDATE() AS DATE)
	UPDATE #Target_AchDay SET Achievement=S.VolSales FROM #OverAllDateWiseSales S  WHERE LevelNo=0 AND MeasureID=1 AND S.DataDate=CAST(GETDATE() AS DATE)

	UPDATE #Target_AchDay SET Target=S.Dstrbn_Tgt FROM #GatemeetingTgtDaywise S  WHERE LevelNo=0 AND MeasureID=2 AND S.DataDate=CAST(GETDATE() AS DATE)
	UPDATE #Target_AchDay SET Achievement=S.Dstrbn FROM #DistributionDayWiseAch S  WHERE LevelNo=0 AND MeasureID=2 AND S.OrderDate=CAST(GETDATE() AS DATE)

	--Focus Brand Sales
	UPDATE #Target_AchDay SET Target=S.Sales_Tgt FROM #FocusbrandGatemeetingTgtDaywise S  WHERE LevelNo=0 AND MeasureID=3 AND S.DataDate=CAST(GETDATE() AS DATE)
	UPDATE #Target_AchDay SET Achievement=S.VolSales FROM #FocusBrandDateWiseSales S  WHERE LevelNo=0 AND MeasureID=3 AND S.DataDate=CAST(GETDATE() AS DATE)
	
	--Focus Brand Distribution
	UPDATE #Target_AchDay SET Target=S.Dstrbn_Tgt FROM #FocusbrandGatemeetingTgtDaywise S  WHERE LevelNo=0 AND MeasureID=4 AND S.DataDate=CAST(GETDATE() AS DATE)
	UPDATE #Target_AchDay SET Achievement=S.Dstrbn FROM #FocusBrandDateWiseDistribution S  WHERE LevelNo=0 AND MeasureID=4 AND S.DataDate=CAST(GETDATE() AS DATE)

	--- Historical Data
	DECLARE @StartDate DATE =DATEADD(month,MONTH(GETDATE())-1,DATEADD(year,YEAR(GETDATE())-1900,0))
	DECLARE @EndDate DATE =DATEADD(d,-1,GETDATE())

	SELECT  TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1) Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @StartDate) INTO #tblDates
	FROM    sys.all_objects a CROSS JOIN sys.all_objects b

	INSERT INTO #Target_AchDay([LevelNo],DataDate,MeasureID,Measure,Target,Achievement)
	SELECT 1,Date,1,'OverAll Volume',0,0 FROM #tblDates
	UNION
	SELECT 1,Date,2,'OverAll Distribution',0,0 FROM #tblDates
	UNION
	SELECT 1,Date,3,'FB-Volume',0,0 FROM #tblDates
	UNION
	SELECT 1,Date,4,'FB-Distribution',0,0 FROM #tblDates

	UPDATE #Target_AchDay SET Target=S.Sales_Tgt FROM #GatemeetingTgtDaywise S  WHERE LevelNo=1 AND MeasureID=1 AND S.DataDate=#Target_AchDay.DataDate
	UPDATE #Target_AchDay SET Achievement=S.VolSales FROM #OverAllDateWiseSales S  WHERE LevelNo=1 AND MeasureID=1 AND S.DataDate=#Target_AchDay.DataDate

	UPDATE #Target_AchDay SET Target=S.Dstrbn_Tgt FROM #GatemeetingTgtDaywise S  WHERE LevelNo=1 AND MeasureID=2 AND S.DataDate=#Target_AchDay.DataDate
	UPDATE #Target_AchDay SET Achievement=S.Dstrbn FROM #DistributionDayWiseAch S  WHERE LevelNo=1 AND MeasureID=2 AND S.OrderDate=#Target_AchDay.DataDate

	--Focus Brand Sales
	UPDATE #Target_AchDay SET Target=S.Sales_Tgt FROM #FocusbrandGatemeetingTgtDaywise S  WHERE LevelNo=1 AND MeasureID=3 AND S.DataDate=#Target_AchDay.DataDate
	UPDATE #Target_AchDay SET Achievement=S.VolSales FROM #FocusBrandDateWiseSales S  WHERE LevelNo=1 AND MeasureID=3 AND S.DataDate=#Target_AchDay.DataDate
	
	--Focus Brand Distribution
	UPDATE #Target_AchDay SET Target=S.Dstrbn_Tgt FROM #FocusbrandGatemeetingTgtDaywise S  WHERE LevelNo=1 AND MeasureID=4 AND S.DataDate=#Target_AchDay.DataDate
	UPDATE #Target_AchDay SET Achievement=S.Dstrbn FROM #FocusBrandDateWiseDistribution S  WHERE LevelNo=1 AND MeasureID=4 AND S.DataDate=#Target_AchDay.DataDate


	SELECT LevelNo,MeasureID,Measure,ROUND(ISNULL(CAST(MonthTgt AS FLOAT),0),2) MonthTgt,ROUND(ISNULL(CAST(MTD_Ach AS FLOAT),0),2) MTD_Ach,ROUND(ISNULL(CAST(CurrentDayRate AS FLOAT),0),2) CurrentDayRate,ROUND(ISNULL(CAST(RequiredDayRate AS FLOAT),0),2) RequiredDayRate FROM #Target_Ach
	SELECT LevelNo,FORMAT(DataDate,'dd-MMM') RptDate,MeasureID,Measure,ROUND(ISNULL(CAST(Target AS FLOAT),0),2) Target,ROUND(ISNULL(CAST(Achievement AS FLOAT),0),2) Achievement FROM #Target_AchDay ORDER BY DataDate
	

END
