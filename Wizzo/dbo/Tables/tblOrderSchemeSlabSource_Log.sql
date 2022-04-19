CREATE TABLE [dbo].[tblOrderSchemeSlabSource_Log] (
    [OrderLogID]              INT            NULL,
    [OrdSchemeSlabMappingID]  INT            NOT NULL,
    [OrderDetID]              INT            NOT NULL,
    [SchemeSlabBucketTypeID]  TINYINT        NOT NULL,
    [BenExceptionAssignedVal] [dbo].[Amount] NULL
);

