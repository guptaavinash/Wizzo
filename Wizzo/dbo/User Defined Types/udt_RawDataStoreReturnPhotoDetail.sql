CREATE TYPE [dbo].[udt_RawDataStoreReturnPhotoDetail] AS TABLE (
    [StoreID]         NVARCHAR (500) NULL,
    [VisitID]         NVARCHAR (500) NULL,
    [ProductID]       NVARCHAR (500) NULL,
    [ClickedDateTime] NVARCHAR (500) NULL,
    [PhotoName]       NVARCHAR (500) NULL,
    [PhotoValidation] NVARCHAR (500) NULL,
    [PDAPhotoPath]    NVARCHAR (500) NULL,
    [OrderIDPDA]      NVARCHAR (500) NULL);

