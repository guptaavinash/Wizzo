
CREATE proc [dbo].[spPopulateSalesData]-- 43628,'2021-03-06 00:00:00.000'
@FileSetId bigint,
@t_date date
as
begin
Declare @currdate datetime=dbo.fnGetCurrentDateTime()


Delete a  from mrco_TEMP_BillwiseITEMWISE_Astic_ToProcess a join mrco_TEMP_BillwiseITEMWISE_Astic  b on a.dist_code=b.dist_code
and a.sale_inv_no=b.sale_inv_no 
where b.CycFileID=@FileSetId and b.t_date=@t_date

update a set DistNodeId=d.nodeid,DistNodeType=d.NodeType from mrco_TEMP_BillwiseITEMWISE_Astic a join tblDBRSalesStructureDBR d on a.dist_code=d.distributorcode
where a.CycFileID=@FileSetId and a.t_date=@t_date


insert  into mrco_TEMP_BillwiseITEMWISE_Astic_Error
SELECT        t_date, dist_code, dsr_id, dsr_name, beat_id, beat_name, channel, channel_sub, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, parent_retailer_code, retailer_id, retailer_code, 
                         retailer_name, item_comp_code, item_code, batch_no, sale_inv_no, sale_inv_date, sal_inv_doc, qty, rate, sales_volume, sales_value, primary_scheme, secondary_scheme, spl_disc, dist_disc, disp_disc, addi_lnd, sal_ret, 
                         tax1, tax2, total_tax, total_dedn, net_value, upload_flag, teleorderno, upload_time, mrp, retailermargin, lastmoddate, bill_status, company_code, salesqty, offerqty, t_sales_volume, freevolume, primaryamt, 
                         primaryschemevolume, secondaryschemevolume, p3discount, cashdiscount, salesextax, last_src_update_date, CmpRtrCode, ParentCmpRtrCode, RouteGTMType, NormalSecSchemeAmt, AddSecSchemeAmt,@FileSetId,19,@currdate
FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.DistNodeId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date


insert  into mrco_TEMP_BillwiseITEMWISE_Astic_ToProcess
SELECT        t_date, dist_code, dsr_id, dsr_name, beat_id, beat_name, channel, channel_sub, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, parent_retailer_code, retailer_id, retailer_code, 
                         retailer_name, item_comp_code, item_code, batch_no, sale_inv_no, sale_inv_date, sal_inv_doc, qty, rate, sales_volume, sales_value, primary_scheme, secondary_scheme, spl_disc, dist_disc, disp_disc, addi_lnd, sal_ret, 
                         tax1, tax2, total_tax, total_dedn, net_value, upload_flag, teleorderno, upload_time, mrp, retailermargin, lastmoddate, bill_status, company_code, salesqty, offerqty, t_sales_volume, freevolume, primaryamt, 
                         primaryschemevolume, secondaryschemevolume, p3discount, cashdiscount, salesextax, last_src_update_date, CmpRtrCode, ParentCmpRtrCode, RouteGTMType, NormalSecSchemeAmt, AddSecSchemeAmt
FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.DistNodeId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date

Delete a FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.DistNodeId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date




update a set StoreId=s.storeid from mrco_TEMP_BillwiseITEMWISE_Astic a join tblStoreMaster s on a.CmpRtrCode=s.StoreCode
 where a.CycFileID=@FileSetId and a.t_date=@t_date

insert  into mrco_TEMP_BillwiseITEMWISE_Astic_Error
SELECT        t_date, dist_code, dsr_id, dsr_name, beat_id, beat_name, channel, channel_sub, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, parent_retailer_code, retailer_id, retailer_code, 
                         retailer_name, item_comp_code, item_code, batch_no, sale_inv_no, sale_inv_date, sal_inv_doc, qty, rate, sales_volume, sales_value, primary_scheme, secondary_scheme, spl_disc, dist_disc, disp_disc, addi_lnd, sal_ret, 
                         tax1, tax2, total_tax, total_dedn, net_value, upload_flag, teleorderno, upload_time, mrp, retailermargin, lastmoddate, bill_status, company_code, salesqty, offerqty, t_sales_volume, freevolume, primaryamt, 
                         primaryschemevolume, secondaryschemevolume, p3discount, cashdiscount, salesextax, last_src_update_date, CmpRtrCode, ParentCmpRtrCode, RouteGTMType, NormalSecSchemeAmt, AddSecSchemeAmt,@FileSetId,21,@currdate
FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.StoreId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date



insert  into mrco_TEMP_BillwiseITEMWISE_Astic_ToProcess
SELECT        t_date, dist_code, dsr_id, dsr_name, beat_id, beat_name, channel, channel_sub, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, parent_retailer_code, retailer_id, retailer_code, 
                         retailer_name, item_comp_code, item_code, batch_no, sale_inv_no, sale_inv_date, sal_inv_doc, qty, rate, sales_volume, sales_value, primary_scheme, secondary_scheme, spl_disc, dist_disc, disp_disc, addi_lnd, sal_ret, 
                         tax1, tax2, total_tax, total_dedn, net_value, upload_flag, teleorderno, upload_time, mrp, retailermargin, lastmoddate, bill_status, company_code, salesqty, offerqty, t_sales_volume, freevolume, primaryamt, 
                         primaryschemevolume, secondaryschemevolume, p3discount, cashdiscount, salesextax, last_src_update_date, CmpRtrCode, ParentCmpRtrCode, RouteGTMType, NormalSecSchemeAmt, AddSecSchemeAmt
FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.StoreId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date

Delete a FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.StoreId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date








update a set SKUNodeId=s.NodeID,SKUNodeType=s.NodeType from mrco_TEMP_BillwiseITEMWISE_Astic a join tblPrdMstrHierLvl7 s on a.item_code=s.Code
 where a.CycFileID=@FileSetId and a.t_date=@t_date

insert  into mrco_TEMP_BillwiseITEMWISE_Astic_Error
SELECT        t_date, dist_code, dsr_id, dsr_name, beat_id, beat_name, channel, channel_sub, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, parent_retailer_code, retailer_id, retailer_code, 
                         retailer_name, item_comp_code, item_code, batch_no, sale_inv_no, sale_inv_date, sal_inv_doc, qty, rate, sales_volume, sales_value, primary_scheme, secondary_scheme, spl_disc, dist_disc, disp_disc, addi_lnd, sal_ret, 
                         tax1, tax2, total_tax, total_dedn, net_value, upload_flag, teleorderno, upload_time, mrp, retailermargin, lastmoddate, bill_status, company_code, salesqty, offerqty, t_sales_volume, freevolume, primaryamt, 
                         primaryschemevolume, secondaryschemevolume, p3discount, cashdiscount, salesextax, last_src_update_date, CmpRtrCode, ParentCmpRtrCode, RouteGTMType, NormalSecSchemeAmt, AddSecSchemeAmt,@FileSetId,22,@currdate
FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.SKUNodeId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date


insert  into mrco_TEMP_BillwiseITEMWISE_Astic_ToProcess
SELECT        t_date, dist_code, dsr_id, dsr_name, beat_id, beat_name, channel, channel_sub, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, parent_retailer_code, retailer_id, retailer_code, 
                         retailer_name, item_comp_code, item_code, batch_no, sale_inv_no, sale_inv_date, sal_inv_doc, qty, rate, sales_volume, sales_value, primary_scheme, secondary_scheme, spl_disc, dist_disc, disp_disc, addi_lnd, sal_ret, 
                         tax1, tax2, total_tax, total_dedn, net_value, upload_flag, teleorderno, upload_time, mrp, retailermargin, lastmoddate, bill_status, company_code, salesqty, offerqty, t_sales_volume, freevolume, primaryamt, 
                         primaryschemevolume, secondaryschemevolume, p3discount, cashdiscount, salesextax, last_src_update_date, CmpRtrCode, ParentCmpRtrCode, RouteGTMType, NormalSecSchemeAmt, AddSecSchemeAmt
FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.SKUNodeId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date

Delete a FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.SKUNodeId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date




update a set DSENodeId=isnull(p.NodeID,0),DSENodeType=isnull(p.NodeType,0) from mrco_TEMP_BillwiseITEMWISE_Astic a left join tblMstrPerson p on a.dsr_name=p.Descr
and a.distnodeid=p.DistNodeId
and a.DistNodeType=p.DistNodeType
where   a.CycFileID=@FileSetId and a.t_date=@t_date


