CREATE TYPE [dbo].[udt_StoreVisits] AS TABLE (
    [StoreVisitCode]     VARCHAR (200)    NULL,
    [TempStoreVisitCode] VARCHAR (200)    NULL,
    [VisitStartTime]     DATETIME         NULL,
    [VisitEndTime]       DATETIME         NULL,
    [LatCode]            NUMERIC (27, 24) NULL,
    [LongCode]           NUMERIC (27, 24) NULL,
    [flgTelePhonic]      TINYINT          NULL);

