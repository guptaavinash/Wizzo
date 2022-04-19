CREATE TABLE [dbo].[tblCompanySalesStructureHierarchy] (
    [HierID]       INT      IDENTITY (1, 1) NOT NULL,
    [NodeID]       INT      NOT NULL,
    [NodeType]     INT      NOT NULL,
    [PNodeID]      INT      NOT NULL,
    [PNodeType]    INT      NOT NULL,
    [HierTypeID]   INT      NOT NULL,
    [PHierId]      INT      NOT NULL,
    [VldFrom]      DATETIME NOT NULL,
    [VldTo]        DATETIME NOT NULL,
    [FileSetIdIns] BIGINT   NOT NULL,
    CONSTRAINT [PK_tblCompanySalesStructureHierarchy] PRIMARY KEY CLUSTERED ([HierID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Indx_CompanyHierarchy]
    ON [dbo].[tblCompanySalesStructureHierarchy]([VldFrom] ASC, [VldTo] ASC)
    INCLUDE([NodeID], [NodeType], [PNodeID], [PNodeType]);

