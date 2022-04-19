CREATE TABLE [dbo].[tblWhatsAppAPI_OutgoingMessages] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [CustomerMobNo]    BIGINT        NOT NULL,
    [CustomerNodeID]   INT           NULL,
    [CustomerNodeType] SMALLINT      NULL,
    [Text]             VARCHAR (MAX) NULL,
    [Type]             TINYINT       NULL,
    [TimestampIns]     DATETIME      NULL,
    [flgmessageSent]   TINYINT       CONSTRAINT [DF_tblWhatsAppAPI_OutgoingMessages_flgmessageSent] DEFAULT ((0)) NULL,
    [RefMessageID]     VARCHAR (100) NULL,
    [SentTimestamp]    DATETIME      NULL
);

