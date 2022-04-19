CREATE TABLE [dbo].[tblDynamic_PDAQuestOptionsWithDepOptions] (
    [DepQuestId]    INT           NULL,
    [DepOptId]      INT           NULL,
    [QuestId]       INT           NULL,
    [OptId]         INT           NULL,
    [OptDescr]      VARCHAR (200) NULL,
    [Sequence]      INT           NULL,
    [GrpQuestID]    INT           NULL,
    [GrpDepQuestID] INT           NULL,
    [DepNodeID]     INT           NULL,
    [DepNodeType]   SMALLINT      NULL,
    [NodeID]        INT           NULL,
    [NodeType]      SMALLINT      NULL
);

