CREATE TABLE [dbo].[tblTeleCallRuleBranchSMSMapping] (
    [BrnSMSMapId]   INT      IDENTITY (1, 1) NOT NULL,
    [RuleBrnMapId]  INT      NOT NULL,
    [SmsTemplateId] INT      NOT NULL,
    [FromDate]      DATE     NOT NULL,
    [ToDate]        DATE     NOT NULL,
    [LoginIdIns]    INT      NULL,
    [TimeStampUpd]  DATETIME NULL,
    CONSTRAINT [PK_tblTeleCallRuleBranchSMSMapping] PRIMARY KEY CLUSTERED ([BrnSMSMapId] ASC)
);

