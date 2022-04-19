CREATE TABLE [dbo].[tblOrderDetail] (
    [OrderDetailID]        INT            IDENTITY (1, 1) NOT NULL,
    [OrderID]              INT            NOT NULL,
    [ProductID]            INT            NOT NULL,
    [PrcBatchID]           INT            NOT NULL,
    [OrderQty]             INT            NOT NULL,
    [PriceTermId]          INT            NULL,
    [ProductRate]          [dbo].[Amount] NOT NULL,
    [LineOrderVal]         [dbo].[Amount] NOT NULL,
    [TotLineDiscVal]       [dbo].[Amount] NULL,
    [LineOrderValWDisc]    [dbo].[Amount] NULL,
    [TaxRefID]             INT            NULL,
    [TaxRate]              [dbo].[Amount] NULL,
    [TotTaxValue]          [dbo].[Amount] NULL,
    [NetLineOrderVal]      [dbo].[Amount] NULL,
    [LoginIDIns]           INT            CONSTRAINT [DF__tblOrderDD__Login__31D75E8D] DEFAULT ((0)) NOT NULL,
    [TimestampIns]         DATETIME       CONSTRAINT [DF__tblOrderDD__Times__32CB82C6] DEFAULT (getdate()) NOT NULL,
    [LoginIDUpd]           INT            NULL,
    [TimestampUpd]         DATETIME       NULL,
    [SampleQty]            INT            CONSTRAINT [DF_tblOrderDetail_SampleQty1] DEFAULT ((0)) NULL,
    [SalesUnitId]          INT            NULL,
    [FreeQty]              INT            NULL,
    [strSchemeSource]      VARCHAR (500)  NULL,
    [flgRateChange]        BIT            DEFAULT ((0)) NOT NULL,
    [strBatchPrice]        VARCHAR (1000) NULL,
    [ProductRateBeforeTax] [dbo].[Amount] NULL,
    [flgQuotationApplied]  BIT            DEFAULT ((0)) NOT NULL,
    [SalesQuoteDetId]      INT            NULL,
    CONSTRAINT [PK__tblOrder__D3B9D30C2FEF161BB] PRIMARY KEY CLUSTERED ([OrderDetailID] ASC),
    CONSTRAINT [FK_tblOrderDetail_tblOrderMaster1] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[tblOrderMaster] ([OrderID]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_tblOrderDetail]
    ON [dbo].[tblOrderDetail]([OrderID] DESC);

