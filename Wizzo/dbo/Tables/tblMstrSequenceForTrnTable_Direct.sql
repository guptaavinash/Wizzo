CREATE TABLE [dbo].[tblMstrSequenceForTrnTable_Direct] (
    [ID]            INT          IDENTITY (1, 1) NOT NULL,
    [TableName]     VARCHAR (50) NULL,
    [ColumnName]    VARCHAR (50) NULL,
    [TableUnqTag]   VARCHAR (3)  NULL,
    [FYID]          INT          NULL,
    [SalesNodeId]   INT          NULL,
    [SalesNodeType] INT          NULL,
    [InitialTag]    VARCHAR (10) NULL,
    [NumberLength]  INT          NULL,
    [LastGenNum]    INT          NULL,
    CONSTRAINT [PK_tblMstrSequenceForTrnTable_Direct] PRIMARY KEY CLUSTERED ([ID] ASC)
);

