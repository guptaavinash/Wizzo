CREATE TYPE [dbo].[PickListTemporaryData] AS TABLE (
    [PckLstId]   INT NULL,
    [PrdId]      INT NULL,
    [PrdBatchId] INT NULL,
    [QtyToExe]   INT NULL,
    [QtyActPick] INT NULL,
    [QtyRetWH]   INT NULL,
    [ReasonId]   INT NULL,
    [UOMID]      INT NULL);

