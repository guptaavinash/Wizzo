-- =============================================      
-- Author:  Avinash Gupta      
-- Create date: 27-Jun-2017      
-- Description:       
-- =============================================   

--    SpPDA_GetDSROutlets '359648069495987'
CREATE PROCEDURE [dbo].[SpPDA_GetDSROutlets]       
@PDACode VARCHAR(50)      
AS      
BEGIN      
 SET NOCOUNT ON;      
 --DECLARE @DeviceID INT      
 --SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMENumber OR PDA_IMEI_Sec=@IMENumber      
 --  PRINT @DeviceID  
 --SELECT @DeviceID  
  DECLARE @PersonNodeID INT,@PersonType SMALLINT,@Username VARCHAR(200)
  SELECT @PersonNodeID=NodeID,@PersonType=NodeType,@Username=ISNULL(P.Descr,'') FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
 
 SELECT VanID,CoverageAreaNodeID ,CoverageAreaNodetype ,CoverageArea,PersonNOdeID,PersonNodetype,Person INTO #CoverageArea FROM [fnGetLastPersonAssignedBasedOnPDACode](@PDACode,GETDATE())
  

  --- Used in NOn Van Sales
 ----SELECT P.NodeID,P.NodeType INTO #CoverageArea FROM tblSalesPersonMapping P INNER JOIN tblPDA_UserMapMaster M ON M.PersonID=P.PersonNodeID AND M.PersonType=P.PersonType       
 ----INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType       
 ----INNER JOIN tblPDAMaster PDA ON PDA.PDAID=M.PDAID      
 ----WHERE ISNULL(C.flgCoverageArea,0)=1 AND M.PDAID = @DeviceID AND      
 ----(CONVERT(VARCHAR, M.DateFrom, 112) <= CONVERT(VARCHAR, GETDATE(), 112))       
 ----AND (CONVERT(VARCHAR, ISNULL(M.DateTo, GETDATE()), 112) >= CONVERT(VARCHAR, GETDATE(), 112))       
 ----AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))   
 
 
    
    --SELECT * FROM #CoverageArea  
       
 -- Code to get the distributor List      
 ----CREATE TABLE #Distributor (NodeID INT,NodetYpe SMALLINT)      
 ----INSERT INTO #Distributor(NodeID,Nodetype)      
 ----SELECT DISTINCT PH.NodeID,PH.NodeType FROM tblCompanySalesStructureHierarchy PH INNER JOIN tblCompanySalesStructureHierarchy CH      
 ----ON CH.PHierId=PH.HierID INNER JOIN #CoverageArea C ON C.NodeID=CH.NodeID AND C.NodeType=CH.NodeType      
 ----INNER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=PH.NodeID AND DBR.NodeType=PH.NodeType      
 ----UNION      
 ----SELECT DISTINCT M.DHNodeID,M.DHNodeType FROM tblCompanySalesStructure_DistributorMapping M INNER JOIN #CoverageArea C      
 ----ON C.NodeID=M.SHNodeID AND C.NodeType=M.SHNodeType      
    --SELECT * from #Distributor  

	CREATE TABLE #Route (NodeID INT,NodetYpe SMALLINT)      
	---- INSERT INTO #Route(NodeID,Nodetype)      
	----SELECT DISTINCT RouteID,RouteType  from VwSalesHierarchy V INNER JOIN #CoverageArea C ON C.CoverageAreaNodeID=V.ComCoverageAreaID
	---- AND C.CoverageAreaNodetype=V.ComCoverageAreaType
	----UNION
	----SELECT DISTINCT VD.DBRRouteID,VD.RouteNodeType FROM VwAllDistributorHierarchy VD INNER JOIN #CoverageArea C ON C.CoverageAreaNodeID=VD.DBRCoverageID
	---- AND C.CoverageAreaNodetype=VD.DBRCoverageNodeType

	INSERT INTO #Route
	SELECT distinct CH.NodeID,CH.NodeType 
	FROM tblSalesPersonMapping P
	INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
	INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
	INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
	WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonNodeID AND P.PersonType=@PersonType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))


	----SELECT DISTINCT RouteNodeId,RouteNodeType FROM tblRouteCalendar(nolock) RC INNER JOIN tblCompanySalesStructureRouteMstr RM ON RM.NodeID=RC.RouteNodeId AND RC.RouteNodeType=RM.NodeType WHERE RC.SONodeId=@PersonNodeID AND RC.SONodeType=@PersonType 
