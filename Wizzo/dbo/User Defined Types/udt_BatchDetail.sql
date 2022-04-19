CREATE TYPE [dbo].[udt_BatchDetail] AS TABLE (
    [GeoNodeId]              INT            NOT NULL,
    [GeogNodeType]           INT            NOT NULL,
    [PrdBatchLFCustOrderID]  INT            NOT NULL,
    [PrdBatchLFCustSupplyID] INT            NOT NULL,
    [BatchOrderStatusDate]   DATE           NULL,
    [BatchOrderSupplyDate]   DATE           NULL,
    [MRP]                    [dbo].[Amount] NOT NULL);

