-- =============================================
-- Author:		Avinash Gupta
-- Create date: 
-- Description:	
-- =============================================
-- SPRptBrandVisibilityReport '31-Jan-2022',4492,''
CREATE PROCEDURE [dbo].[SPRptBrandVisibilityReport] 
	@RptDate Date,
	@LoginId INT,
	@strSalesHierarchy VARCHAR(5000)=''
AS
BEGIN
	DECLARE @StartDate DATE =DATEADD(month,MONTH(@RptDate)-1,DATEADD(year,YEAR(@RptDate)-1900,0))
	DECLARE @EndDate DATE =EOMONTH(@StartDate) 

	SELECT  TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1) Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @StartDate) INTO #tblDates
	FROM    sys.all_objects a CROSS JOIN sys.all_objects b


	CREATE TABLE #tmpRsltWithFullHierarchy(ZoneId INT,ZoneNodeType INT,Zone VARCHAR(200),RegionNodeId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,Salesman VARCHAR(200),flgActive TINYINT DEFAULT 0 NOT NULL)

	INSERT INTO #tmpRsltWithFullHierarchy(ZoneId,ZoneNodeType,Zone,RegionNodeId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea, RouteId,RouteNodeType,Route)
	EXEC [spRptGetFullSalesHierarchyBasedonLogin] @LoginId,0,0,@strSalesHierarchy

	DELETE A FROM #tmpRsltWithFullHierarchy A INNER JOIN tblSalesPersonMapping(nolock) SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)
	INNER JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID WHERE MP.flgSFAUser<>1
	
	UPDATE A SET A.SalesmanNodeId=MP.NodeId,A.SalesmanNodeType=Mp.NodeType,A.Salesman=ISNULL(MP.Descr,'Vacant')
	FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping(nolock) SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)
	LEFT JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID

	--SELECT * FROM #tmpRsltWithFullHierarchy

	SELECT DISTINCT R.CovAreaId,R.CovAreaNodeType,R.ASMAreaId,R.ASMAreaNodeType,R.RouteId,R.RouteNodeType,R.Route,RC.VisitDate AS RptDate,1 AS FlgPlanned INTO #tmpRoute
	FROM tblRoutePlanningVisitDetail(nolock) RC INNER JOIN #tmpRsltWithFullHierarchy R ON RC.RouteNodeId=R.RouteId AND RC.RouteNodetype=R.RouteNodeType
	WHERE MONTH(RC.VisitDate)=MONTH(@RptDate) AND YEAR(RC.VisitDAte)=YEAR(@RptDate)

	CREATE TABLE #Final(SalesmanNodeID INT,SalesmanNodeType SMALLINT,CoverageAreaId INT,CoverageAreaNodeType INT,StoreID INT,Region VARCHAR(200),ASMArea VARCHAR(200),SOArea VARCHAR(200),Salesman VARCHAR(200),StoreCode VARCHAR(100),Storename VARCHAR(200),Ownername VARCHAR(200),MobNo BIGINT,State VARCHAR(200),City VARCHAR(200),VisitDate Date,AssignRoute VARCHAR(200),VisitedRoute VARCHAR(200),[PreMerchandisingImage] VARCHAR(500),[PostMerchandisingImage] VARCHAR(500))

	INSERT INTO #Final(SalesmanNodeID,SalesmanNodeType,CoverageAreaId,CoverageAreaNodeType,Region,ASMArea,SOArea,Salesman,StoreID,StoreCode,Storename,State,City,Ownername,MobNo,VisitDate,[PreMerchandisingImage])
	SELECT DISTINCT SalesmanNodeId,SalesmanNodeType,CovAreaId,CovAreaNodeType,F.Region,ASMArea,SOArea,Salesman,SM.StoreID,SM.StoreCode,SM.StoreName,A.State,A.City,C.FName,C.MobNo,VM.VisitDate,'http://103.107.67.196/SFAImages/RajTraders_Live/'+ I.Imagename FROM tblVisitStockImage(nolock) I INNER JOIN tblVisitMaster(nolock) VM ON VM.VisitID=I.VisitID INNER JOIN tblStoreMaster(nolock) SM ON SM.StoreID=VM.StoreID INNER JOIN #tmpRsltWithFullHierarchy F ON F.SalesmanNodeID=VM.EntryPersonNodeID AND F.RouteId=VM.RouteID AND F.RouteNodeType=VM.RouteType 
	LEFT OUTER JOIN tblOutletContactDet(nolock) C ON C.StoreID=SM.StoreID AND C.ContactType=1
	LEFT OUTER JOIN tblOutletAddressDet(nolock) A ON A.StoreID=SM.StoreID AND A.OutAddTypeID=1
	WHERE Imagetype=3 AND MONTH(VM.VisitDate)=MONTH(@RptDate) AND YEAR(VM.VisitDate)=YEAR(@RptDate)

	UPDATE F SET [PostMerchandisingImage]='http://103.107.67.196/SFAImages/RajTraders_Live/'+ I.Imagename FROM #Final F 
	 INNER JOIN tblVisitMaster(nolock) VM ON VM.EntryPersonNodeID=F.SalesmanNodeID AND F.VisitDate=VM.VisitDate  INNER JOIN tblVisitStockImage(nolock) I ON VM.VisitID=I.VisitID INNER JOIN #tmpRsltWithFullHierarchy FH ON FH.SalesmanNodeID=VM.EntryPersonNodeID AND FH.RouteId=VM.RouteID AND FH.RouteNodeType=VM.RouteType AND F.StoreID=VM.StoreID WHERE Imagetype=4 AND MONTH(VM.VisitDate)=MONTH(@RptDate) AND YEAR(VM.VisitDate)=YEAR(@RptDate)

	 UPDATE F SET AssignRoute= COALESCE(AssignRoute+',' , '') + Route FROM #Final F INNER JOIN #tmpRoute T ON T.CovAreaId=F.CoverageAreaId AND T.CovAreaNodeType=F.CoverageAreaNodeType AND T.RptDate=F.VisitDate

	UPDATE F SET VisitedRoute= COALESCE(VisitedRoute+',' , '') + R.Descr FROM #Final F INNER JOIN tblVisitMaster T ON T.EntryPersonNodeID=F.SalesmanNodeID AND T.VisitDate=F.VisitDate INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=T.RouteID 

	
	SELECT Region ,ASMArea ,SOArea ,Salesman ,StoreCode ,Storename,Ownername ,MobNo ,State ,City ,VisitDate ,AssignRoute ,VisitedRoute ,[PreMerchandisingImage] ,[PostMerchandisingImage] FROM #Final ORDER BY Region,ASMArea,SOArea,SalesmanNodeID,VisitDate

END
