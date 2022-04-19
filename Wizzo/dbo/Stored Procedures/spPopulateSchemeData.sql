
CREATE proc [dbo].[spPopulateSchemeData]
as
begin
Update a set flgActive=0 from tblSchemeMaster a left join tmpRawDataSchemeMaster b on a.SchemeCode=b.SchemeNo
where b.SchemeNo is null

insert into tblSchemeMaster
select 1,a.SchemeName,a.SchemeDescription,a.SchemeName,'',1,1,null,0,GETDATE(),null,null,1,1,1,1,2,1,0,0,0,0,null,0,3,0,0,'' from tmpRawDataSchemeMaster a left join tblSchemeMaster b on a.SchemeNo=b.SchemeCode
where b.SchemeID is null

Update z set SchemeFromDate=convert(datetime,a.FromDate,105),SchemeToDate=convert(datetime,a.ToDate,105) from tmpRawDataSchemeMaster a  join tblSchemeMaster b on a.SchemeNo=b.SchemeCode
join tblSchemeDetail z on z.SchemeID=b.SchemeID

insert into tblSchemeDetail
select b.SchemeID,convert(datetime,a.FromDate,105),convert(datetime,a.ToDate,105),0,0,0,'1900-01-01 00:00:00','1900-01-01 00:00:00',null,null,null,null,GETDATE(),0,null,10,'','' from tmpRawDataSchemeMaster a  join tblSchemeMaster b on a.SchemeNo=b.SchemeCode
left join tblSchemeDetail z on z.SchemeID=b.SchemeID
where z.SchemeID is null


update z2  set SlabDescr='1@'+
isnull(STUFF((SELECT '~' + CAST(p2.NodeID AS VARCHAR)
                      +'^'+ CAST(p2.NodeType AS VARCHAR)+'#M10'
         FROM tmpRawDataSchemeOnProduct p1 join tblPrdMstrHierLvl2 p2 on p2.Code=p1.ProductCode
         WHERE A.SchemeNo = p1.SchemeNo
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)')
        ,1,1,''),'')+'|'+SlabOnTo+'*1' from tmpRawDataSchemeSlab a join tblSchemeMaster b on a.SchemeNo=b.SchemeCode
JOIN tmpRawDataSchemeMaster z on z.SchemeNo=a.SchemeNo
 join tblSchemeSlabDetails z2 on z2.SchemeID=b.SchemeID
and z2.SlabDescr=a.SlabNo
where a.SchemeNo in(
select distinct SchemeNo from tmpRawDataSchemeOnProduct p1  join tblPrdMstrHierLvl2 p2 on p2.Descr=p1.ProductCode
)


insert into tblSchemeSlabDetails
select b.SchemeID,SlabNo,'1@'+
isnull(STUFF((SELECT '~' + CAST(p2.NodeID AS VARCHAR)
                      +'^'+ CAST(p2.NodeType AS VARCHAR)+'#M10'
         FROM tmpRawDataSchemeOnProduct p1 join tblPrdMstrHierLvl2 p2 on p2.Code=p1.ProductCode
         WHERE A.SchemeNo = p1.SchemeNo
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)')
        ,1,1,''),'')+'|'+SlabOnTo+'*1','',convert(datetime,z.FromDate,105),convert(datetime,z.ToDate,105),1,SlabNo,0,0,0 from tmpRawDataSchemeSlab a join tblSchemeMaster b on a.SchemeNo=b.SchemeCode
JOIN tmpRawDataSchemeMaster z on z.SchemeNo=a.SchemeNo
left join tblSchemeSlabDetails z2 on z2.SchemeID=b.SchemeID
and z2.SlabDescr=a.SlabNo
where a.SchemeNo in(
select distinct SchemeNo from tmpRawDataSchemeOnProduct p1  join tblPrdMstrHierLvl2 p2 on p2.Descr=p1.ProductCode
)
and z2.SchemeSlabID is null


delete z3 from tmpRawDataSchemeSlab a join tblSchemeMaster b on a.SchemeNo=b.SchemeCode
JOIN tmpRawDataSchemeMaster z on z.SchemeNo=a.SchemeNo
 join tblSchemeSlabDetails z2 on z2.SchemeID=b.SchemeID
and z2.SlabDescr=a.SlabNo
join tblSchemeSlabOutput z3 on z3.SchemeSlabID=z2.SchemeSlabID


