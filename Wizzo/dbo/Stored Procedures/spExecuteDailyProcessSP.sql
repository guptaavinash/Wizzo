

CREATE proc [dbo].[spExecuteDailyProcessSP]
AS
BEGIN
Declare @Dt date=dbo.fnGetCurrentDateTime()



---select * from Tbl_RetailerwiseTargetClient_Newlogic
Declare @18FileId bigint=0,@A18FileId bigint=0
select @18FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =18 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)

select @A18FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =18 and TimeDataLoadEnd is not null and DataRowsCopied>0 

if @18FileId>0  and @18FileId=@A18FileId
begin
update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@18FileId
exec spPopulateProductMaster @18FileId
update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID=@18FileId
and flgProcessComplete=1
end


---select * from Tbl_RetailerwiseTargetClient_Newlogic
Declare @23FileId bigint=0,@A23FileId bigint=0
select @23FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =23 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)
select @A23FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =23 and TimeDataLoadEnd is not null and DataRowsCopied>0 


if @23FileId>0 AND @A23FileId=@23FileId
begin
update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@23FileId
exec spPopulateSalesHierarchy @23FileId
update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID=@23FileId
and flgProcessComplete=1

end

---select * from Tbl_RetailerwiseTargetClient_Newlogic
Declare @22FileId bigint=0,@A22FileId bigint=0
select @22FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =22 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)

select @A22FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =22 and TimeDataLoadEnd is not null and DataRowsCopied>0 

if @22FileId>0 AND @A22FileId=@22FileId
begin


update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@22FileId
exec spPopulateRetailerAndRouteCalendar @22FileId
update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID=@22FileId
and flgProcessComplete=1

end

---select * from Tbl_RetailerwiseTargetClient_Newlogic
--Declare @20FileId bigint=0,@A20FileId bigint=0
--select @20FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =20 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)

--select @A20FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =20 and TimeDataLoadEnd is not null and DataRowsCopied>0 

--if @20FileId>0 and @A20FileId=@20FileId
--begin

--update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@20FileId
--exec spPopulateActiveProductList @20FileId
--update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID=@20FileId
--and flgProcessComplete=1

--end


---select * from Tbl_RetailerwiseTargetClient_Newlogic
Declare @3FileId bigint=0,@A3FileId bigint=0
select @3FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =3 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)

select @A3FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =3 and TimeDataLoadEnd is not null and DataRowsCopied>0 

if @3FileId>0 AND @A3FileId=@3FileId
begin

update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@3FileId
exec spPopulateRetailerwiseTargetClient @3FileId
update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID=@3FileId
and flgProcessComplete=1


end


---select * from NRC_SCHEME_BATCHMASTER_Urban
Declare @9FileId bigint=0,@A9FileId bigint=0
select @9FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =9 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)

select @A9FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =9 and TimeDataLoadEnd is not null and DataRowsCopied>0 

if @9FileId>0 AND @A9FileId=@9FileId
begin

update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@9FileId
exec spPopulateProductPrice @9FileId
update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID=@9FileId
and flgProcessComplete=1

end



---select * from NRC_SCHEME_BATCHMASTER_Urban
Declare @12FileId bigint=0,@A12FileId bigint=0
select @12FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =12 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)


select @A12FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =12 and TimeDataLoadEnd is not null and DataRowsCopied>0 


if @12FileId>0 AND @A12FileId=@12FileId
begin
update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@12FileId
exec spPopulateProductConversion @12FileId
update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID=@12FileId
and flgProcessComplete=1

end


---select * from mrco_NRC_SCHEME_HEADER_Urban
Declare @11FileId bigint=0,@A11FileId bigint=0
select @11FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =11 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)


select @A11FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =11 and TimeDataLoadEnd is not null and DataRowsCopied>0 



---NRC_SCHEME_Attribute_Urban
Declare @8FileId bigint=0,@A8FileId bigint=0
select @8FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =8 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)


select @A8FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =8 and TimeDataLoadEnd is not null and DataRowsCopied>0 


---NRC_SCHEME_EXCLUSION
Declare @10FileId bigint=0,@A10FileId bigint=0
select @10FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =10 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)


select @A10FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =10 and TimeDataLoadEnd is not null and DataRowsCopied>0 

---NRC_SCHEME_PRODUCTS_Urban
Declare @13FileId bigint=0,@A13FileId bigint=0
select @13FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =13 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)


select @A13FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =13 and TimeDataLoadEnd is not null and DataRowsCopied>0 

---NRC_SCHEME_SLABS_Urban
Declare @15FileId bigint=0,@A15FileId bigint=0
select @15FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =15 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)

select @A15FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =15 and TimeDataLoadEnd is not null and DataRowsCopied>0 

---NRC_SCHEMEChildSKUblock_Urban
	Declare @16FileId bigint=0,@A16FileId bigint=0
	select @16FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =16 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)

	
select @A16FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =16 and TimeDataLoadEnd is not null and DataRowsCopied>0 

	IF @11FileId>0 AND @8FileId>0 AND @16FileId>0 AND @15FileId>0 AND @13FileId>0 AND @10FileId>0

	AND @11FileId=@a11FileId AND @8FileId=@a8FileId AND @16FileId=@a16FileId AND @15FileId=@a15FileId AND @13FileId=@a13FileId AND @10FileId=@a10FileId
	BEGIN
		


		update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID in(@11FileId,@8FileId,@16FileId,@15FileId,@13FileId,@10FileId)
Exec spPopulateSchemeData @11FileId,@8FileId,@16FileId,@15FileId,@13FileId,@10FileId
update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID in(@11FileId,@8FileId,@16FileId,@15FileId,@13FileId,@10FileId)
and flgProcessComplete=1

	END

	---select * from Tbl_RetailerwiseTargetClient_Newlogic
Declare @25FileId bigint=0,@a25FileId bigint=0
select @25FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =25 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)

select @a25FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =25 and TimeDataLoadEnd is not null and DataRowsCopied>0

if @25FileId>0 and @25FileId=@a25FileId
begin

update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@25FileId
exec spPopulatePlannedCallsData @25FileId
update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID=@25FileId
and flgProcessComplete=1

end


	---select * from Tbl_RetailerwiseTargetClient_Newlogic
Declare @19FileId bigint=0,@a19FileId bigint=0
select @19FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =19 and TimeDataLoadEnd is not null and DataRowsCopied>0 and flgProcessComplete in(0,1)


select @a19FileId=isnull(max(CycFileID),0) from tblExtractCycDet where Date=@Dt and FileID =19 and TimeDataLoadEnd is not null and DataRowsCopied>0

if @19FileId>0 and @19FileId=@a19FileId
begin

update tblExtractCycDet set flgProcessComplete=1,TimeDataProcessStart=dbo.fnGetCurrentDateTime() where CycFileID=@19FileId
exec spPopulateSalesData @19FileId,@Dt
update tblExtractCycDet set flgProcessComplete=2,TimeDataProcessEnd=dbo.fnGetCurrentDateTime() where CycFileID=@19FileId
and flgProcessComplete=1
exec spRefreshDailySuggestedOrderData
exec spPopulateNPDGaps

update tblTeleCallerListForDay set IsUsed=7 where Date=@Dt and DistNodeId not in(select distinct DistNodeId from tblPrdDistributorProductPriceMstr) 

end

END
