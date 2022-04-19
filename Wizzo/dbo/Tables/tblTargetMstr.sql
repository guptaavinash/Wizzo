CREATE TABLE [dbo].[tblTargetMstr] (
    [TgtMstrID]         INT           IDENTITY (1, 1) NOT NULL,
    [TgtMeasureCrtraID] INT           NULL,
    [LoginIDIns]        INT           NULL,
    [TimeStampIns]      SMALLDATETIME CONSTRAINT [DF_tblTargetMstr_TimeStampIns] DEFAULT (getdate()) NULL,
    [LoginIDUpd]        INT           NULL,
    [TimeStampUpd]      SMALLDATETIME NULL,
    CONSTRAINT [PK_tblTargetMstr] PRIMARY KEY CLUSTERED ([TgtMstrID] ASC)
);

