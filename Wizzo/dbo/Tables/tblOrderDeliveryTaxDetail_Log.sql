CREATE TABLE [dbo].[tblOrderDeliveryTaxDetail_Log] (
    [OrderLogID]            INT             NULL,
    [OrderDetailDeliveryID] INT             NOT NULL,
    [PriceTermId]           INT             NOT NULL,
    [OrderId]               INT             NULL,
    [TaxPercentage]         NUMERIC (5, 2)  NULL,
    [TaxAmount]             NUMERIC (38, 6) NULL
);

