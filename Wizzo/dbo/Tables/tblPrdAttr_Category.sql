CREATE TABLE [dbo].[tblPrdAttr_Category] (
    [CatId]   TINYINT       IDENTITY (1, 1) NOT NULL,
    [CatName] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_tblPrdAttr_Category] PRIMARY KEY CLUSTERED ([CatId] ASC)
);

