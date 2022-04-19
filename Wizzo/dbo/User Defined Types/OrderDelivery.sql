CREATE TYPE [dbo].[OrderDelivery] AS TABLE (
    [Item_ROWNO]            INT             NULL,
    [Del_ROWNO]             INT             NULL,
    [OrderID]               INT             NULL,
    [OrderQty]              INT             NULL,
    [RequiredDeliveryDate]  SMALLDATETIME   NULL,
    [TaxPriceTermId]        INT             NULL,
    [TaxPercentage]         NUMERIC (5, 2)  NULL,
    [TaxAmount]             NUMERIC (38, 6) NULL,
    [OrderDetailDeliveryID] INT             NULL);

