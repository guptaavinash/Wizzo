CREATE TABLE [dbo].[tblRptSalesMonthly_Day] (
    [ChannelId]                INT             NULL,
    [SEId]                     INT             NULL,
    [SENodeType]               INT             NULL,
    [RouteId]                  INT             NULL,
    [RouteId_Org]              INT             NULL,
    [RouteNodeType]            INT             NULL,
    [RouteNodeType_Org]        INT             NULL,
    [StoreId]                  INT             NOT NULL,
    [SKUId]                    INT             NOT NULL,
    [Date]                     DATE            NOT NULL,
    [WeekEnding]               DATE            NOT NULL,
    [WeekEndingMonthly]        DATE            NOT NULL,
    [RptMonthYear]             INT             NOT NULL,
    [TotalLinesOrdered]        INT             NOT NULL,
    [OrderQty]                 INT             NOT NULL,
    [OrderVolumeKG]            NUMERIC (38, 6) NOT NULL,
    [OrderVolumeLt]            NUMERIC (38, 6) NOT NULL,
    [OrderGrossVal]            NUMERIC (38, 6) NOT NULL,
    [OrderTaxVal]              NUMERIC (38, 6) NOT NULL,
    [OrderNetVal]              NUMERIC (38, 6) NOT NULL,
    [FreeOrderQty]             INT             NOT NULL,
    [FreeOrderVolumeKG]        NUMERIC (38, 6) NOT NULL,
    [FreeOrderVolumeLt]        NUMERIC (38, 6) NOT NULL,
    [ValueForFreeOrderProduct] NUMERIC (38, 6) NOT NULL,
    [FlgDistrbn]               TINYINT         NOT NULL,
    [FlgDistrbn2X]             TINYINT         NOT NULL,
    [FlgNewStore]              TINYINT         NOT NULL,
    [FlgNewStore_SKULvl]       TINYINT         NOT NULL,
    [WeeksSinceLastBought]     INT             NOT NULL,
    [FlgFirstTimeBought]       TINYINT         NOT NULL,
    [StoreCategoryId]          INT             NOT NULL,
    [StoreClassId]             INT             NOT NULL,
    [StoreTypeId]              INT             NULL,
    [flgOrderType]             TINYINT         NULL,
    [CovAreaId]                INT             NULL,
    [ManDay]                   BIGINT          NULL,
    [flgOrderSource]           TINYINT         NOT NULL,
    [flgActiveStore]           TINYINT         NULL,
    [OrderQtyInCase]           FLOAT (53)      NULL
);

