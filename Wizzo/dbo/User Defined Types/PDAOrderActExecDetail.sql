CREATE TYPE [dbo].[PDAOrderActExecDetail] AS TABLE (
    [PrdId]   INT            NULL,
    [Rate]    [dbo].[Amount] NOT NULL,
    [Qty]     INT            NULL,
    [FreeQty] INT            NULL,
    [DiscAmt] [dbo].[Amount] NULL);

