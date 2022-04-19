CREATE TABLE [dbo].[tblOrderSendOnMailRequest] (
    [RequestID]      INT           IDENTITY (1, 1) NOT NULL,
    [PDACode]        VARCHAR (200) NOT NULL,
    [PersonNodeID]   INT           NULL,
    [PersonNodeType] SMALLINT      NULL,
    [DataDate]       DATE          NULL,
    [EMailID]        VARCHAR (500) NULL,
    [flgSendStatus]  TINYINT       CONSTRAINT [DF_tblOrderSendOnMailRequest_flgSendStatus] DEFAULT ((0)) NULL,
    [Failedtext]     VARCHAR (MAX) NULL,
    [TimestampIns]   DATETIME      CONSTRAINT [DF_tblOrderSendOnMailRequest_TimestampIns] DEFAULT (getdate()) NULL,
    [TimestampUpd]   DATETIME      NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Picked for sending,2=Send,3=Failed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblOrderSendOnMailRequest', @level2type = N'COLUMN', @level2name = N'flgSendStatus';

