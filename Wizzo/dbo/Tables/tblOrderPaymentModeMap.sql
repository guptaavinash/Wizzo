CREATE TABLE [dbo].[tblOrderPaymentModeMap] (
    [OrderPaymentStageMapId] INT     NOT NULL,
    [OrderId]                INT     NOT NULL,
    [PaymentModeId]          TINYINT NOT NULL,
    CONSTRAINT [PK_tblOrderPaymentModeMap_!] PRIMARY KEY CLUSTERED ([OrderPaymentStageMapId] ASC, [PaymentModeId] ASC)
);

