﻿CREATE TYPE [dbo].[PurchaseDetail] AS TABLE (
    [Item_ROWNO]        INT            NULL,
    [PurchaseID]        INT            NULL,
    [PrdID]             INT            NULL,
    [PrdBatchID]        INT            NULL,
    [OrderQty]          INT            NULL,
    [SalesUnitId]       INT            NULL,
    [PriceTermId]       INT            NULL,
    [SysRate]           [dbo].[Amount] NOT NULL,
    [ProductPrice]      [dbo].[Amount] NOT NULL,
    [OrderVal]          [dbo].[Amount] NULL,
    [TotLineDiscVal]    [dbo].[Amount] NOT NULL,
    [LineOrderValWDisc] [dbo].[Amount] NOT NULL,
    [TotTaxRate]        [dbo].[Amount] NOT NULL,
    [TotTaxValue]       [dbo].[Amount] NOT NULL,
    [NetLineOrderVal]   [dbo].[Amount] NULL,
    [SampleQty]         BIT            NULL,
    [FreeQty]           INT            NULL,
    [PurchReqDetId]     INT            NULL,
    [strStockInfo]      VARCHAR (500)  NULL);
