CREATE TABLE [dbo].[tblPrdAttr_Brand] (
    [BrandId]   TINYINT      IDENTITY (1, 1) NOT NULL,
    [BrandName] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_tblPrdAttr_Brand] PRIMARY KEY CLUSTERED ([BrandId] ASC)
);

