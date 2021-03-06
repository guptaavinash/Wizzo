CREATE TABLE [dbo].[tblRptSalesMonthlyWithTarget_Day] (
    [ChannelId]                 INT             NULL,
    [SEId]                      INT             NULL,
    [SENodeType]                INT             NULL,
    [RouteId]                   INT             NULL,
    [RouteId_Org]               INT             NULL,
    [RouteNodeType]             INT             NULL,
    [RouteNodeType_Org]         INT             NULL,
    [StoreId]                   INT             NOT NULL,
    [Date]                      DATE            NOT NULL,
    [WeekEnding]                DATE            NOT NULL,
    [WeekEndingMonthly]         DATE            NOT NULL,
    [RptMonthYear]              INT             NOT NULL,
    [ActiveSKUs]                INT             NOT NULL,
    [OrderVolumeKG]             NUMERIC (38, 6) NOT NULL,
    [OrderVolumeLt]             NUMERIC (38, 6) NOT NULL,
    [OrderGrossVal]             NUMERIC (38, 6) NOT NULL,
    [OrderTaxVal]               NUMERIC (38, 6) NOT NULL,
    [OrderNetVal]               NUMERIC (38, 6) NOT NULL,
    [TotalLinesOrdered]         INT             NOT NULL,
    [TotalDistinctLinesOrdered] INT             NOT NULL,
    [FlgPlanned]                TINYINT         NOT NULL,
    [FlgCovered]                TINYINT         NOT NULL,
    [FlgProductive]             TINYINT         NOT NULL,
    [PlannedCalls]              INT             NOT NULL,
    [ActualCalls]               INT             NOT NULL,
    [ProductiveCalls]           INT             NOT NULL,
    [FlgNewStore]               TINYINT         NOT NULL,
    [StoreCategoryId]           INT             NOT NULL,
    [StoreClassId]              INT             NOT NULL,
    [StoreTypeId]               INT             NULL,
    [CovAreaId]                 INT             NULL,
    [ManDay]                    BIGINT          NULL,
    [flgActiveStore]            TINYINT         NULL
);

