CREATE TYPE [dbo].[PickListDetail] AS TABLE (
    [ident]           INT NOT NULL,
    [PckLstDetailId]  INT NULL,
    [PrdBatchId]      INT NULL,
    [PickedQty]       INT NULL,
    [TobeExecutedQty] INT NULL);

