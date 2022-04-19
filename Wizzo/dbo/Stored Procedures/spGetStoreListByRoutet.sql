---[spGetStoreListByRouteT] 1,220,0,0
CREATE proc [dbo].[spGetStoreListByRoutet] 
@SONodeId int,
@SONodeType int,
@RouteNodeId int,
@RouteNodeType int
as
begin

select * into #vwSalesHierarchy from vwSalesHierarchy 
SELECT distinct b.StoreID,C.SOName as SO
--,cv.Descr as Coverage,r.Descr as Route

,b.StoreCode,b.StoreName,isnull(b.isDiscountApplicable,0) as isDiscountApplicable FROM tblRouteCalendar a join tblStoreMaster b on a.StoreId=b.StoreID join #vwSalesHierarchy c on c.SONodeid=a.SONodeId
and c.SONodeType=a.SONodeType 
--JOIN tblCompanySalesStructureRoute r on r.NodeID=a.RouteNodeId
--and r.NodeType=a.RouteNodeType
--JOIN tblCompanySalesStructureCoverage cv on cv.NodeID=a.CovNodeId
--and cv.NodeType=a.CovNodeType
where a.SONodeId=@SONodeId and a..SONodeType=@SONodeType and 
((RouteNodeId=@RouteNodeId and RouteNodeType=@RouteNodeType) or @RouteNodeId=0)

end