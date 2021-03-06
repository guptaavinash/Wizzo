CREATE TYPE [dbo].[PickListReassignDet] AS TABLE (
    [ItemId]            INT            NULL,
    [PckLstId]          INT            NULL,
    [PckLstDetId]       INT            NULL,
    [PrdId]             INT            NULL,
    [PrdBatchId]        INT            NULL,
    [Orderid]           INT            NULL,
    [ReqTotQty]         INT            NULL,
    [ReqFreeQty]        INT            NULL,
    [ReqBilledQty]      INT            NULL,
    [ReqReplacedQty]    INT            NULL,
    [ActTotQty]         INT            NULL,
    [ActFreeQty]        INT            NULL,
    [ActBilledQty]      INT            NULL,
    [PendingFreeQty]    INT            NULL,
    [ActReplacedQty]    INT            NULL,
    [Remarks]           VARCHAR (500)  NULL,
    [flgShortFreePrd]   TINYINT        NULL,
    [SchemeSlabId]      INT            NULL,
    [ReplacedQtyString] VARCHAR (1000) NULL);

