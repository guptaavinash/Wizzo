CREATE TYPE [dbo].[SchemeDstrHier] AS TABLE (
    [SchemeDetID] INT     NULL,
    [DHNodeID]    INT     NOT NULL,
    [DHNodeType]  INT     NOT NULL,
    [flgActive]   TINYINT NULL);

