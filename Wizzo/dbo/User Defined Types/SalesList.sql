CREATE TYPE [dbo].[SalesList] AS TABLE (
    [Descr]     VARCHAR (200) NULL,
    [NodeID]    INT           NULL,
    [NodeType]  SMALLINT      NULL,
    [HierID]    INT           NULL,
    [PNodeID]   INT           NULL,
    [PNodeType] SMALLINT      NULL,
    [PHierID]   INT           NULL,
    [LstLevel]  TINYINT       NULL);

