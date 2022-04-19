---[spGetStoreListByRoute] 1,220,0,0
CREATE proc [dbo].[spGetStoreListByRoute] 
@SONodeId int,
@SONodeType int,
@RouteNodeId int,
@RouteNodeType int
as
begin

select * into #vwSalesHierarchy from vwSalesHierarchy 
SELECT distinct b.StoreID,C.SOName as SO,cv.Descr as Route,r.Descr as Beat,b.StoreCode,b.StoreName,isnull(b.isDiscountApplicable,0) as isDiscountApplicable FROM tblRouteCalendar a join tblStoreMaster b on a.StoreId=b.StoreID join #vwSalesHierarchy c on c.SONodeid=a.SONodeId
and c.SONodeType=a.SONodeType 
JOIN tblCompanySalesStructureRouteMstr r on r.NodeID=a.RouteNodeId
and r.NodeType=a.RouteNodeType
JOIN tblCompanySalesStructureCoverage cv on cv.NodeID=a.covnodeid
and cv.NodeType=a.covnodeType
where a.SONodeId=@SONodeId and a.SONodeType=@SONodeType and 
((RouteNodeId=@RouteNodeId and RouteNodeType=@RouteNodeType) or @RouteNodeId=0)

end