-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--- SpRptGateMeeting '15-Apr-2022'
CREATE PROCEDURE  SpRptGateMeeting
	@strDate DATE
AS
BEGIN
	DECLARE @StartDate DATE =DATEADD(month,MONTH(@StrDate)-1,DATEADD(year,YEAR(@StrDate)-1900,0))
	--DECLARE @EndDate DATE =EOMONTH(@StartDate) 
	DECLARE @EndDate DATE =@strDate

	SELECT  TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1) Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @StartDate) INTO #tblDates
	FROM    sys.all_objects a CROSS JOIN sys.all_objects b

	CREATE TABLE #tblRpt(CovAreaNodeID INT,CovAreaNodeType INT,RptDate Date,[ASM NAme] VARCHAR(200),[SO NAme] VARCHAR(200))
	INSERT INTO #tblRpt(CovAreaNodeID,CovAreaNodeType,RptDate,[ASM NAme],[SO NAme])
	SELECT DISTINCT DSRAreaID,DSRAreaNodeType,D.Date,V.ASM,V.SO FROM VwCompanyDSRFullDetail V CROSS JOIN #tblDates D

	DECLARE @Counter INT=1
	DECLARE @MaxCount INT
	DECLARE @StrCategory VARCHAR(5000)=''
	DECLARE @StrCategoryForGrouping VARCHAR(5000)=''
	DECLARE @CatNodeId INT
	DECLARE @Category VARCHAR(200)
	DECLARE @strSQL VARCHAR(8000)

	

	CREATE TABLE #tmpCatList(RowId INT IDENTITY(1,1),CategoryNodeId INT,Category VARCHAR(200))
	INSERT INTO #tmpCatList(CategoryNodeId,Category)
	SELECT DISTINCT M.SKUNodeID,P.Brand FROM tblFocusbrandmapping M INNER JOIN vwProductHierarchy P ON P.BrndNodeID=M.SKUNodeID AND P.BrndNodeType=M.SKUNOdeType WHERE @strDate BETWEEN M.FromDate AND  M.ToDate
	--SELECT * FROM #tmpCatList

	SELECT T.CovAreaNodeID,T.CovAreaNodeType,T.PersonNodeID,T.PersonNodeType,T.EntryPersonNodeID,T.EntryPersonNodeType,TD.SKUNodeID CategoryNodeID,TD.SKUNodeType CategoryNodeType,T.DataDate,TD.Dstrbn_Tgt,TD.Sales_Tgt * 1000 Sales_Tgt INTO #TargetCategorywise FROM tblGateMeetingTarget T INNER JOIN #tblDates D ON D.Date=T.DataDate INNER JOIN tblGateMeetingTargetDet TD ON TD.PersonMeetingID=T.PersonMeetingID

	--SELECT * FROM #TargetCategorywise WHERE CovAreaNodeID=7 AND DataDate='12-Apr-2022'

	--SELECT * FROM VwProductHierarchy
	SELECT * INTO #PrdHier FROM VwProductHierarchy
	SELECT R.CovAreaNodeID,R.CovAreaNodeType,OM.StoreID,#PrdHier.BrndNodeID CategoryId,#PrdHier.Brand Category,#PrdHier.PrdNodeId SKUNodeId,#PrdHier.PrdNodeType SKUNodeType,#PrdHier.Product SKU,#PrdHier.PrdCode SKUCode,OM.OrderDate,SUM(Od.OrderQty) OrderQty,SUM(CAST(ROUND((OD.OrderQty * Volume),2) AS FLOAT)) OrderQtyInKG,SUM(CAST(OD.NetLineOrderVal AS FLOAT)) OrderVal,ROUND(SUM(CAST(Od.OrderQty AS FLOAT)/RelConversionUnits),2) OrderInCase INTO [#TMPSales]
	FROM tblOrderMaster(nolock) OM INNER JOIN tblOrderDetail(nolock) OD ON OM.OrderId=OD.OrderId
	INNER JOIN tblCompanySalesStructureHierarchy RH ON RH.NodeID=OM.RouteNodeId AND RH.NodeType=OM.RouteNodeType
	INNER JOIN #tblRpt R ON RH.PNodeID=R.CovAreaNodeID AND RH.PNodeType=R.CovAreaNodeType AND OM.OrderDate=R.RptDate
	INNER JOIN #PrdHier ON OD.ProductID = #PrdHier.PrdNodeId
	LEFT OUTER JOIN tblPrdMstrPackingUnits_ConversionUnits(nolock) C ON C.SKUId=OD.ProductID AND C.BaseUOMID=3
	WHERE MONTH(OM.OrderDate)=MONTH(@strDate) AND YEAR(OM.OrderDate)=YEAR(@StrDate) AND OM.OrderStatusId<>3
	GROUP BY R.CovAreaNodeID,R.CovAreaNodeType,OM.StoreID, #PrdHier.BrndNodeID,#PrdHier.Brand,#PrdHier.PrdNodeId, #PrdHier.PrdNodeType, #PrdHier.Product,#PrdHier.PrdCode,OM.OrderDate

	SELECT CovAreaNodeID,CovAreaNodeType,OrderDate,CategoryId,Category,SUM(OrderQty) OrderQty,SUM(OrderQtyInKG) OrderQtyInKG,SUM(OrderVal) OrderVal,ROUND(SUM(OrderInCase),2) OrderInCase INTO #CoverageSales FROM [#TMPSales] GROUP BY CovAreaNodeID,CovAreaNodeType,OrderDate,CategoryId,Category

	SELECT 	CovAreaNodeID,CovAreaNodeType,OrderDate,CategoryId,Category,COUNT(DISTINCT StoreID) PC INTO #DstrbnAch FROM [#TMPSales] GROUP BY CovAreaNodeID,CovAreaNodeType,OrderDate,CategoryId,Category

	SELECT @MaxCount=Max(RowId) FROM #tmpCatList
	WHILE @Counter<=@MaxCount
	BEGIN
		----IF @Counter<>@MaxCount
		----BEGIN
		----	INSERT INTO #ColumnIndexListForFormatting(ColumnIndex,ColorCode)
		----	SELECT 20+@Counter AS ColumnName,'5F8B41' AS ColorCode
		----END
		
		SELECT @CatNodeId=CategoryNodeId,@Category=Category FROM #tmpCatList WHERE RowId=@Counter

		SELECT @strSQL='ALTER TABLE #tblRpt ADD [Target^' + @Category + 'Sale] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)
		SELECT @strSQL='ALTER TABLE #tblRpt ADD [Target^' + @Category + 'PC] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)

		SELECT @strSQL='UPDATE A SET A.[Target^' + @Category + 'Sale]=ROUND(B.Sales,2) , A.[Target^' + @Category + 'PC]=ROUND(B.TC,2)
		FROM #tblRpt A INNER JOIN (SELECT DataDate,CovAreaNodeID,CovAreaNodeType,Dstrbn_Tgt TC,Sales_Tgt Sales FROM #TargetCategorywise WHERE CategoryNodeId=' + CAST(@CatNodeId AS VARCHAR) + ') B ON A.CovAreaNodeID=B.CovAreaNodeID AND A.CovAreaNodeType=B.CovAreaNodeType AND A.RptDate=B.DataDate'
		PRINT @strSQL
		EXEC(@strSQL)


		SELECT @strSQL='ALTER TABLE #tblRpt ADD [Achievement^' + @Category + 'Sale] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)
		SELECT @strSQL='ALTER TABLE #tblRpt ADD [Achievement^' + @Category + 'PC] FLOAT'
		PRINT @strSQL
		EXEC(@strSQL)



		SELECT @strSQL='UPDATE A SET A.[Achievement^' + @Category + 'Sale]=ROUND(B.OrderQtyInKG,2) , A.[Achievement^' + @Category + 'PC]=PC
		FROM #tblRpt A INNER JOIN (SELECT OrderDate,CovAreaNodeId,CovAreaNodeType,SUM(OrderQtyInKG) OrderQtyInKG FROM #CoverageSales WHERE CategoryId=' + CAST(@CatNodeId AS VARCHAR) + ' GROUP BY OrderDate,CovAreaNodeId,CovAreaNodeType) B ON A.CovAreaNodeID=B.CovAreaNodeId AND A.CovAreaNodeType=B.CovAreaNodeType AND A.RptDate=B.OrderDate 
		LEFT OUTER JOIN (SELECT OrderDate,CovAreaNodeId,CovAreaNodeType,PC FROM #DstrbnAch WHERE CategoryId=' + CAST(@CatNodeId AS VARCHAR) + ' ) C ON A.CovAreaNodeID=C.CovAreaNodeId AND A.CovAreaNodeType=C.CovAreaNodeType AND A.RptDate=C.OrderDate'
		
		PRINT @strSQL
		EXEC(@strSQL)

		
		SELECT @Counter+=1
	END

	SELECT * FROM #tblRpt
END
