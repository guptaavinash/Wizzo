CREATE TYPE [dbo].[udt_RawDataQuestAnsMstr] AS TABLE (
    [StoreVisitCode]      NVARCHAR (500) NULL,
    [JointVisitCode]      NVARCHAR (500) NULL,
    [StoreCheckVisitID]   NVARCHAR (500) NULL,
    [JointVisitID]        NVARCHAR (500) NULL,
    [flgApplicablemodule] NVARCHAR (500) NULL,
    [QuestID]             NVARCHAR (500) NULL,
    [AnswerType]          NVARCHAR (500) NULL,
    [AnswerValue]         NVARCHAR (500) NULL,
    [QuestionGroupID]     NVARCHAR (500) NULL,
    [sectionID]           NVARCHAR (500) NULL,
    [Sstat]               NVARCHAR (500) NULL);