insert  into mrco_TEMP_BillwiseITEMWISE_Astic_Error
SELECT        t_date, dist_code, dsr_id, dsr_name, beat_id, beat_name, channel, channel_sub, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, parent_retailer_code, retailer_id, retailer_code, 
                         retailer_name, item_comp_code, item_code, batch_no, sale_inv_no, sale_inv_date, sal_inv_doc, qty, rate, sales_volume, sales_value, primary_scheme, secondary_scheme, spl_disc, dist_disc, disp_disc, addi_lnd, sal_ret, 
                         tax1, tax2, total_tax, total_dedn, net_value, upload_flag, teleorderno, upload_time, mrp, retailermargin, lastmoddate, bill_status, company_code, salesqty, offerqty, t_sales_volume, freevolume, primaryamt, 
                         primaryschemevolume, secondaryschemevolume, p3discount, cashdiscount, salesextax, last_src_update_date, CmpRtrCode, ParentCmpRtrCode, RouteGTMType, NormalSecSchemeAmt, AddSecSchemeAmt,@FileSetId,23,@currdate
FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.DSENodeId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date




update a set RouteNodeId=isnull(p.NodeID,0),RouteNodeType=isnull(p.NodeType,0) from mrco_TEMP_BillwiseITEMWISE_Astic a left join tblDBRSalesStructureRoute p on a.beat_name=p.Descr
and a.distnodeid=p.DistNodeId
and a.DistNodeType=p.DistNodeType
 where a.CycFileID=@FileSetId and a.t_date=@t_date

insert  into mrco_TEMP_BillwiseITEMWISE_Astic_Error
SELECT        t_date, dist_code, dsr_id, dsr_name, beat_id, beat_name, channel, channel_sub, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, parent_retailer_code, retailer_id, retailer_code, 
                         retailer_name, item_comp_code, item_code, batch_no, sale_inv_no, sale_inv_date, sal_inv_doc, qty, rate, sales_volume, sales_value, primary_scheme, secondary_scheme, spl_disc, dist_disc, disp_disc, addi_lnd, sal_ret, 
                         tax1, tax2, total_tax, total_dedn, net_value, upload_flag, teleorderno, upload_time, mrp, retailermargin, lastmoddate, bill_status, company_code, salesqty, offerqty, t_sales_volume, freevolume, primaryamt, 
                         primaryschemevolume, secondaryschemevolume, p3discount, cashdiscount, salesextax, last_src_update_date, CmpRtrCode, ParentCmpRtrCode, RouteGTMType, NormalSecSchemeAmt, AddSecSchemeAmt,@FileSetId,24,@currdate
FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.RouteNodeId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date

if object_id('tempdb..#Status') is not    null
begin
	drop table #Status
end
select distinct bill_status into #Status from mrco_TEMP_BillwiseITEMWISE_Astic where bill_status<>'' and CycFileID=@FileSetId and t_date=@t_date


insert into tblMstrInvStatus
select a.bill_status from #Status a left join tblMstrInvStatus b on a.bill_status=b.InvStatus
where b.InvStatusId is null and isnull(a.bill_status,'')<>'' 


update a set StatusId=isnull(p.InvStatusId,0) from mrco_TEMP_BillwiseITEMWISE_Astic a left join tblMstrInvStatus p on a.bill_status=p.InvStatus
 where a.CycFileID=@FileSetId and a.t_date=@t_date


insert  into mrco_TEMP_BillwiseITEMWISE_Astic_Error
SELECT        t_date, dist_code, dsr_id, dsr_name, beat_id, beat_name, channel, channel_sub, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, parent_retailer_code, retailer_id, retailer_code, 
                         retailer_name, item_comp_code, item_code, batch_no, sale_inv_no, sale_inv_date, sal_inv_doc, qty, rate, sales_volume, sales_value, primary_scheme, secondary_scheme, spl_disc, dist_disc, disp_disc, addi_lnd, sal_ret, 
                         tax1, tax2, total_tax, total_dedn, net_value, upload_flag, teleorderno, upload_time, mrp, retailermargin, lastmoddate, bill_status, company_code, salesqty, offerqty, t_sales_volume, freevolume, primaryamt, 
                         primaryschemevolume, secondaryschemevolume, p3discount, cashdiscount, salesextax, last_src_update_date, CmpRtrCode, ParentCmpRtrCode, RouteGTMType, NormalSecSchemeAmt, AddSecSchemeAmt,@FileSetId,25,@currdate
FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.StatusId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date


insert  into mrco_TEMP_BillwiseITEMWISE_Astic_ToProcess
SELECT        t_date, dist_code, dsr_id, dsr_name, beat_id, beat_name, channel, channel_sub, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, parent_retailer_code, retailer_id, retailer_code, 
                         retailer_name, item_comp_code, item_code, batch_no, sale_inv_no, sale_inv_date, sal_inv_doc, qty, rate, sales_volume, sales_value, primary_scheme, secondary_scheme, spl_disc, dist_disc, disp_disc, addi_lnd, sal_ret, 
                         tax1, tax2, total_tax, total_dedn, net_value, upload_flag, teleorderno, upload_time, mrp, retailermargin, lastmoddate, bill_status, company_code, salesqty, offerqty, t_sales_volume, freevolume, primaryamt, 
                         primaryschemevolume, secondaryschemevolume, p3discount, cashdiscount, salesextax, last_src_update_date, CmpRtrCode, ParentCmpRtrCode, RouteGTMType, NormalSecSchemeAmt, AddSecSchemeAmt
FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.StatusId,0)=0 and a.CycFileID=@FileSetId and a.t_date=@t_date

Delete a FROM            mrco_TEMP_BillwiseITEMWISE_Astic a 
where isnull(a.StatusId,0)=0 and a.t_date=@t_date



update a set invid=b.invid  from mrco_TEMP_BillwiseITEMWISE_Astic a join tblSalesMaster b on a.DistNodeId=b.DistNodeId
and a.DistNodeType=b.DistNodeType
and a.sale_inv_no=b.InvCode
where  a.CycFileID=@FileSetId and a.t_date=@t_date

if OBJECT_ID('tempdb..#ExistsInvIds') is not null
begin
	drop table #ExistsInvIds
end
select  InvId,Max(StatusId) as StatusId,sum(net_value)  as net_value,sum(sales_value) as sales_value  into #ExistsInvIds from mrco_TEMP_BillwiseITEMWISE_Astic where isnull(InvId,0)<>0  and CycFileID=@FileSetId and t_date=@t_date
group by InvId

Update a set StatusId=b.StatusId,Tot_Sales_Val=b.sales_value,Tot_Net_Val=b.net_value,FileSetIdUpd=@FileSetId,TimeStampUpd=@currdate from tblSalesMaster a join #ExistsInvIds b on a.InvId=b.InvId




Delete a from tblSalesDetail a join #ExistsInvIds b on a.InvId=b.InvId


Update a set channelid=b.ChannelId from mrco_TEMP_BillwiseITEMWISE_Astic a join  tblMstrChannel b  on a.channel=b.ChannelCode
 where a.CycFileID=@FileSetId and a.t_date=@t_date

Update a set SubChannelId=b.SubChannelId from mrco_TEMP_BillwiseITEMWISE_Astic a join  tblMstrSUBChannel b  on a.channel_sub=b.SubChannelCode
where  a.CycFileID=@FileSetId and a.t_date=@t_date

insert into tblSalesMaster(InvCode, InvDate, DistNodeId, DistNodeType, StoreId, ChannelId, SubChannelId, StatusId, Tot_Sales_Val, Tot_Net_Val, FileSetIdIns, TimeStampIns)


select sale_inv_no,sale_inv_date,DistNodeId,DistNodeType,Min(StoreId),max(isnull(channelid,0)),max(isnull(subchannelid,0)),max(statusid),
sum(sales_value) as sales_value,sum(net_value)  as net_value,@FileSetId,@currdate
from mrco_TEMP_BillwiseITEMWISE_Astic
where isnull(mrco_TEMP_BillwiseITEMWISE_Astic.InvId,0)=0  and CycFileID=@FileSetId and t_date=@t_date
group by sale_inv_no,sale_inv_date,DistNodeId,DistNodeType--,isnull(channelid,0)--,isnull(subchannelid,0),statusid




update a set invid=b.invid  from mrco_TEMP_BillwiseITEMWISE_Astic a join tblSalesMaster b on a.DistNodeId=b.DistNodeId
and a.DistNodeType=b.DistNodeType
and a.sale_inv_no=b.InvCode
where isnull(a.InvId,0)=0  and a.CycFileID=@FileSetId and a.t_date=@t_date


