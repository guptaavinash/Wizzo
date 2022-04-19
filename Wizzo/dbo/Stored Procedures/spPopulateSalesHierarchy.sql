
CREATE proc [dbo].[spPopulateSalesHierarchy]
@FileSetId bigint
as
begin
--Declare @FileSetId bigint=0


Declare  @CurrDate datetime=dbo.[fnGetCurrentDateTime]()
  
if (select count(*) from tblCompanySalesStructureMgnrLvl1)=0
begin
	insert into tblCompanySalesStructureMgnrLvl1 (Descr,NodeType,IsActive,FileSetIDIns,TimestampIns)
	values('India',95,1,0,@CurrDate)
end


set @CurrDate =dbo.[fnGetCurrentDateTime]()
insert into tblCompanySalesStructureMgnrLvl2(Descr,NodeType,IsActive,FileSetIDIns,TimestampIns)
select Distinct a.Region,100,1,@FileSetId,@CurrDate from mrco_MI_Sales_User_Relationship a left join tblCompanySalesStructureMgnrLvl2 b on a.Region=b.Descr
where b.Descr is null AND a.CycFileID=@FileSetId

set @CurrDate =dbo.[fnGetCurrentDateTime]()
insert into tblCompanySalesStructureMgnrLvl3(Descr,NodeType,IsActive,FileSetIDIns,TimestampIns)
select Distinct a.RSH_CODE,105,1,@FileSetId,@CurrDate from mrco_MI_Sales_User_Relationship a left join tblCompanySalesStructureMgnrLvl3 b on a.RSH_CODE=b.Descr
where b.Descr is null AND a.CycFileID=@FileSetId


set @CurrDate =dbo.[fnGetCurrentDateTime]()
insert into tblCompanySalesStructureMgnrLvl4(Descr,NodeType,IsActive,FileSetIDIns,TimestampIns)
select Distinct ISNULL(a.ASM_AREA,''),110,1,@FileSetId,@CurrDate from mrco_MI_Sales_User_Relationship a left join tblCompanySalesStructureMgnrLvl4 b on ISNULL(a.ASM_AREA,'')=b.Descr
where b.Descr is null AND a.CycFileID=@FileSetId

set @CurrDate =dbo.[fnGetCurrentDateTime]()
insert into tblCompanySalesStructureSprvsnLvl1(UnqCode,Descr,NodeType,IsActive,FileSetIDIns,TimestampIns)
select Distinct ISNULL(a.ASM_AREA,'')+'-'+ISNULL(a.TSO_TSE_HQ,''),a.TSO_TSE_HQ,120,1,@FileSetId,@CurrDate from mrco_MI_Sales_User_Relationship a left join tblCompanySalesStructureSprvsnLvl1 b on ISNULL(a.ASM_AREA,'')+'-'+ISNULL(a.TSO_TSE_HQ,'')=b.UnqCode
where b.Descr is null AND a.CycFileID=@FileSetId

Update B set b.Descr=a.DISTRIBUTOR_NAME
, b.StateCode=a.DISTRIBUTOR_STATE_Code
, b.StateName=a.DISTRIBUTOR_STATE_Name
, b.City=a.DISTRIBUTOR_CITY
, b.ISRCode=a.ISR_Code
, b.ISRNAME=a.ISR_Name
, b.HQCode=a.HQ_code
, b.FLAG=a.Distributor_Flag,FileSetIDUpd=@FileSetId,TimestampUpd=@CurrDate from mrco_MI_Sales_User_Relationship a  join tbldbrsalesstructuredbr b on a.DISTRIBUTOR_CODE=b.DistributorCode
where (a.DISTRIBUTOR_NAME<>b.Descr
or a.DISTRIBUTOR_STATE_Code<>b.StateCode
or a.DISTRIBUTOR_STATE_Name<>b.StateName
or a.DISTRIBUTOR_CITY<>b.City
or a.ISR_Code<>b.ISRCode
or a.ISR_Name<>b.ISRNAME
or a.HQ_code<>b.HQCode
or a.Distributor_Flag<>b.FLAG)
AND a.CycFileID=@FileSetId

