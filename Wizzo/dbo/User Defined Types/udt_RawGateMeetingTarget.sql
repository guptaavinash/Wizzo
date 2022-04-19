CREATE TYPE [dbo].[udt_RawGateMeetingTarget] AS TABLE (
    [CovAreaNodeID]       VARCHAR (500) NULL,
    [CovAreaNodeType]     VARCHAR (500) NULL,
    [PersonNodeID]        VARCHAR (500) NULL,
    [PersonNodeType]      VARCHAR (500) NULL,
    [Dstrbn_Tgt]          VARCHAR (500) NULL,
    [Sales_Tgt]           VARCHAR (500) NULL,
    [PDACode]             VARCHAR (500) NULL,
    [EntryPersonNOdeID]   INT           NULL,
    [EntryPersonNodeType] INT           NULL,
    [EntryDate]           VARCHAR (500) NULL);

