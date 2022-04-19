-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpUpdateSFAHierarchy] 
	
AS
BEGIN
	SELECT * FROM tblPMstNodeTypes
	SELECT * FROM tblCompanySalesStructureMgnrLvl0
	SELECT * FROM RajSFAHierarchy

	----ALTER TABLE RajSFAHierarchy ADD OLDDSRAreaID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD OLDSOAreaID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD OLDASMAreaID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD OLDRSMAreaID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD OLDStateHeadAreaID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD OLDStateHeadID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD OLDRSMID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD OLDASMID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD OLDSOID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD OLDDSRID INT NULL

	----ALTER TABLE RajSFAHierarchy ADD NEWDSRAreaID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD NEWSOAreaID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD NEWASMAreaID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD NEWRSMAreaID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD NEWStateHeadAreaID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD NEWStateHeadID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD NEWRSMID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD NEWASMID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD NEWSOID INT NULL
	----ALTER TABLE RajSFAHierarchy ADD NEWDSRID INT NULL
	

	SELECT DISTINCT RSMArea,[RSM EmpCode],RSMPersonName FROM RajSFAHierarchy
	SELECT DISTINCT StateHeadArea,[StateHead EmpCode],StateHeadPersonName FROM RajSFAHierarchy
	SELECT DISTINCT ASMArea,ASMEmpCode,ASMPersonName FROM RajSFAHierarchy
	SELECT DISTINCT SOArea,SOEmpCode,SOPersonName FROM RajSFAHierarchy

	UPDATE R SET OLDSOAreaID=NULL,OLDASMAreaID=NUll,OLDStateHeadAreaID=NULL,OLDRSMAreaID=NULL,OLDRSMID=NULL,OLDStateHeadID=NULL,OLDASMID=NULL,OLDSOID=NULL,OLDDSRAreaID=NULL,OLDDSRID=NULL FROM RajSFAHierarchy R

	UPDATE R SET NEWRSMAreaID=NULL,NEWStateHeadAreaID=NULL,NEWASMAreaID=NULL,NEWSOAreaID=NULL,NEWDSRAreaID = NULL,NEWRSMID=NULL,NEWStateHeadID=NULL,NEWASMID=NULL,NEWSOID=NULL,NEWDSRID=NULL FROM RajSFAHierarchy R
	

	UPDATE RajSFAHierarchy SET [RSM EmpCode]=NULL,RSMPersonName=NULL WHERE RSMPersonName like '%VACANT%'
	UPDATE RajSFAHierarchy SET [StateHead EmpCode]=NULL,StateHeadPersonName=NULL WHERE StateHeadPersonName like '%VACANT%'
	UPDATE RajSFAHierarchy SET [StateHead EmpCode]=NULL,StateHeadPersonName=NULL WHERE StateHeadPersonName like '%NA%'

	UPDATE RajSFAHierarchy SET ASMEmpCode=NULL,ASMPersonName=NULL WHERE ASMPersonName like '%VACANT%'
	UPDATE RajSFAHierarchy SET ASMEmpCode='EMP00664',ASMPersonName='AJAY DUBEY' WHERE ASMArea like '%Uttar Pradesh2%'

	UPDATE RajSFAHierarchy SET SOEmpCode=NULL,SOPersonName=NULL WHERE SOPersonName like '%VACANT%'
	UPDATE RajSFAHierarchy SET SOEmpCode=NULL,SOPersonName=NULL WHERE SOPersonName ='NULL'

	UPDATE RajSFAHierarchy SET DSRArea=SOArea ,DSREmpCode=SOEmpCode,DSRPersonName=SOPersonName
	
	UPDATE R SET OLDRSMAreaID=V.RSMAreaID FROM RajSFAHierarchy R INNER JOIN  VwCompanyDSRFullDetail V ON V.DSRAreaID=R.DSRAreaID
	UPDATE R SET OLDStateHeadAreaID=V.StateHeadAreaID FROM RajSFAHierarchy R INNER JOIN  VwCompanyDSRFullDetail V ON V.DSRAreaID=R.DSRAreaID
	UPDATE R SET OLDASMAreaID=V.ASMAreaID FROM RajSFAHierarchy R INNER JOIN  VwCompanyDSRFullDetail V ON V.DSRAreaID=R.DSRAreaID
	UPDATE R SET OLDSOAreaID=V.SOAreaID FROM RajSFAHierarchy R INNER JOIN  VwCompanyDSRFullDetail V ON V.DSRAreaID=R.DSRAreaID
	UPDATE R SET OLDDSRAreaID=V.DSRAreaID FROM RajSFAHierarchy R INNER JOIN  VwCompanyDSRFullDetail V ON V.DSRAreaID=R.DSRAreaID
	

	UPDATE R SET OLDRSMID=V.RSMID FROM RajSFAHierarchy R INNER JOIN  VwCompanyDSRFullDetail V ON V.DSRAreaID=R.DSRAreaID
	UPDATE R SET OLDStateHeadID=V.StateHeadID FROM RajSFAHierarchy R INNER JOIN  VwCompanyDSRFullDetail V ON V.DSRAreaID=R.DSRAreaID
	UPDATE R SET OLDASMID=V.ASMID FROM RajSFAHierarchy R INNER JOIN  VwCompanyDSRFullDetail V ON V.DSRAreaID=R.DSRAreaID
	UPDATE R SET OLDSOID=V.SOID FROM RajSFAHierarchy R INNER JOIN  VwCompanyDSRFullDetail V ON V.DSRAreaID=R.DSRAreaID
	UPDATE R SET OLDDSRID=V.CompanyDSRID FROM RajSFAHierarchy R INNER JOIN  VwCompanyDSRFullDetail V ON V.DSRAreaID=R.DSRAreaID

	UPDATE L SET Descr=R.RSMArea FROM tblCompanySalesStructureMgnrLvl0 L INNER JOIN RajSFAHierarchy R ON R.OLDRSMAreaID=L.NodeID
	UPDATE L SET Descr=R.StateHeadArea FROM tblCompanySalesStructureMgnrLvl1 L INNER JOIN RajSFAHierarchy R ON R.OLDStateHeadAreaID=L.NodeID
	UPDATE L SET Descr=R.ASMArea FROM tblCompanySalesStructureMgnrLvl2 L INNER JOIN RajSFAHierarchy R ON R.OLDASMAreaID=L.NodeID
	UPDATE L SET Descr=R.SOArea FROM tblCompanySalesStructureSprvsnLvl1 L INNER JOIN RajSFAHierarchy R ON R.OLDSOAreaID=L.NodeID
	UPDATE L SET Descr=R.DSRArea FROM tblCompanySalesStructureCoverage L INNER JOIN RajSFAHierarchy R ON R.OLDDSRAreaID=L.NodeID

		
	
	UPDATE R SET NEWRSMAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureMgnrLvl0 V ON V.Descr=R.RSMArea
	UPDATE R SET NEWStateHeadAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureMgnrLvl1 V ON V.Descr=R.StateHeadArea
	UPDATE R SET NEWASMAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureMgnrLvl2 V ON V.Descr=R.ASMArea
	UPDATE R SET NEWSOAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureSprvsnLvl1 V ON V.Descr=R.SOArea
	UPDATE R SET NEWDSRAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureCoverage V ON V.Descr=R.DSRArea

	INSERT INTO tblCompanySalesStructureMgnrLvl0(Code,Descr,NodeType,IsActive,FileSetIdIns,TimestampIns)
	SELECT DISTINCT [RSM EmpCode],RSMArea,95,1,0,GETDATE() FROM RajSFAHierarchy WHERE Status='Active' AND NewRSMAreaID IS NULL

	UPDATE R SET NEWRSMAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureMgnrLvl0 V ON V.Descr=R.RSMArea

	INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	SELECT DISTINCT L.NodeID,L.NodeType,0,0,2,0,GETDATE(),'31-Dec-2049',0 FROM tblCompanySalesStructureMgnrLvl0 L LEFT OUTER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=L.NodeID AND H.NodeType=L.NodeType WHERE H.HierID IS NULL

	UPDATE R SET NEWRSMAreaHierID=H.HierID FROM RajSFAHierarchy R INNER JOIN tblCompanySalesStructureMgnrLvl0 L ON L.Descr=R.RSMArea INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=L.NodeID AND H.NodeType=L.NodeType
		
	INSERT INTO tblCompanySalesStructureMgnrLvl1(Code,Descr,NodeType,IsActive,FileSetIdIns,TimestampIns) 
	SELECT DISTINCT [StateHead EmpCode],StateHeadArea + '-' + RSMArea,100,1,0,GETDATE() FROM RajSFAHierarchy WHERE Status='Active' AND NEWStateHeadAreaID IS NULL

	UPDATE R SET NEWStateHeadAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureMgnrLvl1 V ON V.Descr=R.StateHeadArea + '-' + RSMArea

	INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	SELECT DISTINCT R.NEWStateHeadAreaID,100,R.NEWRSMAreaID,95,2,R.NEWRSMAreaHierID,GETDATE(),'31-Dec-2049',0 FROM RajSFAHierarchy R INNER JOIN tblCompanySalesStructureMgnrLvl1 L ON L.Descr=R.StateHeadArea + '-' + RSMArea LEFT OUTER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=L.NodeID AND H.NodeType=L.NodeType WHERE H.HierID IS NULL 

	UPDATE R SET NEWStateHeadAreaHierID=H.HierID FROM RajSFAHierarchy R INNER JOIN tblCompanySalesStructureMgnrLvl1 L ON L.Descr=R.StateHeadArea INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=L.NodeID AND H.NodeType=L.NodeType
	UPDATE R SET NEWStateHeadAreaHierID=H.HierID FROM RajSFAHierarchy R INNER JOIN tblCompanySalesStructureMgnrLvl1 L ON L.Descr=R.StateHeadArea + '-' + RSMArea INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=L.NodeID AND H.NodeType=L.NodeType

	INSERT INTO tblCompanySalesStructureMgnrLvl2(Code,Descr,NodeType,IsActive,FileSetIdIns,TimestampIns)
	SELECT DISTINCT [ASMEmpCode],ASMArea,110,1,0,GETDATE() FROM RajSFAHierarchy WHERE Status='Active' AND NEWASMAreaID IS NULL

	UPDATE R SET NEWASMAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureMgnrLvl2 V ON V.Descr=R.ASMArea

	INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	SELECT DISTINCT R.NEWASMAreaID,110,R.NEWStateHeadAreaID,100,2,R.NEWStateHeadAreaHierID,GETDATE(),'31-Dec-2049',0 FROM RajSFAHierarchy R INNER JOIN tblCompanySalesStructureMgnrLvl2 L ON L.Descr=R.ASMArea LEFT OUTER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=L.NodeID AND H.NodeType=L.NodeType WHERE H.HierID IS NULL
	
	UPDATE R SET NewASMAreaHierID=H.HierID FROM RajSFAHierarchy R INNER JOIN tblCompanySalesStructureMgnrLvl2 L ON L.Descr=R.ASMArea INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=L.NodeID AND H.NodeType=L.NodeType

	INSERT INTO tblCompanySalesStructureSprvsnLvl1(UnqCode,Descr,NodeType,IsActive,FileSetIdIns,TimestampIns)
	SELECT DISTINCT [SOEmpCode],SOArea,120,1,0,GETDATE() FROM RajSFAHierarchy WHERE Status='Active' AND NEWSOAreaID IS NULL

	UPDATE R SET NEWSOAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureSprvsnLvl1 V ON V.Descr=R.SOArea

	INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	SELECT DISTINCT R.NEWSOAreaID,120,R.NEWASMAreaID,110,2,R.NewASMAreaHierID,GETDATE(),'31-Dec-2049',0 FROM RajSFAHierarchy R INNER JOIN tblCompanySalesStructureSprvsnLvl1 L ON L.Descr=R.SOArea LEFT OUTER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=L.NodeID AND H.NodeType=L.NodeType WHERE H.HierID IS NULL

	UPDATE R SET NewSOAreaHierID=H.HierID FROM RajSFAHierarchy R INNER JOIN tblCompanySalesStructureSprvsnLvl1 L ON L.Descr=R.SOArea INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=L.NodeID AND H.NodeType=L.NodeType

	INSERT INTO tblCompanySalesStructureCoverage(Descr,NodeType,IsActive,TimestampIns)
	SELECT DISTINCT DSRArea,130,1,GETDATE() FROM RajSFAHierarchy WHERE Status='Active' AND NEWDSRAreaID IS NULL

	UPDATE R SET NEWDSRAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureCoverage V ON V.Descr=R.DSRArea

	INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,FileSetIdIns)
	SELECT DISTINCT R.NEWDSRAreaID,130,R.NEWSOAreaID,120,2,R.NEWSOAreaHierID,GETDATE(),'31-Dec-2049',0 FROM RajSFAHierarchy R INNER JOIN tblCompanySalesStructureCoverage L ON L.Descr=R.DSRArea LEFT OUTER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=L.NodeID AND H.NodeType=L.NodeType WHERE H.HierID IS NULL

	UPDATE R SET NewDSRAreaHierID=H.HierID FROM RajSFAHierarchy R INNER JOIN tblCompanySalesStructureCoverage L ON L.Descr=R.DSRArea INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=L.NodeID AND H.NodeType=L.NodeType



	UPDATE R SET NEWRSMAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureMgnrLvl0 V ON V.Descr=R.RSMArea
	UPDATE R SET NEWStateHeadAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureMgnrLvl1 V ON V.Descr=R.StateHeadArea
	UPDATE R SET NEWStateHeadAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN tblCompanySalesStructureMgnrLvl1 V ON V.Descr=R.StateHeadArea + '-' + RSMArea 
	UPDATE R SET NEWASMAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureMgnrLvl2 V ON V.Descr=R.ASMArea
	UPDATE R SET NEWSOAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureSprvsnLvl1 V ON V.Descr=R.SOArea
	UPDATE R SET NEWDSRAreaID=V.NodeID FROM RajSFAHierarchy R INNER JOIN  tblCompanySalesStructureCoverage V ON V.Descr=R.DSRArea


	UPDATE P SET Descr=R.RSMPersonName FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[RSM EmpCode]=P.Code
	UPDATE P SET Descr=R.StateHeadPersonName FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[StateHead EmpCode]=P.Code
	UPDATE P SET Descr=R.ASMPersonName FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[ASMEmpCode]=P.Code
	UPDATE P SET Descr=R.SOPersonName FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[SOEmpCode]=P.Code
	UPDATE P SET Descr=R.DSRPersonName FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[DSREmpCode]=P.Code
	
	UPDATE C SET C.IsActive=0 FROM tblCompanySalesStructureCoverage C INNER JOIN RajSFAHierarchy R ON R.DSRAreaID=C.NodeID WHERE R.Status='InActive'
	UPDATE S SET S.IsActive=0 FROM tblCompanySalesStructureSprvsnLvl1 S INNER JOIN RajSFAHierarchy R ON R.OLDSOAreaID=S.NodeID WHERE R.Status='InActive'

	UPDATE R SET NewRSMID=P.NodeID FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[RSM EmpCode]=P.Code
	UPDATE R SET NEWStateHeadID=P.NodeID FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[StateHead EmpCode]=P.Code
	UPDATE R SET NEWASMID=P.NodeID FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[ASMEmpCode]=P.Code
	UPDATE R SET NEWSOID=P.NodeID FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[SOEmpCode]=P.Code
	UPDATE R SET NEWDSRID=P.NodeID FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[DSREmpCode]=P.Code

	--RSM
	INSERT INTO tblMstrPerson(Code,Descr,NodeType,FromDate,ToDate,FileSetIdIns,LoginIDIns,TimestampIns,flgWhatsAppReg,flgActive,flgSFAUser)
	SELECT DISTINCT [RSM EmpCode],RSMPersonName,195,GETDATE(),'31-Dec-2049',0,0,GETDATE(),0,1,1 FROM RajSFAHierarchy R WHERE NEWRSMID IS NULL AND [RSM EmpCode] IS NOT NULL

	UPDATE SP SET ToDate=DATEADD(d,-1,GETDATE()) FROM tblSalesPersonMapping SP INNER JOIN RajSFAHierarchy R ON R.OLDRSMAreaID=SP.NodeID AND SP.NodeType=95 AND R.[RSM EmpCode] IS NULL AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate

	INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,FromDate,ToDate,FileSetIDIns,LoginIDIns,TimestampIns)
	SELECT DISTINCT P.NodeID,P.NodeType,R.NEWRSMAreaID,95,GETDATE(),'31-Dec-2049',0,0,GETDATE() FROM RajSFAHierarchy R INNER JOIN tblMstrPerson P ON P.Code=R.[RSM EmpCode] LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=P.NodeID AND SP.NodeID=R.NEWRSMAreaID AND SP.NodeType=95 AND SP.ToDate>GETDATE() WHERE [RSM EmpCode] IS NOT NULL AND SP.NodeType IS NULL

	UPDATE R SET NewRSMID=P.NodeID FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[RSM EmpCode]=P.Code
	 
	 -- State Head
	INSERT INTO tblMstrPerson(Code,Descr,NodeType,FromDate,ToDate,FileSetIdIns,LoginIDIns,TimestampIns,flgWhatsAppReg,flgActive,flgSFAUser)
	SELECT DISTINCT [StateHead EmpCode],StateHeadPersonName,200,GETDATE(),'31-Dec-2049',0,0,GETDATE(),0,1,1 FROM RajSFAHierarchy R WHERE NEWStateHeadID IS NULL AND [StateHead EmpCode] IS NOT NULL

	UPDATE SP SET ToDate=DATEADD(d,-1,GETDATE()) FROM tblSalesPersonMapping SP INNER JOIN RajSFAHierarchy R ON R.OLDStateHeadAreaID=SP.NodeID AND SP.NodeType=100 AND R.[StateHead EmpCode] IS NULL AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate

	INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,FromDate,ToDate,FileSetIDIns,LoginIDIns,TimestampIns)
	SELECT DISTINCT P.NodeID,P.NodeType,R.NEWStateHeadAreaID,100,GETDATE(),'31-Dec-2049',0,0,GETDATE() FROM RajSFAHierarchy R INNER JOIN tblMstrPerson P ON P.Code=R.[StateHead EmpCode] LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=P.NodeID AND SP.NodeID=R.NEWStateHeadAreaID AND SP.NodeType=100 AND SP.ToDate>GETDATE() WHERE [StateHead EmpCode] IS NOT NULL AND SP.NodeType IS NULL

	UPDATE R SET NEWStateHeadID=P.NodeID FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.[StateHead EmpCode]=P.Code


	 -- ASM ARea
	 UPDATE P SET ASMEmpCode=NULL FROM RajSFAHierarchy P WHERE ASMEmpCode='NULL'
	INSERT INTO tblMstrPerson(Code,Descr,NodeType,FromDate,ToDate,FileSetIdIns,LoginIDIns,TimestampIns,flgWhatsAppReg,flgActive,flgSFAUser)
	SELECT DISTINCT ASMEmpCode,ASMPersonName,210,GETDATE(),'31-Dec-2049',0,0,GETDATE(),0,1,1 FROM RajSFAHierarchy R WHERE NEWASMID IS NULL AND ASMEmpCode IS NOT NULL

	UPDATE SP SET ToDate=DATEADD(d,-1,GETDATE()) FROM tblSalesPersonMapping SP INNER JOIN RajSFAHierarchy R ON R.OLDASMAreaID=SP.NodeID AND SP.NodeType=110 AND R.ASMEmpCode IS NULL AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate

	INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,FromDate,ToDate,FileSetIDIns,LoginIDIns,TimestampIns)
	SELECT DISTINCT P.NodeID,P.NodeType,R.NEWASMAreaID,110,GETDATE(),'31-Dec-2049',0,0,GETDATE() FROM RajSFAHierarchy R INNER JOIN tblMstrPerson P ON P.Code=R.ASMEmpCode LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=P.NodeID AND SP.NodeID=R.NEWASMAreaID AND SP.NodeType=110 AND SP.ToDate>GETDATE()
	WHERE ASMEmpCode IS NOT NULL AND SP.NodeType IS NULL

	UPDATE R SET NEWASMID=P.NodeID FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.ASMEmpCode=P.Code

	-- SO ARea
	INSERT INTO tblMstrPerson(Code,Descr,NodeType,FromDate,ToDate,FileSetIdIns,LoginIDIns,TimestampIns,flgWhatsAppReg,flgActive,flgSFAUser)
	SELECT DISTINCT SOEmpCode,SOPersonName,220,GETDATE(),'31-Dec-2049',0,0,GETDATE(),0,1,1 FROM RajSFAHierarchy R WHERE NEWSOID IS NULL AND SOEmpCode IS NOT NULL

	UPDATE SP SET ToDate=DATEADD(d,-1,GETDATE()) FROM tblSalesPersonMapping SP INNER JOIN RajSFAHierarchy R ON R.OLDSOAreaID=SP.NodeID AND SP.NodeType=120 AND R.SOEmpCode IS NULL AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate

	INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,FromDate,ToDate,FileSetIDIns,LoginIDIns,TimestampIns)
	SELECT DISTINCT P.NodeID,P.NodeType,R.NEWSOAreaID,120,GETDATE(),'31-Dec-2049',0,0,GETDATE() FROM RajSFAHierarchy R INNER JOIN tblMstrPerson P ON P.Code=R.SOEmpCode LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=P.NodeID AND SP.NodeID=R.NEWSOAreaID AND SP.NodeType=120 AND SP.ToDate>GETDATE()
	WHERE SOEmpCode IS NOT NULL AND SP.NodeType IS NULL AND SOArea IS NOT NULL

	UPDATE R SET NEWSOID=P.NodeID FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.SOEmpCode=P.Code

	-- DSR ARea
	INSERT INTO tblMstrPerson(Code,Descr,NodeType,FromDate,ToDate,FileSetIdIns,LoginIDIns,TimestampIns,flgWhatsAppReg,flgActive,flgSFAUser)
	SELECT DISTINCT DSREmpCode,DSRPersonName,230,GETDATE(),'31-Dec-2049',0,0,GETDATE(),0,1,1 FROM RajSFAHierarchy R WHERE NEWDSRID IS NULL AND DSREmpCode IS NOT NULL

	UPDATE SP SET ToDate=DATEADD(d,-1,GETDATE()) FROM tblSalesPersonMapping SP INNER JOIN RajSFAHierarchy R ON R.OLDDSRAreaID=SP.NodeID AND SP.NodeType=130 AND R.DSREmpCode IS NULL AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate

	INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,FromDate,ToDate,FileSetIDIns,LoginIDIns,TimestampIns)
	SELECT DISTINCT P.NodeID,P.NodeType,R.NEWDSRAreaID,130,GETDATE(),'31-Dec-2049',0,0,GETDATE() FROM RajSFAHierarchy R INNER JOIN tblMstrPerson P ON P.Code=R.DSREmpCode LEFT OUTER JOIN tblSalesPersonMapping SP ON SP.PersonNodeID=P.NodeID AND SP.NodeID=R.NEWDSRAreaID AND SP.NodeType=130 AND SP.ToDate>GETDATE()
	WHERE  DSREmpCode IS NOT NULL AND SP.NodeType IS NULL AND DSRArea IS NOT NULL

	UPDATE R SET NEWDSRID=P.NodeID FROM tblMstrPerson P INNER JOIN RajSFAHierarchy R ON R.DSREmpCode=P.Code



	--SELECT * FROM tblPMstNodeTypes WHERE HierTypeID=3
	----UPDATE SP SET ToDate=DATEADD(d,-1,GETDATE()) FROM tblSalesPersonMapping SP INNER JOIN RajSFAHierarchy R ON R.OLDStateHeadAreaID=SP.NodeID AND SP.NodeType=100 AND R.[StateHead EmpCode] IS NULL
	----UPDATE SP SET ToDate=DATEADD(d,-1,GETDATE()) FROM tblSalesPersonMapping SP INNER JOIN RajSFAHierarchy R ON R.OLDASMAreaID=SP.NodeID AND SP.NodeType=110 AND R.ASMEmpCode IS NULL
	----UPDATE SP SET ToDate=DATEADD(d,-1,GETDATE()) FROM tblSalesPersonMapping SP INNER JOIN RajSFAHierarchy R ON R.OLDSOAreaID=SP.NodeID AND SP.NodeType=120 AND R.SOEmpCode IS NULL
	----UPDATE SP SET ToDate=DATEADD(d,-1,GETDATE()) FROM tblSalesPersonMapping SP INNER JOIN RajSFAHierarchy R ON R.OLDDSRAreaID=SP.NodeID AND SP.NodeType=130 AND R.DSREmpCode IS NULL

	-- UPdate HIerarchy of DSR
	SELECT * FROM RajSFAHierarchy WHERE OLDDSRAreaID<>NEWDSRAreaID
	SELECT * FROM RajSFAHierarchy WHERE OLDSOAreaID<>NEWSOAreaID
	SELECT * FROM RajSFAHierarchy WHERE OLDASMAreaID<>NEWASMAreaID
	SELECT * FROM RajSFAHierarchy WHERE OLDStateHeadAreaID<>NEWStateHeadAreaID
	SELECT * FROM RajSFAHierarchy WHERE OLDRSMAreaID<>NEWRSMAreaID

	UPDATE H SET PNODEID=ASMHIer.NodeID,PHierId=ASMHIer.HierID FROM tblCompanySalesStructureHierarchy H INNER JOIN RajSFAHierarchy R ON R.NEWSOAreaID=H.NodeID 
	INNER JOIN tblCompanySalesStructureHierarchy ASMHIer ON ASMHIer.NodeID=R.NEWASMAreaID AND ASMHIer.NodeType=110
	WHERE H.NodeType=120 AND OLDASMAreaID<>NEWASMAreaID

	UPDATE H SET PNODEID=StateHeadHIer.NodeID,PHierId=StateHeadHIer.HierID FROM tblCompanySalesStructureHierarchy H INNER JOIN RajSFAHierarchy R ON R.NEWASMAreaID=H.NodeID 
	INNER JOIN tblCompanySalesStructureHierarchy StateHeadHIer ON StateHeadHIer.NodeID=R.NEWStateHeadAreaID AND StateHeadHIer.NodeType=100
	WHERE H.NodeType=110 --AND OLDStateHeadAreaID<>NEWStateHeadAreaID


	UPDATE H SET PNODEID=RSMHeadHIer.NodeID,PHierId=RSMHeadHIer.HierID FROM tblCompanySalesStructureHierarchy H  INNER JOIN RajSFAHierarchy R ON R.NEWStateHeadAreaID=H.NodeID 
	INNER JOIN tblCompanySalesStructureHierarchy RSMHeadHIer ON RSMHeadHIer.NodeID=R.NEWRSMAreaID AND RSMHeadHIer.NodeType=95
	WHERE H.NodeType=100 AND OLDRSMAreaID<>NEWRSMAreaID

END
