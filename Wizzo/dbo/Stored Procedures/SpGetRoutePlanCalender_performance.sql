-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--SELECT * FROM tblPDACodeMapping
-- SpGetRoutePlanCalender_performance '49523BD4-BD84-4A80-84E2-7AA7C2CC53CD'
CREATE PROCEDURE [dbo].[SpGetRoutePlanCalender_performance] 
	@PDA_IMEI VARCHAR(50),
	@MonthName VARCHAR(30)='',
	@Year INT=2019,
	@CoverageAreaNodeID INT=0,
	@CoverageAreaNodeType SMALLINT=0
AS
BEGIN
	DECLARE @NextMonthYear INT
	DECLARE @PreviousMonthYear INT


	SELECT @MonthName=MONTH(GETDATE())
	
	DECLARE @NextMonthName VARCHAR(15)
	--SELECT @Year=YEAR(GETDATE())
	--DECLARE @TodaysDate DATE=DATEADD(d,10,GETDATE())
	DECLARE @TodaysDate DATE=GETDATE()
	--SET @TOdaysDate='01-' + @MonthName + '-' + CAST(@Year AS VARCHAR)
	DECLARE @FirstDayOfMonth DATE
	SELECT @FirstDayOfMonth=CAST(DATEADD(DD,-DAY(GETDATE()),GETDATE()) +1 AS DATE)
	IF DATEDIFF(day,@FirstDayOfMonth,@TodaysDate)<15
	BEGIN
		SELECT @MonthName=DATENAME(month,DATEADD(m,-1,@TodaysDate))
		SELECT @PreviousMonthYear=YEAR(DATEADD(m,-1,@TodaysDate))


		SELECT @NextMonthName=DATENAME(month,@TodaysDate)
		SELECT @NextMonthYear=YEAR(@TodaysDate)
		--SELECT @Year=YEAR(GETDATE())
	END
	ELSE
	BEGIN
		SELECT @MonthName=DATENAME(month,@TodaysDate)
		SELECT @PreviousMonthYear=YEAR(@TodaysDate)

		SELECT @NextMonthName=DATENAME(month,DATEADD(m,1,@TodaysDate))
		SELECT @NextMonthYear=YEAR(DATEADD(m,1,@TodaysDate))
		--SELECT @Year=YEAR(GETDATE())
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

	PRINT '@@PreviousMonthYear=' + CAST(@PreviousMonthYear AS VARCHAR)
	PRINT '@@NextMonthYear=' + CAST(@NextMonthYear AS VARCHAR)

	DECLARE @Month INT,@NextMonth INT
	SELECT @Month=MONTH(CONCAT(1,@MonthName,0))
	SELECT @NextMonth=MONTH(CONCAT(1,@NextMonthName,0))

	DECLARE @PersonNodeID INT
	DECLARE @PersonType INT 

	SELECT @PersonNodeID=P.NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDA_IMEI) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	SELECT * INTO #VwCompanySalesHierarchy FROM VwCompanySalesHierarchy

	CREATE TABLE #CoverageArea(NodeID INT,NodeType SMALLINT)

	IF @PersonType IN (220,230)
	BEGIN
		INSERT INTO  #CoverageArea
		SELECT DISTINCT P.NodeID,P.NodeType  
		FROM tblSalesPersonMapping(nolock) P     
		INNER JOIN [dbo].[tblSecMenuContextMenu] S ON S.NodeType=P. NodeType     
		WHERE P.PersonNodeID=@PersonNodeID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) AND S.flgCoverageArea=1
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
			SELECT @CoverageAreaNodeID,@coverageAreaNodeType
			--SELECT DISTINCT V.DSRAreaID,V.DSRAreaNodeType  
			--FROM tblSalesPersonMapping P INNER JOIN #VwCompanySalesHierarchy V ON V.ASMAreaID=P.NodeID AND V.ASMAreaNodeType=P.NodeType 
			--WHERE P.PersonNodeID=@PersonNodeID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
		END
	END


	--DECLARE @PersonNodeID INT
	--SELECT @PersonNodeID=dbo.fnGetPersonIDfromIMEI(@PDA_IMEI)

	PRINT '@PersonNodeID=' + CAST(ISNULL(@PersonNodeID,0) AS VARCHAR)
	--DECLARE @DeviceID INT
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI

	PRINT '1=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')

	----SELECT distinct P.NodeID,P.NodeType,MIN(P.FromDate) AS FromDate, MAX(P.ToDate) AS ToDate  INTO #CoverageArea 
	----FROM tblSalesPersonMapping P 
	------INNER JOIN tblPDA_UserMapMaster M ON M.PersonID=P.PersonID 
	----INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
	------INNER JOIN tblPDAMaster PDA ON PDA.PDAID=M.PDAID
	----WHERE ISNULL(C.flgCoverageArea,0)=1 AND P.PersonNodeID=@PersonNodeID  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
	----GROUP BY P.NodeID,P.NodeType

	--SELECT * FROM #CoverageArea

	
	SET DATEFirst 1 
	PRINT @Month
	PRINT @Year

	
	----DECLARE @StartDate DATE = DATEADD(week, datediff(week, 0, DATEADD(d,-14,GETDATE())), 0)  
	----DECLARE @EndDate DATE = DATEADD(DAY, 7 - DATEPART(WEEKDAY, DATEADD(d,14,GETDATE())), CAST(DATEADD(d,14,GETDATE()) AS DATE)) 

	DECLARE @StartDate DATE =DATEADD(month,@Month-1,DATEADD(year,@PreviousMonthYear-1900,0))
	DECLARE @EndDate DATE =EOMONTH(@StartDate) --DATEADD(day,-1,DATEADD(month,@Month,DATEADD(year,@Year-1900,0)))
	PRINT '@StartDate=' + CAST(@StartDate AS VARCHAR)
	PRINT '@EndDate=' + CAST(@EndDate AS VARCHAR)
	
	DECLARE @NextMonthStartDate DATE =DATEADD(month,@NExtMonth-1,DATEADD(year,@NextMonthYear-1900,0))
	DECLARE @NextMonthEndDate DATE =EOMONTH(@NextMonthStartDate) --DATEADD(day,-1,DATEADD(month,@Month,DATEADD(year,@Year-1900,0)))

	----DECLARE @NextMonthStartDate DATE=DATEADD(m,1,DATEADD(month,@Month-1,DATEADD(year,@Year-1900,0)))
	----DECLARE @NextMonthEndDate DATE=EOMONTH(@NextMonthStartDate) --DATEADD(m,1,DATEADD(day,-1,DATEADD(month,@Month,DATEADD(year,@Year-1900,0))))
	PRINT '@NextMonthStartDate=' + CAST(@NextMonthStartDate AS VARCHAR)
	PRINT '@NextMonthEndDate=' + CAST(@NextMonthEndDate AS VARCHAR)

	----SELECT @Month=1
	----SELECT @NextMonth=2
	----SELECT @StartDate='01-Jan-2022'
	----SELECT @EndDate='31-Jan-2022'
	----SELECT @NextMonthStartDate='01-Feb-2022'
	----SELECT @NextMonthEndDate='28-Feb-2022'


	SELECT  TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1) Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @StartDate) INTO #tblDates
	FROM    sys.all_objects a CROSS JOIN sys.all_objects b

	PRINT '2=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	SELECT  TOP (DATEDIFF(DAY, @NextMonthStartDate, @NextMonthEndDate) + 1) Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @NextMonthStartDate) INTO #tblNextMonthDates
	FROM    sys.all_objects a CROSS JOIN sys.all_objects b

	CREATE TABLE #TotalDates(Date DATE,MonthVal INT,YearVal INT,WeekID INT,Visitmonthyear int,strMonthYear VARCHAR(15))
	INSERT INTO #TotalDates(Date,MonthVal,YearVal,WeekID,Visitmonthyear,strMonthYear)
	SELECT Date,@month,YEAR(Date),DATEPART(WEEK, Date)  -  DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,Date), 0))+ 1,YEAR(Date)*100 + @month,LEFT(DATENAME(month,DATEADD(mm,@month,-1)),3) + '-' + CAST(YEAR(Date) AS VARCHAR) FROM #tblDates
	UNION
	SELECT Date,@NextMonth,YEAR(Date),DATEPART(WEEK, Date)  -  DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,Date), 0))+ 1,YEAR(Date)*100 + @NextMonth,LEFT(DATENAME(month,DATEADD(mm,@NextMonth,-1)),3) + '-' + CAST(YEAR(Date) AS VARCHAR) FROM #tblNextMonthDates

	PRINT '3=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')

	CREATE TABLE #RptmonthYear(monthval int,yearval int,Visitmonthyear int)
	INSERT INTO #RptmonthYear
	SELECT DISTINCT MonthVal,YearVal,YearVal*100 + MonthVal FROM #TotalDates

	-- SELECT DateName(mm,DATEADD(mm,7,-1))
	--SELECT * FROM #TotalDates
	CREATE TABLE #Routes(NodeID INT,NodeType SMALLINT,VisitDate Date,flgPlanned TINYINT DEFAULT 0,WeekID INT,monthval INT,Visitmonthyear int,strMonthYear VARCHAR(15))
	INSERT INTO #Routes(Nodeid,Nodetype,VisitDate,WeekID,monthval,Visitmonthyear,strMonthYear)
	SELECT DISTINCT  RouteNodeId,RouteNodetype,D.Date,D.WeekID,D.MonthVal,D.Visitmonthyear,D.strMonthYear
	FROM tblRoutePlanningVisitDetail(nolock) RP INNER JOIN #CoverageArea C ON C.NodeID=RP.CovAreaNodeID AND C.NodeType=RP.CovAreaNodeType CROSS JOIN #TotalDates D 

	UPDATE R SET flgPlanned=1 FROM #Routes R INNER JOIN tblRoutePlanningVisitDetail RP ON RP.RouteNodeId=R.NodeID AND RP.RouteNodetype=R.NodeType AND RP.VisitDate=R.VisitDate

	--SELECT * FROM #Routes --WHERE Visitdate=''

	CREATE TABLE #tblRoutePlan(RouteNodeID INT,RouteNodeType SMALLINT,RouteName VARCHAR(200),PlannedDate Date,StoreNodeID INT,flgDBRPlanned TINYINT,flgStorePlanned TINYINT,flgDBRActual TINYINT,flgStoreActual TINYINT DEFAULT 0,flgAttendance TINYINT DEFAULT 2,WeekID INT,MonthVal INT,MonthYear VARCHAR(15))

	INSERT INTO #tblRoutePlan(RouteNodeID,RouteNodeType,RouteName,PlannedDate,StoreNodeID,WeekID,MonthVal,MonthYear,flgStorePlanned)
	SELECT R.NodeID,R.NodeType,M.Descr,R.VisitDate,RM.StoreID,R.WeekID,R.monthval,R.strMonthYear,CASE WHEN flgPlanned=1 THEN 1 ELSE 0 END FROM #Routes R LEFT OUTER JOIN tblRouteCoverageStoreMapping(nolock) RM ON RM.RouteID=R.NodeID AND RM.RouteNodeType=R.NodeType AND GETDATE() BETWEEN RM.FromDate AND RM.ToDate LEFT OUTER JOIN tblCompanySalesStructureRouteMstr(nolock) M ON M.NodeID=R.NodeID AND M.NodeType=R.NodeType 


	SELECT * FROM #tblRoutePlan --WHERE StoreNodeID=1925
	
	PRINT '4=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	----CREATE TABLE #Route (RouteNodeID INT,RouteNodetype SMALLINT,PlannedDate Date,flgPlanned TINYINT DEFAULT 0 NOT NULL,CovFrqId INT,WeekId INT,FrqVal TINYINT)
	----INSERT INTO #Route(RouteNodeID,RouteNodetype,PlannedDate)
	----SELECT DISTINCT RouteNodeID,RouteNodeType,PlannedDate FROM #tblRoutePlan

	----INSERT INTO #Route(RouteNodeID,RouteNodetype,PlannedDate)
	----SELECT DISTINCT NodeID,NodeType,V.VisitDate FROM #Routes S INNER JOIN tblRoutePlanningVisitDetail(nolock) V ON V.RouteNodeId=S.NodeID AND V.RouteNodetype=S.NodeType
	----LEFT OUTER JOIN #Route R ON R.RouteNodeID=S.NodeID AND R.RouteNodetype=S.NodeType  AND V.VisitDate=R.PlannedDate  WHERE R.PlannedDate IS NULL
	
	PRINT '4.1=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')

	--------------------added by gaurav ON 04-Oct-19 to updated flgPlanned directly using query not from the function-----------------------------------

					--*************************** New Code ***************************--
	----UPDATE A SET A.CovFrqId=B.CovFrqId,A.WeekId=B.WeekId
	----FROM #Route A INNER JOIN tblRouteCoverage B ON A.RouteNodeID=B.RouteId AND A.RouteNodeType=B.NodeType 
	----WHERE (A.PlannedDate BETWEEN B.FromDate AND B.ToDate) AND DATEPART(dw,A.PlannedDate)=B.[Weekday]

	----UPDATE A SET A.FrqVal=B.value FROM #Route A INNER JOIN tblRoutePlanDetails B ON A.WeekId=B.WeekId AND A.CovFrqID=B.CovFrqID
	----UPDATE A SET A.flgPlanned=1 FROM #Route A INNER JOIN tblRoutePlanDetails B ON A.FrqVal=B.value AND A.CovFrqID=B.CovFrqID AND (A.PlannedDate BETWEEN WeekFrom AND WeekTo)
	--UPDATE A SET A.flgplanned=1 FROM #Route A INNER JOIN tblRoutePlanningVisitDetail(nolock) V ON V.RouteNodeId=A.RouteNodeID AND V.RouteNodetype=A.RouteNodetype AND A.PlannedDate=V.VisitDate

	--SELECT * FROM #Route
					--****************************************************************--
					
					/*--*************************** Old Code ***************************--
	UPDATE A SET flgPlanned=dbo.fnGetPlannedVisit(A.RouteNodeID,A.RouteNodeType,A.PlannedDate) FROM #Route A 

					--****************************************************************--*/
	--------------------------------------------------------------------------------------------------------------------------------------------
	--SELECT * FROM #Route
		

	PRINT '4.2=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	----UPDATE A SET flgStorePlanned=flgPlanned FROM #tblRoutePlan A INNER JOIN #Route B ON A.RouteNodeID=B.RouteNodeID AND A.RouteNodetype=B.RouteNodeType AND A.PlannedDate=B.PlannedDate

	PRINT '4.3=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	--SELECT * FROM #tblRoutePlan

	---UPDATE A SET flgStorePlanned=1 FROM #tblRoutePlan A  WHERE flgSpokePlanned=1

	----UPDATE A SET flgSpokeActual=1 FROM #tblRoutePlan A INNER JOIN tblVisitMaster(nolock) VM ON VM.CustomerNodeId=A.SpokeNodeID AND VM.CustomerNodeType=180 AND VM.VisitDate=CAST(PlannedDate AS DATE)
	PRINT '4.2=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	UPDATE A SET flgStoreActual=1 FROM #tblRoutePlan A INNER JOIN tblVisitMaster(nolock) VM ON VM.StoreID=A.StoreNodeID AND VM.VisitDate=CAST(PlannedDate AS DATE)

	--SELECT * FROM #tblRoutePlan WHERE RouteNodeID=47674
	PRINT '5=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	----SELECT DISTINCT VM.StoreID,VM.VisitDate INTO #ProductiveStores FROM tblVisitMaster VM INNER JOIN #tblRoutePlan R ON R.StoreNodeID=VM.StoreID AND R.PlannedDate=VM.VisitDate INNER JOIN tblOrderMaster OM ON OM.VisitID=VM.VisitID

	SELECT OM.StoreID,OM.OrderDate INTO #ProductiveStores FROM tblOrderMaster(nolock) OM INNER JOIN #tblRoutePlan R ON R.StoreNodeID=OM.StoreID AND R.PlannedDate=OM.OrderDate WHERE OM.OrderSourceID=1

	--UPDATE A SET flgAttendance=dbo.fnGetPersonAttendance(@PersonNodeID,PlannedDate) FROM #tblRoutePlan A WHERE PlannedDate<=CAST(GETDATE() AS DATE)

	--SELECT * FROM #ProductiveStores
	

	SELECT CAST(A.Datetime AS DATE) AttnDate,R.ReasonID,B.flgNoVisitOption INTO #MarkedDates FROM tblPersonAttendance(nolock) A INNER JOIN personAttreason(nolock) R ON A.PersonAttendanceID=R.PersonAttendanceID INNER JOIN tblMstrReasonsForNoVisit(nolock) B ON R.ReasonID=B.ReasonID INNER JOIN #tblRoutePlan RP ON RP.PlannedDate=CAST(A.Datetime AS DATE) WHERE A.PersonNodeID=@PersonNodeID

	UPDATE A SET flgStoreActual=1 FROM #tblRoutePlan A INNER JOIN #ProductiveStores P ON P.StoreID=A.StoreNodeID AND P.OrderDate=A.PlannedDate

	UPDATE A SET flgAttendance=0 FROM #tblRoutePlan A WHERE A.PlannedDate NOT IN (SELECT DISTINCT AttnDate FROM #MarkedDates)

	UPDATE A SET flgAttendance=1 FROM #tblRoutePlan A WHERE A.PlannedDate IN (SELECT DISTINCT AttnDate FROM #MarkedDates WHERE ReasonID IN (SELECT ReasonID FROM tblMstrReasonsForNoVisit(nolock) WHERE flgNoVisitOption=0)) AND PlannedDate<=CAST(GETDATE() AS DATE)

	----UPDATE A SET flgAttendance=1 FROM #tblRoutePlan A INNER JOIN (SELECT OrderDate FROM #ProductiveStores GROUP BY OrderDate HAVING COUNT(DISTINCT StoreID)>=7) X ON X.OrderDate=A.PlannedDate
	
	--WHERE PlannedDate<=CAST(GETDATE() AS DATE)

	PRINT '5.1=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	--SELECT DISTINCT PlannedDate,SpokeNodeID,flgSpokePlanned,flgSpokeActual INTO #SpokeDet FROM #tblRoutePlan

	SELECT DISTINCT PlannedDate,StoreNodeID,flgStorePlanned,flgStoreActual,flgAttendance INTO #StoreDet FROM #tblRoutePlan

	--SELECT * FROM #tblRoutePlan WHERE flgStorePlanned=1 AND RouteNodeID=47674

	--SELECT * FROM #SpokeDet
	PRINT '6=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	CREATE TABLE #tblReport(PlannedDate Date,DateStr VARCHAR(20),PlannedDayname VARCHAR(20),PlannedSpoke SMALLINT,ActualVisitedSpokes SMALLINT,PlannedStores SMALLINT,ActualVisitedStores SMALLINT,flgAttendance TINYINT,Color VARCHAR(10),LegendText VARCHAR(100),WeekID INT,MonthVal INT,flgPJPDone TINYINT DEFAULT 0,MonthYear VARCHAR(20),RouteName VARCHAR(200)) 

	--SELECT 1

	INSERT INTO #tblReport(PlannedDate,DateStr,PlannedDayname,flgAttendance,Color,LegendText,WeekID,MonthVal,flgPJPDone,MonthYear)
	SELECT PlannedDate,FORMAT(PlannedDate,'dd-MMM-yyyy'),FORMAT(PlannedDate,'ddd'),flgAttendance,CASE ISNULL(flgAttendance,0) WHEN 0 THEN '#FF0000' WHEN 1 THEN '#008000' WHEN 2 THEN '#FFBF00' END,CASE ISNULL(flgAttendance,0) WHEN 0 THEN 'Absent' WHEN 1 THEN 'Present' WHEN 2 THEN 'Leave' END,WeekID,MonthVal,0,MonthYear  
	FROM #tblRoutePlan ORDER BY PlannedDate,flgAttendance
	PRINT '7=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	--SELECT * FROM #tblReport
	--SELECT * FROM #tblRoutePlan

	UPDATE R SET RouteName=ISNULL(M.Descr,'NA') FROM #tblReport R INNER JOIN #Routes P ON P.VisitDate=R.PlannedDate INNER JOIN tblCompanySalesStructureRouteMstr(nolock) M ON M.NodeID=P.NodeID WHERE flgPlanned=1

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
