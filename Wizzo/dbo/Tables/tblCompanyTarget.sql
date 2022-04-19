CREATE TABLE [dbo].[tblCompanyTarget] (
    [CovNodeID]       INT            NULL,
    [CovNodeType]     SMALLINT       NULL,
    [PersonNodeID]    INT            NULL,
    [PersonNodeType]  SMALLINT       NULL,
    [PrimaryTarget]   NUMERIC (6, 2) NULL,
    [SecondaryTarget] NUMERIC (6, 2) NULL,
    [RptMonthYear]    INT            NULL
);

