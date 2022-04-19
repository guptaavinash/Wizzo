CREATE proc [dbo].[spUpdateSalesManTeleCallerMapping]
@SOTCMap SOTCMap readonly,
@LoginId int
as
begin

Update a set TCNodeId=b.TCNodeId,TCNodeType=b.TCNodeType,LoginIdUpd=@LoginId,TimeStampUpd=GETDATE() from tblTeleCallerSalesManMapping a join @SOTCMap b on a.SoNodeId=b.SONodeId and a.SoNodeType=b.SONodeType
where FromDate=CONVERT(date,getdate())

Delete a from tblTeleCallerSalesManMapping a join @SOTCMap b on a.SoNodeId=b.SONodeId
and a.SoNodeType=b.SONodeType
where FromDate=convert(date,getdate())

Update a set ToDate=DATEADD(dd,-1,Getdate()),LoginIdUpd=@LoginId,TimeStampUpd=GETDATE() from tblTeleCallerSalesManMapping a join @SOTCMap b on a.SoNodeId=b.SONodeId and a.SoNodeType=b.SONodeType
where CONVERT(date,getdate()) between  FromDate and ToDate



insert into tblTeleCallerSalesManMapping
select SONodeId,SONodeType,TCNodeId,TCNodeType,CONVERT(date,getdate()),'2050-12-31',@LoginId,GETDATE(),null,null from @SOTCMap
where TCNodeId<>0

update a set TCNodeId=b.TCNodeId,TCNodeType=b.TCNodeType,DialerTypeId=t.DialerTypeId from tblTeleCallerListForDay a join tblTeleCallerSalesManMapping b
on a.SOAreaNodeId=b.SoNodeId
and a.SOAreaNodeType=b.SoNodeType
join tblTeleCallerMstr t on t.TeleCallerId=b.TCNodeId
and t.NodeType=b.TCNodeType
where IsUsed=0 and convert(date,GETDATE()) between FromDate and ToDate
and a.Date=CONVERT(date,getdate())


end