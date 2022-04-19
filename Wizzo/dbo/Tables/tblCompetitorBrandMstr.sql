CREATE TABLE [dbo].[tblCompetitorBrandMstr] (
    [CompetitorBrandID] INT           IDENTITY (1, 1) NOT NULL,
    [CompetitorBrand]   VARCHAR (100) NOT NULL,
    [flgOther]          TINYINT       CONSTRAINT [DF_tblCompetitorBrandMstr_flgOther] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblCompetitorBrandMstr] PRIMARY KEY CLUSTERED ([CompetitorBrandID] ASC)
);

