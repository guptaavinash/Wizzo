CREATE TYPE [dbo].[udt_PhoneRestartInfo] AS TABLE (
    [PrevStoreID]              NVARCHAR (200) NULL,
    [CurrStoreID]              NVARCHAR (200) NULL,
    [ActionDateTime]           DATETIME       NULL,
    [IsSavedOrSubmittedStore]  TINYINT        NULL,
    [IsMsgToRestartPopUpShown] TINYINT        NULL,
    [IsRestartDone]            TINYINT        NULL);

