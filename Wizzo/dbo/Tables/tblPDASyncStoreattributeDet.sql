CREATE TABLE [dbo].[tblPDASyncStoreattributeDet] (
    [StoreIDDB]                INT           NOT NULL,
    [OutletTypeID]             INT           NULL,
    [OutletChannelID]          INT           NULL,
    [TaxNumber]                VARCHAR (50)  NULL,
    [Address]                  VARCHAR (500) NULL,
    [OutletSalesPersonname]    VARCHAR (200) NULL,
    [OutletSalesPersonContact] BIGINT        NULL,
    [IsSameWhatsappnumber]     TINYINT       NULL,
    [alternatewhatsappNo]      BIGINT        NULL,
    [IsGSTCompliance]          TINYINT       NULL,
    [STD]                      VARCHAR (10)  NULL,
    [LandLine]                 BIGINT        NULL,
    [OutletClassID]            INT           NULL,
    CONSTRAINT [FK_tblPDASyncStoreattributeDet_tblPDASyncStoreMappingMstr] FOREIGN KEY ([StoreIDDB]) REFERENCES [dbo].[tblPDASyncStoreMappingMstr] ([StoreIDDB]) ON DELETE CASCADE ON UPDATE CASCADE
);

