CREATE TABLE [dbo].[tblTeleCallingInvMstr] (
    [TeleCallingId]  INT          NOT NULL,
    [InvNo]          VARCHAR (50) NOT NULL,
    [InvDate]        DATE         NOT NULL,
    [flgOrderSource] TINYINT      NULL,
    CONSTRAINT [PK_tblTeleCallingInvMstr] PRIMARY KEY CLUSTERED ([TeleCallingId] ASC, [InvNo] ASC, [InvDate] ASC)
);

