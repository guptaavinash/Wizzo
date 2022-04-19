CREATE TYPE [dbo].[StockMovmentDetail] AS TABLE (
    [StkMovId]             INT            NULL,
    [PrdID]                INT            NULL,
    [PrdBatchID]           INT            NULL,
    [Qty]                  INT            NULL,
    [ProductRate]          [dbo].[Amount] NOT NULL,
    [ProductRateBeforeTax] [dbo].[Amount] NOT NULL,
    [TaxRate]              [dbo].[Amount] NOT NULL,
    [ValueBeforeTax]       [dbo].[Amount] NOT NULL,
    [TaxValue]             [dbo].[Amount] NOT NULL,
    [NetValue]             [dbo].[Amount] NOT NULL,
    [UOMId]                INT            NULL,
    [Remarks]              VARCHAR (100)  NULL,
    [FromStockStatusId]    INT            NULL,
    [ToStockStatusId]      INT            NULL,
    [ReasonId]             INT            NULL,
    [PurchaseDetId]        INT            NULL);

