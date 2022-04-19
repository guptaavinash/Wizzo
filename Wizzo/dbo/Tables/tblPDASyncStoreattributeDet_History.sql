CREATE TABLE [dbo].[tblPDASyncStoreattributeDet_History] (
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
    [OutletClassID]            INT           NULL
);

