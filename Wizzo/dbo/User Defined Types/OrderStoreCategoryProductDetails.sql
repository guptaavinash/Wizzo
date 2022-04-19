CREATE TYPE [dbo].[OrderStoreCategoryProductDetails] AS TABLE (
    [CategoryNodeID]       INT           NOT NULL,
    [CategoryNodeType]     INT           NOT NULL,
    [Category]             VARCHAR (200) NOT NULL,
    [ProductTypeNodeID]    INT           NOT NULL,
    [ProductTypeNodeType]  INT           NOT NULL,
    [ProductType]          VARCHAR (200) NOT NULL,
    [IsCategorySeleted]    INT           NOT NULL,
    [IsSubCategorySeleted] INT           NOT NULL,
    [SubCategoryValue]     FLOAT (53)    NOT NULL);

