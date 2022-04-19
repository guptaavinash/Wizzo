CREATE TABLE [dbo].[tblPDAStoreFeedbackResponseMstr_ASM] (
    [StoreCheckVisitID]   INT            NULL,
    [StoreVisitCode]      VARCHAR (100)  NOT NULL,
    [flgApplicablemodule] TINYINT        NOT NULL,
    [GrpQuestID]          INT            NOT NULL,
    [QstId]               INT            NOT NULL,
    [AnsControlTypeID]    INT            NULL,
    [AnsValId]            VARCHAR (200)  NULL,
    [AnsTextVal]          NVARCHAR (MAX) NULL,
    [TimeStampIn]         SMALLDATETIME  NOT NULL,
    [OptionValue]         VARCHAR (50)   NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Store Addition,2=ASM Store Survey,3=ASM OverAll Feedback,4=ASM SubordinateFeedback', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPDAStoreFeedbackResponseMstr_ASM', @level2type = N'COLUMN', @level2name = N'flgApplicablemodule';

