CREATE TABLE [dbo].[tblTeleCallerLanguageMapping] (
    [TelecallerId] INT     NOT NULL,
    [LanguageId]   TINYINT NOT NULL,
    CONSTRAINT [PK_tblTeleCallerLanguageMapping] PRIMARY KEY CLUSTERED ([TelecallerId] ASC, [LanguageId] ASC)
);

