CREATE TYPE [dbo].[CreditNoteDet] AS TABLE (
    [PrdId]              INT            NULL,
    [PrdBatchId]         INT            NULL,
    [Qty]                INT            NULL,
    [UOMID]              INT            NULL,
    [Remarks]            VARCHAR (500)  NULL,
    [CreNoteAmount]      [dbo].[Amount] NULL,
    [OrderReturnStepsId] INT            NULL,
    [CreNoteTaxAmt]      [dbo].[Amount] NOT NULL,
    [DlvryNoteDetailsID] INT            NULL);

