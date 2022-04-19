CREATE TABLE [dbo].[tblVisitStock] (
    [VisitStockID] INT      IDENTITY (1, 1) NOT NULL,
    [VisitID]      INT      NOT NULL,
    [StockDate]    DATETIME NOT NULL,
    [ProductID]    INT      NOT NULL,
    [Qty]          INT      NOT NULL,
    [StoreID]      INT      NULL,
    CONSTRAINT [FK_tblVisitStock_tblVisitMaster] FOREIGN KEY ([VisitID]) REFERENCES [dbo].[tblVisitMaster] ([VisitID]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_tblVisitStock]
    ON [dbo].[tblVisitStock]([StockDate] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_tblVisitStock_1]
    ON [dbo].[tblVisitStock]([StoreID] ASC);

