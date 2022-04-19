-- =============================================
-- Author:		Avinash Gupta
-- Create date: 18-Sep-2021
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpPDASendNotification] 
	
AS
BEGIN
	
	--SELECT * FROM tblStoreListForValidation

	CREATE TABLE #DSRStoreList (StoreID INT,RouteNodeID INT,RouteNodeType SMALLINT,RouteName VARCHAR(100),PersonNodeID INT,PersonNodeType SMALLINT)
	INSERT INTO #DSRStoreList(StoreID,RouteNodeID,RouteNodeType,RouteName,PersonNodeID,PersonNodeType)
	SELECT DISTINCT SM.StoreId,RouteNodeId,RC.RouteNodetype,RM.Descr,RC.DSENodeId,RC.DSENodeType FROM tblRoutePlanningVisitDetail RC INNER JOIN tblCompanySalesStructureRouteMstr RM ON RM.NodeID=RC.RouteNodeId AND RC.RouteNodeType=RM.NodeType
	INNER JOIN tblRouteCoverageStoreMapping SM ON SM.RouteID=RC.RouteNodeId AND SM.RouteNodeType=RC.RouteNodetype AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate
	INNER JOIN tblStoreListForValidation S ON S.StoreID=SM.StoreId AND S.StoreID NOT IN (SELECT StoreID FROM tblStoreContactUpdate)
	WHERE RC.VisitDate=CAST(GETDATE() AS DATE)


	--SELECT * FROM #DSRStoreList

	

	SELECT DISTINCT P.NodeID PersonNodeID,P.NodeType PersonNodeType,P.Descr Personname,P.FCMTokenNo FCMToken,'You have stores in your current beat ' + S.RouteName + ' which need to be updated. The list is provided here and when you visit the store, please remember to get updated phone number from retailer.' MessageText FROM tblMstrPerson P INNER JOIN #DSRStoreList S ON P.NodeID=S.PersonNodeID AND P.NodeType=S.PersonNodeType WHERE P.FCMTokenNo IS NOT NULL 
	--WHERE P.FCMTokenNo IS NOT NULL
END
