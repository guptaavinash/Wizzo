CREATE TABLE [dbo].[tblOrderDelivery] (
    [OrderDetailDeliveryID]   INT             IDENTITY (1, 1) NOT NULL,
    [OrderDetailID]           INT             NULL,
    [OrderId]                 INT             NULL,
    [Qty]                     INT             NULL,
    [RequiredDeliveryDate]    SMALLDATETIME   NULL,
    [OrderDeliveryLocationId] INT             NULL,
    [OrderBillingLocationId]  INT             NULL,
    [TaxRate]                 NUMERIC (38, 6) NULL,
    [LoginIDIns]              INT             NULL,
    [LoginIDUpd]              INT             NULL,
    [TimeStampIns]            DATETIME        NULL,
    [TimeStampUpd]            DATETIME        NULL,
    CONSTRAINT [PK_tblOrderDelivery] PRIMARY KEY CLUSTERED ([OrderDetailDeliveryID] ASC)
);

