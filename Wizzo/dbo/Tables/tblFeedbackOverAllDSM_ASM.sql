CREATE TABLE [dbo].[tblFeedbackOverAllDSM_ASM] (
    [FeedbackOverAllID]          INT     IDENTITY (1, 1) NOT NULL,
    [JointVisitId]               INT     NOT NULL,
    [flgDSMKnewRetailername]     TINYINT NOT NULL,
    [flgDSMStartedDayOnTime]     TINYINT NOT NULL,
    [flgDSMAwareMarketGeography] TINYINT NOT NULL,
    [flgDSMAwareProductDet]      TINYINT NOT NULL,
    CONSTRAINT [PK_tblFeedbackOverAllDSM_ASM] PRIMARY KEY CLUSTERED ([FeedbackOverAllID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Knew All
2=Knew Most
3=Knew Some
4=Knew None', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackOverAllDSM_ASM', @level2type = N'COLUMN', @level2name = N'flgDSMKnewRetailername';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Was on Time
2=Was more than 1 hour delayed
3=Was more than 30 minutes delayed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackOverAllDSM_ASM', @level2type = N'COLUMN', @level2name = N'flgDSMStartedDayOnTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Not Aware
1=Yes was aware
2=Somewhat aware of the market', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackOverAllDSM_ASM', @level2type = N'COLUMN', @level2name = N'flgDSMAwareMarketGeography';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Not Aware
1=Yes he was well aware
2=Somewhat aware of the product details', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackOverAllDSM_ASM', @level2type = N'COLUMN', @level2name = N'flgDSMAwareProductDet';

