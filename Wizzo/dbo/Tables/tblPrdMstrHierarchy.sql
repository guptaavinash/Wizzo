CREATE TABLE [dbo].[tblPrdMstrHierarchy] (
    [HierID]       INT    IDENTITY (1, 1) NOT NULL,
    [NodeID]       INT    NOT NULL,
    [NodeType]     INT    NOT NULL,
    [PNodeID]      INT    NOT NULL,
    [PNodeType]    INT    NOT NULL,
    [HierTypeID]   INT    CONSTRAINT [DF_tblPrdMstrHierarchy_HierTypeID] DEFAULT ((1)) NOT NULL,
    [PHierId]      INT    NOT NULL,
    [VldFrom]      DATE   CONSTRAINT [DF_tblPrdMstrHierarchy_VldFrom] DEFAULT (getdate()) NULL,
    [VldTo]        DATE   CONSTRAINT [DF_tblPrdMstrHierarchy_VldTo] DEFAULT ('31-Dec-2049') NULL,
    [FileSetIdins] BIGINT NULL,
    CONSTRAINT [PK__tblPrdMs__6F490D708A204A47] PRIMARY KEY CLUSTERED ([HierID] ASC)
);

