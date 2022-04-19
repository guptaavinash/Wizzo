CREATE TABLE [dbo].[tblVanStockDet] (
    [VanLoadUnLoadCycID] INT           NOT NULL,
    [PrdNodeID]          INT           NOT NULL,
    [PrdNodetype]        INT           NOT NULL,
    [LoadQty]            INT           NULL,
    [UnLoadQty]          INT           NULL,
    [UOMID]              INT           NULL,
    [LoadTime]           SMALLDATETIME NULL,
    [UnloadTime]         SMALLDATETIME NULL,
    CONSTRAINT [FK_tblVanStockDet_tblVanStockMaster] FOREIGN KEY ([VanLoadUnLoadCycID]) REFERENCES [dbo].[tblVanStockMaster] ([VanLoadUnLoadCycID]) ON DELETE CASCADE ON UPDATE CASCADE
);

