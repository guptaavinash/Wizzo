
--SELECT * FROM tmpDaySummaryAPI
--SELECT * FROM tblCompanySalesStructureMgnrLvl1

--SELECT * FROM tmpSalesHierarchyAPI WHERE UserErpId='EMP00806'

CREATE proc [dbo].[spDataLoadSaleshierarchy]
as
begin
RETURN;
--truncate table tblCompanySalesStructureMgnrLvl0

--truncate table tblCompanySalesStructureMgnrLvl1
--truncate table tblCompanySalesStructureMgnrLvl2

--truncate table tblCompanySalesStructureMgnrLvl4

--truncate table tblCompanySalesStructureMgnrLvl5

--truncate table tblCompanySalesStructureSprvsnLvl1

--truncate table tblCompanySalesStructureHierarchy

--truncate table tblMstrPerson

if OBJECT_ID('tempdb..#SalesHierarchy') is not null
begin
	drop table #SalesHierarchy
end
select * into #SalesHierarchy from tmpSalesHierarchyAPI
;with ashcte as(
select *,ROW_NUMBER() over(partition by UserErpId,UserRank order by UserErpId,UserRank,convert(datetime,createdat) desc) as rown  from #SalesHierarchy )
delete ashcte where rown>1

Declare @currdate datetime=Getdate()

insert into tblCompanySalesStructureSprvsnLvl1
select distinct a.UserErpId,a.UserName,a.HQ,120,1,0,@currdate,null,null from #SalesHierarchy a left join tblCompanySalesStructureSprvsnLvl1 b on a.UserErpId=b.UnqCode where UserRank=0 and UserErpId is not null and b.UnqCode is null

Declare @Lvl4 int=0
SELECT @Lvl4=NodeID FROM tblCompanySalesStructureSprvsnLvl1 where UnqCode='NA'
IF @Lvl4=0
begin
insert into tblCompanySalesStructureSprvsnLvl1  values('NA','Not Available','NA',120,1,0,@currdate,null,null)
end
insert into tblCompanySalesStructureCoverage
select a.Descr,130,1,a.UnqCode,'',0,GETDATE(),null,null,0 from  tblCompanySalesStructureSprvsnLvl1 a left join tblCompanySalesStructureCoverage b on a.UnqCode=b.SOERPID
where b.NodeID is null
--insert into tblCompanySalesStructureSprvsnLvl1
--select distinct a.UserErpId,a.UserName,a.HQ,120,1,0,@currdate,null,null from #SalesHierarchy a  left join tblCompanySalesStructureSprvsnLvl1 b on a.UserErpId=b.UnqCode where a.UserRank=1 and a.UserErpId is not null


--insert into tblCompanySalesStructureMgnrLvl4
--select distinct a.UserErpId,a.UserName,105,1,0,@currdate,null,null from #SalesHierarchy a left join tblCompanySalesStructureMgnrLvl4 b on a.UserErpId=b.Code where UserRank=2 and UserErpId is not null
Declare @Lvl3 int=0
SELECT @Lvl3=NodeID FROM tblCompanySalesStructureMgnrLvl2 where Code='NA'
insert into tblCompanySalesStructureMgnrLvl2
select distinct a.UserErpId,a.UserName,110,1,0,@currdate,null,null from #SalesHierarchy a left join tblCompanySalesStructureMgnrLvl2 b on a.UserErpId=b.Code where UserRank=1 and UserErpId is not null and b.Code is null

IF not exists(SELECT * FROM tblCompanySalesStructureMgnrLvl2 where Code='NA')
begin
insert into tblCompanySalesStructureMgnrLvl2  values('NA','Not Available',110,1,0,@currdate,null,null)
end


insert into tblCompanySalesStructureMgnrLvl1
select distinct a.UserErpId,a.UserName,100,1,0,@currdate,null,null from #SalesHierarchy a left join tblCompanySalesStructureMgnrLvl1 b on a.UserErpId=b.Code where UserRank=2 and UserErpId is not null and b.Code is null

Declare @Lvl2 int=0
SELECT @Lvl2=NodeID FROM tblCompanySalesStructureMgnrLvl1 where Code='NA'
IF @Lvl2=0
begin
insert into tblCompanySalesStructureMgnrLvl1  values('NA','Not Available',100,1,0,@currdate,null,null)
end


insert into tblCompanySalesStructureMgnrLvl0
select distinct a.UserErpId,a.UserName,95,1,0,@currdate,null,null from #SalesHierarchy a left join tblCompanySalesStructureMgnrLvl0 b on a.UserErpId=b.Code where UserRank=3 and UserErpId is not null and b.Code is null


Declare @Lvl1 int=0
SELECT @Lvl1=NodeID FROM tblCompanySalesStructureMgnrLvl0 where Code='NA'
IF @Lvl1=0
BEGIN
insert into tblCompanySalesStructureMgnrLvl0  values('NA','Not Available',95,1,0,@currdate,null,null)
end



insert into tblCompanySalesStructureHierarchy 
select a.NodeID,a.NodeType,0,0,0,2,convert(date,Getdate()),'2050-12-31',0 from tblCompanySalesStructureMgnrLvl0 a left join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType

where b.NodeID is null 


insert into tblCompanySalesStructureHierarchy_history

select distinct b.* from tblCompanySalesStructureMgnrLvl1 a 
join #SalesHierarchy c on c.UserErpId=a.Code 
join tblCompanySalesStructureMgnrLvl0 z on z.Code=ISNULL(c.ManagerErpId,'NA')
--join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID 
--and h1.NodeType=z.NodeType and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
 join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo

where c.UserRank=2 and b.PNodeID<>Z.NodeID --and b.PNodeType<>Z.NodeType


delete b from tblCompanySalesStructureMgnrLvl1 a 
join #SalesHierarchy c on c.UserErpId=a.Code 
join tblCompanySalesStructureMgnrLvl0 z on z.Code=ISNULL(c.ManagerErpId,'NA')
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID 
and h1.NodeType=z.NodeType and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
 join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo

where c.UserRank=2 and b.PNodeID<>h1.NodeID --and b.PNodeType<>h1.NodeType



update b set PHierId=h1.HierID from tblCompanySalesStructureMgnrLvl1 a 
join #SalesHierarchy c on c.UserErpId=a.Code 
join tblCompanySalesStructureMgnrLvl0 z on z.Code=ISNULL(c.UserErpId,'NA')
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
and h1.NodeType=z.NodeType  and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
 join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType   and convert(date,GETDATE()) between b.VldFrom and b.VldTo

where c.UserRank=2 and b.PHierId<>h1.HierID


insert into tblCompanySalesStructureHierarchy 
select distinct a.NodeID,a.NodeType,h1.NodeID,h1.NodeType,2,h1.HierID,convert(date,Getdate()),'2050-12-31',0 from tblCompanySalesStructureMgnrLvl1 a 
join #SalesHierarchy c on c.UserErpId=a.Code 
join tblCompanySalesStructureMgnrLvl0 z on z.Code=ISNULL(c.ManagerErpId,'NA')
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
and h1.NodeType=z.NodeType
left join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType

where b.NodeID is null and c.UserRank=2

insert into tblCompanySalesStructureHierarchy 
select distinct a.NodeID,a.NodeType,h1.NodeID,h1.NodeType,2,h1.HierID,convert(date,Getdate()),'2050-12-31',0 from tblCompanySalesStructureMgnrLvl1 a 
 
join tblCompanySalesStructureMgnrLvl0 z on z.Code='NA'
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
and h1.NodeType=z.NodeType
left join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType

where b.NodeID is null and a.Code='NA'

--SELECT * FROM tblCompanySalesStructureMgnrLvl1

--SELECT * FROM #SalesHierarchy WHERE UserRank='1'
--SELECT * FROM #SalesHierarchy WHERE UserRank='2'
--SELECT * FROM #SalesHierarchy WHERE UserRank='3'



insert into tblCompanySalesStructureHierarchy_history

select distinct b.* from tblCompanySalesStructureMgnrLvl2 a 
join #SalesHierarchy c on c.UserErpId=a.Code 
join tblCompanySalesStructureMgnrLvl1 z on z.Code=ISNULL(c.ManagerErpId,'NA')
--join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID 
--and h1.NodeType=z.NodeType and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
 join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo

where c.UserRank=1 and b.PNodeID<>Z.NodeID --and b.PNodeType<>Z.NodeType


delete b from tblCompanySalesStructureMgnrLvl2 a 
join #SalesHierarchy c on c.UserErpId=a.Code 
join tblCompanySalesStructureMgnrLvl1 z on z.Code=ISNULL(c.ManagerErpId,'NA')
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID 
and h1.NodeType=z.NodeType and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
 join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo

where c.UserRank=1 and b.PNodeID<>h1.NodeID --and b.PNodeType<>h1.NodeType


update b set PHierId=h1.HierID from tblCompanySalesStructureMgnrLvl2 a 
join #SalesHierarchy c on c.UserErpId=a.Code 
join tblCompanySalesStructureMgnrLvl1 z on z.Code=ISNULL(c.UserErpId,'NA')
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
and h1.NodeType=z.NodeType  and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
 join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType   and convert(date,GETDATE()) between b.VldFrom and b.VldTo

where c.UserRank=1 and b.PHierId<>h1.HierID

insert into tblCompanySalesStructureHierarchy 
select distinct a.NodeID,a.NodeType,h1.NodeID,h1.NodeType,2,h1.HierID,convert(date,Getdate()),'2050-12-31',0 from tblCompanySalesStructureMgnrLvl2 a 
join #SalesHierarchy c on c.UserErpId=a.Code 
join tblCompanySalesStructureMgnrLvl1 z on z.Code=ISNULL(c.ManagerErpId,'NA')
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
and h1.NodeType=z.NodeType
left join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType

where b.NodeID is null and c.UserRank=1

insert into tblCompanySalesStructureHierarchy 
select distinct a.NodeID,a.NodeType,h1.NodeID,h1.NodeType,2,h1.HierID,convert(date,Getdate()),'2050-12-31',0 from tblCompanySalesStructureMgnrLvl2 a 
join #SalesHierarchy c on c.UserErpId=a.Code 
join tblCompanySalesStructureMgnrLvl1 z on z.Code='NA'
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
and h1.NodeType=z.NodeType
left join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType

where b.NodeID is null and a.Code ='NA'

--insert into tblCompanySalesStructureHierarchy 
--select distinct a.NodeID,a.NodeType,h1.NodeID,h1.NodeType,2,h1.HierID,convert(date,Getdate()),'2050-12-31',0 from tblCompanySalesStructureMgnrLvl4 a 
--join #SalesHierarchy c on c.UserErpId=a.Code 
--join tblCompanySalesStructureMgnrLvl2 z on z.Code=c.ManagerErpId
--join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
--and h1.NodeType=z.NodeType
--left join 
--tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
--and a.NodeType=b.NodeType

--where b.NodeID is null and c.UserRank=2




--insert into tblCompanySalesStructureHierarchy 
--select distinct a.NodeID,a.NodeType,h1.NodeID,h1.NodeType,2,h1.HierID,convert(date,Getdate()),'2050-12-31',0 from tblCompanySalesStructureMgnrLvl5 a 
--join #SalesHierarchy c on c.UserErpId=a.Code 
--join tblCompanySalesStructureMgnrLvl4 z on z.Code=c.ManagerErpId
--join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
--and h1.NodeType=z.NodeType
--left join 
--tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
--and a.NodeType=b.NodeType

--where b.NodeID is null and c.UserRank=1

insert into tblCompanySalesStructureHierarchy_history

select distinct b.* from tblCompanySalesStructureSprvsnLvl1 a 
join #SalesHierarchy c on c.UserErpId=a.UnqCode 
join tblCompanySalesStructureMgnrLvl2 z on z.Code=ISNULL(c.ManagerErpId,'NA')
--join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID 
--and h1.NodeType=z.NodeType and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
 join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo

where c.UserRank=0 and b.PNodeID<>Z.NodeID --and b.PNodeType<>Z.NodeType


delete b from tblCompanySalesStructureSprvsnLvl1 a 
join #SalesHierarchy c on c.UserErpId=a.UnqCode 
join tblCompanySalesStructureMgnrLvl2 z on z.Code=ISNULL(c.ManagerErpId,'NA')
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID 
and h1.NodeType=z.NodeType and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
 join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,GETDATE()) between b.VldFrom and b.VldTo

