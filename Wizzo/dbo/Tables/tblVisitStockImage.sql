CREATE TABLE [dbo].[tblVisitStockImage] (
    [StoreID]        INT           NULL,
    [VisitID]        INT           NULL,
    [Imagename]      VARCHAR (100) NULL,
    [ImageClickTime] DATETIME      NULL,
    [ImageType]      TINYINT       NULL,
    [StoreVisitCode] VARCHAR (100) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'3=Before,4=After', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblVisitStockImage', @level2type = N'COLUMN', @level2name = N'ImageType';

