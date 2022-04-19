CREATE TABLE [dbo].[tblSchemeSlabDetails] (
    [SchemeSlabID] INT             IDENTITY (1, 1) NOT NULL,
    [SchemeID]     INT             NOT NULL,
    [SlabDescr]    VARCHAR (MAX)   NULL,
    [SlabPrdStr]   VARCHAR (MAX)   NULL,
    [SlabDescrOrg] VARCHAR (MAX)   NULL,
    [SlabFrom]     SMALLDATETIME   NOT NULL,
    [SlabTo]       SMALLDATETIME   NULL,
    [flgActive]    TINYINT         NULL,
    [SlabCost]     NUMERIC (18, 4) NULL,
    [SlabBenCost]  NUMERIC (18, 4) NULL,
    [SlabBenPerc]  NUMERIC (18, 4) NULL,
    [FileSetId]    BIGINT          NULL,
    CONSTRAINT [PK_tblSchemeSlabDet] PRIMARY KEY CLUSTERED ([SchemeSlabID] ASC),
    CONSTRAINT [FK_tblSchemeSlabDetails_tblSchemeMaster] FOREIGN KEY ([SchemeID]) REFERENCES [dbo].[tblSchemeMaster] ([SchemeID]) ON DELETE CASCADE ON UPDATE CASCADE
);

