CREATE TABLE [dbo].[tblOrderSchemeSlabMapping] (
    [OrdSchemeSlabMappingID] INT IDENTITY (1, 1) NOT NULL,
    [SchemeSlabID]           INT NOT NULL,
    [OrderID]                INT NOT NULL,
    [SchemeTypeID]           INT NOT NULL,
    CONSTRAINT [PK_tblOrdSchemeSlabMapping_1] PRIMARY KEY CLUSTERED ([OrdSchemeSlabMappingID] ASC)
);

