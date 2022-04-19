CREATE TABLE [dbo].[tblPrdMstrHierarchy_History] (
    [HierID]       INT    NOT NULL,
    [NodeID]       INT    NOT NULL,
    [NodeType]     INT    NOT NULL,
    [PNodeID]      INT    NOT NULL,
    [PNodeType]    INT    NOT NULL,
    [HierTypeID]   INT    NOT NULL,
    [PHierId]      INT    NOT NULL,
    [VldFrom]      DATE   NULL,
    [VldTo]        DATE   NULL,
    [FileSetIdIns] BIGINT NULL
);

