CREATE TABLE [dbo].[tblTCOrderSchemeSlabBenefit_History] (
    [OrdDetSchemeSlabMappingID] INT             NOT NULL,
    [OrdSchemeSlabMappingID]    INT             NOT NULL,
    [OrderDetID]                INT             NOT NULL,
    [FreeQty]                   INT             NULL,
    [DiscValue]                 NUMERIC (18, 4) NULL,
    [BenTypeId]                 INT             NOT NULL,
    [BenCost]                   NUMERIC (18, 4) NULL,
    [flgDiscOnTotAmt]           TINYINT         NOT NULL
);

