CREATE TYPE [dbo].[udt_RawDataStoreClosePhotoDetail] AS TABLE (
    [StoreID]         NVARCHAR (500) NULL,
    [VisitID]         NVARCHAR (500) NULL,
    [ClickedDateTime] NVARCHAR (500) NULL,
    [PhotoName]       NVARCHAR (500) NULL,
    [PDAPhotoPath]    NVARCHAR (500) NULL,
    [Sstat]           NVARCHAR (500) NULL,
    [StoreVisitCode]  NVARCHAR (500) NULL);

