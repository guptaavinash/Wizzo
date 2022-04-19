CREATE TYPE [dbo].[OrdPaymentStage] AS TABLE (
    [PymtStageId]        INT            NOT NULL,
    [Percentage]         NUMERIC (5, 2) NULL,
    [PymtStageAmt]       [dbo].[Amount] NULL,
    [CreditDays]         SMALLINT       NULL,
    [CreditLimit]        [dbo].[Amount] NULL,
    [PymtMode]           VARCHAR (40)   NULL,
    [GracePeriodInDays]  SMALLINT       NULL,
    [CreditPeriodTypeId] TINYINT        NULL,
    [DefaultCreditDays]  SMALLINT       NULL);

