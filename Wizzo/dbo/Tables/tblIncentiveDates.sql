CREATE TABLE [dbo].[tblIncentiveDates] (
    [IncDateMapId] INT      IDENTITY (1, 1) NOT NULL,
    [IncID]        INT      NULL,
    [IncStartDate] DATETIME NULL,
    [IncEndDate]   DATETIME NULL,
    [LoginIDIns]   INT      NULL,
    [TimestampIns] DATETIME CONSTRAINT [DF_tblIncentiveDates_TimestampIns] DEFAULT (getdate()) NULL,
    [LoginIDUpd]   INT      NULL,
    [TimestampUpd] DATETIME NULL,
    CONSTRAINT [PK_tblIncentiveDates] PRIMARY KEY CLUSTERED ([IncDateMapId] ASC)
);

