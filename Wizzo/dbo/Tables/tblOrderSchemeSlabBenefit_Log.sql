CREATE TABLE [dbo].[tblOrderSchemeSlabBenefit_Log] (
    [OrderLogID]                INT            NULL,
    [OrdDetSchemeSlabMappingID] INT            NOT NULL,
    [OrdSchemeSlabMappingID]    INT            NOT NULL,
    [OrderDetID]                INT            NOT NULL,
    [FreeQty]                   INT            NULL,
    [DiscValue]                 [dbo].[Amount] NULL,
    [BenTypeId]                 INT            NOT NULL,
    [BenCost]                   [dbo].[Amount] NULL,
    [flgDiscOnTotAmt]           TINYINT        CONSTRAINT [DF_tblOrderSchemeSlabBenefit_Log_flgDiscOnTotAmt_1] DEFAULT ((0)) NOT NULL
);

