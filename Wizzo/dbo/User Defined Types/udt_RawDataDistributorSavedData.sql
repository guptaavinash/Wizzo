CREATE TYPE [dbo].[udt_RawDataDistributorSavedData] AS TABLE (
    [StockDate]           NVARCHAR (500) NULL,
    [StockPcsCaseType]    NVARCHAR (500) NULL,
    [ProductID]           NVARCHAR (500) NULL,
    [EnteredValue]        NVARCHAR (500) NULL,
    [Date]                NVARCHAR (500) NULL,
    [DistributorNodeType] NVARCHAR (500) NULL,
    [DistribtrId]         NVARCHAR (500) NULL,
    [EntryType]           NVARCHAR (500) NULL,
    [ProductNodeType]     NVARCHAR (500) NULL);

