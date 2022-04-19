CREATE TABLE [dbo].[tblCartonDetail] (
    [CartonID]              INT              NULL,
    [ProductID]             INT              NULL,
    [OrderQty]              INT              NULL,
    [CartonProductDiscount] NUMERIC (22, 18) NULL,
    CONSTRAINT [FK_tblCartonDetail_tblCartonMaster] FOREIGN KEY ([CartonID]) REFERENCES [dbo].[tblCartonMaster] ([CartonID]) ON DELETE CASCADE ON UPDATE CASCADE
);

