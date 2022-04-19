CREATE TYPE [dbo].[ChequeDetail] AS TABLE (
    [ChqNo]       VARCHAR (10)   NULL,
    [ChqDate]     DATE           NULL,
    [ChqAmtLimit] [dbo].[Amount] NOT NULL,
    [BankId]      INT            NULL,
    [BankBranch]  VARCHAR (300)  NULL);

