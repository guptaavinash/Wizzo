CREATE TYPE [dbo].[VanStockLoadUnloadDetail] AS TABLE (
    [PrdNodeID]   INT NULL,
    [PrdNodeType] INT NULL,
    [LoadQty]     INT NULL,
    [UnloadQty]   INT NULL,
    [UOMID]       INT NULL);

