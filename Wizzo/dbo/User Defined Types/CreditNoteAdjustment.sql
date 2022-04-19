CREATE TYPE [dbo].[CreditNoteAdjustment] AS TABLE (
    [RefType]        TINYINT        NOT NULL,
    [RefId]          INT            NOT NULL,
    [AdjustmentDate] DATE           NULL,
    [AdjustedAmount] [dbo].[Amount] NOT NULL);

