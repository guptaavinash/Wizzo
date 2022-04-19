CREATE TABLE [dbo].[tblPDASyncAddressDet_History] (
    [StoreIDDB] INT            NOT NULL,
    [Address]   VARCHAR (500)  NULL,
    [Landmark]  VARCHAR (1000) NULL,
    [City]      VARCHAR (200)  NULL,
    [Pincode]   BIGINT         NULL,
    [District]  VARCHAR (200)  NULL,
    [State]     VARCHAR (200)  NULL,
    [CityId]    INT            NULL,
    [StateID]   INT            NULL
);

