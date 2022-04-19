﻿CREATE TYPE [dbo].[PurchReqDetail] AS TABLE (
    [Item_ROWNO]               INT            NULL,
    [OrderID]                  INT            NULL,
    [PrdID]                    INT            NULL,
    [PrcBatchID]               INT            NULL,
    [OrderQty]                 INT            NULL,
    [SalesUnitId]              INT            NULL,
    [PriceTermId]              INT            NULL,
    [ProductPrice]             [dbo].[Amount] NOT NULL,
    [OrderVal]                 [dbo].[Amount] NULL,
    [TotLineDiscVal]           [dbo].[Amount] NOT NULL,
    [LineOrderValWDisc]        [dbo].[Amount] NOT NULL,
    [TotTaxRate]               [dbo].[Amount] NOT NULL,
    [TotTaxValue]              [dbo].[Amount] NOT NULL,
    [NetLineOrderVal]          [dbo].[Amount] NULL,
    [OrderDetailId]            INT            NULL,
    [strDeliveryDetail]        VARCHAR (4000) NULL,
    [strDeliveryDetailwithTax] VARCHAR (4000) NULL,
    [SampleQty]                INT            NULL,
    [FreeQty]                  INT            NULL,
    [strSchemeSource]          VARCHAR (500)  NULL,
    [flgRateChange]            BIT            NULL,
    [strBatchPrice]            VARCHAR (1000) NULL);

