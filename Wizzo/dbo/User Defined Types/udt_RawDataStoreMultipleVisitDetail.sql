CREATE TYPE [dbo].[udt_RawDataStoreMultipleVisitDetail] AS TABLE (
    [IMEINumber]            NVARCHAR (500) NULL,
    [StoreVisitCode]        NVARCHAR (500) NULL,
    [StoreID]               NVARCHAR (500) NULL,
    [StoreCheckVisitID]     NVARCHAR (500) NULL,
    [TempStoreVisitCode]    NVARCHAR (500) NULL,
    [ForDate]               NVARCHAR (500) NULL,
    [Sstat]                 NVARCHAR (500) NULL,
    [VisitTimeStartAtStore] NVARCHAR (500) NULL,
    [VisitTimeEndStore]     NVARCHAR (500) NULL,
    [VisitLatCode]          NVARCHAR (500) NULL,
    [VisitLongCode]         NVARCHAR (500) NULL,
    [flgTelephonic]         NVARCHAR (500) NULL);

