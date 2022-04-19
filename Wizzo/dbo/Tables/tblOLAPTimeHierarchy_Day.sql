CREATE TABLE [dbo].[tblOLAPTimeHierarchy_Day] (
    [TimeHierarchyId]   INT           IDENTITY (1, 1) NOT NULL,
    [Date]              DATETIME      NOT NULL,
    [strDate]           VARCHAR (20)  NULL,
    [WeekEnding]        DATETIME      NOT NULL,
    [WeekEndingNew]     DATETIME      NULL,
    [strWeekEnding]     VARCHAR (20)  NULL,
    [WeekEndingMonthly] DATETIME      NULL,
    [Month]             NVARCHAR (34) NULL,
    [MonthVal]          NCHAR (10)    NULL,
    [YearVal]           INT           NULL,
    [YearValNew]        INT           NULL,
    [RptMonthYear]      INT           NULL
);

