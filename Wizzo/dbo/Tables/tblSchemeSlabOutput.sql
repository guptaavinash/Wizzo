CREATE TABLE [dbo].[tblSchemeSlabOutput] (
    [SchemeSlabID]    INT             NOT NULL,
    [flgBenefitType]  TINYINT         NULL,
    [strPrdFreePrd]   VARCHAR (MAX)   NULL,
    [BenifitDescr]    VARCHAR (MAX)   NULL,
    [BenifitDescrOrg] VARCHAR (MAX)   NULL,
    [Slab_Max_Limit]  NUMERIC (18, 2) CONSTRAINT [DF_tblSchemeSlabOutput_Slab_Max_Limit] DEFAULT ((0)) NOT NULL,
    [FileSetId]       BIGINT          NULL,
    CONSTRAINT [FK_tblSchemeSlabOutput_tblSchemeSlabDetails] FOREIGN KEY ([SchemeSlabID]) REFERENCES [dbo].[tblSchemeSlabDetails] ([SchemeSlabID]) ON DELETE CASCADE ON UPDATE CASCADE
);

