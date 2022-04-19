Create proc [dbo].[spSORouteDataSentMarking]
@SONodeId int,
@SONodeType int,
@RouteERPId varchar(50)
as
begin

insert into tblSORouteDataSentMarking values(@SONodeId,@SONodeType,@RouteERPId,GETDATE(),1,GETDATE())


end
