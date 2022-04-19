CREATE TYPE [dbo].[PaymentDetails] AS TABLE (
    [AdvChqId]       INT            NOT NULL,
    [InstrumentMode] TINYINT        NOT NULL,
    [TrnRefNo]       VARCHAR (30)   NULL,
    [TrnDate]        DATE           NULL,
    [RcptAmt]        [dbo].[Amount] NOT NULL,
    [BankId]         INT            NULL,
    [BankAdd]        VARCHAR (500)  NULL,
    [Remarks]        VARCHAR (500)  NULL,
    [AttachFilePath] VARCHAR (100)  NULL);

