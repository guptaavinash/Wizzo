CREATE TABLE [dbo].[tblPDASyncStoreSpecialityType] (
    [StoreIDDB]  INT NOT NULL,
    [StoreSpcID] INT NOT NULL,
    CONSTRAINT [FK_tblPDASyncStoreSpecialityType_tblPDASyncStoreMappingMstr] FOREIGN KEY ([StoreIDDB]) REFERENCES [dbo].[tblPDASyncStoreMappingMstr] ([StoreIDDB]) ON DELETE CASCADE ON UPDATE CASCADE
);

