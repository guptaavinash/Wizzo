CREATE TYPE [dbo].[udt_RawDataStoreCompetitorData] AS TABLE (
    [StoreID]           NVARCHAR (500) NULL,
    [StoreCheckVisitID] NVARCHAR (500) NULL,
    [StoreVisitCode]    NVARCHAR (500) NULL,
    [CompProductID]     NVARCHAR (500) NULL,
    [PStockQty]         NVARCHAR (500) NULL,
    [PPTR]              NVARCHAR (500) NULL,
    [PPTC]              NVARCHAR (500) NULL);

