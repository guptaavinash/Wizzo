

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec [spGetLastKnownPosition] 0,0,'30-Nov-2021'
CREATE PROCEDURE [dbo].[spGetLastKnownPosition]
@NodeID INT=0,
@NodeType INT=0,
@RptDate DATE,
@LoginId INT=0	
AS
BEGIN
	
	CREATE TABLE #tmpRsltWithFullHierarchy(ZoneId INT,ZoneNodeType INT,Zone VARCHAR(200),RegionId INT,RegionNodeType INT,Region VARCHAR(200),ASMAreaId INT,ASMAreaNodeType INT,ASMArea VARCHAR(200),SOAreaId INT,SOAreaNodeType INT,SOArea VARCHAR(200),CovAreaId INT,CovAreaNodeType INT,CovArea VARCHAR(200),RouteId INT,RouteNodeType INT,Route VARCHAR(200),SalesmanNodeId INT,SalesmanNodeType INT,Salesman VARCHAR(200))
		
	SELECT * INTO #CompHier FROm VwCompanySalesHierarchy
	
	INSERT INTO #tmpRsltWithFullHierarchy(ZoneId,Zone,RegionId,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaId,SOAreaNodeType,SOArea,CovAreaId,CovAreaNodeType,CovArea)
	SELECT ZoneID,Zone,RegionID,RegionNodeType,Region,ASMAreaId,ASMAreaNodeType,ASMArea,SOAreaID,SOAreaNodeType,SOArea,DSRAreaID,DSRAreaNodeType, DSRArea
	FROM #CompHier vw 
		
	UPDATE A SET A.SalesmanNodeId=MP.NodeId,A.SalesmanNodeType=Mp.NodeType,A.Salesman=MP.Descr
	FROM #tmpRsltWithFullHierarchy A LEFT JOIN tblSalesPersonMapping SP ON A.CovAreaId=SP.NodeId AND A.CovAreaNodeType=SP.NodeType
	INNER JOIN tblMstrPerson MP ON SP.PersonNodeId=MP.NodeID
	WHERE (@RptDate BETWEEN CAST(SP.FromDate AS DATE) AND CAST(SP.ToDate AS DATE)) AND (@RptDate BETWEEN CAST(MP.FromDate AS DATE) AND CAST(MP.ToDate AS DATE))
	--SELECT * FROM #tmpRsltWithFullHierarchy

	CREATE TABLE #DSRList(CoverageAreaNodeID INT,CoverageAreaNodeType SMALLINT,CoverageArea VARCHAR(500),PersonNodeID INT,PersonNodeType SMALLINT,PersonName VARCHAR(200))
	
	IF @NodeType=0
	BEGIN
		INSERT INTO #DSRList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName)
		SELECT DISTINCT CovAreaId,CovAreaNodeType,CovArea,SalesmanNodeId,SalesmanNodeType,Salesman FROM #tmpRsltWithFullHierarchy
	END
	ELSE IF @NodeType=95
	BEGIN
		INSERT INTO #DSRList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName)
		SELECT DISTINCT CovAreaId,CovAreaNodeType,CovArea,SalesmanNodeId,SalesmanNodeType,Salesman FROM #tmpRsltWithFullHierarchy WHERE ZoneId=@NodeID
	END
	ELSE IF @NodeType=100
	BEGIN
		INSERT INTO #DSRList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName)
		SELECT DISTINCT CovAreaId,CovAreaNodeType,CovArea,SalesmanNodeId,SalesmanNodeType,Salesman FROM #tmpRsltWithFullHierarchy WHERE RegionId=@NodeID
	END
	ELSE IF @NodeType=110
	BEGIN
		INSERT INTO #DSRList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName)
		SELECT DISTINCT CovAreaId,CovAreaNodeType,CovArea,SalesmanNodeId,SalesmanNodeType,Salesman FROM #tmpRsltWithFullHierarchy WHERE ASMAreaId=@NodeID
	END
	ELSE IF @NodeType=120
	BEGIN
		INSERT INTO #DSRList(CoverageAreaNodeID,CoverageAreaNodeType,CoverageArea,PersonNodeID,PersonNodeType,PersonName)
		SELECT DISTINCT CovAreaId,CovAreaNodeType,CovArea,SalesmanNodeId,SalesmanNodeType,Salesman FROM #tmpRsltWithFullHierarchy WHERE SOAreaId=@NodeID
	END
	--SELECT * FROM #DSRList
	

	SELECT D.PersonName AS Salesman,D.CoverageArea,D.CoverageAreaNodeID,D.CoverageAreaNodeType,VM.VisitId,VM.EntryPersonNodeId,VM.DeviceVisitStartTS,VM.StoreId,VM.VisitLatitude, VM.VisitLongitude,VM.RouteID,VM.RouteType RouteNodeType INTO #tblVisitMaster 
	FROM tblVisitMaster VM INNER JOIN #DSRList D ON VM.EntryPersonNodeId=D.PersonNodeId
	WHERE VM.VisitDate=@RptDate
	--select * from #tblVisitMaster ORDER BY SalesPersonID,DeviceVisitStartTS

	CREATE TABLE #Tmp(SalesmanNodeID INT,CoverageAreaNodeID INT,CoverageAreaNodeType INT,DSR NVARCHAR(500),LASTVisitTime TIME,StoreId INT,StoreName NVARCHAR(200),VisitLatitude DECIMAL(27,24),VisitLongitude DECIMAL(27,24),RouteId INT,RouteNodeType INT,ActCalls INT,ProdCalls INT,SalesValue FLOAT)

	INSERT INTO #Tmp(SalesmanNodeID,CoverageAreaNodeID,CoverageAreaNodeType,DSR,LASTVisitTime,ActCalls,ProdCalls,SalesValue)
	SELECT VM.EntryPersonNodeId,VM.CoverageAreaNodeID,VM.CoverageAreaNodeType,VM.Salesman,MAX(DeviceVisitStartTS) AS LASTVisitTime,0,0,0
	FROM #tblVisitMaster VM WHERE ISNULL(VisitLatitude,0)<>0
	GROUP BY VM.EntryPersonNodeId,VM.CoverageAreaNodeID,VM.CoverageAreaNodeType,VM.CoverageArea,VM.Salesman

	UPDATE A SET A.ActCalls=B.ActCalls
	FROM #Tmp A INNER JOIN (SELECT EntryPersonNodeId,COUNT(VisitId) ActCalls FROM #tblVisitMaster GROUP BY EntryPersonNodeId) B ON A.SalesmanNodeID=B.EntryPersonNodeId

	UPDATE A SET A.ProdCalls=B.ProdCalls,A.SalesValue=B.SalesValue
	FROM #Tmp A INNER JOIN (SELECT OM.EntryPersonNodeId,COUNT(DISTINCT OM.VisitId) ProdCalls,ROUND(SUM(OD.NetLineOrderVal),0) SalesValue
	FROM tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId WHERE OM.OrderDate=@RptDate GROUP BY OM.EntryPersonNodeId) B ON A.SalesmanNodeID=B.EntryPersonNodeId

	UPDATE A SET A.StoreId=SM.StoreId,A.StoreName=SM.StoreName ,A.VisitLatitude=VM.VisitLatitude,A.VisitLongitude=VM.VisitLongitude,A.RouteId=VM.RouteID,A.RouteNodeType=VM.RouteNodeType 
	FROM #Tmp A INNER JOIN #tblVisitMaster VM ON A.LASTVisitTime=VM.DeviceVisitStartTS AND A.SalesmanNodeID=VM.EntryPersonNodeId
	INNER JOIN tblStoreMaster SM ON VM.StoreId=SM.StoreId
	--SELECT * FROM #Tmp
	
	SELECT SalesmanNodeID,CoverageAreaNodeID,CoverageAreaNodeType,DSR,LASTVisitTime, StoreId,StoreName,VisitLatitude,VisitLongitude,ActCalls,ProdCalls,SalesValue
	FROM #Tmp --where StoreId=0
	ORDER BY SalesmanNodeID
END




