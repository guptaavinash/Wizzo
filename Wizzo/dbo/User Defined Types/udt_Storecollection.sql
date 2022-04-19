CREATE TYPE [dbo].[udt_Storecollection] AS TABLE (
    [StoreID]           INT            NULL,
    [CollectionPending] [dbo].[Amount] NOT NULL,
    [CollectionDone]    [dbo].[Amount] NOT NULL);

