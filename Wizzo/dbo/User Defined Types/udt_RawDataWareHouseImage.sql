CREATE TYPE [dbo].[udt_RawDataWareHouseImage] AS TABLE (
    [ClickedDateTime] NVARCHAR (500) NULL,
    [ClickTagPhoto]   NVARCHAR (500) NULL,
    [PhotoName]       NVARCHAR (500) NULL,
    [PhotoPath]       NVARCHAR (500) NULL,
    [reasonRemark]    NVARCHAR (500) NULL,
    [Sstat]           NVARCHAR (500) NULL,
    [StoreID]         NVARCHAR (500) NULL,
    [ProductID]       NVARCHAR (500) NULL);

