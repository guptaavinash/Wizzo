CREATE TABLE [dbo].[tblRoutePlanningMstr_History] (
    [RouteWkPlnId]  INT      NOT NULL,
    [RouteNodeId]   INT      NOT NULL,
    [RouteNodeType] INT      NOT NULL,
    [WeekNo]        TINYINT  NOT NULL,
    [DayOfWeek]     TINYINT  NOT NULL,
    [RouteCycId]    INT      NOT NULL,
    [RouteWkId]     INT      NOT NULL,
    [DSENodeId]     INT      NOT NULL,
    [DSENodeType]   INT      NOT NULL,
    [FromDate]      DATE     NOT NULL,
    [ToDate]        DATE     NOT NULL,
    [LoginIdIns]    INT      NOT NULL,
    [TmeStampIns]   DATETIME NOT NULL,
    [FileSetId]     INT      NULL
);

