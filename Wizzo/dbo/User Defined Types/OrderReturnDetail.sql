CREATE TYPE [dbo].[OrderReturnDetail] AS TABLE (
    [PrdID]         INT           NOT NULL,
    [Qty]           INT           NOT NULL,
    [Reason]        VARCHAR (500) NOT NULL,
    [StockStatusId] TINYINT       NULL);

