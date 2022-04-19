CREATE TABLE [dbo].[tblFeedbackDSMStoreVisit_ASM] (
    [FeedbackStoreVisitID]          INT     IDENTITY (1, 1) NOT NULL,
    [StoreCheckVisitID]             INT     NULL,
    [flgRetPrdBuying]               TINYINT NULL,
    [flgRetailerSatisfactionRajPrd] TINYINT NOT NULL,
    [flgRetailerSatisfiedwithDB]    TINYINT NOT NULL,
    [flgRajProminentBrand]          TINYINT NOT NULL,
    [IsPotentialForNewPrd]          TINYINT NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=UnSatisfied,1=Satisfied,2=Indifferent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackDSMStoreVisit_ASM', @level2type = N'COLUMN', @level2name = N'flgRetailerSatisfactionRajPrd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=UnSatisfied,1=Satisfied,2=Indifferent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackDSMStoreVisit_ASM', @level2type = N'COLUMN', @level2name = N'flgRetailerSatisfiedwithDB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Top,2=Top2,3=Not In Top2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackDSMStoreVisit_ASM', @level2type = N'COLUMN', @level2name = N'flgRajProminentBrand';

