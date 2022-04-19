CREATE TABLE [dbo].[tblTeleCallRuleBranchChannelMapping] (
    [RuleBrnMapId] INT NOT NULL,
    [ChnlId]       INT NOT NULL,
    CONSTRAINT [PK_tblRuleBranchChannelMapping] PRIMARY KEY CLUSTERED ([RuleBrnMapId] ASC, [ChnlId] ASC),
    CONSTRAINT [FK_tblTeleCallRuleBranchChannelMapping_tblTeleCallRuleBranchMapping] FOREIGN KEY ([RuleBrnMapId]) REFERENCES [dbo].[tblTeleCallRuleBranchMapping] ([RuleBrnMapId]) ON DELETE CASCADE ON UPDATE CASCADE
);

