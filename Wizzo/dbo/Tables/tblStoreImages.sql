CREATE TABLE [dbo].[tblStoreImages] (
    [StoreImageId]       INT           IDENTITY (1, 1) NOT NULL,
    [StoreImageTypeId]   INT           NOT NULL,
    [StoreID]            INT           NOT NULL,
    [StoreImagename]     VARCHAR (500) NOT NULL,
    [ImageType]          TINYINT       NOT NULL,
    [flgManagerUploaded] TINYINT       NULL,
    CONSTRAINT [PK_tblStoreImages] PRIMARY KEY CLUSTERED ([StoreImageId] ASC),
    CONSTRAINT [FK_tblStoreImages_tblStoreMaster] FOREIGN KEY ([StoreID]) REFERENCES [dbo].[tblStoreMaster] ([StoreID]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Shop Sign board,2=Shop Front,3=manager businesscard,4=Chef businesscard,5=Owner businesscard', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblStoreImages', @level2type = N'COLUMN', @level2name = N'ImageType';

