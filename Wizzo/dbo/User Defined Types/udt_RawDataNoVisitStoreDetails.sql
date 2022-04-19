CREATE TYPE [dbo].[udt_RawDataNoVisitStoreDetails] AS TABLE (
    [IMEI]        NVARCHAR (500) NULL,
    [CurDate]     NVARCHAR (500) NULL,
    [ReasonId]    NVARCHAR (500) NULL,
    [ReasonDescr] NVARCHAR (500) NULL,
    [flgHasVisit] NVARCHAR (500) NULL);