where c.UserRank=0 and b.PNodeID<>h1.NodeID --and b.PNodeType<>h1.NodeType



update b set PHierId=h1.HierID from tblCompanySalesStructureSprvsnLvl1 a 
join #SalesHierarchy c on c.UserErpId=a.UnqCode 
join tblCompanySalesStructureMgnrLvl2 z on z.Code=ISNULL(c.UserErpId,'NA')
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
and h1.NodeType=z.NodeType  and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
 join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType   and convert(date,GETDATE()) between b.VldFrom and b.VldTo

where c.UserRank=0 and b.PHierId<>h1.HierID


insert into tblCompanySalesStructureHierarchy 
select distinct a.NodeID,a.NodeType,h1.NodeID,h1.NodeType,2,h1.HierID,convert(date,Getdate()),'2050-12-31',0 from tblCompanySalesStructureSprvsnLvl1 a 
join #SalesHierarchy c on c.UserErpId=a.UnqCode 
join tblCompanySalesStructureMgnrLvl2 z on z.Code=ISNULL(c.ManagerErpId,'NA')
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
and h1.NodeType=z.NodeType and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
left join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType  and convert(date,GETDATE()) between b.VldFrom and b.VldTo

where b.NodeID is null and c.UserRank=0


update b set PHierId=h1.HierID from tblCompanySalesStructureCoverage a 
join #SalesHierarchy c on c.UserErpId=a.SOERPID 
join tblCompanySalesStructureSprvsnLvl1 z on z.UnqCode=ISNULL(c.UserErpId,'NA')
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
and h1.NodeType=z.NodeType  and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
 join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType   and convert(date,GETDATE()) between b.VldFrom and b.VldTo

