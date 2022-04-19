-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [SpSendOrderSMS] 4013,2629
CREATE PROCEDURE [dbo].[SpSendOrderSMS] 
	@StoreID INT,
	@OrderID INT
AS
BEGIN
	
	select SKUNodeID PrdNodeId,SKUNodeType PrdNodeType,CategoryNodeID BrndNodeID,CategoryNodeType BrndNodeType,PcsInBox into #ProductHierarchy from VwSFAProductHierarchy
Declare @CatRSW varchar(50)='0'
Declare @CatTS varchar(50)='0'
Declare @CatXACT varchar(50)='0'
Declare @CatPOWDER varchar(50)='0'
Declare @CatAB varchar(50)='0'
Declare @StoreName varchar(150)=''
Declare @MobNo varchar(10)
DECLARE @OrderCode VARCHAR(30)
DECLARE @DBID INT,@DBNodeType SMALLINT
DECLARE @NetOrderValue FLOAT

SELECT @OrderCode=OrderCode,@NetOrderValue=NetOrderValue,@DBID=SalesNodeId,@DBNodeType=SalesNodeType FROM tblOrderMaster WHERE OrderID=@OrderID

SELECT @OrderCode=@OrderCode + '/' + DistributorCode FROM tblDBRSalesStructureDBR WHERE NodeID=@DBID AND NodeType=@DBNodeType

SELECT * INTO #OrderDetails FROM tblOrderDetail(NoLOck) OD WHERE OrderID=@OrderID

Select  @CatRSW=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.ProductID=p.PrdNodeId
where p.BrndNodeID=1  
having sum(a.OrderQty)>0

Select  @CatTS=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.ProductID=p.PrdNodeId
where p.BrndNodeID=5
having sum(a.OrderQty)>0

Select  @CatPOWDER=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.ProductID=p.PrdNodeId
where p.BrndNodeID=4
having sum(a.OrderQty)>0

Select  @CatXACT=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.ProductID=p.PrdNodeId
where p.BrndNodeID=7
having sum(a.OrderQty)>0

Select  @CatAB=case when isnull(sum(a.OrderQty/p.PcsInBox),'')>0 then convert(varchar,sum(a.OrderQty/p.PcsInBox))+' CS ' ELSE '' END+case when sum(a.OrderQty%p.PcsInBox)>0 then convert(varchar,sum(a.OrderQty%p.PcsInBox))+' PCS' ELSE '' END+Char(13) from #OrderDetails a join #ProductHierarchy p on a.ProductID=p.PrdNodeId
where p.BrndNodeID=6
having sum(a.OrderQty)>0

PRINT '@CatRSW=' + @CatRSW
PRINT '@@CatTS=' + @CatTS
PRINT '@@CatXACT=' + @CatXACT
PRINT '@@CatPOWDER=' + @CatPOWDER
PRINT '@@CatAB=' + @CatAB

SELECT @StoreName=Storename FROM tblStoreMaster(nolock) WHERE StoreID=@StoreID
SELECT @MobNo=MobNo FROM tblOutletContactDet WHERE StoreID=@StoreID AND ContactType=1
--SELECT @MobNo='9818885642'

INSERT INTO [67SERVERSMSDB].SmsDB.dbo.tblOutGoingMsgDetails(SMSTo,Msg,DateTimeStamp,FlgStatus,IsRecdPicked,AppType,ServiceProvider,SenderId,EntityId,TemplateId)
----SELECT @MobNo,'Dear '+@StoreName + CHAR(13) + CHAR(10) + 'Odr id-'+@OrderCode + CHAR(13) + CHAR(10) + 'Odr Amt-'+convert(varchar,convert(float,@NetOrderValue)) + CHAR(13) + CHAR(10) + 'RSW-'+@CatRSW + CHAR(13) + CHAR(10) + 'TS-'+@CatTS + CHAR(13) + CHAR(10) + 'XACT-'+@CatXACT + CHAR(13) + CHAR(10) + 'POWDER-'+@CatPOWDER + CHAR(13) + CHAR(10) + 'AB-'+@CatAB + CHAR(13) + CHAR(10) + 'Will reach in 2 days' + CHAR(13) + CHAR(10) + 'Any query call@9302700090' + CHAR(13) + CHAR(10) + 'Thanks-Raj Soap' AS MSg,GETDATE(),0,0,120,'RajTraders','RAJSOP','1201161492702308055','1207164146511847437'

SELECT @MobNo,'Dear '+@StoreName + CHAR(13) + CHAR(10) + 'Odr id-'+@OrderCode + CHAR(13) + CHAR(10) + 'RSW-'+@CatRSW + CHAR(13) + CHAR(10) + 'TS-'+@CatTS + CHAR(13) + CHAR(10) + 'XACT-'+@CatXACT + CHAR(13) + CHAR(10) + 'POWDER-'+@CatPOWDER + CHAR(13) + CHAR(10) + 'AB-'+@CatAB + CHAR(13) + CHAR(10) + 'Will reach in 2 days' + CHAR(13) + CHAR(10) + 'Any query call@9302700090' + CHAR(13) + CHAR(10) + 'Thanks-Raj Soap' AS MSg,GETDATE(),0,0,120,'RajTraders','RAJSOP','1201161492702308055','1207164302496529719'

END
