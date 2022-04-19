CREATE proc [dbo].[spGetRouteListMstr]
@SONodeId int,
@SONodeType int
as
begin

select distinct RouteNodeId,RouteNodeType,b.Code,b.Descr from tblRouteCalendar A join tblCompanySalesStructureRouteMstr  b on A.RouteNodeId=b.NodeID
and A.RouteNodeType=b.NodeType where a.SONodeId=@SONodeId and a.SONodeType=@SONodeType


end