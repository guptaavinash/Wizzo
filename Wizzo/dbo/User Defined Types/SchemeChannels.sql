CREATE TYPE [dbo].[SchemeChannels] AS TABLE (
    [SchemeDetID] INT     NULL,
    [CHNodeID]    INT     NOT NULL,
    [CHNodeType]  INT     NOT NULL,
    [flgActive]   TINYINT NULL);

