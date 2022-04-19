CREATE TABLE [dbo].[tblMstrLineOfTrade] (
    [LoTId]   TINYINT       IDENTITY (1, 1) NOT NULL,
    [LoTName] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_tblMstrLineOfTrade] PRIMARY KEY CLUSTERED ([LoTId] ASC)
);

