CREATE TABLE [dbo].[tblTeleCallerDailyMstr] (
    [TCDailyId]     INT      IDENTITY (1, 1) NOT NULL,
    [CallDate]      DATE     NOT NULL,
    [TCNodeId]      INT      NOT NULL,
    [TCNodeType]    INT      NOT NULL,
    [StartCall]     TIME (7) CONSTRAINT [DF_tblTeleCallerDailyMstr_StartCall_1] DEFAULT (getdate()) NOT NULL,
    [EndCall]       TIME (7) NULL,
    [StatusId]      TINYINT  NOT NULL,
    [BreakReasonId] TINYINT  NULL,
    [LoginIdIns]    INT      NOT NULL,
    [TimeStampIns]  DATETIME CONSTRAINT [DF_tblTeleCallerDailyMstr_TimeStampIns] DEFAULT (getdate()) NOT NULL,
    [LoginIdUpd]    INT      NULL,
    [TimeStampUpd]  DATETIME NULL,
    CONSTRAINT [PK_tblTeleCallerDailyMstr] PRIMARY KEY CLUSTERED ([TCDailyId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblTeleCallerDailyMstr]
    ON [dbo].[tblTeleCallerDailyMstr]([TCNodeId] ASC, [TCNodeType] ASC, [CallDate] DESC);

