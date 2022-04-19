CREATE TYPE [dbo].[PurchReturnDetail] AS TABLE (
    [PurchRetId]              INT            NULL,
    [PrdID]                   INT            NULL,
    [PrdBatchID]              INT            NULL,
    [Qty]                     INT            NULL,
    [UOMId]                   INT            NULL,
    [Rate]                    [dbo].[Amount] NULL,
    [PurchRetBeforeTaxAmount] [dbo].[Amount] NULL,
    [TaxAmount]               [dbo].[Amount] NULL,
    [NetPurchRetAmount]       [dbo].[Amount] NULL,
    [StockStatusId]           INT            NULL,
    [InvDetail]               VARCHAR (500)  NULL,
    [InvDetailDisplay]        VARCHAR (1000) NULL);

