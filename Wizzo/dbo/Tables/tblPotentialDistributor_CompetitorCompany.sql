CREATE TABLE [dbo].[tblPotentialDistributor_CompetitorCompany] (
    [NodeID]              INT           NOT NULL,
    [NodeType]            SMALLINT      NOT NULL,
    [CompetitorCompanyID] INT           NULL,
    [OtherCompanyCode]    INT           NULL,
    [OtherCompany]        VARCHAR (200) NULL,
    [SalesValue(Lacs)]    INT           NULL
);

