
CREATE proc [dbo].[spDataLoadRetailerMasterFromAPI]
AS
BEGIN

RETURN;
declare @dt date
select @dt=max(date)  from tblTeleCallerListForDay where CallMade is not null group by StoreId

Update a set isCorrectNo=0 from tblStoreMaster a 
 join tblTeleCallerListForDay c on a.StoreID=c.StoreId
left join tblReasonCodeMstr t on t.ReasonCodeID=c.ReasonId
where ((c.flgCallStatus=1 and isnull(t.REASNFOR,'0')='1') or IsValidContactNo=0)
and c.Date=@dt


if object_id('tempdb..#Retailers') is not null
begin


drop table #Retailers
end
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  a.[ShopId],a.[Zone],a.[Region],a.[Territory],a.[ShopName],a.[OutletErpId],a.[BeatName],a.[BeatErpId],a.[OwnerName]
,a.[Contact],a.[Email],a.[DistributorErpId],a.[CreatedAt],a.[Address],a.[Market],a.[SubCity],a.[City],a.[State],a.[Pincode]
,a.[GSTregistered],a.[GSTIN],a.[Channel],a.[ShopType],a.[Segmentation],a.[ShopTypeErpId],a.[CustomChannel],a.[ChannelErpId]
,a.[Aadhar],a.[PAN],a.[AttributeText1],a.[AttributeText2],a.[AttributeText3],a.[BankAccountNumber],a.[IFSCCode],a.[AccountHoldersName]
,a.[LastUpdatedAt],a.[IsBlocked],a.[IsNew],a.[OutletGuid],a.[AttributeText4],a.[AttributeNumber1],a.[AttributeNumber2],a.[AttributeNumber3]
,a.[AttributeNumber4],a.[AttributeBoolean1],a.[AttributeBoolean2],a.[AttributeDate1],a.[AttributeDate2],a.[PlaceOfDelivery],a.[DistributorErpIds],0 as DistNodeId,0 as DistNodeType,0 as ChannelId,0 as SubChannelId,0 as regionid into #Retailers
  FROM [dbo].tmpRawDataRetailerMasterAPI a join (select OutletErpId,max(ShopId) as shopid from tmpRawDataRetailerMasterAPI group by OutletErpId) b on a.OutletErpId=b.OutletErpId and a.ShopId=b.shopid

  Update a  set ChannelId=b.channelid from #Retailers a join tblMstrChannel b on a.CustomChannel=b.ChannelName

    Update a  set SubChannelId=b.SubChannelId from #Retailers a join tblMstrSUBChannel b on a.ShopType=b.SubChannel

	    Update a  set DistNodeId=b.NodeID,DistNodeType=b.NodeType from #Retailers a join tblDBRSalesStructureDBR b on a.DistributorErpId=b.DistributorCode


		insert into tblPriceRegionMstr(PrcRegion)
select distinct A.REGION from #Retailers A left join tblPriceRegionMstr b on A.region=b.prcregion
where b.prcrgnNodeId is null

Update a set regionid=b.PrcRgnNodeId from  #Retailers A join tblPriceRegionMstr b on A.region=b.prcregion

		Declare @currdate datetime=dbo.fnGetCurrentDateTime()
		Update b set ChannelId=a.ChannelId,SubChannelId=a.SubChannelId,StoreName=a.ShopName,Address=a.Address,StateName=a.State,City=a.City ,DistNodeId=a.DistNodeId,
		DistNodeType=a.DistNodeType,Region=a.Region,zone=a.Zone,territory=a.Territory,DBID=a.DistNodeId
		,DBNodeType=a.DistNodeType,regionid=a.regionid,flgActive=case when a.IsBlocked='True' then 0 else 1 end
		FROM #Retailers a  join tblStoreMaster b on a.OutletErpId=b.StoreCode

		Update b set [ContactNo]=case when len(isnull(a.[Contact],''))>=7 and a.Contact<>b.ContactNo then a.[Contact] else b.[ContactNo] end,isCorrectNo=case when len(isnull(a.[Contact],''))>=7 and a.Contact<>b.ContactNo then 1 else 0 end,TimeStampUpd=@currdate 
		OUTPUT inserted.StoreID,isnull(deleted.[ContactNo],''),isnull(inserted.[ContactNo],''), deleted.isCorrectNo ,@currdate
        INTO tblStoreContactDetailChangeLog		
		FROM #Retailers a  join tblStoreMaster b on a.OutletErpId=b.StoreCode
		where isnull(b.contactno,'')<>isnull(a.Contact,'')


		update b set FName=isnull(a.ContactPerson,''),LandLineNo1=isnull(a.ContactNo,'') from  tblStoreMaster a join tblOutletContactDet b on a.StoreID=b.storeid

		update b set StoreAddress1=a.Address,StoreAddress2=a.[Address 2],Landmark=a.[Address 3],City=a.City,State=a.StateName,ContactNo=a.ContactNo,ContactPerson=a.ContactPerson from  tblStoreMaster a join tblOUTLETADDRESSDET b on a.StoreID=b.storeid


		--Declare @currdate datetime=GETDATE()
