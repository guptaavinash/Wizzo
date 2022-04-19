CREATE TABLE [dbo].[tblPersonDayEnd] (
    [DayEndID]       INT           IDENTITY (1, 1) NOT NULL,
    [PersonNodeID]   INT           NULL,
    [PersonNodetype] SMALLINT      NOT NULL,
    [VisitEndDate]   DATE          NULL,
    [Datetime]       SMALLDATETIME NULL,
    [TimestampIns]   DATETIME      NULL,
    [TimestampUpd]   DATETIME      NULL,
    [IMEINo]         VARCHAR (50)  NULL
);

