CREATE TABLE [dbo].[tblVisitDet] (
    [VisitDetID]         INT              IDENTITY (1, 1) NOT NULL,
    [StoreID]            INT              NOT NULL,
    [VisitID]            INT              NOT NULL,
    [StoreVisitCode]     VARCHAR (200)    NULL,
    [TempStoreVisitCode] VARCHAR (200)    NULL,
    [VisitStartDate]     DATETIME         NULL,
    [VisitEndDate]       DATETIME         NULL,
    [TimestampIns]       DATETIME         NULL,
    [TimestampUpd]       DATETIME         NULL,
    [LatCode]            NUMERIC (27, 24) NULL,
    [LongCode]           NUMERIC (27, 24) NULL,
    [flgTelePhonic]      TINYINT          NULL
);

