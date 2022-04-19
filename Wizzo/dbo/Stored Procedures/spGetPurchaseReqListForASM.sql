

--[spGetPurchaseReqListForASM] '',4286,'18-Nov-2021','19-Nov-2021',-1

--spGetPurchaseReqListForPDA '',0,0,'01-MAY-2020','20-MAY-2020'
--select * from tblPurchaseReqMaster
--[spGetPurchaseReqListForPDA] '351976082609146'
--[spGetPurchaseReqListForASM] '',0,default,default,0
CREATE PROCEDURE [dbo].[spGetPurchaseReqListForASM]
@ImeINo varchar(100)='',
@LoginId int,
@FromDate date='01-Jan-2010',
@todate date='01-Jan-2049',
@StatusId int--0=Open,1=Approved,4=Cancelled
as
begin

Declare @ASMNodeId int, @ASMNodeType int
Create table #SalesHier(SalesNodeId int,SalesNodeType int)
if @ImeINo<>''
begin
select distinct @ASMNodeId=A.PersonID,@ASMNodeType=A.PersonType from dbo.fnGetPersonIDfromPDACode(@ImeINo) A 
set @FromDate='01-Jan-2010'
set @todate='01-Jan-2049'
insert into #SalesHier values(@ASMNodeId,@ASMNodeType)
end
else if @LoginId<>0
begin
select @ASMNodeId=b.NodeID,@ASMNodeType=b.NodeType from tblSecUserLogin a join tblSecUser b on a.UserID=b.UserID
where LoginID=@LoginId
end

Create table #HierIds(NodeId int,NodeType int)


insert into #HierIds select a.NodeID,a.NodeType from tblCompanySalesStructureHierarchy a join tblSalesPersonMapping p on a.PNodeID=p.NodeID
and a.PNodeType=p.NodeType 
where CONVERT(date,GETDATE()) between p.FromDate and p.ToDate
and p.PersonNodeID=@ASMNodeId and p.PersonType=@ASMNodeType and a.PNodeType=110
and convert(date,getdate()) between a.VldFrom and a.VldTo
union all
select p.NodeID,p.NodeType from  tblSalesPersonMapping p 
where CONVERT(date,GETDATE()) between p.FromDate and p.ToDate
and p.PersonNodeID=@ASMNodeId and p.PersonType=@ASMNodeType and p.NodeType=110
;with ashcte as(
select * from #HierIds a 
union all
select b.NodeId,b.NodeType from ashcte a  join tblCompanySalesStructureHierarchy b on a.NodeId=b.PNodeID
and a.NodeType=b.PNodeType
where getdate() between b.VldFrom and b.VldTo ) 
select distinct * into #HierId1s from ashcte option (maxrecursion 0)
--select * from #SOList
Create table #dbrList(dbrnodeId int,dbrNodetype int)

insert into #dbrList(dbrnodeid,dbrnodetype)
select distinct a.DHNodeID,a.DHNodeType from tblCompanySalesStructure_DistributorMapping a join #HierId1s b on a.SHNodeID=b.NodeId
and a.SHNodeType=b.NodeType
where convert(date,getdate()) between a.FromDate and a.ToDate
and a.DHNodeType=150
union all
select distinct h.NodeID,h.NodeType from tblCompanySalesStructure_DistributorMapping a join #HierId1s b on a.SHNodeID=b.NodeId
and a.SHNodeType=b.NodeType
join tblCompanySalesStructureHierarchy h on h.NodeID=a.DHNodeID
and h.NodeType=a.DHNodeType
where convert(date,getdate()) between a.FromDate and a.ToDate
and a.DHNodeType=160 and convert(date,getdate()) between convert(date,h.VldFrom) and h.VldTo


--if @SalesNodetype in(120,100)
--begin

PRINT 'ASDF'

--select * from #dbrList

delete #dbrList where dbrnodeId is null
select a.PurchReqId,case when a.StatusId in(1,2) then 1 else 0 end as flgApproved,case when A.StatusId =4 then 1 else 0 end as flgDelete,c.NodeID as DBNodeId,c.NodeType AS DBNodeType,C.DistributorCode AS DBCode,replace(replace(C.Descr,'&',' and '),'''','') AS DBName,a.PurchReqNo as [Order#],format(ReqDate,'dd-MMM-yy')  as [Order Date],format(Expectedby,'dd-MMM-yy') as [Exp. Dlvry Date],count(d.PrdId) as [# of SKU], convert(numeric(18,2),Round(A.NetAmt,0)) as Value

,
z.ASMStatus 
		 as Status,A.StatusId  from tblPurchaseReqMaster AS A 
		
join tblPurchaseReqdetail D on a.PurchReqId=d.PurchReqId

join 
#dbrList b on a.SalesNodeId=b.dbrnodeId and a.SalesNodeType=b.dbrNodetype
join tblDBRSalesStructuredbr c ON c.nodeid=b.dbrnodeId and c.nodetype=b.dbrNodetype
join [dbo].[tblMstrPurchaseReqProcessStatus] z on a.StatusId=z.POProcessStatusId
 where a.ReqDate between @FromDate and @Todate
 and (A.StatusId=@StatusId or (@StatusId='-1' and A.StatusId in(0,1,4)))
GROUP BY a.PurchReqId,C.DistributorCode,a.PurchReqNo,format(ReqDate,'dd-MMM-yy') ,format(Expectedby,'dd-MMM-yy') , replace(replace(C.Descr,'&',' and '),'''',''),convert(numeric(18,2),Round(A.NetAmt,0)),
z.ASMStatus ,A.StatusId,c.NodeID,c.NodeType
order by dbcode,[Order#]
end
