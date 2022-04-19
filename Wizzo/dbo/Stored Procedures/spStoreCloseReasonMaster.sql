
--fnGetStoreCloseReasonMaster(ByVal uuid As String) As String
CREATE PROCEDURE [dbo].[spStoreCloseReasonMaster]
AS
BEGIN
	
	CREATE TABLE #tblStoreCloseReasonMaster (CloseReasonID INT,CloseReasonDescr Varchar(100),Seq INT)
	
	INSERT INTO #tblStoreCloseReasonMaster(CloseReasonID,CloseReasonDescr,Seq)
	SELECT ReasonId,ReasonDescr,Ordr FROM tblMstrReasonForClosedStore WHERE IsActive=1
	UNION
	SELECT -99 AS CloseReasonID,'Other' AS CloseReasonDescr,1000 AS Seq

	--SELECT 1 AS CloseReasonID,'Close Reason 1' AS CloseReasonDescr,0 AS Seq
	--UNION 
	--SELECT 2 AS CloseReasonID,'Close Reason  2' AS CloseReasonDescr,1 AS Seq
	--UNION
	--SELECT 3 AS CloseReasonID,'Close Reason  3' AS CloseReasonDescr,2 AS Seq
	--UNION
	--SELECT -99 AS CloseReasonID,'Other' AS CloseReasonDescr,3 AS Seq
	SELECT CloseReasonID,CloseReasonDescr FROM #tblStoreCloseReasonMaster ORDER BY Seq ASC



END
