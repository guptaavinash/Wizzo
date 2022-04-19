CREATE TABLE [dbo].[tblDynamic_PDAQuestDependentMstr] (
    [AutoDependentQuestID] INT      NOT NULL,
    [QuestID]              INT      NULL,
    [DependentQuestID]     INT      NULL,
    [OptID]                INT      NULL,
    [GrpQuestID]           INT      NULL,
    [GrpDepQuestID]        INT      NULL,
    [NodeID]               INT      NULL,
    [NodeType]             SMALLINT NULL
);

