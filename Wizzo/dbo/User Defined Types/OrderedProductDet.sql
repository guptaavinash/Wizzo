CREATE TYPE [dbo].[OrderedProductDet] AS TABLE (
    [ProdID]           INT            NOT NULL,
    [Stock]            INT            NULL,
    [OrderQty]         INT            NULL,
    [ProductRate]      [dbo].[Amount] NOT NULL,
    [LineOrderVal]     [dbo].[Amount] NULL,
    [DisVal]           [dbo].[Amount] NOT NULL,
    [TaxRate]          [dbo].[Amount] NOT NULL,
    [TaxValue]         [dbo].[Amount] NOT NULL,
    [SampleQty]        INT            NULL,
    [flgSalesQuote]    BIT            NOT NULL,
    [FreeQty]          INT            NULL,
    [flgTC/SFA]        TINYINT        NULL,
    [TCOrderDeatailID] INT            NULL);