set @CurrDate =dbo.[fnGetCurrentDateTime]()
insert into tbldbrsalesstructuredbr(DistributorCode,Descr,NodeType,IsActive,FLAG,StateCode,StateName,City,ISRCode,ISRNAME,HQCode,FileSetIDIns,TimestampIns)
select Distinct a.DISTRIBUTOR_CODE,a.DISTRIBUTOR_NAME,150,1,A.Distributor_Flag,a.DISTRIBUTOR_STATE_Code,a.DISTRIBUTOR_STATE_Name,a.DISTRIBUTOR_CITY,a.ISR_Code,a.ISR_Name,a.HQ_code,@FileSetId,@CurrDate from mrco_MI_Sales_User_Relationship a left join tbldbrsalesstructuredbr b on a.DISTRIBUTOR_CODE=b.DistributorCode
where b.DistributorCode is null AND a.CycFileID=@FileSetId



set @CurrDate =dbo.[fnGetCurrentDateTime]()
insert into [tblCompanySalesStructureHierarchy](NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)

select a.NodeId,a.NodeType,0,0,2,0,convert(date,@CurrDate),'2050-12-31',@FileSetId from tblCompanySalesStructureMgnrLvl1 a left join [tblCompanySalesStructureHierarchy] b on a.nodeid=b.nodeid
and a.nodetype=b.nodetype
where b.nodeid is null




set @CurrDate =dbo.[fnGetCurrentDateTime]()
insert into tblCompanySalesStructureHierarchy_History
select Hier.HierID,Hier.NodeID,Hier.NodeType,Hier.PNodeID,Hier.PNodeType,Hier.HierTypeID,Hier.PHierId,Hier.VldFrom,Hier.VldTo,Hier.FileSetIdins
FROM            tblCompanySalesStructureMgnrLvl2 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.Descr = Raw.Region INNER JOIN
                         tblCompanySalesStructureMgnrLvl1 AS P ON  P.Descr='India' INNER JOIN
                         tblCompanySalesStructureHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 INNER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
						 where Hier.PnodeId<> PHier.NodeID
						 and raw.CycFileID=@FileSetId

Update Hier set PnodeId= PHier.NodeID , PHierId= PHier.HierID ,VldFrom=CONVERT(DATE,@CurrDate)
FROM            tblCompanySalesStructureMgnrLvl2 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.Descr = Raw.Region INNER JOIN
                         tblCompanySalesStructureMgnrLvl1 AS P ON P.Descr='India' INNER JOIN
                         tblPrdMstrHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 INNER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
						 where Hier.PnodeId<> PHier.NodeID
						 and raw.CycFileID=@FileSetId
set @CurrDate =dbo.[fnGetCurrentDateTime]()

insert into tblCompanySalesStructureHierarchy
SELECT    distinct    C.NodeID, C.NodeType, PHier.NodeID AS Expr1, PHier.NodeType AS Expr2, 1 AS Expr3, PHier.HierID AS Expr4, convert(date,@CurrDate) AS Expr5, '2050-12-31' AS Expr6,@FileSetId
FROM            tblCompanySalesStructureMgnrLvl2 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.Descr = Raw.Region INNER JOIN
                         tblCompanySalesStructureMgnrLvl1 AS P ON  P.Descr='India'  INNER JOIN
                         tblCompanySalesStructureHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 LEFT OUTER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
WHERE        (Hier.HierID IS NULL) and raw.CycFileID=@FileSetId





set @CurrDate =dbo.[fnGetCurrentDateTime]()
insert into tblCompanySalesStructureHierarchy_History
select Hier.HierID,Hier.NodeID,Hier.NodeType,Hier.PNodeID,Hier.PNodeType,Hier.HierTypeID,Hier.PHierId,Hier.VldFrom,Hier.VldTo,Hier.FileSetIdins
FROM            tblCompanySalesStructureMgnrLvl3 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.Descr = Raw.RSH_CODE INNER JOIN
                         tblCompanySalesStructureMgnrLvl2 AS P ON  P.Descr=Raw.Region INNER JOIN
                         tblCompanySalesStructureHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 INNER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
						 where Hier.PnodeId<> PHier.NodeID and raw.CycFileID=@FileSetId

Update Hier set PnodeId= PHier.NodeID , PHierId= PHier.HierID ,VldFrom=CONVERT(DATE,@CurrDate)
FROM            tblCompanySalesStructureMgnrLvl3 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.Descr = Raw.RSH_CODE INNER JOIN
                         tblCompanySalesStructureMgnrLvl2 AS P ON P.Descr=Raw.Region INNER JOIN
                         tblPrdMstrHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 INNER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
						 where Hier.PnodeId<> PHier.NodeID and raw.CycFileID=@FileSetId
