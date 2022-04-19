

CREATE FUNCTION [dbo].[fnGetDistributorList](@NodeId int,@NodeType int,@Date date)
RETURNS @DBRList TABLE (DBRNodeId int,DBRNodetype int)
BEGIN
Declare @CmpSales [dbo].[DSRList]
;with cmpSales as
(select NodeId,NodeType from [dbo].[tblCompanySalesStructureHierarchy] where NodeId=@NodeId and NodeType=@NodeType and @Date between CAST(VldFrom AS DATE) and CAST(VldTo AS DATE) and HierTypeId=2
union all
select b.NodeId,b.NodeType from cmpSales A join [dbo].[tblCompanySalesStructureHierarchy] b on a.NodeId=b.pnodeid and a.NodeType=b.pNodeType  and @Date between CAST(b.VldFrom AS DATE) and CAST(b.VldTo AS DATE) and HierTypeId=2
)
insert into @CmpSales
select NodeId,NodeType  from cmpSales where NodeType<>0

;with cmpSales as
(select NodeId,NodeType from [dbo].[tblCompanySalesStructureHierarchy] where NodeId=@NodeId and NodeType=@NodeType and @Date between CAST(VldFrom AS DATE) and CAST(VldTo AS DATE) and HierTypeId=5
union all
select b.pNodeId,b.pNodeType from cmpSales A join [dbo].[tblCompanySalesStructureHierarchy] b on a.NodeId=b.nodeid and a.NodeType=b.NodeType  and @Date between CAST(b.VldFrom AS DATE) and CAST(b.VldTo AS DATE) and HierTypeId=5
)
insert into @CmpSales
select NodeId,NodeType  from cmpSales where NodeType<>0

insert into @DBRList(DBRNodeId ,DBRNodetype)
select b.DHNodeId,b.DHNodetype from @CmpSales A join [dbo].[tblCompanySalesStructure_DistributorMapping] B on b.SHNodeId=a.nodeid and b.SHNodeType=a.nodetype
WHERE Exists(select * from tblDbrsalesstructuredbr where nodetype=b.DHNodeType  and IsActive=1) AND @Date between CAST(b.Fromdate AS DATE) and CAST(b.Todate AS DATE)
union 
select b.DHNodeId,b.DHNodetype from @CmpSales A join [tblCompanySalesStructureHierarchy] c on c.NodeId=a.nodeid and c.NodeType=a.nodetype
AND @Date between CAST(c.VldFrom AS DATE) and CAST(c.VldTo AS DATE)

 join [dbo].[tblCompanySalesStructure_DistributorMapping] B on b.SHNodeId=c.pnodeid and b.SHNodeType=c.pnodetype
WHERE Exists(select * from tblDbrsalesstructuredbr where nodetype=b.DHNodeType  and IsActive=1) AND @Date between CAST(b.Fromdate AS DATE) and CAST(b.Todate AS DATE)
union 
select c.Pnodeid,c.Pnodetype from @CmpSales A join [dbo].[tblCompanySalesStructure_DistributorMapping] B on b.SHNodeId=a.nodeid and b.SHNodeType=a.nodetype
join [tblCompanySalesStructureHierarchy] C ON C.NodeId=b.DHNodeId and C.NodeType=b.DHNodeType
WHERE Exists(select * from tblDbrsalesstructuredbr where nodetype=c.Pnodetype  and IsActive=1) AND @Date between CAST(b.Fromdate AS DATE) and CAST(b.Todate AS DATE)
union 
select c.Pnodeid,c.Pnodetype from @CmpSales A join [dbo].[tblCompanySalesStructureHierarchy] B on b.NodeId=a.nodeid and b.NodeType=a.nodetype
join [tblCompanySalesStructureHierarchy] C ON C.NodeId=b.pNodeId and C.NodeType=b.pNodeType
WHERE Exists(select * from tblDbrsalesstructuredbr where nodetype=c.Pnodetype  and IsActive=1) AND @Date between CAST(b.VldFrom AS DATE) and CAST(b.VldTo AS DATE)
 AND @Date between CAST(c.VldFrom AS DATE) and CAST(c.VldTo AS DATE)
 union 
select b.Pnodeid,b.Pnodetype from @CmpSales A join [dbo].[tblCompanySalesStructureHierarchy] B on b.NodeId=a.nodeid and b.NodeType=a.nodetype
WHERE Exists(select * from tblDbrsalesstructuredbr where nodetype=b.Pnodetype  and IsActive=1) AND @Date between CAST(b.VldFrom AS DATE) and CAST(b.VldTo AS DATE)
union 
select nodeid,nodetype from @CmpSales A WHERE  Exists(select * from tblDbrsalesstructuredbr where nodetype=A.nodetype and IsActive=1)
union
select nodeid,nodetype from tblDbrsalesstructuredbr where @NodeType=0 and IsActive=1
RETURN
end
