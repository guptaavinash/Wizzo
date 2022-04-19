CREATE TABLE [dbo].[tblPDASyncStorePaymentModeMap] (
    [StorePaymentStageMappingId] INT     CONSTRAINT [DF_tblPDASyncStorePaymentModeMap_StorePaymentStageMappingId] DEFAULT ((0)) NOT NULL,
    [StoreIddb]                  INT     NOT NULL,
    [PaymentModeId]              TINYINT NOT NULL,
    CONSTRAINT [PK_tblPDASyncStorePaymentModeMap_1] PRIMARY KEY CLUSTERED ([StorePaymentStageMappingId] ASC, [PaymentModeId] ASC)
);

