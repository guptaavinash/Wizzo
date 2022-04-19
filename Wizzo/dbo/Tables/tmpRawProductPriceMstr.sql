CREATE TABLE [dbo].[tmpRawProductPriceMstr] (
    [Category]          VARCHAR (500)   NULL,
    [SKUCode]           VARCHAR (50)    NULL,
    [SKU]               VARCHAR (500)   NULL,
    [MRP]               NUMERIC (18, 2) NULL,
    [SKUShortDescr]     VARCHAR (500)   NULL,
    [PrcRegion]         VARCHAR (50)    NULL,
    [RLPWithTax]        NUMERIC (18, 2) NULL,
    [DLPWithTax]        NUMERIC (18, 2) NULL,
    [UOMValue]          NUMERIC (18, 2) NULL,
    [UOMType]           VARCHAR (50)    NULL,
    [RelConversionUnit] INT             NULL,
    [BoxUOMType]        VARCHAR (50)    NULL,
    [CustPrdWeightInGm] NUMERIC (18)    NULL
);

