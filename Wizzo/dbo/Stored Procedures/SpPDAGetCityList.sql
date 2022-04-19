-- =============================================
-- Author:		Avinash Gupta
-- Create date: 16-Feb-2018
-- Description:	
-- =============================================
-- SpPDAGetCityList 'BA02A21A-26FE-4D4B-89C6-B81CDC633175'
CREATE PROCEDURE [dbo].[SpPDAGetCityList] 
	@PDACode VARCHAR(50)
	
AS
BEGIN
	--DECLARE @DeviceID INT
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI
	PRINT '1=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')

	DECLARE @PersonNodeID INT,@PersonType SMALLINT
	SELECT @PersonNodeID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	
	SELECT distinct P.NodeID,P.NodeType INTO #PersonWorkingArea
	FROM tblSalesPersonMapping P 
	INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
	WHERE P.PersonNodeID=@PersonNodeID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))

	--SELECT * FROM #PersonWorkingArea

	CREATE TABLE #DBRList(NodeID INT,NodeType SMALLINT) 
	INSERT INTO #DBRList(NodeID,NodeType)
	SELECT DISTINCT B.*  FROM #PersonWorkingArea A CROSS APPLY dbo.fnGetDistributorList(A.NodeID,A.NodeType,GETDATE()) B
	--SElECT * FROM #DBRList
	PRINT '2=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	CREATE TABLE #CityList(RegionID INT DEFAULT 0,StateID INT,State VARCHAR(200),CityID INT,City VARCHAR(200),CityDefault TINYINT DEFAULT 0)
	
	--SELECT NodeID GeoNodeID,NodeType GeoNodeType,RegionID INTO #StateList FROM tblLocLvl2 S 
	SELECT L.RegionID,SH.GeoNodeID,SH.GeoNodeType INTO #StateList FROM tblSalesHier_GeoHierMapping(nolock) SH INNER JOIN #DBRList D ON D.NodeID=SH.SalesAreaNodeID AND D.Nodetype=SH.SalesAreaNodetype 
	INNER JOIN tblLocLvl2 L ON L.NodeID=GeoNodeId AND L.NodeType=GeoNodeType
	WHERE SalesAreaNodetype=150 AND GeoNodetype=310 AND GETDATE() BETWEEN SH.FromDate AND SH.ToDate -- Distributor and State
	PRINT '3=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	--SELECT * FROM #StateList

	INSERT INTO  #CityList(RegionID,StateID,State,CityID,City)
	SELECT DISTINCT ISNULL(S.RegionID,0),V.StateNodeId,LTRIM(RTRIM(V.State)),V.CityNodeId,RTRIM(LTRIM(V.City)) FROM [dbo].[vwLocationHierarchy] V INNER JOIN #StateList S ON S.GeoNodeID=V.StateNodeId AND S.GeoNodeType=V.StateNodeType

	IF EXISTS(SELECT 1 FROM #CityList)
	INSERT INTO  #CityList(StateID,State,CityID,City)
	SELECT 0,'Select',0,'Other'
	
	SELECT * FROM  #CityList
	PRINT '4=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
END
