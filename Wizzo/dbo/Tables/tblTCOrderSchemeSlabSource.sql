CREATE TABLE [dbo].[tblTCOrderSchemeSlabSource] (
    [OrdSchemeSlabMappingID]  INT             NOT NULL,
    [OrderDetID]              INT             NOT NULL,
    [SchemeSlabBucketTypeID]  TINYINT         NOT NULL,
    [BenExceptionAssignedVal] NUMERIC (18, 4) NULL,
    CONSTRAINT [PK_tblOrderSchemeSlabSource] PRIMARY KEY CLUSTERED ([OrdSchemeSlabMappingID] ASC, [OrderDetID] ASC),
    CONSTRAINT [FK_tblOrderSchemeSlabSource_tblOrderSchemeSlabMapping] FOREIGN KEY ([OrdSchemeSlabMappingID]) REFERENCES [dbo].[tblTCOrderSchemeSlabMapping] ([OrdSchemeSlabMappingID]) ON DELETE CASCADE ON UPDATE CASCADE
);

