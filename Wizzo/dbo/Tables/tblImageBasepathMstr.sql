CREATE TABLE [dbo].[tblImageBasepathMstr] (
    [ApplicationType] INT           NULL,
    [ImageType]       INT           NULL,
    [BasePath]        VARCHAR (500) NULL,
    [Level]           TINYINT       NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DSR,SO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblImageBasepathMstr', @level2type = N'COLUMN', @level2name = N'ApplicationType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Selfie,2=Signature', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblImageBasepathMstr', @level2type = N'COLUMN', @level2name = N'ImageType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Development,2=Test,3=Live,4=Staging', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblImageBasepathMstr', @level2type = N'COLUMN', @level2name = N'Level';

