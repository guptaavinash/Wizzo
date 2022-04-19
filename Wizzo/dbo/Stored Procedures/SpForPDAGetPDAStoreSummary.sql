-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- [SpForPDAGetPDAStoreSummary] '314D6CE8-0C6A-4635-9D75-04AC1A56F27A'
CREATE PROCEDURE [dbo].[SpForPDAGetPDAStoreSummary] 
	@PDACode VARCHAR(100),
	@CoverageAreaNodeID INT=0,
	@CoverageAreaNodeType SMALLINT=0
AS
BEGIN
Print 'Step1'
Print convert(varchar,Getdate(),109)
	--SELECT TOP 2 * FROM tblDailyUpdatedStoreTranData
	DECLARE @PersonNodeID Integer=0 
	DECLARE @PersonNodeType Integer=0
	SELECT @PersonNodeID=NodeID,@PersonNodeType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	CREATE TABLE #CoverageArea(CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT)

	IF @PersonNodeType IN (220,230)
	BEGIN
		INSERT INTO  #CoverageArea
		SELECT DISTINCT P.NodeID,P.NodeType  
		FROM tblSalesPersonMapping P     
		INNER JOIN [dbo].[tblSecMenuContextMenu] S ON S.NodeType=P. NodeType     
		WHERE P.PersonNodeID=@PersonNodeID AND P.PersonType=@PersonNodeType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) AND S.flgCoverageArea=1
	END
	ELSE IF @PersonNodeType=210
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
			WHERE P.PersonNodeID=@PersonNodeID AND P.PersonType=@PersonNodeType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		END
	END
	Print 'Step2'
Print convert(varchar,Getdate(),109)

	--CREATE TABLE #CoverageArea (CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT) 

	----INSERT INTO #CoverageArea(CoverageAreaNodeID,CoverageAreaNodeType)
	----SELECT DISTINCT NodeID,NodeType FROM tblSalespersonmapping WHERE PersonNOdeID=@PersonNodeID AND PersonType=@PersonNodeType AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate 

	----CREATE TABLE #Routes(NodeID INT,NodeType SMALLINT,FromDate Date,ToDate Date)
	----INSERT INTO #Routes(Nodeid,Nodetype,Fromdate,ToDate)
	----SELECT DISTINCT  RouteNodeId,RouteNodetype,GETDATE(),'31-Dec-2049' FROM tblRoutePlanningVisitDetail RP INNER JOIN #CoverageArea C ON C.CoverageAreaNodeID=RP.CovAreaNodeID AND C.CoverageAreaNodeType=RP.CovAreaNodeType

	CREATE TABLE #DSRStoreList (CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT,CoverageArea VARCHAR(500),PersonNodeID INT,PersonNodeType SMALLINT,PersonName VARCHAR(200), RouteNodeID INT,RouteNodeType SMALLINT,Route VARCHAR(500),flgDefaultRoute TINYINT,StoreID INT)

	INSERT INTO #DSRStoreList(CoverageAreaNodeID,CoverageAreaNodeType,PersonNodeID,PersonNodeType,RouteNodeID,RouteNodeType,Route,StoreID)
	   		
	SELECT DISTINCT C.CoverageAreaNodeID,C.CoverageAreaNodeType,@PersonNodeID,@PersonNodeType,RouteID,H.RouteNodetype,RM.Descr,RC.StoreId FROM tblRouteCoverageStoreMapping(nolock) RC INNER JOIN tblCompanySalesStructureRouteMstr(nolock) RM ON RM.NodeID=RC.RouteID AND RC.RouteNodeType=RM.NodeType
	INNER JOIN tblRoutePlanningVisitDetail H  ON H.RouteNodeId=RC.RouteID AND H.RouteNodetype=RC.RouteNodeType
	INNER JOIN #CoverageArea C ON C.CoverageAreaNodeID=H.CovAreaNodeID AND C.CoverageAreaNodeType=H.CovAreaNodeType
	WHERE  CAST(GETDATE() AS DATE) BETWEEN RC.FromDate AND RC.ToDate AND H.VisitDate>=CAST(GETDATE() AS DATE)
	Print 'Step3'
