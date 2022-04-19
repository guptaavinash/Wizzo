-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetLastPersonAssigned] 
(	
	@VanID INT,
	@TransDate Date
)
RETURNS @VanDet TABLE(CoverageAreaNodeID INT,CoverageAreaNodetype SMALLINT,CoverageArea VARCHAR(200),PersonNOdeID INT,PersonNodetype SMALLINT,Person VARCHAR(500)) 
BEGIN
	DECLARE @MaxVanLoadUnloadCycle INT=0

	INSERT INTO @VanDet(CoverageAreaNodeID,CoverageAreaNodetype,PersonNOdeID,PersonNodetype,Person)
	SELECT SH.SalesNodeID,SH.SalesNodetype,SM.PersonNodeID,SM.PersonType,P.Descr  FROM tblSalesHierVanMapping SH INNER JOIN tblSalesPersonMapping SM ON SM.NodeID=SH.SalesNodeID AND SM.NodeType=SH.SalesNodetype INNER JOIN tblMstrPerson P ON P.NodeID=SM.PersonNodeID AND P.NodeType=SM.PersonType WHERE @TransDate BETWEEN SM.FromDate AND SM.ToDate AND CAST(@TransDate AS DATE) BETWEEN CAST(SH.Fromdate AS DATE) AND CAST(SH.Todate AS DATE) AND @TransDate BETWEEN P.FromDate AND P.ToDate AND VanID=@VanID 

	
	SELECT @MaxVanLoadUnloadCycle=VM.VanLoadUnLoadCycID FROM tblVanStockMaster VM ,(SELECT VanID,MAX(TransDate) MaxTransDate FROM tblVanStockMaster VM WHERE VanID=@VanID AND TransDate<=@TransDate GROUP BY VanID) X WHERE X.MaxTransDate=VM.TransDate AND X.VanID=VM.VanID

	IF ISNULL(@MaxVanLoadUnloadCycle,0)>0
	BEGIN
		DELETE FROM @VanDet
		INSERT INTO @VanDet(CoverageAreaNodeID,CoverageAreaNodetype,PersonNOdeID,PersonNodetype,Person)
		SELECT DISTINCT SalesAreaNodeID,SalesAreaNodeType,SalesManNodeId,SalesManNodeType,P.Descr FROM tblVanStockMaster VM INNER JOIN tblMstrPerson P ON P.NodeID=VM.SalesManNodeId AND VM.SalesManNodeType=P.NodeType WHERE VanLoadUnLoadCycID=@MaxVanLoadUnloadCycle AND GETDATE() BETWEEN P.FromDate AND P.ToDate
	END

	--IF (220=(SELECT PersonNodeType FROM @VanDet)) --- SO
	--BEGIN
		UPDATE V SET CoverageArea=DSRArea FROM @VanDet V INNER JOIN [VwCompanyDSRFullDetail] C ON C.DSRAreaID=V.CoverageAreaNodeID AND C.DSRAreaNodeType=V.CoverageAreaNodetype
		UPDATE V SET CoverageArea=DBRCoverage FROM @VanDet V INNER JOIN [VwDistributorDSRFullDetail] C ON C.DBRCoverageID=V.CoverageAreaNodeID AND C.DBRCoverageNodeType=V.CoverageAreaNodetype
		
	--END
		
RETURN 
END
