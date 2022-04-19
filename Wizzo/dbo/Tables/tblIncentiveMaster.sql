CREATE TABLE [dbo].[tblIncentiveMaster] (
    [IncId]         INT           IDENTITY (1, 1) NOT NULL,
    [IncentiveName] VARCHAR (500) NOT NULL,
    [KPIId]         INT           NULL,
    [LoginIDIns]    INT           NULL,
    [TimestampIns]  DATETIME      CONSTRAINT [DF_tblIncentiveMaster_TimestampIns] DEFAULT (getdate()) NULL,
    [LoginIDUpd]    INT           NULL,
    [TimestampUpd]  DATETIME      NULL,
    CONSTRAINT [PK_tblIncentiveMaster] PRIMARY KEY CLUSTERED ([IncId] ASC)
);