set @CurrDate =dbo.[fnGetCurrentDateTime]()

insert into tblCompanySalesStructureHierarchy
SELECT    distinct    C.NodeID, C.NodeType, PHier.NodeID AS Expr1, PHier.NodeType AS Expr2, 1 AS Expr3, PHier.HierID AS Expr4, convert(date,@CurrDate) AS Expr5, '2050-12-31' AS Expr6,@FileSetId
FROM            tblCompanySalesStructureMgnrLvl3 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.Descr = Raw.RSH_CODE INNER JOIN
                         tblCompanySalesStructureMgnrLvl2 AS P ON  P.Descr=Raw.Region  INNER JOIN
                         tblCompanySalesStructureHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 LEFT OUTER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
WHERE        (Hier.HierID IS NULL) and raw.CycFileID=@FileSetId





set @CurrDate =dbo.[fnGetCurrentDateTime]()
insert into tblCompanySalesStructureHierarchy_History
select Hier.HierID,Hier.NodeID,Hier.NodeType,Hier.PNodeID,Hier.PNodeType,Hier.HierTypeID,Hier.PHierId,Hier.VldFrom,Hier.VldTo,Hier.FileSetIdins
FROM            tblCompanySalesStructureMgnrLvl4 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.Descr = Raw.ASM_AREA INNER JOIN
                         tblCompanySalesStructureMgnrLvl3 AS P ON  P.Descr=Raw.RSH_CODE INNER JOIN
                         tblCompanySalesStructureHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 INNER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
						 where Hier.PnodeId<> PHier.NodeID and raw.CycFileID=@FileSetId

Update Hier set PnodeId= PHier.NodeID , PHierId= PHier.HierID ,VldFrom=CONVERT(DATE,@CurrDate)
FROM            tblCompanySalesStructureMgnrLvl4 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.Descr = Raw.ASM_AREA INNER JOIN
                         tblCompanySalesStructureMgnrLvl3 AS P ON P.Descr=Raw.RSH_CODE INNER JOIN
                         tblPrdMstrHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 INNER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
						 where Hier.PnodeId<> PHier.NodeID and raw.CycFileID=@FileSetId
set @CurrDate =dbo.[fnGetCurrentDateTime]()

insert into tblCompanySalesStructureHierarchy
SELECT    distinct    C.NodeID, C.NodeType, PHier.NodeID AS Expr1, PHier.NodeType AS Expr2, 1 AS Expr3, PHier.HierID AS Expr4, convert(date,@CurrDate) AS Expr5, '2050-12-31' AS Expr6,@FileSetId
FROM            tblCompanySalesStructureMgnrLvl4 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.Descr = Raw.ASM_AREA INNER JOIN
                         tblCompanySalesStructureMgnrLvl3 AS P ON  P.Descr=Raw.RSH_CODE  INNER JOIN
                         tblCompanySalesStructureHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 LEFT OUTER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
WHERE        (Hier.HierID IS NULL) and raw.CycFileID=@FileSetId



set @CurrDate =dbo.[fnGetCurrentDateTime]()
insert into tblCompanySalesStructureHierarchy_History
select Hier.HierID,Hier.NodeID,Hier.NodeType,Hier.PNodeID,Hier.PNodeType,Hier.HierTypeID,Hier.PHierId,Hier.VldFrom,Hier.VldTo,Hier.FileSetIdins
FROM            tblCompanySalesStructureSprvsnLvl1 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.UnqCode = ISNULL(Raw.ASM_AREA,'')+'-'+ISNULL(Raw.TSO_TSE_HQ,'') INNER JOIN
                         tblCompanySalesStructureMgnrLvl4 AS P ON  P.Descr=Raw.ASM_AREA INNER JOIN
                         tblCompanySalesStructureHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 INNER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
						 where Hier.PnodeId<> PHier.NodeID and raw.CycFileID=@FileSetId

Update Hier set PnodeId= PHier.NodeID , PHierId= PHier.HierID ,VldFrom=CONVERT(DATE,@CurrDate)
FROM            tblCompanySalesStructureSprvsnLvl1 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.UnqCode = ISNULL(Raw.ASM_AREA,'')+'-'+ISNULL(Raw.TSO_TSE_HQ,'') INNER JOIN
                         tblCompanySalesStructureMgnrLvl4 AS P ON P.Descr=Raw.ASM_AREA INNER JOIN
                         tblPrdMstrHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 INNER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
						 where Hier.PnodeId<> PHier.NodeID and raw.CycFileID=@FileSetId
