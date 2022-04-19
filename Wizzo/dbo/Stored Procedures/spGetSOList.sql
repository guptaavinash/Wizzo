
--[spGetSOList] 0
CREATE proc [dbo].[spGetSOList] 
@LoginId int,
@ANodeId int=0,
@ANodeType int=0
as
begin
Declare @NodeId int,@NodeType int=0,@RoleId int=0,@NodeIds [NodeIds]
Declare @Curr_Date datetime
set @Curr_Date=Getdate()

SELECT * INTO #vwSalesHierarchy FROM VwCompanyDSRFullDetail
if @ANodeId=0
begin
select @NodeId=b.UserNodeId,@NodeType=b.UserNodeType,@RoleId=b.RoleId from tblSecUserLogin a join tblSecMapUserRoles b on a.userid=b.UserID where LoginId=@LoginId 

insert into @NodeIds
select NodeID,NodeType from tblsalespersonmapping a where PersonNodeID=@NodeId and PersonType=@nodetype
and convert(date,getdate()) between fromdate and todate
select @NodeId=NodeId,@NodeType=NodeType from @NodeIds
end
else
begin
set @NodeId=@ANodeId
set @NodeType=@ANodeType
insert into @NodeIds
values(@NodeId,@NodeType)
end
Create table #SoList(Zone varchar(100),Region varchar(100),ASMArea varchar(100),SOArea varchar(100),SOAreaNodeId int,SOAreaNodeType int
,ASMAreaNodeId int,ASMAreaNodeType int
,ZoneNodeId int,ZoneNodeType int
,RegionNodeId int,RegionNodeType int,
SONodeid int,SONodeType int
)

if @RoleId in(1,0,3)
begin
insert into #SoList
select distinct 
RSMArea ,StateHeadArea,ASMArea ,SOArea 
,SOAreaId ,SOAreaNodeType 
,ASMAreaId ,ASMAreaNodeType 
,RSMAreaID,RSMAreaType
,StateHeadAreaID ,StateHeadAreaNodeType,SOID,SONodeType

 from #vwSalesHierarchy  where  (exists (select * from @NodeIds  where NodeId=StateHeadAreaID and StateHeadAreaNodeType=NodeType) and @NodeType=100
)
or (exists (select * from @NodeIds  where NodeId=RSMAreaID and RSMAreaType=NodeType)  and @NodeType=95
)
or (exists (select * from @NodeIds  where NodeId=ASMAreaID and ASMAreaNodeType=NodeType)   and @NodeType=110
 )
or (exists (select * from @NodeIds  where NodeId=SOAreaID and SOAreaNodeType=NodeType)    and @NodeType=120
)
or @NodeType in(0,800)
end
else if @RoleId in(2,4,5,6,7,8)
begin
insert into #SoList
select distinct 
RSMArea ,StateHeadArea,ASMArea ,SOArea 
,SOAreaId ,SOAreaNodeType 
,ASMAreaId ,ASMAreaNodeType 
,RSMAreaID,RSMAreaType
,StateHeadAreaID ,StateHeadAreaNodeType,SOID,SONodeType
 from #vwSalesHierarchy where  (exists (select * from @NodeIds  where NodeId=StateHeadAreaID and StateHeadAreaNodeType=NodeType)  and @NodeType=100
and @RoleId in(4,2))
or (exists (select * from @NodeIds  where NodeId=RSMAreaID and RSMAreaType=NodeType)  and @NodeType=95
and @RoleId in(4,2,5))
or (exists (select * from @NodeIds  where NodeId=ASMAreaID and ASMAreaNodeType=NodeType)   and @NodeType=110
and @RoleId in(4,2,5,6) )
or (exists (select * from @NodeIds  where NodeId=SOAreaID and SOAreaNodeType=NodeType)    and @NodeType=120
and @RoleId in(4,2,5,6,7,8) )

end
select * from #SoList
end
