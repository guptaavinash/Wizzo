
CREATE proc [dbo].[spTransferOrderStatus]
@CycFileId bigint,
@flgStatus tinyint ---1=Success,2=Error
as
begin




if @flgStatus=2
begin

	update tblOrderMaster set CycleId=0,flgSent=0 where CycleId=@CycFileId
delete mrco_MI_TELE_ORDER  where CycleId=@CycFileId 
end
else if @flgStatus=1
begin


	
	update tblOrderMaster set flgSent=2 where CycleId=@CycFileId

insert into [mrco_MI_TELE_ORDER_Archive]
	select [DIST_CODE],[RETAILER_CODE],[RETAILER_NAME],[BEAT_DESC],[SKU_CODE],[SKU_DESC],[ORDER_QTY],[TELE_ORDER_NO],[TELE_CALLER_ID]
,[TELE_CALLER_NAME],[DOWNLOAD_FLAG],[ORDER_DATE],[RouteGTMType],[CycleId] from mrco_MI_TELE_ORDER  where CycleId=@CycFileId
	delete mrco_MI_TELE_ORDER  where CycleId=@CycFileId 

end


end
