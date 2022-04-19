CREATE TYPE [dbo].[udt_RawDistProductStock] AS TABLE (
    [CustomerNodeID]   INT           NULL,
    [CustomerNodeType] SMALLINT      NULL,
    [StockDate]        DATE          NULL,
    [PDACode]          VARCHAR (100) NULL,
    [ProductNodeID]    INT           NULL,
    [ProductNodeType]  SMALLINT      NULL,
    [Monthval]         INT           NULL,
    [Yearval]          INT           NULL,
    [MonthName]        VARCHAR (100) NULL,
    [StockQty]         INT           NULL,
    [flgProductType]   TINYINT       NULL);

