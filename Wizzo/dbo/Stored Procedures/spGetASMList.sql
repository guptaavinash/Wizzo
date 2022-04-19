--[spGetASMList] 0
CREATE proc [dbo].[spGetASMList]
@Loginid int
as
begin
Declare @NodeId int,@NodeType int,@RoleId int,@NodeIds [NodeIds] 
select @NodeId=b.UserNodeId,@NodeType=b.UserNodeType,@RoleId=b.RoleId from tblSecUser a join tblSecMapUserRoles b on a.UserID=b.UserID
join tblSecUserLogin l on l.UserID=a.UserID
where l.LoginID=@Loginid


if @RoleId=6
begin
insert into @NodeIds
select NodeID,NodeType from tblsalespersonmapping a where PersonNodeID=@NodeId and PersonType=@nodetype
and convert(date,getdate()) between fromdate and todate


select distinct ASMAreaNodeId,ASMAreaNodeType,ASMArea from vwSalesHierarchy a join @NodeIds b on a. ASMAreaNodeId=b.NodeId and a.ASMAreaNodeType=b.NodeType

select distinct  SOAreaNodeId AS  SONodeId,SOAreaNodeType AS SONodeType,SOArea AS  SOName,ASMAreaNodeId,ASMAreaNodeType from vwSalesHierarchy a join @NodeIds b on a. ASMAreaNodeId=b.NodeId and a.ASMAreaNodeType=b.NodeType

end

else 
begin
select distinct ASMAreaNodeId,ASMAreaNodeType,ASMArea from vwSalesHierarchy
select distinct SOAreaNodeId AS  SONodeId,SOAreaNodeType AS SONodeType,SOArea AS  SOName,ASMAreaNodeId,ASMAreaNodeType from vwSalesHierarchy a

end

select TeleCallerId,TeleCallerCode,NodeType from tblTeleCallerMstr
end
