CREATE TABLE [dbo].[tblPotentialDistributor_CompetitorBrand] (
    [NodeID]            INT           NOT NULL,
    [NodeType]          SMALLINT      NOT NULL,
    [CompetitorBrandID] INT           NULL,
    [OtherBrandCode]    INT           NULL,
    [OtherBrand]        VARCHAR (200) NULL
);

