-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [SpPDAGetStoredetailforcontactupdate] '86FA0580-EC50-4D29-A401-D5E2A5A86C7B'
CREATE PROCEDURE [dbo].[SpPDAGetStoredetailforcontactupdate]--'86FA0580-EC50-4D29-A401-D5E2A5A86C7B'
	@PDACode VARCHAR(50)
AS
BEGIN
	DECLARE @PersonNodeID Integer=0 
	DECLARE @PersonNodeType Integer=0 

	SELECT @PersonNodeID=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	SELECT @PersonNodetype=PersonType FROM tblSalesPersonMapping WHERE PersonNodeID=@PersonNodeID

	PRINT '@PersonNodeID=' + CAST(@PersonNodeID AS VARCHAR)

	CREATE TABLE #DSRStoreList (StoreID INT,RouteNodeID INT,RouteNodeType SMALLINT)
	INSERT INTO #DSRStoreList(StoreID,RouteNodeID,RouteNodeType)
	SELECT RS.StoreId,R.RouteNodeId,R.RouteNodeType FROM tblRoutePlanningVisitDetail R INNER JOIN tblRouteCoverageStoreMapping RS ON RS.RouteID=R.RouteNodeId,(SELECT StoreID,MAX(VisitDate) LastAssignDate FROM tblRoutePlanningVisitDetail V INNER JOIN tblRouteCoverageStoreMapping RS ON RS.RouteID=V.RouteNodeId WHERE CAST(GETDATE() AS DATE) BETWEEN RS.FromDate AND RS.ToDate GROUP BY StoreId) X WHERE X.StoreId=RS.StoreId AND X.LastAssignDate=R.VisitDate AND R.DSENodeId=@PersonNodeID AND R.DSENodeType=@PersonNodetype AND CAST(GETDATE() AS DATE) BETWEEN RS.FromDate AND RS.ToDate

	--SELECT DISTINCT StoreId,RouteNodeId,RouteNodeType FROM tblRouteCalendar RC INNER JOIN tblCompanySalesStructureRouteMstr RM ON RM.NodeID=RC.RouteNodeId AND RC.RouteNodeType=RM.NodeType WHERE RC.SONodeId=@PersonNodeID AND RC.SONodeType=@PersonNodetype  --AND RC.VisitDate=CAST(GETDATE() AS DATE)
	   	
 	CREATE TABLE #StoreNeedContactupdate(StoreID INT,StoreName Varchar(200),StoreLat Decimal(10,8),StoreLong Decimal(10,8),Ownername VARCHAR(200),Contactnumber BIGINT,Address VARCHAR(500),Reasonforupdate VARCHAR(200),RouteNodeID INT,RouteNodeType SMALLINT)

	INSERT INTO #StoreNeedContactupdate(StoreID,StoreName,StoreLat,StoreLong,Ownername,Contactnumber,[Address],Reasonforupdate,RouteNodeID,RouteNodeType)


	SELECT DISTINCT S.StoreID,S.StoreName,S.[Lat Code] AS StoreLat,S.[Long Code] AS StoreLong,C.FName,C.MobNo ,A.StoreAddress1,ISNULL(RC.REASNCODE_LVL2NAME,'InCorrect Number'),R.RouteNodeId,R.RouteNodeType FROM tblStoreListForValidation V INNER JOIN tblStoreMaster S ON S.StoreID=V.StoreID LEFT OUTER JOIN [tblReasonCodeMstr] RC ON RC.ReasonCodeID=V.ReasonID AND RC.REASNFOR=1 INNER JOIN #DSRStoreList R ON R.StoreID=S.StoreId LEFT OUTER JOIN tblOutletAddressDet A ON A.StoreID=S.StoreID AND A.OutAddTypeID=1 LEFT OUTER JOIN tblOutletContactDet C ON C.StoreID=S.StoreID AND C.ContactType=1
	 WHERE V.StoreID NOT IN (SELECT StoreID FROM tblStoreContactUpdate WHERE CAST(TimestampIns AS DATE)<CAST(GETDATE() AS DATE))

	SELECT * FROM #StoreNeedContactupdate 
END