set @CurrDate =dbo.[fnGetCurrentDateTime]()

insert into tblCompanySalesStructureHierarchy
SELECT    distinct    C.NodeID, C.NodeType, PHier.NodeID AS Expr1, PHier.NodeType AS Expr2, 1 AS Expr3, PHier.HierID AS Expr4, convert(date,@CurrDate) AS Expr5, '2050-12-31' AS Expr6,@FileSetId
FROM            tblCompanySalesStructureSprvsnLvl1 AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.UnqCode = ISNULL(Raw.ASM_AREA,'')+'-'+ISNULL(Raw.TSO_TSE_HQ,'') INNER JOIN
                         tblCompanySalesStructureMgnrLvl4 AS P ON  P.Descr=Raw.ASM_AREA  INNER JOIN
                         tblCompanySalesStructureHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 LEFT OUTER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
WHERE        (Hier.HierID IS NULL) and raw.CycFileID=@FileSetId




set @CurrDate =dbo.[fnGetCurrentDateTime]()
insert into tblCompanySalesStructureHierarchy_History
select Hier.HierID,Hier.NodeID,Hier.NodeType,Hier.PNodeID,Hier.PNodeType,Hier.HierTypeID,Hier.PHierId,Hier.VldFrom,Hier.VldTo,Hier.FileSetIdins
FROM            tblDBRSalesStructureDBR AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.DistributorCode = Raw.DISTRIBUTOR_CODE INNER JOIN
                         tblCompanySalesStructureSprvsnLvl1 AS P ON  P.UnqCode = ISNULL(Raw.ASM_AREA,'')+'-'+ISNULL(Raw.TSO_TSE_HQ,'') INNER JOIN
                         tblCompanySalesStructureHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 INNER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
						 where Hier.PnodeId<> PHier.NodeID and raw.CycFileID=@FileSetId

Update Hier set PnodeId= PHier.NodeID , PHierId= PHier.HierID ,VldFrom=CONVERT(DATE,@CurrDate)
FROM            tblDBRSalesStructureDBR AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.DistributorCode = Raw.DISTRIBUTOR_CODE INNER JOIN
                         tblCompanySalesStructureSprvsnLvl1 AS P ON  P.UnqCode = ISNULL(Raw.ASM_AREA,'')+'-'+ISNULL(Raw.TSO_TSE_HQ,'') INNER JOIN
                         tblPrdMstrHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 INNER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
						 where Hier.PnodeId<> PHier.NodeID and raw.CycFileID=@FileSetId
set @CurrDate =dbo.[fnGetCurrentDateTime]()

insert into tblCompanySalesStructureHierarchy
SELECT    distinct    C.NodeID, C.NodeType, PHier.NodeID AS Expr1, PHier.NodeType AS Expr2, 1 AS Expr3, PHier.HierID AS Expr4, convert(date,@CurrDate) AS Expr5, '2050-12-31' AS Expr6,@FileSetId
FROM           tblDBRSalesStructureDBR AS C INNER JOIN
                         mrco_MI_Sales_User_Relationship AS Raw ON C.DistributorCode = Raw.DISTRIBUTOR_CODE INNER JOIN
                         tblCompanySalesStructureSprvsnLvl1 AS P ON  P.UnqCode = ISNULL(Raw.ASM_AREA,'')+'-'+ISNULL(Raw.TSO_TSE_HQ,'')  INNER JOIN
                         tblCompanySalesStructureHierarchy AS PHier ON P.NodeID = PHier.NodeID AND P.NodeType = PHier.NodeType 
						  AND CONVERT(DATE,@CurrDate) BETWEEN PHier.VldFrom AND PHier.VldTo
						 LEFT OUTER JOIN
                         tblCompanySalesStructureHierarchy AS Hier ON C.NodeID = Hier.NodeID
						 and  C.Nodetype = Hier.Nodetype 	 AND CONVERT(DATE,@CurrDate) BETWEEN Hier.VldFrom AND Hier.VldTo
WHERE        (Hier.HierID IS NULL) and raw.CycFileID=@FileSetId



insert into tblmstrperson
select distinct GSM_CODE,GSM_Name,'GSM','',0,195,@CurrDate,'2050-12-31',@FileSetId,@CurrDate,null,null,1,0,0,0,0,0 from mrco_MI_Sales_User_Relationship a left join tblmstrperson b on a.GSM_CODE=b.code
where b.nodeid is null  and a.CycFileID=@FileSetId


