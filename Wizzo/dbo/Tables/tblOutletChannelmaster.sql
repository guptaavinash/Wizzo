CREATE TABLE [dbo].[tblOutletChannelmaster] (
    [OutChannelID]      INT           NOT NULL,
    [ChannelName]       VARCHAR (100) NOT NULL,
    [BusinessSegmentID] TINYINT       CONSTRAINT [DF_tblOutletChannelmaster_BusinessSegmentID] DEFAULT ((1)) NOT NULL,
    [NodeType]          SMALLINT      CONSTRAINT [DF_tblOutletChannelmaster_NodeType] DEFAULT ((240)) NULL,
    CONSTRAINT [PK_tblOutletChannelmaster] PRIMARY KEY CLUSTERED ([OutChannelID] ASC)
);

