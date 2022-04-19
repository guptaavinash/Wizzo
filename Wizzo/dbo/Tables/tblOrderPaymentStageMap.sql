CREATE TABLE [dbo].[tblOrderPaymentStageMap] (
    [OrderPaymentStageMapId] INT            IDENTITY (1, 1) NOT NULL,
    [OrderId]                INT            NOT NULL,
    [PymtStageId]            INT            NOT NULL,
    [Percentage]             NUMERIC (5, 2) NOT NULL,
    [PymtStageAmt]           [dbo].[Amount] NULL,
    [CreditDays]             SMALLINT       NOT NULL,
    [CreditLimit]            [dbo].[Amount] NOT NULL,
    [ExtendedCreditDays]     SMALLINT       NULL,
    [InvoiceSettlementType]  TINYINT        NULL,
    [CreditPeriodType]       TINYINT        NULL,
    [GracePeriodinDays]      SMALLINT       NULL,
    CONSTRAINT [PK_tblOrderPaymentStageMap_!] PRIMARY KEY CLUSTERED ([OrderPaymentStageMapId] ASC),
    CONSTRAINT [IX_tblOrderPaymentStageMap] UNIQUE NONCLUSTERED ([OrderId] ASC, [PymtStageId] ASC)
);

