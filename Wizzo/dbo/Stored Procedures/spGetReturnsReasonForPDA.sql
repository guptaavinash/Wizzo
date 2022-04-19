

CREATE proc [dbo].[spGetReturnsReasonForPDA]
AS
SELECT        StockStatusId, StockStatus
FROM            tblPhysicalStockStatusMstr
WHERE        (flgActive = 1)

