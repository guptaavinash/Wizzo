CREATE TABLE [dbo].[tblCompetitorCompanyMstr] (
    [CompetitorCompanyID] INT           IDENTITY (1, 1) NOT NULL,
    [CompetitorCompany]   VARCHAR (100) NOT NULL,
    [flgOther]            TINYINT       CONSTRAINT [DF_tblCompetitorCompanyMstr_flgOther] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblCompetitorCompanyMstr] PRIMARY KEY CLUSTERED ([CompetitorCompanyID] ASC)
);

