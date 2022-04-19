
--SELECT * FROM dbo.[fnGetRouteList](3 ,160 ,GETDATE() )

CREATE FUNCTION [dbo].[fnGetRouteList](@NodeId int,@NodeType int,@Date date)
RETURNS @DBRList TABLE (RouteNodeId int,RouteNodetype int)
BEGIN
Declare @CmpSales [dbo].[DSRList]
;with cmpSales as
(select NodeId,NodeType from [dbo].[tblCompanySalesStructureHierarchy] where NodeId=@NodeId and NodeType=@NodeType and @Date between VldFrom and VldTo and HierTypeId=2
union all
select b.NodeId,b.NodeType from cmpSales A join [dbo].[tblCompanySalesStructureHierarchy] b on a.NodeId=b.pnodeid and a.NodeType=b.pNodeType  and @Date between b.VldFrom and b.VldTo and HierTypeId=2
)
insert into @CmpSales
select NodeId,NodeType  from cmpSales 

;with cmpSales as
(select NodeId,NodeType from [dbo].[tblCompanySalesStructureHierarchy] where NodeId=@NodeId and NodeType=@NodeType and @Date between VldFrom and VldTo and HierTypeId=5
union all
select b.NodeId,b.NodeType from cmpSales A join [dbo].[tblCompanySalesStructureHierarchy] b on a.NodeId=b.pNodeId and a.NodeType=b.pNodeType  and @Date between b.VldFrom and b.VldTo and HierTypeId=5
)
insert into @CmpSales
select NodeId,NodeType  from cmpSales

insert into @DBRList(RouteNodeId ,RouteNodetype)
select NodeId,Nodetype from @CmpSales A where Exists(select * from tblCompanySalesStructureRouteMstr where nodetype=a.nodetype)
union 
select c.nodeid,c.nodetype from @CmpSales A join [dbo].[tblCompanySalesStructure_DistributorMapping] B on b.SHNodeId=a.nodeid and b.SHNodeType=a.nodetype
join [tblCompanySalesStructureHierarchy] C ON C.Pnodeid=b.DHNodeId and C.Pnodetype=b.DHNodeType
WHERE  Exists(select * from tblDBRSalesStructureRouteMstr where nodetype=c.nodetype)
union 
select nodeid,nodetype from @CmpSales A WHERE  Exists(select * from tblDBRSalesStructureRouteMstr where nodetype=A.nodetype)
RETURN
end



