CREATE TABLE [dbo].[tblPDASyncAddressDet] (
    [StoreIDDB] INT            NOT NULL,
    [Address]   VARCHAR (500)  NULL,
    [Landmark]  VARCHAR (1000) NULL,
    [City]      VARCHAR (200)  NULL,
    [Pincode]   BIGINT         NULL,
    [District]  VARCHAR (200)  NULL,
    [State]     VARCHAR (200)  NULL,
    [CityId]    INT            NULL,
    [StateID]   INT            NULL,
    CONSTRAINT [FK_tblPDASyncAddressDet_tblPDASyncStoreMappingMstr] FOREIGN KEY ([StoreIDDB]) REFERENCES [dbo].[tblPDASyncStoreMappingMstr] ([StoreIDDB]) ON DELETE CASCADE ON UPDATE CASCADE
);

