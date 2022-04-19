CREATE TABLE [dbo].[tblRouteCalendar] (
    [RouteCalendarId] INT      IDENTITY (1, 1) NOT NULL,
    [SONodeId]        INT      NOT NULL,
    [SONodeType]      INT      NOT NULL,
    [DistNodeId]      INT      NOT NULL,
    [DistNodeType]    INT      NOT NULL,
    [StoreId]         INT      NOT NULL,
    [SectorId]        INT      NOT NULL,
    [RouteNodeId]     INT      NOT NULL,
    [RouteNodeType]   INT      NOT NULL,
    [CovNodeId]       INT      CONSTRAINT [DF_tblRouteCalendar_CovNodeId] DEFAULT ((0)) NOT NULL,
    [CovNodeType]     INT      CONSTRAINT [DF_tblRouteCalendar_CovNodeType] DEFAULT ((0)) NOT NULL,
    [VisitDate]       DATE     NOT NULL,
    [FileSetId]       BIGINT   NULL,
    [TimeStamps]      DATETIME NULL,
    [FrqTypeId]       TINYINT  CONSTRAINT [DF__tblRouteC__FrqTy__762C88DA] DEFAULT ((0)) NOT NULL,
    [SOAreaNodeId]    INT      NULL,
    [SOAreaNodeType]  INT      NULL,
    CONSTRAINT [PK_tblRouteCalendar] PRIMARY KEY CLUSTERED ([RouteCalendarId] ASC)
);

