CREATE TABLE [dbo].[tblCompanySalesStructureHierarchy_Backup] (
    [HierID]       INT      NOT NULL,
    [NodeID]       INT      NOT NULL,
    [NodeType]     INT      NOT NULL,
    [PNodeID]      INT      NOT NULL,
    [PNodeType]    INT      NOT NULL,
    [HierTypeID]   INT      NOT NULL,
    [PHierId]      INT      NOT NULL,
    [VldFrom]      DATETIME NOT NULL,
    [VldTo]        DATETIME NOT NULL,
    [FileSetIdIns] BIGINT   NOT NULL,
    [LoginIdIns]   INT      NULL,
    [TimeStampIns] DATETIME NULL,
    CONSTRAINT [PK_tblCompanySalesStructureHierarchy_Backup] PRIMARY KEY CLUSTERED ([HierID] ASC)
);

