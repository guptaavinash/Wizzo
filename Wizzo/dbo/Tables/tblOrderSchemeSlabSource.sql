CREATE TABLE [dbo].[tblOrderSchemeSlabSource] (
    [OrdSchemeSlabMappingID]  INT            NOT NULL,
    [OrderDetID]              INT            NOT NULL,
    [SchemeSlabBucketTypeID]  TINYINT        NOT NULL,
    [BenExceptionAssignedVal] [dbo].[Amount] NULL,
    CONSTRAINT [PK_tblOrderSchemeSlabSource_!] PRIMARY KEY CLUSTERED ([OrdSchemeSlabMappingID] ASC, [OrderDetID] ASC),
    CONSTRAINT [FK_tblOrderSchemeSlabSource_tblOrderSchemeSlabMapping_1] FOREIGN KEY ([OrdSchemeSlabMappingID]) REFERENCES [dbo].[tblOrderSchemeSlabMapping] ([OrdSchemeSlabMappingID]) ON DELETE CASCADE ON UPDATE CASCADE
);

