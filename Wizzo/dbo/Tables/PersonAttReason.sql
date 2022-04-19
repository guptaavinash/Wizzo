CREATE TABLE [dbo].[PersonAttReason] (
    [PersonAttendanceID] INT           NOT NULL,
    [ReasonID]           INT           NULL,
    [ReasonDescr]        VARCHAR (500) NULL,
    [StartDate]          DATE          NULL,
    [EndDate]            DATE          NULL
);

