CREATE TYPE [dbo].[udt_GPSInfo] AS TABLE (
    [StoreID]          VARCHAR (100)    NULL,
    [Address]          VARCHAR (500)    NULL,
    [Distance]         NUMERIC (38, 6)  NULL,
    [AllProviderData]  VARCHAR (500)    NULL,
    [GPSLatitude]      NUMERIC (20, 16) NULL,
    [GPSLongitude]     NUMERIC (20, 16) NULL,
    [GPSAccuracy]      VARCHAR (100)    NULL,
    [GPSAddress]       VARCHAR (500)    NULL,
    [NetworkLatitude]  NUMERIC (20, 16) NULL,
    [NetworkLongitude] NUMERIC (20, 16) NULL,
    [NetworkAccuracy]  VARCHAR (100)    NULL,
    [NetworkAddress]   VARCHAR (500)    NULL,
    [FusedLatitude]    NUMERIC (20, 16) NULL,
    [FusedLongitude]   NUMERIC (20, 16) NULL,
    [FusedAccuracy]    VARCHAR (100)    NULL,
    [FusedAddress]     VARCHAR (500)    NULL);

