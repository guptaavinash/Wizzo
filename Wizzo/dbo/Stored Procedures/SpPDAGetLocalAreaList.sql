-- =============================================
-- Author:		Avinash Gupta
-- Create date: 16-Feb-2018
-- Description:	
-- =============================================
-- SpPDAGetLocalAreaList 'A908AF3A-AE7A-4BF8-92E0-670E493C627E'
CREATE Procedure [dbo].[SpPDAGetLocalAreaList] 
	@PDACode VARCHAR(50)
	
AS
BEGIN
	--DECLARE @DeviceID INT
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI
	DECLARE @PersonNodeID INT,@PersonType SMALLINT
	SELECT @PersonNodeID=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	
	SELECT distinct P.NodeID,P.NodeType INTO #PersonWorkingArea
	FROM tblSalesPersonMapping P 
	INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
	WHERE P.PersonNodeID=@PersonNodeID  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))

	-- SELECT * FROM #PersonWorkingArea

	CREATE TABLE #DBRList(NodeID INT,NodeType SMALLINT) 
	INSERT INTO #DBRList(NodeID,NodeType)
	SELECT DISTINCT DM.DHNodeID,DM.DHNodeType  FROM #PersonWorkingArea A INNER JOIN tblCompanySalesStructure_DistributorMapping DM ON DM.SHNodeID=A.NodeID AND DM.SHNodeType=A.NodeType AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate  AND DM.DHNodeType=150

	--SELECT * FROM #DBRList
	
	CREATE TABLE #CityList(StateID INT,State VARCHAR(200),CityID INT,City VARCHAR(200),LocalAreaID INT,LocalArea VARCHAR(200))
	
	SELECT SH.GeoNodeID,SH.GeoNodeType INTO #StateList FROM tblSalesHier_GeoHierMapping SH INNER JOIN #DBRList D ON D.NodeID=SH.SalesAreaNodeID AND D.Nodetype=SH.SalesAreaNodetype WHERE SalesAreaNodetype=150 AND GeoNodetype=310 AND GETDATE() BETWEEN SH.FromDate AND SH.ToDate -- Distributor and State

	--SELECT * FROM #StateList

	INSERT INTO  #CityList(StateID,State,CityID,City,LocalAreaID,LocalArea)
	SELECT DISTINCT V.StateNodeId,LTRIM(RTRIM(V.State)),V.CityNodeId,RTRIM(LTRIM(V.City)),L.LocalAreaNodeID,l.LocalArea FROM [dbo].[vwLocationHierarchy] V INNER JOIN #StateList S ON S.GeoNodeID=V.StateNodeId AND S.GeoNodeType=V.StateNodeType INNER JOIN tblLocationMaster L ON l.CityID=V.CityNodeId

	----IF EXISTS(SELECT 1 FROM #CityList)
	----INSERT INTO  #CityList(StateID,State,CityID,City)
	----SELECT 0,'Select',0,'Other'
	
	SELECT * FROM  #CityList ORDER BY LOcalArea

END


