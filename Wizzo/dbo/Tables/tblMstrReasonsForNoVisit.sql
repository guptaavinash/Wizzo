CREATE TABLE [dbo].[tblMstrReasonsForNoVisit] (
    [ReasonId]         INT           NOT NULL,
    [ReasonDescr]      VARCHAR (200) NULL,
    [FlgToShowTextBox] TINYINT       NULL,
    [flgSOApplicable]  TINYINT       CONSTRAINT [DF_tblMstrReasonsForNoVisit_flgSOApplicable_1] DEFAULT ((0)) NULL,
    [flgDSRApplicable] TINYINT       CONSTRAINT [DF_tblMstrReasonsForNoVisit_flgDSRApplicable_1] DEFAULT ((0)) NULL,
    [flgNoVisitOption] TINYINT       CONSTRAINT [DF_tblMstrReasonsForNoVisit_flgNoVisitOption_1] DEFAULT ((0)) NULL,
    [SeqNo]            INT           NULL,
    [Priority]         TINYINT       CONSTRAINT [DF_tblMstrReasonsForNoVisit_Priority] DEFAULT ((0)) NOT NULL,
    [flgDelayedReason] TINYINT       NULL,
    [flgMarketVisit]   TINYINT       NULL,
    [flgASMApplicable] TINYINT       NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMstrReasonsForNoVisit', @level2type = N'COLUMN', @level2name = N'flgSOApplicable';

