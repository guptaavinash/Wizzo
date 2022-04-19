CREATE TYPE [dbo].[udt_DistProductStock] AS TABLE (
    [ProductNodeID]   INT           NULL,
    [ProductNodeType] SMALLINT      NULL,
    [Monthval]        INT           NULL,
    [Yearval]         INT           NULL,
    [MonthName]       VARCHAR (100) NULL,
    [StockQty]        INT           NULL,
    [flgProductType]  TINYINT       NULL);

