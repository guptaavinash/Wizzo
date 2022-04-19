CREATE TABLE [dbo].[tblStoreTypeMstr] (
    [NodeID]    INT           IDENTITY (1, 1) NOT NULL,
    [StoreType] VARCHAR (200) NULL,
    [NodeType]  SMALLINT      CONSTRAINT [DF_tblStoreTypeMstr_NodeType] DEFAULT ((420)) NOT NULL,
    CONSTRAINT [PK_tblStoreTypeMstr] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);

