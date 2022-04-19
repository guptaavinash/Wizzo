CREATE TABLE [dbo].[tblDBRDefaultPaymentStageMap] (
    [DBRDefaultPaymentStageMappingId] INT            IDENTITY (1, 1) NOT NULL,
    [DBRNodeId]                       INT            NOT NULL,
    [DBRNodeType]                     INT            NOT NULL,
    [PymtStageId]                     INT            NOT NULL,
    [Percentage]                      NUMERIC (5, 2) NOT NULL,
    [CreditDays]                      SMALLINT       NOT NULL,
    [CreditLimit]                     [dbo].[Amount] NOT NULL,
    [FromDate]                        DATE           NOT NULL,
    [ToDate]                          DATE           NOT NULL,
    [PrdNodeId]                       INT            NOT NULL,
    [PrdNodeType]                     INT            NOT NULL,
    [InvoiceSettlementType]           TINYINT        CONSTRAINT [DF_tblDBRDefaultPaymentStageMap_InvoiceSettlementType] DEFAULT ((1)) NOT NULL,
    [CreditPeriodType]                TINYINT        CONSTRAINT [DF_tblDBRDefaultPaymentStageMap_CreditPeriodType] DEFAULT ((1)) NOT NULL,
    [GracePeriodinDays]               SMALLINT       CONSTRAINT [DF_tblDBRDefaultPaymentStageMap_GracePeriodinDays] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblDBRDefaultPaymentStageMap] PRIMARY KEY CLUSTERED ([DBRDefaultPaymentStageMappingId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1: Bill To Bill Settlement, 2:Period Settlement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDBRDefaultPaymentStageMap', @level2type = N'COLUMN', @level2name = N'InvoiceSettlementType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1:Day,2:Weekly(Mon-Sun),3:Half Month(1-15,16-31),4:Monthly', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDBRDefaultPaymentStageMap', @level2type = N'COLUMN', @level2name = N'CreditPeriodType';

