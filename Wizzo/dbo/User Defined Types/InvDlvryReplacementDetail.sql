CREATE TYPE [dbo].[InvDlvryReplacementDetail] AS TABLE (
    [DlvryNoteID]              INT           NULL,
    [OrderReturnReplacementId] INT           NULL,
    [PrdId]                    INT           NULL,
    [PrdBatchId]               INT           NULL,
    [Storeid]                  INT           NULL,
    [ReqTotQty]                INT           NULL,
    [ActTotQty]                INT           NULL,
    [Remarks]                  VARCHAR (500) NULL,
    [SalesUnitId]              INT           NULL,
    [ReasonId]                 INT           NULL,
    [StkRetActionId]           TINYINT       NULL);

