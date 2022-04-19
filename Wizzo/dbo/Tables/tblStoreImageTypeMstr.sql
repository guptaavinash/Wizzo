CREATE TABLE [dbo].[tblStoreImageTypeMstr] (
    [StoreImageTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [ImageType]        INT           NULL,
    [Descr]            VARCHAR (500) NULL,
    [ChannelId]        TINYINT       NULL,
    CONSTRAINT [PK_tblStoreImageTypeMstr] PRIMARY KEY CLUSTERED ([StoreImageTypeId] ASC)
);

