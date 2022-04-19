
CREATE proc [dbo].[spRptInvalidWrongContactNoList]
as
begin

select 1 as SheetId,'WrongInvalidNumber' as SheetName,'abhishek.agrawal@bisleri.co.in,aditi1.agarwal@in.ey.com' as EmailId,'Wrong/Invalid Number List' as Subject
,'ashwani@bisleri.co.in,mohit@bisleri.co.in,balaji@bisleri.co.in,dineshg@bisleri.co.in,nilesh.verma@bisleri.co.in,pooja.kanodia@bisleri.co.in,Shambhavi.Pathak@in.ey.com,dipesh.mhatre@bisleri.co.in,alok@astix.in,rohit.chopra@astixtes.in,ashwani@astix.in' as CCEmailId 
select b.DistributorCode,b.Descr as Distributor,a.StoreCode,a.StoreName,a.ContactNo,r.REASNCODE_LVL2NAME as Reason from tblTeleCallerListForDay a join tblDBRSalesStructureDBR b on a.DistNodeId=b.NodeID
and a.DistNodeType=b.NodeType
left join tblReasonCodeMstr r on r.ReasonCodeID=a.ReasonId
where date=Convert(date,getdate())
and ((flgCallStatus<>0 and ReasonId in(1,15)) or len(ContactNo)<7) 



end
