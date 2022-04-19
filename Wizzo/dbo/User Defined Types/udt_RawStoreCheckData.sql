CREATE TYPE [dbo].[udt_RawStoreCheckData] AS TABLE (
    [StoreID]        NVARCHAR (500) NULL,
    [VisitID]        NVARCHAR (500) NULL,
    [StoreVisitCode] NVARCHAR (500) NULL,
    [ProductID]      NVARCHAR (500) NULL,
    [StockQty]       NVARCHAR (500) NULL,
    [PStockQty]      NVARCHAR (500) NULL);

