CREATE TYPE [dbo].[PaymentStage] AS TABLE (
    [PymtStageId]        INT            NOT NULL,
    [Percentage]         NUMERIC (5, 2) NULL,
    [CreditDays]         SMALLINT       NULL,
    [CreditLimit]        [dbo].[Amount] NULL,
    [CreditPeriodTypeId] TINYINT        NULL,
    [GracePeriodInDays]  SMALLINT       NULL,
    [PymtMode]           VARCHAR (40)   NULL);

