CREATE TYPE [dbo].[udt_OutletDet] AS TABLE (
    [Storename]    VARCHAR (500) NULL,
    [FirmName]     VARCHAR (100) NULL,
    [EstDate]      INT           NULL,
    [IsLeased]     TINYINT       NULL,
    [OutNatureID]  INT           NULL,
    [OutOwnTypeID] INT           NULL,
    [OutChannelID] INT           NULL);

