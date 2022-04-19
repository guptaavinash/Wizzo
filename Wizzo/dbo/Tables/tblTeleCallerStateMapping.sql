CREATE TABLE [dbo].[tblTeleCallerStateMapping] (
    [TelecallerId] INT     NOT NULL,
    [StateId]      TINYINT NOT NULL,
    CONSTRAINT [PK_tblTeleCallerStateMapping] PRIMARY KEY CLUSTERED ([TelecallerId] ASC, [StateId] ASC)
);

