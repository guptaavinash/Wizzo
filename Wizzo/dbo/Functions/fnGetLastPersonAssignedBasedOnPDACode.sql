


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetLastPersonAssignedBasedOnPDACode] 
(	
	@PDACode VARCHAR(50),
	@TransDate Date
)
RETURNS @VanDet TABLE(VanID INT,CoverageAreaNodeID INT,CoverageAreaNodetype SMALLINT,CoverageArea VARCHAR(200),PersonNOdeID INT,PersonNodetype SMALLINT,Person VARCHAR(500)) 
BEGIN
	DECLARE @MaxVanLoadUnloadCycle INT=0
	
	DECLARE @PersonNodeID INT,@PersonNodeType SMALLINT ,@Person VARCHAR(500)     
	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMEINo OR PDA_IMEI_Sec=@IMEINo
	SELECT @PersonNodeID=NodeID,@PersonNodeType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	
	--SELECT  @PersonNodeID=P.NodeID,@PersonNodeType=P.NOdeType,@Person=P.Descr FROM tblMstrPerson P INNER JOIN [tblPDA_UserMapMaster] U ON U.PersonID=P.NodeID AND U.PersonType=P.NodeType WHERE @TransDate BETWEEN U.DateFrom AND U.DateTo AND U.PDAID=@DeviceID AND @TransDate BETWEEN P.FromDate AND P.ToDate

	INSERT INTO @VanDet(VanID,CoverageAreaNodeID,CoverageAreaNodetype,PersonNOdeID,PersonNodetype,Person)
	SELECT DISTINCT SH.VanID,SH.SalesNodeID,SH.SalesNodetype,SM.PersonNodeID,SM.PersonType,@Person  FROM tblSalesHierVanMapping SH INNER JOIN tblSalesPersonMapping SM ON SM.NodeID=SH.SalesNodeID AND SM.NodeType=SH.SalesNodetype WHERE @TransDate BETWEEN SM.FromDate AND SM.ToDate AND CAST(@TransDate AS DATE) BETWEEN CAST(SH.Fromdate AS DATE) AND CAST(SH.Todate AS DATE) AND SM.PersonNodeID=@PersonNodeID AND SM.PersonType=@PersonNodeType

	
	SELECT @MaxVanLoadUnloadCycle=VM.VanLoadUnLoadCycID FROM tblVanStockMaster VM ,(SELECT SalesManNodeId,SalesManNodeType,MAX(TransDate) MaxTransDate FROM tblVanStockMaster VM WHERE SalesManNodeId=@PersonNodeID AND SalesmanNodeType=@PersonNodeType AND TransDate<=@TransDate GROUP BY SalesManNodeId,SalesManNodeType) X WHERE X.MaxTransDate=VM.TransDate AND X.SalesManNodeId=VM.SalesManNodeId AND X.SalesManNodeType=VM.SalesManNodeType

	IF ISNULL(@MaxVanLoadUnloadCycle,0)>0
	BEGIN
		DELETE FROM @VanDet
		INSERT INTO @VanDet(VanID,CoverageAreaNodeID,CoverageAreaNodetype,PersonNOdeID,PersonNodetype,Person)
		SELECT DISTINCT VM.VanID,SalesAreaNodeID,SalesAreaNodeType,SalesManNodeId,SalesManNodeType,P.Descr FROM tblVanStockMaster VM INNER JOIN tblMstrPerson P ON P.NodeID=VM.SalesManNodeId AND VM.SalesManNodeType=P.NodeType WHERE VanLoadUnLoadCycID=@MaxVanLoadUnloadCycle AND GETDATE() BETWEEN P.FromDate AND P.ToDate
	END

	--IF (220=(SELECT PersonNodeType FROM @VanDet)) --- SO
	--BEGIN
		--UPDATE V SET CoverageArea=DSRArea FROM @VanDet V INNER JOIN [VwCompanyDSRFullDetail] C ON C.DSRAreaID=V.CoverageAreaNodeID AND C.DSRAreaNodeType=V.CoverageAreaNodetype
		
	--END
		
RETURN 
END
