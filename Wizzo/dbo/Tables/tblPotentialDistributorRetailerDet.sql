CREATE TABLE [dbo].[tblPotentialDistributorRetailerDet] (
    [DBNodeID]       INT           NULL,
    [DBNodeType]     SMALLINT      NULL,
    [RetailerCode]   VARCHAR (100) NULL,
    [RetailerName]   VARCHAR (200) NULL,
    [Address]        VARCHAR (500) NULL,
    [Comment]        VARCHAR (500) NULL,
    [RetFeedback]    TINYINT       CONSTRAINT [DF_tblPotentialDistributorRetailerDet_RetFeedback] DEFAULT ((0)) NULL,
    [TimestampIns]   DATETIME      CONSTRAINT [DF_tblPotentialDistributorRetailerDet_TimestampIns] DEFAULT (getdate()) NULL,
    [TimestampUpd]   DATETIME      NULL,
    [flgFinalSubmit] TINYINT       CONSTRAINT [DF_tblPotentialDistributorRetailerDet_flgFinalSubmit] DEFAULT ((0)) NULL,
    [ContactNumber]  BIGINT        NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Good,2=Bad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributorRetailerDet', @level2type = N'COLUMN', @level2name = N'RetFeedback';

