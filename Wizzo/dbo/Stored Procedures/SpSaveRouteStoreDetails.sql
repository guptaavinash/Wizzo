
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 11-May-2015
-- Description:	Sp to manage the route to store mapping for the DSR
-- =============================================
--[SpSaveRouteStoreDetails] 36,7,3735,'18638^18673^18674^18679^18682^18690^18695^18706^18708^18709^18712^18713^18717^18719^18721^18722^18723^18728^18729^18742^18745^18750^18751^18754^18762^18768^18773^18776^18778^18782^18784^18785^18790^18791^18795^18800^18801^18803^18821','01-Feb-2015','31-Aug-2015'
CREATE PROCEDURE [dbo].[SpSaveRouteStoreDetails] 
	@NodeID INT,
	@NodeType INT,
	@LoginID INT,
	@strAddStoresID VARCHAR(MAX),
	@FromDate SMALLDATETIME,
	@ToDate SMALLDATETIME
AS
BEGIN
	DECLARE @SQL VARCHAR(MAX)
	DECLARE @Stores VARCHAR(MAX)
	DECLARE @DeletedStores VARCHAR(MAX)
	SET @Stores=REPLACE (@strAddStoresID,'^',',')
	--SET @DeletedStores=REPLACE (@strDeletedStoreID,'^',',')
	
	SELECT RouteID,StoreID,FromDate,ToDate,LoginIDIns,1 AS flgActive,RouteNodeType INTO #tmpRoutePlan FROM tblRouteCoverageStoreMapping 
	WHERE RouteID=@NodeID AND RouteNodeType=@NodeType AND Todate>=GETDATE()--DATEDIFF(d,FromDate,@FromDate)>0 AND DATEDIFF(d,ISNULL(ToDate,'01-Jan-2049'),@FromDate)<0
	CREATE TABLE #tmpStores(RouteID INT,StoreID INT,FromDate DATETIME,ToDAte DateTime,LoginIDIns INT,NodeType INT)
	IF ISNULL(@Stores,'') <> ''
	BEGIN
		PRINT 'Route Store Mapped'
		
		SET @SQL='UPDATE #tmpRoutePlan SET flgActive=0 FROM #tmpRoutePlan WHERE StoreID NOT IN (' + @Stores + ')' -- Deleting
		EXEC (@SQL)
		SET @SQL='UPDATE #tmpRoutePlan SET flgActive=1 FROM #tmpRoutePlan WHERE StoreID IN (' + @Stores + ')'  -- Updating
		EXEC (@SQL)
		SET @SQL='SELECT ' + CAST(@NodeID AS VARCHAR) + ',StoreID,''' + CONVERT(VARCHAR,@FromDate,112) + ''' ,''' + CONVERT(VARCHAR,@ToDate,112) + ''' ,' + CAST(@LoginID AS VARCHAR) + ',' + CAST(@NodeType AS VARCHAR) + ' FROM tblStoremaster WHERE StoreID IN (' + @Stores + ')'
		INSERT INTO #tmpStores(RouteID,StoreID,FromDate,ToDate,LoginIDIns,NodeType)
		EXEC (@SQL)
	END
	ELSE
	BEGIN
		PRINT 'Route Store Unmapped'
		
		SET @SQL='UPDATE #tmpRoutePlan SET flgActive=0 FROM #tmpRoutePlan ' -- Deleting
		EXEC (@SQL)
	END
	
	INSERT INTO #tmpRoutePlan(RouteID,StoreID,FromDate,ToDate,LoginIDIns,flgActive,RouteNodeType)
	SELECT S.RouteID,S.StoreID,S.FromDate,S.ToDate,S.LoginIDIns,2,S.NodeType FROM #tmpStores S 
	LEFT OUTER JOIN #tmpRoutePlan RP ON S.StoreID=RP.StoreID WHERE RP.StoreID IS NULL

	--UPDATE tblRouteCoverageStoreMapping SET ToDate=@ToDate,LoginIDUpd=@LoginID,TimestampUpd=GETDATE() FROM tblRouteCoverageStoreMapping RCM INNER JOIN #tmpRoutePlan TP ON
	--TP.RouteID=RCM.RouteID AND TP.StoreID=RCM.StoreID WHERE TP.flgActive=1
	IF @FromDate<=GETDATE() AND @ToDate>GETDATE()
		SET @FromDate=GETDATE()
		
	UPDATE tblRouteCoverageStoreMapping SET ToDate=DATEADD(d,-1,@FromDate),LoginIDUpd=@LoginID,TimestampUpd=GETDATE() FROM tblRouteCoverageStoreMapping RCM 
		INNER JOIN #tmpRoutePlan TP ON TP.RouteID=RCM.RouteID AND TP.RouteNodeType=RCM.RouteNodeType  AND TP.StoreID=RCM.StoreID WHERE TP.flgActive=0
	
		
	INSERT INTO tblRouteCoverageStoreMapping(RouteID,StoreID,FromDate,ToDate,LoginIDIns,RouteNodeType)
	SELECT RouteID,StoreID,@FromDate,@ToDate,@LoginID,@NodeType FROM #tmpRoutePlan WHERE flgActive=2

	
	
	
	----IF @FromDate <= GETDATE() AND @ToDate>GETDATE()
	----	SET @FromDate=GETDATE()
	----DECLARE @StoreID INT
	----WHILE (PATINDEX('%,%',@Stores)>0)
	----BEGIN
	----	Select @StoreID = CAST(SUBSTRING(@Stores,0,PATINDEX('%,%',@Stores)) AS INT)
		
	----	EXEC SpRouteToStoreCoverageMapping @NodeID,@NodeType,@StoreID,@FromDate,@ToDate,@LoginID

	----	IF PATINDEX('%,%',@Stores)>0
	----		SET @Stores = SUBSTRING(@Stores,PATINDEX('%,%',@Stores)+1, LEN(@Stores) - PATINDEX('%,%',@Stores))
	----END 	

	
END








