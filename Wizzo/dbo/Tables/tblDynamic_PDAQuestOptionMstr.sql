CREATE TABLE [dbo].[tblDynamic_PDAQuestOptionMstr] (
    [OptID]        INT           NOT NULL,
    [AnsVal]       INT           NULL,
    [OptionDescr]  VARCHAR (300) NULL,
    [QuestID]      INT           NULL,
    [Sequence]     INT           NULL,
    [ActiveOption] TINYINT       NULL,
    [NodeID]       INT           NULL,
    [NodeType]     SMALLINT      NULL
);

