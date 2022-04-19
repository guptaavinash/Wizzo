CREATE TABLE [dbo].[tblTeleCallRuleBranchMapping] (
    [RuleBrnMapId]       INT      IDENTITY (1, 1) NOT NULL,
    [RuleId]             INT      NOT NULL,
    [FrqTypeId]          TINYINT  CONSTRAINT [DF_tblRuleBranchMapping_FrqTypeId] DEFAULT ((0)) NOT NULL,
    [BranchSubdNodeId]   INT      NOT NULL,
    [BranchSubdNodeType] INT      NOT NULL,
    [DayFrom]            SMALLINT NOT NULL,
    [DayTo]              SMALLINT NOT NULL,
    [FromDate]           DATE     CONSTRAINT [DF_tblRuleBranchMapping_FromDate] DEFAULT (getdate()) NOT NULL,
    [ToDate]             DATE     CONSTRAINT [DF_tblRuleBranchMapping_ToDate] DEFAULT ('2050-12-31') NOT NULL,
    CONSTRAINT [PK_tblRuleBranchMapping] PRIMARY KEY CLUSTERED ([RuleBrnMapId] ASC)
);

