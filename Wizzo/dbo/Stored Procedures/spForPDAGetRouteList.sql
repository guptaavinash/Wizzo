

-- EXEC spForPDAGetRouteList '957F67F9-763B-449D-943C-0DEE279DFB9C','17-Nov-2021',1
CREATE PROCEDURE [dbo].[spForPDAGetRouteList]  
@PDACode VARCHAR(50),  
@strDate VARCHAR(20), 
@AppVersionID INT,
@CoverageAreaNodeID INT=0,
@CoverageAreaNodeType SMALLINT=0
--@flgToShowValueTarget TINYINT=0 -- 1: to show value target for the day,0: to not show value target for the day


AS  
	DECLARE @Date DATETIME 
	DECLARE @DefaultRouteID INT  
	DECLARE @WeekNumber INT
	DECLARE @DayofWeek INT  
	DECLARE @DeviceID INT
	--DECLARE @AppVersionID INT
	DECLARE @WorkingAreaNodeID INT 
	DECLARE @WorkingAreaNodeType TINYINT
	DECLARE @HierTypeID INT
	DECLARE @PersonID INT   
	DECLARE @PersonType INT 
	DECLARE @TargetMTD FLOAT=0
	DECLARE @AcheivedMTD FLOAT=0
	DECLARE @TargetDay FLOAT=0  
	DECLARE @WorkingDaysRemaining INT          
	DECLARE @strValueTarget VARCHAR(5000)=''
	DECLARE @FirstDate DATETIME        
    DECLARE @LastDate DATETIME 

	SELECT @Date = REPLACE(CONVERT(VARCHAR, CONVERT(DATETIME,@strDate,105), 106),' ','-')   
	
	SET DATEFirst 1  

	SELECT @WeekNumber=DATEPART(WEEK, CONVERT(DATETIME,@date,105))  -  DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,CONVERT(DATETIME,@date,105)), 0))+ 1
	PRINT '@WeekNumber=' + CAST(ISNULL(@WeekNumber,0) AS VARCHAR)

	SELECT @DayofWeek = datepart(dw,@Date)   
	PRINT '@DayofWeek=' + CAST(ISNULL(@DayofWeek,0) AS VARCHAR)

	SET DATEFirst 7  
	
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMENumber OR PDA_IMEI_Sec=@IMENumber
	PRINT '@DeviceID=' + CAST(ISNULL(@DeviceID,0) AS VARCHAR)

	--SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@DeviceID  AND (GETDATE() BETWEEN DateFrom AND DateTo)

	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	PRINT 'PersonID=' + CAST(@PersonID AS VARCHAR)          
	PRINT 'PersonType=' + CAST(@PersonType AS VARCHAR)

	--Select @AppVersionID = VersionID FROM tblVersionMstr WHERE VersionSerialNo= @AppVersionNo

	--select * from tblPDAMaster
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


	----SELECT P.NodeID,P.NodeType INTO #CoverageArea FROM tblSalesPersonMapping P 
	----INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
	
	----WHERE ISNULL(C.flgCoverageArea,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))

	--- Get the workingType for the salesman
	DECLARE @WorkingType TINYINT
	SELECT  @WorkingType=dbo.fnGetWorkingTypeForCoverageArea(NodeID,Nodetype) FROM #CoverageArea
	PRINT '@WorkingType=' + CAST(@WorkingType AS VARCHAR)


	-- Get the Default Route Assigned
	CREATE TABLE #TodaysCoverageArea(SalesAreaNodeID INT,SalesAreaNodeType SMALLINT)

	IF @WorkingType=1 -- Directsales
	BEGIN
		INSERT INTO #TodaysCoverageArea
		SELECT DISTINCT SalesAreaNodeID,SalesAreaNodeType FROM tblVanStockMaster V,(SELECT SalesManNodeId,MAX(TransDate) TransDate FROM tblVanStockMaster WHERE SalesManNodeId=@PersonID AND SalesManNodeType=@PersonType AND CAST(TransDate AS DATE)<=CAST(GETDATE() AS DATE) GROUP BY SalesManNodeId) X WHERE X.TransDate=V.TransDate AND X.SalesManNodeId=V.SalesManNodeId
	END
	

	CREATE TABLE #Routes(NodeID INT,NodeType SMALLINT,FromDate Date,ToDate Date)
	
	--SELECT * FROM #TodaysCoverageArea
	IF EXISTS(SELECT 1 FROM #TodaysCoverageArea)
	BEGIN
		SELECT 1
		----INSERT INTO #Routes(Nodeid,Nodetype,Fromdate,ToDate)
		----SELECT V.DSRRouteNodeID,V.DSRRouteNodeType,DATEADD(d,-1,GETDATE()),'31-dec-2049' FROM #TodaysCoverageArea A INNER JOIN VwCompanyDSRFullDetail V ON V.DSRAreaID=A.SalesAreaNodeID AND V.DSRAreaNodeType=A.SalesAreaNodeType 
		----UNION
		----SELECT V.DBRRouteID,V.RouteNodeType,DATEADD(d,-1,GETDATE()),'31-dec-2049' FROM #TodaysCoverageArea A INNER JOIN [VwDistributorDSRFullDetail] V ON V.DBRCoverageID=A.SalesAreaNodeID AND V.DBRCoverageNodeType=A.SalesAreaNodeType

	END
	ELSE
	BEGIN
		PRINT 'AA Gaya'
		----INSERT INTO #Routes(Nodeid,Nodetype,Fromdate,ToDate)
		----SELECT distinct CH.NodeID,CH.NodeType,MIN(CH.VldFrom) AS FromDate, MAX(CH.VldTo) AS ToDate 
		----FROM tblSalesPersonMapping P
		----INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
		----AND CAST(GETDATE() AS DATE) BETWEEN H.VldFrom AND H.VldTo
		----INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
		----AND CAST(GETDATE() AS DATE) BETWEEN CH.VldFrom AND CH.VldTo
		----INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
		----WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		----GROUP BY CH.NodeID,CH.NodeType
		INSERT INTO #Routes(Nodeid,Nodetype,Fromdate,ToDate)
		SELECT DISTINCT  RouteNodeId,RouteNodetype,GETDATE(),'31-Dec-2049' FROM tblRoutePlanningMstr RP
		INNER JOIN #CoverageArea C ON C.NodeID=RP.CovAreaNodeID AND C.NodeType=RP.CovAreaNodeType WHERE RP.ToDate>GETDATE()

	END

	--INSERT INTO #Routes(Nodeid,Nodetype)
	--SELECT DISTINCT RouteNodeId,RouteNodeType FROM tblRouteCalendar WHERE SONodeId=@PersonID AND SONodeType=@PersonType 

	
	--SELECT * FROM #Routes

	SELECT @HierTypeID=HierTypeID FROM [dbo].[tblSecMenuContextMenu] WHERE NodeType IN (SELECT TOP 1 NodeType FROM #Routes)
	PRINT '@HierTypeID=' + CAST(ISNULL(@HierTypeID,0) AS VARCHAR)
	
	--select * from tblVersionMstr
	--PRINT '@AppVersionID=' + CAST(@AppVersionID AS VARCHAR)

	INSERT INTO tblAppVersionLog(PDACode, AppVersionID, Date)
	SELECT @PDACode, @AppVersionID, GETDATE()

	DECLARE @AppType TINYINT
	SELECT @AppType=ApplicationType FROM tblVersionMstr WHERE VersionID=@AppVersionID
	
	PRINT '@DeviceID=' + CAST(@DeviceID AS VARCHAR)

	CREATE TABLE #AllRoutes(DSRRouteID INT,DSRRouteNodeType TINYINT,DSRRoute VARCHAR(200),Active TINYINT)
	
	CREATE TABLE #AllRoutesONly(DSRRouteID INT,DSRRouteNodeType TINYINT,DSRRoute VARCHAR(200),Active TINYINT,flgApproved TINYINT Default 0,DBNodeID INT)

	CREATE TABLE #DBRList(DBRNodeID INT,DistributorNodeType INT,Distributor VARCHAR(200),[LatCode] NUMERIC(18,16),[LongCode] NUMERIC(18,6),flgDefault TINYINT DEFAULT 0,flgMapped TINYINT)

	DECLARE @RouteType TINYINT
	SELECT @RouteType=NodeType FROM tblSecMenuContextMenu WHERE HierTypeID=@HierTypeID AND flgRoute=1
	PRINT '@RouteType=' + CAST(@RouteType AS VARCHAR)
	
	INSERT INTO #AllRoutes(DSRRouteID,DSRRouteNodeType,DSRRoute)
	SELECT DISTINCT A.NodeId ,A.NodeType,ISNULL(A.Code,'') + '-' + A.Descr 
	FROM [dbo].[tblCompanySalesStructureRouteMstr] A 
	INNER JOIN #Routes C on C.NodeId=A.NodeId AND C.NodeType=A.NodeType
	
	--SELECT * FROM #AllRoutes WHERE DSRRouteID=48164
	--SELECT * FROM #CoverageArea
	--SELECT A.DSRRouteID,A.DSRRouteNodeType FROM #AllRoutes A INNER JOIN tblRoutePlanningVisitDetail R ON R.RouteNodeID=A.DSRRouteID AND R.RouteNodetype=A.DSRRouteNodeType AND CAST(VisitDate AS DATE)=CAST(@strDate AS DATE) INNER JOIN #CoverageArea C ON C.NodeID=R.CovAreaNodeID AND C.NodeType=R.CovAreaNodeType 

	UPDATE A SET Active=1 FROM #AllRoutes A INNER JOIN tblRoutePlanningVisitDetail R ON R.RouteNodeID=A.DSRRouteID AND R.RouteNodetype=A.DSRRouteNodeType AND CAST(VisitDate AS DATE)=CAST(@strDate AS DATE) INNER JOIN #CoverageArea C ON C.NodeID=R.CovAreaNodeID AND C.NodeType=R.CovAreaNodeType
	
	
	

	--IF NOT EXISTS(SELECT 1 FROM #AllRoutes WHERE Active=1)
	--	UPDATE A SET Active=1 FROM #AllRoutes A where DSRRouteID in(select min(DSRRouteID) from #AllRoutes)

	INSERT INTO #AllRoutesONly(DSRRouteID,DSRRouteNodeType ,DSRRoute,Active)
	SELECT DISTINCT #AllRoutes.DSRRouteID AS ID,#AllRoutes.DSRRouteNodeType AS RouteType, DSRRoute AS Descr,Active FROM #AllRoutes order by 1

	
	--UPDATE O SET O.Active=ISNULL(A.Active,0) FROM #AllRoutesONly O INNER JOIN (SELECT DSRRouteID,DSRRouteNodeType,MAX(ISNULl(Active,0)) Active FROM #AllRoutes GROUP BY DSRRouteID,DSRRouteNodeType) A ON A.DSRRouteID=O.DSRRouteID AND A.DSRRouteNodeType=O.DSRRouteNodeType



	----INSERT INTO #AllRoutesONly(DSRRouteID,DSRRouteNodeType ,DSRRoute)
	----SELECT DISTINCT R.NodeID,R.NodeType,RM.Descr + '-' + CAST(RM.NodeID AS VARCHAR)  FROM #Routes R INNER JOIN tblCompanySalesStructureRouteMstr RM ON R.NodeID=RM.NodeID AND R.NodeType=RM.NodeType

	--SELECT * FROM #AllRoutesONly

	----UPDATE O SET O.Active=ISNULL(A.Active,0) FROM #AllRoutesONly O INNER JOIN (SELECT RouteNodeId,RouteNodeType,1 AS Active FROM tblRouteCalendar WHERE VisitDate=@strDate GROUP BY RouteNodeId,RouteNodeType) A ON A.RouteNodeId=O.DSRRouteID AND A.RouteNodeType=O.DSRRouteNodeType

	UPDATE O SET O.flgApproved=1 FROM #AllRoutesONly O INNER JOIN tblPDARouteChangeApprovalDetail A ON A.RequestRouteNodeID=O.DSRRouteID AND A.RequestRouteNodeType=O.DSRRouteNodeType AND CAST(RequestDatetime AS DATE)=CAST(GETDATE() AS DATE) AND RequestPersonNodeID=@PersonID AND RequestPersonNodeType=@PersonType WHERE A.flgApprovedOrReject=1

	--UPDATE O SET O.Active=ISNULL(A.Active,0) FROM #AllRoutesONly O INNER JOIN #AllRoutes A ON A.DSRRouteID=O.DSRRouteID AND A.DSRRouteNodeType=O.DSRRouteNodeType

	--- Commented due to multiplt active route coming 
	---SELECT DISTINCT #AllRoutes.DSRRouteID AS ID,#AllRoutes.DSRRouteNodeType AS RouteType, DSRRoute AS Descr, ISNULL(Active,0) AS Active FROM #AllRoutes order by 1

	SELECT RouteID,RouteNodeType, DBID DistNodeId,DBNOdeType DistNodeType INTO #RouteDBMap FROM tblRouteCoverageStoreMapping RM INNER JOIN tblStoreMaster SM ON SM.StoreID=RM.StoreID
	WHERE CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate and ISNULL(DBID,0)<>0

	--SELECT * FROM #RouteDBMap WHERE RouteID=44537

	--UPDATE R SET DBNOdeID=DM.DHNOdeID FROM #AllRoutesONly R INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=R.DSRRouteID AND H.NodeType=R.DSRRouteNodeType INNER JOIN tblCompanySalesStructureHierarchy PH ON PH.NodeID=H.PnodeID AND PH.NodeType=H.PNodeTYpe
	--INNER JOIN tblCompanySalesStructure_DistributorMapping DM ON DM.SHNOdeID=PH.NOdeID AND DM.SHNodeTYpe=PH.NodeType AND CAST(GETDATE() AS DATE) BETWEEN DM.FRomDate AND DM.ToDate
	UPDATE R SET DBNodeID=M.DistNodeId FROM #AllRoutesONly R INNER JOIN #RouteDBMap M ON M.RouteID=R.DSRRouteID AND M.RouteNodeType=R.DSRRouteNodeType

	IF @AppType=3
	BEGIN
		SELECT DISTINCT #AllRoutesONly.DSRRouteID AS ID,#AllRoutesONly.DSRRouteNodeType AS RouteType, DSRRoute AS Descr, ISNULL(Active,0) AS Active,flgApproved,DBNodeID FROM #AllRoutesONly 
		--WHERE Active=1
		order by 1
	END
	ELSE
	BEGIN
		SELECT DISTINCT #AllRoutesONly.DSRRouteID AS ID,#AllRoutesONly.DSRRouteNodeType AS RouteType, DSRRoute AS Descr, ISNULL(Active,0) AS Active,flgApproved,DBNodeID FROM #AllRoutesONly 
		order by 1
	END


	