where c.UserRank=0 and b.PHierId<>h1.HierID



insert into tblCompanySalesStructureHierarchy 
select distinct a.NodeID,a.NodeType,h1.NodeID,h1.NodeType,2,h1.HierID,convert(date,Getdate()),'2050-12-31',0 from tblCompanySalesStructureCoverage a 
join #SalesHierarchy c on c.UserErpId=a.SOERPID 
join tblCompanySalesStructureSprvsnLvl1 z on z.UnqCode=ISNULL(c.UserErpId,'NA')
join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
and h1.NodeType=z.NodeType  and convert(date,GETDATE()) between h1.VldFrom and h1.VldTo
left join 
tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType   and convert(date,GETDATE()) between b.VldFrom and b.VldTo


where b.NodeID is null and c.UserRank=0


--insert into tblCompanySalesStructureHierarchy 
--select distinct a.NodeID,a.NodeType,h1.NodeID,h1.NodeType,2,h1.HierID,convert(date,Getdate()),'2050-12-31',0 from tblCompanySalesStructureSprvsnLvl1 a 
--join #SalesHierarchy c on c.UserErpId=a.UnqCode 
--join tblCompanySalesStructureMgnrLvl5 z on z.Code=c.UserErpId
--join tblCompanySalesStructureHierarchy h1 on h1.NodeID=z.NodeID
--and h1.NodeType=z.NodeType
--left join 
--tblCompanySalesStructureHierarchy b on a.NodeID=b.NodeID
--and a.NodeType=b.NodeType

