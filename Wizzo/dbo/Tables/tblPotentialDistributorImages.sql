CREATE TABLE [dbo].[tblPotentialDistributorImages] (
    [NodeID]    INT           NOT NULL,
    [NodeType]  TINYINT       NOT NULL,
    [ImageType] TINYINT       CONSTRAINT [DF_tblPotentialDistributorImages_ImageType] DEFAULT ((0)) NULL,
    [ImageName] VARCHAR (100) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Cheque Number,2=GST Copy,3=Proprietor PAN,4=Partner1PAN,5=Partner2PAN,6=PartnerDeed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributorImages', @level2type = N'COLUMN', @level2name = N'ImageType';

