CREATE TYPE [dbo].[ReceiptAdjustment] AS TABLE (
    [RefType]        TINYINT        NOT NULL,
    [RefId]          INT            NOT NULL,
    [TotalInvamount] [dbo].[Amount] NOT NULL,
    [AdjustedAmount] [dbo].[Amount] NOT NULL);

