CREATE TYPE [dbo].[POSMaterialDetail] AS TABLE (
    [MaterialID]      INT NOT NULL,
    [CurrentStockQty] INT NULL,
    [NewOrderQty]     INT NULL,
    [ReturnQty]       INT NULL,
    [DamageQty]       INT NULL);

