CREATE TYPE [dbo].[InvActDlvryDetail] AS TABLE (
    [DlvryNoteId]        INT            NULL,
    [DlvryNoteDetailsID] INT            NULL,
    [PrdId]              INT            NULL,
    [PrdBatchId]         INT            NULL,
    [Storeid]            INT            NULL,
    [ReqTotQty]          INT            NULL,
    [ReqFreeQty]         INT            NULL,
    [ReqBilledQty]       INT            NULL,
    [ActTotQty]          INT            NULL,
    [ActFreeQty]         INT            NULL,
    [ActBilledQty]       INT            NULL,
    [SalesUnitId]        INT            NULL,
    [Rate]               [dbo].[Amount] NOT NULL);

