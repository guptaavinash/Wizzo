CREATE TABLE [dbo].[tblFeedbackDSMVisit_ASM] (
    [StoreCheckVisitID]                INT     NOT NULL,
    [IsStoreInformationReviewed]       TINYINT CONSTRAINT [DF_tblFeedbackDSMVisit_ASM_IsStoreInformationReviewed] DEFAULT ((0)) NOT NULL,
    [IsStorecheckCompleted]            TINYINT CONSTRAINT [DF_tblFeedbackDSMVisit_ASM_IsStorecheckCompleted] DEFAULT ((0)) NOT NULL,
    [flgbeforeMerchandisingPhototaken] TINYINT CONSTRAINT [DF_Table_1_IsbeforeMerchandisingPhototaken] DEFAULT ((0)) NOT NULL,
    [flgAfterMerchandisingPhototaken]  TINYINT CONSTRAINT [DF_Table_1_IsAfterMerchandisingPhototaken] DEFAULT ((0)) NOT NULL,
    [IsStockCleaned/Re-arranged]       TINYINT CONSTRAINT [DF_tblFeedbackDSMVisit_ASM_IsStockCleaned/Re-arranged] DEFAULT ((0)) NOT NULL,
    [IsSalesPitchDone]                 TINYINT CONSTRAINT [DF_tblFeedbackDSMVisit_ASM_IsSalesPitchDon] DEFAULT ((0)) NOT NULL,
    [IsRajStockAvailable]              TINYINT CONSTRAINT [DF_tblFeedbackDSMVisit_ASM_IsRajStockAvailable] DEFAULT ((0)) NOT NULL,
    [flgSchemeExplained]               TINYINT CONSTRAINT [DF_tblFeedbackDSMVisit_ASM_IsSchemeExplained] DEFAULT ((0)) NOT NULL,
    [flgSKUPromoted]                   TINYINT CONSTRAINT [DF_tblFeedbackDSMVisit_ASM_flgSKUPromoted] DEFAULT ((0)) NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=No,1=Yes,2=Not Allowed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackDSMVisit_ASM', @level2type = N'COLUMN', @level2name = N'flgbeforeMerchandisingPhototaken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=No,1=Yes,2=Not Allowed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackDSMVisit_ASM', @level2type = N'COLUMN', @level2name = N'flgAfterMerchandisingPhototaken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Tried but Unsuccessful,1=Yes,2=Only took Order given by retailer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackDSMVisit_ASM', @level2type = N'COLUMN', @level2name = N'IsSalesPitchDone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=No,1=Yes,2=Not Applicable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackDSMVisit_ASM', @level2type = N'COLUMN', @level2name = N'flgSchemeExplained';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Tried but Unsuccessful,1=Yes,2=Only took Order given by retailer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFeedbackDSMVisit_ASM', @level2type = N'COLUMN', @level2name = N'flgSKUPromoted';