insert into tblmstrperson
select distinct RSM_CODE,RSM_Name,'RSM','',0,200,@CurrDate,'2050-12-31',@FileSetId,@CurrDate,null,null,1,0,0,0,0,0 from mrco_MI_Sales_User_Relationship a left join tblmstrperson b on a.RSM_CODE=b.code
where b.nodeid is null  and a.CycFileID=@FileSetId


insert into tblmstrperson
select distinct RSH_CODE,RSH_Name,'RSH','',0,205,@CurrDate,'2050-12-31',@FileSetId,@CurrDate,null,null,1,0,0,0,0,0 from mrco_MI_Sales_User_Relationship a left join tblmstrperson b on a.RSH_CODE=b.code
where b.nodeid is null  and a.CycFileID=@FileSetId

insert into tblmstrperson
select distinct ASM_CODE,ASM_Name,'ASM','',0,210,@CurrDate,'2050-12-31',@FileSetId,@CurrDate,null,null,1,0,0,0,0,0 from mrco_MI_Sales_User_Relationship a left join tblmstrperson b on a.ASM_CODE=b.code
where b.nodeid is null  and a.CycFileID=@FileSetId

insert into tblmstrperson
select distinct TSO_TSE_CODE,TSO_TSE_Name,'TSO','',0,220,@CurrDate,'2050-12-31',@FileSetId,@CurrDate,null,null,1,0,0,0,0,0 from mrco_MI_Sales_User_Relationship a left join tblmstrperson b on a.TSO_TSE_CODE=b.code
where b.nodeid is null  and a.CycFileID=@FileSetId


UPDATE A SET ToDate=DATEADD(dd,-1,convert(date,@CurrDate)),FilesetIdUpd=@FileSetId,TimestampUpd=@CurrDate FROM tblSalesPersonMapping a join tblCompanySalesStructureMgnrLvl1 b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType
join tblMstrPerson p on p.NodeID=a.PersonNodeID
join (select distinct GSM_CODE,'India' as Descr from mrco_MI_Sales_User_Relationship  where CycFileID=@FileSetId) r on r.GSM_CODE<>p.Code 
and b.Descr=r.Descr
where convert(date,@CurrDate) between convert(date,a.FromDate) and convert(date,a.ToDate)

insert into tblSalesPersonMapping

select p.NodeID,p.NodeType,b.NodeID,b.NodeType,convert(date,@CurrDate),'2050-12-31',@FileSetId,@CurrDate,null,null,0 from (select distinct GSM_CODE,'India' as Descr from mrco_MI_Sales_User_Relationship  where CycFileID=@FileSetId) r
inner join  tblMstrPerson p on r.GSM_CODE=p.Code 
join tblCompanySalesStructureMgnrLvl1 b on b.Descr=r.Descr
left join tblSalesPersonMapping a on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,@CurrDate) between convert(date,a.FromDate) and convert(date,a.ToDate)
where a.NodeID is null



UPDATE A SET ToDate=DATEADD(dd,-1,convert(date,@CurrDate)),FilesetIdUpd=@FileSetId,TimestampUpd=@CurrDate FROM tblSalesPersonMapping a join tblCompanySalesStructureMgnrLvl2 b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType
join tblMstrPerson p on p.NodeID=a.PersonNodeID
join (select distinct RSM_CODE as Code,Region as Descr from mrco_MI_Sales_User_Relationship  where CycFileID=@FileSetId) r on r.Code<>p.Code 
and b.Descr=r.Descr
where convert(date,@CurrDate) between convert(date,a.FromDate) and convert(date,a.ToDate)

insert into tblSalesPersonMapping

select p.NodeID,p.NodeType,b.NodeID,b.NodeType,convert(date,@CurrDate),'2050-12-31',@FileSetId,@CurrDate,null,null,0 from (select distinct RSM_CODE as Code,Region as Descr from mrco_MI_Sales_User_Relationship  where CycFileID=@FileSetId) r
inner join  tblMstrPerson p on r.Code=p.Code 
join tblCompanySalesStructureMgnrLvl2 b on b.Descr=r.Descr
left join tblSalesPersonMapping a on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,@CurrDate) between convert(date,a.FromDate) and convert(date,a.ToDate)
where a.NodeID is null



