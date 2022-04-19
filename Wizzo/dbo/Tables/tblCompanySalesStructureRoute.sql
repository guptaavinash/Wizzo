CREATE TABLE [dbo].[tblCompanySalesStructureRoute] (
    [NodeID]       INT           IDENTITY (1, 1) NOT NULL,
    [Code]         VARCHAR (500) NULL,
    [Descr]        VARCHAR (500) NULL,
    [NodeType]     INT           NOT NULL,
    [IsActive]     BIT           NOT NULL,
    [SONodeId]     INT           NOT NULL,
    [SONodeType]   INT           NOT NULL,
    [FileSetIDIns] BIGINT        NOT NULL,
    [TimestampIns] DATETIME      NOT NULL,
    [FileSetIDUpd] INT           NULL,
    [TimestampUpd] DATETIME      NULL,
    [RouteNo]      INT           NULL,
    CONSTRAINT [PK_tblCompanySalesStructureRoute] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);