insert into tblSchemeSlabOutput
select distinct z2.SchemeSlabID,1,'5@(#M|)@'+convert(varchar,z3.FreeQty)+'$default@@@0',null,null,0,null from tmpRawDataSchemeSlab a join tblSchemeMaster b on a.SchemeNo=b.SchemeCode
JOIN tmpRawDataSchemeMaster z on z.SchemeNo=a.SchemeNo
 join tblSchemeSlabDetails z2 on z2.SchemeID=b.SchemeID
and z2.SlabDescr=a.SlabNo
join tmpRawDataSchemeFreeProductDetail z3 on z3.SchemeNo=a.SchemeNo
and z3.SlabNo=a.SlabNo
join tblprdmstrskulvl p on p.PrdCode=z3.SKUCode
join tblPrdMstrHierLvl2 p2 on p2.Descr=p.PckGroupName
join tmpRawDataSchemeOnProduct z4 on z4.SchemeNo=a.SchemeNo
and z4.ProductCode=p2.Descr
WHERE A.SlabType='Free'

insert into tblSchemeSlabOutput
select distinct z2.SchemeSlabID,1,'1@('+convert(varchar,p2.NodeID)+'^'+convert(varchar,p2.NodeType)+'#M|)@'+convert(varchar,z3.FreeQty)+'$default@@@0',null,null,0,null from tmpRawDataSchemeSlab a join tblSchemeMaster b on a.SchemeNo=b.SchemeCode
JOIN tmpRawDataSchemeMaster z on z.SchemeNo=a.SchemeNo
 join tblSchemeSlabDetails z2 on z2.SchemeID=b.SchemeID
and z2.SlabDescr=a.SlabNo
join tmpRawDataSchemeFreeProductDetail z3 on z3.SchemeNo=a.SchemeNo
and z3.SlabNo=a.SlabNo
join tblprdmstrskulvl p on p.PrdCode=z3.SKUCode
join tblPrdMstrHierLvl2 p2 on p2.Descr=p.PckGroupName
left join tmpRawDataSchemeOnProduct z4 on z4.SchemeNo=a.SchemeNo
and z4.ProductCode=p2.Descr
where z4.SchemeNo is null
and not exists(select * from tblSchemeSlabOutput f4 where f4.SchemeSlabID=z2.SchemeSlabID)
and A.SlabType='Free'


insert into tblSchemeSlabOutput
select distinct z2.SchemeSlabID,1,'6@(#M|)@'+convert(varchar,a.SlabValue)+'$default@@@0',null,null,0,null from tmpRawDataSchemeSlab a join tblSchemeMaster b on a.SchemeNo=b.SchemeCode
JOIN tmpRawDataSchemeMaster z on z.SchemeNo=a.SchemeNo
 join tblSchemeSlabDetails z2 on z2.SchemeID=b.SchemeID
and z2.SlabDescr=a.SlabNo
WHERE A.SlabType='Disc. %'

delete d from tmpRawDataSchemeDistributionDetail a join tblSchemeMaster b on a.SchemeNo=b.SchemeCode
join tblSchemeDetail c on c.SchemeID=b.SchemeID
join tblSchemeApplicabilityDetail d on d.SchemeDetID=c.SchemeDetID

insert into tblSchemeApplicabilityDetail

select distinct c.SchemeDetID,g.ChannelId,g.SubChannelId,0,d.NodeID,d.NodeType,0,0,0 from tmpRawDataSchemeDistributionDetail a join tblSchemeMaster b on a.SchemeNo=b.SchemeCode
join tblSchemeDetail c on c.SchemeID=b.SchemeID
join tblDBRSalesStructureDBR d on d.DistributorCode=a.DistributorCode
join tmpRawDataSchemeRetailerType f on f.SchemeNo=a.SchemeNo

join tblMstrSUBChannel g on f.Type2Name=g.SubChannel

delete a from tblSchemeProductDetail a join tblSchemeMaster b on a.SchemeId=b.SchemeID
join tmpRawDataSchemeOnProduct c on c.SchemeNo=b.SchemeCode


insert into tblSchemeProductDetail

select b.SchemeID,p.NodeID,p.NodeType,0,0 from 
tblSchemeMaster b 
join tmpRawDataSchemeOnProduct c on c.SchemeNo=b.SchemeCode
join tblprdmstrhierlvl2 p on p.descr=c.ProductName



end
