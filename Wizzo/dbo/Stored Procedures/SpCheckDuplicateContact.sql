-- =============================================
-- Author:		Avinash
-- Create date: 17-Nov-2021
-- Description:	
-- =============================================
-- [SpCheckDuplicateContact] '2475804F-75B9-473E-B22C-A6F587ECE67F',0,7774847971
CREATE PROCEDURE [dbo].[SpCheckDuplicateContact] 
	@PDACode VARCHAR(50),
	@StoreID VarChar(250),
	@ContactNumber BIGINT
AS
BEGIN
	DECLARE @ExistingStoreName VARCHAR(100),@ExistingPersonname VARCHAR(100),@ExistingStoreID INT,@flgDuplicate TINYINT,@ExistingRoutename VARCHAR(200)
	DECLARE @ExistingRouteID INT
	SET @flgDuplicate=0
	SELECT @ExistingStoreID=S.StoreID,@ExistingStoreName=StoreName FROM tblStoreMaster(nolock) S INNER JOIN tblOutletContactDet(nolock) C ON C.StoreID=S.StoreID 
	WHERE C.MobNo=@ContactNumber OR C.LandLineNo1=CAST(@ContactNumber AS VARCHAR(12))AND flgActive=1

	PRINT '@ExistingStoreID=' + CAST(@ExistingStoreID AS VARCHAR)
	IF ISNULL(@ExistingStoreID,0)>0
	BEGIN
		SELECT @ExistingPersonname=F.DSMCode + '(' + F.DSM + ')',@ExistingRoutename=R.Descr,@ExistingRouteID=R.NodeID FROM tblRouteCoverageStoreMapping SM 
		INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=SM.RouteID AND H.NodeType=SM.RouteNodeType
		INNER JOIN VwSalesHierarchyFull F ON F.ComCoverageAreaID=H.PNodeID AND F.ComCoverageAreaType=H.PNodeType
		INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=H.NodeID AND R.NodeType=H.NodeType
		WHERE StoreID=@ExistingStoreID AND CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate

		--IF @ExistingRouteID>0
		--		SET @flgDuplicate=1
	END

	SELECT @flgDuplicate flgDuplicate,ISNULL(@ExistingStoreName,'NA') ExistingStoreName,ISNULL(@ExistingPersonname,'NA') ExistingPersonname,ISNULL(@ExistingRoutename,'NA') ExistingRoutename
END
