CREATE TYPE [dbo].[OpeningStockDetail] AS TABLE (
    [PrdId]       INT            NULL,
    [PrdBatchId]  INT            NOT NULL,
    [UOMID]       TINYINT        NULL,
    [Rate]        [dbo].[Amount] NOT NULL,
    [StockDetail] VARCHAR (1000) NULL);

