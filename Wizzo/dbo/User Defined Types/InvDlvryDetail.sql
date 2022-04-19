CREATE TYPE [dbo].[InvDlvryDetail] AS TABLE (
    [DlvryNoteDetailsID] INT           NULL,
    [DlvryNoteId]        INT           NULL,
    [InvId]              INT           NULL,
    [PrdId]              INT           NULL,
    [PrdBatchId]         INT           NULL,
    [Storeid]            INT           NULL,
    [ReqTotQty]          INT           NULL,
    [ReqFreeQty]         INT           NULL,
    [ReqBilledQty]       INT           NULL,
    [ActTotQty]          INT           NULL,
    [ActFreeQty]         INT           NULL,
    [ActBilledQty]       INT           NULL,
    [Remarks]            VARCHAR (500) NULL,
    [SalesUnitId]        INT           NULL,
    [ReasonId]           INT           NULL,
    [StkRetActionId]     INT           NULL);

