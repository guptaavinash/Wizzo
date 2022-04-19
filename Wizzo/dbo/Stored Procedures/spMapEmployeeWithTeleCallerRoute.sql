

CREATE proc [dbo].[spMapEmployeeWithTeleCallerRoute]

@EmpToTCRouteMap [EmpToTCRouteMap] readonly,
@LoginId int
as
begin

Declare @Curr_Date datetime
set @Curr_Date=dbo.fnGetCurrentDateTime()

Update a set ToDate=DATEADD(dd,-1,@Curr_Date) from tblTeleCallerEmpMapping a join @EmpToTCRouteMap b on a.NodeId=b.NodeId
and a.NodeType=b.Nodetype
--where @Curr_Date between FromDate and ToDate

;with ashcte as
(select *,ROW_NUMBER() over(partition by NodeId,NodeType order by NodeId,NodeType,EmpNodeId desc) as Rown from @EmpToTCRouteMap where EmpNodeId<>0)


insert into tblTeleCallerEmpMapping(NodeId, NodeType, EmpId, FromDate, ToDate, LoginIdIns, TimeStampIns)
select NodeId,NodeType,EmpNodeId,@Curr_Date,'2050-12-31',@LoginId,@Curr_Date from ashcte where rown=1

end
