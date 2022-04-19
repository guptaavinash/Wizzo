CREATE TABLE [dbo].[tblDynamic_PDAQuestMstr] (
    [QuestID]                       INT           NOT NULL,
    [QuestCode]                     VARCHAR (50)  NULL,
    [QuestDesc]                     VARCHAR (500) NULL,
    [QuestType]                     INT           NULL,
    [AnsControlType]                INT           NULL,
    [AsnControlInputTypeID]         INT           NOT NULL,
    [AnsControlIntputTypeMinLength] INT           NULL,
    [AnsControlInputTypeMaxLength]  INT           NULL,
    [AnswerHint]                    VARCHAR (50)  NULL,
    [AnsMustRequiredFlg]            INT           NULL,
    [QuestBundleFlg]                INT           NULL,
    [ApplicationTypeID]             INT           NULL,
    [Sequence]                      TINYINT       NULL,
    [ActiveQuest]                   TINYINT       NULL,
    [LoginID]                       INT           NULL,
    [CreateDate]                    DATETIME      NULL,
    [LoginID_Modify]                INT           NULL,
    [ModifyDate]                    DATETIME      NULL,
    [AnsSourceTypeID]               TINYINT       NULL,
    [AnsSourceNodeType]             SMALLINT      NULL,
    [AnsSourceOptionDep]            TINYINT       CONSTRAINT [DF_tblDynamic_PDAQuestMstr_AnsSourceOptionDep_1] DEFAULT ((0)) NULL,
    [flgPrvValue]                   TINYINT       CONSTRAINT [DF_tblDynamic_PDAQuestMstr_flgPrvValue_1] DEFAULT ((0)) NULL,
    [flgPrvVisitDependency]         TINYINT       CONSTRAINT [DF_tblDynamic_PDAQuestMstr_flgPrvVisitDependency_1] DEFAULT ((0)) NULL,
    [flgOptionAreaDependent]        TINYINT       CONSTRAINT [DF_tblDynamic_PDAQuestMstr_flgOptionAreaDependent_1] DEFAULT ((0)) NULL,
    [OptionAreaSource]              VARCHAR (200) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=When option dependency required on master table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDynamic_PDAQuestMstr', @level2type = N'COLUMN', @level2name = N'AnsSourceOptionDep';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=No Previous value to be shown,1=Previous value to be shown as lable with no need for current value entry.2=Previous value to be shown by default and can be edited.3=Previous value shown as seperate lable with defalut control for data entry.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDynamic_PDAQuestMstr', @level2type = N'COLUMN', @level2name = N'flgPrvValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Qsnt will only appear based on value of previous visit result.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDynamic_PDAQuestMstr', @level2type = N'COLUMN', @level2name = N'flgPrvVisitDependency';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Options are not based on working area,1=Options are based on working Area.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDynamic_PDAQuestMstr', @level2type = N'COLUMN', @level2name = N'flgOptionAreaDependent';

