CREATE TYPE [dbo].[udt_Storebasicdetails] AS TABLE (
    [Storename]                VARCHAR (500) NULL,
    [Taxnumber]                VARCHAR (20)  NULL,
    [OutletSalesPersonname]    VARCHAR (200) NULL,
    [OutletSalesPersonContact] BIGINT        NULL,
    [StoreChannelID]           INT           NULL);

