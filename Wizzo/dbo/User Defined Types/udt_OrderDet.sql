CREATE TYPE [dbo].[udt_OrderDet] AS TABLE (
    [ProdID]            INT            NULL,
    [Stock]             INT            NULL,
    [OrderQty]          INT            NULL,
    [Rate]              [dbo].[Amount] NOT NULL,
    [LineOrderVal]      [dbo].[Amount] NOT NULL,
    [TotLineDiscVal]    [dbo].[Amount] NOT NULL,
    [LineOrderValWDisc] [dbo].[Amount] NOT NULL,
    [TotTaxRate]        [dbo].[Amount] NOT NULL,
    [TotTaxValue]       [dbo].[Amount] NOT NULL,
    [NetLineOrderVal]   [dbo].[Amount] NOT NULL,
    [SampleQty]         INT            NULL,
    [FreeQty]           INT            NULL);

