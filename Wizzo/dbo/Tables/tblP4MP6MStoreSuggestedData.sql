CREATE TABLE [dbo].[tblP4MP6MStoreSuggestedData] (
    [DistNodeId]   INT             NOT NULL,
    [DistNodeType] INT             NOT NULL,
    [StoreId]      INT             NOT NULL,
    [PrdNodeId]    INT             NOT NULL,
    [PrdNodeType]  INT             NOT NULL,
    [Qty]          INT             NULL,
    [NetValue]     NUMERIC (18, 6) NULL,
    [NetVolume]    NUMERIC (18, 6) NULL
);