insert into tblStoreMaster([StoreCode],[StoreName],[TimeStampIns],[TimeStampUpd],[DistNodeId],[DistNodeType],[flgActive],[CSRtrCode],[ContactNo],EmailId
,[MobileNo1],[MobileNo2],[ContactPerson],[ChannelId],[SubChannelId],[OutstandingAmt],[OutstandingDate],[FileSetIdUpd]
,[FileSetIdTimeStamp],[Address],[Address 2],[Address 3],[StateName],[City],[Pin Code]
,[RelatedParty],[LineOfTradeCode],[programName],[GPS_Lat],[GPS_Long],[RouteGTMType],[FileSetIdIns],[LotId]
,[StateId],[LanguageId],[RetailerFrequency],[RetailerSequence],[CallDays],[TotalVisits],[PendingVisits]
,[LoginIdUpd],[WeeklyOff],[PlaceOfDelivery],[Channel],[ShopType],[Segmentation],[CustomChannel],[GSTRegistered],[Market],[IsBlocked],[IsNew],ShopId,BeatName,Region,Zone,Territory,DBID,DBNodeType,regionid)

SELECT a.OutletErpId,a.[ShopName],@currdate,null,a.DistNodeId,a.DistNodeType,case when a.IsBlocked='True' then 0 else 1 end,'',a.[Contact],a.Email,'','',a.[OwnerName],a.ChannelId,a.SubChannelId,0,@currdate,0,@currdate,a.[Address],'','',a.[State],a.[City],a.[Pincode],'','','','','','',0,0,0,1,'','','',0,0,0,'',a.PlaceOfDelivery,a.Channel,a.ShopType,a.Segmentation,a.CustomChannel,
a.GSTregistered,a.Market,a.IsBlocked,a.IsNew,a.ShopId,a.BeatName,a.Region,a.Zone,a.Territory,a.DistNodeId,a.DistNodeType,a.regionid
  FROM #Retailers a left join tblStoreMaster b on a.OutletErpId=b.StoreCode
  where b.StoreID is null


  insert into tblOUTLETADDRESSDET 
  SELECT 1,a.StoreID,a.Address,a.[Address 2],a.[Address 3],0,a.City,a.[Pin Code],a.StateName,'','',a.ContactPerson,a.ContactNo,0,0 FROM tblStoreMaster a left join tblOUTLETADDRESSDET b on a.StoreID=b.storeid and b.outaddtypeid=1
  where b.storeid is null
  union all
  SELECT 2,a.StoreID,a.Address,a.[Address 2],a.[Address 3],0,a.City,a.[Pin Code],a.StateName,'','',a.ContactPerson,a.ContactNo,0,0 FROM tblStoreMaster a left join tblOUTLETADDRESSDET b on a.StoreID=b.storeid and b.outaddtypeid=2
  where b.storeid is null

  insert into tblOutletContactDet(OutCnctpersonTypeID,ContactType,StoreID,FName,Lname,LandLineNo1,EMailID)
  SELECT 1,1,a.StoreID,isnull(a.ContactPerson,''),'',Isnull(a.ContactNo,''),a.EmailId FROM tblStoreMaster a left join tblOutletContactDet b on a.StoreID=b.storeid 
  where b.storeid is null





  Declare @ShopId bigint
  select @ShopId=MAX(ShopId) from #Retailers

  Update tblExtractMaster set LastId=0,TimeStampUpd=@currdate where extractid=1 --and isnull(lastid,0)<@ShopId
END


