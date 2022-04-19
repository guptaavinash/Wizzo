CREATE TABLE [dbo].[tblMstrSUBChannel] (
    [SubChannelId]   INT           IDENTITY (1, 1) NOT NULL,
    [SubChannelCode] VARCHAR (200) NULL,
    [SubChannel]     VARCHAR (200) NOT NULL,
    [ChannelId]      INT           NULL,
    [FileSetIdIns]   BIGINT        NULL,
    [TimeStampIns]   DATETIME      NULL,
    [NodeType]       SMALLINT      CONSTRAINT [DF_tblMstrSUBChannel_NodeType] DEFAULT ((400)) NULL,
    CONSTRAINT [PK_tblMstrSUBChannel] PRIMARY KEY CLUSTERED ([SubChannelId] ASC)
);

