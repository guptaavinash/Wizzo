CREATE TABLE [dbo].[tblTeleCallingStarDet] (
    [TeleCallingId] INT     NOT NULL,
    [ParamterId]    TINYINT NOT NULL,
    [IsAchieved]    BIT     NOT NULL,
    CONSTRAINT [PK_tblTeleCallingStarDet] PRIMARY KEY CLUSTERED ([TeleCallingId] ASC, [ParamterId] ASC)
);