--where b.NodeID is null and c.UserRank=1

update p set Descr=a.UserName,Designation=a.UserDesignation,PersonEmailID=a.Email,PersonPhone=a.Phone,flgActive=case when a.UserStatus='Active' then 1 else 0 end,TimestampUpd=GETDATE() from #SalesHierarchy a  join tblMstrPerson p on a.UserErpId=p.Code and p.NodeType=case userrank when 0 then 220
when 1 then 210
when 2 then 200
when 3 then 195 end
where isnull(p.flgSFAUser,0)<>1

insert into tblMstrPerson(Code,Descr,Designation,PersonEmailID,PersonPhone,NodeType,
FromDate,ToDate,FileSetIdIns,TimestampIns,FileSetIdUpd,TimestampUpd,flgCompanyPerson,flgDeliveryBoy,flgDriver,flgRegistered,flgWhatsAppReg,flgActive)

select distinct UserErpId,UserName,UserDesignation,Email,Phone,case userrank when 0 then 220
when 1 then 210
when 2 then 200
when 3 then 195 end,CONVERT(date,@currdate),'2050-12-31',0,@currdate,null,null,1,1,1,1,0,case when UserStatus='Active' then 1 else 0 end
 
from #SalesHierarchy a left join tblMstrPerson p on a.UserErpId=p.Code and p.NodeType=case userrank when 0 then 220
when 1 then 210
when 2 then 200
when 3 then 195 end where UserRank in(0,1,2,3) and a.UserErpId is not null and p.NodeID is null


