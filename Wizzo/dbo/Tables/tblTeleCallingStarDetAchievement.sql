CREATE TABLE [dbo].[tblTeleCallingStarDetAchievement] (
    [TeleCallingId] INT     NOT NULL,
    [ParamterId]    TINYINT NOT NULL,
    [IsAchieved]    BIT     NOT NULL,
    CONSTRAINT [PK_tblTeleCallingStarDetAchievement] PRIMARY KEY CLUSTERED ([TeleCallingId] ASC, [ParamterId] ASC)
);