Print convert(varchar,Getdate(),109)
	--SELECT * FROM #DSRStoreList

	-- Target Output
	CREATE TABLE #Target(StoreID INT,[Visit Target] NUMERIC(6,2) DEFAULT 0,[Monthly Target] NUMERIC(6,2) DEFAULT 0,[Achieved] NUMERIC(6,2) DEFAULT 0,[Balance] NUMERIC(6,2) DEFAULT 0)

	INSERT INTO #Target
	SELECT DISTINCT D.StoreId,D.TotalVisits,D.MonthlyTarget,D.AchievedTarget,D.BalanceTarget FROM tblDailyUpdatedStoreLastCallData D INNER JOIN #DSRStoreList S ON S.StoreID=D.StoreId WHERE SourceId=3
	Print 'Step4'
Print convert(varchar,Getdate(),109)
	SELECT * FROM #Target

	--SELECT 0 AS [Visit Target],0 AS [Monthly Target], 0 AS [Achieved] ,0 [Balance]

	-- Store Visit History
	SELECT DISTINCT A.StoreID,A.VisitDate VisitDate,V.VisitID,P.Descr Personname INTO #VisitHistory
	FROM
	(SELECT S.StoreID,V.VisitDate , ROW_NUMBER() OVER(PARTITION BY V.StoreID,V.VisitDate ORDER BY V.VisitDate DESC) AS Rnk FROM tblVisitMaster(nolock) V INNER JOIN #DSRStoreList S ON S.StoreID=V.StoreId 
	) A INNER JOIN tblVisitMaster(nolock) V ON V.StoreId=A.StoreID AND V.VisitDate=A.VisitDate INNER JOIN tblmstrperson P ON P.NodeID=V.EntryPersonNodeID
	WHERE A.Rnk<=5
	Print 'Step5'
Print convert(varchar,Getdate(),109)
	--SELECT 'VisitHistory'
	--SELECT * FROM #VisitHistory

	-- FA Order History
	SELECT DISTINCT A.StoreID,P.InvId,P.PrdNodeId,Qty,NetValue,P.InvDate InvDate INTO #FAOrderHistory
	FROM
	(SELECT S.StoreID,P.InvDate , ROW_NUMBER() OVER(PARTITION BY P.StoreID,P.InvDate ORDER BY P.InvDate DESC) AS Rnk FROM tblP3MSalesDetail(nolock) P INNER JOIN #DSRStoreList S ON S.StoreID=P.StoreId WHERE P.flgOrderSource=1
	) A INNER JOIN tblP3MSalesDetail(nolock) P ON P.StoreId=A.StoreID AND P.InvDate=A.InvDate 
	WHERE A.Rnk<=5 AND P.flgOrderSource=1
	Print 'Step6'
Print convert(varchar,Getdate(),109)
	--SELECT 'FAOrderHistory'
	--SELECT * FROM #FAOrderHistory

	--- Visit from AstixSFA and FA
	SELECT StoreID,InvDate,1 AS VisitType,0 AS VisitID INTO #PastVisitDates FROM #FAOrderHistory(nolock)  
	UNION
	SELECT StoreID,VisitDate,3,VisitID FROM #VisitHistory
	Print 'Step7'
Print convert(varchar,Getdate(),109)
	--- Pick only top 5 dates from DSE and FA
	SELECT A.StoreID,P.InvDate InvDate,P.VisitType,VisitID INTO #Top5Visits
	FROM
	(SELECT S.StoreID,P.InvDate , ROW_NUMBER() OVER(PARTITION BY P.StoreID,P.InvDate ORDER BY P.InvDate DESC) AS Rnk FROM #PastVisitDates(nolock) P INNER JOIN #DSRStoreList S ON S.StoreID=P.StoreId 
	) A INNER JOIN #PastVisitDates(nolock) P ON P.StoreId=A.StoreID AND P.InvDate=A.InvDate 
	WHERE A.Rnk<=5
	Print 'Step8'
Print convert(varchar,Getdate(),109)
	--SELECT 'Top5Visits'
	--SELECT * FROM #Top5Visits


	--- Orders from last visits
	SELECT OM.StoreID,OM.OrderID,OD.OrderQty,H.VisitID,H.InvDate,OD.ProductID,ROUND(CAST(OD.OrderQty AS FLOAT)/prd.PcsInBox,1) OrderQtyInCase,OD.NetLineOrderVal,OM.NetOrderValue INTO #VisitOrderDetailHistory FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderID=OD.OrderID INNER JOIN #Top5Visits H ON H.VisitID=OM.VisitID INNER JOIN tblPrdMstrSKULvl prd ON prd.NodeID=OD.ProductID WHERE H.VisitType=3
	UNION
	SELECT F.StoreID,F.InvID,F.Qty,0,T.InvDate,F.PrdNodeId,ROUND(CAST(Qty AS FLOAT)/prd.PcsInBox,1),NetValue,X.NetOrderValue  FROM #FAOrderHistory F INNER JOIN (SELECT StoreID,InvDate ,SUM(NetValue) NetOrderValue FROM #FAOrderHistory GROUP BY StoreID,InvDate ) X ON X.StoreID=F.StoreID AND X.InvDate=F.InvDate 
	INNER JOIN #Top5Visits T ON T.StoreID=F.StoreID AND T.InvDate=F.InvDate AND T.VisitType=1 INNER JOIN tblPrdMstrSKULvl prd ON prd.NodeID=F.PrdNodeId 
	Print 'Step9'
