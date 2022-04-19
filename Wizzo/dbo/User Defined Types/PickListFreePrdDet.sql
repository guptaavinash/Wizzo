CREATE TYPE [dbo].[PickListFreePrdDet] AS TABLE (
    [ItemId]              INT           NULL,
    [PckLstId]            INT           NULL,
    [PckLstDetId]         INT           NULL,
    [PrdId]               INT           NULL,
    [PrdBatchId]          INT           NULL,
    [Orderid]             INT           NULL,
    [TotQty]              INT           NULL,
    [ActQty]              INT           NULL,
    [SchemeSlabId]        INT           NULL,
    [SchemeSlabMappingId] INT           NULL,
    [SourceProduct]       VARCHAR (500) NULL,
    [BenfitTypeId]        SMALLINT      NULL);

