﻿CREATE TABLE [dbo].[tblTCOrderDetail] (
    [OrderDetailID]        INT              IDENTITY (1, 1) NOT NULL,
    [OrderID]              INT              NOT NULL,
    [PrdNodeId]            INT              NOT NULL,
    [PrdNodeType]          INT              NOT NULL,
    [PrcBatchID]           INT              NOT NULL,
    [OrderQty]             INT              NOT NULL,
    [PriceTermId]          INT              NULL,
    [ProductRate]          DECIMAL (18, 10) NULL,
    [LineOrderVal]         NUMERIC (18, 2)  NOT NULL,
    [TotLineDiscVal]       NUMERIC (18, 2)  NULL,
    [LineOrderValWDisc]    NUMERIC (18, 2)  NULL,
    [TaxRefID]             INT              NULL,
    [TaxRate]              NUMERIC (18, 2)  NULL,
    [TotTaxValue]          NUMERIC (18, 2)  NULL,
    [NetLineOrderVal]      NUMERIC (18, 2)  NULL,
    [LoginIDIns]           INT              CONSTRAINT [DF__tblOrderD__Login__31D75E8D] DEFAULT ((0)) NOT NULL,
    [TimestampIns]         DATETIME         CONSTRAINT [DF__tblOrderD__Times__32CB82C6] DEFAULT (getdate()) NOT NULL,
    [LoginIDUpd]           INT              NULL,
    [TimestampUpd]         DATETIME         NULL,
    [SampleQty]            INT              CONSTRAINT [DF_tblOrderDetail_SampleQty] DEFAULT ((0)) NULL,
    [SalesUnitId]          INT              NULL,
    [FreeQty]              INT              NULL,
    [strSchemeSource]      VARCHAR (500)    NULL,
    [flgRateChange]        BIT              CONSTRAINT [DF__tblOrderD__flgRa__4D5F7D71] DEFAULT ((0)) NOT NULL,
    [strBatchPrice]        VARCHAR (1000)   NULL,
    [ProductRateBeforeTax] DECIMAL (18, 10) NULL,
    [flgQuotationApplied]  BIT              CONSTRAINT [DF_tblOrderDetail_flgQuotationApplied] DEFAULT ((0)) NOT NULL,
    [SalesQuoteDetId]      INT              NULL,
    [InvLevelDisc]         NUMERIC (18, 2)  NULL,
    [flgSBDGAP]            TINYINT          DEFAULT ((0)) NOT NULL,
    [flgFB]                TINYINT          DEFAULT ((0)) NOT NULL,
    [flgInitiative]        TINYINT          DEFAULT ((0)) NOT NULL,
    [SBDGroupId]           INT              DEFAULT ((0)) NOT NULL,
    [flgSBD]               TINYINT          DEFAULT ((0)) NOT NULL,
    [FBID]                 INT              DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__tblOrder__D3B9D30C2FEF161B] PRIMARY KEY CLUSTERED ([OrderDetailID] ASC),
    CONSTRAINT [FK_tblOrderDetail_tblOrderMaster] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[tblTCOrderMaster] ([OrderID]) ON DELETE CASCADE ON UPDATE CASCADE
);

