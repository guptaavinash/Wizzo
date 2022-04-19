CREATE TYPE [dbo].[udt_storemapping] AS TABLE (
    [StoreID]                INT      NULL,
    [CurrentRouteNodeID]     INT      NULL,
    [CurrentRouteNodetype]   SMALLINT NULL,
    [NewRouteNodeID]         INT      NULL,
    [NewRouteNodeType]       SMALLINT NULL,
    [flgAction]              TINYINT  NULL,
    [NewDistributorID]       INT      NULL,
    [NewDistributorNodeType] SMALLINT NULL);

