CREATE TABLE [dbo].[tblP3MBeatWiseSales] (
    [RouteNodeId]   INT             NOT NULL,
    [RouteNodeType] INT             NOT NULL,
    [PrdNodeId]     INT             NOT NULL,
    [PrdNodeType]   INT             NOT NULL,
    [Qty]           INT             NOT NULL,
    [NetValue]      NUMERIC (18, 6) NOT NULL
);

