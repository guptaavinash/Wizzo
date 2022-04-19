CREATE TABLE [dbo].[tblRoutePlanningMstr] (
    [RouteWkPlnId]    INT      IDENTITY (1, 1) NOT NULL,
    [RouteNodeId]     INT      NOT NULL,
    [RouteNodeType]   INT      NOT NULL,
    [WeekNo]          TINYINT  NOT NULL,
    [DayOfWeek]       TINYINT  NOT NULL,
    [RouteCycId]      INT      NOT NULL,
    [RouteWkId]       INT      NOT NULL,
    [DSENodeId]       INT      NOT NULL,
    [DSENodeType]     INT      NOT NULL,
    [CovAreaNodeId]   INT      CONSTRAINT [DF_tblRoutePlanningMstr_CovAreaNodeId_1] DEFAULT ((0)) NOT NULL,
    [CovAreaNodeType] INT      CONSTRAINT [DF_tblRoutePlanningMstr_CovAreaNodeType_1] DEFAULT ((0)) NOT NULL,
    [FromDate]        DATE     NOT NULL,
    [ToDate]          DATE     CONSTRAINT [DF_tblRoutePlanningMstr_ToDate] DEFAULT ('2050-12-31') NOT NULL,
    [LoginIdIns]      INT      NOT NULL,
    [TmeStampIns]     DATETIME CONSTRAINT [DF_tblRoutePlanningMstr_TmeStampIns] DEFAULT (getdate()) NOT NULL,
    [FileSetId]       INT      NULL,
    CONSTRAINT [PK_tblRoutePlanningMstr] PRIMARY KEY CLUSTERED ([RouteWkPlnId] ASC)
);

