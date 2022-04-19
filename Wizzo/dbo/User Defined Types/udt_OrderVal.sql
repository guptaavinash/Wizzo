CREATE TYPE [dbo].[udt_OrderVal] AS TABLE (
    [TotLineOrderVal]  [dbo].[Amount] NOT NULL,
    [TotLineLevelDisc] [dbo].[Amount] NOT NULL,
    [TotOrderVal]      [dbo].[Amount] NOT NULL,
    [TotDiscVal]       [dbo].[Amount] NOT NULL,
    [TotOrderValWDisc] [dbo].[Amount] NOT NULL,
    [TotTaxVal]        [dbo].[Amount] NOT NULL,
    [NetOrderValue]    [dbo].[Amount] NOT NULL,
    [ActDiscVal]       [dbo].[Amount] NOT NULL);