PRINT 'BBB'

  CREATE TABLE #tblStoreList(StoreID VARCHAR(100),StoreIDDB INT,StoreName VARCHAR(200),LatCode NUMERIC(26,22),LongCode NUMERIC(26,22),DateAdded SMALLDATETIME,flgRemap TINYINT,RouteNodeID INT,RouteNodeType INT)      
 INSERT INTO #tblStoreList(StoreID,StoreIDDB,StoreName,LatCode,LongCode,DateAdded,flgRemap,RouteNodeID,RouteNodeType)    
 SELECT S.StoreID, S.StoreIDDB,S.OutletName,ISNULL(S.ActualLatitude,0.0),ISNULL(S.ActualLongitude,0.0),dbo.fncSetDateFormat(S.VisitStartTS), flgStoreValidated,D.NodeID,D.NodeType
 FROM tblPDASyncStoreMappingMstr S INNER JOIN #Route D ON D.NodeID=S.RouteID AND S.RouteNodeType=D.NodeType  
   
   PRINT 'AAA'
 --SELECT   'Welcome Shivam' As UserName    
SELECT @Username    Username
  
 SELECT AA.TotStoreAdded TotStoreAdded,BB.TodayStoreAdded AS TodayStoreAdded   
 FROM (SELECT COUNT(DISTINCT StoreID) AS TotStoreAdded FROM #tblStoreList) AA,  
 (SELECT COUNT(DISTINCT StoreID) AS TodayStoreAdded FROM #tblStoreList WHERE CAST(DateAdded AS DATE)=CAST(GETDATE() AS DATE)) BB       
     
      
 SELECT StoreID,StoreIDDB,StoreName,LatCode,LongCode,ISNULL(DateAdded,'01-Jan-1900') DateAdded,flgRemap,ISNULL(RouteNodeID,0) RouteNodeID,ISNULL(RouteNodeType,0) RouteNodeType  FROM #tblStoreList      
      
SELECT DISTINCT R.StoreIDDB,R.GrpQuestID,R.QstId,R.AnsControlTypeID,ISNULL(CAST(R.AnsTextVal AS VARCHAR(2000)),'0') AS Ans  FROM #tblStoreList V         
	INNER JOIN tblPDAOutletQstResponseMaster R ON R.StoreIDDB=V.StoreIDDB               
	INNER JOIN tblDynamic_PDAQuestMstr ON tblDynamic_PDAQuestMstr.QuestID=R.QstId WHERE  tblDynamic_PDAQuestMstr.ActiveQuest=1 AND R.AnsControlTypeID IN (1,2,3,4,11,12,13,18)AND flgRemap=3  	             
	UNION 
	SELECT DISTINCT R.StoreIDDB,R.GrpQuestID,R.QstId,R.AnsControlTypeID,ISNULL(CAST(R.AnsValID AS VARCHAR(2000)),'0') AS Ans  FROM #tblStoreList V         
	INNER JOIN tblPDAOutletQstResponseMaster R ON R.StoreIDDB=V.StoreIDDB               
	INNER JOIN tblDynamic_PDAQuestMstr ON tblDynamic_PDAQuestMstr.QuestID=R.QstId WHERE  tblDynamic_PDAQuestMstr.ActiveQuest=1 AND R.AnsControlTypeID IN (6,8)AND flgRemap=3  	             
	UNION              
	-- Multi Select              
	SELECT A.StoreIDDB,A.GrpQuestID,A.QstId,A.AnsControlTypeID,ISNULL(STUFF((SELECT '^' + CAST(R.AnsValId AS VARCHAR) FROM tblPDAOutletQstResponseMaster R where A.StoreIDDB=R.StoreIDDB AND A.GrpQuestID=R.GrpQuestID   FOR XML PATH('')) ,1,1,''),'0')  as Ans                 
FROM tblPDAOutletQstResponseMaster AS A              
INNER JOIN #tblStoreList V ON A.StoreIDDB=V.StoreIDDB                
INNER JOIN tblDynamic_PDAQuestMstr ON tblDynamic_PDAQuestMstr.QuestID=A.QstId              
WHERE  tblDynamic_PDAQuestMstr.ActiveQuest=1 AND A.AnsControlTypeID IN (5,15)  AND flgRemap=3              
GROUP BY A.StoreIDDB,A.GrpQuestID,A.QstId,A.AnsControlTypeID 
UNION  
SELECT A.StoreIDDB,A.GrpQuestID,A.QstId,A.AnsControlTypeID,            
ISNULL(STUFF((SELECT '^' + CAST(AnsValId AS VARCHAR) + '~' + CAST(AnsTextVal AS VARCHAR) FROM tblPDAOutletQstResponseMaster R where A.StoreIDDB=R.StoreIDDB AND A.GrpQuestID=R.GrpQuestID FOR XML PATH('')) ,1,1,''),'0')  as Ans          
FROM tblPDAOutletQstResponseMaster AS A              
INNER JOIN #tblStoreList V ON A.StoreIDDB=V.StoreIDDB                
INNER JOIN tblDynamic_PDAQuestMstr ON tblDynamic_PDAQuestMstr.QuestID=A.QstId              
WHERE  tblDynamic_PDAQuestMstr.ActiveQuest=1 AND A.AnsControlTypeID IN (14,16)   AND flgRemap=3              
GROUP BY A.StoreIDDB,A.GrpQuestID,A.QstId,A.AnsControlTypeID         
      
END 
