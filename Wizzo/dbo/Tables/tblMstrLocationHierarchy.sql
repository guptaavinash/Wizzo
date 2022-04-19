CREATE TABLE [dbo].[tblMstrLocationHierarchy] (
    [HierID]     INT      NOT NULL,
    [NodeID]     INT      NOT NULL,
    [NodeType]   INT      NOT NULL,
    [PNodeID]    INT      NOT NULL,
    [PNodeType]  INT      NOT NULL,
    [HierTypeID] INT      NOT NULL,
    [PHierId]    INT      NOT NULL,
    [VldFrom]    DATETIME NULL,
    [VldTo]      DATETIME NULL,
    [LoginID]    INT      NULL
);

