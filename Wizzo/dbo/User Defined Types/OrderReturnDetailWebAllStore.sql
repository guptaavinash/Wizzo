CREATE TYPE [dbo].[OrderReturnDetailWebAllStore] AS TABLE (
    [StoreId]        INT            NULL,
    [PrdID]          INT            NOT NULL,
    [Qty]            INT            NOT NULL,
    [Rate]           [dbo].[Amount] NOT NULL,
    [Tax]            [dbo].[Amount] NOT NULL,
    [NetValueReturn] [dbo].[Amount] NOT NULL,
    [UOMID]          INT            NULL,
    [Reason]         VARCHAR (500)  NOT NULL,
    [StockStatusId]  INT            NULL,
    [InvQtyDetail]   VARCHAR (500)  NULL,
    [EffRate]        [dbo].[Amount] NOT NULL);

