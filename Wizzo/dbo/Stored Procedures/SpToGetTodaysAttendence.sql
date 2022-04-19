-- =============================================
-- Author:		Avinash Gupta
-- Create date: 
-- Description:	
-- =============================================

-- SpToGetTodaysAttendence 'E1736117-8A5C-4508-BFE9-6368F84A8663',0,'22-Dec-2021'
CREATE PROCEDURE [dbo].[SpToGetTodaysAttendence] 
	@PDA_IMEINo VARCHAR(100),
	@LoginID INT,
	@RptDate DATE
AS
BEGIN
	DECLARE @PersonNodeID INT
	DECLARE @PersonNodetype SMALLINT
	DECLARE @LateCutOffTime TIME='09:30:00'
	DECLARE @FinalCutOffTime TIME='10:30:00'

	IF ISNULL(@PDA_IMEINo,'')<>''
	BEGIN
		--SELECT @PersonNodeID=PerosnNodeID,@PersonNodetype=PersonNodeType FROM dbo.fnGetPersonfromIMEI(@PDA_IMEINo)
		SELECT @PersonNodeID=NodeID,@PersonNodetype=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDA_IMEINo) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	END
	IF ISNULL(@LoginID,0)<>0
	BEGIN
		SELECT @PersonNodeID=NodeID,@PersonNodetype=NodeType FROM tblSecuser S INNER JOIN tblSecUserLogin L ON L.UserID=S.UserID  WHERE LoginID=@LoginID
	END
	PRINT '@PersonNodeID=' + CAST(@PersonNodeID AS VARCHAR)
	PRINT '@PersonNodetype=' + CAST(@PersonNodetype AS VARCHAR)
	--SELECT * FROM tblpmstnodetypes
	CREATE TABLE #tblAttendenceReport(PersonNodeID INT,PersonNodeTYpe SMALLINT,Personname VARCHAR(500),WorkingAreaNodeID INT,WorkingAreaNodeType SMALLINT,WorkingArea VARCHAR(500),[Today Working] VARCHAR(200),[Day Start Time] SMALLDATETIME,[Location] VARCHAR(200),[Reason For Delay] VARCHAR(200),TotalWorkingTime VARCHAR(20),[Validation] TINYINT DEFAULT 4,PersonAttendanceID INT,ApprovalStatus TINYINT DEFAULT 0 ) --Validation =1 On Time,2=Late,3=Delayed beyond Limit.,4=Data Not Received
	IF @PersonNodetype=220  ---SO
	BEGIN	
		INSERT INTO #tblAttendenceReport(WorkingAreaNodeID,WorkingAreaNodeType,WorkingArea,PersonNodeID,PersonNodeTYpe,Personname)
		SELECT DISTINCT DSRAreaID,DSRAreaNodeType,DSRArea,CompanyDSRID,CompanyDSRNodeType,CompanyDSR FROM [dbo].[VwCompanyDSRFullDetail] WHERE DSRAreaID>0 AND SOID=@PersonNodeID AND SONodeType=@PersonNodetype
		

		SELECT DISTINCT C.NodeID DBRCoverageID,C.NodeType DBRCoverageNodeType,C.Descr DBRCoverage,PC.NodeID DistributorDSRID,PC.NodeType DistributorDSRNodeType,PC.Descr DistributorDSR INTO #TempSO
		FROM tblSalesPersonMapping SP 
		INNER JOIN tblCompanySalesStructureHierarchy H ON H.PNodeID=SP.NodeID AND H.PNodeType=SP.NodeType 
		INNER JOIN tblCompanySalesStructureCoverage C ON C.NodeID=H.NodeID AND C.NodeType=H.NodeType 
		INNER JOIN tblSalesPersonMapping SPC ON SPC.NodeID=C.NodeID AND SPC.NodeType=C.NodeType AND CAST(GETDATE() AS DATE) BETWEEN SPC.FromDate AND SPC.ToDate
		INNER JOIN tblMstrPerson PC ON PC.NodeID=SPC.PersonNodeID  AND CAST(GETDATE() AS DATE) BETWEEN Sp.FromDate AND SP.ToDate AND CAST(GETDATE() AS DATE) BETWEEN H.VldFrom AND H.VldTo
		where SP.NodeID=@PersonNodeID and SP.NodeType=@PersonNodetype
		UNION
		SELECT DISTINCT DC.NodeID DBRCoverageID,CH.NodeType DBRCoverageNodeType,DC.Descr  DBRCoverage ,PC.NodeID DistributorDSRID,PC.NodeType DistributorDSRNodeType,PC.Descr DistributorDSR
		FROM tblSalesPersonMapping SP INNER JOIN tblCompanySalesStructure_DistributorMapping M ON M.SHNodeID=SP.NodeID AND M.SHNodeType=SP.NodeType 
		INNER JOIN tblCompanySalesStructureHierarchy Ch ON CH.NodeID=M.DHNodeID AND Ch.NodeType=M.DHNodeType
		INNER JOIN tblDBRSalesStructureCoverage DC ON DC.NodeID=CH.NodeID AND DC.NodeType=CH.NodeType 
		INNER JOIN tblSalesPersonMapping SPC ON SPC.NodeID=DC.NodeID AND SPC.NodeType=DC.NodeType 
		INNER JOIN tblMstrPerson PC ON PC.NodeID=SPC.PersonNodeID AND CAST(GETDATE() AS DATE) BETWEEN SPC.FromDate AND SPC.ToDate
		AND CAST(GETDATE() AS DATE) BETWEEN M.FromDate AND M.ToDate AND CAST(GETDATE() AS DATE) BETWEEN CH.VldFrom AND CH.VldTo AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate AND CH.NodeType=160 
		where SP.PersonNodeID=@PersonNodeID and SP.PersonType=@PersonNodetype

		UPDATE A SET A.PersonNodeID=B.DistributorDSRID,A.PersonNodeTYpe=B.DistributorDSRNodeType,A.Personname=B.DistributorDSR FROM #tblAttendenceReport A INNER JOIN #TempSO B ON A.WorkingAreaNodeID=B.DBRCoverageID AND A.WorkingAreaNodeType=B.DBRCoverageNodeType
		WHERE ISNULL(A.PersonNodeID,0)=0
	
	END
	ELSE IF @PersonNodetype =210  -- ASM
	BEGIN
		INSERT INTO #tblAttendenceReport(WorkingAreaNodeID,WorkingAreaNodeType,WorkingArea,PersonNodeID,PersonNodeTYpe,Personname)
		SELECT SOAreaID,SOAreaNodeType,SOArea,SOID,SONodeType,SO FROM [VwCompanyDSRFullDetail] WHERE ASMID=@PersonNodeID
		
	END

	UPDATE A SET [Day Start Time]=[Datetime],[Location]=DBR.Descr,PersonAttendanceID=PA.PersonAttendanceID,ApprovalStatus=PA.flgApprove,A.[Validation]=0,[Today Working]='Yes' FROM #tblAttendenceReport A INNER JOIN tblPersonAttendance PA ON A.PersonNodeID=PA.PersonNodeID  AND CAST(DateTime AS DATE)=CAST(@RptDate AS DATE) LEFT OUTER JOIN [dbo].[tblDBRSalesStructureDBR] DBR ON DBR.NodeID=PA.DBNodeID AND DBR.NodeType=PA.DBNodeType

	UPDATE A SET [Location]=R.ReasonDescr,PersonAttendanceID=PA.PersonAttendanceID,ApprovalStatus=PA.flgApprove FROM #tblAttendenceReport A INNER JOIN tblPersonAttendance PA ON A.PersonNodeID=PA.PersonNodeID  AND CAST(DateTime AS DATE)=CAST(@RptDate AS DATE) INNER JOIN [PersonAttReason] R ON R.PersonAttendanceID=PA.PersonAttendanceID WHERE R.ReasonID=7

	UPDATE A SET [Reason For Delay]=R.ReasonDescr,PersonAttendanceID=PA.PersonAttendanceID,ApprovalStatus=PA.flgApprove FROM #tblAttendenceReport A INNER JOIN tblPersonAttendance PA ON A.PersonNodeID=PA.PersonNodeID  AND CAST(DateTime AS DATE)=CAST(@RptDate AS DATE) INNER JOIN [PersonAttReason] R ON R.PersonAttendanceID=PA.PersonAttendanceID INNER JOIN tblMstrReasonsForNoVisit M ON M.ReasonID=R.ReasonID WHERE M.flgDelayedReason=1

	UPDATE A SET [Today Working]=PR.ReasonDescr FROM #tblAttendenceReport A INNER JOIN [PersonAttReason] PR ON PR.PersonAttendanceID=A.PersonAttendanceID INNER JOIN [tblMstrReasonsForNoVisit] M ON M.ReasonId=PR.ReasonID WHERE M.flgNoVisitOption=1

	UPDATE A SET [Validation]=1 FROM  #tblAttendenceReport A WHERE A.[Day Start Time]<=CAST(@RptDate AS DATETIME) + CAST(@LateCutOffTime AS DATETIME)
	UPDATE A SET [Validation]=2 FROM  #tblAttendenceReport A WHERE A.[Day Start Time] BETWEEN CAST(@RptDate AS DATETIME) + CAST(@LateCutOffTime AS DATETIME) AND CAST(@RptDate AS DATETIME) + CAST(@FinalCutOffTime AS DATETIME)
	UPDATE A SET [Validation]=3 FROM  #tblAttendenceReport A WHERE A.[Day Start Time]>CAST(@RptDate AS DATETIME) + CAST(@FinalCutOffTime AS DATETIME)

	SELECT WorkingAreaNodeID,WorkingAreaNodeType,ISNULL(PersonNodeID,0) PersonNodeID,ISNULL(PersonNodeTYpe,0) PersonNodeTYpe,ISNULL(dbo.ConvertFirstLetterinCapital(Personname),'Vacant') [Person Name],[Today Working],FORMAT([Day Start Time],'dd-MMM hh:mm:ss') [Day Start Time],TotalWorkingTime,[Location],[Validation],PersonAttendanceID,ISNULL(ApprovalStatus,0) ApprovalStatus  FROM #tblAttendenceReport



END
