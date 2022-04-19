CREATE TYPE [dbo].[udt_RawDataStoreReasonSaving] AS TABLE (
    [StoreID]        NVARCHAR (500) NULL,
    [VisitID]        NVARCHAR (500) NULL,
    [ReasonID]       NVARCHAR (500) NULL,
    [ReasonDescr]    NVARCHAR (500) NULL,
    [Sstat]          NVARCHAR (500) NULL,
    [StoreVisitCode] NVARCHAR (500) NULL);

