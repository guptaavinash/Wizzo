



CREATE FUNCTION [dbo].[fnGetRouteListWithName](@NodeId int,@NodeType int,@Date date)
RETURNS @DBRList TABLE (RouteNodeId int,RouteNodetype int,RouteName varchar(500))
BEGIN
Declare @CmpSales [dbo].[DSRList]
;with cmpSales as
(select NodeId,NodeType from [dbo].[tblCompanySalesStructureHierarchy] where NodeId=@NodeId and NodeType=@NodeType and CAST(@Date AS DATE) between CAST(VldFrom AS DATE) and VldTo and HierTypeId=2
union all
select b.NodeId,b.NodeType from cmpSales A join [dbo].[tblCompanySalesStructureHierarchy] b on a.NodeId=b.pnodeid and a.NodeType=b.pNodeType  and CAST(@Date AS DATE) between CAST(b.VldFrom AS DATE) and CAST(b.VldTo AS DATE) and HierTypeId=2
)
insert into @CmpSales
select NodeId,NodeType  from cmpSales 

;with cmpSales as
(select NodeId,NodeType from [dbo].[tblCompanySalesStructureHierarchy] where NodeId=@NodeId and NodeType=@NodeType and CAST(@Date AS DATE) between CAST(VldFrom AS DATE) and CAST(VldTo AS DATE) and HierTypeId=5
union all
select b.NodeId,b.NodeType from cmpSales A join [dbo].[tblCompanySalesStructureHierarchy] b on a.NodeId=b.pNodeId and a.NodeType=b.pNodeType  and CAST(@Date AS DATE) between CAST(b.VldFrom AS DATE) and CAST(b.VldTo AS DATE) and HierTypeId=5
)
insert into @CmpSales
select NodeId,NodeType  from cmpSales

insert into @DBRList(RouteNodeId ,RouteNodetype,RouteName)
select a.NodeId,a.Nodetype,b.descr from @CmpSales A join tblCompanySalesStructureRouteMstr b on b.nodetype=a.nodetype

and b.nodeid=a.nodeid
 --where Exists(select * from tblCompanySalesStructureRouteMstr where nodetype=a.nodetype)
union 
select c.nodeid,c.nodetype,d.Descr from @CmpSales A join [dbo].[tblCompanySalesStructure_DistributorMapping] B on b.SHNodeId=a.nodeid and b.SHNodeType=a.nodetype
join [tblCompanySalesStructureHierarchy] C ON C.Pnodeid=b.DHNodeId and C.Pnodetype=b.DHNodeType
join tblDBRSalesStructureRouteMstr D on D.NodeId=c.nodeid and D.Nodetype=c.nodetype WHERE CAST(@Date AS DATE) BETWEEN CAST(B.FromDate AS DATE) AND CAST(B.ToDate AS DATE)
--WHERE  Exists(select * from tblDBRSalesStructureRouteMstr where nodetype=c.nodetype)
union 
select A.nodeid,A.nodetype,R.Descr from @CmpSales A INNER JOIN tblDBRSalesStructureRouteMstr R ON R.NodeID=A.NodeID AND R.NodeType=A.NodeType
RETURN
end



