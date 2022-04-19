﻿CREATE TABLE [dbo].[tblOLAPDailyInvData] (
    [ChannelId]              INT             NULL,
    [SEId]                   INT             NULL,
    [SENodeType]             INT             NULL,
    [RouteId]                INT             NULL,
    [RouteId_Org]            INT             NULL,
    [RouteNodeType]          INT             NULL,
    [RouteNodeType_Org]      INT             NULL,
    [StoreId]                INT             NOT NULL,
    [SKUId]                  INT             NOT NULL,
    [Date]                   DATE            NOT NULL,
    [WeekEnding]             DATE            NOT NULL,
    [WeekEndingMonthly]      DATE            NOT NULL,
    [RptMonthYear]           INT             NOT NULL,
    [TotalLinesInvoiced]     INT             NOT NULL,
    [InvQty]                 INT             NOT NULL,
    [InvVolumeKG]            NUMERIC (38, 6) NOT NULL,
    [InvVolumeLt]            NUMERIC (38, 6) NOT NULL,
    [InvGrossVal]            NUMERIC (38, 6) NOT NULL,
    [InvTaxVal]              NUMERIC (38, 6) NOT NULL,
    [InvNetVal]              NUMERIC (38, 6) NOT NULL,
    [InvFreeQty]             INT             NOT NULL,
    [InvFreeVolumeKG]        NUMERIC (38, 6) NOT NULL,
    [InvFreeVolumeLt]        NUMERIC (38, 6) NOT NULL,
    [ValueForInvFreeProduct] NUMERIC (38, 6) NOT NULL,
    [FlgDistrbn_Invoice]     TINYINT         NOT NULL,
    [StoreCategoryId]        INT             NOT NULL,
    [StoreClassId]           INT             NOT NULL,
    [StoreTypeId]            INT             NULL,
    [flgInvUpdateSource]     INT             NULL,
    [CovAreaId]              INT             NULL,
    [ManDay]                 BIGINT          NULL,
    [FlgNewStore]            TINYINT         NOT NULL,
    [flgActiveStore]         TINYINT         NULL
);