Print convert(varchar,Getdate(),109)
	----SELECT OM.StoreID,OM.OrderID,H.VisitID,H.InvDate,OD.ProductID,ROUND(CAST(OD.OrderQty AS FLOAT)/prd.PcsInBox,1) OrderQty,OD.NetLineOrderVal,OM.NetOrderValue  FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderID=OD.OrderID INNER JOIN #Top5Visits H ON H.VisitID=OM.VisitID INNER JOIN tblPrdMstrSKULvl prd ON prd.NodeID=OD.ProductID WHERE H.VisitType=3

	----SELECT F.StoreID,F.InvID,0,T.InvDate,F.PrdNodeId,ROUND(CAST(Qty AS FLOAT)/prd.PcsInBox,1),NetValue,X.NetOrderValue  FROM #FAOrderHistory F INNER JOIN (SELECT StoreID,InvDate ,SUM(NetValue) NetOrderValue FROM #FAOrderHistory GROUP BY StoreID,InvDate ) X ON X.StoreID=F.StoreID AND X.InvDate=F.InvDate 
	----INNER JOIN #Top5Visits T ON T.StoreID=F.StoreID AND T.InvDate=F.InvDate AND T.VisitType=1 INNER JOIN tblPrdMstrSKULvl prd ON prd.NodeID=F.PrdNodeId 


	--SELECT 'VisitOrderDetailHistory'
	--SELECT * FROM #VisitOrderDetailHistory
	
	SELECT StoreID,OrderID,VisitID,InvDate , ROUND(SUM(V.OrderQty /prd.PcsInBox),1) TotalQty , NetOrderValue INTO #VisitOrderHistory FROM #VisitOrderDetailHistory  V INNER JOIN tblPrdMstrSKULvl prd ON prd.NodeID=V.ProductID GROUP BY StoreID,OrderID,VisitID,InvDate,NetOrderValue
	Print 'Step10'
Print convert(varchar,Getdate(),109)
	--SELECT 'VisitOrderHistory'
	--SELECT * FROM #VisitOrderHistory

	CREATE TABLE #StoreVisitHistory(StoreID INT,VisitID INT,[Contacted By] VARCHAR(100),[LastCall/Visit] Date,[OrderQty(Cases)] FLOAT,OrderValue INT,OrderStatus VARCHAR(100),OrderID INT) 


	INSERT INTO #StoreVisitHistory([Contacted By],StoreID,VisitID,[LastCall/Visit])
	SELECT DISTINCT '',H.StoreID,H.VisitID,H.InvDate FROM #VisitOrderHistory H 

	--SELECT 'StoreVisitHistory'
	--SELECT * FROM #StoreVisitHistory
	PRINT 'CCCCC'
	UPDATE H SET [OrderQty(Cases)]=V.TotalQty,OrderValue=V.NetOrderValue FROM #StoreVisitHistory H INNER JOIN #VisitOrderHistory V ON V.StoreID=H.StoreID AND V.InvDate=H.[LastCall/Visit]
	Print 'Step11'
