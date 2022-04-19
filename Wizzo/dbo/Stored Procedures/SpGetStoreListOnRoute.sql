

-- =============================================
-- Author:		Avinash Gupta
-- Create date: 04-May-2015
-- Description:	Sp to get the store master list belong to that Route
-- =============================================

-- SpGetStoreListOnRoute 4,7,'03-May-2015','30-May-2015'
CREATE PROCEDURE [dbo].[SpGetStoreListOnRoute] 
	@NodeID INT,
	@NodeType int, --- NODEType=7 for "SE Daily Route" and 16 for "FMCG DSR Daily Route"
	@FromDate DATE,
	@ToDate Date
AS
BEGIN	
		SELECT DISTINCT 'Total Store' StoreTypeDescr,COUNT(DISTINCT SM.StoreID) StoreCount FROM [dbo].[tblStoreMaster] SM 
		--LEFT OUTER JOIN VwStoreAttrHierarchy ST ON ST.StoreTypeHierID=SM.StoreAttrHierID
		LEFT OUTER JOIN tblRouteCoverageStoreMapping RSM ON
		SM.StoreID=RSM.StoreID WHERE RouteID=@NodeID AND RSM.RouteNodeType=@NodeType AND ((FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate) OR
		(@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate))  AND ((GETDATE() BETWEEN FROMDATE AND TODATE) OR (GETDATE()<@FROMDATE))

		--GROUP BY StoreTypeDescr

		SELECT 15 AS DistanceCov 

END




