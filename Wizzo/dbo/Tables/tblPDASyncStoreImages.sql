CREATE TABLE [dbo].[tblPDASyncStoreImages] (
    [StoreIDDB]          INT           NOT NULL,
    [StoreImagename]     VARCHAR (500) NOT NULL,
    [ImageType]          TINYINT       NULL,
    [flgManagerUploaded] TINYINT       CONSTRAINT [DF_tblPDASyncStoreImages_flgManagerUploaded] DEFAULT ((0)) NULL,
    CONSTRAINT [FK_tblPDASyncStoreImages_tblPDASyncStoreMappingMstr] FOREIGN KEY ([StoreIDDB]) REFERENCES [dbo].[tblPDASyncStoreMappingMstr] ([StoreIDDB]) ON DELETE CASCADE ON UPDATE CASCADE
);

