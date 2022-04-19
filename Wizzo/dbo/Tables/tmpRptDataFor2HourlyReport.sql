﻿CREATE TABLE [dbo].[tmpRptDataFor2HourlyReport] (
    [ZoneId]                                        INT            NULL,
    [ZoneNodeType]                                  INT            NULL,
    [Zone]                                          VARCHAR (200)  NULL,
    [RegionNodeId]                                  INT            NULL,
    [RegjonNodeType]                                INT            NULL,
    [Region]                                        VARCHAR (200)  NULL,
    [ASMAreaId]                                     INT            NULL,
    [ASMAreaNodeType]                               INT            NULL,
    [ASMArea]                                       VARCHAR (200)  NULL,
    [ASMId]                                         INT            NULL,
    [ASM]                                           VARCHAR (200)  NULL,
    [SOAreaId]                                      INT            NULL,
    [SOAreaNodeType]                                INT            NULL,
    [SOArea]                                        VARCHAR (200)  NULL,
    [CovAreaId]                                     INT            NULL,
    [CovAreaNodeType]                               INT            NULL,
    [CovArea]                                       VARCHAR (200)  NULL,
    [SalesmanNodeId]                                INT            NULL,
    [Salesman]                                      VARCHAR (200)  NULL,
    [RouteId]                                       INT            NULL,
    [RouteNodeType]                                 INT            NULL,
    [Route]                                         VARCHAR (200)  NULL,
    [flgOnRoute]                                    TINYINT        NOT NULL,
    [SalesmanWorkingType]                           TINYINT        NOT NULL,
    [FirstStoreVisit]                               VARCHAR (20)   NULL,
    [LastStoreVisit]                                VARCHAR (20)   NULL,
    [WorkingHours]                                  VARCHAR (20)   NULL,
    [PlannedCalls]                                  INT            NOT NULL,
    [ActCalls]                                      INT            NOT NULL,
    [ProdCalls]                                     INT            NOT NULL,
    [TotLinesOrdered]                               INT            NOT NULL,
    [OrderQty]                                      FLOAT (53)     NULL,
    [OrderVal]                                      FLOAT (53)     NULL,
    [RptDate]                                       INT            NULL,
    [Tot Order Val^HOUSEHOLD SOAP$3|5F8B41~80B45C]  FLOAT (53)     NULL,
    [Tot Order Val^SOAP POWDER$3|5F8B41~80B45C]     FLOAT (53)     NULL,
    [Tot Order Val^TOILET SOAP$3|5F8B41~80B45C]     FLOAT (53)     NULL,
    [Tot Order Val^ANTI BACTERIAL $3|5F8B41~80B45C] FLOAT (53)     NULL,
    [Tot Order Val^XACT BAR$3|5F8B41~80B45C]        FLOAT (53)     NULL,
    [StrCategory]                                   VARCHAR (5000) NULL,
    [StrCategoryForGrouping]                        VARCHAR (5000) NULL
);

