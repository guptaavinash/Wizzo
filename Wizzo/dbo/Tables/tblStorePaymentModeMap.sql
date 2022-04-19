CREATE TABLE [dbo].[tblStorePaymentModeMap] (
    [StorePaymentStageMappingId] INT     CONSTRAINT [DF_tblStorePaymentModeMap_StorePaymentStageMappingId] DEFAULT ((0)) NOT NULL,
    [StoreId]                    INT     NOT NULL,
    [PaymentModeId]              TINYINT NOT NULL,
    CONSTRAINT [PK_tblStorePaymentModeMap_1] PRIMARY KEY CLUSTERED ([StorePaymentStageMappingId] ASC, [PaymentModeId] ASC)
);

