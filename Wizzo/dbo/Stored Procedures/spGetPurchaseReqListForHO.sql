
--[spGetPurchaseReqListForASM] '',4286,'18-Nov-2021','19-Nov-2021',-1

--spGetPurchaseReqListForPDA '',0,0,'01-MAY-2020','20-MAY-2020'
--select * from tblPurchaseReqMaster
--[spGetPurchaseReqListForPDA] '351976082609146'
--[spGetPurchaseReqListForASM] '',0,default,default,0
CREATE PROCEDURE [dbo].[spGetPurchaseReqListForHO]
@ImeINo varchar(100)='',
@LoginId int,
@FromDate date='01-Jan-2010',
@todate date='01-Jan-2049',
@StatusId int--1=Open,2=Downloaded,-1=All
as
begin

--Declare @ASMNodeId int, @ASMNodeType int
--Create table #SalesHier(SalesNodeId int,SalesNodeType int)
--if @ImeINo<>''
--begin
--select distinct @ASMNodeId=A.PersonID,@ASMNodeType=A.PersonType from dbo.fnGetPersonIDfromPDACode(@ImeINo) A 
--set @FromDate='01-Jan-2010'
--set @todate='01-Jan-2049'
--insert into #SalesHier values(@ASMNodeId,@ASMNodeType)
--end
--else if @LoginId<>0
--begin
--select @ASMNodeId=b.NodeID,@ASMNodeType=b.NodeType from tblSecUserLogin a join tblSecUser b on a.UserID=b.UserID
--where LoginID=@LoginId
--end

--Create table #SOList(NodeId int,NodeType int)


--insert into #SOList select SONodeid,SONodeType from vwSalesHierarchy a join tblSalesPersonMapping p on a.ASMAreaNodeId=p.NodeID
--and a.ASMAreaNodeType=p.NodeType where CONVERT(date,GETDATE()) between p.FromDate and p.ToDate

--Create table #dbrList(dbrnodeId int,dbrNodetype int)

--insert into #dbrList(dbrnodeid,dbrnodetype)
--select distinct s.DBID,s.DBNodeType from tblRoutePlanningVisitDetail a join #SOList b on a.DSENodeId=b.NodeId
--and a.DSENodeType=b.NodeType
--join tblRouteCoverageStoreMapping r on r.RouteID=a.RouteNodeId
--and r.RouteNodeType=a.RouteNodetype
--join tblStoreMaster s on s.StoreID=r.StoreID
--and a.VisitDate>= convert(date,getdate())  and convert(date,getdate()) between r.FromDate and r.ToDate



--if @SalesNodetype in(120,100)
--begin

PRINT 'ASDF'

--select * from #dbrList

select a.PurchReqId,case when a.StatusId in(1,2) then 1 else 0 end as flgApproved,case when A.StatusId =4 then 1 else 0 end as flgDelete,c.NodeID as DBNodeId,c.NodeType AS DBNodeType,C.DistributorCode AS DBCode,replace(replace(C.Descr,'&',' and '),'''','') AS DBName,a.PurchReqNo as [Order#],format(ReqDate,'dd-MMM-yy')  as [Order Date],format(Expectedby,'dd-MMM-yy') as [Exp. Dlvry Date],count(d.PrdId) as [# of SKU], convert(numeric(18,2),Round(A.NetAmt,0)) as Value

,
z.POProcessStatus 
		 as Status,A.StatusId  from tblPurchaseReqMaster AS A 
		
join tblPurchaseReqdetail D on a.PurchReqId=d.PurchReqId


join tblDBRSalesStructuredbr c ON c.nodeid=A.SalesNodeId and c.nodetype=a.SalesNodeType	
join [dbo].[tblMstrPurchaseReqProcessStatus] z on a.StatusId=z.POProcessStatusId
 where a.ReqDate between @FromDate and @Todate
 and A.StatusId=@StatusId or (@StatusId='-1' and A.StatusId in(1,2))
GROUP BY a.PurchReqId,C.DistributorCode,a.PurchReqNo,format(ReqDate,'dd-MMM-yy') ,format(Expectedby,'dd-MMM-yy') , replace(replace(C.Descr,'&',' and '),'''',''),convert(numeric(18,2),Round(A.NetAmt,0)),
z.POProcessStatus ,A.StatusId,c.NodeID,c.NodeType
order by dbcode,[Order#]
end
