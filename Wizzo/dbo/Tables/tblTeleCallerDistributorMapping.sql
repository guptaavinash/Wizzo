CREATE TABLE [dbo].[tblTeleCallerDistributorMapping] (
    [TeleCallerId] INT NOT NULL,
    [DbrNodeId]    INT NOT NULL,
    [DbrNodeType]  INT NOT NULL,
    CONSTRAINT [PK_tblTeleCallerDistributorMapping] PRIMARY KEY CLUSTERED ([TeleCallerId] ASC, [DbrNodeId] ASC, [DbrNodeType] ASC)
);

