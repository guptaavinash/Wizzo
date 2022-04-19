CREATE TABLE [dbo].[tblTargetDet] (
    [TgtDetId]         INT           IDENTITY (1, 1) NOT NULL,
    [TgtMstrId]        INT           NULL,
    [SalesmanNodeId]   INT           NULL,
    [SalesmanNodeType] INT           NULL,
    [AreaNodeId]       INT           NULL,
    [AreaNodeType]     INT           NULL,
    [TargetVal]        FLOAT (53)    NULL,
    [LoginIDIns]       INT           NULL,
    [TimeStampIns]     SMALLDATETIME CONSTRAINT [DF_tblTargetDet_TimeStampIns] DEFAULT (getdate()) NULL,
    [LoginIDUpd]       INT           NULL,
    [TimeStampUpd]     SMALLDATETIME NULL,
    CONSTRAINT [PK_tblTargetDet] PRIMARY KEY CLUSTERED ([TgtDetId] ASC),
    CONSTRAINT [FK_tblTargetMstr_tblTargetDet] FOREIGN KEY ([TgtMstrId]) REFERENCES [dbo].[tblTargetMstr] ([TgtMstrID]) ON DELETE CASCADE ON UPDATE CASCADE
);

