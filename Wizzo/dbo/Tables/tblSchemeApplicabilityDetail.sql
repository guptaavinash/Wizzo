CREATE TABLE [dbo].[tblSchemeApplicabilityDetail] (
    [SchemeDetID]         INT     NOT NULL,
    [ChannelId]           INT     NOT NULL,
    [SubChannelId]        INT     NOT NULL,
    [LoTId]               TINYINT NOT NULL,
    [DistributorNodeId]   INT     NOT NULL,
    [DistributorNodeType] INT     NOT NULL,
    [StoreId]             INT     NOT NULL,
    [StateId]             INT     NOT NULL,
    [FileSetId]           BIGINT  NULL,
    CONSTRAINT [FK_tblSchemeApplicabilityDetail_tblSchemeDetail] FOREIGN KEY ([SchemeDetID]) REFERENCES [dbo].[tblSchemeDetail] ([SchemeDetID]) ON DELETE CASCADE ON UPDATE CASCADE
);

