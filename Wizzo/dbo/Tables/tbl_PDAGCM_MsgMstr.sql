CREATE TABLE [dbo].[tbl_PDAGCM_MsgMstr] (
    [PDAGCM_MsgID]           INT           IDENTITY (1, 1) NOT NULL,
    [PDAGCMAutoID]           INT           NULL,
    [PDAGCM_Msg]             VARCHAR (500) NULL,
    [PDAGCM_MsgSendingTime]  DATETIME      CONSTRAINT [DF_tbl_PDAGCM_MsgMstr_PDAGCM_MsgSendingTime] DEFAULT (getdate()) NULL,
    [PDAGCM_MsgSendStatus]   INT           CONSTRAINT [DF_tbl_PDAGCM_MsgMstr_PDAGCM_MsgSendStatus] DEFAULT ((1)) NULL,
    [PDAGCM_MsgReadStatus]   INT           CONSTRAINT [DF_tbl_PDAGCM_MsgMstr_PDAGCM_MsgReadStatus] DEFAULT ((1)) NULL,
    [PDAGCM_MsgReadDateTime] DATETIME      NULL,
    [AppVersionID]           VARCHAR (50)  NULL,
    [flgnotificationType]    TINYINT       CONSTRAINT [DF_tbl_PDAGCM_MsgMstr_flgnotificationType_1] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tbl_PDAGCM_MsgMstr] PRIMARY KEY CLUSTERED ([PDAGCM_MsgID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 means Msg yet released and 0 means Msg is released', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_PDAGCM_MsgMstr', @level2type = N'COLUMN', @level2name = N'PDAGCM_MsgSendStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 means Msg yet to read and 0 means user read the msg', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_PDAGCM_MsgMstr', @level2type = N'COLUMN', @level2name = N'PDAGCM_MsgReadStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Load/Unload,2=Day End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tbl_PDAGCM_MsgMstr', @level2type = N'COLUMN', @level2name = N'flgnotificationType';