insert into tblMstrPerson(Code,Descr,Designation,PersonEmailID,PersonPhone,NodeType,
FromDate,ToDate,FileSetIdIns,TimestampIns,FileSetIdUpd,TimestampUpd,flgCompanyPerson,flgDeliveryBoy,flgDriver,flgRegistered,flgWhatsAppReg,flgActive)

select distinct UserErpId,UserName,UserDesignation,Email,Phone,case userrank when 0 then 220
when 1 then 210
when 2 then 200
when 3 then 195 end,CONVERT(date,@currdate),'2050-12-31',0,@currdate,null,null,1,1,1,1,0,1
 
from (SELECT 'NA' AS UserErpId,'NA' AS UserName,'' AS UserDesignation,'' AS Email,'' AS Phone,0 AS userrank
UNION ALL
SELECT 'NA' AS UserErpId,'NA' AS UserName,'' AS UserDesignation,'' AS Email,'' AS Phone,1 AS userrank
UNION ALL
SELECT 'NA' AS UserErpId,'NA' AS UserName,'' AS UserDesignation,'' AS Email,'' AS Phone,2 AS userrank
UNION ALL
SELECT 'NA' AS UserErpId,'NA' AS UserName,'' AS UserDesignation,'' AS Email,'' AS Phone,3 AS userrank
)a left join tblMstrPerson p on a.UserErpId=p.Code and p.NodeType=case userrank when 0 then 220
when 1 then 210
when 2 then 200
when 3 then 195 end where UserRank in(0,1,2,3) and a.UserErpId is not null and p.NodeID is null

--union 

--select distinct UserErpId,UserName,UserDesignation,Email,Phone,120,CONVERT(date,@currdate),'2050-12-31',0,@currdate,null,null,1,1,1,1,0,0
 
--from #SalesHierarchy a left join tblMstrPerson p on a.UserErpId=p.Code and p.NodeType= 120
-- where UserRank=1 and a.UserErpId is not null and p.NodeID is null

--update a set from  tblSalesPersonMapping a join 

update tblsalespersonmapping set ToDate=DATEADD(dd,-1,Getdate()) where convert(date,GETDATE()) between FromDate and ToDate
and PersonNodeID not in(select NodeID from tblMstrPerson where isnull(flgSFAUser,0)=1)
--truncate table tblsalespersonmapping
insert into tblsalespersonmapping(PersonNodeID,PersonType,NodeID,NodeType,FromDate,ToDate,FileSetIDIns,
LoginIDIns,TimestampIns,FileSetIDUpd,LoginIDUpd,TimestampUpd,flgOtherLevelPerson)

