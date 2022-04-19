CREATE TYPE [dbo].[OrderReasonMap] AS TABLE (
    [OrderID]    INT           NOT NULL,
    [ReasonId]   INT           NULL,
    [ReasonText] VARCHAR (500) NULL);

