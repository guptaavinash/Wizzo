-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sppopulaterouteCalenderforsfauser] 
	@DataDate Date
AS
BEGIN
	DELETE R FROM tblRouteCalendar R  WHERE VisitDate=@DataDate 
	INSERT INTO tblRouteCalendar(SONodeId,SONodeType,DistNodeId,DistNodeType,StoreId,SectorId,RouteNodeId,RouteNodeType,CovNodeId,CovNodeType,VisitDate,FileSetId,TimeStamps,FrqTypeId,SOAreaNodeId,SOAreaNodeType)
	SELECT DISTINCT rv.DSENodeId,RV.DSENodeType,SM.DistNodeId,SM.DistNodeType,SM.StoreID,1,RS.RouteID,RS.RouteNodeType,rv.CovAreaNodeID,rv.CovAreaNodeType,@DataDate,0,GETDATE(),0,ph.PNodeID,ph.PNodeType
	FROM  tblRoutePlanningVisitDetail RV  INNER JOIN tblRouteCoverageStoreMapping RS ON RS.RouteID=RV.RouteNodeId AND RS.RouteNodeType=RV.RouteNodetype AND CAST(GETDATE() AS DATE) BETWEEN RS.FromDate AND RS.ToDate INNER JOIN tblStoreMaster SM ON SM.StoreID=RS.StoreID   
	join tblCompanySalesStructureHierarchy ph on ph.NodeID=rv.CovAreaNodeID
	and ph.NodeType=rv.CovAreaNodeType
	AND CAST(GETDATE() AS DATE) BETWEEN ph.VldFrom AND ph.VldTo
	WHERE  VisitDate=@DataDate 
END
