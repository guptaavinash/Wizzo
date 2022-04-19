


CREATE Procedure [dbo].[spGetDBRListForPO] 
@IMEI nvarchar(50)='',
@NodeId INT=0,
@NodeType INT=0
AS
begin

if @ImeI<>''
begin
	SELECT @NodeId=P.NodeID,@NodeType=P.NodeType FROM dbo.fnGetPersonIDfromPDACode(@IMEI) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	--SELECT @NodeType=PersonType FROM tblSalesPersonMapping WHERE PersonNodeID=@NodeId

end

Create table #HierIds(NodeId int,NodeType int)

if @NodeType=220
begin
insert into #HierIds select a.NodeID,a.NodeType from tblCompanySalesStructureHierarchy a join tblSalesPersonMapping p on a.PNodeID=p.NodeID
and a.PNodeType=p.NodeType 
where CONVERT(date,GETDATE()) between p.FromDate and p.ToDate
and p.PersonNodeID=@NodeId and p.PersonType=@NodeType and a.PNodeType=120
and convert(date,getdate()) between a.VldFrom and a.VldTo
end
else if @NodeType=210
begin

insert into #HierIds select a.NodeID,a.NodeType from tblCompanySalesStructureHierarchy a join tblSalesPersonMapping p on a.PNodeID=p.NodeID
and a.PNodeType=p.NodeType 
where CONVERT(date,GETDATE()) between p.FromDate and p.ToDate
and p.PersonNodeID=@NodeId and p.PersonType=@NodeType and a.PNodeType=110
and convert(date,getdate()) between a.VldFrom and a.VldTo
union all
select p.NodeID,p.NodeType from  tblSalesPersonMapping p 
where CONVERT(date,GETDATE()) between p.FromDate and p.ToDate
and p.PersonNodeID=@NodeId and p.PersonType=@NodeType and p.NodeType=110

end

;with ashcte as(
select * from #HierIds a 
union all
select b.NodeId,b.NodeType from ashcte a  join tblCompanySalesStructureHierarchy b on a.NodeId=b.PNodeID
and a.NodeType=b.PNodeType
where getdate() between b.VldFrom and b.VldTo ) 
select distinct * into #HierId1s from ashcte option (maxrecursion 0)

Create table #dbrList(dbrnodeId int,dbrNodetype int)
if @NodeType<>0
begin
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
end
else if @NodeType=150
begin
insert into #dbrList(dbrnodeid,dbrnodetype) values (@NodeId,@NodeType)
end
else
begin
insert into #dbrList(dbrnodeid,dbrnodetype)
select distinct NodeID,NodeType from tblDBRSalesStructureDBR where IsActive=1 
end

Declare @StartDate date,@EndDate date

set @EndDate=Getdate()
set @StartDate=convert(date,convert(varchar(6),@EndDate,112)+'01')

if datediff(dd,@StartDate,@EndDate)<8
begin

set @StartDate=dateadd(dd,-7,@StartDate)
end

--IF @ViewAt=1
--BEGIN
SELECT NodeId  as [DBRNodeID],Nodetype as [DistributorNodeType]
      ,[DistributorCode] AS [DBRCode]
      ,z.Descr as [DBRName]
    ,(SELECT Count(*) FROM TBLPURCHASEREQMASTER WHERE SalesNodeId=b.dbrnodeid
and SalesNodeType=b.dbrnodeType AND StatusId<3 and reqdate between @StartDate and @EndDate) as [Total PO]  
,(SELECT Count(*) FROM TBLPURCHASEREQMASTER WHERE SalesNodeId=b.dbrnodeid
and SalesNodeType=b.dbrnodeType AND StatusId=0 and reqdate between @StartDate and @EndDate) as [Pending for Approval/Payment]

,(SELECT Count(*) FROM TBLPURCHASEREQMASTER WHERE SalesNodeId=b.dbrnodeid
and SalesNodeType=b.dbrnodeType AND StatusId=1 and reqdate between @StartDate and @EndDate) as [Approved but Not downloaded]

,(SELECT Count(*) FROM TBLPURCHASEREQMASTER WHERE SalesNodeId=b.dbrnodeid
and SalesNodeType=b.dbrnodeType AND StatusId=2 and reqdate between @StartDate and @EndDate) as [Downloaded PO],
@StartDate as StartDate 
  FROM tbldbrsalesstructuredbr z join #dbrList b on z.nodeid=b.dbrnodeid
  and z.nodetype=b.dbrnodetype
  
  order by [DBRName]
 
--end
--else
--begin

--SELECT NodeId  as [DBRNodeID],Nodetype as [DistributorNodeType]
--      ,[DistributorCode] AS [DBRCode]
--      ,z.Descr as [DBRName]
      
