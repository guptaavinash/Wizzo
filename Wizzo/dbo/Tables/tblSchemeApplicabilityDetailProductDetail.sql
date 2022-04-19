CREATE TABLE [dbo].[tblSchemeApplicabilityDetailProductDetail] (
    [ChannelId]           INT             NOT NULL,
    [SubChannelId]        INT             NOT NULL,
    [DistributorNodeId]   INT             NOT NULL,
    [DistributorNodeType] INT             NOT NULL,
    [LotId]               INT             NOT NULL,
    [StoreId]             INT             NOT NULL,
    [PrdNodeId]           INT             NULL,
    [PrdNodeType]         INT             NULL,
    [MRP]                 NUMERIC (18, 6) NULL,
    [SchemeString]        VARCHAR (MAX)   NULL
);

