CREATE TABLE [dbo].[tblOLAPTimeHierarchy] (
    [TimeHierarchyId]   INT           IDENTITY (1, 1) NOT NULL,
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

