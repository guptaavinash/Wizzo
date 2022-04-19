CREATE TYPE [dbo].[udt_DayWorkSummary] AS TABLE (
    [GroupName]       NVARCHAR (500) NULL,
    [Description]     NVARCHAR (500) NULL,
    [Planned]         NVARCHAR (500) NULL,
    [Actual_Expected] NVARCHAR (500) NULL,
    [Actual_Done]     NVARCHAR (500) NULL);