UPDATE A SET ToDate=DATEADD(dd,-1,convert(date,@CurrDate)),FilesetIdUpd=@FileSetId,TimestampUpd=@CurrDate FROM tblSalesPersonMapping a join tblCompanySalesStructureMgnrLvl3 b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType
join tblMstrPerson p on p.NodeID=a.PersonNodeID
join (select distinct RSh_CODE as Code,RSh_CODE as Descr from mrco_MI_Sales_User_Relationship  where CycFileID=@FileSetId) r on r.Code<>p.Code 
and b.Descr=r.Descr
where convert(date,@CurrDate) between convert(date,a.FromDate) and convert(date,a.ToDate)

insert into tblSalesPersonMapping

select p.NodeID,p.NodeType,b.NodeID,b.NodeType,convert(date,@CurrDate),'2050-12-31',@FileSetId,@CurrDate,null,null,0 from (select distinct RSh_CODE as Code,RSh_CODE as Descr from mrco_MI_Sales_User_Relationship  where CycFileID=@FileSetId) r
inner join  tblMstrPerson p on r.Code=p.Code 
join tblCompanySalesStructureMgnrLvl3 b on b.Descr=r.Descr
left join tblSalesPersonMapping a on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,@CurrDate) between convert(date,a.FromDate) and convert(date,a.ToDate)
where a.NodeID is null


UPDATE A SET ToDate=DATEADD(dd,-1,convert(date,@CurrDate)),FilesetIdUpd=@FileSetId,TimestampUpd=@CurrDate FROM tblSalesPersonMapping a join tblCompanySalesStructureMgnrLvl4 b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType
join tblMstrPerson p on p.NodeID=a.PersonNodeID
join (select distinct ASM_CODE as Code,ASM_AREA as Descr from mrco_MI_Sales_User_Relationship  where CycFileID=@FileSetId) r on r.Code<>p.Code 
and b.Descr=r.Descr
where convert(date,@CurrDate) between convert(date,a.FromDate) and convert(date,a.ToDate)

insert into tblSalesPersonMapping

select p.NodeID,p.NodeType,b.NodeID,b.NodeType,convert(date,@CurrDate),'2050-12-31',@FileSetId,@CurrDate,null,null,0 from (select distinct ASM_CODE as Code,ASM_AREA as Descr from mrco_MI_Sales_User_Relationship  where CycFileID=@FileSetId) r
inner join  tblMstrPerson p on r.Code=p.Code 
join tblCompanySalesStructureMgnrLvl4 b on b.Descr=r.Descr
left join tblSalesPersonMapping a on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,@CurrDate) between convert(date,a.FromDate) and convert(date,a.ToDate)
where a.NodeID is null




UPDATE A SET ToDate=DATEADD(dd,-1,convert(date,@CurrDate)),FilesetIdUpd=@FileSetId,TimestampUpd=@CurrDate FROM tblSalesPersonMapping a join tblCompanySalesStructureSprvsnLvl1 b on a.NodeID=b.NodeID
and a.NodeType=b.NodeType
join tblMstrPerson p on p.NodeID=a.PersonNodeID
join (select distinct TSO_TSE_CODE as Code,ISNULL(ASM_AREA,'')+'-'+ISNULL(TSO_TSE_HQ,'') as Descr from mrco_MI_Sales_User_Relationship  where CycFileID=@FileSetId) r on r.Code<>p.Code 
and b.UNqcode=r.Descr
where convert(date,@CurrDate) between convert(date,a.FromDate) and convert(date,a.ToDate)

insert into tblSalesPersonMapping

select p.NodeID,p.NodeType,b.NodeID,b.NodeType,convert(date,@CurrDate),'2050-12-31',@FileSetId,@CurrDate,null,null,0 from (select distinct TSO_TSE_CODE as Code,ISNULL(ASM_AREA,'')+'-'+ISNULL(TSO_TSE_HQ,'') as Descr from mrco_MI_Sales_User_Relationship  where CycFileID=@FileSetId) r
inner join  tblMstrPerson p on r.Code=p.Code 
join tblCompanySalesStructureSprvsnLvl1 b on b.UNqcode=r.Descr
left join tblSalesPersonMapping a on a.NodeID=b.NodeID
and a.NodeType=b.NodeType and convert(date,@CurrDate) between convert(date,a.FromDate) and convert(date,a.ToDate)
where a.NodeID is null
end
