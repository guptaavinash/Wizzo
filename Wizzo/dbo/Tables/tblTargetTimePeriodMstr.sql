CREATE TABLE [dbo].[tblTargetTimePeriodMstr] (
    [TimePeriodNodeId]   INT           IDENTITY (1, 1) NOT NULL,
    [TimePeriodNodeType] INT           NULL,
    [TimePeriodDescr]    VARCHAR (200) NULL,
    [TimePeriodKey]      VARCHAR (50)  NULL,
    CONSTRAINT [PK_tblTargetTimePeriodMstr] PRIMARY KEY CLUSTERED ([TimePeriodNodeId] ASC)
);

