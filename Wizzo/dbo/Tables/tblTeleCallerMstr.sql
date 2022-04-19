CREATE TABLE [dbo].[tblTeleCallerMstr] (
    [TeleCallerId]             INT           IDENTITY (1, 1) NOT NULL,
    [TeleCallerCode]           VARCHAR (50)  NOT NULL,
    [flgActive]                TINYINT       NOT NULL,
    [NodeType]                 SMALLINT      CONSTRAINT [DF_tblTeleCallerMstr_NodeType] DEFAULT ((220)) NOT NULL,
    [SiteNodeId]               INT           NOT NULL,
    [SiteNodeType]             INT           NOT NULL,
    [TSVNodeId]                INT           NOT NULL,
    [TSVNodeType]              INT           NOT NULL,
    [TCType]                   TINYINT       CONSTRAINT [DF_tblTeleCallerMstr_TCType] DEFAULT ((1)) NOT NULL,
    [LoginIdIns]               INT           CONSTRAINT [DF_tblTeleCallerMstr_LoginIdIns] DEFAULT ((0)) NOT NULL,
    [TimeStampIns]             DATETIME      CONSTRAINT [DF_tblTeleCallerMstr_TimeStampIns] DEFAULT (getdate()) NOT NULL,
    [LoginIdUpd]               INT           NULL,
    [TimeStampUpd]             DATETIME      NULL,
    [TeleCallerCodeForExtract] VARCHAR (50)  NULL,
    [TeleCallerName]           VARCHAR (100) NULL,
    [DialerTypeId]             TINYINT       CONSTRAINT [DF_tblTeleCallerMstr_CallingSource] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblTeleCallerMstr] PRIMARY KEY CLUSTERED ([TeleCallerId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblTeleCallerMstr]
    ON [dbo].[tblTeleCallerMstr]([TeleCallerId] ASC, [NodeType] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Astix Dialer App,3=Cloud Telephony', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblTeleCallerMstr', @level2type = N'COLUMN', @level2name = N'TeleCallerId';

