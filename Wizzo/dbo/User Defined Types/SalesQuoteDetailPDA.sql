CREATE TYPE [dbo].[SalesQuoteDetailPDA] AS TABLE (
    [Row_No]                SMALLINT       NOT NULL,
    [PrdId]                 INT            NOT NULL,
    [StandardRate]          [dbo].[Amount] NOT NULL,
    [StandardRateBeforeTax] [dbo].[Amount] NOT NULL,
    [RateOffer]             [dbo].[Amount] NOT NULL,
    [InclusiveTax]          BIT            NOT NULL,
    [TaxRate]               [dbo].[Amount] NOT NULL,
    [ValidFrom]             DATE           NOT NULL,
    [ValidTo]               DATE           NOT NULL,
    [MinDlvryQty]           INT            NOT NULL,
    [UOMID]                 INT            NOT NULL,
    [Remarks]               VARCHAR (200)  NULL,
    [RateOfferPerPCS]       [dbo].[Amount] NOT NULL);

