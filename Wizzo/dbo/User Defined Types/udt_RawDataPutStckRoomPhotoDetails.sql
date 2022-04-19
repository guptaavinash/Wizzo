CREATE TYPE [dbo].[udt_RawDataPutStckRoomPhotoDetails] AS TABLE (
    [ClickedDateTime] NVARCHAR (500) NULL,
    [ClickTagPhoto]   NVARCHAR (500) NULL,
    [PhotoName]       NVARCHAR (500) NULL,
    [PhotoPath]       NVARCHAR (500) NULL,
    [Sstat]           NVARCHAR (500) NULL,
    [StoreID]         NVARCHAR (500) NULL,
    [TempId]          NVARCHAR (500) NULL,
    [FlagPhotoType]   NVARCHAR (10)  NULL);

