CREATE TABLE [dbo].[tblDynamic_ApplicationQuestMappingMstr] (
    [QuestID]               INT     NOT NULL,
    [ApplicationTypeID]     INT     NOT NULL,
    [flgNewStore]           TINYINT CONSTRAINT [DF_tblDynamic_ApplicationQuestMappingMstr_flgNewStore] DEFAULT ((0)) NULL,
    [flgStoreValidation]    TINYINT CONSTRAINT [DF_tblDynamic_ApplicationQuestMappingMstr_flgStoreValidation_1] DEFAULT ((0)) NULL,
    [flgDSMVisitFeedback]   TINYINT NULL,
    [flgStoreVisitFeedback] TINYINT NULL,
    [flgDSMOverAllFeedback] TINYINT NULL
);