----	  ,format((SELECT Max(isnull(TimeStampUpd,TimeStampIns)) as TimeStamp FROM TBLPURCHASEREQMASTER WHERE SalesNodeId=b.dbrnodeid
----and SalesNodeType=b.dbrnodeType),'dd-MMM-yy hh:mm tt') as [Last Action]
--,convert(numeric(18,0),isnull((SELECT sum(p.Grammage_Act*sp.PcsInBox*l.Qty) FROM TBLPURCHASEREQMASTER k JOIN tblPurchaseReqDetail l on l.PurchReqId=k.PurchReqId
--join tblPrdSAPProductMapping sp join tblPrdMstrSKULvl p on sp.PrdId=p.NodeID on sp.sapprdid=l.SAPPrdId
--WHERE SalesNodeId=b.dbrnodeid
--and SalesNodeType=b.dbrnodeType AND StatusId not in(3,4,5,8) and reqdate between @StartDate and @EndDate and PurchReqType=@POType),0)) as [PO Gen]
--,convert(numeric(18,0),isnull((SELECT sum(p.Grammage_Act*sp.PcsInBox*l.Qty) FROM TBLPURCHASEREQMASTER a  join tblPurchaseSAPSOMaster f on a.PurchReqId=f.PurchReqId
--join tblPurchaseSAPSODetail l on l.SAPSoId=f.SAPSoId
--join tblPrdSAPProductMapping sp join tblPrdMstrSKULvl p on sp.PrdId=p.NodeID on sp.sapprdid=l.SAPPrdId
--WHERE a.SalesNodeId=b.dbrnodeid
--and a.SalesNodeType=b.dbrnodeType and reqdate between @StartDate and @EndDate  and PurchReqType=@POType),0)) as [SO Gen]

--,convert(numeric(18,0),isnull((SELECT sum(p.Grammage_Act*sp.PcsInBox*l.Qty)  FROM TBLPURCHASEREQMASTER a  join tblPurchaseDlvrySchMaster f on a.PurchReqId=f.PurchReqId 
--join tblPurchaseDlvrySchDetail l on l.DlvrySchId=f.DlvrySchId
--join tblPrdSAPProductMapping sp join tblPrdMstrSKULvl p on sp.PrdId=p.NodeID on sp.sapprdid=l.SAPPrdId
--WHERE a.SalesNodeId=b.dbrnodeid
--and a.SalesNodeType=b.dbrnodeType and reqdate between @StartDate and @EndDate  and PurchReqType=@POType),0)) as [SO Scheduled]


--,convert(numeric(18,0),isnull((SELECT sum(p.Grammage_Act*sp.PcsInBox*(f.Qty+f.FreeQty)) FROM TBLPURCHASEREQMASTER a join tblPrimaryInvDetail f on a.PurchReqId=f.PurchReqId
--join tblPrdSAPProductMapping sp join tblPrdMstrSKULvl p on sp.PrdId=p.NodeID on sp.sapprdid=f.SAPPrdId

--WHERE a.SalesNodeId=b.dbrnodeid
--and a.SalesNodeType=b.dbrnodeType  and a.reqdate between @StartDate and @EndDate  and PurchReqType=@POType),0)) as [Invoiced]
--,convert(numeric(18,0),isnull((SELECT sum(p.Grammage_Act*sp.PcsInBox*(f2.Qty+f2.FreeQty)) FROM TBLPURCHASEREQMASTER a join tblPrimaryInvDetail f on a.PurchReqId=f.PurchReqId
--join tblActPrimaryInvMstr f1 on f1.PriInvId=f.PriInvId
--join tblActPrimaryInvDetail f2 on f2.APriInvId=f1.APriInvId
--join tblPrdSAPProductMapping sp join tblPrdMstrSKULvl p on sp.PrdId=p.NodeID on sp.sapprdid=f2.SAPPrdId

--WHERE a.SalesNodeId=b.dbrnodeid
--and a.SalesNodeType=b.dbrnodeType  and a.reqdate between @StartDate and @EndDate  and PurchReqType=@POType),0))  as [Dlvrd],
--@StartDate as StartDate into #DBRLevelDataVol
--  FROM tbldbrsalesstructuredbr z join #dbrList b on z.nodeid=b.dbrnodeid
--  and z.nodetype=b.dbrnodetype
--  where  z.flgActivePOProcess=1

--  SELECT * FROM #DBRLevelDataVol
--  select SUM([PO Gen]) AS [PO Gen],SUM([SO Gen]) AS [SO Gen],SUM([SO Scheduled]) AS [SO Scheduled],SUM([Invoiced]) AS [Invoiced],SUM([Dlvrd]) AS [Dlvrd] from #DBRLevelDataVol

--end







end



--select * from TBLPURCHASEREQMASTER
