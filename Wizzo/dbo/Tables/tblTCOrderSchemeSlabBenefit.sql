CREATE TABLE [dbo].[tblTCOrderSchemeSlabBenefit] (
    [OrdDetSchemeSlabMappingID] INT             IDENTITY (1, 1) NOT NULL,
    [OrdSchemeSlabMappingID]    INT             NOT NULL,
    [OrderDetID]                INT             NOT NULL,
    [FreeQty]                   INT             NULL,
    [DiscValue]                 NUMERIC (18, 4) NULL,
    [BenTypeId]                 INT             NOT NULL,
    [BenCost]                   NUMERIC (18, 4) NULL,
    [flgDiscOnTotAmt]           TINYINT         DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblOrdDetailSchemeSlabMapping] PRIMARY KEY CLUSTERED ([OrdDetSchemeSlabMappingID] ASC),
    CONSTRAINT [FK_tblOrdDetailSchemeSlabMapping_tblOrdSchemeSlabMapping] FOREIGN KEY ([OrdSchemeSlabMappingID]) REFERENCES [dbo].[tblTCOrderSchemeSlabMapping] ([OrdSchemeSlabMappingID]) ON DELETE CASCADE ON UPDATE CASCADE
);

