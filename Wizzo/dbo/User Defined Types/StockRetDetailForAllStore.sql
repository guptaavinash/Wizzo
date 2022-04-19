CREATE TYPE [dbo].[StockRetDetailForAllStore] AS TABLE (
    [PrdId]             INT            NOT NULL,
    [PrdBatchId]        INT            NOT NULL,
    [UOMID]             INT            NOT NULL,
    [Qty]               INT            NOT NULL,
    [Remarks]           VARCHAR (100)  NULL,
    [AttachDoc]         VARCHAR (100)  NULL,
    [StoreId]           INT            NOT NULL,
    [OrderReturnDetId]  INT            NOT NULL,
    [strStockStatusQty] VARCHAR (1000) NOT NULL,
    [ReasonId]          INT            NULL,
    [StkRetActionId]    TINYINT        NULL);

