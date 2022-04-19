CREATE TYPE [dbo].[DayClosureCollectionDetail] AS TABLE (
    [StoreId]          INT             NULL,
    [InstrumentModeId] INT             NULL,
    [TrnRefNo_Old]     VARCHAR (30)    NULL,
    [TrnDate_Old]      DATE            NOT NULL,
    [RcptAmt_Old]      NUMERIC (18, 2) NOT NULL,
    [BankId_Old]       INT             NULL,
    [TrnRefNo_New]     VARCHAR (30)    NULL,
    [TrnDate_New]      DATE            NOT NULL,
    [RcptAmt_New]      NUMERIC (18, 2) NOT NULL,
    [PersonAmt]        NUMERIC (18, 2) NOT NULL,
    [PersonNodeId]     INT             NULL,
    [PersonNodeType]   INT             NULL,
    [BankId_New]       INT             NULL,
    [flgChange]        TINYINT         NULL);

