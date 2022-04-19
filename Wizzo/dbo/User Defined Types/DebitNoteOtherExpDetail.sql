CREATE TYPE [dbo].[DebitNoteOtherExpDetail] AS TABLE (
    [DebNoteTypeId]    TINYINT        NULL,
    [ClaimExpId]       INT            NULL,
    [ClaimAmount]      [dbo].[Amount] NULL,
    [ClmExpDocNo]      VARCHAR (50)   NULL,
    [ClmExpDate]       DATE           NULL,
    [ReceiptAttachDoc] VARCHAR (200)  NULL,
    [Remarks]          VARCHAR (500)  NULL,
    [Percentage]       NUMERIC (5, 2) NULL,
    [IsInclude]        BIT            NULL);

