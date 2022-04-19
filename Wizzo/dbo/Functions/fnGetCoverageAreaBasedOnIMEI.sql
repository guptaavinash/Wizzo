-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetCoverageAreaBasedOnIMEI]
(	
	@PDA_IMEI VARCHAR(20),
	@TrnDate DATE
)
RETURNS @CoverageArea TABLE (CoverageAreaNodeID INT,CoverageAreaNodetype SMALLINT,CoverageArea VARCHAR(500))
AS
BEGIN
	DECLARE @PDAID INT,@PersonID INT,@PersonType INT
	SELECT @PDAID=PDAID FROM tblPDAMaster WHERE PDA_IMEI=@PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI
	SELECT @PersonID=PersonID,@PersonType=PersonType FROM tblPDA_UserMapMaster WHERE PDAID=@PDAID AND @TrnDate BETWEEN DateFrom AND DateTo
	--- IF Person is from Indirect Sale
	
	INSERT INTO @CoverageArea(CoverageAreaNodeID,CoverageAreaNodetype)
	SELECT DISTINCT SP.NodeID,SP.NodeType FROM tblSalesPersonMapping SP WHERE SP.PersonNodeID=@PersonID AND SP.PersonType=@PersonType AND @TrnDate BETWEEN SP.FromDate AND SP.ToDate AND SP.NodeType IN (SELECT NodeType FROM [dbo].[tblSecMenuContextMenu] WHERE flgCoverageArea=1)
	UNION
	SELECT VM.SalesAreaNodeID,VM.SalesAreaNodeType FROM tblVanStockMaster VM WHERE SalesManNodeId=@PersonID AND SalesManNodeType=@PersonType AND TransDate=@TrnDate

	UPDATE T SET T.CoverageArea=Descr FROM @CoverageArea T INNER JOIN tblDBRSalesStructureCoverage DC ON DC.NodeID=T.CoverageAreaNodeID AND DC.NodeType=T.CoverageAreaNodetype
	UPDATE T SET T.CoverageArea=Descr FROM @CoverageArea T INNER JOIN tblCompanySalesStructureCoverage CC ON CC.NodeID=T.CoverageAreaNodeID AND CC.NodeType=T.CoverageAreaNodetype

	RETURN 

END
