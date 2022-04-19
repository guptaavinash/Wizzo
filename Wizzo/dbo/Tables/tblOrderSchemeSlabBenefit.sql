CREATE TABLE [dbo].[tblOrderSchemeSlabBenefit] (
    [OrdDetSchemeSlabMappingID] INT            IDENTITY (1, 1) NOT NULL,
    [OrdSchemeSlabMappingID]    INT            NOT NULL,
    [OrderDetID]                INT            NOT NULL,
    [FreeQty]                   INT            NULL,
    [DiscValue]                 [dbo].[Amount] NULL,
    [BenTypeId]                 INT            NOT NULL,
    [BenCost]                   [dbo].[Amount] NULL,
    [flgDiscOnTotAmt]           TINYINT        DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblOrdDetailSchemeSlabMapping_1] PRIMARY KEY CLUSTERED ([OrdDetSchemeSlabMappingID] ASC),
    CONSTRAINT [FK_tblOrdDetailSchemeSlabMapping_tblOrdSchemeSlabMapping_1] FOREIGN KEY ([OrdSchemeSlabMappingID]) REFERENCES [dbo].[tblOrderSchemeSlabMapping] ([OrdSchemeSlabMappingID]) ON DELETE CASCADE ON UPDATE CASCADE
);

