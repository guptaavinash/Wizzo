CREATE TABLE [dbo].[tblTCOrderSchemeSlabSource_History] (
    [OrdSchemeSlabMappingID]  INT             NOT NULL,
    [OrderDetID]              INT             NOT NULL,
    [SchemeSlabBucketTypeID]  TINYINT         NOT NULL,
    [BenExceptionAssignedVal] NUMERIC (18, 4) NULL
);

