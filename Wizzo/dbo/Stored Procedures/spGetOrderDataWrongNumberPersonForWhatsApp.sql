Create proc spGetOrderDataWrongNumberPersonForWhatsApp
@NodeId int,
@NodeType int,
@RouteName varchar(100)
as
begin

Declare @Dt date
select @Dt=MAX(a.Date)  from tblTeleCallerListForDay a 

where a.SONodeId=@NodeId and a.SONodeType=@NodeType


select b.OrderID,a.StoreCode,a.StoreName,b.OrderDate,p.SKUCode,p.Descr,c.OrderQty,c.FreeQty from tblTeleCallerListForDay a join tblTCOrderMaster b on a.TeleCallingId=b.TeleCallingId 
join tblTCOrderDetail c on c.OrderID=b.OrderID
join tblPrdMstrSKULvl p on p.NodeID=c.PrdNodeId
where Date=@Dt and SONodeId=@NodeId
and SONodeType=@NodeType and RouteName=@RouteName


select a.TeleCallingId,a.StoreCode,a.StoreName,a.ContactNo,r.REASNCODE_LVL2NAME as Reason from tblTeleCallerListForDay a join tblReasonCodeMstr r on r.ReasonCodeID=a.ReasonId
where Date=@Dt and SONodeId=@NodeId
and SONodeType=@NodeType and RouteName=@RouteName and a.ReasonId in(1,16)

end

