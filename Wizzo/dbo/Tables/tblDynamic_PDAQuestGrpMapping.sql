CREATE TABLE [dbo].[tblDynamic_PDAQuestGrpMapping] (
    [GrpQuestID]     INT           NOT NULL,
    [GrpID]          INT           NULL,
    [GrpDesc]        VARCHAR (200) NULL,
    [QuestID]        INT           NULL,
    [GrpNodeId]      INT           NULL,
    [SectionNo]      INT           NULL,
    [GrpCopyID]      INT           NULL,
    [QuestCopyID]    INT           NULL,
    [Sequence]       INT           NULL,
    [ActiveGrpQuest] TINYINT       NULL
);

