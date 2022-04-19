CREATE TABLE [dbo].[tblRoutePlanDetails] (
    [WeekId]        INT            NOT NULL,
    [WeekNoInMonth] INT            NULL,
    [WeekFrom]      DATE           NULL,
    [WeekTo]        DATE           NULL,
    [MonthId1]      TINYINT        NULL,
    [MonthId2]      TINYINT        NULL,
    [CovFrqID]      INT            NULL,
    [CovFreq]       NVARCHAR (128) NULL,
    [Value]         TINYINT        NULL
);

