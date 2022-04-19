CREATE TYPE [dbo].[udt_OutletAdd] AS TABLE (
    [OutAddID]      INT            NULL,
    [OutAddTypeID]  INT            NULL,
    [StoreAddress1] VARCHAR (2000) NULL,
    [StoreAddress2] VARCHAR (2000) NULL,
    [CityID]        INT            NULL,
    [PinCode]       BIGINT         NULL,
    [flgAction]     TINYINT        NULL);