Print convert(varchar,Getdate(),109)
	----UPDATE V SET [OrderQty(Cases)]=0,[LastCall/Visit]=D.LastVisitDate,OrderValue=D.LastOrderValue,OrderStatus='Order Taken' FROM #StoreVisitHistory V INNER JOIN tblDailyUpdatedStoreTranData D ON D.StoreId=V.StoreID INNER JOIN #DSRStoreList S ON S.storeID=D.StoreId  WHERE D.SourceId=1

	----UPDATE V SET [LastCall/Visit]=D.LastVisitDate,OrderValue=D.LastOrderValue,OrderStatus='Completed' FROM #StoreVisitHistory V 
	----INNER JOIN tblDailyUpdatedStoreTranData D ON D.StoreId=V.StoreID INNER JOIN #DSRStoreList S ON S.storeID=D.StoreId  WHERE D.SourceId=2

	----UPDATE V SET [LastCall/Visit]=D.LastVisitDate,OrderValue=D.LastOrderValue,OrderStatus='Completed' FROM #StoreVisitHistory V INNER JOIN tblDailyUpdatedStoreTranData D ON D.StoreId=V.StoreID INNER JOIN #DSRStoreList S ON S.storeID=D.StoreId  WHERE D.SourceId=1

	PRINT 'AAAA'

	-- TC Order For Visit
	

	;WITH CTE AS 
	(
		SELECT T.StoreID,TeleCallingId,ROW_Number() OVER(PARTITION BY T.StoreID Order BY TeleCallingId DESC) rn FROM [tblTeleCallerListForDay] T(nolock) INNER JOIN #DSRStoreList S ON S.StoreID=T.StoreId WHERE T.flgCallConversionStatus=1
	)
	SELECT * INTO #TelecallingStores FROM CTE WHERE rn<=5

	SELECT O.StoreID,O.OrderID,D.PrdNodeId,D.PrdNodeType,ROUND(CAST(D.OrderQty AS FLOAT)/prd.PcsInBox,1) OrderQty,D.NetLineOrderVal,O.NetOrderValue,O.OrderDate INTO #LastTCOrder FROM tblTCOrderMaster O INNER JOIN tblTCOrderDetail D ON D.OrderID=O.OrderID INNER JOIN tblPrdMstrSKULvl prd ON prd.NodeID=D.PrdNodeId INNER JOIN
	(SELECT  T.StoreID,TeleCallingId FROM #TelecallingStores T) X
	ON X.StoreId=O.StoreID AND O.TeleCallingId=X.TeleCallingId
	Print 'Step12'
Print convert(varchar,Getdate(),109)
	CREATE TABLE #TCOrderHistory(StoreID INT,[Contacted By] VARCHAR(100),[LastCall/Visit] Date,[OrderQty(Cases)] NUMERIC(5,1),OrderValue INT,OrderStatus VARCHAR(100))

	INSERT INTO #TCOrderHistory([Contacted By],StoreID,OrderStatus,[OrderQty(Cases)],[LastCall/Visit],OrderValue)
	SELECT 'Telecaller',L.StoreID,'Booked',SUM(OrderQty),L.OrderDate,L.NetOrderValue FROM #LastTCOrder L GROUP BY L.StoreID,L.OrderDate,L.NetOrderValue

	--UPDATE V SET [OrderQty(Cases)]=0,[LastCall/Visit]=D.OrderDate,OrderValue=D.NetOrderValue,OrderStatus='Order Taken' FROM #StoreVisitHistory V 
	--INNER JOIN tblTCOrderMaster D ON D.StoreId=V.StoreID INNER JOIN #DSRStoreList S ON S.storeID=D.StoreId  WHERE [Contacted By]='Telecaller'

	
	Print 'Step14'
Print convert(varchar,Getdate(),109)
	SELECT DISTINCT StoreID,[Contacted By],FORMAT([LastCall/Visit],'dd-MMM-yyyy')[LastCall/Visit],ROUND([OrderQty(Cases)],2) [OrderQty(Cases)],OrderValue,OrderStatus FROM #StoreVisitHistory Order By StoreID

	SELECT DISTINCT StoreID,[Contacted By],FORMAT([LastCall/Visit],'dd-MMM-yyyy')[LastCall/Visit],[OrderQty(Cases)],OrderValue,OrderStatus FROM #TCOrderHistory Order By StoreID

	SELECT StoreID,OrderID,VisitID,FORMAT(InvDate,'dd-MMM-yyyy')InvDate,ProductID,OrderQty,NetLineOrderVal,NetOrderValue FROM #VisitOrderDetailHistory
	Print 'Step15'
Print convert(varchar,Getdate(),109)
	
	SELECT StoreID,OrderID,FORMAT(OrderDate,'dd-MMM-yyyy') InvDate,PrdNodeId ProductID,OrderQty [OrderQty(Cases)],NetLineOrderVal,NetOrderValue FROM #LastTCOrder

	Print 'Step16'
Print convert(varchar,Getdate(),109)

	--UPDATE #StoreVisitHistory SET [LastCall/Date]= FROM  tblTCOrderMaster T INNER JOIN vwTeleCallerListForDay  ON T.TeleCallingId=
END
