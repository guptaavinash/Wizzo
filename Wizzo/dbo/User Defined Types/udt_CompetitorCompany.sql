CREATE TYPE [dbo].[udt_CompetitorCompany] AS TABLE (
    [CompetitorCompanyID] INT           NULL,
    [OtherCompanyCode]    VARCHAR (200) NULL,
    [OtherCompany]        VARCHAR (200) NULL,
    [SalesValue(Lacs)]    INT           NULL);

