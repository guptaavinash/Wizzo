CREATE TYPE [dbo].[StoreCategoryProductDetails] AS TABLE (
    [CategoryId]       INT        NOT NULL,
    [SubCategoryId]    INT        NOT NULL,
    [SubCategoryValue] FLOAT (53) NOT NULL);

