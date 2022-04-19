
CREATE PROCEDURE [dbo].[SpSalesHierarchyImport] 
	
AS
BEGIN
	----TRUNCATE TABLE  tblCompanySalesStructureMgnrLvl0
	----TRUNCATE TABLE tblCompanySalesStructureMgnrLvl1
	----TRUNCATE TABLE tblCompanySalesStructureMgnrLvl2
	----TRUNCATE TABLE tblCompanySalesStructureHierarchy
	----TRUNCATE TABLE [dbo].[tblCompanySalesStructureCoverage]
	----TRUNCATE TABLE [dbo].[tblCompanySalesStructureRouteMstr]
	----TRUNCATE TABLE [dbo].[tblCompanySalesStructureSprvsnLvl1]
	----TRUNCATE TABLE tblSalespersonmapping
	----TRUNCATE TABLE tblmstrperson
	----TRUNCATE TABLE tblSalesHierChannelMapping
	----TRUNCATE TABLE tblDBRSalesStructureDBR
	----TRUNCATE TABLE tblCompanySalesStructure_DistributorMapping
	----TRUNCATE TABLE tblSalesHier_GeoHierMapping
	----TRUNCATE TABLE tblRouteCoverage

	UPDATE T SET StateHeadAreaID=NULL,StateHeadAreaHierID=NULL, RSMID=NULL,RegionID=NULL,RegionHierID=NULL,STATEHEADID=NULL,ASMID=NULL,ASMAreaID=NULL,ASMHierID=NULL,TSIID=NULL,SOAreaID=NULL,SOAreaHierID=NULL,CoverageAreaID=NULL,CoverageAreaHierID=NULL,DSMID=NULL,DHNOdeID=NULL,DHNOdeType=NULL,RouteNodeID=NULL,RouteHierID=NULL FROM tmpSalesHierarchyImport T
	--SELECT  * FROM tmpSalesHierarchyImport



	--SELECT * FROM tblCompanySalesStructureMgnrLvl0

	-- RSM Area
	UPDATE T SET RegionID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureMgnrLvl0 L ON L.Descr=T.Region
	UPDATE T SET RegionID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureMgnrLvl0 L ON L.Code=T.RSMEmpCode
	

	UPDATE L SET Descr=T.Region FROM tblCompanySalesStructureMgnrLvl0 L INNER JOIN tmpSalesHierarchyImport T ON T.RegionID=L.NodeID 

	INSERT INTO tblCompanySalesStructureMgnrLvl0(Descr,NodeType,IsActive,TimestampIns)
	SELECT DISTINCT Region,95,1,GETDATE() FROM tmpSalesHierarchyImport T WHERE ISNULL(RegionID,0)=0

	UPDATE T SET RegionID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureMgnrLvl0 L ON L.Code=T.RSMEmpCode
	UPDATE T SET RegionID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureMgnrLvl0 L ON L.Descr=T.Region

	UPDATE T SET RegionHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.RegionID AND H.NodeType=95

	INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	SELECT DISTINCT RegionID,95,0,0,2,0,GETDATE(),'31-Dec-2049',0 FROM  tmpSalesHierarchyImport T WHERE ISNULL(RegionHierID,0)=0

	UPDATE T SET RegionHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.RegionID AND H.NodeType=95

	UPDATE T SET RSMID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.PersonPhone=T.RSMContactNo
	UPDATE T SET RSMID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.Code=T.RSMEmpCode

	INSERT INTO tblMstrPerson(Code,NodeType,Descr,PersonEmailId,PersonPhone,Designation,flgCompanyPerson,FromDate,ToDate,LoginIDIns,TimestampIns,FileSetIdIns)
	SELECT DISTINCT RSMEmpCode,195,RSMName,RSMEMailID,RSMContactNo,'RSM',1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE(),0 FROM tmpSalesHierarchyImport WHERE ISNULL(RSMID,0) =0 AND RSMEmpCode IS NOT NULL

	INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,flgOtherLevelPerson,FromDate,ToDate,LoginIDIns,TimestampIns,FileSetIDIns)
	SELECT DISTINCT T.RSMID,195,T.RegionID,95,1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE(),0 FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=T.RSMID AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate AND SP.NodeID=T.RegionID AND SP.NodeType=95 WHERE SP.NodeID IS NULL AND T.RSMID IS NOT NULL

	INSERT INTO tblSalesHierChannelMapping(SalesStructureNodID,SalesStructureNodType,ChannelID,FromDate,ToDate,LoginIDIns,TimestampIns)
	SELECT DISTINCT RegionID,95,1,GETDATE(),'31-Dec-2021',0,GETDATE() FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblSalesHierChannelMapping M ON M.SalesStructureNodID=T.RegionID AND M.SalesStructureNodType=95 AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate WHERE M.ChannelID IS NULL


	--- State Head

	UPDATE T SET StateHeadAreaID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureMgnrLvl1 L ON L.Descr=T.StateHead

	INSERT INTO tblCompanySalesStructureMgnrLvl1(Descr,NodeType,IsActive,TimestampIns)
	SELECT DISTINCT StateHead,100,1,GETDATE() FROM tmpSalesHierarchyImport T WHERE ISNULL(StateHeadAreaID,0)=0

	UPDATE T SET StateHeadAreaID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureMgnrLvl1 L ON L.Descr=T.StateHead


	UPDATE T SET StateHeadAreaHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.StateHeadAreaID AND H.NodeType=100

	INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	SELECT DISTINCT StateHeadAreaID,100,RegionID,95,2,RegionHierID,GETDATE(),'31-Dec-2049',0 FROM  tmpSalesHierarchyImport T WHERE ISNULL(StateHeadAreaHierID,0)=0

	UPDATE T SET StateHeadAreaHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.StateHeadAreaID AND H.NodeType=100

	UPDATE H SET PHIerID=RegionHierID,PNodeID=T.RegionID,PNodeType=95 FROM  tblCompanySalesStructureHierarchy H INNER JOIN tmpSalesHierarchyImport T ON T.StateHeadAreaHierID=H.HierID

	UPDATE T SET STATEHEADID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.PersonPhone=T.StateHeadContactNo
	UPDATE T SET STATEHEADID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.Code=T.StateHeadEmpCode

	INSERT INTO tblMstrPerson(Code,NodeType,Descr,PersonEmailId,PersonPhone,Designation,flgCompanyPerson,FromDate,ToDate,LoginIDIns,TimestampIns,FileSetIdIns)
	SELECT DISTINCT StateHeadEmpCode,200,StateHeadName,StateHeadEMailID,StateHeadContactNo,'State Head',1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE(),0 FROM tmpSalesHierarchyImport WHERE ISNULL(STATEHEADID,0) =0 AND StateHeadEmpCode IS NOT NULL
		 

	UPDATE T SET STATEHEADID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.PersonPhone=T.StateHeadContactNo
	UPDATE T SET STATEHEADID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.Code=T.StateHeadEmpCode WHERE ISNULL(T.StateHeadEmpCode,'')<>''

	
	INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,flgOtherLevelPerson,FromDate,ToDate,LoginIDIns,TimestampIns,FileSetIDIns)
	SELECT DISTINCT T.STATEHEADID,200,T.StateHeadAreaID,100,1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE(),0 FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=T.STATEHEADID AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate AND SP.NodeID=T.StateHeadAreaID AND SP.NodeType=100 WHERE SP.NodeID IS NULL AND StateheadID IS NOT NULL

	--SELECT 18,210,@ID,120,1,0,GETDATE(),'31-Dec-2049',0,GETDATE()
	INSERT INTO tblSalesHierChannelMapping(SalesStructureNodID,SalesStructureNodType,ChannelID,FromDate,ToDate,LoginIDIns,TimestampIns)
	SELECT DISTINCT StateHeadAreaID,100,1,GETDATE(),'31-Dec-2021',0,GETDATE() FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblSalesHierChannelMapping M ON M.SalesStructureNodID=T.StateHeadAreaID AND M.SalesStructureNodType=100 AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate WHERE M.ChannelID IS NULL

	--- ASM Area
	UPDATE T SET ASMAreaID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureMgnrLvl2 L ON L.Descr=T.ASMArea
	UPDATE T SET ASMAreaID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureMgnrLvl2 L ON L.Code=T.ASMEmpCode
	

	INSERT INTO tblCompanySalesStructureMgnrLvl2(Code,Descr,NodeType,IsActive,TimestampIns)
	SELECT DISTINCT ASMEmpCode,ASMArea,110,1,GETDATE() FROM tmpSalesHierarchyImport T  WHERE ISNULL(ASMAreaID,0)=0

	UPDATE T SET ASMAreaID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureMgnrLvl2 L ON L.Code=T.ASMEmpCode
	UPDATE T SET ASMAreaID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureMgnrLvl2 L ON L.Descr=T.ASMArea


	UPDATE T SET ASMHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.ASMAreaID AND H.NodeType=110

	INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	SELECT DISTINCT ASMAreaID,110,StateHeadAreaID,100,2,StateHeadAreaHierID,GETDATE(),'31-Dec-2049',0 FROM  tmpSalesHierarchyImport T WHERE ISNULL(ASMHierID,0)=0

	UPDATE T SET ASMHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.ASMAreaID AND H.NodeType=110

	UPDATE H SET PHIerID=StateHeadAreaHierID,PNodeID=T.StateHeadAreaID,PNodeType=100 FROM  tblCompanySalesStructureHierarchy H INNER JOIN tmpSalesHierarchyImport T ON T.ASMHierID=H.HierID

	UPDATE T SET ASMID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.PersonPhone=T.ASMContactNo AND NodeType=210
	UPDATE T SET ASMID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.Code=T.ASMEmpCode WHERE ISNULL(T.ASMEmpCode,'')<>'' AND P.NodeType=210

	INSERT INTO tblMstrPerson(Code,NodeType,Descr,PersonEmailId,PersonPhone,Designation,flgCompanyPerson,FromDate,ToDate,LoginIDIns,TimestampIns,FileSetIdIns)
	SELECT DISTINCT ASMEmpCode,210,ASMName,ASMEMailID,ASMContactNo,'ASM',1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE(),0 FROM tmpSalesHierarchyImport WHERE ISNULL(ASMID,0) =0 AND ASMEmpCode IS NOT NULL

	UPDATE T SET ASMID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.PersonPhone=T.ASMContactNo AND NodeType=210
	UPDATE T SET ASMID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.Code=T.ASMEmpCode WHERE ISNULL(T.ASMEmpCode,'')<>'' AND P.NodeType=210

	
	INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,flgOtherLevelPerson,FromDate,ToDate,LoginIDIns,TimestampIns,FileSetIDIns)
	SELECT DISTINCT T.ASMID,P.NodeType,T.ASMAreaID,110,1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE(),0 FROM tmpSalesHierarchyImport T 
	INNER JOIN tblMstrPerson P ON P.NodeID=T.ASMID
	LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=T.ASMID AND SP.PersonType=P.NodeType AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate AND SP.NodeID=T.ASMAreaID AND SP.NodeType=110 WHERE SP.NodeID IS NULL AND T.ASMID IS NOT NULL

	INSERT INTO tblSalesHierChannelMapping(SalesStructureNodID,SalesStructureNodType,ChannelID,FromDate,ToDate,LoginIDIns,TimestampIns)
	SELECT DISTINCT ASMAreaID,110,1,GETDATE(),'31-Dec-2021',0,GETDATE() FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblSalesHierChannelMapping M ON M.SalesStructureNodID=T.ASMAreaID AND M.SalesStructureNodType=110 AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate WHERE M.ChannelID IS NULL


	--- TSI Area

	UPDATE T SET SOAreaID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureSprvsnLvl1 L ON L.UnqCode=T.TSIEmpCode

	INSERT INTO tblCompanySalesStructureSprvsnLvl1(UnqCode,Descr,NodeType,IsActive,TimestampIns)
	SELECT DISTINCT TSIEmpCode,SOArea,120,1,GETDATE() FROM tmpSalesHierarchyImport T WHERE ISNULL(SOAreaID,0)=0

	UPDATE T SET SOAreaID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureSprvsnLvl1 L ON L.UnqCode=T.TSIEmpCode


	UPDATE T SET SOAreaHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.SOAreaID AND H.NodeType=120

	INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	SELECT DISTINCT SOAreaID,120,ASMAreaID,110,2,ASMHierID,GETDATE(),'31-Dec-2049',0 FROM  tmpSalesHierarchyImport T WHERE ISNULL(SOAreaHierID,0)=0

	UPDATE T SET SOAreaHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.SOAreaID AND H.NodeType=120

	UPDATE H SET PHIerID=ASMHierID,PNodeID=T.ASMAreaID,PNodeType=110 FROM  tblCompanySalesStructureHierarchy H INNER JOIN tmpSalesHierarchyImport T ON T.SOAreaHierID=H.HierID

	UPDATE T SET TSIID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.PersonPhone=T.SOContactNo
	UPDATE T SET TSIID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.Code=T.TSIEmpCode WHERE ISNULL(T.TSIEmpCode,'')<>''

	INSERT INTO tblMstrPerson(Code,NodeType,Descr,PersonEmailId,PersonPhone,Designation,flgCompanyPerson,FromDate,ToDate,LoginIDIns,TimestampIns,FileSetIdIns)
	SELECT DISTINCT TSIEmpCode,220,TSIName,SOEMailID,SOContactNo,'TSI',1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE(),0 FROM tmpSalesHierarchyImport WHERE ISNULL(TSIID,0) =0

	UPDATE T SET TSIID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.PersonPhone=T.SOContactNo
	UPDATE T SET TSIID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.Code=T.TSIEmpCode WHERE ISNULL(T.TSIEmpCode,'')<>''

	
	INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,flgOtherLevelPerson,FromDate,ToDate,LoginIDIns,TimestampIns,FileSetIDIns)
	SELECT DISTINCT T.TSIID,P.NodeType,T.SOAreaID,120,1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE(),0 FROM tmpSalesHierarchyImport T
	INNER JOIN tblMstrPerson P ON P.NodeID=T.TSIID
	LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=T.TSIID AND SP.PersonType=P.NodeType AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate AND SP.NodeID=T.SOAreaID AND SP.NodeType=120 WHERE SP.NodeID IS NULL

	INSERT INTO tblSalesHierChannelMapping(SalesStructureNodID,SalesStructureNodType,ChannelID,FromDate,ToDate,LoginIDIns,TimestampIns)
	SELECT DISTINCT SOAreaID,120,1,GETDATE(),'31-Dec-2021',0,GETDATE() FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblSalesHierChannelMapping M ON M.SalesStructureNodID=T.SOAreaID AND M.SalesStructureNodType=120 AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate WHERE M.ChannelID IS NULL


	--INSERT INTO tblSalesHierChannelMapping



	--- DSM Coverage Area

	UPDATE T SET CoverageAreaID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureCoverage L ON L.SOERPID=T.CoverageArea

	INSERT INTO tblCompanySalesStructureCoverage(SOERPID,Descr,NodeType,IsActive,LoginIDIns,TimestampIns)
	SELECT DISTINCT CoverageArea,CoverageArea,130,1,0,GETDATE() FROM tmpSalesHierarchyImport T WHERE ISNULL(CoverageAreaID,0)=0

	UPDATE T SET CoverageAreaID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureCoverage L ON L.SOERPID=T.CoverageArea


	UPDATE T SET CoverageAreaHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.CoverageAreaID AND H.NodeType=130

	INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	SELECT DISTINCT CoverageAreaID,130,SOAreaID,120,2,SOAreaHierID,GETDATE(),'31-Dec-2049',0 FROM  tmpSalesHierarchyImport T WHERE ISNULL(CoverageAreaHierID,0)=0

	UPDATE T SET CoverageAreaHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.CoverageAreaID AND H.NodeType=130

	UPDATE H SET PHIerID=SOAreaHierID,PNodeID=T.SOAreaID,PNodeType=120 FROM  tblCompanySalesStructureHierarchy H INNER JOIN tmpSalesHierarchyImport T ON T.CoverageAreaHierID=H.HierID

	UPDATE P SET flgSFAUser=1 FROM tblMstrPerson P INNER JOIN tmpSalesHierarchyImport T ON T.TSIID=P.NodeID

	INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,flgOtherLevelPerson,FromDate,ToDate,LoginIDIns,TimestampIns,FileSetIDIns)
	SELECT DISTINCT T.TSIID,P.NodeType,T.CoverageAreaID,130,1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE(),0 FROM tmpSalesHierarchyImport T
	INNER JOIN tblMstrPerson P ON P.NodeID=T.TSIID
	LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=T.TSIID AND SP.PersonType=P.NodeType AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate AND SP.NodeID=T.SOAreaID AND SP.NodeType=130 WHERE SP.NodeID IS NULL

	INSERT INTO tblSalesHierChannelMapping(SalesStructureNodID,SalesStructureNodType,ChannelID,FromDate,ToDate,LoginIDIns,TimestampIns)
	SELECT DISTINCT CoverageAreaID,130,1,GETDATE(),'31-Dec-2021',0,GETDATE() FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblSalesHierChannelMapping M ON M.SalesStructureNodID=T.CoverageAreaID AND M.SalesStructureNodType=130 WHERE M.ChannelID IS NULL


	INSERT INTO tblDBRSalesStructureDBR(Descr,DistributorCode,NodeType,IsActive,FileSetIDIns,TimestampIns,flgLive,DlvryWeeklyOffDay,OfficeWeeklyOffDay,IsSuperStockiest)
	SELECT DISTINCT Distributor,T.DistributorCode,150,1,0,GETDATE(),1,7,7,0 FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblDBRSalesStructureDBR D ON D.DistributorCode=T.DistributorCode WHERE D.NodeID IS NULL AND T.Distributor IS NOT NULL

	UPDATE T SET DHNOdeID=B.NodeID,DHNodeType=B.NodeType FROM tmpSalesHierarchyImport T INNER JOIN tblDBRSalesStructureDBR B ON B.DistributorCode=T.DistributorCode

	--UPDATE O SET CovNodeID=SM.NodeID FROM tmpSalesHierarchyImport O INNER JOIN tblMstrPerson P ON P.Descr=O.[User ] INNER JOIN tblSalesPersonMapping SM ON SM.PersonNodeID=P.NodeID AND CAST(GETDATE() AS DATE) BETWEEN SM.FromDate AND SM.ToDate WHERE P.flgSFAUser=1

	--UPDATE O SET CovNodeID=SM.NodeID FROM tmpSalesHierarchyImport O INNER JOIN tblMstrPerson P ON P.Code=O.UserErpID INNER JOIN tblSalesPersonMapping SM ON SM.PersonNodeID=P.NodeID AND CAST(GETDATE() AS DATE) BETWEEN SM.FromDate AND SM.ToDate WHERE P.flgSFAUser=1
	
	INSERT INTO tblCompanySalesStructure_DistributorMapping(DHNodeID,DHNodeType,SHNodeID,SHNodeType,TimestampIns,LoginIDIns,FromDate,ToDate,flgSup)
	SELECT DISTINCT T.DHNodeID,T.DHNodeType,CoverageAreaID,130,GETDATE(),0,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0 FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblCompanySalesStructure_DistributorMapping D ON D.DHNodeID=T.DHNodeID AND D.DHNodeType=T.DHNodeType AND D.SHNOdeID=T.CoverageAreaID AND D.SHNodeType=130 AND CAST(GETDATE() AS DATE) BETWEEN D.FromDate AND D.ToDate AND T.DHNodeID IS NOT NULL AND D.DHNodeID IS NULL WHERE T.DHNodeID IS NOT NULL

	UPDATE T SET StateID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblLocLvl2 L ON L.Descr=T.state

	insert into tblSalesHier_GeoHierMapping(GeoNodeId,GeoNodeType,SalesAreaNodeId,SalesAreaNodeType,FromDate,ToDate)
	select distinct StateId,310,DHNodeID,150,getdate(),'31-Dec-2049'
	from tmpSalesHierarchyImport A left outer join tblSalesHier_GeoHierMapping b on a.DHNodeID=b.SalesAreaNodeId and b.SalesAreaNodeType=150 and a.StateId=b.GeoNodeId and b.GeoNodeType=310 
	where b.GeoNodeId is null and b.GeoNodeType is null and b.SalesAreaNodeId is null and b.SalesAreaNodeType is null and a.DHNodeID is not null




	----UPDATE T SET DSMID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.PersonPhone=T.DSMContactNo
	----UPDATE T SET DSMID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.Code=T.DSMEmpCode WHERE ISNULL(T.DSMEmpCode,'')<>''

	----INSERT INTO tblMstrPerson(Code,NodeType,Descr,PersonEmailId,PersonPhone,Designation,flgCompanyPerson,FromDate,ToDate,LoginIDIns,TimestampIns)
	----SELECT DISTINCT DSMEmpCode,230,DSMName,DSMEMailID,DSMContactNo,'DSM',1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE() FROM tmpSalesHierarchyImport WHERE ISNULL(DSMID,0) =0 AND ISNULL(DSMEmpCode,'')<>''

	----UPDATE T SET DSMID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.PersonPhone=T.DSMContactNo
	----UPDATE T SET DSMID=P.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblMstrPerson P ON P.Code=T.DSMEmpCode WHERE ISNULL(T.DSMEmpCode,'')<>''

	
	----INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,flgOtherLevelPerson,FromDate,ToDate,LoginIDIns,TimestampIns)
	----SELECT DISTINCT T.DSMID,230 ,T.CoverageAreaID,130,1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE() FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=T.DSMID AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate AND SP.NodeID=T.CoverageAreaID AND SP.NodeType=130 WHERE SP.NodeID IS NULL AND T.DSMID IS NOT NULL


	------ Local Beat 
	----UPDATE T SET RouteNodeID=R.NodeID FROM tmpSalesHierarchyImport T  INNER JOIN tblCompanySalesStructureRouteMstr R ON R.Descr=T.RouteName

	----INSERT INTO tblCompanySalesStructureRouteMstr(Descr,NodeType,IsActive,LoginIDIns,TimestampIns,OffDay)
	----SELECT DISTINCT CoverageArea + '-' + RouteName,140,1,0,GETDATE(),7 FROM tmpSalesHierarchyImport T WHERE ISNULL(T.RouteNodeID,0)=0

	----UPDATE T SET RouteNodeID=R.NodeID FROM tmpSalesHierarchyImport T  INNER JOIN tblCompanySalesStructureRouteMstr R ON R.Descr=T.CoverageArea + '-' + T.RouteName

	----UPDATE T SET RouteHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.RouteNodeID AND H.NodeType=140

	----INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo)
	----SELECT DISTINCT RouteNodeID,140,CoverageAreaID,130,2,CoverageAreaHierID,GETDATE(),'31-Dec-2049' FROM  tmpSalesHierarchyImport T WHERE ISNULL(RouteHierID,0)=0

	----UPDATE T SET RouteHierID=H.HierID FROM tmpSalesHierarchyImport T INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=T.RouteNodeID AND H.NodeType=140

	
	----INSERT INTO tblSalesHierChannelMapping(SalesStructureNodID,SalesStructureNodType,ChannelID,FromDate,ToDate,LoginIDIns,TimestampIns)
	----SELECT DISTINCT T.CoverageAreaID,130,1,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0,GETDATE() FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblSalesHierChannelMapping C ON C.SalesStructureNodID=T.CoverageAreaID AND C.SalesStructureNodType=130 AND C.ChannelID=1 WHERE C.ChannelID IS NULL

	----INSERT INTO tblDBRSalesStructureDBR(Descr,DistributorCode,NodeType,IsActive,FileSetIDIns,TimestampIns,flgLive,DlvryWeeklyOffDay,OfficeWeeklyOffDay,IsSuperStockiest)
	----SELECT DISTINCT Distributor,T.DistributorCode,150,1,0,GETDATE(),1,7,7,0 FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblDBRSalesStructureDBR D ON D.DistributorCode=T.DistributorCode WHERE D.NodeID IS NULL

	----UPDATE T SET DHNOdeID=B.NodeID,DHNodeType=B.NodeType FROM tmpSalesHierarchyImport T INNER JOIN tblDBRSalesStructureDBR B ON B.DistributorCode=T.DistributorCode

	----INSERT INTO tblCompanySalesStructure_DistributorMapping(DHNodeID,DHNodeType,SHNodeID,SHNodeType,TimestampIns,LoginIDIns,FromDate,ToDate,flgSup)
	----SELECT DISTINCT T.DHNodeID,T.DHNodeType,CoverageAreaID,130,GETDATE(),0,DATEADD(d,-1,GETDATE()),'31-Dec-2049',0 FROM tmpSalesHierarchyImport T LEFT OUTER JOIN tblCompanySalesStructure_DistributorMapping D ON D.DHNodeID=T.DHNodeID AND D.DHNodeType=T.DHNodeType AND D.SHNOdeID=T.CoverageAreaID AND D.SHNodeType=130 AND CAST(GETDATE() AS DATE) BETWEEN D.FromDate AND D.ToDate AND T.DHNodeID IS NOT NULL AND D.DHNodeID IS NULL

	----UPDATE T SET StateID=L.NodeID FROM tmpSalesHierarchyImport T INNER JOIN tblLocLvl2 L ON L.Descr=T.state

	----insert into tblSalesHier_GeoHierMapping(GeoNodeId,GeoNodeType,SalesAreaNodeId,SalesAreaNodeType,FromDate,ToDate)
	----select distinct StateId,310,DHNodeID,150,getdate(),'31-dEC-2049'
	----from tmpSalesHierarchyImport A left outer join tblSalesHier_GeoHierMapping b on a.DHNodeID=b.SalesAreaNodeId and b.SalesAreaNodeType=150 and a.StateId=b.GeoNodeId and b.GeoNodeType=310 
	----where b.GeoNodeId is null and b.GeoNodeType is null and b.SalesAreaNodeId is null and b.SalesAreaNodeType is null
	
	
	----UPDATE tmpSalesHierarchyImport set Coverage=LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(Coverage,CHAR(13),''),CHAR(10),''),CHAR(9),'')))

	----select distinct Coverage,CovFrqId from tmpSalesHierarchyImport
	------select * from tblMstrCoverageFrequency
	----update tmpSalesHierarchyImport set Coverage='FORTNIGHTLY' where Coverage='FORTNIGHTLY'
	----update tmpSalesHierarchyImport set Coverage='FORTNIGHTLY' where Coverage='Fortnightly'
	----update tmpSalesHierarchyImport set Coverage='FORTNIGHTLY' where Coverage='fourth nightly'
	----update tmpSalesHierarchyImport set Coverage='MONTHLY' where Coverage='Monthly'
	----update tmpSalesHierarchyImport set Coverage='MONTHLY' where Coverage='MONHTLY'

	----UPDATE tmpSalesHierarchyImport set Coverage='Every4thWeek' where Coverage='MONTHLY'
	----UPDATE tmpSalesHierarchyImport set Coverage='Alternate Week' where Coverage='FORTNIGHTLY'
	----UPDATE tmpSalesHierarchyImport set Coverage='Every Week' where Coverage='Weekly'
	----UPDATE tmpSalesHierarchyImport set Coverage='Every Week' where Coverage='daily'

	----update A SET A.CovFrqId=null FROM tmpSalesHierarchyImport A 
	----update A SET A.CovFrqId=B.CovFrqID FROM tmpSalesHierarchyImport A Inner JOIN tblMstrCoverageFrequency B  ON A.Coverage=B.CovFrq 
	------update A SET A.CovFrqId=A.Coverage FROM tmpSalesHierarchyImport A 

	------ALTER TABLE tmpSalesHierarchyImport add WeekId int
	
	----select * from tmpSalesHierarchyImport where CovFrqId=10 order by startdate
	----select * from tmpSalesHierarchyImport where CovFrqId=1 order by startdate
	----update tmpSalesHierarchyImport set startdate=GETDATE() WHERE CovFrqId=1 AND startdate IS NULL
	
	----select * from tmpSalesHierarchyImport where startdate IS NULL

	----update A SET A.WeekId=B.WeekId FROM tmpSalesHierarchyImport A Inner JOIN 
	----(select DISTINCT RouteNodeID,140 RouteNodeType,A.CovFrqId,startdate,MIN(A.WeekId) WeekId FROM tblRoutePlanDetails A INNER JOIN tmpSalesHierarchyImport B ON A.CovFrqID=B.CovFrqId
	----WHERE weekfrom>= CAST(DATEADD(dd, -(DATEPART(dw, startdate)-1), startdate) AS DATE) 
	----GROUP BY RouteNodeID,A.CovFrqId,startdate) B 
	----ON A.RouteNodeID=B.RouteNodeID AND A.CovFrqId=B.CovFrqId

	------update A SET A.WeekId=B.WeekId FROM tmpSalesHierarchyImport A Inner JOIN (select CovFrqId,MIN(WeekId) WeekId FROM tblRoutePlanDetails WHERE weekfrom>= CAST(DATEADD(dd, -(DATEPART(dw, GETDATE())-1), GETDATE()) AS DATE) GROUP BY CovFrqId) B  ON A.CovFrqId=B.CovFrqId 

	----SELECT DISTINCT Mon FROM tmpSalesHierarchyImport 
	----SELECT DISTINCT Tue FROM tmpSalesHierarchyImport 
	----SELECT DISTINCT Wed FROM tmpSalesHierarchyImport 
	----SELECT DISTINCT Thu FROM tmpSalesHierarchyImport 
	----SELECT DISTINCT Fri FROM tmpSalesHierarchyImport 
	----SELECT DISTINCT Sat FROM tmpSalesHierarchyImport 
	----SELECT DISTINCT Sun FROM tmpSalesHierarchyImport 

	----UPDATE tmpSalesHierarchyImport set Mon=null where Mon=''
	----UPDATE tmpSalesHierarchyImport set Tue=null where Tue=''
	----UPDATE tmpSalesHierarchyImport set Wed=null where Wed=''
	----UPDATE tmpSalesHierarchyImport set Thu=null where Thu=''
	----UPDATE tmpSalesHierarchyImport set Fri=null where Fri=''
	----UPDATE tmpSalesHierarchyImport set Sat=null where Sat=''
	----UPDATE tmpSalesHierarchyImport set Sun=null where Sun=''

	----DECLARE @cur CURSOR,@RouteId INT,@RouteNodeType INT,@Mon VARCHAR(5),@Tue VARCHAR(5),@Wed VARCHAR(5),@Thu VARCHAR(5),@Fri VARCHAR(5),@Sat VARCHAR(5),@Sun VARCHAR(5),@CovFrqId INT,@WeekId INT
	----SET @cur = CURSOR FOR
	----SELECT DISTINCT RouteNodeID,140,Mon,Tue,Wed,Thu,Fri,Sat,Sun,CovFrqId,WeekId FROM tmpSalesHierarchyImport where RouteNodeID IS not null AND CovFrqId IS NOT NULL --and WeekId IS NOT NULL
	------SELECT DISTINCT Mon,Tue,Wed,Thu,Fri,Sat,Sun FROM tmpSalesHierarchyImport 
	----OPEN @cur
	----FETCH NEXT FROM @cur INTO @RouteId,@RouteNodeType,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun,@CovFrqId,@WeekId
	----WHILE @@FETCH_STATUS=0
	----BEGIN
		
	----	If @Mon IS NOT NULL
	----	BEGIN			
	----		INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,RouteNodeType,WeekID)
	----		VALUES(@RouteId,@CovFrqId,1,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
	----	END	
	----	If @Tue IS NOT NULL
	----	BEGIN
	----		INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,RouteNodeType,WeekID)
	----		VALUES(@RouteId,@CovFrqId,2,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
	----	END
	----	If @Wed IS NOT NULL
	----	BEGIN
	----		INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,RouteNodeType,WeekID)
	----		VALUES(@RouteId,@CovFrqId,3,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
	----	END
	----	If @Thu IS NOT NULL
	----	BEGIN
	----		INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,RouteNodeType,WeekID)
	----		VALUES(@RouteId,@CovFrqId,4,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
	----	END
	----	If @Fri IS NOT NULL
	----	BEGIN
	----		INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,RouteNodeType,WeekID)
	----		VALUES(@RouteId,@CovFrqId,5,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
	----	END
	----	If @Sat IS NOT NULL
	----	BEGIN
	----		INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,RouteNodeType,WeekID)
	----		VALUES(@RouteId,@CovFrqId,6,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
	----	END
	----	If @Sun IS NOT NULL
	----	BEGIN
	----		INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,RouteNodeType,WeekID)
	----		VALUES(@RouteId,@CovFrqId,7,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
	----	END
		
	----	FETCH NEXT FROM @cur INTO @RouteId,@RouteNodeType,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun,@CovFrqId,@WeekId
	----END


END
