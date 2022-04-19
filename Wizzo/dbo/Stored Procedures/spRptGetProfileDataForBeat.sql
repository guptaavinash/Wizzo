

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spRptGetProfileDataForBeat]48654,140
CREATE PROCEDURE [dbo].[spRptGetProfileDataForBeat] 
@SalesAreaNodeId INT,
@SalesAreaNodeType INT
AS
BEGIN
	DECLARE @SalesmanName VARCHAR(100)
	DECLARE @SalesmanTarget VARCHAR(10)
	DECLARE @SalesmanAch  VARCHAR(10)
	DECLARE @BeatName VARCHAR(200)
	DECLARE @BeatFrequency VARCHAR(200)
	DECLARE @LastVisited DATE
	DECLARE @RptDate DATE
	SELECT @RptDate=DATEADD(dd,-1,GETDATE())

	SELECT * INTO #tmpBeatProfileData FROM tblRptBeatProfileData WHERE AreaNodeId=@SalesAreaNodeId AND AreaNodeType=@SalesAreaNodeType
	--SELECT * FROM tblRptBeatProfileData

	SELECT @BeatName=dbo.ConvertFirstLetterinCapital(AreaName),@BeatFrequency=dbo.ConvertFirstLetterinCapital(VisitFrequency),@LastVisited=LastVisited,@SalesmanName=dbo.ConvertFirstLetterinCapital(Personname),@SalesmanTarget=SalesmanSalesTarget,@SalesmanAch=SalesmanSalesAch FROM #tmpBeatProfileData
	PRINT 'Grv'
	CREATE TABLE #ProfileData(HeaderName VARCHAR(200),Value VARCHAR(200),HeaderId INT,GroupID INT,GroupName VARCHAR(200),flgForLink TINYINT)

	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 1,'Name',@SalesmanName,1,'Salesman Details',0
	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 2,'Target/Ach',CAST(@SalesmanTarget AS VARCHAR) + '/' + CAST(@SalesmanAch AS VARCHAR),1,'Salesman Details',0
	


	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 3,'Name',@BeatName,2,'Route Detail',0
	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 4,'Frequency',@BeatFrequency,2,'Route Detail',0
	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 5,'Last Visited',FORMAT(@LastVisited,'dd-MMM-yy'),2,'Route Detail',0

	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 6,'#Visits',COUNT(DISTINCT StoreId),3,'Visit Detail',1 FROM #tmpBeatProfileData WHERE IsVisitedOnLastVisit=1
	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 7,'#Productive',COUNT(DISTINCT StoreId),3,'Visit Detail',1 FROM #tmpBeatProfileData WHERE IsProductiveOnLastVisit=1
	--SELECT 7,'#Productive',SUM(NoOfProdVisits_MTD),3,'Visit Detail',1 FROM #tmpBeatProfileData 

	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 8,'Total Sales',SUM(SaleOnLastVisit),3,'Visit Detail',1 FROM #tmpBeatProfileData 
	--SELECT 8,'Total Sales',SUM(SalesQty),3,'Visit Detail',1 FROM #tmpBeatProfileData 

	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 9,'#Active',COUNT(DISTINCT StoreId),4,'Store Detail',1 FROM #tmpBeatProfileData --WHERE IsPlanned=1
	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 10,'#Vol(MTD)',SUM(MTDSales),4,'Store Detail',0 FROM #tmpBeatProfileData 
	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 11,'#Covered(P4W)',COUNT(DISTINCT StoreId),4,'Store Detail',1 FROM #tmpBeatProfileData WHERE Covered_P4W=1
	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 12,'#Productive(P4W)',COUNT(DISTINCT StoreId),4,'Store Detail',1 FROM #tmpBeatProfileData WHERE Productive_P4W=1
	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 13,'#UnProductive(P4W)',COUNT(DISTINCT StoreId),4,'Store Detail',1 FROM #tmpBeatProfileData WHERE NonProductive_P4W=1
	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 14,'#UnProductive(P3M)',COUNT(DISTINCT StoreId),4,'Store Detail',1 FROM #tmpBeatProfileData WHERE NonProductive_P3M=1
	INSERT INTO #ProfileData(HeaderId,HeaderName,Value,GroupID,GroupName,flgForLink)
	SELECT 15,'#UnProductive Star Outlet (P4W)',COUNT(DISTINCT StoreId),4,'Store Detail',1 FROM #tmpBeatProfileData WHERE NonProductive_P4W=1 AND flgStarOutlets=1
	
	--SELECT 7,'# Stores not covered in past 2 visits',COUNT(DISTINCT StoreId),1 FROM #tmpBeatProfileData WHERE NotCoveredInPast2Visits=1

	SELECT FORMAT(@RptDate,'dd-MMM-yy') AS ReportAsOn

	SELECT * FROM #ProfileData ORDER BY HeaderId

END


