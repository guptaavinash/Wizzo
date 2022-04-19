CREATE proc [dbo].[spSendTCOrderSMS]
@TeleCallID INT
AS
BEGIN


Declare @OrderId int,@DistNodeType int,@DistNodeId int,@OrderCode varchar(50)

Select @OrderId=OrderId,@OrderCode=OrderCode,@DistNodeId=DistNodeId,@DistNodeType=DistNodeType from tblTCOrderMaster where TeleCallingId=@TeleCallID

select * into #OrderDetails from tblTCOrderDetail where OrderID=@OrderId
select PrdNodeId,PrdNodeType,BrndNodeID,BrndNodeType,PcsInBox into #ProductHierarchy from vwProductHierarchy
Declare @CatRSW varchar(50)='0'
Declare @CatTS varchar(50)='0'
Declare @CatXACT varchar(50)='0'
Declare @CatPOWDER varchar(50)='0'
Declare @CatAB varchar(50)='0'
Declare @StoreName varchar(150)
Declare @MobNo varchar(10)

Select  @CatRSW=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.PrdNodeID=p.PrdNodeId
and a.PrdNodeType=p.PrdNodeType
where p.BrndNodeID=1  
having sum(a.OrderQty)>0

Select  @CatTS=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.PrdNodeID=p.PrdNodeId
and a.PrdNodeType=p.PrdNodeType
where p.BrndNodeID=5
having sum(a.OrderQty)>0

Select  @CatPOWDER=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.PrdNodeID=p.PrdNodeId
and a.PrdNodeType=p.PrdNodeType
where p.BrndNodeID=4
having sum(a.OrderQty)>0

Select  @CatXACT=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.PrdNodeID=p.PrdNodeId
and a.PrdNodeType=p.PrdNodeType
where p.BrndNodeID=7
having sum(a.OrderQty)>0

Select  @CatAB=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.PrdNodeID=p.PrdNodeId
and a.PrdNodeType=p.PrdNodeType
where p.BrndNodeID=6
having sum(a.OrderQty)>0

select @MobNo=z.Items,@StoreName=a.StoreName from tblTeleCallerListForDay a 
	cross apply dbo.Split(A.contactno,',') z
	 where TeleCallingId=@TeleCallID and len(z.Items)=10
	 --set @MobNo='9210000543'
	--+convert(varchar,convert(float,@NetOrderValue))
Declare @DistCode varchar(50)
select @DistCode=DistributorCode from tblDBRSalesStructureDBR where NodeId= @DistNodeId
and NodeType=@DistNodeType
INSERT INTO [67SERVERSMSDB].SmsDB.dbo.tblOutGoingMsgDetails(SMSTo,Msg,DateTimeStamp,FlgStatus,IsRecdPicked,AppType,ServiceProvider,SenderId,EntityId,TemplateId)
SELECT @MobNo,'Dear '+@StoreName + CHAR(13) + CHAR(10) + 'Odr id-'+@OrderCode+'/'+@DistCode + CHAR(13) + CHAR(10) + 'RSW-'+@CatRSW + CHAR(13) + CHAR(10) + 'TS-'+@CatTS + CHAR(13) + CHAR(10) + 'XACT-'+@CatXACT + CHAR(13) + CHAR(10) + 'POWDER-'+@CatPOWDER + CHAR(13) + CHAR(10) + 'AB-'+@CatAB + CHAR(13) + CHAR(10) + 'Will reach in 2 days' + CHAR(13) + CHAR(10) + 'Any query call@9302700090' + CHAR(13) + CHAR(10) + 'Thanks-Raj Soap' AS MSg,GETDATE(),0,0,120,'RajTraders','RAJSOP','1201161492702308055','1207164302496529719'

END