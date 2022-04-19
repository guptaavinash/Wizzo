CREATE TABLE [dbo].[tmpRoutePlanRawData_backup] (
    [RouteCode]           VARCHAR (50)  NOT NULL,
    [RouteName]           VARCHAR (500) NOT NULL,
    [WeekNo]              TINYINT       NOT NULL,
    [DayOfWeek]           TINYINT       NOT NULL,
    [ApplicableStartDate] DATE          NOT NULL,
    [DSECode]             VARCHAR (50)  NOT NULL,
    [DSEName]             VARCHAR (500) NOT NULL,
    [filesetid]           INT           NULL
);

