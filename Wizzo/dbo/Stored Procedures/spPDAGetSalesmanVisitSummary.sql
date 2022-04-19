

--[spPDAGetSalesmanVisitSummary]'8A3964B9-3FA0-4C49-B93F-C9A328D41FD4'
CREATE PROC [dbo].[spPDAGetSalesmanVisitSummary]
@IMEINO VARCHAR(100)

AS
	 DECLARE @PDAID INT  
	 DECLARE @PDAPersonID INT  
	 DECLARE @PDAPersonType INT  
	 DECLARE @ReportDate DATE=GETDATE()

	 CREATE TABLE #SalesmanList(SalesmanNodeId INT,SalesmanNodeType INT)

	 IF @IMEINo<>''
	 BEGIN
		SELECT @PDAPersonID=NodeID,@PDAPersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@IMEINO) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	 END

	 SELECT * INTO #SalesHier FROm VwSalesHierarchyFull
	 --SELECT * INTO #DBRHier FROm VwAllDistributorHierarchy

	 --To get salesman list working under
	 ----IF @PDAPersonType=220 --SO
	 ----BEGIN
		------Company SalesMan
		----INSERT INTO #SalesmanList(SalesmanNodeId,SalesmanNodeType)
		----SELECT DISTINCT SP.PersonNodeID,SP.PersonType
		----FROM tblSalesPersonMapping PDA_SP INNER JOIN #SalesHier ON PDA_SP.NodeId=#SalesHier.SOAreaNodeId AND PDA_SP.NodeType=#SalesHier.SOAreaNodeType
		------INNER JOIN tblSalesPersonMapping SP ON SP.NodeId=#SalesHier.RouteId AND SP.NodeType=#SalesHier.RouteType
		----WHERE PDA_SP.PersonNodeID=@PDAPersonID AND PDA_SP.PersonType=@PDAPersonType AND (@ReportDate BETWEEN PDA_SP.FromDate AND PDA_SP.ToDate) AND (@ReportDate BETWEEN SP.FromDate AND SP.ToDate)

		----------DBR SalesMan
		--------INSERT INTO #SalesmanList(SalesmanNodeId,SalesmanNodeType)
		--------SELECT DISTINCT SP.PersonNodeID,SP.PersonType
		--------FROM tblSalesPersonMapping PDA_SP INNER JOIN #SalesHier ON PDA_SP.NodeId=#SalesHier.SOId AND PDA_SP.NodeType=#SalesHier.SOAreaType
		--------INNER JOIN tblCompanySalesStructure_DistributorMapping Map ON #SalesHier.SOId=Map.SHNodeID AND #SalesHier.SOAreaType=Map.SHNodeType
		--------INNER JOIN #DBRHier ON Map.DHNodeID=#DBRHier.DBRCoverageID AND Map.DHNodeType=#DBRHier.DBRCoverageNodeType
		--------INNER JOIN tblSalesPersonMapping SP ON SP.NodeId=#DBRHier.DBRRouteID AND SP.NodeType=#DBRHier.RouteNodeType
		--------WHERE PDA_SP.PersonNodeID=@PDAPersonID AND PDA_SP.PersonType=@PDAPersonType AND (@ReportDate BETWEEN PDA_SP.FromDate AND PDA_SP.ToDate) AND (@ReportDate BETWEEN SP.FromDate AND SP.ToDate) AND (@ReportDate BETWEEN Map.FromDate AND Map.ToDate)
	 ----END
	 IF @PDAPersonType=210 --ASM
	 BEGIN
		--Company SalesMan
		INSERT INTO #SalesmanList(SalesmanNodeId,SalesmanNodeType)
		SELECT DISTINCT SP.PersonNodeID,SP.PersonType
		FROM tblSalesPersonMapping PDA_SP INNER JOIN #SalesHier S ON PDA_SP.NodeId=S.ASMAreaNodeId AND PDA_SP.NodeType=S.ASMAreaNodeType
		INNER JOIN tblSalesPersonMapping SP ON SP.NodeID=S.ComCoverageAreaID AND SP.NodeType=S.ComCoverageAreaType
		WHERE PDA_SP.PersonNodeID=@PDAPersonID AND PDA_SP.PersonType=@PDAPersonType AND (@ReportDate BETWEEN PDA_SP.FromDate AND PDA_SP.ToDate) AND (@ReportDate BETWEEN SP.FromDate AND SP.ToDate)

		------DBR SalesMan
		----SELECT DISTINCT Map.DHNodeId,Map.DHNodeType INTO #DBRCoverageAreas
		----FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN #SalesHier CS ON Map.SHNodeId=CS.SOID AND Map.SHNodeType=CS.SOAreaType
		----INNER JOIN tblSalesPersonMapping SP ON 	CS.ASMAreaId=SP.NodeId AND CS.ASMAreaType=SP.NodeType
		----WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate) AND SP.PersonNodeID=@PDAPersonID AND SP.PersonType=@PDAPersonType AND (@ReportDate BETWEEN SP.FromDate AND SP.ToDate)
		----UNION ALL
		----SELECT DISTINCT Map.DHNodeId,Map.DHNodeType
		----FROM tblCompanySalesStructure_DistributorMapping Map INNER JOIN VwSalesHierarchy CS ON Map.SHNodeId=CS.ASMAreaID AND Map.SHNodeType=CS.ASMAreaType	
		----INNER JOIN tblSalesPersonMapping SP ON 	CS.ASMAreaId=SP.NodeId AND CS.ASMAreaType=SP.NodeType	
		----WHERE Map.SHNodeId<>0 AND DHNodeType=160 AND (GETDATE() BETWEEN Map.Fromdate AND Map.ToDate) AND SP.PersonNodeID=@PDAPersonID AND SP.PersonType=@PDAPersonType AND (@ReportDate BETWEEN SP.FromDate AND SP.ToDate)

		----INSERT INTO #SalesmanList(SalesmanNodeId,SalesmanNodeType)
		----SELECT DISTINCT SP.PersonNodeID,SP.PersonType
		----FROM #DBRCoverageAreas INNER JOIN #DBRHier ON #DBRCoverageAreas.DHNodeID=#DBRHier.DBRCoverageID AND #DBRCoverageAreas.DHNodeType=#DBRHier.DBRCoverageNodeType
		----INNER JOIN tblSalesPersonMapping SP ON SP.NodeId=#DBRHier.DBRRouteID AND SP.NodeType=#DBRHier.RouteNodeType
		----WHERE (@ReportDate BETWEEN SP.FromDate AND SP.ToDate)
	 END
	 --SELECT * FROM #SalesmanList

	 CREATE TABLE #RouteList(SalesmanNodeId INT,SalesmanNodeType INT,RouteId INT,RouteNodeType INT,Active TINYINT)

	 INSERT INTO #RouteList(SalesmanNodeId,SalesmanNodeType,RouteId,RouteNodeType)
	 SELECT DISTINCT SP.PersonNodeID,SP.PersonType,SP.NodeId,SP.NodeType
	 FROM tblSalesPersonMapping SP INNER JOIN tblRoutePlanningVisitDetail RV ON RV.CovAreaNodeID=SP.NodeID AND RV.CovAreaNodeType=SP.NodeType
	 INNER JOIN #SalesmanList S ON S.SalesmanNodeId=SP.PersonNodeID AND S.SalesmanNodeType=SP.PersonType
	 WHERE  (@ReportDate BETWEEN SP.FromDate AND SP.ToDate) AND RV.VisitDate>=CAST(GETDATE() AS DATE)
	
	--SELECT * FROM #RouteList ORDER BY SalesmanNodeId,RouteNodeType,RouteId

	--Target Calls
	SET DATEFirst 1  
	----SELECT DISTINCT #RouteList.SalesmanNodeId,#RouteList.SalesmanNodeType,RC.RouteId,RC.NodeType AS RouteNodeType,@ReportDate AS RptDate,dbo.[fnGetPlannedVisit](RC.RouteId,RC.NodeType,@ReportDate) AS FlgPlanned INTO #RouteList
	----FROM tblRouteCoverage RC INNER JOIN #RouteList ON RC.RouteId=#RouteList.RouteId AND RC.NodeType=#RouteList.RouteNodeType
	----WHERE (@ReportDate BETWEEN RC.FromDate AND RC.ToDate) AND (DATEPART(dw,@ReportDate)=Weekday)

	UPDATE A SET Active=1 FROM #RouteList A INNER JOIN tblRoutePlanningVisitDetail R ON R.RouteNodeID=A.RouteId AND R.RouteNodetype=A.RouteNodeType AND CAST(VisitDate AS DATE)=CAST(GETDATE() AS DATE)


	--SELECT * FROM #RouteList ORDER BY FlgPlanned

	SET DATEFirst 7
	DELETE FROM #RouteList WHERE Active=0
	--SELECT * FROM #RouteList ORDER BY RouteNodeType,RouteId
	
	SELECT DISTINCT AA.StoreID AS StoreID, #RouteList.RouteID, #RouteList.RouteNodeType, 1 AS OnRoute,SalesmanNodeId,SalesmanNodeType INTO [#Target]
	FROM    #RouteList
	LEFT JOIN (SELECT RouteID,RouteNodeType,StoreID FROM tblRouteCoverageStoreMapping WHERE (CONVERT(VARCHAR,tblRouteCoverageStoreMapping.FromDate, 112) <= CONVERT(VARCHAR, @ReportDate, 112)) AND (CONVERT(VARCHAR, ISNULL(tblRouteCoverageStoreMapping.ToDate, @ReportDate), 112) >= CONVERT(VARCHAR, @ReportDate, 112))) AA ON #RouteList.RouteID=AA.RouteID AND #RouteList.RouteNodeType=AA.RouteNodeType 
	--SELECT * FROM [#Target] ORDER BY RouteNodeType,RouteId


	--Actual Calls
	SELECT S.SalesmanNodeId,S.SalesmanNodeType,V.VisitId,V.RouteID,V.RouteType AS RouteNodeType,V.StoreID,V.BatteryLeftStatus,V.DeviceVisitStartTS, V.DeviceVisitEndTS 
	INTO [#VIsitedStores]
	FROM tblVisitMaster V --INNER JOIN #RouteList R ON V.RouteID=R.RouteId AND V.RouteType=R.RouteNodeType
	INNER JOIN #SalesmanList S ON S.SalesmanNodeId=V.SalesPersonID AND S.SalesmanNodeType=V.SalesPersonType
	WHERE (CONVERT(VARCHAR, V.VisitDate, 112) = CONVERT(VARCHAR, @ReportDate, 112))  AND ISNULL(V.SourceId,0)<>1 AND ISNULL(V.flgTelePhonicCall,0)<>1
	ORDER BY V.StoreID
	--SELECT * FROM [#VIsitedStores]
	
	Select SalesmanNodeId,SalesmanNodeType, 0 AS MIN_Battery, 0 AS MAX_Battery, MIN(DeviceVisitStartTS) AS Start_Time, MAX(DeviceVisitEndTS) AS End_Time,CAST('' AS VARCHAR(20)) AS WorkingHours INTO #BatteryStatus
	FROM [#VIsitedStores]
	GROUP BY SalesmanNodeId,SalesmanNodeType
	
	UPDATE #BatteryStatus SET WorkingHours=CAST(DATEDIFF(MINUTE,Start_Time,End_Time)/60 AS VARCHAR) + ':' + CAST(CAST(DATEDIFF(MINUTE,Start_Time,End_Time)%60 AS INT) AS VARCHAR)

	UPDATE #BatteryStatus SET MIN_Battery = BatteryLeftStatus FROM #BatteryStatus INNER JOIN [#VIsitedStores] ON [#VIsitedStores].DeviceVisitStartTS = Start_Time

	UPDATE #BatteryStatus SET MAX_Battery = BatteryLeftStatus FROM #BatteryStatus INNER JOIN [#VIsitedStores] ON [#VIsitedStores].DeviceVisitEndTS = End_Time
	--SELECT * FROM #BatteryStatus

	SELECT OM.SalesPersonID SalesmanNodeId,OM.SalesPersonType SalesmanNodeType,OM.VisitId,OM.StoreId,OM.RouteNodeID RouteID,OM.RouteNodeType INTO #Orders
	FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderID = OD.OrderID 
	INNER JOIN #SalesmanList S ON S.SalesmanNodeId=OM.SalesPersonID AND S.SalesmanNodeType=OM.SalesPersonType
	WHERE (CONVERT(VARCHAR, OM.OrderDate, 112) = CONVERT(VARCHAR, @ReportDate, 112)) AND (OD.OrderQty > 0 OR OD.FreeQty > 0)
	--SELECT * FROM #Orders

	CREATE TABLE #Final(SalesmanNodeId INT,SalesmanNodeType INT,Salesman VARCHAR(200), [Start Time] VARCHAR(20) DEFAULT '', [End Time] VARCHAR(20) DEFAULT '',[Working Hours] VARCHAR(20) DEFAULT '',[Calls^Target] INT DEFAULT 0, [Calls^Actual] INT DEFAULT 0, [Calls^Productive] INT DEFAULT 0)

	INSERT INTO #Final(SalesmanNodeId,SalesmanNodeType)
	Select DISTINCT SalesmanNodeId,SalesmanNodeType FROM [#VIsitedStores]
	UNION
	Select DISTINCT SalesmanNodeId,SalesmanNodeType FROM #Target
	--SELECT * FROM #Final

	UPDATE #Final SET [Calls^Target] = AA.TargetCalls
	FROM #Final  INNER JOIN (Select SalesmanNodeId,SalesmanNodeType, COUNT(DISTINCT StoreID) AS TargetCalls FROM #Target GROUP BY SalesmanNodeId,SalesmanNodeType) AS AA ON #Final.SalesmanNodeId = AA.SalesmanNodeId AND #Final.SalesmanNodeType = AA.SalesmanNodeType
	
	UPDATE #Final SET [Calls^Actual] = AA.Actual FROM #Final INNER JOIN (Select SalesmanNodeId,SalesmanNodeType, COUNT(DISTINCT StoreID) AS Actual FROM [#VIsitedStores] GROUP BY SalesmanNodeId,SalesmanNodeType) AS AA ON #Final.SalesmanNodeId = AA.SalesmanNodeId AND #Final.SalesmanNodeType = AA.SalesmanNodeType
	
	UPDATE #Final SET [Calls^Productive] = AA.Prod FROM #Final  INNER JOIN (SELECT SalesmanNodeId,SalesmanNodeType, COUNT(DISTINCT StoreID) AS Prod FROM #Orders GROUP BY SalesmanNodeId,SalesmanNodeType) AS AA ON #Final.SalesmanNodeId = AA.SalesmanNodeId AND #Final.SalesmanNodeType = AA.SalesmanNodeType
	

	UPDATE #Final SET [Start Time] = CASE WHEN DATEPART(hh,Start_Time)<10 THEN '0'+ CAST(DATEPART(hh,Start_Time) AS VARCHAR)  ELSE CAST(DATEPART(hh,Start_Time) AS VARCHAR) End+':'+ CASE WHEN DATEPART(mi,Start_Time)<10 THEN '0'+ CAST(DATEPART(mi,Start_Time) AS VARCHAR) ELSE CAST(DATEPART(mi,Start_Time) AS VARCHAR) End+' Bt@'+CAST(MIN_Battery AS VARCHAR),[End Time] = CASE WHEN DATEPART(hh,end_Time)<10 THEN '0'+ CAST(DATEPART(hh,end_Time) AS VARCHAR) ELSE CAST(DATEPART(hh,end_Time) AS VARCHAR) End+':'+
CASE WHEN DATEPART(mi,end_Time)<10 THEN '0'+ CAST(DATEPART(mi,end_Time) AS VARCHAR) ELSE CAST(DATEPART(mi,end_Time) AS VARCHAR) End+' Bt@'+CAST(MAX_Battery AS VARCHAR),[Working Hours]=#BatteryStatus.WorkingHours
	FROM #Final INNER JOIN #BatteryStatus ON #BatteryStatus.SalesmanNodeId = #Final.SalesmanNodeId AND #Final.SalesmanNodeType = #BatteryStatus.SalesmanNodeType
	

	UPDATE #Final SET #Final.Salesman=MP.Descr FROM #Final INNER JOIN tblMstrPerson MP ON #Final.SalesmanNodeId=Mp.NodeId AND #Final.SalesmanNodeType=Mp.NodeType

	--SELECT * FROM #Final

	SELECT Salesman [Salesman^],[Start Time] [Start Time^],[End Time] [End Time^],[Working Hours] [Working Hours^],[Calls^Target],[Calls^Actual], [Calls^Productive]
	FROM #Final
	ORDER BY Salesman












