CREATE TABLE [dbo].[tblMstrTeleCallRule] (
    [RuleId]          TINYINT      IDENTITY (1, 1) NOT NULL,
    [RuleCode]        VARCHAR (20) NULL,
    [RuleName]        VARCHAR (50) NOT NULL,
    [RuleDisplayName] VARCHAR (50) NULL,
    CONSTRAINT [PK_tblMstrRule] PRIMARY KEY CLUSTERED ([RuleId] ASC)
);

