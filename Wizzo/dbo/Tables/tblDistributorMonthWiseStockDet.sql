CREATE TABLE [dbo].[tblDistributorMonthWiseStockDet] (
    [DistStockID] INT           NULL,
    [Monthval]    INT           NULL,
    [Yearval]     INT           NULL,
    [monthname]   VARCHAR (200) NULL,
    [StockQty]    INT           NULL,
    CONSTRAINT [FK_tblDistributorMonthWiseStockDet_tblDistributorStockDet] FOREIGN KEY ([DistStockID]) REFERENCES [dbo].[tblDistributorStockDet] ([DistStockID]) ON DELETE CASCADE ON UPDATE CASCADE
);

