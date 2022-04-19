CREATE TYPE [dbo].[OrderPrdBatch] AS TABLE (
    [Item_ROWNO]            INT            NULL,
    [Del_RowNo]             INT            NULL,
    [PrdId]                 INT            NULL,
    [PrdBatchId]            INT            NULL,
    [Qty]                   INT            NULL,
    [Rate]                  [dbo].[Amount] NULL,
    [OrderDetailID]         INT            NULL,
    [OrderDetailDeliveryID] INT            NULL,
    [flgPriceChange]        BIT            NULL);