--Declare @currdate datetime=dbo.fnGetCurrentDateTime()
select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,0,@currdate,null,null,null,0 from #SalesHierarchy a join tblCompanySalesStructureMgnrLvl0 b on a.UserErpId=b.Code
join tblMstrPerson p on p.Code=a.UserErpId
where a.UserRank=3 and p.NodeType=195 and isnull(p.flgSFAUser,0)<>1
union 
select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,0,@currdate,null,null,null,0 from #SalesHierarchy a join tblCompanySalesStructureMgnrLvl1 b on a.UserErpId=b.Code
join tblMstrPerson p on p.Code=a.UserErpId
where a.UserRank=2 and p.NodeType=200 and isnull(p.flgSFAUser,0)<>1
union 
select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,0,@currdate,null,null,null,0 from #SalesHierarchy a join tblCompanySalesStructureMgnrLvl2 b on a.UserErpId=b.Code
join tblMstrPerson p on p.Code=a.UserErpId
where a.UserRank=1 and p.NodeType=210 and isnull(p.flgSFAUser,0)<>1
--union all
--select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,@currdate,null,null,0 from #SalesHierarchy a join tblCompanySalesStructureMgnrLvl4 b on a.UserErpId=b.Code
--join tblMstrPerson p on p.Code=a.UserErpId
--where a.UserRank=2 and p.NodeType=205
--union all
--select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,@currdate,null,null,0 from #SalesHierarchy a join tblCompanySalesStructureMgnrLvl5 b on a.UserErpId=b.Code
--join tblMstrPerson p on p.Code=a.UserErpId
--where a.UserRank=1 and p.NodeType=210
--union all
--select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,@currdate,null,null,0 from #SalesHierarchy a join tblCompanySalesStructureSprvsnLvl1 b on a.UserErpId=b.UnqCode
--join tblMstrPerson p on p.Code=a.UserErpId
--where a.UserRank=1 and p.NodeType=220
union 
select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,0,@currdate,null,null,null,0 from #SalesHierarchy a join tblCompanySalesStructureSprvsnLvl1 b on a.UserErpId=b.UnqCode
join tblMstrPerson p on p.Code=a.UserErpId
where a.UserRank=0 and p.NodeType=220 and isnull(p.flgSFAUser,0)<>1
union 
select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,0,@currdate,null,null,null,0 from #SalesHierarchy a join tblCompanySalesStructureCoverage b on a.UserErpId=b.SOERPID
join tblMstrPerson p on p.Code=a.UserErpId
where a.UserRank=0 and p.NodeType=220 and isnull(p.flgSFAUser,0)<>1
Union 
select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,0,@currdate,null,null,null,0 from tblCompanySalesStructureMgnrLvl0 b
cross join tblMstrPerson p 
where  b.Code='NA' and p.Code='NA' AND p.NodeType=195 and isnull(p.flgSFAUser,0)<>1
union 
select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,0,@currdate,null,null,null,0 from tblCompanySalesStructureMgnrLvl1 b
cross join tblMstrPerson p 
where  b.Code='NA' and p.Code='NA' AND p.NodeType=200 and isnull(p.flgSFAUser,0)<>1
union 
select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,0,@currdate,null,null,null,0 from tblCompanySalesStructureMgnrLvl2 b
cross join tblMstrPerson p 
where  b.Code='NA' and p.Code='NA' AND p.NodeType=210 and isnull(p.flgSFAUser,0)<>1
union 
select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,0,@currdate,null,null,null,0 from tblCompanySalesStructureSprvsnLvl1 b
cross join tblMstrPerson p 
where  b.UnqCode='NA' and p.Code='NA' AND p.NodeType=220 and isnull(p.flgSFAUser,0)<>1
union 
select p.NodeID,p.NodeType,b.NodeID,b.NodeType,CONVERT(date,Getdate()),'2050-12-31',0,0,@currdate,null,null,null,0 from tblCompanySalesStructureCoverage b
cross join tblMstrPerson p 
where  b.SOERPID='NA' and p.Code='NA' AND p.NodeType=220 and isnull(p.flgSFAUser,0)<>1


UPDATE c set PHierId=p.HierID from tblCompanySalesStructureHierarchy c join tblCompanySalesStructureHierarchy p on c.PNodeID=p.NodeID and c.PNodeType=p.NodeType


where c.NodeType<>140 and p.HierID<>c.PHierId and p.NodeID<>0


  Declare @ShopId varchar(50)
  select @ShopId=MAX(LastUpdatedAtAsEpochTime) from tmpSalesHierarchyAPI

  Update tblExtractMaster set LastId=0,TimeStampUpd=@currdate where extractid=2 and isnull(lastid,'')<@ShopId

end


--SELECT * FROM tblsalespersonmapping ORDER BY 1

--select * from tblExtractMaster

--select * from tblCompanySalesStructureHierarchy

--select * from tblMstrPerson

--select * from tblSalesPersonMapping


