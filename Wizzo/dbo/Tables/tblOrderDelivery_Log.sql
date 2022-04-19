CREATE TABLE [dbo].[tblOrderDelivery_Log] (
    [OrderLogID]              INT             NULL,
    [OrderDetailDeliveryID]   INT             NOT NULL,
    [OrderDetailID]           INT             NULL,
    [OrderId]                 INT             NULL,
    [Qty]                     INT             NULL,
    [RequiredDeliveryDate]    DATE            NULL,
    [OrderDeliveryLocationId] INT             NULL,
    [OrderBillingLocationId]  INT             NULL,
    [TaxRate]                 NUMERIC (38, 6) NULL,
    [LoginIDIns]              INT             NULL,
    [LoginIDUpd]              INT             NULL,
    [TimeStampIns]            DATETIME        NULL,
    [TimeStampUpd]            DATETIME        NULL
);