insert into tblSalesDetail(InvId, DSENodeId, DSENodeType, RouteNodeId, RouteNodeType, SKUNodeId, SKUNodeType, batch, MRP, retMargin, quantity, Rate, Line_Sales_Vol, Line_Sales_Val, Line_PrimarySch_Val, Line_SecondarySch_Val, 
                         Line_Spl_disc, Line_dist_disc, Line_disp_disc, Line_add_ind, Line_sal_ret, Line_tax1, Line_tax2, Line_tottax_Val, Line_total_dedn, Line_Net_Val, Line_salesqty, Line_offerqty, Line_t_sales_vol, Line_freevolume, 
                         Line_primaryamt, Line_p3discount, Line_primaryschemevolume, Line_secondaryschemevolume, Line_cashdiscount, Line_salesextax, last_src_update_date, Line_NormalSecSchemeAmt, Line_AddSecSchemeAmt, po_no, 
                         sal_inv_doc, teleorderno, FileSetIdIns, TimeStampIns, program_1, program_2, program_3, program_4, program_5, program_6, retailer_type, RouteGTMType)

select InvId, DSENodeId, DSENodeType, RouteNodeId, RouteNodeType, SKUNodeId, SKUNodeType, batch_no, AVG(MRP), AVG(retailermargin), SUM(qty), AVG(Rate), SUM(sales_volume), SUM(sales_value), SUM(primary_scheme), SUM(secondary_scheme), SUM(Spl_disc), SUM(dist_disc), SUM(disp_disc), SUM(addi_lnd), SUM(sal_ret), SUM(tax1), SUM(tax2), SUM(total_tax), SUM(total_dedn), SUM(net_value), SUM(salesqty), SUM(offerqty), SUM(t_sales_volume), SUM(freevolume), SUM(primaryamt), SUM(p3discount), SUM(primaryschemevolume), SUM(secondaryschemevolume), SUM(cashdiscount), SUM(salesextax), MAX(last_src_update_date), SUM(NormalSecSchemeAmt), SUM(AddSecSchemeAmt), '', 
                         MAX(sal_inv_doc), MAX(teleorderno), @FileSetId, @currdate, MAX(program_1), MAX(program_2), MAX(program_3), MAX(program_4), MAX(program_5), MAX(program_6), MAX(retailer_type), MAX(RouteGTMType) from mrco_TEMP_BillwiseITEMWISE_Astic
						  where CycFileID=@FileSetId and t_date=@t_date
						 group by InvId, DSENodeId, DSENodeType, RouteNodeId, RouteNodeType, SKUNodeId, SKUNodeType, batch_no

INSERT INTO tblSalesStatusLog
SELECT  InvId,max(StatusId),@FileSetId,@currdate FROM mrco_TEMP_BillwiseITEMWISE_Astic   where CycFileID=@FileSetId
 and t_date=@t_date
group by InvId




if object_id('tempdb..#teleorderno') is not null
begin
drop table #teleorderno
end

select distinct teleorderno,0 as TeleCallngId,1 as flgOrderSource into #teleorderno from mrco_TEMP_BillwiseITEMWISE_Astic where teleorderno<>'' --and StatusId=5 

Update a set  TeleCallngId=b.TeleCallingId from #teleorderno a join vwOrderMaster b on a.teleorderno=b.ordercode
Update a set  TeleCallngId=b.TeleCallingId from #teleorderno a join vwOrderMaster b on a.teleorderno=convert(varchar,b.OrderID)
delete #teleorderno where TeleCallngId=0

delete a from tblTeleCallingInvDetail a join #teleorderno b on a.TeleCallingId=b.TeleCallngId

insert into tblTeleCallingInvDetail

select b.TeleCallngId,a.SKUNodeId,a.SKUNodeType,a.sale_inv_no,a.sale_inv_date,sum(a.qty),sum(a.net_value),sum(a.sales_value),sum(total_tax),sum(secondary_scheme),sum(sales_value),flgOrderSource,a.StatusId from mrco_TEMP_BillwiseITEMWISE_Astic a join #teleorderno b on a.teleorderno=b.teleorderno
						  where CycFileID=@FileSetId and t_date=@t_date
						  group by b.TeleCallngId,a.SKUNodeId,a.SKUNodeType,a.sale_inv_no,a.sale_inv_date,flgOrderSource,a.StatusId
end
