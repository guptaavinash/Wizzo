CREATE TYPE [dbo].[SchemeTown] AS TABLE (
    [SchemeDetID] INT     NULL,
    [TCNodeID]    INT     NOT NULL,
    [TCNodeType]  INT     NOT NULL,
    [flgActive]   TINYINT NULL);

