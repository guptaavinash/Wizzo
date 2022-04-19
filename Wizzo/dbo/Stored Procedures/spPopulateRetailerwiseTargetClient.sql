
--select * from mrco_Tbl_RetailerwiseTargetClient_Newlogic
--[spPopulateRetailerwiseTargetClient]  19
CREATE proc [dbo].[spPopulateRetailerwiseTargetClient]  
@FileSetId bigint
as
begin

Declare @currdate datetime=dbo.fnGetCurrentDateTime()

insert into mrco_Tbl_RetailerwiseTargetClient_Newlogic_Error
SELECT        DistributorCode, DistributorName, TargetMonth, TargetYear, DSRID, DSRName, BeatID, BeatName, RetailerCode, RetailerName, CMPRetailerCode, ChannelCode, ChannelName, BrandName, TargetVolume, TargetBPM, 
                         ParentSKUcode, CompParentretailerCode, CSParentretailercode, a.RouteGTMType, IndexBPM,@FileSetId,21,@currdate
FROM            mrco_Tbl_RetailerwiseTargetClient_Newlogic a left join tblStoreMaster s on a.CMPRetailerCode=s.StoreCode
where s.StoreID is null


delete a FROM            mrco_Tbl_RetailerwiseTargetClient_Newlogic a left join tblStoreMaster s on a.CMPRetailerCode=s.StoreCode
where s.StoreID is null


insert into mrco_Tbl_RetailerwiseTargetClient_Newlogic_Error
SELECT        DistributorCode, DistributorName, TargetMonth, TargetYear, DSRID, DSRName, BeatID, BeatName, RetailerCode, RetailerName, CMPRetailerCode, ChannelCode, ChannelName, BrandName, TargetVolume, TargetBPM, 
                         ParentSKUcode, CompParentretailerCode, CSParentretailercode, a.RouteGTMType, IndexBPM,@FileSetId,40,@currdate
FROM            mrco_Tbl_RetailerwiseTargetClient_Newlogic a left join tblPrdMstrHierLvl6 p on a.ParentSKUcode=p.Code
where p.NodeID is null


delete a FROM            mrco_Tbl_RetailerwiseTargetClient_Newlogic a left join tblPrdMstrHierLvl6 p on a.ParentSKUcode=p.Code
where p.NodeID is null

;with ashcte as(

select*,ROW_NUMBER() over(partition by TargetMonth, TargetYear,CMPRetailerCode,ParentSKUcode order by TargetMonth, TargetYear,CMPRetailerCode,ParentSKUcode) rown  from mrco_Tbl_RetailerwiseTargetClient_Newlogic)

insert into mrco_Tbl_RetailerwiseTargetClient_Newlogic_Error
SELECT        DistributorCode, DistributorName, TargetMonth, TargetYear, DSRID, DSRName, BeatID, BeatName, RetailerCode, RetailerName, CMPRetailerCode, ChannelCode, ChannelName, BrandName, TargetVolume, TargetBPM, 
                         ParentSKUcode, CompParentretailerCode, CSParentretailercode, a.RouteGTMType, IndexBPM,@FileSetId,39,@currdate
FROM            ashcte a where rown>1

;with ashcte as(

select*,ROW_NUMBER() over(partition by TargetMonth, TargetYear,CMPRetailerCode,ParentSKUcode order by TargetMonth, TargetYear,CMPRetailerCode,ParentSKUcode) rown  from mrco_Tbl_RetailerwiseTargetClient_Newlogic)

delete a
FROM            ashcte a where rown>1


--update a set TargetValue=z.IndexBPM,FileSetIdUpd=@FileSetId,TimeStampUpd=@currdate from mrco_Tbl_RetailerwiseTargetClient_Newlogic z join tblStoreMaster s on s.StoreCode=z.CMPRetailerCode
--join tblPrdMstrHierLvl6 p on p.Code=z.ParentSKUcode
--join tblRetailerSKUKWiseTarget a on z.TargetMonth=a.MonthVal
--and z.TargetYear=a.YearVal
--and s.StoreID=a.StoreId
--and p.NodeID=a.SkuNodeId
--and p.NodeType=a.SkuNodeType

--select distinct TargetMonth,TargetYear into #tmpMonth from mrco_Tbl_RetailerwiseTargetClient_Newlogic
--delete a from tblRetailerSKUKWiseTarget a join #tmpMonth b on a.MonthVal=b.TargetMonth
--and a.YearVal=b.TargetYear

update a set TargetValue=isnull(z.IndexBPM,0),FileSetIdUpd=@FileSetId,TimeStampUpd=@currdate from
mrco_Tbl_RetailerwiseTargetClient_Newlogic z join tblStoreMaster s on s.StoreCode=z.CMPRetailerCode
join tblPrdMstrHierLvl6 p on p.Code=z.ParentSKUcode
left join tblRetailerSKUKWiseTarget a on z.TargetMonth=a.MonthVal
and z.TargetYear=a.YearVal
and s.StoreID=a.StoreId
and p.NodeID=a.SkuNodeId
and p.NodeType=a.SkuNodeType

insert into tblRetailerSKUKWiseTarget(StoreId,SkuNodeId,SkuNodeType,MonthVal,YearVal,TargetValue,
FileSetIdIns,TimeStampIns,FileSetIdUpd,TimeStampUpd,MonthlyTarget)
Select s.StoreID,p.NodeID,p.NodeType,z.TargetMonth,z.TargetYear,z.IndexBPM,@FileSetId,@currdate,null,null,z.IndexBPM from
mrco_Tbl_RetailerwiseTargetClient_Newlogic z join tblStoreMaster s on s.StoreCode=z.CMPRetailerCode
join tblPrdMstrHierLvl6 p on p.Code=z.ParentSKUcode
LEFT join tblRetailerSKUKWiseTarget a on z.TargetMonth=a.MonthVal
and z.TargetYear=a.YearVal
and s.StoreID=a.StoreId
and p.NodeID=a.SkuNodeId
and p.NodeType=a.SkuNodeType
WHERE A.STOREID IS  NULL



end
