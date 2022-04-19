CREATE TABLE [dbo].[tblDailyUpdatedStoreLastCallData] (
    [StoreId]                INT             NOT NULL,
    [SourceId]               TINYINT         NOT NULL,
    [PersonNodeId]           INT             NOT NULL,
    [PersonNodeType]         INT             NOT NULL,
    [PersonName]             VARCHAR (100)   NULL,
    [LastOrderValue]         NUMERIC (18, 2) NULL,
    [LastOrderDate]          DATE            NULL,
    [LastVisitDate]          DATE            NULL,
    [MonthlyTarget]          NUMERIC (18)    NULL,
    [AchievedTarget]         NUMERIC (18)    NULL,
    [BalanceTarget]          NUMERIC (18)    NULL,
    [CallTarget]             NUMERIC (18)    NULL,
    [AlreadyVisited]         INT             NULL,
    [PendingVisit]           INT             NULL,
    [TotalVisits]            INT             NULL,
    [UnproductiveCallReason] VARCHAR (100)   NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Astix SFA,2=TARS,3= FA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDailyUpdatedStoreLastCallData', @level2type = N'COLUMN', @level2name = N'SourceId';

