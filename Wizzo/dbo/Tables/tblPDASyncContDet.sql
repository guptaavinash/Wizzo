CREATE TABLE [dbo].[tblPDASyncContDet] (
    [StoreIDDB]    INT           NOT NULL,
    [Ownername]    VARCHAR (500) NULL,
    [OwnerMobNo]   BIGINT        NULL,
    [OwnerEmailID] VARCHAR (200) NULL,
    CONSTRAINT [FK_tblPDASyncContDet_tblPDASyncStoreMappingMstr] FOREIGN KEY ([StoreIDDB]) REFERENCES [dbo].[tblPDASyncStoreMappingMstr] ([StoreIDDB]) ON DELETE CASCADE ON UPDATE CASCADE
);

