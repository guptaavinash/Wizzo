CREATE TABLE [dbo].[tblTCOrderSchemeSlabMapping] (
    [OrdSchemeSlabMappingID] INT     IDENTITY (1, 1) NOT NULL,
    [SchemeSlabID]           INT     NOT NULL,
    [OrderID]                INT     NOT NULL,
    [SchemeTypeID]           INT     NOT NULL,
    [IsApply]                TINYINT DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblOrdSchemeSlabMapping] PRIMARY KEY CLUSTERED ([OrdSchemeSlabMappingID] ASC)
);

