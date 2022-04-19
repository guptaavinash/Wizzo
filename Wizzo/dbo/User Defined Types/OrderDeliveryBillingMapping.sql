CREATE TYPE [dbo].[OrderDeliveryBillingMapping] AS TABLE (
    [Del_ROWNO]                     INT NULL,
    [OrderID]                       INT NULL,
    [DeliveryLocationNodeId]        INT NULL,
    [DeliveryLocationNodeType]      INT NULL,
    [DeliveryContactPersonNodeId]   INT NULL,
    [DeliveryContactPersonNodeType] INT NULL,
    [BillingLocationNodeId]         INT NULL,
    [BillingLocationNodeType]       INT NULL,
    [BillingDeptNodeId]             INT NULL,
    [BillingDeptNodeType]           INT NULL,
    [OrderDeliveryLocationId]       INT NULL,
    [OrderBillingLocationId]        INT NULL);

