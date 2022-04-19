-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- SpGetRoutePlanCalender_tocheck 'F098033F-75E6-499B-9B35-2960287D1091'
CREATE PROCEDURE [dbo].[SpGetRoutePlanCalender_tocheck] 
	@PDA_IMEI VARCHAR(50),
	@MonthName VARCHAR(30)='',
	@Year INT=2019
AS
BEGIN
	SELECT @MonthName=MONTH(GETDATE())
	SELECT @Year=YEAR(GETDATE())
	DECLARE @NextMonthName VARCHAR(15)
	SELECT @Year=YEAR(GETDATE())
	--DECLARE @TodaysDate DATE=DATEADD(d,10,GETDATE())
	DECLARE @TodaysDate DATE=GETDATE()
	--SET @TOdaysDate='01-' + @MonthName + '-' + CAST(@Year AS VARCHAR)
	DECLARE @FirstDayOfMonth DATE
	SELECT @FirstDayOfMonth=CAST(DATEADD(DD,-DAY(GETDATE()),GETDATE()) +1 AS DATE)
	IF DATEDIFF(day,@FirstDayOfMonth,@TodaysDate)<15
	BEGIN
		SELECT @MonthName=DATENAME(month,DATEADD(m,-1,@TodaysDate)) 
		SELECT @NextMonthName=DATENAME(month,@TodaysDate)
	END
	ELSE
	BEGIN
		SELECT @MonthName=DATENAME(month,@TodaysDate)
		SELECT @NextMonthName=DATENAME(month,DATEADD(m,1,@TodaysDate))
	END


	--IF @MonthName=''
	--BEGIN
	--	SELECT @MonthName=DATENAME(month,@TodaysDate)
	--	SELECT @NextMonthName=DATENAME(month,DATEADD(m,1,@TodaysDate))
	--END
	--ELSE
	--BEGIN
	--	SELECT @MonthName=DATENAME(month,@TodaysDate)
	--	SELECT @NextMonthName=DATENAME(month,DATEADD(m,1,@TodaysDate))
	--END

	PRINT '@MonthName=' + @MonthName
	PRINT '@NextMonthName=' + @NextMonthName

	DECLARE @Month INT,@NextMonth INT
	SELECT @Month=MONTH(CONCAT(1,@MonthName,0))
	SELECT @NextMonth=MONTH(CONCAT(1,@NextMonthName,0))

	DECLARE @PersonNodeID INT
	SELECT @PersonNodeID=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@PDA_IMEI) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	--DECLARE @PersonNodeID INT
	--SELECT @PersonNodeID=dbo.fnGetPersonIDfromIMEI(@PDA_IMEI)

	PRINT '@PersonNodeID=' + CAST(ISNULL(@PersonNodeID,0) AS VARCHAR)
	--DECLARE @DeviceID INT
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI

	PRINT '1=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')

	SELECT distinct P.NodeID,P.NodeType,MIN(P.FromDate) AS FromDate, MAX(P.ToDate) AS ToDate  INTO #CoverageArea 
	FROM tblSalesPersonMapping P 
	--INNER JOIN tblPDA_UserMapMaster M ON M.PersonID=P.PersonID 
	INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
	--INNER JOIN tblPDAMaster PDA ON PDA.PDAID=M.PDAID
	WHERE ISNULL(C.flgCoverageArea,0)=1 AND P.PersonNodeID=@PersonNodeID  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
	GROUP BY P.NodeID,P.NodeType

	--SELECT * FROM #CoverageArea

	
	SET DATEFirst 1  

	----DECLARE @StartDate DATE = DATEADD(week, datediff(week, 0, DATEADD(d,-14,GETDATE())), 0)  
	----DECLARE @EndDate DATE = DATEADD(DAY, 7 - DATEPART(WEEKDAY, DATEADD(d,14,GETDATE())), CAST(DATEADD(d,14,GETDATE()) AS DATE)) 

	DECLARE @StartDate DATE =DATEADD(month,@Month-1,DATEADD(year,@Year-1900,0))
	DECLARE @EndDate DATE =EOMONTH(@StartDate) --DATEADD(day,-1,DATEADD(month,@Month,DATEADD(year,@Year-1900,0)))
	PRINT '@StartDate=' + CAST(@StartDate AS VARCHAR)
	PRINT '@EndDate=' + CAST(@EndDate AS VARCHAR)
	
	DECLARE @NextMonthStartDate DATE=DATEADD(m,1,DATEADD(month,@Month-1,DATEADD(year,@Year-1900,0)))
	DECLARE @NextMonthEndDate DATE=EOMONTH(@NextMonthStartDate) --DATEADD(m,1,DATEADD(day,-1,DATEADD(month,@Month,DATEADD(year,@Year-1900,0))))
	PRINT '@NextMonthStartDate=' + CAST(@NextMonthStartDate AS VARCHAR)
	PRINT '@NextMonthEndDate=' + CAST(@NextMonthEndDate AS VARCHAR)


	SELECT  TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1) Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @StartDate) INTO #tblDates
	FROM    sys.all_objects a CROSS JOIN sys.all_objects b

	PRINT '2=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	SELECT  TOP (DATEDIFF(DAY, @NextMonthStartDate, @NextMonthEndDate) + 1) Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @NextMonthStartDate) INTO #tblNextMonthDates
	FROM    sys.all_objects a CROSS JOIN sys.all_objects b

	CREATE TABLE #TotalDates(Date DATE,MonthVal INT,YearVal INT)
	INSERT INTO #TotalDates(Date,MonthVal,YearVal)
	SELECT Date,@month,YEAR(Date) FROM #tblDates
	UNION
	SELECT Date,@NextMonth,YEAR(Date) FROM #tblNextMonthDates

	PRINT '3=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')

	-- SELECT DateName(mm,DATEADD(mm,7,-1))
	--SELECT * FROM #TotalDates

	CREATE TABLE #tblRoutePlan(RouteNodeID INT,RouteNodeType SMALLINT,RouteName VARCHAR(200),PlannedDate Date,DBRNodeID INT,StoreNodeID INT,flgDBRPlanned TINYINT,flgStorePlanned TINYINT,flgDBRActual TINYINT,flgStoreActual TINYINT DEFAULT 0,flgAttendance TINYINT DEFAULT 2,WeekID INT,MonthVal INT,MonthYear VARCHAR(15))

	INSERT INTO #tblRoutePlan(RouteNodeID,RouteNodeType,RouteName,PlannedDate,DBRNodeID,StoreNodeID,WeekID,MonthVal,MonthYear)
	SELECT DISTINCT H.NodeID RouteNodeID,H.NodeType RouteNodetype,R.Descr,D.Date,SM.DBID,SM.StoreID,DATEPART(WEEK, D.Date)  -  DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,D.Date), 0))+ 1,D.MonthVal,LEFT(DATENAME(month,DATEADD(mm,D.MonthVal,-1)),3) + '-' + CAST(D.YearVal AS VARCHAR) FROM tblCompanySalesStructureHierarchy H INNER JOIN #CoverageArea C ON H.PNodeID=C.NodeID AND H.PNodeType=C.NodeType 
	LEFT OUTER JOIN tblRouteCoverageStoreMapping RM ON RM.RouteID=H.NodeID AND RM.RouteNodeType=H.NodeType
	AND GETDATE() BETWEEN RM.FromDate AND RM.ToDate
	LEFT OUTER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=H.NodeID AND R.NodeType=H.NodeType
	LEFT OUTER JOIN tblStoreMaster(nolock) SM ON SM.StoreID=RM.StoreID 
	CROSS JOIN #TotalDates D WHERE GETDATE() BETWEEN H.VldFrom AND H.VldTo 

	--SELECT * FROM #tblRoutePlan WHERE PlannedDate='05-Dec-2021'
	
	PRINT '4=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	CREATE TABLE #Route (RouteNodeID INT,RouteNodetype SMALLINT,PlannedDate Date,flgPlanned TINYINT DEFAULT 0 NOT NULL,CovFrqId INT,WeekId INT,FrqVal TINYINT)
	INSERT INTO #Route(RouteNodeID,RouteNodetype,PlannedDate)
	SELECT DISTINCT RouteNodeID,RouteNodeType,PlannedDate FROM #tblRoutePlan
	
	PRINT '4.1=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')

	--------------------added by gaurav ON 04-Oct-19 to updated flgPlanned directly using query not from the function-----------------------------------

					--*************************** New Code ***************************--
	----UPDATE A SET A.CovFrqId=B.CovFrqId,A.WeekId=B.WeekId
	----FROM #Route A INNER JOIN tblRouteCoverage B ON A.RouteNodeID=B.RouteId AND A.RouteNodeType=B.NodeType 
	----WHERE (A.PlannedDate BETWEEN B.FromDate AND B.ToDate) AND DATEPART(dw,A.PlannedDate)=B.[Weekday]

	----UPDATE A SET A.FrqVal=B.value FROM #Route A INNER JOIN tblRoutePlanDetails B ON A.WeekId=B.WeekId AND A.CovFrqID=B.CovFrqID
	----UPDATE A SET A.flgPlanned=1 FROM #Route A INNER JOIN tblRoutePlanDetails B ON A.FrqVal=B.value AND A.CovFrqID=B.CovFrqID AND (A.PlannedDate BETWEEN WeekFrom AND WeekTo)
	UPDATE A SET A.flgplanned=1 FROM #Route A INNER JOIN tblRoutePlanningVisitDetail V ON V.RouteNodeId=A.RouteNodeID AND V.RouteNodetype=A.RouteNodetype AND A.PlannedDate=V.VisitDate

	--SELECT * FROM #Route
					--****************************************************************--
					
					/*--*************************** Old Code ***************************--
	UPDATE A SET flgPlanned=dbo.fnGetPlannedVisit(A.RouteNodeID,A.RouteNodeType,A.PlannedDate) FROM #Route A 

					--****************************************************************--*/
	--------------------------------------------------------------------------------------------------------------------------------------------
	--SELECT * FROM #Route
		

	PRINT '4.2=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	UPDATE A SET flgStorePlanned=flgPlanned FROM #tblRoutePlan A INNER JOIN #Route B ON A.RouteNodeID=B.RouteNodeID AND A.RouteNodetype=B.RouteNodeType AND A.PlannedDate=B.PlannedDate

	PRINT '4.3=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	--SELECT * FROM #tblRoutePlan

	---UPDATE A SET flgStorePlanned=1 FROM #tblRoutePlan A  WHERE flgSpokePlanned=1

	----UPDATE A SET flgSpokeActual=1 FROM #tblRoutePlan A INNER JOIN tblVisitMaster(nolock) VM ON VM.CustomerNodeId=A.SpokeNodeID AND VM.CustomerNodeType=180 AND VM.VisitDate=CAST(PlannedDate AS DATE)
	PRINT '4.2=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	UPDATE A SET flgStoreActual=1 FROM #tblRoutePlan A INNER JOIN tblVisitMaster(nolock) VM ON VM.StoreID=A.StoreNodeID AND VM.VisitDate=CAST(PlannedDate AS DATE)

	--SELECT * FROM #tblRoutePlan WHERE RouteNodeID=47674
	PRINT '5=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	----SELECT DISTINCT VM.StoreID,VM.VisitDate INTO #ProductiveStores FROM tblVisitMaster VM INNER JOIN #tblRoutePlan R ON R.StoreNodeID=VM.StoreID AND R.PlannedDate=VM.VisitDate INNER JOIN tblOrderMaster OM ON OM.VisitID=VM.VisitID

	SELECT DISTINCT OM.StoreID,OM.OrderDate INTO #ProductiveStores FROM tblOrderMaster OM INNER JOIN #tblRoutePlan R ON R.StoreNodeID=OM.StoreID AND R.PlannedDate=OM.OrderDate WHERE OM.OrderSourceID=1

	--UPDATE A SET flgAttendance=dbo.fnGetPersonAttendance(@PersonNodeID,PlannedDate) FROM #tblRoutePlan A WHERE PlannedDate<=CAST(GETDATE() AS DATE)

	--SELECT * FROM #ProductiveStores
	


	SELECT DISTINCT CAST(A.Datetime AS DATE) AttnDate INTO #MarkedDates FROM tblPersonAttendance A INNER JOIN personAttreason R ON A.PersonAttendanceID=R.PersonAttendanceID INNER JOIN tblMstrReasonsForNoVisit B ON R.ReasonID=B.ReasonID INNER JOIN #tblRoutePlan RP ON RP.PlannedDate=CAST(A.Datetime AS DATE) WHERE R.ReasonID NOT IN(0,1) AND A.PersonNodeID=@PersonNodeID

	--SELECT * FROM #MarkedDates

	UPDATE A SET flgStoreActual=1 FROM #tblRoutePlan A INNER JOIN #ProductiveStores P ON P.StoreID=A.StoreNodeID AND P.OrderDate=A.PlannedDate

	UPDATE A SET flgAttendance=0 FROM #tblRoutePlan A WHERE A.PlannedDate NOT IN (SELECT AttnDate FROM #MarkedDates)

	UPDATE A SET flgAttendance=1 FROM #tblRoutePlan A INNER JOIN (SELECT OrderDate FROM #ProductiveStores GROUP BY OrderDate HAVING COUNT(DISTINCT StoreID)>=7) X ON X.OrderDate=A.PlannedDate

	

	PRINT '5.1=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	--SELECT DISTINCT PlannedDate,SpokeNodeID,flgSpokePlanned,flgSpokeActual INTO #SpokeDet FROM #tblRoutePlan

	SELECT DISTINCT PlannedDate,StoreNodeID,flgStorePlanned,flgStoreActual,flgAttendance INTO #StoreDet FROM #tblRoutePlan

	--SELECT * FROM #tblRoutePlan WHERE flgStorePlanned=1 AND RouteNodeID=47674

	--SELECT * FROM #SpokeDet
	PRINT '6=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	CREATE TABLE #tblReport(PlannedDate Date,DateStr VARCHAR(20),PlannedDayname VARCHAR(20),PlannedSpoke SMALLINT,ActualVisitedSpokes SMALLINT,PlannedStores SMALLINT,ActualVisitedStores SMALLINT,flgAttendance TINYINT,Color VARCHAR(10),LegendText VARCHAR(100),WeekID INT,MonthVal INT,flgPJPDone TINYINT DEFAULT 0,MonthYear VARCHAR(20),RouteName VARCHAR(200)) 

	--SELECT 1

	INSERT INTO #tblReport(PlannedDate,DateStr,PlannedDayname,flgAttendance,Color,LegendText,WeekID,MonthVal,flgPJPDone,MonthYear)
	SELECT DISTINCT PlannedDate,FORMAT(PlannedDate,'dd-MMM-yyyy'),FORMAT(PlannedDate,'ddd'),flgAttendance,CASE ISNULL(flgAttendance,0) WHEN 0 THEN '#FF0000' WHEN 1 THEN '#008000' WHEN 2 THEN '#FFBF00' END,CASE ISNULL(flgAttendance,0) WHEN 0 THEN 'Absent' WHEN 1 THEN 'Present' WHEN 2 THEN 'Leave' END,WeekID,MonthVal,0,MonthYear  
	FROM #tblRoutePlan ORDER BY PlannedDate,flgAttendance
	PRINT '7=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	--SELECT * FROM #tblReport
	--SELECT * FROM #tblRoutePlan
	-- For JC Meeting
	UPDATE P SET flgAttendance=1 FROM #tblReport P INNER JOIN tblPersonAttendance A ON CAST(A.Datetime AS DATE)=CAST(P.PlannedDate AS DATE) INNER JOIN personAttreason R ON A.PersonAttendanceID=R.PersonAttendanceID INNER JOIN tblMstrReasonsForNoVisit B ON R.ReasonID=B.ReasonID WHERE R.ReasonID IN(17) AND A.PersonNodeID=@PersonNodeID AND PlannedDate<=CAST(GETDATE() AS DATE)


	UPDATE R SET RouteName=ISNULL(M.Descr,'NA') FROM #tblReport R INNER JOIN #Route P ON P.PlannedDate=R.PlannedDate INNER JOIN tblCompanySalesStructureRouteMstr M ON M.NodeID=P.RouteNodeID WHERE flgPlanned=1

	--SELECT * FROM #tblReport 

	----UPDATE R SET R.PlannedSpoke=X.Spokeplanned,R.ActualVisitedSpokes=X.SpokeActual FROM #tblReport R ,(SELECT PlannedDate,SUM(flgSpokePlanned) Spokeplanned,SUM(flgSpokeActual) SpokeActual FROM #SpokeDet WHERE flgSpokePlanned=1 GROUP BY PlannedDate) X WHERE X.PlannedDate=R.PlannedDate

	UPDATE R SET R.PlannedStores=X.Storeplanned,R.ActualVisitedStores=X.StoreActual FROM #tblReport R ,(SELECT PlannedDate,SUM(flgStorePlanned) Storeplanned,SUM(flgStoreActual) StoreActual FROM #StoreDet WHERE flgStorePlanned=1 GROUP BY PlannedDate) X WHERE X.PlannedDate=R.PlannedDate

	--SELECT * FROM #tblReport WHERE PlannedDate='29-Nov-2021'
	

	UPDATE R SET flgPJPDone=1 FROM #tblReport R WHERE flgAttendance=1 AND ISNULL(PlannedStores,0)<>0

	--SELECT * FROM #tblReport ORDER BY WeekId
	--SELECT * FROM #tblReport WHERE WeekID=4 

	PRINT '8=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	CREATE TABLE #FinalReport(Dayname VARCHAR(20),WeekDay INT,Week1 VARCHAR(100),Week2 VARCHAR(100),Week3 VARCHAR(100),Week4 VARCHAR(100),Week5 VARCHAR(100),Week6 VARCHAR(100),MonthValue INT,MonthYear VARCHAR(15))
	INSERT INTO #FinalReport(Dayname,MonthValue,WeekDay,MonthYear)
	SELECT DISTINCT PlannedDayname,MonthVal,DATEPART(WEEKDAY,PlannedDate),MonthYear FROM #tblReport ORDER BY PlannedDayname,MonthVal

	--SELECT * FROM #FinalReport

	UPDATE F SET Week1=CAST(ISNULL(flgAttendance,0) AS VARCHAR) + '^' + LEFT(R.DateStr,6) + '^' + CAST(ISNULL(R.ActualVisitedStores,0) AS VARCHAR) + '(' + CAST(ISNULL(R.PlannedStores,0) AS VARCHAR) +')' + '^' + CAST(ISNULL(flgPJPDone,0) AS VARCHAR) + '^' + R.DateStr + '^' + ISNULL(R.RouteName,'NA')  FROM #FinalReport F INNER JOIN #tblReport R ON R.PlannedDayname=F.Dayname AND R.MonthVal=F.MonthValue WHERE R.WeekID=1
	UPDATE F SET Week2=CAST(ISNULL(flgAttendance,0) AS VARCHAR) + '^' + LEFT(R.DateStr,6) + '^' + CAST(ISNULL(R.ActualVisitedStores,0) AS VARCHAR) + '(' + CAST(ISNULL(R.PlannedStores,0) AS VARCHAR) +')' + '^' + CAST(ISNULL(flgPJPDone,0) AS VARCHAR) + '^' + R.DateStr + '^' + ISNULL(R.RouteName,'NA') FROM #FinalReport F INNER JOIN #tblReport R ON R.PlannedDayname=F.Dayname AND R.MonthVal=F.MonthValue WHERE R.WeekID=2
	UPDATE F SET Week3=CAST(ISNULL(flgAttendance,0) AS VARCHAR) + '^' + LEFT(R.DateStr,6) + '^' + CAST(ISNULL(R.ActualVisitedStores,0) AS VARCHAR) + '(' + CAST(ISNULL(R.PlannedStores,0) AS VARCHAR) +')' + '^' + CAST(ISNULL(flgPJPDone,0) AS VARCHAR) + '^' + R.DateStr + '^' + ISNULL(R.RouteName,'NA') FROM #FinalReport F INNER JOIN #tblReport R ON R.PlannedDayname=F.Dayname AND R.MonthVal=F.MonthValue WHERE R.WeekID=3
	UPDATE F SET Week4=CAST(ISNULL(flgAttendance,0) AS VARCHAR) + '^' + LEFT(R.DateStr,6) + '^' + CAST(ISNULL(R.ActualVisitedStores,0) AS VARCHAR) + '(' + CAST(ISNULL(R.PlannedStores,0) AS VARCHAR) +')' + '^' + CAST(ISNULL(flgPJPDone,0) AS VARCHAR) + '^' + R.DateStr + '^' + ISNULL(R.RouteName,'NA') FROM #FinalReport F INNER JOIN #tblReport R ON R.PlannedDayname=F.Dayname AND R.MonthVal=F.MonthValue WHERE R.WeekID=4

	UPDATE F SET Week5=CAST(ISNULL(flgAttendance,0) AS VARCHAR) + '^' + LEFT(R.DateStr,6) + '^' + CAST(ISNULL(R.ActualVisitedStores,0) AS VARCHAR) + '(' + CAST(ISNULL(R.PlannedStores,0) AS VARCHAR) +')' + '^' + CAST(ISNULL(flgPJPDone,0) AS VARCHAR) + '^' + R.DateStr + '^' + ISNULL(R.RouteName,'NA') FROM #FinalReport F INNER JOIN #tblReport R ON R.PlannedDayname=F.Dayname AND R.MonthVal=F.MonthValue WHERE R.WeekID=5

	UPDATE F SET Week6=CAST(ISNULL(flgAttendance,0) AS VARCHAR) + '^' + LEFT(R.DateStr,6) + '^' + CAST(ISNULL(R.ActualVisitedStores,0) AS VARCHAR) + '(' + CAST(ISNULL(R.PlannedStores,0) AS VARCHAR) +')' + '^' + CAST(ISNULL(flgPJPDone,0) AS VARCHAR) + '^' + R.DateStr + '^' + ISNULL(R.RouteName,'NA') FROM #FinalReport F INNER JOIN #tblReport R ON R.PlannedDayname=F.Dayname AND R.MonthVal=F.MonthValue WHERE R.WeekID=6

	PRINT '9=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	SELECT LEFT (Dayname,1) Dayname,WeekDay,Week1,Week2,Week3,Week4,Week5,Week6,MonthValue,MonthYear FROM #FinalReport ORDER BY MonthValue,WeekDay

	
	
	--SELECT PlannedDate,DateStr,PlannedDayname,ISNULL(PlannedSpoke,0) PlannedSpoke,ISNULL(ActualVisitedSpokes,0) ActualVisitedSpokes,ISNULL(PlannedStores,0) PlannedStores,ISNULL(ActualVisitedStores,0) ActualVisitedStores,flgAttendance,Color,LegendText,WeekID,MonthVal,flgPJPDone FROM #tblReport
	
	SELECT DISTINCT FORMAT(PlannedDate,'dd-MMM-yyyy') Date,StoreNodeID StoreID,flgStorePlanned flgStorePlanned,flgStoreActual AS flgStoreVisited FROM #StoreDet 
	WHERE flgStorePlanned=1 AND StoreNodeID IS NOT NULL
	
	PRINT '10=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
END
