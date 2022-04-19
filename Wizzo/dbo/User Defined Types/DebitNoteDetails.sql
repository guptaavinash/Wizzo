CREATE TYPE [dbo].[DebitNoteDetails] AS TABLE (
    [DebitNoteTypeId]    TINYINT         NULL,
    [TotAmount]          NUMERIC (18, 2) NULL,
    [Remarks]            VARCHAR (500)   NULL,
    [AttachDocPath]      VARCHAR (250)   NULL,
    [OtherExpenseDetail] VARCHAR (MAX)   NULL);

