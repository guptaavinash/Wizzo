
CREATE proc [dbo].[spDataLoadDistributorFromAPI]
  AS
  RETURN
  Update b set Descr=a.Name,Address1=a.Address,region=a.Region,pincode=a.Pincode,IsActive=case when IsDeactive='False' then 1 else 0 end,TimestampUpd=getdate() from [tmpDistributorMasterAPI] a  join tblDBRSalesStructureDBR b on a.DistributorERPId=b.DistributorCode
  where DistributorERPId is not null

  Insert into tblDBRSalesStructureDBR (DistributorCode,Descr,Phone,Address1,PinCode,Region,IsActive)
  select a.DistributorERPId,a.Name,a.ContactNo,a.Address,a.Pincode,a.Region,case when IsDeactive='False' then 1 else 0 end from [tmpDistributorMasterAPI] a left join tblDBRSalesStructureDBR b on a.DistributorERPId=b.DistributorCode where DistributorERPId is not null and b.NodeID is null
