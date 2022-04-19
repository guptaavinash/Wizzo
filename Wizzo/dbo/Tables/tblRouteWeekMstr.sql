CREATE TABLE [dbo].[tblRouteWeekMstr] (
    [RouteWkId]  INT     IDENTITY (1, 1) NOT NULL,
    [RouteCycId] INT     NOT NULL,
    [WeekNo]     TINYINT NOT NULL,
    [StartDate]  DATE    NOT NULL,
    [EndDate]    DATE    NOT NULL,
    [YearWkNo]   TINYINT NOT NULL,
    CONSTRAINT [PK_tblRouteWeekMstr] PRIMARY KEY CLUSTERED ([RouteWkId] ASC)
);

