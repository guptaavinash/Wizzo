CREATE TABLE [dbo].[tblMstrChannel] (
    [ChannelId]    INT           IDENTITY (1, 1) NOT NULL,
    [ChannelCode]  VARCHAR (20)  NOT NULL,
    [ChannelName]  VARCHAR (100) NOT NULL,
    [FileSetIdIns] BIGINT        NULL,
    [TimeStampIns] DATETIME      NULL,
    [NodeType]     INT           NULL
);

