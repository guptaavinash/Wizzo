CREATE TABLE [dbo].[tblDBRDefaultPaymentModeMap] (
    [DBRDefaultPaymentStageMappingId] INT     CONSTRAINT [DF_tblDBRDefaultPaymentModeMap_StorePaymentStageMappingId] DEFAULT ((0)) NOT NULL,
    [DBRNodeId]                       INT     NOT NULL,
    [DBRNodeType]                     INT     NOT NULL,
    [PaymentModeId]                   TINYINT NOT NULL,
    CONSTRAINT [PK_tblDBRDefaultPaymentModeMap_1] PRIMARY KEY CLUSTERED ([DBRDefaultPaymentStageMappingId] ASC, [PaymentModeId] ASC)
);

