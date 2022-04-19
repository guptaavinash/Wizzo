CREATE TYPE [dbo].[udt_RawDataStoreCheckImage] AS TABLE (
    [StoreId]        NVARCHAR (500) NULL,
    [VisitID]        NVARCHAR (500) NULL,
    [PhotoName]      NVARCHAR (500) NULL,
    [ImageClicktime] NVARCHAR (500) NULL,
    [StoreVisitCode] NVARCHAR (500) NULL,
    [ImageType]      NVARCHAR (500) NULL);

