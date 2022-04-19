CREATE TABLE [dbo].[tblOrderDeliveryTaxDetail] (
    [OrderDetailDeliveryID] INT             NOT NULL,
    [PriceTermId]           INT             NOT NULL,
    [OrderId]               INT             NULL,
    [TaxPercentage]         NUMERIC (5, 2)  NULL,
    [TaxAmount]             NUMERIC (38, 6) NULL,
    CONSTRAINT [PK_tblOrderDeliveryTaxDetail] PRIMARY KEY CLUSTERED ([OrderDetailDeliveryID] ASC, [PriceTermId] ASC)
);

