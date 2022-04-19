CREATE TYPE [dbo].[udt_RawDataStoreReturnDetail] AS TABLE (
    [StoreID]               NVARCHAR (500) NULL,
    [VisitID]               NVARCHAR (500) NULL,
    [RouteID]               NVARCHAR (500) NULL,
    [RouteNodeType]         NVARCHAR (500) NULL,
    [ReturnProductID]       NVARCHAR (500) NULL,
    [ProdReturnQty]         NVARCHAR (500) NULL,
    [ProdReturnReason]      NVARCHAR (500) NULL,
    [ProdReturnReasonIndex] NVARCHAR (500) NULL,
    [ReturnDate]            NVARCHAR (500) NULL,
    [outstat]               NVARCHAR (500) NULL,
    [OrderIDPDA]            NVARCHAR (500) NULL,
    [StoreVisitCode]        NVARCHAR (500) NULL);

