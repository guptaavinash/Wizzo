CREATE TYPE [dbo].[SchemeSalesHier] AS TABLE (
    [SchemeDetID] INT     NULL,
    [SHNodeID]    INT     NOT NULL,
    [SHNodeType]  INT     NOT NULL,
    [flgActive]   TINYINT NULL);

